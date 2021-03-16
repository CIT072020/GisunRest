unit uROCDTO;

{$DEFINE SIGN}
{$DEFINE AVEST_GISUN}

interface

uses
  Classes,
  Types,
  Windows,
  DB,
  kbmMemTable,
  superobject,
  superdate,
  uAvest,
  AvCryptMail,
  SasaINiFile,
  uROCService;

type
  // Поддержка ЭЦП и сертификатов
  TSecureExchg = class
  private
    FMeta : TSasaIniFile;
    FAvest : TAvest;
    FPin : string;

    FSign : string;
    FSignRaw : string;
    FCertif : string;
    FAuth : string;

    FPubKey : string;
    FSignPost : Boolean;
    // Способ формирования ЭЦП для сообщения
    FSignMode : Integer;
    // Использование формата ASN при формировании ЭЦП для RAW
    FASNMode : Integer;

    FSignGet : Boolean;

    procedure DebSec(FileDeb: String; x: Variant);
    function AvestReady(var strErr: String): Boolean;
    function TryOpenSess(var hSession: AvCmHc; UseDef : Boolean = True) : DWORD;

    function SignTextRaw(var sText, sSign: ANSIString; var sCert:String; lOpenDefSession: Boolean; AsnMode : DWORD) : Boolean;
    function VerifyTextRaw(sText: ANSIString; sSign: ANSIString; sCert: String; lOpenDefSession: Boolean; AsnMode : DWORD) : Boolean;

  protected
  public
    //property Pin : string read FPin write FPin;
    property Sign : string read FSign write FSign;
    property Certif : string read FCertif write FCertif;
    property PubKey : string read FPubKey write FPubKey;
    property SignRaw : string read FSignRaw write FSignRaw;
    property Auth : string read FAuth write FAuth;

    property Meta : TSasaIniFile read FMeta write FMeta;
    property SignPost : Boolean read FSignPost write FSignPost;
    property SignMode : Integer read FSignMode write FSignMode;
    property SignGet : Boolean read FSignGet write FSignGet;
    property Avest : TAvest read FAvest write FAvest;

    function CreateESign(var sUtf8: Utf8String; SignType : Integer; var strErr: String): Boolean;
    function VerifyESign(var sSignedUTF: Utf8String; const sSign, sCert : string; var strErr: String): Boolean;

    constructor Create(MetaINI : TSasaIniFile);

  published
  end;

  // Чтение списка ИН
  TIndNomDTO = class
  public
    class function GetIndNumList(SOArr: ISuperObject; IndNum : TkbmMemTable; EmpTbl : Boolean = True): Integer;
  end;

  // Чтение/Запись установочных данных
  TDocSetDTO = class
  private
    // MemTable with Docs
    FDoc : TDataSet;
    FChild : TDataSet;
    FSO : ISuperObject;

    function GetFS(sField: String): String;
    function GetFI(sField: String): Integer;
    function GetFD(sField: String): TDateTime;
    // Код из справочного реквизита
    //function GetCode(sField: String; KeyField : string = 'klUniPK'): Integer;
    function GetCode(sField: String; KeyField: string = 'klUniPK'): Variant;
    function GetName(sField: String): string;

    // Паспортные данные
    procedure GetPasp;
    // Место рождения
    procedure GetPlaceOfBirth;
    // Место проживания
    procedure GetPlaceOfLiving;
    // Белорусская версия
    procedure GetByVer;
    // Адрес регистрации
    procedure GetROC(SODsdAddr: ISuperObject);
    // Форма 19-20
    procedure GetForm19_20(SOf20 : ISuperObject; MasterI: integer);
    // Данные по детям из внутреннего массива
    procedure GetChild(SOA: ISuperObject; MasterI: integer);

  public
    NeedUpper : Boolean;

    // Список документов из SuperObject сохранить в MemTable
    function GetDocList(SOArr: ISuperObject): Integer;
    function MemDoc2JSON(dsDoc: TDataSet; dsChild: TDataSet; StreamDoc: TStringStream; NeedUp : Boolean): Boolean;

    constructor Create(MTDoc, MTChild : TDataSet);

    class function GetNsi(SOArr: ISuperObject; Nsi: TkbmMemTable; EmpTbl: Boolean = True): Integer;
  end;


implementation

uses
  Forms,
  SysUtils,
  Variants,
  NativeXml,
  EncdDecd,
  FuncPr,
  uROCNSI;

constructor TSecureExchg.Create(MetaINI : TSasaIniFile);
begin
  inherited Create;
  FSign    := 'amlsnandwkn&@871099udlaukbdeslfug12p91883y1hpd91h';
  FCertif  := '109uu21nu0t17togdy70-fuib';
  Meta     := MetaINI;
  Avest    := TAvest.Create;
  Avest.FDeleteCRLF := True;
  FAuth    := Meta.ReadString(SCT_SECURE, 'Authorization', '');
  SignPost := Meta.ReadBool(SCT_SECURE, 'SIGNPOST', False);
  // Default - AVCMF_ADD_SIGN_CERT
  SignMode := Meta.ReadInteger(SCT_SECURE, 'SIGNMODE', SIGN_WITH_DATA);
  SignGet  := Meta.ReadBool(SCT_SECURE, 'SIGNGET', False);
  FASNMode := SIGN_NO_ASN;
