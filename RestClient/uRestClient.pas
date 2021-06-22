unit uRestClient;

interface

uses
  Classes,
  SysUtils,
  DB,
  {$IFDEF SYNA} httpsend,  {$ENDIF}
  superobject,
  FuncPr,
  mRegInt,
  uGisun,
  uROCService,
  uUNDTO
  ;

const
  SECURE_TODES = 'SEC_TODES';
  SECURE_OAIS  = 'SEC_OAIS';

type
  TSecure = class;

  // Настройки обращений к ресурсу, предоставляющему REST-сервисы
  TRestConfig = class
  private
    FBasePath : string;
    FDefHeader : TStringList;
    FOrgan     : string;
    FSec : TSecure;
  public
    property BasePath : string read FBasePath write FBasePath;
    // Заголовок по-умолчанию
    property DefHeader : TStringList read FDefHeader write FDefHeader;
    // Код сельсовета
    property Organ : string read FOrgan write FOrgan;
    property Secure : TSecure read FSec write FSec;

    constructor Create(DefH : TStringList = nil);
    destructor Destroy;
  end;

  // Параметры защищенного обмена
  TSecure = class
  private
  public
    UseOAIS : Boolean;
    User : string;
    Pass : string;


  end;

  // Соответствие типов документов методам и параметрам HTTP-запросов
  TActInf = class
  private
  public
    Act      : TActKind;
    Oper     : TOperation;
    ResPath  : string;
    MsgType  : string;
    MakeBody : TMakePostBoby;
    Method   : string;
  end;

  // Запрос к REST-серверу
  TRestRequest = class
  private
    FCfg    : TRestConfig;
    // Параметры каждого запроса
    FActInf   : TActInf;
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
    FRetMsg  : string;
    // объект response из ответа сервера
    FSupObj  : ISuperObject;
  public
    property RetAsSOAP : TRequestResult read FRetAsSOAP write FRetAsSOAP;
  end;

  // Клиент для вызова API (REST-Full)
  TRestClient = class
  private
    FHTTP   : THTTPSend;

    procedure SecReq(Req : TRestRequest; var URL : string; var Head : TStringList; var HTTPDoc : TStringStream);
    procedure SetRetData(const Meth, URL : string; Resp : TRestResponse);
  public
    function CallApi(Req : TRestRequest) : TRestResponse;

    constructor Create;
    destructor Destroy;
  end;



implementation

// Конфиг запроса к REST-серверу
constructor TRestConfig.Create(DefH : TStringList = nil);
begin
  inherited Create;
  DefHeader := DefH;
  Secure := TSecure.Create;
end;

//
destructor TRestConfig.Destroy;
begin
  FreeAndNil(FSec);
  inherited;
end;


// Создание запроса к REST-серверу
constructor TRestRequest.Create(Cfg : TRestConfig);
begin
  inherited Create;
  FCfg := Cfg;
  FHeader := TStringList.Create;
  if (Assigned(Cfg.DefHeader)) then
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

// Клиент для вызова API (REST-Full)
constructor TRestClient.Create;
var
  i : Integer;
begin
  inherited;
  FHTTP := THTTPSend.Create;
  FHTTP.Protocol := '1.1';
end;

// Клиент для вызова API (REST-Full)
destructor TRestClient.Destroy;
begin
  FreeAndNil(FHTTP);
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
    akBirth : begin
    // Свидетельство о рождении
      FActInf.ResPath  := 'zags/birth-certificate';
      FActInf.MsgType  := '0160';
      FActInf.MakeBody := TActBirth.BirthDS2Json;
      end;
    akAffiliation : begin
    // Свидетельство об установлении отцовства
      FActInf.ResPath  := 'zags/affiliation-certificate';
      FActInf.MsgType  := '0200';
      FActInf.MakeBody := TActAffil.AffilDS2Json;
      end;
    akMarriage : begin
    // Свидетельство о браке
      FActInf.ResPath  := 'zags/marriage-certificate';
      FActInf.MsgType  := '0300';
      FActInf.MakeBody := TActMarr.MarrDS2Json;
      end;
    akDecease : begin
    // Свидетельство о смерти
      FActInf.ResPath  := 'zags/decease-certificate';
      FActInf.MsgType  := '0400';
      FActInf.MakeBody := TActDecease.DeceaseDS2Json;
      end;
    akDivorce : begin
    // Свидетельство о расторжении брака
      FActInf.ResPath  := 'zags/divorce-certificate';
      FActInf.MsgType  := '0500';
      FActInf.MakeBody := TActDvrc.DvrcDS2Json;
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




