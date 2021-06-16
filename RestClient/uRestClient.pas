unit uRestClient;

interface

uses
  Classes,
  SysUtils,
  DB,
  {$IFDEF SYNA} httpsend,  {$ENDIF}
  FuncPr,
  mRegInt,
  uGisun,
  uROCService,
  uUNDTO
  ;

type
  TRestConfig = class;

  // Соответствие типов документов методам и параметрам HTTP-запросов
  TActInf = class
  private
  public
    Act      : TActKind;
    Oper     : TOperation;
    ResPath  : string;
    MsgType  : string;
    //ActFun   : TActPostBoby;
    MakeBody : TMakePostBoby;
    Method   : string;
  end;

  // Запрос к REST-серверу
  TRestRequest = class
  private
    FCfg    : TRestConfig;
    FMethod : string;
    FFullURL : string;
    // Summary:
    //     The Resource URL to make the request against. Tokens are substituted with UrlSegment parameters and match by name.
    //     Should not include the scheme or domain. Do not include leading slash. Combined with RestClient.BaseUrl to assemble final URL:
    //     {BaseUrl}/{Resource} (BaseUrl is scheme + domain, e.g. http://example.com)
    FResource : string;
    FParams : TStringList;
    FHeader : TStringList;
    FBody   : string;
    // Summary:
    //     Timeout in milliseconds to be used for the request. This timeout value overrides
    //     a timeout set on the RestClient.
    FTimeout : Integer;
    // Summary:
    //     The number of milliseconds before the writing or reading times out. This timeout
    //     value overrides a timeout set on the RestClient.
    FReadWriteTimeout : Integer;
    // Summary:
    //     How many attempts were made to send this Request?
    // Remarks:
    //     This number is incremented each time the RestClient sends the request.
    FAttempts : integer;
    FActInf   : TActInf;
    FPersDataDTO : TPersDataDTO;

    function MakeAgreement : string;
    function MakeCover(const MsgSrcCode : string; MsgTypeCode : string = uGisun.QUERY_INFO; DSet : string = '[15]') : string;
    function MakeReqInBody(const InDS: TDataSet): string;
    function MakeBody4Post(const InDS: TDataSet) : string;
  public
    property Params : TStringList read FParams write FParams;
    property Header : TStringList read FHeader write FHeader;
    property Body : string read FBody write FBody;

    function SetActInf(ActKind: TActKind; MessageType: string; const Input : TDataSet; slPar : TStringList = nil): TRestRequest;
    function MakeReqLine(Meth : string; Pars : TStringList = nil) : string;
    // Подготовка тела запроса
    function MakeBody(const InDS : TDataSet; slPar:TStringList = nil): TRestRequest;

    constructor Create(Cfg : TRestConfig);
    destructor Destroy;
  end;

  // Ответ REST-сервера
  TRestResponse = class
  private
    FRestReq : TRestRequest;
    FRetAsSOAP : TRequestResult;
    FRetData : TMemoryStream;
    FRetCode : Integer;
  public
    property RetAsSOAP : TRequestResult read FRetAsSOAP write FRetAsSOAP;
  end;

  // Клиент для вызова API (REST-Full)
  TRestClient = class
  private
    FHTTP   : THTTPSend;

  public
    function CallApi(Req : TRestRequest) : TRestResponse;

    constructor Create;
    destructor Destroy;
  end;

  // Настройки обращений к ресурсу, предоставляющему REST-сервисы
  TRestConfig = class
  private
    FBasePath : string;
    FDefHeader : TStringList;
    FOrgan     : string;
  public
    property BasePath : string read FBasePath write FBasePath;
    property DefHeader : TStringList read FDefHeader write FDefHeader;
    property Organ : string read FOrgan write FOrgan;

    constructor Create(DefH : TStringList = nil);
    destructor Destroy;
  end;


implementation





// Конфиг запроса к REST-серверу
constructor TRestConfig.Create(DefH : TStringList = nil);
begin
  inherited Create;
  if (Assigned(DefH)) then
    DefHeader := DefH
  else
    DefHeader := TStringList.Create;
end;

//
destructor TRestConfig.Destroy;
begin
  FreeAndNil(FDefHeader);
  inherited;
