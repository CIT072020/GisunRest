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
  UN_IN_FILES  = '..\GISUN\GISUN_InputJ.ini';
  UN_OUT_FILES = '..\GISUN\GISUN_OutputJ.ini';

  // Секции INI-файла
  SCT_REST = 'REST';



//=== *** === === *** === === *** === === *** === <=

  // Режимы обмена с регистром населения
  EM_DEFLT = 0;
  EM_SOAP  = 1;
  EM_JSON  = 2;
  EM_MIXED = 3;

  // Используемые НСИ
  NSI_SSOVET = 80;

  // Имена в списке параметров вызова GET
  PGET_FAM_ALL   = 'family';
  PGET_FAM_CHILD = 'child';
  PGET_FAM_MTHR  = 'mather';
  PGET_FAM_FTHR  = 'father';
  PGET_FAM_WIFE  = 'wife';
  PGET_FAM_HSBD  = 'husband';

  PGET_SUD = 'RESH_SUD';
  PGET_FRM = 'FORM';

  // Сообщения об ошибках
  ERR_NO_AUTH = 'Отказ от взаимодействия';


type
  TExchangeMode = (emDefault, emSOAP, emJSON, emMIXED);

  TObrPersonalDataSO = procedure(data : ISuperObject; dsOutPut:TDataSet; dsDokument:TDataSet; slPar:TStringList) of object;

   //Интерфейс для обмена с регистром населения
  TRegIntX = class(TRegInt)
  private
    FExchMode : Integer;
    FConfig   : TRestConfig;
    FIniIn,
    FIniOut,
    FIni : TSasaIniFile;
    FRestClient : TRestClient;

    function AddCourts(PersData: ISuperObject; slPar: TStringList; const ReqID : string): integer;
    function SetErrData(const Act: TActKind; Resp: TRestResponse) : Integer;
    function SetOutDS(const Act: TActKind; slPar : TStringList; Resp: TRestResponse): Integer;
    function GetResponse : TRestResponse;
    function AddMartInfo(MartInfo: ISuperObject; const ReqID : string): integer;
    function AddFamily(PersData: ISuperObject; slPar : TStringList; const ReqID, Pfx : string): integer;
    function LocateID(IDS : TDataSet; const RequestID: string): Boolean;
  public
    property Config : TRestConfig read FConfig write FConfig;
    property ApiClient : TRestClient read FRestClient write FRestClient;
    property Response : TRestResponse read GetResponse;

    // Получение персональных данных, ИН, резервирование ИН
    function Get(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument: TDataSet = nil;
    slPar: TStringList = nil; ExchMode: Integer = EM_DEFLT): TRequestResult;

    // версия для работы с REST-сервисами
    function GetRest(ActKind: TActKind; MessageType: string; const InDS, Dokument: TDataSet; var Output, Error: TDataSet; slPar:TStringList): TRestResponse;

    // Передача документов в регистр
    function Post(RequestMessageId: string; ActKind: TActKind; MessageType: string; const Input: TDataSet; var Error: TDataSet; ExchMode: Integer = EM_DEFLT): TRequestResult;
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

// Получить последний ответ от сервера
function TRegIntX.GetResponse : TRestResponse;
begin
  Result := FRestClient.Response;
end;

// Заполненеие DataSet в случае ошибок
function TRegIntX.SetErrData(const Act: TActKind; Resp: TRestResponse): Integer;
var
  ErrsInSO: Integer;
begin
  ErrsInSO := 0;
  if (Resp.RetAsSOAP = rrOk) then begin
    Resp.ErrDS := nil;
  end
  else begin
    Resp.ErrDS := CreateErrorTable;
    if (Resp.RetAsSOAP = rrBeforeError) then begin
      AddOneErr(Resp.ErrDS, IntToStr(Resp.RetCode), Resp.RetMsg);
    end
    else begin
      // объекта со списком ошибок не оказалось
      ErrsInSO := TPersData.SObj2DSErr(Resp.RetSO, Resp.ErrDS);
      if (ErrsInSO <= 0) then
        AddOneErr(Resp.ErrDS, IntToStr(Resp.RetCode), Resp.RetMsg);
    end;

  end;
  Result := ErrsInSO;
end;