procedure TRestClient.SecReq(Req : TRestRequest; var URL : string; var Head : TStringList; var HTTPDoc : TStringStream);
var
  sUTF : UTF8String;
begin
  URL := Req.FFullURL;
  Head := TStringList.Create;
  Head.AddStrings(Req.FHeader);
  sUTF := AnsiToUtf8(Req.Body);

  if (Req.FCfg.Secure.UseOAIS = True) then begin


  end else begin

  end;
  HTTPDoc := TStringStream.Create(sUTF);

end;


// Установка кодов возврата после HTTPSend
procedure TRestClient.SetRetData(const Meth, URL: string; Resp: TRestResponse);
var
  IsGet, Ret: Boolean;
  nErr: Integer;
  sErr: string;
  ErrList, SOErr: ISuperObject;
  StreamDoc: TStringStream;
begin
  sErr := '';
  IsGet := Iif(Resp.FRestReq.FActInf.Oper = opGet, True, False);

  Ret := FHTTP.HTTPMethod(Meth, URL);
  FHTTP.Document.SaveToFile('BodyUNResp');
  try
    if (Ret = True) then begin
      nErr := FHTTP.ResultCode;
      if (IsGet) then begin
      // если все хорошо, должен прийти 200
        if (FHTTP.ResultCode = 200) then
          nErr := 0;

      end
      else begin
      // если все хорошо, должен прийти 201
        if (FHTTP.ResultCode = 201) then
          nErr := 0;

      end;

    // JSON-ответ должен быть всегда

      if (nErr = 0) then begin
          // пока все хорошо
        StreamDoc := TStringStream.Create('');
        try
          StreamDoc.Seek(0, soBeginning);
          StreamDoc.CopyFrom(FHTTP.Document, 0);
          if (IsJSON(StreamDoc.DataString) = True) then begin
            SOErr := SO(Utf8Decode(StreamDoc.DataString));
            if (IsGet) then begin
              Resp.FSupObj := SOErr.O['response'];

            end
            else begin
              // Даже для 201 возможны ошибочные данные
              ErrList := SOErr.O['error_list'];
              if (Assigned(ErrList) and (Not ErrList.IsType(stNull))) then begin
                nErr := 300;


              end;

            end;

          end
          else begin
          // скорее всего, XML свалился вместо JSON
            sErr := FHTTP.ResultString;
            raise Exception.Create(sErr);
          end;
        finally
          StreamDoc.Free;
        end;
      end
      else begin
        // HTTP-error, Что-то не так с данными из запроса

      end;

    Resp.FRetAsSOAP := rrOk;

    end
    else begin
      // Какая-то сетевая проблема
      nErr := FHTTP.sock.LastError;
      sErr := FHTTP.sock.LastErrorDesc;
      raise Exception.Create(sErr);
    end;
  except
    on E: Exception do begin
      if (sErr <> '') then
        sErr := E.Message;
    end;
  end;
    Resp.FRetCode   := nErr;
    Resp.FRetMsg    := sErr;
    Resp.FRetData   := FHTTP.Document;
end;

function TRestClient.CallApi(Req : TRestRequest) : TRestResponse;
var
  Ret : Boolean;
  sURL : string;
  sUTF : UTF8String;
  SecHead : TStringList;
  DocStream : TStringStream;
begin
  Result := TRestResponse.Create;
  FHTTP.Clear;
  FHTTP.MimeType := 'application/json;charset=UTF-8';

  SecReq(Req, sURL, SecHead, DocStream);
  FHTTP.Headers.AddStrings(SecHead);
  FHTTP.Document.LoadFromStream(DocStream);

  FHTTP.Document.SaveToFile('BodyUN');

  Result.FRestReq := Req;
  SetRetData('POST', sURL, Result);
end;



end.
