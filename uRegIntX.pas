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
  uGetSrvX;

const
//=== *** === === *** === === *** === === *** === =>
  UN_INI_NAME = '..\GISUN\GISUN.ini';
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


  TRegIntX = class(TRegInt)
  private
    FExchMode : Integer;
    FIniIn,
    FIniOut,
    FIni : TSasaIniFile;
    FGetSrv : TGetSrvX;
    FRestClient : TRestClient;

    function SetTypeAndIDMsg(ActKind: TActKind; var MessageType: string; const PCount : Integer = -1; const INCount : Integer = -1) : TObject;
    function GetRestIN(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument:TDataSet; slPar:TStringList): TRequestResult;
  public
    property GisunX : TGetSrvX read FGetSrv write FGetSrv;

    //
    function Get(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet;
      const Dokument:TDataSet=nil; slPar:TStringList=nil; EMode : Integer = EM_SOAP): TRequestResult;
    // версия для работы с REST-сервисами
    function GetRest(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument:TDataSet; slPar:TStringList): TRequestResult;
    //
    function Post(RequestMessageId: string; ActKind: TActKind; MessageType: string; const Input: TDataSet;
      var Error: TDataSet; EMode : Integer = EM_SOAP): TRequestResult;

    constructor Create(MessageSource: string; Ini : TSasaIniFile = nil);
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



implementation

uses
  SysUtils,
  kbmMemTable,
  FuncPr;


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
    FJSONStream.WriteString('"cover":{' +
      '"message_type":{"code": "88","type":-2},' +
      '"message_source":{"code": "7689","type": 80},' +
      '"agreement":{"operator_info": "Организация адрес", "target":"верификация персональных данных","rights": [201,703,208,480,481,482,490,491,527,528,252,465,466,516,517],' +
            '"issue_date": "2019-12-07T13:22:09.619+03:00", "expiry_date": "2023-12-07T13:22:09.619+03:00", "assignee_persons": ["инспектор Иванов", "начальник инспектора Петров"]},' +
      '"dataset": [15]}');
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
































constructor TRegIntX.Create(MessageSource: string; Ini : TSasaIniFile = nil);
var
  i : Integer;
begin
  inherited Create(MessageSource);
  FIni := Ini;
  if (not Assigned(Ini)) then
    FExchMode := EM_SOAP
  else begin
    FExchMode := Ini.ReadInteger(SCT_ADMIN, 'EXCHG_MODE', EM_SOAP);
    if (FExchMode <> EM_SOAP) then begin
      // JSON допускается
    end;
  end;
  FGetSrv := TGetSrvX.Create;

end;

// Получение из регистра
function TRegIntX.Get(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet;
  const Dokument:TDataSet=nil; slPar:TStringList=nil; EMode : Integer = EM_SOAP): TRequestResult;
begin
  Result := rrFault;
  if (FExchMode <> EM_MIXED) then
    EMode := FExchMode;
  if (EMode = EM_SOAP) then
    Result := inherited Get(ActKind, MessageType, Input, Output, Error, Dokument, slPar)
  else begin
    // Через REST-сервис
    // Подготовка Body
    // Подготовка Headers
    Result := GetRest(ActKind, MessageType, Input, Output, Error, Dokument, slPar);


  end;
end;

// Запись в регистр документов
function TRegIntX.Post(RequestMessageId: string; ActKind: TActKind; MessageType: string; const Input: TDataSet; var Error: TDataSet; EMode : Integer = EM_SOAP): TRequestResult;
begin
  Result := rrFault;
end;





















function TRegIntX.SetTypeAndIDMsg(ActKind: TActKind; var MessageType: string; const PCount: Integer = -1; const INCount: Integer = -1): TObject;
//var
  //old: Integer;