end;

{
function TSecureExchg.SetHeadSign: string;
begin
  FSign  := 'amlsnandwkn&@871099udlaukbdeslfug12p91883y1hpd91h';
  Result := FSign;
end;

function TSecureExchg.SetHeadCertif: string;
begin
  FCertif := '109uu21nu0t17togdy70-fuib';
  Result  := FCertif;
end;
}

// Список убывших
class function TIndNomDTO.GetIndNumList(SOArr: ISuperObject; IndNum : TkbmMemTable; EmpTbl : Boolean = True): Integer;
var
  i : Integer;
  FSO: ISuperObject;
begin
  Result := 0;
  try
    if (EmpTbl = True) then
      IndNum.EmptyTable;
    i := 0;
    while (i <= SOArr.AsArray.Length - 1) do begin
      FSO := SOArr.AsArray.O[i];
      IndNum.Append;
      IndNum.FieldByName('IDENTIF').AsString         := FSO.S[CT('IDENTIFIER')];
      IndNum.FieldByName('ORG_WHERE_CODE').AsInteger := FSO.O[CT('SYS_ORGAN_WHERE')].I[CT('CODE')];
      IndNum.FieldByName('ORG_WHERE_NAME').AsString  := FSO.O[CT('SYS_ORGAN_WHERE')].S[CT('LEX')];
      IndNum.FieldByName('ORG_FROM_CODE').AsInteger  := FSO.O[CT('SYS_ORGAN_FROM')].I[CT('CODE')];
      IndNum.FieldByName('ORG_FROM_NAME').AsString   := FSO.O[CT('SYS_ORGAN_FROM')].S[CT('LEX')];
      IndNum.FieldByName('DATEREC').AsDateTime       := sdDateTimeFromString(FSO.S[CT('REG_DATE')], false);
      IndNum.FieldByName('PID').AsString             := FSO.S[CT('pid')];
      IndNum.Post;
      i := i + 1;
    end;
    Result := i;
  except
    Result := -1;
  end;
end;


constructor TDocSetDTO.Create(MTDoc, MTChild : TDataSet);
begin
  inherited Create;
  FDoc := MTDoc;
  FChild := MTChild;
end;

// Строковое из MemTable
function TDocSetDTO.GetFS(sField: String): String;
begin
  Result := FDoc.FieldByName(sField).AsString;
end;

// Числовое целое из MemTable
function TDocSetDTO.GetFI(sField: String): Integer;
begin
  try
    Result := FDoc.FieldByName(sField).AsInteger;
  except
    Result := null;
  end;
end;


// Дата из MemTable
function TDocSetDTO.GetFD(sField: String): TDateTime;
begin
  Result := FDoc.FieldByName(sField).AsDateTime;
end;


// Поля ключевого реквизита
{
function TDocSetDTO.GetKeyField(sField: String; KeyField : string = 'klUniPK'): Integer;
begin
  Result := FSO.O[KeyField].I['code'];
end;
}

// Код из справочного реквизита
function TDocSetDTO.GetCode(sField: String; KeyField: string = 'klUniPK'): Variant;
begin
  try
    Result := FSO.O[sField].O[KeyField].I['code'];
  except
    Result := null;
  end;
end;

// Наименование из справочного реквизита
function TDocSetDTO.GetName(sField: String): string;
begin
  try
    Result := FSO.O[sField].S['lex1'];
  except
    Result := '';
  end;
end;


  // Паспортные данные
procedure TDocSetDTO.GetPasp;
var
  d: TDateTime;
begin
  FDoc.FieldByName('PASP_SERIA').AsString := FSO.S[CT('docSery')];
  FDoc.FieldByName('PASP_NOMER').AsString := FSO.S[CT('docNum')];
  FDoc.FieldByName('PASP_DATE').AsDateTime := JavaToDelphiDateTime(FSO.I[CT('docDateIssue')]);
  FDoc.FieldByName('docIssueOrgan').AsInteger := GetCode('docIssueOrgan');
  FDoc.FieldByName('PASP_VIDAN').AsString := GetName('docIssueOrgan');

  FDoc.FieldByName('docAppleDate').AsDateTime := JavaToDelphiDateTime(FSO.I[CT('docAppleDate')]);

  //d := JavaToDelphiDateTime(FSO.I[CT('expireDate')]);
  FDoc.FieldByName('expireDate').AsDateTime := JavaToDelphiDateTime(FSO.I[CT('expireDate')]);

  FDoc.FieldByName('docType').AsInteger := GetCode('docType');
  FDoc.FieldByName('docType_NAME').AsString := GetName('docType');

  FDoc.FieldByName('DateR').AsDateTime := STOD(FSO.S[CT('bdate')]);
  FDoc.FieldByName('CITIZEN').AsInteger := GetCode('citizenship');
  FDoc.FieldByName('CITIZEN_NAME').AsString := GetName('citizenship');

  GetPlaceOfBirth;

  FDoc.FieldByName('FAMILIA_B').AsString := FSO.S[CT('surnameBel')];
  FDoc.FieldByName('NAME_B').AsString := FSO.S[CT('nameBel')];
  FDoc.FieldByName('OTCH_B').AsString := FSO.S[CT('snameBel')];

  FDoc.FieldByName('FAMILIA_E').AsString := FSO.S[CT('surnameEn')];
  FDoc.FieldByName('NAME_E').AsString := FSO.S[CT('nameEn')];


