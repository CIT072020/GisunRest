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
  TActPostBoby = function(IDS : TDataSet) : string;
  TMakePostBoby = function(IDS : TDataSet) : string of object;

  // �������������
  TClassifier = class
  private
  public
    class function SetCT(const ACode: string; AType: integer; IsBraces: Boolean = True): string;
    class function SetCTL(const ACode: string; AType: integer; const Lex : string; Lang : string = 'ru'; IsBraces: Boolean = True): string;
  end;

(*
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
*)

  // ������� ����� ��� �������������� DataSet -> JSON
  TDS2JSON = class
  private
  public
    class function MakeBirthPlace(IDS : TDataSet; Pfx : string = '') : string;
  end;


  // ������� ����� ���������� ������������ ������
  TPersDataMin = class
  private
    FInDS     : TDataSet;
  public
    property InDS : TDataSet read FInDS write FInDS;

    constructor Create(IDS : TDataSet = nil);
    destructor Destroy;

    class function DS2Json(IDS: TDataSet; Pfx: string = ''): string;
  end;

  // ������������� � �����
  TActMarr = class(TPersDataMin)
  private
    class function MarrDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string) : string;
  public
    class function MarrDS2Json(IDS : TDataSet) : string;
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

//function Marr2Json(IDS : TDataSet) : string;

implementation

// ��� - ��� �� �����������
class function TClassifier.SetCT(const ACode: string; AType: integer; IsBraces: Boolean = True): string;
begin
  Result := Format('"code":"%s","type":%d', [ACode, AType]);
  if (IsBraces) then
    Result := '{' + Result + '}';
end;

// ��� - ��� - ������� �� �����������
class function TClassifier.SetCTL(const ACode: string; AType: integer; const Lex : string; Lang : string = 'ru'; IsBraces: Boolean = True): string;
begin
  Result := Format('"code":"%s","type":%d,"lexema":{"value":["value":"%s","lang":"%s"]}', [ACode, AType, Lex, Lang]);
  if (IsBraces) then
    Result := '{' + Result + '}';
end;


// ����� ��������
class function TDS2JSON.MakeBirthPlace(IDS : TDataSet; Pfx : string = '') : string;
var
  s : string;
begin
  s := '"country_b":' +
    TClassifier.SetCT(IDS.FieldByName(Pfx + 'GOSUD').AsString, 8);
  s := s + Format(',"area_b":"%s","area_b_bel":"%s","region_b":"%s","region_b_bel":"%s",',
    [IDS.FieldByName(Pfx + 'OBL').AsString, IDS.FieldByName(Pfx + 'OBL_B').AsString, IDS.FieldByName(Pfx + 'RAION').AsString, IDS.FieldByName(Pfx + 'RAION_B').AsString]);
  s := s + '"type_city_b":' + TClassifier.SetCT(IDS.FieldByName(Pfx + 'TIP_GOROD').AsString, 68);
  s := s + Format(',"city_b":"%s","city_b_bel":"%s"',
    [IDS.FieldByName(Pfx + 'GOROD').AsString, IDS.FieldByName(Pfx + 'GOROD_B').AsString]);
  Result := s;
end;




//
constructor TPersDataMin.Create(IDS : TDataSet = nil);
begin
  inherited Create;
  FInDS := IDS;
end;

//
destructor TPersDataMin.Destroy;
begin
  inherited;
end;


class function TPersDataMin.DS2Json(IDS: TDataSet; Pfx: string = ''): string;
var
  Mode : Integer;
  s: string;
begin
  with IDS do begin
    s := Format('"identif":"%s","last_name":"%s","name":"%s","patronymic":"%s","sex":%s,"birth_day":"%s"',
      [FieldByName(Pfx + 'IDENTIF').AsString, FieldByName(Pfx + 'FAMILIA').AsString, FieldByName(Pfx + 'NAME').AsString,
       FieldByName(Pfx + 'OTCH').AsString, TClassifier.SetCT(IDS.FieldByName(Pfx + 'POL').AsString, 32),
       FieldByName(Pfx + 'DATER').AsString]);

    s := s + Format(',"last_name_bel":"%s","name_bel":"%s","patronymic_bel":"%s"',
      [FieldByName(Pfx + 'FAMILIA_B').AsString, FieldByName(Pfx + 'NAME_B').AsString, FieldByName(Pfx + 'OTCH_B').AsString]);
  end;
  Result := s;
end;


// ������������� � ����� ��� ������ �������
class function TActMarr.MarrDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string) : string;
var
  sF,
  sD,
  s : string;
