unit uUNNsi;

interface

{$WARN UNIT_PLATFORM OFF}
{$WARN SYMBOL_PLATFORM OFF}

uses
  Classes, DB,
  Windows,
  Controls,
  Forms,
  adscnnct, adstable,
  kbmMemTable,
  superobject,
  httpsend,
  NativeXml,
  EncdDecd,
  uAvest,
  AvCryptMail,
  SasaINiFile,
  FuncPr,
  uUseful,
  uLoggerThr,
  uROCDTO,
  uRestService;

const

  // Секции INI-файла
  SCT_ADMIN   = 'ADMIN';
  SCT_HOST    = 'HOST';
  SCT_SECURE  = 'SECURE';
  SCT_NSI     = 'NSI';

  // Секции INI-файла для описания таблиц
  SCT_TBL_INS = 'TABLE_INDNUM';
  SCT_TBL_DOC = 'TABLE_DOCSETDATA';
  SCT_TBL_CLD = 'TABLE_CHILD';
  SCT_TBL_NSI = 'TABLE_NSI';

  // Персональных данных в в списке уехавших
  // (если окажется слишком много)
  MAX_DATA4IN = 100;

  // функции запросов к серверу
  GET_DEPART_ID  = 1;
  GET_ACTUAL_REG = 2;
  GET_NSI        = 3;
  POST_DOC       = 4;
  GET_TEMP_IN    = 5;
  GET_SRV_READY  = 6;

  // Формат данных для GET/POST
  FMT_20       = 'FMT_20';
  FMT_21       = 'FMT_21';

  // Тип данных в списке параметров для GET
  TLIST_FIO = Integer(1);
  TLIST_INS = Integer(2);

  // Режим создания выходных парметров (TResHTTP)
  NO_DATA   = 1;
  DATA_ONLY = 2;
  NSI_ONLY  = 3;

  // Пути к ресурсам
  RES_HOST     = 'https://a.todes.by:13555';
  RES_GENPOINT = '/village-council-service/api';
  RES_NSI      = '/kluni-service/api';
  RES_TMPIN    = 'https://a.todes.by:13700/identif-validator-service/api/v1/identif/transient/table_name';
  RES_TEST     = '/village-council-service/service/status';

  RESOURCE_LISTID_PATH  = '/movements';
  RESOURCE_LISTDOC_PATH = '/data';
  RESOURCE_POSTDOC_PATH = '/data/save';
  RESOURCE_NSICNTT_PATH = '/kl_uni/with_links';

  // Имена таблиц
  MT_INS   = 'INS';
  MT_DOCS  = 'DOCS';
  MT_CHILD = 'CHILD';
  MT_NSI   = 'NSI';

  // Загрузка всех справочников
  NSIALL   = 99887766;
  // Имя соединения (создается в объекте)
  CONNADS_NAME = 'ROC_CNNCT2NSI';
  // Таблица со всеми НСИ
  ADS_NAME_TEMPL = 'kluni';

  // Поле для преобразования BigInteger -> String
  // в JSON-данных от сервера
  BIGINT_STR = 'pid';

  // Идиотская строка, с помощью которой код возврата становится хорошим
  CURVE_ERR_MSG = '(запись сохранена)';
  ERR404_MSG = ' Что-то пошло не так...';

