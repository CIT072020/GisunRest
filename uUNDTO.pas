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

const
  BPLC_WITH_BY  = 1;
  BPLC_RU_ONLY  = 2;
  BPLC_RU_NOCTZ = 3;

type
  TActPostBoby = function(IDS : TDataSet) : string;
  TMakePostBoby = function(IDS : TDataSet) : string of object;

  // Классификатор
  TClassifier = class
  private
  public
    // Для конвертации DataSet -> String(JSON)
    class function SetCT(const ACode: string; AType: integer; IsBraces: Boolean = True): string;
    class function SetCTL(const ACode: string; AType: integer; const Lex : string; Lang : string = 'ru'; IsBraces: Boolean = True): string;

    // Для конвертации SuperObject -> DataSet
    class function FindRUName(LexValArr: ISuperObject; const ALang: string = 'RU'): string;
    class procedure SObj2DSSetTKN(SOClsf: ISuperObject; ODS: TDataSet; const Pfx : string);
  end;

(*
  // Базовый набор для преобразований JSON <-> DataSet
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

  // Базовый набор для преобразований DataSet -> JSON
  TDS2JSON = class
  private
  public
    class function CourtDec(IDS: TDataSet): string;
    class function MakeBirthPlace(IDS : TDataSet; Pfx : string = ''; Mode : integer = 1) : string;
    class function MakeActData(IDS : TDataSet; ActName : string; Pfx : string = 'ACT_') : string;
    class function MakeDocCertif(IDS : TDataSet; const DocName, DocType : string; Pfx : string = 'DOC_') : string;
  end;


  // Базовый набор реквизитов персональных данных
  TPersData = class
  private
    FInDS     : TDataSet;
  public
    property InDS : TDataSet read FInDS write FInDS;

    constructor Create(IDS : TDataSet = nil);
    destructor Destroy;

    class function DS2JsonMin(IDS: TDataSet; Pfx: string = ''): string;
    class procedure SObj2DSMin(SOPersData: ISuperObject; IDS: TDataSet);
    class procedure SObj2DSFull(SOPersData: ISuperObject; IDS: TDataSet);
  end;

  // Свидетельство о рождении
  TActBirth = class(TPersData)
  private
    class function BirthDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string; Mode : Integer = 1) : string;
  public
    class function BirthDS2Json(IDS : TDataSet) : string;
  end;

  // Свидетельство об установлении отцовства
  TActAffil = class(TPersData)
  private
    class function AffilDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string; Mode : Integer = 1) : string;
  public
    class function AffilDS2Json(IDS : TDataSet) : string;
  end;

  // Свидетельство о браке
  TActMarr = class(TPersData)
  private
    class function MarrDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string) : string;
  public
    class function MarrDS2Json(IDS : TDataSet) : string;
  end;
// Свидетельство о смерти
  TActDecease = class(TPersData)
  private
    class function DeceaseDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string; Mode : Integer = 1) : string;
    class function DeceaseDS2JsonDCD(IDS : TDataSet) : string;
  public
    class function DeceaseDS2Json(IDS : TDataSet) : string;
  end;
