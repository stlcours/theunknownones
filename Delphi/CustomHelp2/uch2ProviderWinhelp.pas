unit uch2ProviderWinhelp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, ToolWin, uch2FrameHelpItemDecoration, StdCtrls,
  Spin, ExtCtrls, uch2Main, Registry, Contnrs, StrUtils;

type
  Tch2WinhelpItem = class(TObject)
  public
    Name : String;
    FileName : String;
    Deco : Tch2HelpItemDecoration;
    GUID : TGUID;

    constructor Create();

    procedure Load(ARegistry : TRegistry);
    procedure Save(ARegistry : TRegistry);
  end;

  Tch2ProviderWinhelp = class(TInterfacedObject, Ich2Provider)
  private
    FPriority : Integer;
    FItems: TObjectList;

    procedure LoadSettings;
    procedure SaveSettings;
    function GetItem(AIndex: Integer): Tch2WinhelpItem;
  public

    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;

    {$REGION 'Ich2Provider'}
    function GetGUID : TGUID;
    function GetDescription : String;
    function GetName : String;

    procedure ProvideHelp(AKeyword : String; AGUI : Ich2GUI);
    procedure Configure;

    function GetPriority : Integer;
    procedure SetPriority(ANewPriority : Integer);
    {$ENDREGION}

    property Items : TObjectList read FItems;
    property Item[AIndex : Integer] : Tch2WinhelpItem read GetItem;
  end;


  Tch2FormConfigWinhelp = class(TForm)
    Panel1: TPanel;
    btn_OK: TButton;
    GroupBox2: TGroupBox;
    LV: TListView;
    Panel2: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label8: TLabel;
    ed_Name: TEdit;
    ed_File: TEdit;
    frame_Deco: Tch2FrameHelpItemDecoration;
    ToolBar1: TToolBar;
    btn_Add: TToolButton;
    btn_Del: TToolButton;
    btn_FindFile: TButton;
    dlg_SelectFile: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure LVSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure btn_AddClick(Sender: TObject);
    procedure btn_DelClick(Sender: TObject);
    procedure ed_NameChange(Sender: TObject);
    procedure ed_FileChange(Sender: TObject);
    procedure btn_FindFileClick(Sender: TObject);
  private
    FProvider : Tch2ProviderWinhelp;

    procedure OnDecoChange(Sender : TObject);
  public
    class function Execute(AProvider : Tch2ProviderWinhelp) : Boolean;
  end;

implementation

uses uch2Data;

{$R *.dfm}
{$I CustomHelp2.inc}

const
  Settings_Value_Priority = 'Priority';
  Settings_Value_Name = 'Name';
  Settings_Value_File = 'File';
  Settings_Key_Files = '\Files';
  Settings_Value_GUID = 'GUID';

type
  Tch2HIWinhelpItem = class(TInterfacedObject, Ich2HelpItem)
  private
    FItem : Tch2WinhelpItem;
    FKeyword : String;
  public
    constructor Create(AItem : Tch2WinhelpItem; AKeyword : String);

    {$REGION 'Ich2HelpItem'}
    function GetGUID : TGUID;
    function GetCaption : String;
    function GetDescription : String;
    function GetDecoration : Tch2HelpItemDecoration;
    function GetFlags : Tch2HelpItemFlags;
    procedure ShowHelp;
    {$ENDREGION}
  end;

{ Tch2WinhelpItem }

constructor Tch2WinhelpItem.Create;
begin
  CreateGUID(GUID);
end;

procedure Tch2WinhelpItem.Load(ARegistry: TRegistry);
begin
  Deco.LoadFromRegistry(ARegistry);

  if ARegistry.ValueExists(Settings_Value_Name) then
    Name := ARegistry.ReadString(Settings_Value_Name)
  else
    Name := EmptyStr;

  if ARegistry.ValueExists(Settings_Value_File) then
    FileName := ARegistry.ReadString(Settings_Value_File)
  else
    FileName := EmptyStr;

  if ARegistry.ValueExists(Settings_Value_GUID) then
    GUID := StringToGUID(ARegistry.ReadString(Settings_Value_GUID));
end;

procedure Tch2WinhelpItem.Save(ARegistry: TRegistry);
begin
  Deco.SaveToRegistry(ARegistry);

  ARegistry.WriteString(Settings_Value_Name, Name);
  ARegistry.WriteString(Settings_Value_File, FileName);

  ARegistry.WriteString(Settings_Value_GUID, GUIDToString(GUID));
end;

{ Tch2ProviderWinhelp }