begin
//------------------- стало  16.03.2021   по просьбе МВД
  GisunX.TypeMessageCover := 0;
  // при запросе ИН, данных для захоронений и опеки
  if (MessageType = QUERY_INFO) or (ActKind = akZah) or (ActKind = akOpeka) or (ActKind = akPopech) then begin
    //old := GisunX.TypeMessageCover;
    GisunX.TypeMessageCover := -2;
    MessageType := QUERY_INFO;
  end;
  if (PCount < 0) then
    Result := GisunX.CreateRegisterPersonIdentifRequest(MessageType)
  else
    Result := GisunX.CreateRegisterRequest(MessageType, PCount, INCount);

  GisunX.TypeMessageCover := 0;
//-------------------
// было         registerPersonIdentifRequest:=GisunX.CreateRegisterPersonIdentifRequest(MessageType);
//-------------------
end;




//Запрос на получение ИН по Ф.И.О.
//----------------------------------------------------------------
function TRegIntX.GetRestIN(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument:TDataSet; slPar:TStringList): TRequestResult;
var
   registerRequest: wsGisun.register_request;
   registerPersonIdentifRequest: wsGisun.register_person_identif_request;
   registerResponse: wsGisun.register_response;
   Person: wsGisun.ResponsePerson;
   PersonFam: wsGisun.ResponsePerson;
   Identif: wsGisun.ResponseIdentif;
   PersonCount: Integer;
   IdentifierCount: Integer;
   PersonInd: Integer;
   IdentifierInd: Integer;
   Table: TRegTable;
   Temp: TkbmMemTable;
   n,I: Integer;
   sss,s:String;
   lOk:Boolean;
   doc:TRegDocument;
   //FGisun : TGetSrvX;

begin
         Result := rrFault;
         registerPersonIdentifRequest := wsGisun.register_person_identif_request(SetTypeAndIDMsg(ActKind, MessageType));
         FRequestMessageId:= registerPersonIdentifRequest.cover.message_id;

         //скопировать данные из входной таблицы в свойства объекта
         Table := TableList.Find(True, akGetPersonIdentif, opGet);
         Input.First;
         if not Input.Eof then begin
            Input.Edit;
            Input.FieldByName('REQUEST_ID').AsString:=registerPersonIdentifRequest.request.request_id;
            Input.Post;
            if Table<>nil then begin
               Table.SetProp(registerPersonIdentifRequest.request, Input);
            end;
         end;

         registerResponse:=nil;
         try
            {$IFDEF MY_PROJECT}
            gisun.WriteTextLog('запрос ИН: '+registerPersonIdentifRequest.request.surname+' '+registerPersonIdentifRequest.request.name_+' '+registerPersonIdentifRequest.request.sname+' '+
                               registerPersonIdentifRequest.request.bdate, LOG_GISUN);

            SetOwnerForm(gisun.CurAkt);
            {$ENDIF}
            OpenMessage('     Запрос ИН ...          ','',0);
            try
              lOk:=FGisun.GetPersonIdentif(registerPersonIdentifRequest, registerResponse, Log, Username, Password);
            finally
              CloseMessage;
              {$IFDEF MY_PROJECT}
              gisun.CheckMainForm;
              {$ENDIF}
            end;
            FCoverMessageId:=FGisun.CoverMessageId;  //ID сообщения ответа
            FCoverMessageTime:=Now; //FGisun.CoverMessageTime;//время сообщения ответа