type

  // Поддержка ЭЦП и сертификатов
  TSecureExchg = class
  private
    FMeta     : TSasaIniFile;
    FAvest    : TAvest;
    //FPin      : string;

    FSign     : string;
    FSignRaw  : string;
    FCertif   : string;
    FAuth     : string;
    FSrvTest  : string;

    FPubKey   : string;
    FSignPost : Boolean;
    // Способ формирования ЭЦП для сообщения
    FSignMode : Integer;
    // Использование формата ASN при формировании ЭЦП для RAW
    FASNMode  : Integer;

    FSignGet  : Boolean;
    // Запрос пароля только 1 раз
    FAskPassOnce  : Boolean;

    procedure DebSec(FileDeb: String; x: Variant);
    function AvestReady(var strErr: String): Boolean;
    function TryOpenSess(var hSession: AvCmHc; UseDef : Boolean = True) : DWORD;

    function SignTextRaw(var sText, sSign: ANSIString; var sCert:String; lOpenDefSession: Boolean; AsnMode : DWORD) : Boolean;
    function VerifyTextRaw(sText: ANSIString; sSign: ANSIString; sCert: String; lOpenDefSession: Boolean; AsnMode : DWORD) : Boolean;
  public
    property Sign : string read FSign write FSign;
    property Certif : string read FCertif write FCertif;
    property PubKey : string read FPubKey write FPubKey;
    property SignRaw : string read FSignRaw write FSignRaw;
    property Auth : string read FAuth write FAuth;

    property Meta : TSasaIniFile read FMeta write FMeta;
    property SignPost : Boolean read FSignPost write FSignPost;
    property SignMode : Integer read FSignMode write FSignMode;
    property SignGet : Boolean read FSignGet write FSignGet;
    property xAvest : TAvest read FAvest write FAvest;

    function CreateESign(var sUtf8: Utf8String; SignType : Integer; var strErr: String): Boolean;
    function VerifyESign(var sSignedUTF: Utf8String; const sSign, sCert : string; var strErr: String): Boolean;

    constructor Create(MetaINI : TSasaIniFile);
    destructor Destroy; override;
  end;

  // параметры для GetDocs
  TParsGet = class
    Organ   : string;
    DateBeg : TDateTime;
    DateEnd : TDateTime;
    First   : Integer;
    Count   : Integer;
    PID     : string;

    //TypeDoc : string;
    FullURL : string;

    FIOrINs  : TStringList;
    // Тип данных во входном списке
    ListType : Integer;
    // Нужны актуальные сведения по ИН или убывшие
    NeedINsOnly : Boolean;
    // Нужны актуальные сведения по ИН или убывшие
    NeedActual  : Boolean;
    FullFIO     : string;
    ChildMode   : Integer;

    constructor Create(DBeg, DEnd : TDateTime; OrgCode : string = ''); overload;
    constructor Create(URL : string); overload;
    constructor Create(INs : TStringList; LType : Integer); overload;
    destructor Destroy; override;
  end;

  // параметры для GetNsi
  TParsNsi = class
    NsiURL   : string;
    NsiPoint : string;

    NsiType   : Integer;
    NsiCode   : Integer;
    FullURL   : string;
    PathAds   : string;
    AdsTName  : string;
    AlterName : string;
    ConnADS   : TAdsConnection;
    ADSNsi    : TAdsTable;
    ADSCopy   : Boolean;
    //ConnOwner : TComponent;
    UserName  : string;
    Password  : string;
    AllNsi    : Boolean;
    AllTypes  : string;
    DicMode   : Boolean;
    MaxLex    : Integer;
    NsiDesc   : TStringList;
    ShowCapt  : string;

    constructor Create(NType : Integer; Meta : TSasaIniFile; Conn : TAdsConnection = nil; Own : TComponent = nil);
    destructor Destroy; override;
  end;

  // параметры для PostDocs
  TParsPost = class
  private
    FChild,
    FDocs   : TkbmMemTable;
    FChildMode : Integer;
  public
    FullURL : string;
    JSONSrc : string;

    property Docs      : TkbmMemTable read FDocs write FDocs;
    property Child     : TkbmMemTable read FChild write FChild;
    property ChildMode : Integer read FChildMode write FChildMode;

    constructor Create(ChildPostMode : Integer; URL : string = '');
  end;

