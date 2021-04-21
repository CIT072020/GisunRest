unit HttpConnectionSyna;

interface

{$I DelphiRest.inc}

uses
  SysUtils,
  Classes,
  httpsend,
  HttpConnection,
  RestUtils,
  RestException;

type
  TRestRequest = class
    Source : TStream;
    AcceptLanguage : string;
    Accept : string;
  end;

  TRestResponse = class
    Source : TStream;
    AcceptLanguage : string;
    Accept : string;
  end;

  // Метод для повторного вызова при обработке исключений
  THTTPMeth = procedure(AUrl: string; AContent: TStream; AResponse: TStream) of Object;
  // Метод для повторного вызова при обработке исключений
  THTTPMethGet = procedure(AUrl: string; AResponse: TStream) of Object;

  TSynaHTTP = class(THTTPSend)
  public
    ProxyAuth : Boolean;
    ReadTimeout : Integer;

    //procedure Delete(AURL: string);
    //procedure Patch(AURL: string; ASource, AResponseContent: TStream);
  end;

  THttpConnectionSyna = class(TInterfacedObject, IHttpConnection)
  private
    FSynaHttp: TSynaHTTP;
    FEnabledCompression: Boolean;
    FVerifyCert: boolean;
    FRequest : TRestRequest;
    FResponse : TRestResponse;

    procedure CancelRequest;
    ///
    ///  Delphi 2007
    ///
    {$IFNDEF DELPHI_10TOKYO_UP}
    //function IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate: TIdX509; AOk: Boolean): Boolean;overload;
    ///
    ///  Delphi 2010 and XE
    ///
    //function IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate: TIdX509; AOk: Boolean; ADepth: Integer): Boolean;overload;
    {$ENDIF}
    ///
    ///  Delphi XE2 and newer
    ///
    //function IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate: TIdX509; AOk: Boolean; ADepth, AError: Integer): Boolean;overload;

    //===***===
    function GenExceptHandl(AUrl: string; AContent, AResponse: TStream; E : Exception; ReCallMeth : THTTPMeth; ReCallMethG : THTTPMethGet = nil) : Boolean;

  public
    OnConnectionLost: THTTPConnectionLostEvent;

    property Request : TRestRequest read FRequest write FRequest;
    property Response : TRestResponse read FResponse write FResponse;

    constructor Create;
    destructor Destroy; override;

    function SetAcceptTypes(AAcceptTypes: string): IHttpConnection;
    function SetAcceptedLanguages(AAcceptedLanguages: string): IHttpConnection;
    function SetContentTypes(AContentTypes: string): IHttpConnection;
    function SetHeaders(AHeaders: TStrings): IHttpConnection;

    procedure Get(AUrl: string; AResponse: TStream);
    procedure Post(AUrl: string; AContent: TStream; AResponse: TStream);
    procedure Put(AUrl: string; AContent: TStream; AResponse: TStream);
    procedure Patch(AUrl: string; AContent: TStream; AResponse: TStream);
    procedure Delete(AUrl: string; AContent: TStream; AResponse: TStream);

    function GetResponseCode: Integer;
    function GetResponseHeader(const Header: string): string;

    function GetEnabledCompression: Boolean;
    procedure SetEnabledCompression(const Value: Boolean);

    procedure SetVerifyCert(const Value: boolean);
    function GetVerifyCert: boolean;

    function SetAsync(const Value: Boolean): IHttpConnection;
    function GetOnConnectionLost: THTTPConnectionLostEvent;
    procedure SetOnConnectionLost(AConnectionLostEvent: THTTPConnectionLostEvent);

    function ConfigureTimeout(const ATimeOut: TTimeOut): IHttpConnection;
    function ConfigureProxyCredentials(AProxyCredentials: TProxyCredentials): IHttpConnection;
    function SetOnAsyncRequestProcess(const Value: TAsyncRequestProcessEvent): IHttpConnection;
  end;


implementation

uses
  ProxyUtils;

{ THttpConnectionSyna }

constructor THttpConnectionSyna.Create;
var
  //ssl: TIdSSLIOHandlerSocketOpenSSL;
  ProxyServerIP: string;
begin
  FSynaHttp := TSynaHTTP.Create;
  FRequest  := TRestRequest.Create;
  FResponse := TRestResponse.Create;

  //ssl := TIdSSLIOHandlerSocketOpenSSL.Create(FSynaHttp);
  //ssl.OnVerifyPeer := IdSSLIOHandlerSocketOpenSSL1VerifyPeer;

  {$if defined(DELPHI_7) or defined(DELPHI_2007) or
       defined(DELPHI_2009) or defined(DELPHI_2010)}
    //ssl.SSLOptions.Method := sslvTLSv1;
  {$ifend}

  {$if defined(DELPHI_XE) or defined(DELPHI_XE2)}
    //ssl.SSLOptions.SSLVersions := [sslvTLSv1];
  {$ifend}

  {$IFDEF DELPHI_XE3_UP}
    //ssl.SSLOptions.SSLVersions := [sslvTLSv1,sslvTLSv1_1,sslvTLSv1_2];
  {$ENDIF}

  //FSynaHttp.IOHandler := ssl;
  //FSynaHttp.HandleRedirects := True;
  //FSynaHttp.Request.CustomHeaders.FoldLines := false;

  if ProxyActive then begin
    ProxyServerIP := GetProxyServerIP;
    if ProxyServerIP <> '' then begin
      FSynaHttp.ProxyHost := ProxyServerIP;
      FSynaHttp.ProxyPort := IntToStr(GetProxyServerPort);
    end;
  end;