// Заполнить DataSet информацией о решениях суда
function TRegIntX.AddCourts(PersData: ISuperObject; slPar: TStringList; const ReqID : string): integer;
var
  iCrts: Integer;
  lOtmena: Boolean;
  DcsnHead, DcsnGoal, GroupName: string;
  DcsnDate: TDateTime;
  dsOutPut,
  dsCourts: TDataSet;
  x : TObject;
  CourtData, OneInf, OneData, OneDecision, Courts: ISuperObject;

  // Добавить в DataSet группу решений суда одного типа
  function OneCourtsGroup(ParName: string; nType: TOneReshSud): integer;
  var
    i, iMax: Integer;
  begin
    GroupName := ParName + 's';
    if (Assigned(Courts.O[GroupName]) and (Courts.O[GroupName].IsType(stArray))) then begin
      iMax := Courts.O[GroupName].AsArray.Length;
      for i := 0 to iMax - 1 do begin
        OneDecision := Courts.O[GroupName].AsArray.O[i];
        if (Assigned(OneDecision) and (NOT OneDecision.IsType(stNull))) then begin
          OneData := OneDecision.O[ParName + '_info.' + ParName + '_data'];
          DcsnGoal := 'физического лица ';
          if ISO8601DateToDelphiDateTime(OneData.S[ParName + '_date'], DcsnDate) then begin
            // положительное решение
            lOtmena := False;
            DcsnHead := 'о признании ';
          end
          else begin
            // решение об отмене
            lOtmena := True;
            if NOT (ISO8601DateToDelphiDateTime(OneData.S[ParName + '_date_cancel'], DcsnDate)) then
              // Решение без дат, пропускаем
              Break;
            DcsnHead := 'об отмене признания ';
          end;

          case nType of
            rsUneff:
              DcsnGoal := DcsnGoal + 'недееспособным';
            rsDeaths:
              DcsnGoal := DcsnGoal + 'умершим';
            rsAbsents:
              DcsnGoal := DcsnGoal + 'безвестно отсутствующим';
            rsRestrict:
              DcsnGoal := DcsnGoal + 'ограниченно дееспособным';
          end;

          with dsCourts do begin
            Append;
            FieldByName('ID').AsString          := dsOutPut.FieldByName('PREFIX').AsString;
            FieldByName('FIO').AsString         := dsOutPut.FieldByName('FAMILIA').AsString + ' ' + dsOutPut.FieldByName('NAME').AsString + ' ' + dsOutPut.FieldByName('OTCH').AsString;
            FieldByName('TYPE_RESH').AsInteger  := Integer(nType);
            FieldByName('DATE_RESH').AsDateTime := DcsnDate;
            FieldByName('CANCEL').AsBoolean     := lOtmena;
            FieldByName('REQUEST_ID').AsString  := dsOutPut.FieldByName('REQUEST_ID').AsString;
            //FieldByName('TEXT').AsString:=DokumentToStr(doc,s+ss);
            //FieldByName('SUD').AsString:=doc.AuthorName;
            Post;
          end;

        end;
      end;

    end;

  end;

begin
  iCrts := 0;
  try
    iCrts := slPar.IndexOf(PGET_SUD);
    if (iCrts >= 0) then begin
      Courts := PersData.O['courts'];
      if (Assigned(Courts) and (Not Courts.IsType(stNull))) then begin
        dsOutPut := Response.OutDS;
        dsCourts := TDataSet(slPar.Objects[iCrts]);
        if (dsCourts = nil) then begin
          dsCourts := TRestResponse.CreateCourts;
          dsCourts.Open;
        end;
        Response.CourtDS := dsCourts;

        OneCourtsGroup('death', rsDeaths);
        OneCourtsGroup('unefficient', rsUneff);
        OneCourtsGroup('absent', rsAbsents);
        OneCourtsGroup('restrict_efficient', rsRestrict);

      end;
      iCrts := 1;
    end;
  except
    iCrts := 0;
  end;
  Result := iCrts;
end;




const
  // брак признан недействительным
  MRG_STATE_INVALID = 23;
  // брак расторгнут по суду
  MRG_STATE_BYDVC   = 22;





// Заполнить DataSet информацией о членах семьи
function TRegIntX.AddMartInfo(MartInfo: ISuperObject; const ReqID : string): integer;
var
  Status,
  i, iMax: Integer;
  EventDate : TDateTime;
  MartCert,
  Child, Mart: ISuperObject;
  Org : TNSIValue;

