unit uFBParamDescription;

interface

uses
  uIBFBGlobals, uIB2007;


type
  paramdsc = record
    dsc_dtype : Byte;
    dsc_scale : ShortInt;
    dsc_length : ISC_USHORT;
    dsc_sub_type : Short;
    dsc_flags : ISC_USHORT;
    dsc_address : Pointer;
  end;

  TParamDsc = paramdsc;
  PParamDsc = ^paramdsc;

  paramvary = record
    vary_length : ISC_USHORT;
    vary_string : array[0..0] of AnsiChar;
  end;

  TParamVary = paramvary;
  PParamVary = ^paramvary;

const
  DSC_null = 1;
  DSC_no_subtype = 2;
  DSC_nullable = 4;

  dtype_unknown = 0;
  dtype_text = 1;
  dtype_cstring = 2;
  dtype_varying = 3;

  dtype_packed = 6;
  dtype_byte = 7;
  dtype_short = 8;
  dtype_long = 9;
  dtype_quad = 10;
  dtype_real = 11;
  dtype_double = 12;
  dtype_d_float = 13;
  dtype_sql_date = 14;
  dtype_sql_time = 15;
  dtype_timestamp = 16;
  dtype_blob = 17;
  dtype_array = 18;
  dtype_int64 = 19;
  dtype_dbkey = 20;
  DTYPE_TYPE_MAX = 21;


function ParamIsNull(AParam : PParamDsc) : Boolean;

function NewParamDsc : PParamDSC;

implementation

function ParamIsNull(AParam : PParamDsc) : Boolean;
begin
  Result := (AParam = nil) or
            (AParam^.dsc_address = nil) or
            (AParam^.dsc_flags and DSC_null > 0);
end;

function NewParamDsc : PParamDSC;
begin
  Result :=ib_util_malloc(sizeof(paramdsc));
  FillChar(Result^, sizeof(paramdsc), #0);
end;

end.
