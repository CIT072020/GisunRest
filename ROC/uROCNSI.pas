unit uROCNSI;

interface

uses
  SysUtils,
  superobject;

const
  // ���� (���� ������������) � ROC
  S_SYSDOCTYPE = -2;
  S_SYSORGAN   = -5;
  S_SEX        = 32;
  S_COUNTRY    = 8;
  // ��� ��������� ������������� ��������
  S_IDDOC      = 37;
  S_DOCISORG   = 24;
  S_REGTYPE    = 500;

  KEY_NULL  = 1;
  KEY_EMPTY = 2;
  KEY_VAL   = 3;

  GET_VAL = 1;
  SET_VAL = 2;

type
  TNsiRoc = class
    private
      function RSupObj : ISuperObject;
      procedure WSupObj(const x : ISuperObject);
    public
    property SO : ISuperObject read RSupObj write WSupObj;

    class function SysDocType(ICode : Integer = 8; Func : Integer = SET_VAL) : String;
    class function Sex(xCode: Variant; Func: Integer = SET_VAL): String;
    class function Country(ICode : Integer = 11200001; Func : Integer = SET_VAL) : String;
    class function SysOrgan(ICode : Integer = 0) : String;
    class function DocType(ICode : Integer = 54100001) : String;
    class function PaspOrg(ICode : Integer = 0; OrgName : string = '') : String;
    class function RegistrType(ICode : Integer = 1) : String;
  end;

implementation

var
  SO : ISuperObject;

function TNsiRoc.RSupObj: ISuperObject;
begin
  Result := SO;
end;

procedure TNsiRoc.WSupObj(const x : ISuperObject);
begin
  SO := x;
end;

//-------------------------------------------------------
// ������ JSON-������� ��� �������� ��������� ���������
function UniKey(nType : Integer; nValue : Int64; ValType : integer = KEY_VAL) : String;
begin
  Result := 'null';
  if (ValType = KEY_VAL) then
    Result := Format('{"klUniPK":{"type":%d,"code":%d}}', [nType, nValue])
  else if (ValType = KEY_EMPTY) then
    Result := Format('{"klUniPK":{"type":%d,"code":0}}', [nType]);
end;

// SYS-��� ���������
class function TNsiRoc.SysDocType(ICode : Integer = 8; Func : Integer = SET_VAL) : String;
begin
  if (Func = SET_VAL) then begin
    if (ICode = 0) then
    //Default - ����� 19-20
      ICode := 8;
    Result := UniKey(S_SYSDOCTYPE, ICode);
  end else begin

  end;
end;

// �������/�������
class function TNsiRoc.Sex(xCode: Variant; Func: Integer = SET_VAL): String;
var
  n : Int64;
begin
  if (Func = SET_VAL) then begin
    if (UpperCase(xCode) = '�') then n := 21000001
    else n := 21000002;
    Result := UniKey(S_SEX, n);
  end else begin
    if (xCode = 21000001) then
      Result := '�'
    else
      Result := '�';
  end;
end;

// ��� ������(�����������, ...)
class function TNsiRoc.Country(ICode : Integer = 11200001; Func : Integer = SET_VAL) : String;
begin
  if (Func = SET_VAL) then begin
    if (ICode = 0) then
      // Default - Belarus
      ICode := 11200001;
    Result := UniKey(S_COUNTRY, ICode);
  end else begin

  end;
end;

// ��� ��������� ������ ��� (� ����)
class function TNsiRoc.SysOrgan(ICode : Integer = 0) : String;
begin
  Result := UniKey(S_SYSORGAN, ICode);
end;

// ��� ��������� ������������� ��������
class function TNsiRoc.DocType(ICode : Integer = 54100001) : String;
begin
  if (ICode = 0) then
    // Default - ������� ��
    ICode := 54100001;
  Result := UniKey(S_IDDOC, ICode);
end;

// ����� ������ ��������� ������������� ��������
class function TNsiRoc.PaspOrg(ICode : Integer = 0; OrgName : string = '') : String;
begin
  if (ICode = 0) then begin
    // ��������, ���� � ���������� ����
  end;
  Result := UniKey(S_DOCISORG, ICode);
end;

// ��� ����������� ������� (����., ����.)
class function TNsiRoc.RegistrType(ICode : Integer = 1) : String;
begin
  if (ICode = 0) then
    // Default - ����������
    ICode := 1;
  Result := UniKey(S_REGTYPE, ICode);
end;




















end.