procedure Tch2ProviderWinhelp.AfterConstruction;
begin
  inherited;

  FItems := TObjectList.Create(true);

  LoadSettings;
end;

procedure Tch2ProviderWinhelp.BeforeDestruction;
begin
  SaveSettings;

  FItems.Free;

  inherited;
end;

procedure Tch2ProviderWinhelp.Configure;
begin
  Tch2FormConfigWinhelp.Execute(Self);
  SaveSettings;
end;

function Tch2ProviderWinhelp.GetDescription: String;
begin
  Result := 'Open *.hlp - files (requires winhlp32.exe)'
end;

function Tch2ProviderWinhelp.GetGUID: TGUID;
const
  g : TGUID = '{0EC31C5A-6088-47EF-A76E-DEE5B9B6BBC5}';
begin
  Result := g;
end;

function Tch2ProviderWinhelp.GetItem(AIndex: Integer): Tch2WinhelpItem;
begin
  Result := Tch2WinhelpItem(FItems[AIndex]);
end;

function Tch2ProviderWinhelp.GetName: String;
begin
  Result := 'Winhelp';
end;

function Tch2ProviderWinhelp.GetPriority: Integer;
begin
  Result := FPriority;
end;

procedure Tch2ProviderWinhelp.LoadSettings;
var
  Reg : TRegistry;
  sl : TStringList;
  s : String;
  item : Tch2WinhelpItem;