// Свидетельство о расторжении брака
  TActDvrc = class(TPersData)
  private
    class function DvrcDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string) : string;
  public
    class function DvrcDS2Json(IDS : TDataSet) : string;
  end;

  // Свидетельство о смене ФИО
  TActChgName = class(TPersData)
  private
    class function ChgNameDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string) : string;
  public
    class function ChgNameDS2Json(IDS : TDataSet) : string;
  end;



  // Чтение/Запись актов и персональных данных
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
    // Код из справочного реквизита
    //function GetCode(sField: String; KeyField: string = 'klUniPK'): Variant;
    //function GetName(sField: String): string;

    // Добавить в JSON-поток
    procedure AddNum(const ss1: string; ss2: Variant); overload;
    procedure AddNum(const ss1: string); overload;
    procedure AddStr(const ss1: string; ss2: String = '');
    procedure AddDJ(ss1: String; dValue: TDateTime);

    function MakeCover(dsDoc: TDataSet; StreamDoc: TStringStream): Boolean;

    // Паспортные данные
    //procedure GetPasp;
    // Место рождения
    //procedure GetPlaceOfBirth;
    // Место проживания
    //procedure GetPlaceOfLiving;
    // Белорусская версия
    //procedure GetByVer;
    // Адрес регистрации
    //procedure GetROC(SODsdAddr: ISuperObject);
    // Форма 19-20
    //procedure GetForm19_20(SOf20 : ISuperObject; MasterKey: Variant);
    // Данные по детям из внутреннего массива
    //procedure GetChild(SOA: TSuperArray; MasterKey: Variant);

  public

    // Список документов из SuperObject сохранить в MemTable
    //function GetDocList(SOArr: ISuperObject): Boolean;
    function MemDoc2JSON(dsDoc: TDataSet; dsChild: TDataSet; StreamDoc: TStringStream; NeedUp : Boolean): Boolean;

    //constructor Create(MTDoc, MTChild : TDataSet; ChSep : Boolean = False);
    //destructor Destroy;

    //class function GetNsi(SOArr: ISuperObject; Nsi: TkbmMemTable; EmpTbl: Boolean = True): Integer;
  end;

//function Marr2Json(IDS : TDataSet) : string;

implementation

// Код - тип из справочника
class function TClassifier.SetCT(const ACode: string; AType: integer; IsBraces: Boolean = True): string;
begin
  Result := Format('"code":"%s","type":%d', [ACode, AType]);
  if (IsBraces) then
    Result := '{' + Result + '}';
end;

// Код - тип - лексема из справочника
class function TClassifier.SetCTL(const ACode: string; AType: integer; const Lex : string; Lang : string = 'ru'; IsBraces: Boolean = True): string;
begin
  Result := Format('"code":"%s","type":%d,"lexema":{"value":["value":"%s","lang":"%s"]}', [ACode, AType, Lex, Lang]);
  if (IsBraces) then
    Result := '{' + Result + '}';
end;


// Поиск среди символьных наименований нужного языка
class function TClassifier.FindRUName(LexValArr: ISuperObject; const ALang: string = 'RU'): string;
var
  i, iMax: Integer;
  x: ISuperObject;
begin
  Result := '';
  iMax := LexValArr.AsArray.Length - 1;
  for i := 0 to iMax do begin
    x := LexValArr.AsArray.O[i];
    if (UpperCase(x.S['lang']) = ALang) then begin
      Result := x.S['value'];
      Break;
    end;
  end;
end;

class procedure TClassifier.SObj2DSSetTKN(SOClsf: ISuperObject; ODS: TDataSet; const Pfx : string);
var
  s: string;
  x: ISuperObject;
begin
  with ODS do begin
    FieldByName('K_' + Pfx).AsString := SOClsf.S['code'];
    FieldByName('T_' + Pfx).AsString := IntToStr(SOClsf.I['type']);
    FieldByName('N_' + Pfx).AsString := FindRUName(SOClsf.O['lexema'].O['value']);
  end;
end;


// Место рождения
// 1 - использовать By, 2 - только русский
class function TDS2JSON.MakeBirthPlace(IDS : TDataSet; Pfx : string = ''; Mode : integer = BPLC_WITH_BY) : string;
var
  s : string;
begin
  s := '"country_b":' +
    TClassifier.SetCT(IDS.FieldByName(Pfx + 'GOSUD').AsString, 8);
  s := s + Format(',"area_b":"%s","region_b":"%s","city_b":"%s",',[
    IDS.FieldByName(Pfx + 'OBL').AsString,
    IDS.FieldByName(Pfx + 'RAION').AsString,
    IDS.FieldByName(Pfx + 'GOROD').AsString]);

  if (Mode = BPLC_WITH_BY) then
    s := s + Format('"area_b_bel":"%s","region_b_bel":"%s","city_b_bel":"%s",', [
      IDS.FieldByName(Pfx + 'OBL_B').AsString,
      IDS.FieldByName(Pfx + 'RAION_B').AsString,
      IDS.FieldByName(Pfx + 'GOROD_B').AsString]);

  Result := s + '"type_city_b":' + TClassifier.SetCT(IDS.FieldByName(Pfx + 'TIP_GOROD').AsString, 68);