begin

  sF := '"%s":{%s,' +
        '"birth_place":{%s},' +
        '"citizenship":%s,' +
        '"status":%s},' +
        '"old_last_name":"%s"';
  sD := ObjName + DS2Json(IDS,Pfx);
  sD := sD + TDS2JSON.MakeBirthPlace(IDS, Pfx);
  sD := sD + TClassifier.SetCT(IDS.FieldByName(Pfx + 'GRAJD').AsString, 8);
  sD := sD + TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18);
  sD := sD + IDS.FieldByName(Pfx + 'FAMILIA_OLD').AsString;

  s := Format(sF,
    [ObjName,
     DS2Json(IDS,Pfx),
     TDS2JSON.MakeBirthPlace(IDS, Pfx),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'GRAJD').AsString, 8),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18),
     IDS.FieldByName(Pfx + 'FAMILIA_OLD').AsString]);
  Result := s;
end;

(*
// ������������� � �����
function Marr2Json(IDS : TDataSet) : string;
var
  org,
  r,
  s : string;
begin
  s := '"mrg_cert_data":{"bride":{';
  s := s + '"bride_data":{' + TPersDataMin.DS2Json(IDS, 'ONA_');

  s := s + ',' +
               '"status":' + TClassifier.SetCT('1', -18) + '}},';
  s := s + '"bridegroom":{' +
           '"bridegroom_data":{' + TPersDataMin.DS2Json(IDS, 'ON_') + ',' +

               '"status":' + TClassifier.SetCT('1', -18) + '}},';
  s := s + '"mrg_act_data":{' +
               '"act_type":' + TClassifier.SetCT(IDS.FieldByName('ACT_TIP').AsString, 82) + ',';
  org := IDS.FieldByName('ACT_ORGAN').AsString;
  org := Iif( StrToInt(org) > 0, TClassifier.SetCT(org, 80), TClassifier.SetCTL('', 80, IDS.FieldByName('ACT_ORGAN_LEX').AsString) );
  s := s + '"authority":' + org + ',';
               r := Format('"date":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('ACT_DATE').AsDateTime) ]);
               s := s + r;
               r := Format('"number":"%s"},', [ IDS.FieldByName('ACT_NOMER').AsString ]);
               s := s + r;
  s := s + '"mrg_certificate_data":{' +
               '"document_type":' + TClassifier.SetCT('54100006', 37) + ',' +
               '"authority":' + TClassifier.SetCT(IDS.FieldByName('DOC_ORGAN').AsString, 80) + ',' +
               Format('"date_of_issue":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('DOC_DATE').AsDateTime) ]) +
               Format('"series":"%s",', [ IDS.FieldByName('DOC_SERIA').AsString ]) +
               Format('"number":"%s"}}', [ IDS.FieldByName('DOC_NOMER').AsString ]);
  Result := s;
end;
*)

// ������������� � �����
class function TActMarr.MarrDS2Json(IDS : TDataSet) : string;
var
  org,
  r,
  s : string;
begin
  s := '"mrg_cert_data":{' +
    '"bride":{' +
    MarrDS2JsonOne(IDS, 'ONA_', 'bride_data') +
    '},"bridegroom":{' +
    MarrDS2JsonOne(IDS, 'ON_', 'bridegroom_data') + '},';

  s := s + '"mrg_act_data":{' +
               '"act_type":' + TClassifier.SetCT(IDS.FieldByName('ACT_TIP').AsString, 82) + ',';
  org := IDS.FieldByName('ACT_ORGAN').AsString;
  org := Iif( StrToInt(org) > 0, TClassifier.SetCT(org, 80), TClassifier.SetCTL('', 80, IDS.FieldByName('ACT_ORGAN_LEX').AsString) );
  s := s + '"authority":' + org + ',';
               r := Format('"date":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('ACT_DATE').AsDateTime) ]);
               s := s + r;
               r := Format('"number":"%s"},', [ IDS.FieldByName('ACT_NOMER').AsString ]);
               s := s + r;
  s := s + '"mrg_certificate_data":{"document":{' +
               '"document_type":' + TClassifier.SetCT('54100006', 37) + ',' +
               '"authority":' + TClassifier.SetCT(IDS.FieldByName('DOC_ORGAN').AsString, 80) + ',' +
               Format('"date_of_issue":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('DOC_DATE').AsDateTime) ]) +
               Format('"series":"%s",', [ IDS.FieldByName('DOC_SERIA').AsString ]) +
               Format('"number":"%s"}}}', [ IDS.FieldByName('DOC_NOMER').AsString ]);
  Result := s;
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
 