unit uUNDTO;

interface

uses
  SysUtils,
  Classes,
  DB,
  Variants,
  superobject,
  superdate,
  FuncPr,
  uROCService;

type
  // ������/������ ����� � ������������ ������
  TPersDataDTO = class
  private
    // MemTable with Docs
    FDoc : TDataSet;
    //FChild : TDataSet;
    //FChildSepar : Boolean;
    FSO : ISuperObject;
    //FChildList : TStringList;
    FJSONStream: TStringStream;

    function GetFI(sField: String): Integer;
    function GetFS(sField: String): String;
    function GetFD(sField: String): TDateTime;
    function GetFB(sField: String): String;
    // ��� �� ����������� ���������
    //function GetCode(sField: String; KeyField: string = 'klUniPK'): Variant;
    //function GetName(sField: String): string;

    // �������� � JSON-�����
    procedure AddNum(const ss1: string; ss2: Variant); overload;
    procedure AddNum(const ss1: string); overload;
    procedure AddStr(const ss1: string; ss2: String = '');
    procedure AddDJ(ss1: String; dValue: TDateTime);

    function MakeCover(dsDoc: TDataSet; StreamDoc: TStringStream): Boolean;

    // ���������� ������
    //procedure GetPasp;
    // ����� ��������
    //procedure GetPlaceOfBirth;
    // ����� ����������
    //procedure GetPlaceOfLiving;
    // ����������� ������
    //procedure GetByVer;
    // ����� �����������
    //procedure GetROC(SODsdAddr: ISuperObject);
    // ����� 19-20
    //procedure GetForm19_20(SOf20 : ISuperObject; MasterKey: Variant);
    // ������ �� ����� �� ����������� �������
    //procedure GetChild(SOA: TSuperArray; MasterKey: Variant);

  public

    // ������ ���������� �� SuperObject ��������� � MemTable
    //function GetDocList(SOArr: ISuperObject): Boolean;
    function MemDoc2JSON(dsDoc: TDataSet; dsChild: TDataSet; StreamDoc: TStringStream; NeedUp : Boolean): Boolean;

    //constructor Create(MTDoc, MTChild : TDataSet; ChSep : Boolean = False);
    //destructor Destroy;

    //class function GetNsi(SOArr: ISuperObject; Nsi: TkbmMemTable; EmpTbl: Boolean = True): Integer;
  end;


implementation



// �������� ����� �� MemTable
function TPersDataDTO.GetFI(sField: String): Integer;
begin
  try
    Result := FDoc.FieldByName(sField).AsInteger;
  except
    Result := null;
  end;
end;

// ��������� �� MemTable
function TPersDataDTO.GetFS(sField: String): String;
begin
  Result := FDoc.FieldByName(sField).AsString;
end;

// ���� �� MemTable
function TPersDataDTO.GetFD(sField: String): TDateTime;
begin
  Result := FDoc.FieldByName(sField).AsDateTime;
end;

// ���������� �� MemTable
function TPersDataDTO.GetFB(sField: String): String;
begin
  try
    Result := Iif(FDoc.FieldByName(sField).AsBoolean, 'true', 'false');
  except
    Result := null;
  end;
end;


// �������� ����� � JSON-�����
// �������� ����������
// �������� �������� �����
procedure TPersDataDTO.AddNum(const ss1: string; ss2: Variant);
begin
  ss2 := VarToStrDef(ss2, 'null');
  FJSONStream.WriteString('"' + ss1 + '":' + ss2 + ',');
end;

// �������� NULL
procedure TPersDataDTO.AddNum(const ss1: string);
begin
  AddNum(ss1, null);
end;

// �������� ������
procedure TPersDataDTO.AddStr(const ss1: string; ss2: String = '');
begin
  if (Pos('"', ss2) > 0) then
    ss2 := StringReplace(ss2, '"', '\"', [rfReplaceAll]);
  ss2 := '"' + ss2 + '"';
  FJSONStream.WriteString('"' + ss1 + '": ' + ss2 + ',');
end;
  // �������� ����

procedure TPersDataDTO.AddDJ(ss1: String; dValue: TDateTime);
var
  sss : string;
begin
  if (dValue = 0) or (Dtos(dValue) = '01.01.1970') then
    sss := 'null'
  else
    sss := IntToStr(Delphi2JavaDate(dValue));
  FJSONStream.WriteString('"' + ss1 + '": ' + sss + ',');
end;









function TPersDataDTO.MakeCover(dsDoc: TDataSet; StreamDoc: TStringStream): Boolean;
var
  s: string;
begin
  try
    FJSONStream.WriteString('"cover":{' + '"message_type":{"code": "88","type":-2},' + '"message_source":{"code": "7689","type": 80},' + '"agreement":{"operator_info": "����������� �����", "target":"����������� ������������ ������","rights": [201,703,208,480,481,482,490,491,527,528,252,465,466,516,517],' + '"issue_date": "2019-12-07T13:22:09.619+03:00", "expiry_date": "2023-12-07T13:22:09.619+03:00", "assignee_persons": ["��������� ������", "��������� ���������� ������"]},' + '"dataset": [15]}');
  finally
      // ��������� ���� �������, �������� ��� ������ ����� �������
    FJSONStream.Seek(-1, soCurrent);
    FJSONStream.WriteString('},');
  end;

end;
















// ���� ��������� ��� POST
function TPersDataDTO.MemDoc2JSON(dsDoc: TDataSet; dsChild: TDataSet; StreamDoc: TStringStream; NeedUp : Boolean): Boolean;
var
  s, sURL, sPar, sss, sF, sFld, sPath, sPostDoc, sResponse, sError, sStatus, sId: String;
  sUTF : UTF8String;
  ws : WideString;
  new_obj, obj: ISuperObject;
  nSpr, n, i, j: Integer;
  lOk: Boolean;



// ����� 19-20
  procedure PostForm19_20;
  begin
    FJSONStream.WriteString('"form19_20":{');
    AddStr('form19_20Base', 'form19_20');
    try
    finally
      // ��������� ���� �������, �������� ��� ������ ����� �������
      FJSONStream.Seek(-1, soCurrent);
      FJSONStream.WriteString('},');
    end;
  end;



begin
  Result := False;
  FJSONStream := StreamDoc;
  FJSONStream.WriteString('{');
  try

    // ����� null
    AddNum('pid');


    sUTF := AnsiToUtf8(StreamDoc.DataString);
    FJSONStream.Seek(0, soBeginning);
    FJSONStream.WriteString(sUTF);
    Result := True;
  finally
  // ��������� ���� �������, �������� ��� ������ ����� �������
    StreamDoc.Seek(-1, soCurrent);
    StreamDoc.WriteString('}');
  end;
end;






end.
 