end;

// Описание зафиксированного акта
class function TDS2JSON.MakeActData(IDS: TDataSet; ActName: string; Pfx: string = 'ACT_'): string;
var
  org, s: string;
begin
  s := Format('"%s":{"act_type":%s,', [ActName, TClassifier.SetCT(IDS.FieldByName(Pfx + 'TIP').AsString, 82)]);
  try
    org := IDS.FieldByName(Pfx + 'ORGAN').AsString;
    if (StrToInt(org) <= 0) then begin
      org := IDS.FieldByName(Pfx + 'ORGAN_LEX').AsString;
      org := TClassifier.SetCTL('0', 80, org);
    end
    else
      org := TClassifier.SetCT(org, 80);
  except
    org := '';
  end;

  if (Length(org) = 0) then
    org := TClassifier.SetCT('0', 80);

  Result := s + '"authority":' + org + ',' +
    Format('"date":"%s",', [FormatDateTime('yyyy-mm-dd', IDS.FieldByName(Pfx + 'DATE').AsDateTime)]) +
    Format('"number":"%s"}', [IDS.FieldByName(Pfx + 'NOMER').AsString]);
end;

// Описание подтверждающего документа-сертификата
class function TDS2JSON.MakeDocCertif(IDS : TDataSet; const DocName, DocType : string; Pfx : string = 'DOC_') : string;
begin
  Result := Format('"%s":{"document":{"document_type":%s,"authority":%s,', [DocName,
    TClassifier.SetCT(DocType, 37), TClassifier.SetCT(IDS.FieldByName(Pfx + 'ORGAN').AsString, 80)]) +
    Format('"date_of_issue":"%s",', [FormatDateTime('yyyy-mm-dd', IDS.FieldByName(Pfx + 'DATE').AsDateTime) ]) +
    Format('"series":"%s",', [ IDS.FieldByName(Pfx + 'SERIA').AsString ]) +
    Format('"number":"%s"}}', [ IDS.FieldByName(Pfx + 'NOMER').AsString ]);
end;

// Решение суда
class function TDS2JSON.CourtDec(IDS: TDataSet): string;
var
  s: string;
begin
  try
    s := Format('{"court_name":"%s","court_decision_date":"%s","comment":"%s"}', [
      IDS.FieldByName('SUD_NAME').AsString,
      IDS.FieldByName('SUD_DATE').AsString,
      IDS.FieldByName('SUD_COMM').AsString]);
  except
    s := '';
  end;
  Result := s;
end;


//
constructor TPersData.Create(IDS : TDataSet = nil);
begin
  inherited Create;
  FInDS := IDS;
end;

//
destructor TPersData.Destroy;
begin
  inherited;
end;


class function TPersData.DS2JsonMin(IDS: TDataSet; Pfx: string = ''): string;
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

class procedure TPersData.SObj2DSMin(SOPersData: ISuperObject; IDS: TDataSet);
var
  s: string;
begin
  with IDS do begin
    FieldByName('IDENTIF').AsString := SOPersData.S['identif'];
    FieldByName('FAMILIA').AsString := SOPersData.S['last_name'];
    FieldByName('NAME').AsString    := SOPersData.S['name'];
    FieldByName('OTCH').AsString    := SOPersData.S['patronymic'];
    FieldByName('DATER').AsString   := SOPersData.S['birth_day'];
  end;
end;


class procedure TPersData.SObj2DSFull(SOPersData: ISuperObject; IDS: TDataSet);
var
  s: string;
