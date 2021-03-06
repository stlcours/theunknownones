object ch2FormConfigure: Tch2FormConfigure
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Configure CustomHelp'
  ClientHeight = 626
  ClientWidth = 947
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 17
  object GroupBox1: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 941
    Height = 351
    Align = alClient
    Caption = 
      'Helpprovider (doubleclick to configure / drag and drop to change' +
      ' priority)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    object lv_Provider: TListView
      AlignWithMargins = True
      Left = 5
      Top = 23
      Width = 931
      Height = 323
      Align = alClient
      Columns = <
        item
          Caption = 'Name'
          Width = 196
        end
        item
          AutoSize = True
          Caption = 'Description'
        end>
      DragMode = dmAutomatic
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = lv_ProviderDblClick
      OnDragDrop = lv_ProviderDragDrop
      OnDragOver = lv_ProviderDragOver
    end
  end
  object GroupBox2: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 360
    Width = 941
    Height = 225
    Align = alBottom
    Caption = 'GUI'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    object lv_GUI: TListView
      AlignWithMargins = True
      Left = 5
      Top = 23
      Width = 931
      Height = 197
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          Caption = 'Name'
          Width = 196
        end
        item
          AutoSize = True
          Caption = 'Description'
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      TabOrder = 0
      ViewStyle = vsReport
      OnChange = lv_GUIChange
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 588
    Width = 947
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btn_Cancel: TButton
      AlignWithMargins = True
      Left = 846
      Top = 3
      Width = 98
      Height = 32
      Align = alRight
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object btn_OK: TButton
      AlignWithMargins = True
      Left = 742
      Top = 3
      Width = 98
      Height = 32
      Align = alRight
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = btn_OKClick
    end
  end
end