end;


// Создание запроса к REST-серверу
constructor TRestRequest.Create(Cfg : TRestConfig);
begin
  inherited Create;
  FCfg := Cfg;
  FHeader := TStringList.Create;
  FHeader.AddStrings(Cfg.DefHeader);
  FActInf := TActInf.Create;
  FPersDataDTO := TPersDataDTO.Create;
  FAttempts := 0;
end;

// Запрос к REST-серверу
destructor TRestRequest.Destroy;
begin
  FreeAndNil(FActInf);
  FreeAndNil(FPersDataDTO);
  FreeAndNil(FHeader);
  inherited;
end;


// Заполнение дполнительных полей в зависимости от типа документа
function TRestRequest.SetActInf(ActKind: TActKind; MessageType: string; const Input : TDataSet; slPar : TStringList = nil): TRestRequest;
var
  s: string;
begin
  FActInf.Act := ActKind;
  FActInf.MsgType :=  MessageType;
  if (ActKind = akGetPersonalData) OR (ActKind = akGetPersonIdentif) then begin
    FActInf.Oper := opGet;
  end
  else begin
    FActInf.Oper := opPost;

  end;
  case ActKind of
    akGetPersonalData : begin
      FActInf.ResPath := 'common/register';
      end;
    akGetPersonIdentif:
      FActInf.ResPath := 'common/person-identif';
    akMarriage : begin
      FActInf.ResPath := 'zags/marriage-certificate';

      //FActInf.ActFun := Marr2Json;
      FActInf.MakeBody := TActMarr.MarrDS2Json;
      end;
  end;
  Result := Self;
end;



// Формирование строки запроса (ReqLine) к REST-серверу
function TRestRequest.MakeReqLine(Meth : string; Pars : TStringList = nil) : string;
var
  s : string;
begin
  FFullURL := FCfg.BasePath + FActInf.ResPath;
  Result := s;
end;


function TRestRequest.MakeAgreement : string;
var
  OperInf,
  Targ,
  Rights,
  IssDate,
  ExpDate,
  AssgnPers,
  Insp, LeadInsp,
  s: string;
begin
  try
    OperInf  := 'Организация адрес';
    Targ     := 'верификация персональных данных';
    Rights   := '201,703,208,480,481,482,490,491,527,528,252,465,466,516,517';
    IssDate  := '2021-06-07T13:22:09.619+03:00';
    ExpDate  := '2023-06-07T13:22:09.619+03:00';
    Insp     := '"инспектор Иванов"';
    LeadInsp := ',"начальник инспектора Петров"';

    AssgnPers := Format('"assignee_persons":[%s%s]', [Insp, LeadInsp]);

    Result := Format('"agreement":{"operator_info":"%s","target":"%s","rights":[%s],"issue_date":"%s","expiry_date": "%s",%s}',
      [OperInf, Targ, Rights, IssDate, ExpDate, AssgnPers]);
  except
  end;

end;


function TRestRequest.MakeCover(const MsgSrcCode : string; MsgTypeCode : string = QUERY_INFO; DSet : string = '[15]') : string;
var
  MsgT,
  Agree,
  MsgId : string;
begin
  Result := '';
  try
    MsgId := NewGUID;
    MsgT  := FormatDateTime('yyyy-MM-dd"T"HH:mm:ss.SSS', Now);
    //MsgT  := DateTimeToStr(Now);
    if (FActInf.Oper = opGet) then begin
      Agree := Format(',%s,"dataset":%s}', [MakeAgreement, DSet]);
    end else begin
      Agree := '';
    end;
    //Result := Format('"cover":{"message_id":"%s","message_type":{"code":"%s","type":-2},"message_source":{"code":"%s","type":80},%s,"dataset":%s}', [MsgId, MsgTypeCode, MsgSrcCode, MakeAgreement, DSet]);
    Result := Format('"cover":{"message_id":"%s","message_type":{"code":"%s","type":-2},"message_time":"%s","message_source":{"code":"%s","type":80}%s}', [MsgId, MsgTypeCode, MsgT, MsgSrcCode, Agree]);
  except
  end;
end;