end;


destructor THttpConnectionSyna.Destroy;
begin
  FreeAndNil(FResponse);
  FreeAndNil(FRequest);
  FreeAndNil(FSynaHttp);
  //FSynaHttp.Free;
  inherited;
end;


procedure THttpConnectionSyna.CancelRequest;
begin
  FSynaHttp.Abort;
end;


function THttpConnectionSyna.ConfigureProxyCredentials(
  AProxyCredentials: TProxyCredentials): IHttpConnection;
begin
  if Assigned(AProxyCredentials) then
    if AProxyCredentials.Informed and ProxyActive then begin
      FSynaHttp.ProxyAuth := True;
      FSynaHttp.ProxyUser := AProxyCredentials.UserName;
      FSynaHttp.ProxyPass := AProxyCredentials.Password;
    end;
  Result := Self;
end;


function THttpConnectionSyna.ConfigureTimeout(const ATimeOut: TTimeOut): IHttpConnection;
begin
  FSynaHttp.Timeout     := ATimeOut.ConnectTimeout;
  FSynaHttp.ReadTimeout := ATimeOut.ReceiveTimeout;
  Result := Self;
end;

// Типичная обработка исключений при выполнении запроса к серверу
function THttpConnectionSyna.GenExceptHandl(AUrl: string; AContent, AResponse: TStream; E : Exception; ReCallMeth : THTTPMeth; ReCallMethG : THTTPMethGet = nil) : Boolean;
var
  NeedRaise : Boolean;
  RetryMode: THTTPRetryMode;
  Temp: TStringStream;
begin
  NeedRaise := False;
  if (FSynaHttp.Sock.LastError <> 0) then begin
    FSynaHttp.Abort;
    RetryMode := hrmRaise;
    if (Assigned(OnConnectionLost)) then
      OnConnectionLost(E, RetryMode);
    if (RetryMode = hrmRaise) then
      NeedRaise := True
    else if (RetryMode = hrmRetry) then
      if (Assigned(ReCallMeth)) then
        ReCallMeth(AUrl, AContent, AResponse)
      else
        ReCallMethG(AUrl, AResponse);
  end
  else begin
    if Length(E.Message) > 0 then begin
      Temp := TStringStream.Create(E.Message);
      AResponse.CopyFrom(Temp, 0);
      Temp.Free;
    end;
  end;
  Result := NeedRaise;
end;


procedure THttpConnectionSyna.Get(AUrl: string; AResponse: TStream);
begin
  try
    //FSynaHttp.Get(AUrl, AResponse);
    FSynaHttp.HTTPMethod('GET', AUrl);
  except
    on E : Exception do
      if GenExceptHandl(AUrl, nil, AResponse, E, nil, Get) then
        raise;
  end;
end;


procedure THttpConnectionSyna.Post(AUrl: string; AContent, AResponse: TStream);
begin
  try
    //FSynaHttp.Post(AUrl, AContent, AResponse);
    FSynaHttp.Document.CopyFrom(AContent, 0);
    FSynaHttp.HTTPMethod('POST', AUrl);
  except
    on E: Exception do
      if GenExceptHandl(AUrl, AContent, AResponse, E, Post) then
        raise;
  end;
end;


procedure THttpConnectionSyna.Patch(AUrl: string; AContent, AResponse: TStream);
begin
  try
    //FSynaHttp.Patch(AUrl, AContent, AResponse);
    FSynaHttp.HTTPMethod('PATCH', AUrl);
  except
    on E: Exception do
      if GenExceptHandl(AUrl, AContent, AResponse, E, Patch) then
        raise;
  end;
end;


procedure THttpConnectionSyna.Put(AUrl: string; AContent, AResponse: TStream);
begin
  try
    //FSynaHttp.Put(AUrl, AContent, AResponse);
    FSynaHttp.HTTPMethod('PUT', AUrl);
  except
    on E: Exception do
      if GenExceptHandl(AUrl, AContent, AResponse, E, Put) then
        raise;
  end;
end;