end;


// Место рождения
procedure TDocSetDTO.GetPlaceOfBirth;
var
  d: TDateTime;
begin
  try
    FDoc.FieldByName('GOSUD_R').AsInteger := GetCode('countryB');
    FDoc.FieldByName('GOSUD_R_NAME').AsString := GetName('countryB');
  except
  end;
end;


// Место проживания
procedure TDocSetDTO.GetPlaceOfLiving;
begin
end;

// Белорусская версия
procedure TDocSetDTO.GetByVer;
begin
end;


// Адрес регистрации
procedure TDocSetDTO.GetROC(SODsdAddr: ISuperObject);
begin
  if (Assigned(SODsdAddr) and (Not SODsdAddr.IsType(stNull))) then begin
    FDoc.FieldByName('villageCouncil').AsString := SODsdAddr.S[CT('villageCouncil')];
    FDoc.FieldByName('vilCouncilObjNum').AsInteger := SODsdAddr.I[CT('vilCouncilObjNum')];

    FDoc.FieldByName('ateObjectNum').AsInteger := SODsdAddr.I[CT('ateObjectNum')];
    FDoc.FieldByName('ateElementUid').AsInteger := SODsdAddr.I[CT('ateElementUid')];
    FDoc.FieldByName('ADRES_ID').AsInteger := SODsdAddr.I[CT('ateAddrNum')];
    FDoc.FieldByName('house').AsString := SODsdAddr.S[CT('house')];
    FDoc.FieldByName('korps').AsString := SODsdAddr.S[CT('korps')];
    FDoc.FieldByName('app').AsString := SODsdAddr.S[CT('app')];
  end;
end;

// Форма 19-20
procedure TDocSetDTO.GetForm19_20(SOf20: ISuperObject; MasterI: integer);
var
  s : string;
  IsF20: Boolean;
  NCh: Integer;
  OldSO, SOChild: ISuperObject;
begin
  OldSO := FSO;
  try
    if (Assigned(SOf20) and (Not SOf20.IsType(stNull))) then begin
      FSO := SOf20;
      FDoc.FieldByName('signAway').AsBoolean := SOf20.B[CT('signAway')];
      FDoc.FieldByName('GOSUD_O').AsInteger := GetCode('countryPu');
      FDoc.FieldByName('GOSUD_O_NAME').AsString := GetName('countryPu');
      FDoc.FieldByName('OBL_O_NAME').AsString := SOf20.S[CT('areaPu')];
      FDoc.FieldByName('RAION_O_NAME').AsString := SOf20.S[CT('regionPu')];

      //FDoc.FieldByName('GOROD_O_NAME').AsString := SOf20.S[CT('cityPu')];
      s := SOf20.S[CT('cityPu')];
      FDoc.FieldByName('GOROD_O_NAME').AsString := s;

      FDoc.FieldByName('typeCityPu').AsInteger := GetCode('typeCityPu');
      FDoc.FieldByName('typeCityPu_NAME').AsString := GetName('typeCityPu');

      FDoc.FieldByName('regType').AsInteger := GetCode('regType');
      FDoc.FieldByName('regType_NAME').AsString := GetName('regType');


      FDoc.FieldByName('DATE_O').AsDateTime := JavaToDelphiDateTime(FSO.I[CT('datePu')]);
        // Сведения о детях
      try
        SOChild := FSO.O[CT('infants')];
        NCh := SOChild.AsArray.Length;
      except
        NCh := 0;
      end;

      if (Assigned(SOChild)) and (NCh > 0) then begin
        GetChild(SOChild, MasterI);
      end;
      FDoc.FieldByName('DETI').AsInteger := NCh;
    end;
  finally
    FSO := OldSO;
  end;
end;




// Данные по детям из внутреннего массива
procedure TDocSetDTO.GetChild(SOA: ISuperObject; MasterI: integer);
var
  iV, j: Integer;
  s: string;
  Prev, SO: ISuperObject;
begin
  Prev := FSO;
  try
    try
      for j := 0 to SOA.AsArray.Length - 1 do begin
        FSO := SOA.AsArray.O[j];
        FChild.Append;
        FChild.FieldByName('MID').AsInteger := MasterI;
        FChild.FieldByName('PID').AsString := FSO.S[CT('pid')];
      //FChild.FieldByName('IDENTIF').AsString := FSO.S[CT('identif')];
        FChild.FieldByName('FAMILIA').AsString := FSO.S[CT('surname')];
        FChild.FieldByName('NAME').AsString := FSO.S[CT('name')];
        FChild.FieldByName('OTCH').AsString := FSO.S[CT('sname')];

        FChild.FieldByName('POL').AsString := TNsiRoc.Sex(GetCode('sex'), GET_VAL);

        FChild.FieldByName('BDATE').AsDateTime := STOD(FSO.S[CT('bdate')]);
        FChild.FieldByName('DATER').AsDateTime := UnixStrToDateTime(FSO.S[CT('dateRec')]);
        FChild.FieldByName('OTNOSH').AsInteger := GetCode('rel');
        FChild.FieldByName('OTNOSH_NAME').AsString := GetName('rel');

        FChild.Post;
      end;
    except
    end;
  finally
    FSO := Prev;
  end;