(*
 Выходные результаты для GET/POST
*)
  TResultHTTP = class
  private
    FNsi,
    FChild,
    FDocs,
    FINs    : TkbmMemTable;
    FINCount,
    FCode   : Integer;
    FMsg    : string;
    FStrInf : string;
    FQuery  : Integer;
  protected
  public
    property INs   : TkbmMemTable read FINs write FINs;
    property Docs  : TkbmMemTable read FDocs write FDocs;
    property Child : TkbmMemTable read FChild write FChild;
    property Nsi   : TkbmMemTable read FNsi write FNsi;
    property INCount : Integer read FINCount write FINCount;
    // Результат запроса, 0 - dct uen
    property ResCode : Integer read FCode write FCode;
    // Сообщение об ошибке
    property ResMsg  : string read FMsg write FMsg;
    // Результат запроса в виде символьной строки (например, временный ИН)
    property StrInf  : string read FStrInf write FStrInf;

    procedure ClearRes(QueryCode: Integer);

    constructor Create(Meta: TSasaIniFile);
    destructor Destroy; override;
  end;

  // Загрузка НСИ через REST-сервис
  TNsi = class(TInterfacedObject)
  private
    FMetaName : string;
    FMeta     : TSasaIniFile;

    FHost   : THostReg;
    FHTTP   : THTTPSendEx;
    FSecure : TSecureExchg;
    FDebug  : Boolean;
    FLogger : TLoggerThread;



    FShowProgress : TShowProgress;

    procedure ReadIni;
    procedure GenCreate;
    procedure WriteHTTPHead(Headers: TStringList; Caption : string = '');

    function StoreIndNum(Pars : TParsGet) : integer;
    function GetIndNum(ParsGet: TParsGet; IndNums: TkbmMemTable): Integer;
    //function Docs4CurIN(Pars4GET: string; DocDTO: TDocSetDTO; var sErr : string): Integer;
    function Post1Doc(ParsPost: TParsPost; StreamDoc : TStringStream) : TResultHTTP;
    function SetRetCode(Ret: Boolean; var sErr: string): integer;

    function GetDSDList(ParsGet: TParsGet; APIFunc : Integer): TResultHTTP;

    function VerifyConnect(ParsNsi: TParsNsi; CloseNow: Boolean = False): Boolean;
    function SecureGet(const URL: string; AuthToken : string = '') : Boolean;

    function CreateADSTDic(ParsNsi: TParsNsi; CurNsiType: string; DSNsi: TDataSet; var sErr: string): Integer;
    function CreateADSTFree(ParsNsi : TParsNsi; CurNsiType: string; DSNsi: TDataSet; var sErr : string) : Integer;
    function GetOneNSI(ParsNsi : TParsNsi; CurNsiType: string; URL : string; ROCNsi : TkbmMemTable; var sErr : string): Integer;
  public
    // Параметры и настройки
    property Meta : TSasaIniFile read FMeta write FMeta;
    // Параметры безопасности
    property Secure : TSecureExchg read Fsecure write Fsecure;
    // Параметры HOST
    property Host : THostReg read FHost write FHost;
    property Logger : TLoggerThread read FLogger write FLogger;


    (* Получить содержимое справочника
    *)
    function GetROCNSI(NsiType: integer; Conn : TAdsConnection = nil; AdsTable : string = ''): TResultHTTP;  overload;
    function GetROCNSI(ParsNsi : TParsNsi): TResultHTTP;  overload;

    (* Установить флаг отображения прогресса выполнения запроса
     NewVal = True - отображать прогресс
     AOff   = True - сбросить флаг отображения после выполнения запроса
     Result - предыдущее значение флага
    *)
    function SetProgressVisible(NewVal : Boolean = True; AOff : Boolean = True) : Boolean;

    constructor Create(MName : string); overload;
    constructor Create(MetaINI : TSasaIniFile; Own : TComponent); overload;
    destructor Destroy; override;
  published
  end;

implementation

uses
  SysUtils,
  StrUtils,
  DateUtils,
  synautil,
  synacode,
  adsset;


// Удаление последних BackSlash
function DelLastBSlash(const Src: string): string;
begin
  Result:=Trim(Src);
  while RightStr(Result,1)='/' do
    Result:=Copy(Result,1,Length(Result)-1);
end;
// Проверка лидирующего BackSlash в пути к ресурсу
function LeadBSlash(const Src: string): string;
begin
  Result:=Trim(Src);
  if (AnsiUpperCase(LeftStr(Src, 4)) <> 'HTTP') then
    if (LeftStr(Src, 1) <> '/') then
      Result := '/' + Src;
  Result:=DelLastBSlash(Result);      
end;



function SetNsiAllList(const NsiIDs : string) : TStringList;
var
  i : Integer;
  s : string;
