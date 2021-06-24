unit uRegIntX;

interface

{$I Task.inc}

uses
  Classes,
  DB,
  Variants,
  superobject,
  superdate,
  SasaIniFile,
  uROCService,
  mGisun,
  mRegInt,
  wsGisun,
  uGisun,
  uRestClient,
  uUNDTO;

const
//=== *** === === *** === === *** === === *** === =>
  UN_INI_NAME  = '..\GISUN\GISUN.ini';
  UN_IN_FILES  = '..\GISUN\GISUN_Input.ini';
  UN_OUT_FILES = '..\GISUN\GISUN_Output.ini';

  // Секции INI-файла
  SCT_REST = 'REST';



//=== *** === === *** === === *** === === *** === <=

  // Режимы обмена с регистром населения
  EM_DEFLT = 0;
  EM_SOAP  = 1;
  EM_JSON  = 2;
  EM_MIXED = 3;

  // Сообщения об ошибках
  ERR_NO_AUTH = 'Отказ от взаимодействия';


type
  TExchangeMode = (emDefault, emSOAP, emJSON, emMIXED);

   //Интерфейс для обмена с регистром населения
  TRegIntX = class(TRegInt)
  private
    FExchMode : Integer;
    FConfig   : TRestConfig;
    FIniIn,
    FIniOut,
    FIni : TSasaIniFile;
    FRestClient : TRestClient;

    function SetOutDS(const Act : TActKind; Resp : TRestResponse) : Integer;
  public
    property Config : TRestConfig read FConfig write FConfig;
    property ApiClient : TRestClient read FRestClient write FRestClient;

    // Получение персональных данных, ИН, резервирование ИН
    function Get(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument: TDataSet = nil;
    slPar: TStringList = nil; ExchMode: Integer = EM_DEFLT): TRestResponse;

    // версия для работы с REST-сервисами
    function GetRest(ActKind: TActKind; MessageType: string; const InDS, Dokument: TDataSet; var Output, Error: TDataSet; slPar:TStringList): TRestResponse;

    // Передача документов в регистр
    function Post(RequestMessageId: string; ActKind: TActKind; MessageType: string; const Input: TDataSet; var Error: TDataSet; ExchMode: Integer = EM_DEFLT): TRestResponse;
    function PostRest(RequestMessageId: string; ActKind: TActKind; MessageType: string; const InDS : TDataSet; var Error: TDataSet): TRestResponse;

    constructor Create(MessageSource: string; Ini : TSasaIniFile = nil);
    destructor Destroy;

  end;


implementation

uses
  SysUtils,
  kbmMemTable,
  FuncPr;


constructor TRegIntX.Create(MessageSource: string; Ini : TSasaIniFile = nil);
var
  IsOAIS : Boolean;
  SecMode : string;
  i : Integer;
  DefH : TStringList;
begin
  inherited Create(MessageSource);

  DefH := TStringList.Create;
  DefH.Add('Reg-auth-username:PASSPORT_USER');
  DefH.Add('Reg-auth-password:user_password');
  Config := TRestConfig.Create(DefH);
  Config.Secure.UseOAIS := False;
  FIni := Ini;
  FExchMode := EM_SOAP;
  if (Assigned(Ini)) then begin
    FExchMode := Ini.ReadInteger(SCT_REST, 'EXCHG_MODE', EM_SOAP);
    Config.BasePath := Ini.ReadString(SCT_REST, 'BASE_URI', '');
    SecMode := Ini.ReadString(SCT_REST, 'SECURE_MODE', SECURE_OAIS);
    Config.Secure.UseOAIS := Iif(SecMode = SECURE_OAIS, True, False);
  end;
  Config.Organ := MessageSource;
  ApiClient := TRestClient.Create;

  //FGetSrv := TGetSrvX.Create;
end;


destructor TRegIntX.Destroy;
begin
  FreeAndNil(FRestClient);
  FreeAndNil(FConfig);
  inherited;
end;


// Для GET-запросов заполнение выходных DataSet
function TRegIntX.SetOutDS(const Act: TActKind; Resp: TRestResponse): Integer;
var
  i, iMax, nErr: Integer;
  OnePD, SOArrPD: ISuperObject;