end;




// Список DSD
function TDocSetDTO.GetDocList(SOArr: ISuperObject): Integer;
var
  s: string;
  i: Integer;
  d: TDateTime;
  v: Variant;
begin
  Result := 0;
  try
    i := 0;
    while (i <= SOArr.AsArray.Length - 1) do begin
      FSO := SOArr.AsArray.O[i];
      FDoc.Append;
      FDoc.FieldByName('PID').AsString := FSO.S[CT('pid')];

      //FDoc.FieldByName('view').AsInteger := GetCode('view');
      FDoc.FieldByName('LICH_NOMER').AsString := FSO.S[CT('identif')];
      FDoc.FieldByName('sysDocType').AsInteger := GetCode('sysDocType');
      FDoc.FieldByName('sysDocName').AsString := GetName('sysDocType');
      FDoc.FieldByName('Familia').AsString := FSO.S[CT('surname')];
      FDoc.FieldByName('Name').AsString := FSO.S[CT('name')];
      FDoc.FieldByName('Otch').AsString := FSO.S[CT('sname')];

      FDoc.FieldByName('POL').AsString := TNsiRoc.Sex(GetCode('sex'), GET_VAL);

      FDoc.FieldByName('sysOrgan').AsInteger := GetCode('sysOrgan');
      FDoc.FieldByName('ORGAN').AsString := GetName('sysOrgan');

      FDoc.FieldByName('SelSovet').AsInteger := GetCode('villageCouncil');
      FDoc.FieldByName('SelSovet_Name').AsString := GetName('villageCouncil');

      FDoc.FieldByName('WORK_NAME').AsString := FSO.S[CT('workPlace')];
      FDoc.FieldByName('DOLG_NAME').AsString := FSO.S[CT('workPosition')];

      // Паспортные данные
      GetPasp;

      // Место рождения
      GetPlaceOfBirth;
      // Место проживания
      GetPlaceOfLiving;
      // Белорусская версия
      GetByVer;
      // Адрес регистрации
      GetROC(FSO.O[CT('dsdAddressLive')]);
      // Форма 19-20
      GetForm19_20(FSO.O[CT('form19_20')], FDoc.FieldByName('MID').AsInteger);
      FDoc.Post;
      i := i + 1;
    end;
    Result := i;
  except
    Result := -1;
  end;
end;








































//-------------------------------------------------------
function VarKey(nType : Integer; nValue : Int64; Emp : Boolean = False) : String;
begin
  //Result := Format('{"klUniPK":{"type":%d,"code":%d},"lex1":null,"lex2":null,"lex3":null,"dateBegin":null,"active":true}', [nType, nValue]);
  if (NOT Emp) then
    Result := Format('{"klUniPK":{"type":%d,"code":%d}}', [nType, nValue])
  else
    Result := Format('{"klUniPK":{"type":%d,"code":0}}', [nType]);
end;



// Код типа населенного пункта
function VarKeyTypeCity(ICode : Integer = 0) : String;
begin
  Result := VarKey(35, ICode);
end;

// Тип документа
{
function VarKeyDocType(ICode : Integer = 0) : String;
begin
  Result := VarKey(37, ICode);
end;
}
// Территория/область
function VarKeyArea(ICode : Integer = 0) : String;
begin
  Result := VarKey(1, ICode);
end;

// Регион
function VarKeyRegion(ICode : Integer = 0) : String;
begin
  Result := VarKey(29, ICode);
end;

// Населенный пункт
function VarKeyCity(ICode : Integer = 0) : String;
begin
  Result := VarKey(7, ICode);
end;

// Тип Улицы
function VarKeyTypeStreet(ICode : Integer = 0) : String;
begin
  Result := VarKey(38, ICode);
end;

// Улица
function VarKeyStreet(ICode : Integer = 0) : String;
begin
  Result := VarKey(34, ICode);
end;


// Сельсовет
function VarKeyVillage(ICode : Integer = 0) : String;
begin
  Result := VarKey(98, ICode);
end;

// IntrRegion
function VarKeyIntrRegion(ICode : Integer = 0) : String;
begin
  Result := VarKey(99, ICode);
end;