begin
  iMax := 0;
  try
    if (MartInfo <> nil) then begin
      MartCert := MartInfo.O['cert_data'];
      if (Assigned(MartCert) and (Not MartCert.IsType(stNull))) then begin

         if NOT (ISO8601DateToDelphiDateTime(MartCert.S['invalid_mrg_date'], EventDate)) then begin
           if NOT (ISO8601DateToDelphiDateTime(MartCert.S['invalid_mrg_date'], EventDate)) then begin

           if (ISO8601DateToDelphiDateTime(MartCert.S['date'], EventDate)) then begin
             Org := TClassifier.SObj2TKN(MartCert.O['region']);



           end else begin
             // ни одна из дат не установлена ???
           end;


           end else begin
             // брак расторгнут по суду
             Status := MRG_STATE_BYDVC;
           end;
         end else begin
           // брак признан недействительным
           Status := MRG_STATE_INVALID;

         end;

      end;
    end;
  except
    iMax := 0;
  end;
  Result := iMax;
end;


// Заполнить DataSet информацией о членах семьи
function TRegIntX.AddFamily(PersData: ISuperObject; slPar : TStringList; const ReqID, Pfx : string): integer;
var
  i, iMax: Integer;
  Child, Fam: ISuperObject;

  // Добавить одного члена семьи в DataSet
  function OneFamMember(const ParName : string): integer;
  begin
    if (Assigned(Fam.O[ParName]) and (Not Fam.O[ParName].IsType(stNull))) then begin
      if (slPar.Values[ParName] = '1') then begin
        TPersData.SObj2DSPersData(Fam.O[ParName].O['person_data'], Response.OutDS);
        Response.OutDS.Edit;
        Response.OutDS.FieldByName('IS_PERSON').AsBoolean := False;
        Response.OutDS.FieldByName('PREFIX').AsString     := Pfx + '_' + UpperCase(ParName);
        Response.OutDS.FieldByName('REQUEST_ID').AsString := ReqID;
        Response.OutDS.Post;
      end;
    end;
  end;

begin
  iMax := 0;
  try
      Fam := PersData.O['family'];
      if (Assigned(Fam) and (Not Fam.IsType(stNull))) then begin
        AddMartInfo(Fam.O['martial_status'], ReqID);
        if (Assigned(slPar) and (NOT Iif(slPar.Values['family'] = '0', True, False))) then begin

        OneFamMember('mather');
        OneFamMember('father');
        OneFamMember('wife');
        OneFamMember('husband');
        if (slPar.Values['child'] = '1') then begin
          Child := Fam.O['child'];

          if (Assigned(Child) and (Child.IsType(stArray))) then begin
            iMax := Child.AsArray.Length;
            for i := 0 to iMax - 1 do begin
              TPersData.SObj2DSPersData(Child.AsArray.O[i].O['person_data'], Response.OutDS);
              Response.OutDS.Edit;
              Response.OutDS.FieldByName('IS_PERSON').AsBoolean := False;
              Response.OutDS.FieldByName('PREFIX').AsString     := Pfx + '_CHILD' + IntToStr(i + 1);
              Response.OutDS.FieldByName('REQUEST_ID').AsString := ReqID;
              Response.OutDS.Post;
            end;
          end;
        end;


        end;
    end;
  except
    iMax := 0;
  end;
  Result := iMax;
end;


// Позиционирование входного DataSet
function TRegIntX.LocateID(IDS: TDataSet; const RequestID: string): Boolean;
begin
  Result := False;
  IDS.First;
  while not IDS.Eof do begin
    if (IDS.FieldByName('REQUEST_ID').AsString = RequestID) then begin
      Result := True;
      Break;
    end;
    IDS.Next;
  end;
end;


// Для GET-запросов заполнение выходных DataSet
function TRegIntX.SetOutDS(const Act: TActKind; slPar: TStringList; Resp: TRestResponse): Integer;
var
  i, iMax, nErr: Integer;
  ReqID: string;
  OnePD, SOArrPD: ISuperObject;