begin
  nErr := 0;
  try
    SOArrPD := Resp.RetSO.O['personal_data'];
    if (Assigned(SOArrPD) and (SOArrPD.IsType(stArray))) then begin

      iMax := SOArrPD.AsArray.Length - 1;
      for i := 0 to iMax do begin
        OnePD := SOArrPD.AsArray.O[i].O['data'];
        Resp.RetDS.Append;
        TPersData.SObj2DSMin(OnePD, Resp.RetDS);
        if (Act = akGetPersonIdentif) then begin
        // Должен вернуть запрошенный ИН по ФИО
          Resp.RetDS.FieldByName('IS_PERSON').AsBoolean := False;
        end
        else begin
        // Должен вернуть персональные данные
          Resp.RetDS.FieldByName('IS_PERSON').AsBoolean := True;
          TPersData.SObj2DSFull(OnePD, Resp.RetDS);

        end;
        Resp.RetDS.Post;
      end;
    end;

    SOArrPD := Resp.RetSO.O['identif_number'];
    if (Assigned(SOArrPD) and (SOArrPD.IsType(stArray))) then begin
      iMax := SOArrPD.AsArray.Length - 1;

      for i := 0 to iMax do begin
    // Должен вернуть зарезервированные новые ИН
        OnePD := SOArrPD.AsArray.O[i];
        Resp.RetDS.Append;
        Resp.RetDS.FieldByName('REQUEST_ID').AsString := OnePD.S['request_id'];
        Resp.RetDS.FieldByName('NEW_IDENTIF').AsString := OnePD.S['data'];
        Resp.RetDS.FieldByName('IS_PERSON').AsBoolean := False;
        Resp.RetDS.Post;
      end;

    end;

  except
    nErr := 1;
  end;

end;








// Получение из регистра
function TRegIntX.Get(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument: TDataSet = nil;
    slPar: TStringList = nil; ExchMode: Integer = EM_DEFLT): TRestResponse;
var
  nErr : Integer;
  ResObs : TRequestResult;
begin
  if (ExchMode = EM_DEFLT) then
    ExchMode := FExchMode;
  if (ExchMode = EM_SOAP) then begin
    ResObs := inherited Get(ActKind, MessageType, Input, Output, Error, Dokument, slPar);
    Result := TRestResponse.Create;
    Result.RetAsSOAP := ResObs;
  end
  else begin
    // Через REST-сервис
    Result := GetRest(ActKind, MessageType, Input, Dokument, Output, Error, slPar);
    if (Result.RetAsSOAP = rrOk) then begin
       Result.RetDS := CreateOutputTable(akGetPersonalData);
       nErr := SetOutDS(ActKind, Result);

    end;


  end;
end;

// Запись в регистр документов
function TRegIntX.Post(RequestMessageId: string; ActKind: TActKind; MessageType: string; const Input: TDataSet; var Error: TDataSet; ExchMode: Integer = EM_DEFLT): TRestResponse;
var
  ResObs : TRequestResult;
begin
  if (ExchMode = EM_DEFLT) then
    ExchMode := FExchMode;
  if (ExchMode = EM_SOAP) then begin
    ResObs := inherited Post(RequestMessageId, ActKind, MessageType, Input, Error);
    Result := TRestResponse.Create;
    Result.RetAsSOAP := ResObs;
  end
  else begin
    // Через REST-сервис
    Result := PostRest(RequestMessageId, ActKind, MessageType, Input, Error);
  end;
end;




// Получение персональных данных, ИН, резервирование ИН через REST-сервис
function TRegIntX.GetRest(ActKind: TActKind; MessageType: string; const InDS, Dokument: TDataSet; var Output, Error: TDataSet; slPar:TStringList): TRestResponse;
var
  i : Integer;
  s : string;
  Req : TRestRequest;

begin
  // Формирование запроса на сервер
  Req := TRestRequest.Create(Self.Config);
  Req.SetActInf(ActKind, MessageType, InDS, slPar);

  Req.MakeReqLine('POST', slPar);

  // Формирование тела запроса
  Req.MakeReqBody(InDS);

  Result := ApiClient.CallApi(Req);
end;

// Отправка данных через REST-сервис
function TRegIntX.PostRest(RequestMessageId: string; ActKind: TActKind; MessageType: string; const InDS : TDataSet; var Error: TDataSet): TRestResponse;
var
  i : Integer;
  s : string;
  Req : TRestRequest;
begin
  // Формирование запроса на сервер
  Req := TRestRequest.Create(Self.Config);
  Req.SetActInf(ActKind, MessageType, InDS);

  Req.MakeReqLine('POST');

  // Формирование тела запроса
  Req.MakeReqBody(InDS);

  Result := ApiClient.CallApi(Req);
end;




end.