begin
  with IDS do begin
    FieldByName('FAMILIA_B').AsString := SOPersData.S[CT('last_name_bel')];
    FieldByName('NAME_B').AsString    := SOPersData.S[CT('name_bel')];
    FieldByName('OTCH_B').AsString    := SOPersData.S[CT('patronymic_bel')];

    TClassifier.SObj2DSSetTKN(SOPersData.O['sex'], IDS, 'POL');
  end;
end;



// Свидетельство о рождении (ребенок или родитель)
class function TActBirth.BirthDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string; Mode : Integer = 1) : string;
var
  sF,
  sD,
  s : string;
begin

  sF := '"%s":{%s,' +
        '"birth_place":{%s},' +
        '"citizenship":%s,' +
        '"status":%s}';
  s := Format(sF,
    [ObjName,
     DS2JsonMin(IDS,Pfx),
     TDS2JSON.MakeBirthPlace(IDS, Pfx, Mode),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'GRAJD').AsString, 8),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18)]);
  Result := s;
end;


// Свидетельство о рождении
class function TActBirth.BirthDS2Json(IDS : TDataSet) : string;
var
  org,
  r,
  s : string;
begin
  s := '"birth_cert_data":{' +
    BirthDS2JsonOne(IDS, '', 'child_data') + ',';
  s := s +
    BirthDS2JsonOne(IDS, 'ONA_', 'mother_data', BPLC_RU_ONLY) + ',';
  s := s +
    BirthDS2JsonOne(IDS, 'ON_', 'father_data', BPLC_RU_ONLY) + ',';

  s := s + '"birth_act_data":{' +
               '"act_type":' + TClassifier.SetCT(IDS.FieldByName('ACT_TIP').AsString, 82) + ',';
  org := IDS.FieldByName('ACT_ORGAN').AsString;
  org := Iif( StrToInt(org) > 0, TClassifier.SetCT(org, 80), TClassifier.SetCTL('', 80, IDS.FieldByName('ACT_ORGAN_LEX').AsString) );
  s := s + '"authority":' + org + ',';
               r := Format('"date":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('ACT_DATE').AsDateTime) ]);
               s := s + r;
               r := Format('"number":"%s"},', [ IDS.FieldByName('ACT_NOMER').AsString ]);
               s := s + r;
  s := s + '"birth_certificate_data":{"document":{' +
               '"document_type":' + TClassifier.SetCT('54100005', 37) + ',' +
               '"authority":' + TClassifier.SetCT(IDS.FieldByName('DOC_ORGAN').AsString, 80) + ',' +
               Format('"date_of_issue":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('DOC_DATE').AsDateTime) ]) +
               Format('"series":"%s",', [ IDS.FieldByName('DOC_SERIA').AsString ]) +
               Format('"number":"%s"}}}', [ IDS.FieldByName('DOC_NOMER').AsString ]);
  Result := s;
end;


// Свидетельство об установлении отцовства
class function TActAffil.AffilDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string; Mode : Integer = 1) : string;
var
  sF,
  sCtz,
  s : string;
begin

  if (Mode = BPLC_RU_NOCTZ) then
    sCtz := '0'
  else
    sCtz := IDS.FieldByName(Pfx + 'GRAJD').AsString;

  sF := '"%s":{%s,' +
        '"birth_place":{%s},' +
        '"citizenship":%s,' +
        '"status":%s}';

  s := Format(sF,
    [ObjName,
     DS2JsonMin(IDS,Pfx),
     TDS2JSON.MakeBirthPlace(IDS, Pfx, Mode),
     TClassifier.SetCT(sCtz, 8),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18)]);
  Result := s;
end;


// Свидетельство об установлении отцовства
class function TActAffil.AffilDS2Json(IDS : TDataSet) : string;
var
  org,
  r,
  s : string;