// Тело документа для POST
function TDocSetDTO.MemDoc2JSON(dsDoc: TDataSet; dsChild: TDataSet; StreamDoc: TStringStream; NeedUp : Boolean): Boolean;
var
  s, sURL, sPar, sss, sF, sFld, sPath, sPostDoc, sResponse, sError, sStatus, sId: String;
  sUTF : UTF8String;
  ws : WideString;
  new_obj, obj: ISuperObject;
  nSpr, n, i, j: Integer;
  lOk: Boolean;

  // Вставить число
  // Вставить логическое
  // Вставить значение ключа
  procedure AddNum(const ss1: string; ss2: Variant); overload;
  begin
    //if (VarType(ss2) = varNull) then ss2 := 'null'
    //else ss2 := IntToStr(ss2);
    ss2 := VarToStrDef(ss2, 'null');
    StreamDoc.WriteString('"' + ss1 + '":' + ss2 + ',');
  end;

  procedure AddNum(const ss1: string); overload;
  begin
       AddNum(ss1, null);
  end;



  // Вставить строку
  procedure AddStr(const ss1: string; ss2: String = '');
  begin
    if (Pos('"', ss2) > 0) then
    ss2 := StringReplace(ss2, '"', '\"', [rfReplaceAll]);
    ss2 := '"' + ss2 + '"';
    StreamDoc.WriteString('"' + ss1 + '": ' + ss2 + ',');
  end;
  // Вставить дату

  procedure AddDJ(ss1: String; dValue: TDateTime);
  begin
    if (dValue = 0) or (Dtos(dValue) = '01.01.1970') then
      sss := 'null'
    else
      sss := IntToStr(Delphi2JavaDate(dValue));
    StreamDoc.WriteString('"' + ss1 + '": ' + sss + ',');
  end;



  // Место рождения
procedure PostPlaceOfBorn;
begin
  try
    AddNum('countryB', TNsiRoc.Country(GetFI('GOSUD_R')));
    AddStr('areaB', GetFS('areaB'));
    AddNum('typeCityB', VarKeyCity(GetFI('typeCityB')));
  except
  end;
end;

  // Место проживания
procedure PostPlaceOfLive;
begin
  try
    AddNum('contryL', TNsiRoc.Country(GetFI('countryL')));
    AddNum('areaL', VarKeyArea(GetFI('areaL')));
    AddNum('regionL', VarKeyRegion(GetFI('regionL')));
    AddNum('typeCityL', VarKeyTypeCity(GetFI('typeCityL')));
    AddNum('cityL', VarKeyCity(GetFI('cityL')));
    AddNum('typeStreetL', VarKeyTypeStreet(GetFI('typeStreetL')));
    AddNum('streetL', VarKeyStreet(GetFI('streetL')));

    AddStr('house', GetFS('house'));
    AddStr('korps', GetFS('korps'));
    AddStr('app', GetFS('app'));

    AddStr('areaBBel', GetFS('areaB'));
    AddNum('regionBBelL', GetFI('regionL'));
    AddNum('cityBBel', GetFI('cityL'));

  except
  end;
end;

  // Схема Паспорт
procedure PostPasport;
begin
  try
    AddStr('docSery', GetFS('PASP_SERIA'));                       // серия основного документа
    AddStr('docNum', GetFS('PASP_NOMER'));                       // номер основного документа
    AddDJ('docDateIssue', GetFD('PASP_DATE'));           // дата выдачи основного документа
    AddNum('docType', TNsiRoc.DocType(GetFI('docType')));  // тип основного документа
    AddNum('docIssueOrgan', TNsiRoc.PaspOrg(GetFI('docIssueOrgan'),GetFS('PASP_VIDAN')));    //###  код органа

    AddDJ('docAppleDate', GetFD('docAppleDate'));            // дата подачи документа  ???
    AddDJ('expireDate', GetFD('expireDate'));                // дата действия  ???
    AddNum('docOrgan');                                       // орган выдачи основного документа

    //AddStr('surnameBel', getFld('FAMILIA'));
    //AddStr('nameBel', getFld('NAME'));
    //AddStr('snameBel', getFld('OTCH'));

    AddStr('surnameEn', GetFS('FAMILIA_E'));
    AddStr('nameEn', GetFS('NAME_E'));
  except
  end;
end;

// Структура dsdAddressLive
procedure PostDsdAddress;
begin
  try
    StreamDoc.WriteString('"dsdAddressLive":{');
    AddStr('dsdAddressLiveBase', 'dsdAddressLive');
    AddNum('pid');
    {
    AddStr('areaL', GetFS('МИНСК'));
    AddNum('areaObjNum');
    AddStr('regionL');
    AddNum('regionObjNum', 0);
    AddStr('villageCouncil');
    AddNum('vilCouncilObjNum', 0);
    AddStr('typeCityL', 'г.');
    AddStr('cityL');
    AddStr('typeStreetL');
    AddStr('streetL');

    AddStr('house', GetFS('house'));
    AddStr('korps', GetFS('korps'));
    AddStr('app', GetFS('app'));
    AddNum('ateObjectNum', GetFI('ateObjectNum'));
    AddNum('ateElementUid', GetFI('ateElementUid'));
    }
    //AddNum('ateAddrNum', GetFI('ADRES_ID'));

    // Для отладки - константы
    AddStr('areaL', 'МИНСК');
    AddNum('areaObjNum', 0);
    AddStr('regionL');
    AddNum('regionObjNum', 0);
    AddStr('villageCouncil');
    AddNum('vilCouncilObjNum', 0);
    AddStr('typeCityL', 'г.');
    AddStr('cityL');
    AddStr('typeStreetL');
    AddStr('streetL');

    AddStr('house', '88');
    AddStr('korps', '');
    AddStr('app', '381');
    AddNum('ateObjectNum', 17030);
    AddNum('ateElementUid', 23164);
    AddNum('ateAddrNum');

  // Последней была запятая, вернемся для записи конца объекта
    StreamDoc.Seek(-1, soCurrent);
    StreamDoc.WriteString('},');

  except
  end;