//  ???             registerResponse.cover.message_time;
//  ???             registerResponse.cover.message_id;

            if lOk then begin
               Result:=rrOk;
               Output:=CreateOutputTable(akGetPersonalData); //akGetPersonIdentif
               //Проверяем заголовок сообщения
               if registerResponse.cover.parent_message_id<>FRequestMessageId then begin
                  Result:=rrAfterError;
                  FFaultError:='Ошибка обмена с регистром. Не совпадают идентификаторы сообщений запроса и ответа.';
                  Log.Add('!ОШИБКА: не совпадают идентификаторы сообщений')
               end;
               Table:=TableList.Find(False, akGetPersonalData, opGet); //akGetPersonIdentif
               for I:=Low(registerResponse.response.personal_data) to High(registerResponse.response.personal_data) do begin
                  Person:=registerResponse.response.personal_data[I];
                  //Персональные данные
                  if Person<>nil then begin
                     Output.Append;
                     if Table<>nil then begin
                        Table.GetProp(Person, Output);
                     end;
                     Output.Post;
                  end
                  else begin
                     Result:=rrAfterError;
                     FFaultError:='Ошибка обмена с регистром. Не найден идентификатор запроса персональных данных.';
                     Log.Add('!ОШИБКА: не совпадают идентификаторы запросов персональных данных')
                  end;
               end;
            end
            else begin
               Result:=rrFault;
               Temp:=TkbmMemTable.Create(nil);
               CreateAndCopyMemTable(FGisun.Error, Temp);
               Error:=TDataSet(Temp);
               FFaultError:=FGisun.FaultError;
            end;
            if FFaultError<>'' then begin
              {$IFDEF MY_PROJECT}
              gisun.WriteTextLog('запрос ИН ошибка: '+FFaultError, LOG_GISUN);
              {$ENDIF}
            end;
         finally
            registerPersonIdentifRequest.Free;
            registerResponse.Free;
         end
end;








//----------------------------------------------------------------
function TRegIntX.GetRest(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument:TDataSet; slPar:TStringList): TRequestResult;
var
   registerRequest: wsGisun.register_request;
   registerPersonIdentifRequest: wsGisun.register_person_identif_request;
   registerResponse: wsGisun.register_response;
   Person: wsGisun.ResponsePerson;
   PersonFam: wsGisun.ResponsePerson;
   Identif: wsGisun.ResponseIdentif;
   PersonCount: Integer;
   IdentifierCount: Integer;
   PersonInd: Integer;
   IdentifierInd: Integer;
   Table: TRegTable;
   Temp: TkbmMemTable;
   n,I, old: Integer;
   sss,s:String;
   lOk:Boolean;
   doc:TRegDocument;

   function FindPersonData(request_id: WideString; personal_data: wsGisun.Array_Of_ResponsePerson): wsGisun.ResponsePerson;
   var
      I: Integer;
   begin
      Result:=nil;
      for I:=Low(personal_data) to High(personal_data) do begin
         if CompareText(personal_data[I].request_id, request_id)=0 then begin
            Result:=personal_data[I];
            Break;
         end;
      end;
   end;

   function FindResponseIdentif(request_id: WideString; identif_number: wsGisun.Array_Of_ResponseIdentif): wsGisun.ResponseIdentif;
   var
      I: Integer;
   begin
      Result:=nil;
      for I:=Low(identif_number) to High(identif_number) do begin
         if CompareText(identif_number[I].request_id, request_id)=0 then begin
            Result:=identif_number[I];
            Break;
         end;
      end;
   end;
   function GetPar(sParam,sDefault: String): String;
   begin
     Result:=sDefault;
     if (slPar<>nil) and (slPar.Count>0) then begin
       Result:=slPar.Values[sParam];
       if Result=''
         then Result:=sDefault;
     end;
   end;