function TRestRequest.MakeBody4Post(const InDS: TDataSet) : string;
begin
  Result := '';
  try
    Result := FActInf.MakeBody(InDS);
  except
  end;
end;


function TRestRequest.MakeReqInBody(const InDS: TDataSet): string;
var
  iIN, iPD: Integer;
  MsgTypeCode, MsgSrcCode, DSet, sPersDat, sIN, sR, s: string;
begin
  s := '';
  try
    if (FActInf.Oper = opGet) then begin
      s := '"request":{';
      sPersDat := '';
      sIN := '';

      with InDS do begin
        First;
        if (FActInf.Act = akGetPersonIdentif) then begin
        //Запрос на получение ИН (по ф.и.о.)
          sR := Format('"surname":"%s","name":"%s","sname":"%s","bdate":"%s"', [FieldByName('FAMILIA').AsString, FieldByName('NAME').AsString, FieldByName('OTCH').AsString, FieldByName('DATER').AsString]);
          Last;
        end
        else begin

          iPD := 0;
          iIN := 0;
          while not Eof do begin
            if (FieldByName('IS_PERSON').AsBoolean = True) then begin
            // Запрос персональных данных
              iPD := iPD + 1;
              if (iPD > 1) then
                sPersDat := sPersDat + ',';
              sPersDat := sPersDat + Format('{"request_id":"%s","identif_number":"%s"}', [FieldByName('REQUEST_ID').AsString, FieldByName('IDENTIF').AsString])
            end
            else begin
            // Запрос ИН
              iIN := iIN + 1;
              if (iIN > 1) then
                sIN := sIN + ',';
              sIN := sIN + Format('{"request_id":"%s","sex":{"code":"%s","type":32},"birth_day":"%s"}', [FieldByName('REQUEST_ID').AsString, FieldByName('POL').AsString, FieldByName('DATER').AsString])
            end;
            Next;
          end;

          if (iPD > 0) then
            sR := '"person_request":[' + sPersDat + ']';
          if (iIN > 0) then begin
            if (Length(sR) > 0) then
              sR := sR + ',';
            sR := sR + '"identif_request":[' + sIN + ']';
          end;

        end;
        s := s + sR + '}';
      end;
    end
    else
      s := MakeBody4Post(InDS);

  except
  end;
  Result := s;
end;

// Сформировать тело запроса
function TRestRequest.MakeBody(const InDS : TDataSet; slPar:TStringList = nil): TRestRequest;
var
  s: string;
begin
  try
(*
    Body   := '{' +
      MakeCover(FCfg.Organ, FActInf.MsgType) + ',' +
      MakeReqInBody(InDS) + '}';
*)
    Body := '{' +
      MakeCover(FCfg.Organ, FActInf.MsgType) + ',';
    s := MakeReqInBody(InDS) + '}';
    Body := Body + s;

    Result := Self;
  except
  end;
end;



// Клиент для вызова API (REST-Full)
constructor TRestClient.Create;
var
  i : Integer;
begin
  inherited;
  FHTTP := THTTPSend.Create;
end;

// Клиент для вызова API (REST-Full)
destructor TRestClient.Destroy;
begin
  FreeAndNil(FHTTP);
  inherited;
end;








function TRestClient.CallApi(Req : TRestRequest) : TRestResponse;
var
  Ret : Boolean;
  sUTF : UTF8String;
  DocStream : TStringStream;
begin
  Result := TRestResponse.Create;
  FHTTP.Clear;
  FHTTP.Headers.AddStrings(Req.FHeader);
  FHTTP.MimeType := 'application/json;charset=UTF-8';

  sUTF := AnsiToUtf8(Req.Body);
  DocStream := TStringStream.Create(sUTF);
  MemoWrite('BodyUN', sUTF);

  FHTTP.Document.LoadFromStream(DocStream);
  Ret := FHTTP.HTTPMethod('POST', Req.FFullURL);
  if (Ret = True) then begin
    Result.FRetAsSOAP := rrOk;
    Result.FRetCode   := 0;
    Result.FRetAsSOAP := rrOk;
    Result.FRetData   := FHTTP.Document;
    FHTTP.Document.SaveToFile('BodyUNResp');
  end;
end;



end.