end;


// Форма 19-20
procedure PostForm19_20;
begin
  try
    StreamDoc.WriteString('"form19_20":{');
    AddStr('form19_20Base', 'form19_20');
    AddNum('signAway', 'false');
    AddNum('dateReс');
    AddDJ('dateReg', GetFD('DATEZ'));

    AddNum('marks');
    AddNum('notes');
    AddNum('reason');
    AddNum('term');

    AddNum('datePu');
    AddNum('countryPu', TNsiRoc.Country(GetFI('GOSUD_O')));
    AddStr('areaPu', GetFS('OBL_O_NAME'));
    AddStr('regionPu', GetFS('RAION_O_NAME'));
    AddNum('typeCityPu');
    AddStr('cityPu', GetFS('GOROD_O_NAME'));
    AddNum('typeStreetPu');
    AddNum('streetPu');
    AddNum('housePu');
    AddNum('korpsPu');
    AddNum('appPu');

    AddNum('termReg');
    AddNum('dateRegTill');
    AddNum('causeIssue');
    AddNum('deathDate');
    AddNum('signNoTake');
    AddNum('signNoReg');
    AddNum('signDestroy');
    AddNum('noAddrPu');
    AddNum('regType', TNsiRoc.RegistrType(GetFI('regType')));

    AddNum('maritalStatus');
    AddNum('education');
    AddNum('student');
    AddNum('infants', '[]');

  // Последней была запятая, вернемся для записи конца объекта
    StreamDoc.Seek(-1, soCurrent);
    StreamDoc.WriteString('},');
  except
  end;
end;

begin
  Result := False;
  try
    StreamDoc.WriteString('{');

    AddNum('pid');
    AddStr('identif', GetFS('LICH_NOMER'));
    AddNum('view');
    AddNum('sysDocType', TNsiRoc.SysDocType(GetFI('sysDocType')));
    AddStr('surname', UpperCase(GetFS('Familia')));
    AddStr('name', UpperCase(GetFS('Name')));
    AddStr('sname', UpperCase(GetFS('Otch')));
    AddNum('sex', TNsiRoc.Sex(GetFS('POL')));
    AddNum('citizenship', TNsiRoc.Country(GetFI('CITIZEN')));
    AddNum('sysOrgan', TNsiRoc.SysOrgan(GetFI('sysOrgan')));    //###  код органа откуда отправляются данные !!!
    AddStr('bdate', DTOSDef(GetFD('DateR'), tdClipper, '')); // 19650111

    // Схема Паспорт
    PostPasport;

    AddNum('dsdDateRec');                                        // iuse
    AddNum('regNum');                                            // рег. № карточки
    AddNum('dateRec');                                           // iuse
    AddNum('ateAddress');                                        // iuse
    AddNum('aisPasspDocStatus');                                 // iuse
    AddNum('identifCheckResult');                                // iuse
    AddNum('organDoc');                                          // iuse

    // Место рождения
    PostPlaceOfBorn;

    // Место проживания
    PostPlaceOfLive;

    AddStr('workPlace', GetFS('WORK_NAME'));
    AddStr('workPosition', GetFS('DOLG_NAME'));

    AddNum('villageCouncil', VarKeyVillage(GetFI('SelSovet')));    // код сельсовета
    AddNum('intracityRegion');    //  код

    // Форма 19-20
    //AddNum('form19_20');    //###  код органа
    PostForm19_20;

    // Адрес регистрации
    PostDsdAddress;

    AddNum('getPassportDate');    //iuse
    AddNum('images', '[]');    //###  код органа
    AddNum('addressLast');    //iuse
    AddNum('dossieStatus');    //iuse
    AddNum('status');    //###  код органа

  // Последней была запятая, вернемся для записи конца объекта
    StreamDoc.Seek(-1, soCurrent);
    StreamDoc.WriteString('}');

    sUTF := AnsiToUtf8(StreamDoc.DataString);
    //ws := UTF8Encode();
    StreamDoc.Seek(0, soBeginning);
    StreamDoc.WriteString(sUTF);
    Result := True;
  except
    Result := False;
  end;
end;









function GetChildLinks(SOArr: ISuperObject; LeftM: string): string;

  function CT(s: string): string;
  begin
    Result := s;
  end;

const
  LeftPad = '              ';
var
  v, s: string;
  NCh, i: Integer;
  SOCh, SO: ISuperObject;