begin
  s := '"aff_cert_data":{' +
    '"aff_person":{' +
      '"birth_act_data":{' +
        '"act_type":' + TClassifier.SetCT(IDS.FieldByName('R_TIP').AsString, 82) + ',' +
        '"authority":' + TClassifier.SetCT(IDS.FieldByName('R_ORGAN').AsString, 80) + ',';
  s := s + Format(
        '"date":"%s","number":"%s"},', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('R_DATE').AsDateTime), IDS.FieldByName('R_NOMER').AsString ]);
  s := s + AffilDS2JsonOne(IDS, 'DO_', 'before_aff_person_data', BPLC_RU_NOCTZ) + ',';
  s := s + AffilDS2JsonOne(IDS, 'PO_', 'after_aff_person_data', BPLC_RU_NOCTZ) +
    '},'; // aff_person made
  s := s +
    AffilDS2JsonOne(IDS, 'ONA_', 'mother_data', BPLC_RU_ONLY) + ',';
  s := s +
    AffilDS2JsonOne(IDS, 'ON_', 'father_data', BPLC_RU_ONLY) + ',';

  s := s + '"aff_act_data":{' +
               '"act_type":' + TClassifier.SetCT(IDS.FieldByName('ACT_TIP').AsString, 82) + ',';
  org := IDS.FieldByName('ACT_ORGAN').AsString;
  org := Iif( StrToInt(org) > 0, TClassifier.SetCT(org, 80), TClassifier.SetCTL('', 80, IDS.FieldByName('ACT_ORGAN_LEX').AsString) );
  s := s + '"authority":' + org + ',';
               r := Format('"date":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('ACT_DATE').AsDateTime) ]);
               s := s + r;
               r := Format('"number":"%s"},', [ IDS.FieldByName('ACT_NOMER').AsString ]);
               s := s + r;
  s := s + '"aff_mother_certificate_data":{"document":{' +
               '"document_type":' + TClassifier.SetCT('54100027', 37) + ',' +
               '"authority":' + TClassifier.SetCT(IDS.FieldByName('DOC_ONA_ORGAN').AsString, 80) + ',' +
               Format('"date_of_issue":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('DOC_ONA_DATE').AsDateTime) ]) +
               Format('"series":"%s",', [ IDS.FieldByName('DOC_ONA_SERIA').AsString ]) +
               Format('"number":"%s"}},', [ IDS.FieldByName('DOC_ONA_NOMER').AsString ]);
  s := s + '"aff_father_certificate_data":{"document":{' +
               '"document_type":' + TClassifier.SetCT('54100026', 37) + ',' +
               '"authority":' + TClassifier.SetCT(IDS.FieldByName('DOC_ON_ORGAN').AsString, 80) + ',' +
               Format('"date_of_issue":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('DOC_ON_DATE').AsDateTime) ]) +
               Format('"series":"%s",', [ IDS.FieldByName('DOC_ON_SERIA').AsString ]) +
               Format('"number":"%s"}}', [ IDS.FieldByName('DOC_ON_NOMER').AsString ]);
  r := TDS2JSON.CourtDec(IDS);
  if (Length(r) > 0) then
    s := s + ',"court_decision":' + r;
  s := s + '}';
  Result := s;
end;



// Свидетельство о браке для одного супруга
class function TActMarr.MarrDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string) : string;
begin
  Result := Format('"%s":{%s,' +
    '"birth_place":{%s},' +
    '"citizenship":%s,' +
    '"status":%s},' +
    '"old_last_name":"%s"', [ObjName, DS2JsonMin(IDS,Pfx),
     TDS2JSON.MakeBirthPlace(IDS, Pfx),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'GRAJD').AsString, 8),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18),
     IDS.FieldByName(Pfx + 'FAMILIA_OLD').AsString]);
end;


// Свидетельство о браке
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

  Result := s +
    TDS2JSON.MakeActData(IDS, 'mrg_act_data') + ',' +
    TDS2JSON.MakeDocCertif(IDS, 'mrg_certificate_data', IDS.FieldByName('DOC_TIP').AsString) + '}';