begin
   Log.Clear;
   Output:=nil;
   Error:=nil;
   FRequestMessageId:='';
   FFaultError:='';
   Result:=rrFault;

   if not CheckLogon then begin
     // Отказ от авторизации
     FFaultError := ERR_NO_AUTH;
     Log.Add(FaultError);
     exit;
   end;

   if MessageType='' then begin
      MessageType:=CMessageType[ActKind];
   end;
   case ActKind of
      //Запрос на получение персональных данных по ф.и.о.
      akGetPersonIdentif: begin
        Result := GetRestIN(ActKind, MessageType, Input, Output, Error, Dokument, slPar);
      end;

      //Запрос на получение персональных данных
      akGetPersonalData,
      //Актовая запись о рождении
      akBirth,
      //Ребёнок - CHILD
      //Отец    - ON
      //Мать    - ONA
      //Актовая запись об установлении отцовства
      //Актовая запись об установлении материнства
      akAffiliation,
      //1. Ребёнок - CHILD
      //2. Отец    - ON
      //3. Мать    - ONA
      //Актовая запись о заключении брака
      akMarriage,
      //1. Жених   - ON
      //2. Невеста - ONA
      //Актовая запись о смерти
      akDecease,
      //Данные об умершем
      //Актовая запись о расторжении брака
      akDivorce,
      //Жена  - ONA
      //Муж   - ON
      //Актовая запись об усыновлении (удочерении)
      akAdoption,
      //Ребёнок         - CHILD
      //Мать            - ONA
      //Отец            - ON
      //Усыновительница - ONA2
      //Усыновитель     - ON2
      //Актовая запись о перемени имени
      akNameChange,
      akOpeka,
      akPopech,
      akZah
      //Персональные данные лица
      : begin
         //Считаем количество запросов идентификаторов и персональных данных
         PersonCount:=0;
         IdentifierCount:=0;
         Input.First;
         while not Input.Eof do begin
            if Input.FieldByName('IS_PERSON').AsBoolean then begin
               Inc(PersonCount);
            end
            else begin
               Inc(IdentifierCount);
            end;
            Input.Next;
         end;
{
         FGisun.TypeMessageCover:=0;
         // при запросе данных для захоронений и опеки
         if (MessageType=QUERY_INFO) or (ActKind=akZah) or (ActKind=akOpeka) or (ActKind=akPopech) then begin
           old:=FGisun.TypeMessageCover;
           FGisun.TypeMessageCover:=-2;
           MessageType:=QUERY_INFO;
         end;
         registerRequest:=FGisun.CreateRegisterRequest(MessageType, PersonCount, IdentifierCount);
         FGisun.TypeMessageCover:=0;

}
         registerRequest   := wsGisun.register_request(SetTypeAndIDMsg(ActKind, MessageType, PersonCount, IdentifierCount));
         FRequestMessageId := registerRequest.cover.message_id;


         //
         Table:=TableList.Find(True, akGetPersonalData, opGet);
         PersonInd:=0;
         IdentifierInd:=0;
         Input.First;
         while not Input.Eof do begin
            if Input.FieldByName('IS_PERSON').AsBoolean then begin
               Input.Edit;
               Input.FieldByName('REQUEST_ID').AsString:=registerRequest.request.person_request[PersonInd].request_id;
               Input.Post;
               if Table<>nil then begin
                  Table.SetProp(registerRequest.request.person_request[PersonInd], Input)
               end;
               Inc(PersonInd);
            end
            else begin
               Input.Edit;
               Input.FieldByName('REQUEST_ID').AsString:=registerRequest.request.identif_request[IdentifierInd].request_id;
               Input.Post;
               if Table<>nil then begin
                  Table.SetProp(registerRequest.request.identif_request[IdentifierInd], Input)
               end;
               Inc(IdentifierInd);
            end;
            Input.Next;
         end;
         registerResponse:=nil;
         try
            {$IFDEF MY_PROJECT}
            if gisun.FEnableTextLog then begin
              s:='';
              if length(registerRequest.request.person_request)>0 then begin
                s:=s+' запрос данных по ИН: [';
                for i:=0 to length(registerRequest.request.person_request)-1 do begin
                  s:=s+registerRequest.request.person_request[i].identif_number+' ';
                end;
                s:=Trim(s)+']';
              end;
              if length(registerRequest.request.identif_request)>0 then begin
                s:=s+' запрос ИН['+IntToStr(length(registerRequest.request.identif_request))+']';
              end;
              if s<>'' then gisun.WriteTextLog(Trim(s),LOG_GISUN);
            end;
            SetOwnerForm(gisun.CurAkt);
            {$ENDIF}
            OpenMessage('     Запрос данных ...          ','',0);
            {$IFDEF GIS_THREAD}
              EnterWorkerThread;
            {$ENDIF}
            try
              lOk:=FGisun.GetPersonalData(registerRequest, registerResponse, Log, Username, Password);