procedure THttpConnectionSyna.Delete(AUrl: string; AContent, AResponse: TStream);
begin
  try
    //FSynaHttp.Clear;
    FSynaHttp.Document.CopyFrom(AContent, 0);
    FSynaHttp.HTTPMethod('DELETE', AUrl);
  except
    //on E: EIdHTTPProtocolException do
    on E : Exception do
      if GenExceptHandl(AUrl, AContent, AResponse, E, Delete) then
        raise;
  end;
end;

function THttpConnectionSyna.GetEnabledCompression: Boolean;
begin
  Result := FEnabledCompression;
end;

function THttpConnectionSyna.GetOnConnectionLost: THTTPConnectionLostEvent;
begin
  result := OnConnectionLost;
end;

function THttpConnectionSyna.GetResponseCode: Integer;
begin
  Result := FSynaHttp.FResultCode;
end;

function THttpConnectionSyna.GetResponseHeader(const Header: string): string;
begin
  raise ENotSupportedException.Create('');
end;

function THttpConnectionSyna.GetVerifyCert: boolean;
begin
  result := FVerifyCert;
end;

{$IFNDEF DELPHI_10TOKYO_UP}
{
function THttpConnectionSyna.IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate: TIdX509; AOk: Boolean): Boolean;
begin
  Result := IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate, AOk, -1);
end;

function THttpConnectionSyna.IdSSLIOHandlerSocketOpenSSL1VerifyPeer(
  Certificate: TIdX509; AOk: Boolean; ADepth: Integer): Boolean;
begin
  Result := IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate, AOk, ADepth, -1);
end;
}
{$ENDIF}

{
function THttpConnectionSyna.IdSSLIOHandlerSocketOpenSSL1VerifyPeer(
  Certificate: TIdX509; AOk: Boolean; ADepth, AError: Integer): Boolean;
begin
  result := AOk;
  if not FVerifyCert then
  begin
    result := True;
  end;
end;
}


function THttpConnectionSyna.SetAcceptedLanguages(AAcceptedLanguages: string): IHttpConnection;
begin
  Request.AcceptLanguage := AAcceptedLanguages;
  Result := Self;
end;

function THttpConnectionSyna.SetAcceptTypes(AAcceptTypes: string): IHttpConnection;
begin
  Request.Accept := AAcceptTypes;
  Result := Self;
end;

function THttpConnectionSyna.SetAsync(const Value: Boolean): IHttpConnection;
begin
  if Value then
    raise ENotImplemented.Create('Async requests not implemented for Indy.');

  Result := Self;
end;

function THttpConnectionSyna.SetContentTypes(AContentTypes: string): IHttpConnection;
begin
  FSynaHttp.MimeType := AContentTypes;
  Result := Self;
end;

procedure THttpConnectionSyna.SetEnabledCompression(const Value: Boolean);
begin
  if (FEnabledCompression <> Value) then
  begin
    FEnabledCompression := Value;

    if FEnabledCompression then
    begin
      {$IFDEF DELPHI_XE2}
        {$Message Warn 'TIdCompressorZLib does not work properly in Delphi XE2. Access violation occurs.'}
      {$ENDIF}
      //FSynaHttp.Compressor := TIdCompressorZLib.Create(FSynaHttp);
    end
    else
    begin
      //FSynaHttp.Compressor.Free;
      //FSynaHttp.Compressor := nil;
    end;
  end;
end;

function THttpConnectionSyna.SetHeaders(AHeaders: TStrings): IHttpConnection;
var
  i: Integer;
begin
  //FSynaHttp.Request.Authentication.Free;
  //FSynaHttp.Request.Authentication := nil;
  FSynaHttp.Headers.Clear;

  for i := 0 to AHeaders.Count-1 do
  begin
    //FSynaHttp.Request.CustomHeaders.AddValue(AHeaders.Names[i], AHeaders.ValueFromIndex[i]);
    FSynaHttp.Headers.AddObject(AHeaders.Names[i], TObject(AHeaders.ValueFromIndex[i]));
  end;

  Result := Self;
end;

function THttpConnectionSyna.SetOnAsyncRequestProcess(const Value: TAsyncRequestProcessEvent): IHttpConnection;
begin
  Result := Self;
end;

procedure THttpConnectionSyna.SetOnConnectionLost(
  AConnectionLostEvent: THTTPConnectionLostEvent);
begin
  OnConnectionLost := AConnectionLostEvent;
end;

procedure THttpConnectionSyna.SetVerifyCert(const Value: boolean);
begin
  FVerifyCert := Value;
end;

{ TSynaHTTP }
{
procedure TSynaHTTP.Delete(AURL: string);
begin
  try
    DoRequest(Id_HTTPMethodDelete, AURL, Request.Source, nil, []);
  except
    on E: EIdHTTPProtocolException do
      raise EHTTPError.Create(e.Message, e.ErrorMessage, e.ErrorCode);
  end;
end;

procedure TSynaHTTP.Patch(AURL: string; ASource, AResponseContent: TStream);
begin
  DoRequest('PATCH', AURL, ASource, AResponseContent, []);
end;
}

end.