end;



// Свидетельство о смерти
class function TActDecease.DeceaseDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string; Mode : Integer = 1) : string;
var
  s : string;
begin
// Место рождения
  s := '"country_b":' +
    TClassifier.SetCT(IDS.FieldByName(Pfx + 'GOSUD_R').AsString, 8);
  s := s + Format(',"area_b":"%s","region_b":"%s","city_b":"%s",',[
    IDS.FieldByName(Pfx + 'OBL_R').AsString,
    IDS.FieldByName(Pfx + 'RAION_R').AsString,
    IDS.FieldByName(Pfx + 'GOROD_R').AsString]);
  s := s + '"type_city_b":' + TClassifier.SetCT(IDS.FieldByName(Pfx + 'TIP_GOROD_R').AsString, 68);

  Result := Format('"%s":{%s,' +
        '"birth_place":{%s},' +
        '"citizenship":%s,' +
        '"status":%s}', [
     ObjName, DS2JsonMin(IDS,Pfx),
     s,
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'GRAJD').AsString, 8),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18)]);
end;


// Свидетельство о смерти
class function TActDecease.DeceaseDS2JsonDCD(IDS : TDataSet) : string;
var
  sD,
  sP  : string;
begin

  sD :=
    '"death_cause":' +
      TClassifier.SetCT(IDS.FieldByName('SM_PRICH').AsString, 81) + ',' +
    '"death_date":"' + IDS.FieldByName('SM_DATE').AsString + '",';

  // Место смерти
  sP := Format('"country_d":%s,"area_d":"%s","region_d":"%s","city_d":"%s",',[
    TClassifier.SetCT(IDS.FieldByName('GOSUD').AsString, 8),
    IDS.FieldByName('OBL').AsString,
    IDS.FieldByName('RAION').AsString,
    IDS.FieldByName('GOROD').AsString]);

  sP := sP + Format('"area_d_bel":"%s","region_d_bel":"%s","city_d_bel":"%s","type_city_d":%s', [
      IDS.FieldByName('OBL_B').AsString,
      IDS.FieldByName('RAION_B').AsString,
      IDS.FieldByName('GOROD_B').AsString,
      TClassifier.SetCT(IDS.FieldByName('TIP_GOROD').AsString, 68)]);

  Result := Format('"decease_data":{%s' +
        '"decease_place":{%s}}',[sD, sP]);
end;


// Свидетельство о смерти
class function TActDecease.DeceaseDS2Json(IDS : TDataSet) : string;
var
  org,
  r,
  s : string;
begin
  s := '"dcs_cert_data":{' +
    DeceaseDS2JsonOne(IDS, '', 'person_data') + ',';
  s := s +
    DeceaseDS2JsonDCD(IDS) + ',' +
    '"reason":"' + IDS.FieldByName('SM_DOC').AsString + '",';

  s := s + '"dcs_act_data":{' +
               '"act_type":' + TClassifier.SetCT(IDS.FieldByName('ACT_TIP').AsString, 82) + ',';
  org := IDS.FieldByName('ACT_ORGAN').AsString;
  org := Iif( StrToInt(org) > 0, TClassifier.SetCT(org, 80), TClassifier.SetCTL('', 80, IDS.FieldByName('ACT_ORGAN_LEX').AsString) );
  s := s + '"authority":' + org + ',';
               r := Format('"date":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('ACT_DATE').AsDateTime) ]);
               s := s + r;
               r := Format('"number":"%s"},', [ IDS.FieldByName('ACT_NOMER').AsString ]);
               s := s + r;
  s := s + '"dcs_certificate_data":{"document":{' +
               '"document_type":' + TClassifier.SetCT('54100009', 37) + ',' +
               '"authority":' + TClassifier.SetCT(IDS.FieldByName('DOC_ORGAN').AsString, 80) + ',' +
               Format('"date_of_issue":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('DOC_DATE').AsDateTime) ]) +
               Format('"series":"%s",', [ IDS.FieldByName('DOC_SERIA').AsString ]) +
               Format('"number":"%s"}}}', [ IDS.FieldByName('DOC_NOMER').AsString ]);
  Result := s;
end;


// Свидетельство о расторжении брака для одного супруга
class function TActDvrc.DvrcDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string) : string;
var
  sD,
  s : string;
begin
  Result := Format('"%s":{%s,' +
    '"birth_place":{%s},' +
    '"citizenship":%s,' +
    '"status":%s},' +
    '"old_last_name":"%s"',
    [ObjName, DS2JsonMin(IDS,Pfx),
     TDS2JSON.MakeBirthPlace(IDS, Pfx, BPLC_RU_ONLY),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'GRAJD').AsString, 8),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18),
     IDS.FieldByName(Pfx + 'FAMILIA_OLD').AsString]);