begin
  Result := Split(',', NsiIDs);
  for i := 0 to Result.Count - 1 do begin
    s := Result[i];
    Result[i] := s + '=' + s;
    if (s = '-5') then
      Result[i] := s + '=' + 'Системные органы регистрации';
    if (s = '-2') then
      Result[i] := s + '=' + 'Типы документов';
    if (s = '1') then
      Result[i] := s + '=' + 'Области';
    if (s = '2') then
      Result[i] := s + '=' + 'Отметки АСБ';
    if (s = '3') then
      Result[i] := s + '=' + 'Цели убытия-прибытия';
    if (s = '7') then
      Result[i] := s + '=' + 'Населенные пункты';
    if (s = '8') then
      Result[i] := s + '=' + 'Страны';
    if (s = '16') then
      Result[i] := s + '=' + 'Степени родства';
    if (s = '24') then
      Result[i] := s + '=' + 'Органы';
    if (s = '27') then
      Result[i] := s + '=' + 'Срок прописки(АСБ)';
    if (s = '29') then
      Result[i] := s + '=' + 'Районы';
    if (s = '32') then
      Result[i] := s + '=' + 'Пол';
    if (s = '34') then
      Result[i] := s + '=' + 'Улицы';
    if (s = '35') then
      Result[i] := s + '=' + 'Типы населенных пунктов';
    if (s = '37') then
      Result[i] := s + '=' + 'Типы документов';
    if (s = '38') then
      Result[i] := s + '=' + 'Типы улиц';
    if (s = '39') then
      Result[i] := s + '=' + 'Причины выдачи паспорта';
    if (s = '70') then
      Result[i] := s + '=' + 'Причина составления адресного листка(АСБ)';
    if (s = '98') then
      Result[i] := s + '=' + 'Сельский (поселковый) совет';
    if (s = '99') then
      Result[i] := s + '=' + 'Внутригородской район';
    if (s = '500') then
      Result[i] := s + '=' + 'Тип регистрации АСБ';
    if (s = '501') then
      Result[i] := s + '=' + 'Семейное положение АСБ';
    if (s = '502') then
      Result[i] := s + '=' + 'Образование АСБ';
  end;
end;


//
constructor TParsNsi.Create(NType : Integer; Meta : TSasaIniFile; Conn : TAdsConnection = nil; Own : TComponent = nil);
begin
  inherited Create;
  NsiURL   := Meta.ReadString(SCT_NSI, 'NSIURL', RES_NSI);
  NsiPoint := LeadBSlash(Meta.ReadString(SCT_NSI, 'NSIPATH', RES_NSI));
  NsiType  := NType;
  AllNsi   := Iif(NsiType = NSIALL, True, False);
  // По умолчанию:
  ADSNsi   := nil;
  NsiCode  := 0;
  UserName := 'AdsSys';
  Password := 'sysdba';
  PathAds  := '';
  AdsTName := ADS_NAME_TEMPL;
  AllTypes := '-5,-2,1,2,3,7,8,16,24,27,29,32,34,35,37,38,39,70,98,99,500,501,502';
  DicMode  := True;
  ADSCopy  := False;

  ConnADS  := Conn;
  if (Assigned(Conn)) then
    // Нужна копия в ADS
    ADSCopy := True
  else
    ADSCopy := Meta.ReadBool(SCT_NSI, 'SAVE2ADS', ADSCopy);

  AllTypes := Meta.ReadString(SCT_NSI, 'NSIALL', AllTypes);
  NsiDesc  := SetNsiAllList(AllTypes);
  if (ADSCopy = True) then begin
      AdsTName := Meta.ReadString(SCT_NSI, 'ADSTABLE', AdsTName);
      if (NOT Assigned(ConnADS)) then begin
        // Создается с помощью данных из Meta
        ConnADS := TAdsConnection.Create(Own);
        ConnADS.Name := CONNADS_NAME;
        ConnADS.AdsServerTypes := [stADS_LOCAL];
        ConnADS.LoginPrompt := False;
        PathAds := Meta.ReadString(SCT_NSI, 'ADSPATH', '');
        DicMode := IsDicAds(PathAds);
        if (DicMode = True) then begin
        // Для словарных таблиц
          UserName := Meta.ReadString(SCT_NSI, 'NSIUSER', UserName);
          Password := Meta.ReadString(SCT_NSI, 'NSIPASS', Password);
          ConnADS.Username := UserName;
          ConnADS.Password := Password;
         end;
        ConnADS.ConnectPath := PathAds;
      end;
  end;
  // ???
  FullURL  := '';
end;

destructor TParsNsi.Destroy;
begin
  if Assigned(ConnADS) AND (ConnADS.Name = CONNADS_NAME) then
  // создавал сам
    FreeAndNil(ConnADS);
  if (Assigned(ADSNsi)) then
    FreeAndNil(ADSNsi);
  FreeAndNil(NsiDesc);
  inherited;
