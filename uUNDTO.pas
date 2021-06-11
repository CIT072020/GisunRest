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

  // �������������
  TClassifier = class
  private
    FJObjName : string;
    FInDS     : TDataSet;
  public
    CodeC : string;
    TypeC : Integer;

    property JObjName : string read FJObjName write FJObjName;

    function GetFI(sField: String): Integer;
    function GetFS(sField: String): String;
    function GetFD(sField: String): TDateTime;
    function GetFB(sField: String): String;


    constructor Create(JN : string);
    destructor Destroy;
  end;


  // ������� ����� ��� �������������� JSON <-> DataSet
  TJ2DS = class
  private
    FJObjName : string;
    FInDS     : TDataSet;
  public
    property JObjName : string read FJObjName write FJObjName;

    function GetFI(sField: String): Integer;

    constructor Create(JN : string);
    destructor Destroy;
  end;

  // ������� ����� ���������� ������������ ������
  TPersDataBase = class
  private
    FJObjName : string;
    FInPfx    : string;
    FInDS     : TDataSet;
  public
    property JObjName : string read FJObjName write FJObjName;
    function DS2Json1Obj(InP : string = ''; IDS : TDataSet = nil) : string;
    function DS2Json(InP : string = ''; IDS : TDataSet = nil) : string;

    constructor Create(JN : string; FInDS : TDataSet);
    destructor Destroy;
  end;

  // ������������� � �����
  TActMarr = class(TPersDataBase)
  private
  public
    function DS2Json(InP : string = ''; IDS : TDataSet = nil) : string;
  end;



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


class function TClassifier.SetJson(ACode: string; AType: integer; IsBraces: Boolean = False): string;
begin
  Result := Format('"code":"%s","type":%s', [ACode, AType]);
  if (IsBraces) then
    Result := '{' + Result + '}';
end;

//
constructor TPersDataBase.Create(JN : string; InP : string = '');
begin
  inherited Create;
  JObjName := JN;
  FInPfx   := InP;
end;

//
destructor TPersDataBase.Destroy;
begin
  inherited;
end;


function TPersDataBase.DS2Json1Obj(InP: string = ''; IDS: TDataSet = nil): string;
var
  s: string;
begin
  if (not Assigned(IDS)) then
    IDS := FInDS;
  with IDS do begin
    s :=     '"identif":"'    + FieldByName(FInPfx + 'IDENTIF').AsString + '",';
    s := s + '"last_name":"'  + FieldByName(FInPfx + 'FAMILIA').AsString + '",';
    s := s + '"name":"'       + FieldByName(FInPfx + 'NAME').AsString + '",';
    s := s + '"patronymic":"' + FieldByName(FInPfx + 'OTCH').AsString + '",';

    Result := s + '"birth_day":"' + FieldByName(FInPfx + 'DATER').AsString + '"';
  end;
end;

function TPersDataBase.DS2Json(InP : string = ''; IDS : TDataSet = nil) : string;
var
  r,
  s : string;
begin
  if (not Assigned(IDS)) then
    IDS := FInDS;
  Result := Format('"%s":{%s}', [JObjName, DS2Json1Obj(InP, IDS)]);
end;

// ������������� � �����
function TActMarr.MarrDS2Json(InP : string = ''; IDS : TDataSet = nil) : string;
var
  r,
  s : string;
begin
  if (not Assigned(IDS)) then
    IDS := FInDS;
  s := '"mrg_cert_data":{"bride":{';
  s := s + '"bride_data":{' + DS2Json1Obj('ONA_', IDS) +
               '"status":' + TClassifier.SetJson('1', -18) + '}},';
  s := s + '"bridegroom":{' +
           '"bridegroom_data":{' + DS2Json1Obj('ON_', IDS) +
               '"status":' + TClassifier.SetJson('1', -18) + '}},';
  s := s + '"mrg_act_data":{' +
               '"act_type":' + TClassifier.SetJson('0300', 82) + ',' +
               '"authority":' + TClassifier.SetJson('617', 80) + ',' +
               '"date":' +  ',' +
               '"number":' + '},';
  s := s + '"mrg_certificate_data":{' +
               '"document_type":' + TClassifier.SetJson('54100006', 37) + ',' +
               '"authority":' + TClassifier.SetJson('617', 80) + ',' +
			         '"date_of_issue":"2013-06-11",' +
			         '"series": "I-??",' +
			         '"number": "0221734"}}'

end;


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
 