begin
  nErr := 0;
  try
    SOArrPD := Resp.RetSO.O['response'].O['personal_data'];
    if (Assigned(SOArrPD) and (SOArrPD.IsType(stArray))) then begin

      iMax := SOArrPD.AsArray.Length - 1;
      for i := 0 to iMax do begin
        ReqID := SOArrPD.AsArray.O[i].S['request_id'];
        if (LocateID(Resp.Req.InDS, ReqID)) then begin
          OnePD := SOArrPD.AsArray.O[i].O['data'];
          if (Act = akGetPersonIdentif) then begin
        // Должен вернуть запрошенный ИН по ФИО
            TPersData.SObj2DSPersData(OnePD, Resp.OutDS, False);
          end
          else begin
        // Должен вернуть персональные данные
            TPersData.SObj2DSPersData(OnePD, Resp.OutDS);
            AddCourts(OnePD, slPar, ReqID);
            AddFamily(OnePD, slPar, ReqID, Resp.Req.InDS.FieldByName('PREFIX').AsString);
          end;
        end
        else begin
          // Какой-то неправильный ID?!

        end;
      end;
    end
    else begin
    // Данные отсутствуют

    end;

    SOArrPD := Resp.RetSO.O['response'].O['identif_number'];
    if (Assigned(SOArrPD) and (SOArrPD.IsType(stArray))) then begin
      iMax := SOArrPD.AsArray.Length - 1;

      for i := 0 to iMax do begin
    // Должен вернуть зарезервированные новые ИН
        OnePD := SOArrPD.AsArray.O[i];
        Resp.OutDS.Append;
        //Resp.OutDS.FieldByName('REQUEST_ID').AsString := OnePD.S['request_id'];
        Resp.OutDS.FieldByName('NEW_IDENTIF').AsString := OnePD.S['data'];
        Resp.OutDS.FieldByName('IS_PERSON').AsBoolean := False;
        Resp.OutDS.Post;
      end;

    end;

  except
    nErr := 1;
  end;

end;




























































// Получение из регистра
function TRegIntX.Get(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument: TDataSet = nil;
    slPar: TStringList = nil; ExchMode: Integer = EM_DEFLT): TRequestResult;
var
  nErr : Integer;
  Resp : TRestResponse;
begin
  if (ExchMode = EM_DEFLT) then
    ExchMode := FExchMode;
  if (ExchMode = EM_SOAP) then begin
    Result := inherited Get(ActKind, MessageType, Input, Output, Error, Dokument, slPar);
  end
  else begin
    // Через REST-сервис
    Resp := GetRest(ActKind, MessageType, Input, Dokument, Output, Error, slPar);
    Result := Resp.RetAsSOAP;
    if (Result = rrOk) then begin
       Resp.OutDS := CreateOutputTable(akGetPersonalData);
       Output := Resp.OutDS;
       nErr := SetOutDS(ActKind, slPar, Resp);
       if Assigned(FObrPersonalData) then begin
         //FObrPersonalData(Person.data, output, dokument, slPar);
       end;
     end;
    SetErrData(ActKind, Resp);
    Error := Resp.ErrDS;
  end;
end;

// Запись в регистр документов
function TRegIntX.Post(RequestMessageId: string; ActKind: TActKind; MessageType: string; const Input: TDataSet; var Error: TDataSet; ExchMode: Integer = EM_DEFLT): TRequestResult;
var
  Resp : TRestResponse;
begin
  if (ExchMode = EM_DEFLT) then
    ExchMode := FExchMode;
  if (ExchMode = EM_SOAP) then begin
    Result := inherited Post(RequestMessageId, ActKind, MessageType, Input, Error);
  end
  else begin
    // Через REST-сервис
    Resp := PostRest(RequestMessageId, ActKind, MessageType, Input, Error);
    Result := Resp.RetAsSOAP;
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
  with InDS do begin
    Edit;
    FieldByName('REQUEST_ID').AsString := NewGUID;
    Post;
  end;
  Req := TRestRequest.Create(Self.Config);
  Req.InDS := InDS;
  Req.SetActInf(ActKind, MessageType, InDS, opGet);

  Req.MakeReqLine('POST', slPar);

  // Формирование тела запроса
  Req.MakeReqBody(InDS, MessageType);

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
  Req.InDS := InDS;
  Req.SetActInf(ActKind, MessageType, InDS, opPost);

  Req.MakeReqLine('POST');

  // Формирование тела запроса
  Req.MakeReqBody(InDS, MessageType);

  Result := ApiClient.CallApi(Req);
end;




end.