begin
  try
    s := '';
    i := 0;
    while (i <= SOArr.AsArray.Length - 1) do begin
      SO := SOArr.AsArray.O[i];
      s := s + Format('%srid = %-20d%s', [LeftM, SO.I[CT('rid')], CRLF]);
      s := s + Format('%stype:   type:%8d code: %12d lex1: %s%s', [LeftM,
        SO.O[CT('type')].O[CT('klUniPK')].i[CT('type')],
        SO.O[CT('type')].O[CT('klUniPK')].i[CT('code')],
        SO.O[CT('type')].s[CT('lex1')], CRLF]);

      SOCh := SO.O[CT('type')].O[CT('childKlUniLinks')];
      if (Assigned(SOCh) and (Not SOCh.IsType(stNull))) then begin
        NCh := SOCh.AsArray.Length;
        if (NCh > 0) then begin
          v := GetChildLinks(SOCh, LeftM + LeftPad);
          s := s + v;
        end;
      end;

      s := s + Format('%sparType: type:%8d code: %12d lex1: %s%s', [LeftM,
        SO.O[CT('parType')].O[CT('klUniPK')].i[CT('type')],
        SO.O[CT('parType')].O[CT('klUniPK')].i[CT('code')],
        SO.O[CT('parType')].s[CT('lex1')], CRLF]);
      i := i + 1;
    end;
    Result := s;
  except
    Result := 'Err-SO';
  end;
end;


class function TDocSetDTO.GetNsi(SOArr: ISuperObject; Nsi: TkbmMemTable; EmpTbl: Boolean = True): Integer;
  function CT(s: string): string;
  begin
    Result := s;
  end;

var
  b : Boolean;
  s : string;
  NCh,
  j,
  i : Integer;
  SOCh,
  SO: ISuperObject;
begin
  Result := 0;
  try
    if (EmpTbl = True) then
      Nsi.EmptyTable;
    i := 0;
    while (i <= SOArr.AsArray.Length - 1) do begin
      SO := SOArr.AsArray.O[i];
      Nsi.Append;
      Nsi.FieldByName('Type').AsInteger := SO.O[CT('klUniPK')].I[CT('type')];
      Nsi.FieldByName('Code').AsInteger := SO.O[CT('klUniPK')].I[CT('code')];
      Nsi.FieldByName('Lex1').AsString  := SO.S[CT('lex1')];
      Nsi.FieldByName('Lex2').AsString  := SO.S[CT('lex2')];
      Nsi.FieldByName('Lex3').AsString  := SO.S[CT('lex3')];
      Nsi.FieldByName('DateBegin').AsDateTime := JavaToDelphiDateTime(SO.I[CT('dateBegin')]);
      Nsi.FieldByName('Active').AsBoolean := SO.B[CT('active')];
      Nsi.FieldByName('TempId').AsString  := SO.S[CT('tempId')];

      SOCh := SO.O[CT('childKlUniLinks')];
      NCh := SOCh.AsArray.Length;
      Nsi.FieldByName('NChilds').AsInteger := NCh;
      if (NCh > 0) then
        s := GetChildLinks(SOCh, '')
      else
        s := '';
      Nsi.FieldByName('ChildKlUniLinks').AsString  := s;
      Nsi.Post;
      i := i + 1;
    end;
    Result := i;
  except
    Result := -1;
  end;
end;



//----------------------------------------------------------------
procedure TSecureExchg.DebSec(FileDeb: String; x: Variant);
begin
  if (Avest.Debug = True) then begin
    MemoWrite(FileDeb, x);
  end;
end;

function TSecureExchg.AvestReady(var strErr: String): Boolean;
var
  s: string;
begin
  Result := True;
  if (Avest.IsActive = False) then begin
    s := Meta.ReadString(SCT_SECURE, 'CSPNAME', NAME_AVEST_DLL);
    Result := Avest.LoadDLL(s, strErr);
  end;
end;


function TSecureExchg.TryOpenSess(var hSession: AvCmHc; UseDef: Boolean = True): DWORD;
begin
  if (UseDef = True) then begin
    Result := Avest.InitSession(True);   // если сессия не открыта, то откроем, но закрывать не будем !!!
    if (Result = AVCMR_SUCCESS) then
      hSession := Avest.hDefSession;
  end else
    Result := Avest.ActivateSession(hSession, True);
end;


//-------------------------------------------------------
function TSecureExchg.SignTextRaw(var sText, sSign: ANSIString; var sCert:String; lOpenDefSession: Boolean; AsnMode : DWORD) : Boolean;
var
  ret : Boolean;
  hSession: AvCmHc;
  w, res: DWORD;
begin
  ret := True;
  try
    Avest.CheckMsg(TryOpenSess(hSession, lOpenDefSession), True);
    Avest.CheckMsg(AvCmSignRawData(hSession, nil, @sText[1], Length(sText), 0, w, AsnMode), True);
    SetLength(sSign, w);
    Avest.CheckMsg(AvCmSignRawData(hSession, nil, @sText[1], Length(sText), @sSign[1], w, AsnMode), True);
    if (sCert = '+') then begin
      sCert := '';
      Avest.CheckMsg(Avest.GetCert(hSession, sCert), True);
    end;
    if (NOT lOpenDefSession) then
      Avest.CheckMsg(Avest.DeactivateSession(hSession), True);
  except
    ret := False;
  end;
  Result := ret;
end;

//-------------------------------------------------------
function TSecureExchg.VerifyTextRaw(sText: ANSIString; sSign: ANSIString; sCert: String; lOpenDefSession: Boolean; AsnMode : DWORD): Boolean;
var
  ret : Boolean;
  w : DWORD;
  hSession: AvCmHc;
  hMycert: AvCmHcert;