end;


// Свидетельство о расторжении брака
class function TActDvrc.DvrcDS2Json(IDS : TDataSet) : string;
var
  org,
  r,
  s : string;
begin
  s := '"dvc_cert_data":{' +
    '"wife":{' + DvrcDS2JsonOne(IDS, 'ONA_', 'wife_data') +
    '},"husband":{' + DvrcDS2JsonOne(IDS, 'ON_', 'husband_data') + '},';
  s := s +
    TDS2JSON.MakeActData(IDS, 'mrg_act_data', 'BRAK_') + ',';
  r := TDS2JSON.CourtDec(IDS);
  if (Length(r) > 0) then
    s := s + '"court_decision":' + r + ',';

  Result := s +
    TDS2JSON.MakeActData(IDS, 'dvc_act_data') + ',' +
    TDS2JSON.MakeDocCertif(IDS, 'dvc_wm_certificate_data', IDS.FieldByName('ONA_TIP').AsString, 'ONA_') + ',' +
    TDS2JSON.MakeDocCertif(IDS, 'dvc_mn_certificate_data', IDS.FieldByName('ON_TIP').AsString, 'ONA_') + '}';
end;





// Свидетельство о смене ФИО
class function TActChgName.ChgNameDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string) : string;
var
  sD,
  s : string;
begin

s := DS2JsonMin(IDS,Pfx);
s :=      TDS2JSON.MakeBirthPlace(IDS, Pfx);
s :=      TClassifier.SetCT(IDS.FieldByName(Pfx + 'GRAJD').AsString, 8);
s :=      TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18);


  Result := Format('"%s":{%s,' +
    '"birth_place":{%s},' +
    '"citizenship":%s,' +
    '"status":%s}', [
    ObjName, DS2JsonMin(IDS,Pfx),
    TDS2JSON.MakeBirthPlace(IDS, Pfx),
    TClassifier.SetCT(IDS.FieldByName(Pfx + 'GRAJD').AsString, 8),
    TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18)]);
end;


// Свидетельство о смене ФИО
class function TActChgName.ChgNameDS2Json(IDS : TDataSet) : string;
var
  org,
  r,
  s : string;
begin
  s := '"cng_cert_data":{' +
    '"person":{' + ChgNameDS2JsonOne(IDS, '', 'person_data') + ',';
  s := s +
    TDS2JSON.MakeActData(IDS, 'birth_act_data', 'R_') + ',';

  s := s + Format('"old_last_name":"%s","old_name":"%s","old_patronymic":"%s"},', [
    IDS.FieldByName('DO_FAMILIA').AsString,
    IDS.FieldByName('DO_NAME').AsString,
    IDS.FieldByName('DO_OTCH').AsString]);
  s := s + '"reason":"' + IDS.FieldByName('OSNOV').AsString + '",';

  Result := s +
    TDS2JSON.MakeActData(IDS, 'cng_act_data') + ',' +
    TDS2JSON.MakeDocCertif(IDS, 'cng_certificate_data', IDS.FieldByName('DOC_TIP').AsString) + '}';