//              registerResponse.response.personal_data[i].data.courts.absents
            finally
//              gisun.CurAkt.WriteToDebug([FormatDateTime('hh:mm:ss',Now)+'  завершение запроса RegInt  1']);
              {$IFDEF GIS_THREAD}
                LeaveWorkerThread;
              {$ENDIF}
              CloseMessage;
              {$IFDEF MY_PROJECT}
              gisun.CheckMainForm;
              {$ENDIF}
            end;
            {$IFDEF MY_PROJECT}
            gisun.WriteTextLog('завершение запроса данных', LOG_GISUN);
            {$ENDIF}
            if lOk then begin
               Result:=rrOk;
               Output:=CreateOutputTable(akGetPersonalData); //akGetPersonalData
               //Проверяем заголовок сообщения
               if registerResponse.cover.parent_message_id<>FRequestMessageId then begin
                  Result:=rrAfterError;
                  FFaultError:='Ошибка обмена с регистром. Не совпадают идентификаторы сообщений запроса и ответа.';
                  Log.Add('!ОШИБКА: не совпадают идентификаторы сообщений')
               end;
               //
               FCoverMessageId:=Copy(registerResponse.cover.message_id,2,36);     //GUID сообщения ответа
               FCoverMessageTime:=registerResponse.cover.message_time.AsDateTime; //время сообщения ответа
               Table:=TableList.Find(False, akGetPersonalData, opGet);
               Input.First;
               while not Input.Eof do begin
                  if Input.FieldByName('IS_PERSON').AsBoolean then begin
                     Person:=FindPersonData(Input.FieldByName('REQUEST_ID').AsString, registerResponse.response.personal_data);
                     //Персональные данные
                     if Person<>nil then begin
                        Output.Append;
                        Output.FieldByName('IS_PERSON').AsBoolean:=Input.FieldByName('IS_PERSON').AsBoolean;
                        Output.FieldByName('PREFIX').AsString:=Input.FieldByName('PREFIX').AsString;
                        if Table<>nil then begin
                           Table.GetProp(Person, Output);
                        end;
                        Output.Post;
                        //-----------------------------------
                        if (person.data.family<>nil) and (GetPar('family', '0')='1') then begin   // load fam
                        {
    property father:      Array_Of_familyInfo
    property mather:      Array_Of_familyInfo
    property wife:        Array_Of_familyInfo
    property husband:     Array_Of_familyInfo
    property child:       Array_Of_familyInfo
                         }
                          Table.ChangePath('ResponsePerson.data','PersonalData'); // !!!
                          try
                            sss:=Input.FieldByName('PREFIX').AsString;
                            if (person.data.family.child<>nil) and (GetPar('child', '0')='1') then begin
                              for n:=Low(person.data.family.child) to HIGH(person.data.family.child) do begin
                                Output.Append;
                                Output.FieldByName('IS_PERSON').AsBoolean:=false;
                                Output.FieldByName('PREFIX').AsString:=sss+'_CHILD'+InttoStr(n+1);
                                Table.GetProp(person.data.family.child[n].person_data, Output);
                                Output.Post;
                              end;
                            end;
                            if (person.data.family.husband<>nil) and (GetPar('husband', '0')='1') then begin
                              Output.Append;
                              Output.FieldByName('IS_PERSON').AsBoolean:=false;
                              Output.FieldByName('PREFIX').AsString:=sss+'_HUSBAND';
                              Table.GetProp(person.data.family.husband.person_data, Output);
                              Output.Post;
                            end;
                            if (person.data.family.wife<>nil) and (GetPar('wife', '0')='1') then begin
                              Output.Append;
                              Output.FieldByName('IS_PERSON').AsBoolean:=false;
                              Output.FieldByName('PREFIX').AsString:=sss+'_WIFE';
                              Table.GetProp(person.data.family.wife.person_data, Output);
                              Output.Post;
                            end;
                            if (person.data.family.father<>nil) and (GetPar('father', '0')='1') then begin
                              Output.Append;
                              Output.FieldByName('IS_PERSON').AsBoolean:=false;
                              Output.FieldByName('PREFIX').AsString:=sss+'_FATHER';
                              Table.GetProp(person.data.family.father.person_data, Output);
                              Output.Post;
                            //  doc:=FindDokumentFromArr(person.data.family.father.documents, '0300', 82);   // load doc
                            //  showmessage(inttostr(HIGH(person.data.family.father.documents))+' '+doc.AuthorName+' '+doc.Number);
                            end;
                            if (person.data.family.mather<>nil) and (GetPar('mather', '0')='1') then begin
                              Output.Append;
                              Output.FieldByName('IS_PERSON').AsBoolean:=false;
                              Output.FieldByName('PREFIX').AsString:=sss+'_MATHER';
                              Table.GetProp(person.data.family.mather.person_data, Output);
                              Output.Post;
                            end;
                          finally
                            Table.ChangePath('PersonalData','ResponsePerson.data'); // !!!
                            Output.First;
                          end;
                        end;
                        //-------------------------------------------
                        if Assigned(FObrPersonalData) then begin
                          FObrPersonalData(Person.data, output, dokument, slPar);
                        end;
                     end
                     else begin
                        Result:=rrAfterError;
                        FFaultError:='Ошибка обмена с регистром. Не найден идентификатор запроса персональных данных.';
                        Log.Add('!ОШИБКА: не совпадают идентификаторы запросов персональных данных')
                     end;
                  end
                  else begin
                     Identif:=FindResponseIdentif(Input.FieldByName('REQUEST_ID').AsString, registerResponse.response.identif_number);
                     //Персональные данные
                     if Identif<>nil then begin
                        Output.Append;
                        Output.FieldByName('IS_PERSON').AsBoolean:=Input.FieldByName('IS_PERSON').AsBoolean;
                        Output.FieldByName('PREFIX').AsString:=Input.FieldByName('PREFIX').AsString;
                        if Table<>nil then begin
                           Table.GetProp(Identif, Output)
                        end;
                        Output.Post;
                     end
                     else begin
                        Result:=rrAfterError;
                        FFaultError:='Ошибка обмена с регистром. Не найден идентификатор запроса личного номера.';
                        Log.Add('!ОШИБКА: не совпадают идентификаторы запросов личного номера')
                     end;
                  end;
                  Input.Next;
               end;
               //------ отладка ----------------------------
               {
               Output.First;
                sss:=IntToStr(Output.RecordCount)+#13#10;
                while not Output.Eof do begin
                  sss:=sss+Output.FieldByName('PREFIX').AsString+' '+Output.FieldByName('FAMILIA').AsString+' '+Output.FieldByName('NAME').AsString+' '+
                  Output.FieldByName('OTCH').AsString+' '+Output.FieldByName('DATER').AsString+
                  Output.FieldByName('ZH_N_KLAD').AsString+' '+Output.FieldByName('ZH_N_OBL').AsString+' '+Output.FieldByName('ZH_N_RAION').AsString+
                  #13#10;
                  Output.Next;
                end;
                Output.First;
                Showmessage(sss);
                }
                //-------------------------------------------
            end else begin
               Result:=rrFault;
               Temp:=TkbmMemTable.Create(nil);
               CreateAndCopyMemTable(FGisun.Error, Temp);
               Error:=TDataSet(Temp);
               FFaultError:=FGisun.FaultError;
            end;
            if FFaultError<>'' then begin
              {$IFDEF MY_PROJECT}
              gisun.WriteTextLog('запрос данных ошибка: '+FFaultError, LOG_GISUN);
              {$ENDIF}
            end;
//            gisun.CurAkt.WriteToDebug([FormatDateTime('hh:mm:ss',Now)+'  завершение запроса RegInt  2']);
         finally
            registerRequest.Free;
            registerResponse.Free;
         end;
      end;
   end;
end;

end.