begin
  ret := True;
  try
    Avest.CheckMsg(TryOpenSess(hSession, lOpenDefSession), True);
    if (sCert = '') then begin
      w := SizeOf(hMycert);
      Avest.CheckMsg(AvCmGetObjectInfo(hSession, AVCM_MY_CERT, @hMycert, w, 0), True);
    end
    else
      Avest.CheckMsg(AvCmOpenCert(hSession, @sCert[1], Length(sCert), hMycert, 0), True);
    Avest.CheckMsg(AvCmVerifyRawDataSign(hMycert, nil, @sText[1], Length(sText), @sSign[1], Length(sSign), AsnMode), True);
    if (NOT lOpenDefSession) then
      Avest.CheckMsg(Avest.DeactivateSession(hSession), True);
  except
    ret := False;
  end;
  Result := ret;
end;











//----------------------------------------------------------------
// Подписать JSON-документ и преобразовать в Base64
function TSecureExchg.CreateESign(var sUtf8: Utf8String; SignType : Integer; var strErr: String): Boolean;
var
  sSignRaw, sCertRaw,
  sPubKey,
  sCert, sSignedUTF : String;
  ASNMode : DWORD;
  lOpenDefSession, l: Boolean;
begin
  strErr  := '';
  Result  := True;
  sCert   := '';
  sPubKey := '';
  sSignedUTF := '';
  sSignRaw := '';

  if (SignPost = True) then begin
    if (AvestReady(strErr)) then begin
      DebSec('Body.json', sUtf8);
      Avest.slError.Clear;
      try
        lOpenDefSession := True;
        //AvestSignType := 1; // AVCMF_ADD_SIGN_CERT
        //AvestSignType := 2; // AVCMF_DETACHED + AVCMF_ADD_SIGN_CERT
        //AvestSignType := 3; // AVCMF_DETACHED

        sCert := '+';  // !!! вернуть сертификат в переменную sCert !!!
        Avest.CheckMsg(Avest.SignText(ANSIString(sUtf8), sSignedUTF, sCert, lOpenDefSession, SignType, true), True);
        sCertRaw := '+';  // !!! вернуть сертификат !!!
        if (FASNMode = SIGN_WITH_ASN) then
          ASNMode := 0
        else
          ASNMode := AVCMF_RAW_SIGN;

        if (SignTextRaw(ANSIString(sUtf8), sSignRaw, sCertRaw, lOpenDefSession, ASNMode) = True) then begin
          // Подписанное сообщение
          DebSec('sign64', sSignedUTF);
          DebSec('sign64Raw', EncodeBase64(sSignRaw));

          // DER-представление сертификата
          DebSec('cert64', sCert);
          //DebSec('cert64Raw', EncodeBase64(sCertRaw));

          Avest.CheckMsg(Avest.GetPublicKey(Avest.hDefSession, sPubKey), True);
          DebSec('PubKey', sPubKey);
          sPubKey := EncodeBase64(sPubKey);
          DebSec('PubKeyBase64', sPubKey);
        end
        else
          Result := false;
      except
          Result := false;
      end;
      if (Result = False) then begin
          strErr := 'Ошибка ЭЦП: ' + Avest.slError[Avest.slError.Count - 1];
        // получить сертификат не удалось ?
          sCert := ''; // !!!
      end;
    end
    else
      Result := False;
  end;
  Certif := sCert;
  PubKey := sPubKey;
  Sign   := sSignedUTF;
  SignRaw := sSignRaw;
end;


//----------------------------------------------------------------
// Проверить подпись
function TSecureExchg.VerifyESign(var sSignedUTF: Utf8String; const sSign, sCert : string; var strErr: String): Boolean;
var
  sUtf8 : Utf8String;
  RetAv,
  ASNMode : DWORD;
  lOpenDefSession,
  l: Boolean;
  LSigns : TStringList;

begin
  strErr := '';
  Result := True;
  if (SignGet = True)
    AND (Length(sSign) + Length(sCert) > 0) then begin
    if (AvestReady(strErr)) then begin
      Avest.slError.Clear;
      DebSec('SignedBody', sSignedUTF);
      //sUtf8 := DecodeString(sSignedUTF);
      sUtf8 := sSignedUTF;
      try
        lOpenDefSession := True;
        if (FASNMode = SIGN_WITH_ASN) then
          ASNMode := 0
        else
          ASNMode := AVCMF_RAW_SIGN;
        if (VerifyTextRaw(ANSIString(sUtf8), SignRaw, sCert, lOpenDefSession, ASNMode) = True) then begin
          LSigns := TStringList.Create;
          LSigns.Add(sSign);
          Avest.FBase64 := False;
          RetAv := Avest.SMDOVerify(AnsiString(sSignedUTF), LSigns, False, 0);

          // Подписанное сообщение
          DebSec('BodyUnsigned.JSON', sUtf8);
          sSignedUTF := sUTF8;





        end
        else begin
          Result := false;
          strErr := 'Ошибка ЭЦП: ' + Avest.slError[Avest.slError.Count - 1];
        end;

      finally
      end;

    end
    else
      Result := False;
  end;

end;



end.