end;



// Заполнение параметров из INI-файла
procedure TNsi.ReadIni;
begin
(*
  // Установки из INI или по умолчанию
  FHost.MaxDays     := 10;
  FHost.MaxPersData := MAX_DATA4IN;
  FHost.GetFormat   := FMT_20;
  FHost.PostFormat  := FMT_21;

  FChildGetDef  := CHILD_GET_SEPAR_DS;
//  FChildPostDef := CHILD_POST_INTERN;
  FChildPostDef := CHILD_FREE;

  FDebug := False;

  FHost.URL          := DelLastBSlash(Meta.ReadString(SCT_HOST, 'URL', RES_HOST));
  FHost.ResPath      := LeadBSlash(Meta.ReadString(SCT_HOST, 'RESPATH', RES_GENPOINT));
  FHost.ResPathTmpIN := LeadBSlash(Meta.ReadString(SCT_HOST, 'RESPATH_TMPIN', RES_GENPOINT));
  FHost.ResPathTest  := LeadBSlash(Meta.ReadString(SCT_HOST, 'RESPATH_TEST', RES_GENPOINT));

  FHost.MaxDays     := Meta.ReadInteger(SCT_HOST, 'MAXPERIOD', FHost.MaxDays);
  FHost.MaxPersData := Meta.ReadInteger(SCT_HOST, 'MAX_PERS_DATA', FHost.MaxPersData);
  FHost.PostFormat  := Meta.ReadString(SCT_HOST, 'FORMAT_POST', FHost.PostFormat);
  FHost.GetFormat   := Meta.ReadString(SCT_HOST, 'FORMAT_GET', FHost.GetFormat);

  FChildGetDef  := Meta.ReadInteger(SCT_ADMIN, 'CHILD_GET_MODE', FChildGetDef);
  FChildPostDef := Meta.ReadInteger(SCT_ADMIN, 'CHILD_POST_MODE', FChildPostDef);

  FOrgan := Meta.ReadString(SCT_ADMIN, 'MESSAGESOURCE', '');
  FDebug := Meta.ReadBool(SCT_ADMIN, 'DEBUG', FDebug);
*)
end;


// Общая часть для всех конструкторов
procedure TNsi.GenCreate;
var
  s : string;