begin
  inherited;

  sl := TStringList.Create;
  Reg := TRegistry.Create(KEY_ALL_ACCESS);
  try
    if Reg.OpenKey(ch2Main.RegRootKeyProvider[GetGUID], true) then
    begin
      if Reg.ValueExists(Settings_Value_Priority) then
        FPriority := reg.ReadInteger(Settings_Value_Priority)
      else
        FPriority := 0;

      Reg.CloseKey;
    end;

    if Reg.OpenKey(ch2Main.RegRootKeyProvider[GetGUID] + Settings_Key_Files, true) then
    begin
      Reg.GetKeyNames(sl);
      Reg.CloseKey;
    end;

    for s in sl do
    begin
      if Reg.OpenKey(ch2Main.RegRootKeyProvider[GetGUID] + Settings_Key_Files + '\' + s, false) then
      begin
        item := Tch2WinhelpItem.Create;
        item.Load(Reg);
        FItems.Add(item);
        Reg.CloseKey;
      end;
    end;

  finally
    sl.Free;
    Reg.Free;
  end;

end;

procedure Tch2ProviderWinhelp.ProvideHelp(AKeyword: String; AGUI: Ich2GUI);
var
  o : Pointer;
  i : Tch2WinhelpItem absolute o;
begin
  for o in Items do
  begin
    AGUI.AddHelpItem(Tch2HIWinhelpItem.Create(i, AKeyword));
  end;
end;

procedure Tch2ProviderWinhelp.SaveSettings;
var
  Reg : TRegistry;
  sl : TStringList;
  s : String;
  idx : Integer;
begin
  sl := TStringList.Create;
  Reg := TRegistry.Create(KEY_ALL_ACCESS);
  try
    if Reg.OpenKey(ch2Main.RegRootKeyProvider[GetGUID], true) then
    begin
      Reg.WriteInteger(Settings_Value_Priority, FPriority);

      Reg.CloseKey;
    end;

    if Reg.OpenKey(ch2Main.RegRootKeyProvider[GetGUID] + Settings_Key_Files, true) then
    begin
      Reg.GetKeyNames(sl);

      for s in sl do
      begin
        Reg.DeleteKey(ch2Main.RegRootKeyProvider[GetGUID] + Settings_Key_Files + '\' + s);
      end;

      Reg.CloseKey;
    end;

    for idx := 0 to FItems.Count - 1 do
    begin
      if Reg.OpenKey(ch2Main.RegRootKeyProvider[GetGUID] + Settings_Key_Files + '\' + IntToStr(idx), true) then
      begin
        Item[idx].Save(Reg);
        Reg.CloseKey;
      end;
    end;

  finally
    sl.Free;
    Reg.Free;
  end;

end;

procedure Tch2ProviderWinhelp.SetPriority(ANewPriority: Integer);
var
  Reg : TRegistry;
begin
  FPriority:=ANewPriority;

  Reg := TRegistry.Create(KEY_ALL_ACCESS);
  try
    if Reg.OpenKey(ch2Main.RegRootKeyProvider[GetGUID], true) then
    begin
      Reg.WriteInteger(Settings_Value_Priority, FPriority);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

{ Tch2FormConfigWinhelp }

procedure Tch2FormConfigWinhelp.btn_AddClick(Sender: TObject);
var
  item : Tch2WinhelpItem;
begin
  item := Tch2WinhelpItem.Create;
  item.Name := IfThen(ed_Name.Text = '', 'NewItem', ed_Name.Text);
  item.FileName := ed_File.Text;
  item.Deco := frame_Deco.Decoration;
  FProvider.Items.Add(item);
  with lv.Items.Add do
  begin
    Data := item;
    Caption := item.Name;
    SubItems.Add(item.FileName);
    Selected := true;
  end;
end;

procedure Tch2FormConfigWinhelp.btn_DelClick(Sender: TObject);
begin
  if Assigned(lv.Selected) then
  begin
    FProvider.Items.Remove(lv.Selected.Data);
    lv.DeleteSelected;
  end;
end;

procedure Tch2FormConfigWinhelp.btn_FindFileClick(Sender: TObject);
begin
  if dlg_SelectFile.Execute then
    ed_File.Text := dlg_SelectFile.FileName;
end;

procedure Tch2FormConfigWinhelp.ed_FileChange(Sender: TObject);
begin
  if Assigned(lv.Selected) then
  begin
    Tch2WinhelpItem(lv.Selected.Data).FileName := ed_File.Text;
    lv.Selected.SubItems[0] := ed_File.Text;
  end;
end;

procedure Tch2FormConfigWinhelp.ed_NameChange(Sender: TObject);
begin
  if Assigned(lv.Selected) then
  begin
    Tch2WinhelpItem(lv.Selected.Data).Name := ed_Name.Text;
    lv.Selected.Caption := ed_Name.Text;
    frame_Deco.Caption := ed_Name.Text;
  end;
end;

class function Tch2FormConfigWinhelp.Execute(
  AProvider: Tch2ProviderWinhelp): Boolean;
var
  form : Tch2FormConfigWinhelp;
begin
  form := Tch2FormConfigWinhelp.Create(nil);
  try
    form.FProvider := AProvider;
    Result := IsPositiveResult(form.ShowModal);
  finally
    form.Free;
  end;
end;

procedure Tch2FormConfigWinhelp.FormShow(Sender: TObject);
var
  o : Pointer;
  item : Tch2WinhelpItem absolute o;
begin
  for o in FProvider.Items do
  begin
    with lv.Items.Add do
    begin
      Caption := item.Name;
      SubItems.Add(item.FileName);
      Data := item;
    end;
  end;

  frame_Deco.OnChange := OnDecoChange;
end;

procedure Tch2FormConfigWinhelp.LVSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected then
  begin
    with Tch2WinhelpItem(Item.Data) do
    begin
      ed_Name.Text := Name;
      ed_File.Text := FileName;
      frame_Deco.Decoration := Deco;
      frame_Deco.Caption := Name;
    end;
  end
  else
  begin
    ed_Name.Text := EmptyStr;
    ed_File.Text := EmptyStr;
    frame_Deco.ResetToDefault;
  end;
end;

procedure Tch2FormConfigWinhelp.OnDecoChange(Sender: TObject);
begin
  if Assigned(lv.Selected) then
  begin
    Tch2WinhelpItem(lv.Selected.Data).Deco := frame_Deco.Decoration;
  end;
end;

{ Tch2HIWinhelpItem }

constructor Tch2HIWinhelpItem.Create(AItem: Tch2WinhelpItem; AKeyword : String);
begin
  inherited Create;

  FItem := AItem;
  FKeyword := AKeyword;
end;

function Tch2HIWinhelpItem.GetCaption: String;
begin
  Result := FItem.Name;
end;

function Tch2HIWinhelpItem.GetDecoration: Tch2HelpItemDecoration;
begin
  Result := FItem.Deco;
end;

function Tch2HIWinhelpItem.GetDescription: String;
begin
  Result := FItem.FileName;
end;

function Tch2HIWinhelpItem.GetFlags: Tch2HelpItemFlags;
begin
  Result := [ifProvidesHelp, ifSaveStats];
end;

function Tch2HIWinhelpItem.GetGUID: TGUID;
begin
  Result := FItem.GUID;
end;

procedure Tch2HIWinhelpItem.ShowHelp;
begin
  ch2Main.ShellOpen('winhlp32.exe', '-k ' + StringReplace(FKeyword, '.', ',', [rfReplaceAll]) + ' "' + FItem.FileName + '"');
end;

initialization
  {$IFDEF ProviderWinhelp}ch2Main.RegisterProvider(Tch2ProviderWinhelp.Create);{$ENDIF}

end.