end;












// Числовое целое из MemTable
function TPersDataDTO.GetFI(sField: String): Integer;
begin
  try
    Result := FDoc.FieldByName(sField).AsInteger;
  except
    Result := null;
  end;
end;

// Строковое из MemTable
function TPersDataDTO.GetFS(sField: String): String;
begin
  Result := FDoc.FieldByName(sField).AsString;
end;

// Дата из MemTable
function TPersDataDTO.GetFD(sField: String): TDateTime;
begin
  Result := FDoc.FieldByName(sField).AsDateTime;
end;

// Логическое из MemTable
function TPersDataDTO.GetFB(sField: String): String;
begin
  try
    Result := Iif(FDoc.FieldByName(sField).AsBoolean, 'true', 'false');
  except
    Result := null;
  end;
end;


// Вставить число в JSON-поток
// Вставить логическое
// Вставить значение ключа
procedure TPersDataDTO.AddNum(const ss1: string; ss2: Variant);
begin
  ss2 := VarToStrDef(ss2, 'null');
  FJSONStream.WriteString('"' + ss1 + '":' + ss2 + ',');
end;

// Вставить NULL
procedure TPersDataDTO.AddNum(const ss1: string);
begin
  AddNum(ss1, null);
end;

// Вставить строку
procedure TPersDataDTO.AddStr(const ss1: string; ss2: String = '');
begin
  if (Pos('"', ss2) > 0) then
    ss2 := StringReplace(ss2, '"', '\"', [rfReplaceAll]);
  ss2 := '"' + ss2 + '"';
  FJSONStream.WriteString('"' + ss1 + '": ' + ss2 + ',');
end;
  // Вставить дату

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
    FJSONStream.WriteString('"cover":{' + '"message_type":{"code": "88","type":-2},' + '"message_source":{"code": "7689","type": 80},' + '"agreement":{"operator_info": "Организация адрес", "target":"верификация персональных данных","rights": [201,703,208,480,481,482,490,491,527,528,252,465,466,516,517],' + '"issue_date": "2019-12-07T13:22:09.619+03:00", "expiry_date": "2023-12-07T13:22:09.619+03:00", "assignee_persons": ["инспектор Иванов", "начальник инспектора Петров"]},' + '"dataset": [15]}');
  finally
      // Последней была запятая, вернемся для записи конца объекта
    FJSONStream.Seek(-1, soCurrent);
    FJSONStream.WriteString('},');
  end;

end;
















// Тело документа для POST
function TPersDataDTO.MemDoc2JSON(dsDoc: TDataSet; dsChild: TDataSet; StreamDoc: TStringStream; NeedUp : Boolean): Boolean;
var
  s, sURL, sPar, sss, sF, sFld, sPath, sPostDoc, sResponse, sError, sStatus, sId: String;
  sUTF : UTF8String;
  ws : WideString;
  new_obj, obj: ISuperObject;
  nSpr, n, i, j: Integer;
  lOk: Boolean;



// Форма 19-20
  procedure PostForm19_20;
  begin
    FJSONStream.WriteString('"form19_20":{');
    AddStr('form19_20Base', 'form19_20');
    try
    finally
      // Последней была запятая, вернемся для записи конца объекта
      FJSONStream.Seek(-1, soCurrent);
      FJSONStream.WriteString('},');
    end;
  end;



begin
  Result := False;
  FJSONStream := StreamDoc;
  FJSONStream.WriteString('{');
  try

    // Будет null
    AddNum('pid');


    sUTF := AnsiToUtf8(StreamDoc.DataString);
    FJSONStream.Seek(0, soBeginning);
    FJSONStream.WriteString(sUTF);
    Result := True;
  finally
  // Последней была запятая, вернемся для записи конца объекта
    StreamDoc.Seek(-1, soCurrent);
    StreamDoc.WriteString('}');
  end;
end;






end.