begin
(*
  if (NOT Assigned(Meta)) then begin
    if ( NOT FileExists(FMetaName) ) then
      raise Exception.Create('Bad INI-file:' + FMetaName);
    Meta := TSasaIniFile.Create(FMetaName);
  end;
  FHost := THostReg.Create;
  ReadIni;
  Secure := TSecureExchg.Create(Meta);
  s := Meta.ReadString(SCT_ADMIN, 'SYNADLL', '');
  if (Length(s) > 0) then begin
    if (Pos(':\', s) <= 0) then
    // задан относительный путь
      s := ExtractFilePath(Application.ExeName) + s;
    s := IncludeTrailingPathDelimiter(s);
  end;
  FHTTP := THTTPSendEx.Create(s, WriteHTTPHead);

  FShowProgress := TShowProgress.Create;
  FResHTTP      := TResultHTTP.Create(Meta);
*)
end;

// Имя INI-файла
constructor TNsi.Create(MName : string);
begin
  inherited Create;
  FMetaName := MName;
  GenCreate;
end;

// Передан готовый INI
constructor TNsi.Create(MetaINI : TSasaIniFile; Own : TComponent);
begin
  inherited Create;
  Meta := MetaINI;
  // Флаг того, что создавалось не мной
  FMetaName := '';
  GenCreate;
end;


destructor TNsi.Destroy;
begin
  if (FMetaName <> '') then
  // Передавалось имя, INI-объект создавал сам
    FreeAndNil(FMeta);
  FreeAndNil(FHTTP);
  FreeAndNil(FHost);
  FreeAndNil(FSecure);
  FreeAndNil(FShowProgress);
  inherited;
end;

procedure TNsi.WriteHTTPHead(Headers: TStringList; Caption: string = '');
const
  H_OFFS = '    ';
  BETW_STR = '  ...  ';
var
  i: Integer;
  s: string;
  LogList: TStringList;
begin
  if (Assigned(FLogger)) then begin
    if (Caption = '') then
      Caption := DEB_HEADS_REQ;
    LogList := TStringList.Create;
    try
      LogList.AddStrings(Headers);
      for i := 0 to LogList.Count - 1 do begin
        if (Pos(HDR_SIGN, LogList[i]) = 1) OR (Pos(HDR_CERT, LogList[i]) = 1) then
          LogList[i] := CutBigString(LogList[i], BETW_STR, '', 30);
        LogList[i] := H_OFFS + LogList[i];
      end;
      StringsTrim(LogList);
      FLogger.Add2Log(Caption, True, LogList);
    finally
      FreeAndNil(LogList);
    end;
  end;
end;


function TNsi.SetProgressVisible(NewVal : Boolean = True; AOff : Boolean = True) : Boolean;
begin
  Result := FShowProgress.SetProgressVisible(NewVal, AOff);
end;



// установка параметров для GET : получения списка документов по территории
//
// Example:
// /v1/movements/sys_organ/:sys_organ/period/:since/:till?first=1&count=1
// :sys_organ - required
// :since - required
// :till - required
// first=[0]
// count=[500]
function SetPars4GetIDs(Pars : TStringList) : string;
var
  s : string;
begin
  s := Format( '/sys_organ/%s/period/%s/%s?first=%s&count=%s',
    [Pars[0], Pars[1], Pars[2], Pars[3], Pars[4]]);
  Result := s;
end;




// Полученный справочник - в ADS (Dic-Table)
function TNsi.CreateADSTDic(ParsNsi: TParsNsi; CurNsiType: string; DSNsi: TDataSet; var sErr: string): Integer;
var
  Ret, i, MaxF, n: Integer;
  s,
  AName,
  sSQL: string;
  v : Variant;
begin
  Ret := 0;
  try
    try
      if (ParsNsi.ConnADS.IsConnected = False) then
        ParsNsi.ConnADS.Connect;
      if (ParsNsi.ConnADS.IsConnected = True) then begin
        if (ParsNsi.AdsNsi = nil) then begin
          ParsNsi.AdsNsi := TAdsTable.Create(ParsNsi.ConnADS.Owner);
          ParsNsi.AdsNsi.TableName := Iif(ParsNsi.AlterName = '', ParsNsi.AdsTName, ParsNsi.AlterName);
          ParsNsi.AdsNsi.AdsConnection := ParsNsi.ConnADS;
          end;
        // Очистить только один справочник
        sSQL := Format('DELETE FROM %s WHERE (TYPE=%s)', [ParsNsi.AdsNsi.TableName, CurNsiType]);
        Ret  := ParsNsi.ConnADS.Execute(sSQL);
        ParsNsi.AdsNsi.Active := True;

        if (ParsNsi.AdsNsi.Active = True) then begin
          MaxF := DSNsi.Fields.Count;
          with DSNsi do begin
            First;
            while not Eof do begin
              ParsNsi.AdsNsi.Append;
              for i := 0 to MaxF - 1 do begin

{$IFDEF DEMOAPP}
                v := Fields[i].Value;
                s := UpperCase(Fields[i].FieldName);
                if (s = 'LEX1') then begin
                  n := Length(string(v));
                  if (n > ParsNsi.MaxLex) then
                    ParsNsi.MaxLex := n;
                end;
{$ENDIF}
                ParsNsi.AdsNsi.Fields[i].Value := Fields[i].Value;
              end;
              ParsNsi.AdsNsi.Post;
              Next;
            end;
          end;
          Ret := 0;
          //ParsNsi.AdsNsi.CommitUpdates;
        end else
          raise Exception.Create('Не открылась таблица НСИ');
      end;

    except
      on E: Exception do begin
        if (sErr = '') then
          sErr := E.Message;
        if (Ret = 0) then
          Ret := UERR_CVRT_NSI;
      end;
    end;
  finally
    Result := Ret;
  end;
end;


// Полученный справочник - в ADS (Free Table)
function TNsi.CreateADSTFree(ParsNsi : TParsNsi; CurNsiType: string; DSNsi: TDataSet; var sErr : string) : Integer;
var
  Ret,
  i, MaxF : Integer;
  CurName, StrucInStr, TName, FName, sSQL: string;
  t: TAdsTable;
begin
  Ret    := 0;
  sErr   := '';
  FName := Iif(ParsNsi.AlterName = '', ParsNsi.AdsTName, ParsNsi.AlterName);
  if (ParsNsi.AllNsi = True) then
  // № НСИ надо включать в имя
    TName  := Format('%s%s', [FName, CurNsiType])
  else
    TName  := Format('%s', [FName]);

  t := TAdsTable.Create(ParsNsi.ConnADS.Owner);
  try
    try
      FName := ParsNsi.ConnADS.ConnectPath + TName;
      CurName := SafeNewNsi(ParsNsi.ConnADS.ConnectPath, TName);
      sSQL := ADSTCreateOnDefs(CurName, DSNsi.FieldDefs, StrucInStr);
      //ParsNsi.ConnADS.IsConnected := True;
      t.TableName := CurName;
      t.AdsConnection := ParsNsi.ConnADS;
      ParsNsi.ConnADS.Execute(sSQL);
      // Вариант без SQL
      //t.AdsCreateTable(FName, ttAdsADT, ANSI, 0, StrucInStr);
      t.Active := True;

      MaxF := DSNsi.Fields.Count;
      with DSNsi do begin
        First;
        while not Eof do begin
          t.Append;
          for i := 0 to MaxF - 1 do
            t.Fields[i].Value := Fields[i].Value;
          t.Post;
          Next;
        end;
      end;
      t.Active := False;
      ParsNsi.ConnADS.IsConnected := False;
      SafeNewNsi(ParsNsi.ConnADS.ConnectPath, TName, CurName);
    except
      on E: Exception do begin
        if (sErr = '') then
          sErr := E.Message;
        if (Ret = 0) then
          Ret := UERR_CVRT_NSI;
      end;
    end;
  finally
    ParsNsi.ADSNsi := t;
  end;
  Result := Ret;
end;

// Получить содержимое одного справочника
function TNsi.GetOneNSI(ParsNsi : TParsNsi; CurNsiType: string; URL : string; ROCNsi : TkbmMemTable; var sErr : string): Integer;
var
  LenSO,
  Ret: Integer;
  SOList: ISuperObject;
begin
  Ret  := 0;
  sErr := Format('Ошибка загрузки НСИ (%s)', [CurNsiType]);
  try
    try
      FShowProgress.ChangeSingleShow(0, 'Запрос данных...');
      Ret := SetRetCode(SecureGet(URL), sErr);
      if (Ret = 0) then begin
        FShowProgress.ChangeSingleShow(30, 'SO - создание');
        SOList := SO(Utf8Decode( MemStream2Str(FHTTP.Document) ));
        if Assigned(SOList) and (SOList.DataType = stArray) then begin
          LenSO := SOList.AsArray.Length;
          FShowProgress.ChangeShow(25, Format('%s - %d', [ParsNsi.ShowCapt, LenSO]));
          FLogger.Add2Log(Format('-----------------------------%s%s - получено %d элементов', [CRLF, ParsNsi.ShowCapt, LenSO]), False);
          if (TDocSetDTO.GetNSI(SOList, ROCNsi) > 0) then begin
            // Есть записи
            FShowProgress.ChangeSingleShow(90, 'JSON->ADS - конвертация');
            if (ParsNsi.ADSCopy = True)  then begin
              if (ParsNsi.DicMode = True)  then
                Ret := CreateADSTDic(ParsNsi, CurNsiType, ROCNsi, sErr)
              else
                Ret := CreateADSTFree(ParsNsi, CurNsiType, ROCNsi, sErr);
              FShowProgress.ChangeSingleShow(100);
              if (Ret <> 0) then
                raise Exception.Create(sErr);
            end;
            Ret  := 0;
            sErr := '';
          end
          else
            raise Exception.Create('Отсутствуют данные в НСИ');
        end
        else
          raise Exception.Create('Некорректные данные в НСИ');
      end;
    except
      on E: Exception do begin
        if (sErr = '') then
          sErr := E.Message;
        if (Ret = 0) then
          Ret := UERR_GET_NSI;
      end;
    end;
  finally
    Result := Ret;
  end;
end;

// ADS
function TNsi.VerifyConnect(ParsNsi: TParsNsi; CloseNow: Boolean = False): Boolean;
begin
  if (ParsNsi.ADSCopy = True) then begin
    if (CloseNow = True) then begin
      if (Assigned(ParsNsi.ADSNsi)) then
        ParsNsi.ADSNsi.Active := False;
      if Assigned(ParsNsi.ConnADS) AND (ParsNsi.ConnADS.Name = CONNADS_NAME) then
      // только если создавал сам
        ParsNsi.ConnADS.IsConnected := False;
      Result := True;
    end
    else begin
      try
        ParsNsi.ConnADS.Connect;
        Result := ParsNsi.ConnADS.IsConnected;
      except
        Result := False;
      end;
    end;
  end
  else
    Result := True;
end;

// Получить содержимое справочника (Easy)
function TNsi.GetROCNSI(NsiType: integer; Conn : TAdsConnection = nil; AdsTable : string = ''): TResultHTTP;
var
  ParsNsi: TParsNsi;
begin
  ParsNsi := TParsNsi.Create(NsiType, Meta, Conn, FOwn);
  ParsNsi.AlterName := AdsTable;
  ParsNsi.MaxLex := 0;
  try
    Result := GetROCNSI(ParsNsi);
  finally
    FreeAndNil(ParsNsi);
  end;
end;


// Получить содержимое справочника (Параметры готовы)
function TNsi.GetROCNSI(ParsNsi : TParsNsi): TResultHTTP;
var
  i, iMax, Ret: Integer;
  NsiID: TStringList;
  URL,
  s,
  sCode, sErr: string;
  WaitCursor : IUnknown;
begin
  ResHTTP.ClearRes(GET_NSI);
  Ret     := UERR_GET_NSI;
  sErr    := '';
  WaitCursor := TTmpCursor.ChangeToWait;

  FShowProgress.PrepareShow('Загрузка НСИ','');
  FShowProgress.PrepareSingleShow('');
  try
    try
      if (NOT VerifyConnect(ParsNsi)) then
        raise Exception.Create('Ошибка подключения к ADS-базе');

      if (ParsNsi.NsiType = NSIALL) then begin
        sCode := '';
        //NsiID := Split(',', ParsNsi.AllTypes);
        NsiID := ParsNsi.NsiDesc;
        iMax := NsiID.Count - 1;
        if (iMax < 0) then
          raise Exception.Create('Отсутствует список НСИ');
      end else begin
        NsiID := SetNsiAllList(IntToStr(ParsNsi.NsiType));
        iMax := 0;
      end;

      URL := ParsNsi.FullURL;
      if (URL = '') then
        if (ParsNsi.NsiCode = 0) then
          sCode := ''
        else
          sCode := IntToStr(ParsNsi.NsiCode);

      FShowProgress.AdjustShow(iMax);
      for i := 0 to iMax do begin
        s := NsiID.Values[NsiID.Names[i]];
        if (s = NsiID.Names[i]) then s := 'Справочник ' + NsiID.Names[i];
        ParsNsi.ShowCapt := s;
        if (URL = '') OR (i > 0) then
          URL := FullPath(FHost, GET_NSI, Format('/type/%s?code=%s&active=true&first&count', [NsiID.Names[i], sCode]), ParsNsi);
        FShowProgress.ChangeShow(i, s);
        Ret := GetOneNSI(ParsNsi, NsiID.Names[i], URL, ResHTTP.Nsi, sErr);
        FShowProgress.ChangeSingleShow(100);
        if (Ret <> 0) then begin
          if (ParsNsi.NsiType = NSIALL) then begin
          // Только для NSIALL
            sErr := sErr + Format('Ошибка (%d) загрузки НСИ (%s) - %s%s', [Ret, s, sErr, CRLF]);
          end else
            raise Exception.Create(sErr);
        end;
      end;
      // 100%
      FShowProgress.AdjustShow(-1, iMax);
      VerifyConnect(ParsNsi, True);
    except
      on E: Exception do begin
        if (sErr = '') then
          sErr := E.Message;
        if (Ret = 0) then
          Ret := UERR_GET_NSI;
      end;
    end;
  finally
    FShowProgress.CloseShow;
    if (ParsNsi.NsiType <> NSIALL) then
      FreeAndNil(NsiID);
    ResHTTP.ResCode := Ret;
    ResHTTP.ResMsg := sErr;
{$IFDEF DEMOAPP}
    ResHTTP.ResMsg := Format('%s MaxLen = %d', [sErr, ParsNsi.MaxLex]);
{$ENDIF}
    Result := ResHTTP;
  end;
end;




end.
