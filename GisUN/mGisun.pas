unit mGisun;

interface

{$I Task.inc}

uses
   wsGisun, SysUtils, Classes, Forms, TypInfo, SoapHTTPClient, WinInet, SOAPHTTPTrans,
   XSBuiltIns, InvokeRegistry, uProject, uTypes,
   Variants, Dialogs, DB, NativeXML, FuncPr, uWideStrUtils;

type
   TGisunInterface=class(TObject)
   private
      //SOAP
      FRIO: THTTPRIO;
      //адрес сервиса
      FUrl: string;
      FProxy: string;
      //
      FMessageSource: string;
      //
      FFaultError: string;
      //
      FError: TDataSet;
      FTypeMessageSource:Integer;
      FTypeMessageCover:Integer;
   private
      //события SOAP
      procedure RIOAfterExecute(const MethodName: string; SOAPResponse: TStream);
      procedure RIOBeforeExecute(const MethodName: string; var SOAPRequest: WideString);
      procedure RIOHTTPWebNodeReceivingData(Read, Total: Integer);
      procedure RIOHTTPWebNodePostingData(Write, Total: Integer);
      procedure RIOHTTPWebNodeBeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);

      //
      procedure SetUrl(Value: string);
      procedure CopyErrorList(error_list: ErrorList);
   protected
      //сервис
      FFService: GisunCommonWs;
      //
      FCurLog: TStrings;
      
      //получение ссылки не сервис
      function GetService: GisunCommonWs;
      procedure ClearError;
   public
      CoverMessageId:String;
//      CoverMessageTime:TDateTime;
      EnabledLog:Boolean;
      constructor Create;
      destructor Destroy; override;
      //ИНТЕРФЕЙС:
      //создание объектов
      function CreateId: string;
      function CreateMessageCover(MessageType, ParentId: string): MessageCover;
      function CreateClassifier(Code: string; ClassifierType: Integer): Classifier;
      function CreateDateTime(DateTime: TDateTime): TXSDateTime;
      function CreateRegisterRequest(MessageType: string; PersonCount, IdentifierCount: Integer): register_request;
      function CreateRegisterPersonIdentifRequest(MessageType: string): register_person_identif_request;
      function CreateDocument: Document;
      //обработка исключений
      procedure HandleException(E: Exception; Log: TStrings);
      //запись исключения в error-dataset
      function  FindNodeXML(x:TXMLNode; strFind:String):TXMLNode;
      procedure FaultDetailToError(strFaultDetail:String; strMessage:String);
      //вызов методов
      function GetPersonalData(const registerRequest: register_request; var registerResponse: register_response; Log: TStrings; User, Pasw: string): Boolean;
      function GetPersonIdentif(const registerPersonIdentifRequest: register_person_identif_request; var registerResponse: register_response; Log: TStrings; User, Pasw: string): Boolean; virtual;
      //ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ ТЕСТОВ:
      //вывод в лог
      procedure MessageCoverToLog(Log: TStrings; Cover: MessageCover);
      procedure ErrorListToLog(Log: TStrings; error_list: ErrorList);
      class procedure PersonalDataToLog(Log: TStrings; Data: PersonalData; Add: string);
      class procedure DocumentToLog(Log: TStrings; Doc: Document; Add: string);
      class procedure AddressToLog(Log: TStrings; Adr: Address; Add: string);
      class procedure FamilyDataToLog(Log: TStrings; Family: FamilyData; Add: string);
      class procedure FamilyInfoToLog(Log: TStrings; Family: FamilyInfo; Add: string);
      class procedure DeathInfoToLog(Log: TStrings; D: DeathInfo; Add: string);
      class procedure DeathToLog(Log: TStrings; D: Death; Add: string);
      class procedure CitizenshipToLog(Log: TStrings; C: Citizenship; Add: string);
      class procedure PensionInfoToLog(Log: TStrings; P: PensionInfo; Add: string);
      class procedure PensionToLog(Log: TStrings; P: Pension; Add: string);
      class procedure PhotoToLog(Log: TStrings; P: PhotoInfo; Add: string);
      class procedure CourtListToLog(Log: TStrings; C: CourtList; Add: string);
      class procedure EducationInfoToLog(Log: TStrings; E: EducationInfo; Add: string);
      class procedure EducationToLog(Log: TStrings; E: Education; Add: string);
      class procedure ScienceRankInfoToLog(Log: TStrings; R: ScienceRankInfo; Add: string);
      class procedure ScienceRankToLog(Log: TStrings; R: ScienceRank; Add: string);
      class procedure ScienceDegreeInfoToLog(Log: TStrings; D: ScienceDegreeInfo; Add: string);
      class procedure ScienceDegreeToLog(Log: TStrings; D: ScienceDegree; Add: string);
      class procedure InsuranceInfoToLog(Log: TStrings; I: InsuranceInfo; Add: string);
      class procedure InsuranceToLog(Log: TStrings; I: Insurance; Add: string);
      class procedure TaxInfoToLog(Log: TStrings; T: TaxInfo; Add: string);
      class procedure TaxToLog(Log: TStrings; T: Tax; Add: string);
      class procedure MilitaryInfoToLog(Log: TStrings; M: MilitaryInfo; Add: string);
      class procedure MilitaryToLog(Log: TStrings; M: Military; Add: string);
      //преобразование в строку
      class function GetClassifierString(C: Classifier): string;
      class function GetDateString(Date: TXSDate): string;
      class function GetDateTimeString(DateTime: TXSDateTime): string;
      //другие вспомогательные
      function GetClassifierLexema(C: Classifier): string;
      function GetClassifierCode(C: Classifier): string;
      //
      procedure UpdateUrl(Value: string);
      function RequestChangeClassif(nType: Integer;  dDateFrom: TDateTime; dsResult:TDataSet; Log:TStrings): Boolean;

   public
      property TypeMessageSource: Integer read FTypeMessageSource write FTypeMessageSource;
      property TypeMessageCover: Integer read FTypeMessageCover write FTypeMessageCover;
      property MessageSource: string read FMessageSource write FMessageSource;
      property Service: GisunCommonWs read GetService;
      property Url: string read FUrl write SetUrl;
      property Proxy: string read FProxy write FProxy;
      property FaultError: string read FFaultError;
      property Error: TDataSet read FError;
   end;

implementation
uses
   mRegInt, mSecHeader, StrUtils;

{ TGisunInterface }

constructor TGisunInterface.Create;
begin
   EnabledLog:=true;
   FTypeMessageSource:=ctZags;
   FTypeMessageCover:=0;
   //Список последних ошибок
   FError:=CreateErrorTable;
   //SOAP
   FRIO:=THTTPRIO.Create(nil);
//   FRIO.HTTPWebNode.SendTimeout:=
   FRIO.OnAfterExecute:=RIOAfterExecute;
   FRIO.OnBeforeExecute:=RIOBeforeExecute;
   FRIO.HTTPWebNode.OnReceivingData:=RIOHTTPWebNodeReceivingData;
   FRIO.HTTPWebNode.OnPostingData:=RIOHTTPWebNodePostingData;
   FRIO.HTTPWebNode.OnBeforePost:=RIOHTTPWebNodeBeforePost;

end;

destructor TGisunInterface.Destroy;
begin
   FFService:=nil;
   //!!!!!!! почему то возникал AV
   //FRIO.Free;
   FError.Close;
   FError.Free;
   inherited;
end;

//-----------------------------------------------------------------------------------------------------------------------
procedure TGisunInterface.RIOHTTPWebNodeBeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);
begin
  if Global_TimeOut_BeforePost>0 then begin
    InternetSetOption(Data, INTERNET_OPTION_CONNECT_TIMEOUT, Pointer(@Global_TimeOut_BeforePost), SizeOf(Global_TimeOut_BeforePost));
    InternetSetOption(Data, INTERNET_OPTION_SEND_TIMEOUT, Pointer(@Global_TimeOut_BeforePost), SizeOf(Global_TimeOut_BeforePost));
    InternetSetOption(Data, INTERNET_OPTION_RECEIVE_TIMEOUT, Pointer(@Global_TimeOut_BeforePost), SizeOf(Global_TimeOut_BeforePost));
  end;
end;
//-----------------------------------------------------------------------------------------------------------------------
procedure TGisunInterface.RIOHTTPWebNodeReceivingData(Read, Total: Integer);
begin
  if (FCurLog<>nil) and EnabledLog
    then FCurLog.Add('Получение данных    получено='+IntToStr(Read)+', всего='+IntToStr(Total));
end;

procedure TGisunInterface.RIOHTTPWebNodePostingData(Write, Total: Integer);
begin
  if (FCurLog<>nil) and EnabledLog
    then FCurLog.Add('Отправка данных    отправлено='+IntToStr(Write)+', всего='+IntToStr(Total));
end;

procedure TGisunInterface.RIOAfterExecute(const MethodName: string; SOAPResponse: TStream);
var
   XMLDoc:TNativeXML;
   sFile:String;
   stFile:TFileStream;
   {$IFDEF DEBUG_GIS}
     stDebug:TMemoryStream;
   {$ENDIF}
begin
   {$IFDEF DEBUG_GIS}
   sFile:=ExtractFilePath(Application.ExeName)+'Запрос_ответ+.xml';
   if FileExists(sFile) then begin
     stDebug:=TMemoryStream.Create;
     stDebug.LoadFromFile(sFile);
     stDebug.Position:=0;
     SOAPResponse.Size:=0;
     SOAPResponse.Position:=0;
     SOAPResponse.CopyFrom(stDebug, stDebug.Size);
     SOAPResponse.Position:=0;
     stDebug.Free;
   end;
   {$ENDIF}
   //вывод текста запроса
   sFile:=ExtractFilePath(Application.ExeName)+'Запрос_ответ.xml';
   DeleteFile(sFile);
   stFile:=TFileStream.Create(sFile, fmCreate);
   SOAPResponse.Position:=0;
   try
     stFile.CopyFrom(SOAPResponse, SOAPResponse.Size);
   finally
     stFile.Free;
   end;
   SOAPResponse.Position:=0;

   //вывод текста запроса
   XMLDoc:=TNativeXML.Create;
   try
     XMLDoc.LoadFromStream(SOAPResponse);
     if not CheckHash(XMLDoc) then begin  // контроль хеш-строки
// !!!       PutError('Ошибка полученных данных: неверное Хеш-значение');
     end;
//     XMLDoc.SaveToFile(ExtractFilePath(Application.ExeName)+'Запрос_ответ.xml');
   finally
     XMLDoc.Free;
   end;
end;

procedure TGisunInterface.RIOBeforeExecute(const MethodName: string; var SOAPRequest: WideString);
var
   S: Utf8String;
   n,m: Integer;
   strErr:String;
begin
   //вывод текста запроса

   CreateETSP(SOAPRequest,strErr);

   try
     S:=Utf8Encode(SOAPRequest);
     n:=Pos('<Password>',s);
     m:=Pos('</Password>',s);
     if (n>0) and (m>0) then begin
       s:=Copy(s,1,n+9)+'*****'+Copy(s,m,Length(s));
     end;
     MemoWrite(ExtractFilePath(Application.ExeName)+'Запрос.xml', S);
   except

   end;
end;

function TGisunInterface.GetService: GisunCommonWs;
begin
   if FFService=nil then begin
      FFService:=GetGisunWs(FUrl, FProxy, FRIO);
      //try except end !!! когда нет связи
   end;
   Result:=FFService;
end;

function TGisunInterface.CreateClassifier(Code: string; ClassifierType: Integer): Classifier;
begin
   //Классификатор
   Result:=Classifier.Create;
   //Кодовое значение
   Result.code:=Code;
   //Тип классификатора
   Result.type_:=ClassifierType;
   //Список лексем
   //Result.lexema/
   //Result.lexema/Text
   //Язык передаваемого значения
   //Result.lexema/lang
   //Признак активности
   //Result.active
   //Дата формирования
   //Result.begin_date
   //Дата упразднения
   //Result.end_date
end;

function TGisunInterface.CreateDateTime(DateTime: TDateTime): TXSDateTime;
begin
   Result:=TXSDateTime.Create;
   Result.AsDateTime:=DateTime;
end;

function TGisunInterface.CreateId: string;
var
   GUID: TGUID;
begin
   CReateGUID(GUID);
   //Внутренний идентификатор
   Result:=GUIDToString(GUID);
end;

function TGisunInterface.CreateMessageCover(MessageType, ParentId: string): MessageCover;
var
  n:Integer;
begin
   //Сопроводительная информация к сообщению
   Result:=MessageCover.Create;
   //Идентификатор сообщения
   Result.message_id:=CreateId;
   //Тип сообщения
   if FTypeMessageCover=0 then n:=ctActType else n:=FTypeMessageCover;
   Result.message_type:=CreateClassifier(MessageType, n);
   //Время отправки сообщения
   Result.message_time:=CreateDateTime(Now);
   //Источник сообщения
   Result.message_source:=CreateClassifier(FMessageSource, FTypeMessageSource);
   //Идентификатор сообщения, для которого текущее является ответом
   Result.parent_message_id:=ParentId;
end;

function TGisunInterface.CreateRegisterRequest(MessageType: string; PersonCount, IdentifierCount: Integer): register_request;
var
   I: Integer;
   person_request: Array_Of_PersonRequest;
   identif_request: Array_Of_IdentifRequest;
begin
   //Запрос на получение данных из ГИС РН
   Result:=register_request.Create;
   //Заголовок запроса
   //Сопроводительная информация к сообщению
   Result.cover:=CreateMessageCover(MessageType, '');
   //Тело запроса
   //Список запросов в ГИС РН
   Result.request:=RequestData.Create;
   //инициализация массива на получение персональных данных
   if PersonCount>0 then begin
      SetLength(person_request, PersonCount);
      for I:=0 to Pred(PersonCount) do begin
         //Запрос на получение персональных данных
         person_request[I]:=PersonRequest.Create;
         //Идентификатор запроса
         person_request[I].request_id:=CreateId;
         //Идентификационный номер
         //person_request[I].identif_number
         //Данные паспорта
         person_request[I].document:=CreateDocument;
      end;
      Result.request.person_request:=person_request;
   end;
   //инициализация массива на генерацию новых идентификационных номеров
   if IdentifierCount>0 then begin
      SetLength(identif_request, IdentifierCount);
      for I:=0 to Pred(IdentifierCount) do begin
         //Запрос на получение идентификационного номера
         identif_request[I]:=IdentifRequest.Create;
         //Идентификатор запроса
         identif_request[I].request_id:=CreateId;
         //Пол
         //identif_request[I].sex
         //Дата рождения
         //identif_request[I].birth_day
      end;
      Result.request.identif_request:=identif_request;
   end;
end;

function TGisunInterface.CreateDocument: Document;
begin
   //Документ, удостоверяющий личность
   Result:=Document.Create;
   //Тип доступа
   //Result.access
   //Тип документа
   //Result.document_type
   //Гос. орган, выдавший документ
   //Result.authority
   //Дата выдачи документа
   //Result.date_of_issue
   //Срок действия документа
   //Result.expire_date
   //Серия документа
   //Result.series
   //Номер документа
   //Result.number
   //Информация по актовой записи
   //Result.act_data
   //Признак действительного документа
   //Result.active
end;

function TGisunInterface.GetPersonalData(const registerRequest: register_request; var registerResponse: register_response; Log: TStrings; User, Pasw: string): Boolean;
var
   I: Integer;
   hdr: TSOAPHeader;
   Headers: ISOAPHeaders;
begin
   ClearError;
   Result:=False;
   try
      if GetService<>nil then begin
         if EnabledLog then begin
           Log.Add('');
           Log.Add('Выполняется запрос на получение данных из регистра:');
           Log.Add('');
           MessageCoverToLog(Log, registerRequest.cover);
           Log.Add('');
           Log.Add(Format('Запрос на получение пресональных данных person_request (%d):', [Length(registerRequest.request.person_request)]));
           for I:=Low(registerRequest.request.person_request) to High(registerRequest.request.person_request) do begin
              Log.Add('');
              Log.Add(Format('person_request/request_id     =%s', [registerRequest.request.person_request[I].request_id]));
              Log.Add(Format('person_request/identif_number =%s', [registerRequest.request.person_request[I].identif_number]));
              DocumenttoLog(Log, registerRequest.request.person_request[I].document, 'person_request/document/');
           end;
           Log.Add('');
           Log.Add(Format('Запрос на генерацию нового идентификационного номера  (%d):', [Length(registerRequest.request.identif_request)]));
           for I:=Low(registerRequest.request.identif_request) to High(registerRequest.request.identif_request) do begin
              Log.Add('');
              Log.Add(Format('identif_request/request_id =%s', [registerRequest.request.identif_request[I].request_id]));
              Log.Add(Format('identif_request/sex        =%s', [GetClassifierString(registerRequest.request.identif_request[I].sex)]));
              Log.Add(Format('identif_request/birth_day  =%s', [registerRequest.request.identif_request[I].birth_day]));
           end;
         end;
         hdr:=nil;
         {$IFDEF MY_PROJECT}
         if IsCreateHeader then begin
         {$ELSE}
         if (User<>'') and (Pasw<>'') then begin
         {$ENDIF}
            hdr:=CreateHeader(User, Pasw);
            Headers:=FFService as ISOAPHeaders;
            Headers.Send(hdr);
         end;

         FCurLog:=Log;
         registerResponse:=FFService.getPersonalData(registerRequest);
         FCurLog:=nil;
         hdr.Free;

         if EnabledLog then begin
           Log.Add('');
           Log.Add('Получен ответ:');
           Log.Add('');
           MessageCoverToLog(Log, registerResponse.cover);
           Log.Add('');
           Log.Add(Format('Список персональных данных personal_data (%d):', [Length(registerResponse.response.personal_data)]));
           for I:=Low(registerResponse.response.personal_data) to High(registerResponse.response.personal_data) do begin
//           registerResponse.response.personal_data[I].data.courts.unefficients[0].unefficient_data.unefficient_date
              Log.Add('');
              Log.Add(Format('personal_data/request_id =%s', [registerResponse.response.personal_data[I].request_id]));
              PersonalDataToLog(Log, registerResponse.response.personal_data[I].data, 'personal_data/');
           end;
           Log.Add('');
           Log.Add(Format('Список идентификационных номеров identif_number (%d):', [Length(registerResponse.response.identif_number)]));
           for I:=Low(registerResponse.response.identif_number) to High(registerResponse.response.identif_number) do begin
              Log.Add('');
              Log.Add(Format('identif_number/request_id =%s', [registerResponse.response.identif_number[I].request_id]));
              Log.Add(Format('identif_number/data       =%s', [registerResponse.response.identif_number[I].data]));
           end;
         end;
         Result:=True;
      end
      else begin
        if EnabledLog then begin
          Log.Add('ОШИБКА: GetService=nil');
        end;
      end;
   except
      on E: Exception do begin
         HandleException(E, Log);
      end;
   end;
end;

procedure TGisunInterface.MessageCoverToLog(Log: TStrings; Cover: MessageCover);
begin
   if EnabledLog then begin
     if cover<>nil then begin
        Log.Add('/cover/');
        Log.Add(Format('/cover/message_id        =%s', [cover.message_id]));
        Log.Add(Format('/cover/message_type      =%s', [GetClassifierString(cover.message_type)]));
        Log.Add(Format('/cover/message_time      =%s', [GetDateTimeString(cover.message_time)]));
        Log.Add(Format('/cover/message_source    =%s', [GetClassifierString(cover.message_source)]));
        Log.Add(Format('/cover/parent_message_id =%s', [cover.parent_message_id]));
     end
     else begin
        Log.Add('/cover/ =nil');
     end;
   end;
end;

procedure TGisunInterface.ErrorListToLog(Log: TStrings; error_list: ErrorList);
var
   I: Integer;
   ErrorList: TStringList;
begin
   if EnabledLog then begin
     ErrorList:=TStringList.Create;
     ErrorList.Add('error_code.code;error_code.text;error_place;wrong_value;correct_value;check_name;description;identif');
     try
        Log.Add(Format('Список ошибок error_list (%d):', [Length(error_list)]));
        for I:=Low(error_list) to High(error_list) do begin
           Log.Add(Format('error_code=%s', [GetClassifierString(error_list[I].error_code)]));
           Log.Add(Format('error_place=%s', [error_list[I].error_place]));
           Log.Add(Format('wrong_value=%s', [error_list[I].wrong_value]));
           Log.Add(Format('correct_value=%s', [error_list[I].correct_value]));
           Log.Add(Format('check_name=%s', [error_list[I].check_name]));
           Log.Add(Format('description   =%s', [error_list[I].description]));
           Log.Add(Format('identif       =%s', [error_list[I].identif]));
           ErrorList.Add(Format('"%s";"%s";"%s";"%s";"%s";"%s";"%s";"%s"', [GetClassifierCode(error_list[I].error_code), GetClassifierLexema(error_list[I].error_code), error_list[I].error_place, error_list[I].wrong_value, error_list[I].correct_value, error_list[I].check_name, error_list[I].description, error_list[I].identif]));
        end;
        ErrorList.SaveToFile('error_list.csv');
     finally
        ErrorList.Free;
     end;
   end;
end;

const
   MapBool: array [Boolean] of string=('False', 'True');

class procedure TGisunInterface.PersonalDataToLog(Log: TStrings; Data: PersonalData; Add: string);
var
   I: Integer;
begin
     if Data<>nil then begin
        Log.Add(Format(Add+'access         =%s', [GetClassifierString(Data.access)]));
        Log.Add(Format(Add+'identif        =%s', [Data.identif]));
        Log.Add(Format(Add+'last_name      =%s', [Data.last_name]));
        Log.Add(Format(Add+'last_name_bel  =%s', [Data.last_name_bel]));
        Log.Add(Format(Add+'last_name_lat  =%s', [Data.last_name_lat]));
        Log.Add(Format(Add+'name_          =%s', [Data.name_]));
        Log.Add(Format(Add+'name_bel       =%s', [Data.name_bel]));
        Log.Add(Format(Add+'name_lat       =%s', [Data.name_lat]));
        Log.Add(Format(Add+'patronymic     =%s', [Data.patronymic]));
        Log.Add(Format(Add+'patronymic_bel =%s', [Data.patronymic_bel]));
        Log.Add(Format(Add+'patronymic_lat =%s', [Data.patronymic_lat]));
        Log.Add(Format(Add+'sex            =%s', [GetClassifierString(Data.sex)]));
        Log.Add(Format(Add+'birth_day      =%s', [Data.birth_day]));
        if Data.birth_place<>nil then begin
           Log.Add(Format(Add+'birth_place/country_b    =%s', [GetClassifierString(Data.birth_place.country_b)]));
           Log.Add(Format(Add+'birth_place/area_b       =%s', [Data.birth_place.area_b]));
           Log.Add(Format(Add+'birth_place/area_b_bel   =%s', [Data.birth_place.area_b_bel]));
           Log.Add(Format(Add+'birth_place/region_b     =%s', [Data.birth_place.region_b]));
           Log.Add(Format(Add+'birth_place/region_b_bel =%s', [Data.birth_place.region_b_bel]));
           Log.Add(Format(Add+'birth_place/type_city_b  =%s', [GetClassifierString(Data.birth_place.type_city_b)]));
           Log.Add(Format(Add+'birth_place/city_b       =%s', [Data.birth_place.city_b]));
           Log.Add(Format(Add+'birth_place/city_b_bel   =%s', [Data.birth_place.city_b_bel]));
           Log.Add(Format(Add+'birth_place/city_b_ate   =%s', [GetClassifierString(Data.birth_place.city_b_ate)]));
        end
        else begin
           Log.Add(Add+'birth_place    =nil');
        end;
        Log.Add(Format(Add+'citizenship    =%s', [GetClassifierString(Data.citizenship)]));
        Log.Add(Format(Add+'status         =%s', [GetClassifierString(Data.status)]));
        if Length(Data.document)<>0 then begin
           for I:=Low(Data.document) to High(Data.document) do begin
              DocumentToLog(Log, Data.document[I], Format(Add+'document[%d]/', [I]));
           end;
        end
        else begin
           Log.Add(Add+'document (0)');
        end;
        if Length(Data.photo)<>0 then begin
           for I:=Low(Data.photo) to High(Data.photo) do begin
              PhotoToLog(Log, Data.photo[I], Format(Add+'photo[%d]/', [I]));
           end;
        end
        else begin
           Log.Add(Add+'photo (0)');
        end;
        if Length(Data.nationality_data)<>0 then begin
           for I:=Low(Data.nationality_data) to High(Data.nationality_data) do begin
              CitizenshipToLog(Log, Data.nationality_data[I], Format(Add+'nationality_data[%d]/', [I]));
           end;
        end
        else begin
           Log.Add(Add+'nationality_data (0)');
        end;
        AddressToLog(Log, Data.address, Add+'address/');

  //      AddressToLog(Log, Data.temp_address, Add+'temp_address/');
       {   !!!
        if Length(Data.temp_addresses)<>0 then begin
           for I:=Low(Data.temp_addresses) to High(Data.temp_addresses) do begin
              AddressToLog(Log, Data.temp_addresses[I], Format(Add+'temp_addresses[%d]/', [I]));
           end;
        end
        else begin
           Log.Add(Add+'temp_addresses (0)');
        end;
        }

        if Length(Data.deaths)<>0 then begin
           for I:=Low(Data.deaths) to High(Data.deaths) do begin
              DeathInfoToLog(Log, Data.deaths[I], Format(Add+'deaths[%d]/', [I]));
           end;
        end
        else begin
           Log.Add(Add+'deaths (0)');
        end;
        FamilyDataToLog(Log, Data.family, Add+'family/');

        CourtListToLog(Log, Data.courts, Add+'courts/');    // суды
        //-----------------------------------
        if Length(Data.educations)<>0 then begin   // образование
           for I:=Low(Data.educations) to High(Data.educations) do begin
              EducationInfoToLog(Log, Data.educations[I], Format(Add+'educations[%d]/', [I]));
           end;
        end
        else begin
           Log.Add(Add+'educations (0)');
        end;
        //-----------------------------------
        if Length(Data.scienceRanks)<>0 then begin   // ученая чин, категория
           for I:=Low(Data.scienceRanks) to High(Data.scienceRanks) do begin
              ScienceRankInfoToLog(Log, Data.scienceRanks[I], Format(Add+'scienceRanks[%d]/', [I]));
           end;
        end
        else begin
           Log.Add(Add+'scienceRanks (0)');
        end;
        //-----------------------------------
        if Length(Data.scienceDegrees)<>0 then begin   // ученая степень
           for I:=Low(Data.scienceDegrees) to High(Data.scienceDegrees) do begin
              ScienceDegreeInfoToLog(Log, Data.scienceDegrees[I], Format(Add+'scienceDegrees[%d]/', [I]));
           end;
        end
        else begin
           Log.Add(Add+'scienceDegrees (0)');
        end;
        if Length(Data.pensions)<>0 then begin
           for I:=Low(Data.pensions) to High(Data.pensions) do begin
              PensionInfoToLog(Log, Data.pensions[I], Format(Add+'pensions[%d]/', [I]));
           end;
        end
        else begin
           Log.Add(Add+'pensions (0)');
        end;
        if Length(Data.insurances)<>0 then begin
           for I:=Low(Data.insurances) to High(Data.insurances) do begin
              InsuranceInfoToLog(Log, Data.insurances[I], Format(Add+'insurances[%d]/', [I]));
           end;
        end
        else begin
           Log.Add(Add+'insurances (0)');
        end;
        if Length(Data.taxies)<>0 then begin
           for I:=Low(Data.taxies) to High(Data.taxies) do begin
              TaxInfoToLog(Log, Data.taxies[I], Format(Add+'taxies[%d]/', [I]));
           end;
        end
        else begin
           Log.Add(Add+'taxies (0)');
        end;
        if Length(Data.militaries)<>0 then begin
           for I:=Low(Data.militaries) to High(Data.militaries) do begin
              MilitaryInfoToLog(Log, Data.militaries[I], Format(Add+'militaries[%d]/', [I]));
           end;
        end
        else begin
           Log.Add(Add+'militaries (0)');
        end;
     end
     else begin
        Log.Add(Add+' =nil');
     end;
end;

class function TGisunInterface.GetClassifierString(C: Classifier): string;
var
   I: Integer;
begin
   if C=nil then begin
      Result:='nil';
   end
   else begin
      Result:=Format('type: %d, code: %s', [C.type_, C.code]);
      for I:=Low(C.lexema) to High(C.lexema) do begin
         Result:=Format('%s, Text: %s, lang: %s', [Result, C.lexema[I].Text, C.lexema[I].lang]);
      end;
   end;
end;

class function TGisunInterface.GetDateString(Date: TXSDate): string;
begin
   if Date=nil then begin
      Result:='nil';
   end
   else begin
      Result:=FormatDateTime('yyyy.mm.dd', Date.AsDate);
   end;
end;

class function TGisunInterface.GetDateTimeString(DateTime: TXSDateTime): string;
begin
   if DateTime=nil then begin
      Result:='nil';
   end
   else begin
      Result:=FormatDateTime('yyyy.mm.dd hh:nn', DateTime.AsDateTime);
   end;
end;

procedure TGisunInterface.HandleException(E: Exception; Log: TStrings);    // vadim
begin
   if E is WsException then begin
     CoverMessageId:=WsException(E).cover.message_id;
//     CoverMessageTime:=WsException(E).cover.message_time.AsDateTime;
     if EnabledLog and (Log<>nil) then begin
       Log.Add('');
       Log.Add('!Исключение WsException');
       Log.Add(Format('FaultActor  =%s', [WsException(E).FaultActor]));
       Log.Add(Format('FaultCode   =%s', [WsException(E).FaultCode]));
       Log.Add(Format('FaultDetail =%s', [WsException(E).FaultDetail]));
       Log.Add(Format('Message     =%s', [WsException(E).Message]));
       Log.Add(Format('ClassName   =%s', [WsException(E).ClassName]));
     end;
     MessageCoverToLog(Log, WsException(E).cover);
     ErrorListToLog(Log, WsException(E).error_list);
     //обработка исключения
     CopyErrorList(WsException(E).error_list);
   end
   else if E is ERemotableException then begin
      if EnabledLog and (Log<>nil) then begin
        Log.Add('');
        Log.Add('!Исключение ERemotableException');
        Log.Add(Format('FaultActor  =%s', [ERemotableException(E).FaultActor]));
        Log.Add(Format('FaultCode   =%s', [ERemotableException(E).FaultCode]));
        Log.Add(Format('FaultDetail =%s', [ERemotableException(E).FaultDetail]));
        Log.Add(Format('Message     =%s', [ERemotableException(E).Message]));
        Log.Add(Format('ClassName   =%s', [ERemotableException(E).ClassName]));
      end;
      //обработка исключения
      FFaultError:=ERemotableException(E).Message;
      FaultDetailToError(ERemotableException(E).FaultDetail, FFaultError);
   end
   //!!! ESOAPHTTPException
   else begin
      if EnabledLog and (Log<>nil) then begin
        Log.Add('');
        Log.Add('!Исключение Exception');
        Log.Add(Format('Message   =%s', [E.Message]));
        Log.Add(Format('ClassName =%s', [E.ClassName]));
      end;
      //обработка исключения
      FFaultError:=E.Message;
   end;
end;

function TGisunInterface.FindNodeXML(x:TXMLNode; strFind:String):TXMLNode;
var
  n,m:Integer;
  xx,xxx:TXMLNode;
begin
  Result:=nil;
  for n:=0 to x.NodeCount-1 do begin
    xx:=x.Nodes[n];
    if Pos(strFind,LowerCase(Utf8ToAnsi(xx.Name))) >0 then begin
      Result:=xx;
    end else begin
      for m:=0 to xx.NodeCount-1 do begin
        xxx:=xx.Nodes[m];
        if Pos(strFind,LowerCase(Utf8ToAnsi(xxx.name))) >0 then begin
          Result:=xxx;
          break;
        end else begin
          xxx:=FindNodeXML(xx.Nodes[m],strFind);
          if xxx<>nil then begin
            Result:=xxx;
            break;
          end;
        end;
      end;
    end;
    if Result<>nil then break;
  end;
end;

procedure TGisunInterface.FaultDetailToError(strFaultDetail:String; strMessage:String);
var
  i,j:Integer;
  XMLDoc:TNativeXML;
  sCorr,sCode,sPlace,s1,sText,sWrong,sChName,sDesc,sIN,ss:String;
  XMLNode,XMLNodeErr,nd:TXMLNode;
  lAdd:Boolean;
 function getTeg(sTeg:String):String;
 begin
   result:='';
   try
     nd:=XMLNodeErr.FindNode(AnsiToUtf8(sTeg));
     if nd<>nil then result:=Utf8ToANSI(nd.ValueAsString);
   except
     ////
   end;
   if result='' then begin
     nd:=FindNodeXML(XMLNodeErr,':'+sTeg);
     if nd<>nil then result:=Utf8ToANSI(nd.ValueAsString);
   end;
 end;
begin
  if strFaultDetail='' then begin
    if Trim(strMessage)=''
      then FError.AppendRecord(['--','Неизвестная ошибка','','','','','',''])
      else FError.AppendRecord(['--',strMessage,'','','','','','']);
    exit;
  end;
  XMLDoc:=TNativeXML.Create;
  XMLDoc.ReadFromString(AnsiToUtf8(strFaultDetail));
  XMLNode:=FindNodeXML(XMLDoc.Root,'cover');
  if XMLNode<>nil then begin
    for i:=0 to XMLNode.NodeCount-1 do begin
      if (XMLNode.Nodes[i].Name='message_id') or (RightStr(XMLNode.Nodes[i].Name,11)=':message_id') then begin
        CoverMessageId:=Copy(XMLNode.Nodes[i].ValueAsString,2,36);
//      end else if XMLNode.Nodes[i].Name='message_time' then begin
//        CoverMessageTime:=XMLNode.Nodes[i].ValueAsDateTime;
      end;
    end;
  end;
  XMLNode:=FindNodeXML(XMLDoc.Root,'error_list');
  if XMLNode<>nil then begin
    for i:=0 to XMLNode.NodeCount-1 do begin
      XMLNodeErr:=XMLNode.Nodes[i];
      s1:=Utf8ToAnsi(XMLNodeErr.Name);   //  типа: 'ns2:error'
      j:=Pos(':error',s1);
      ss:=Copy(s1,1,j);  // типа 'ns2:'
      //------------------
      nd:=XMLNodeErr.FindNode(AnsiToUtf8('code'));
      if nd<>nil then begin
        sCode:=Utf8ToAnsi(nd.ValueAsString);
      end else begin
        nd:=FindNodeXML(XMLNodeErr,':code');
        if nd<>nil then begin
          sCode:=Utf8ToANSI(nd.ValueAsString);
        end else begin
          sCode:='';
        end;
      end;
      //------------------
      sText:='';
      nd:=XMLNodeErr.FindNode(AnsiToUtf8('lexema'));
      if nd<>nil then begin
        nd:=nd.FindNode('value');
        if nd<>nil then begin
          sText:=Utf8ToANSI(nd.ValueAsString);
        end;
      end;
      if sText='' then begin
        nd:=FindNodeXML(XMLNodeErr,':lexema');
        if nd<>nil then begin
          nd:=FindNodeXML(nd,':value');
          if nd<>nil then begin
            sText:=Utf8ToANSI(nd.ValueAsString);
          end else begin
            sText:='';  // 'ОШИБКА'
          end;
        end else begin
          sText:=''; //'ОШИБКА';
        end;
      end;
      //-------------------------------
      sWrong:=getTeg('wrong_value');  // sWrong
      sCorr:='';
      sChName:=getTeg('check_name');
      sDesc:=getTeg('description');
      sIN:=getTeg('identif');
      sPlace:=getTeg('error_place');

      //-------------------------------
      if (strMessage<>'') and (sText='') then begin
        if (sDesc='') and (sChName='')
          then sText:=strMessage;
      end;
      //--------- ошибка авторизации ----------------
//      if (sCode='08') then begin
//        nd:=FindNodeXML(XMLNode,'check_name');
//        if nd<>nil then begin
//          s2:=Utf8ToANSI(nd.ValueAsString);
//        end;
//      end;
      lAdd:=true;
      if (sPlace<>'') and (sWrong<>'') then begin
        if FError.Locate('ERROR_PLACE;WRONG_VALUE', VarArrayOf([sPlace,sWrong]), [])
          then lAdd:=false;
      end;
      if lAdd
        then FError.AppendRecord([sCode,sText,sPlace,sWrong,sCorr,sChName,sDesc,sIN]);
      {
function CreateErrorTable: TDataSet;    // mRegInt.pas
begin

   Result:=CreateMemTable([
      'ERROR_CODE',    Integer(ftString),    10,  //Тип ошибки
      'ERROR_TEXT',    Integer(ftString),   250,  //Текст ошибки
      'ERROR_PLACE',   Integer(ftString),   250,  //Место возникновения ошибки
      'WRONG_VALUE',   Integer(ftString),   250,  //Неправильное значение
      'CORRECT_VALUE', Integer(ftString),   250,  //Правильное значение
      'CHECK_NAME',    Integer(ftString),   250,  //Название проверяемого элемента
      'DESCRIPTION',   Integer(ftString),   500,  //
      'IDENTIF',       Integer(ftString),   50    //
   ], True, True);
end;
      }
    end;
  end else begin
    FError.AppendRecord(['--','Неизвестная ошибка','','','','','','']);
  end;
  XMLDoc.Free;
end;

procedure TGisunInterface.SetUrl(Value: string);
begin
   if CompareText(FUrl, Value)<>0 then begin
      FUrl:=Value;
   end;
end;

procedure TGisunInterface.ClearError;
begin
   FFaultError:='';
   FError.First;
   while not FError.Eof do FError.Delete;
end;

procedure TGisunInterface.CopyErrorList(error_list: ErrorList);
var
   I: Integer;
   lAdd:Boolean;
begin
   for I:=Low(error_list) to High(error_list) do begin
      lAdd:=true;
      if (error_list[I].error_place<>'') and (error_list[I].wrong_value<>'') then begin
        if FError.Locate('ERROR_PLACE;WRONG_VALUE', VarArrayOf([error_list[I].error_place,error_list[I].wrong_value]), [])
          then lAdd:=false;
      end;
      if lAdd then begin
        FError.Append;
        //Тип ошибки
        FError.FieldByName('ERROR_CODE').AsString:=GetClassifierCode(error_list[I].error_code);
        //Текст ошибки
        FError.FieldByName('ERROR_TEXT').AsString:=GetClassifierLexema(error_list[I].error_code);
        //Место возникновения ошибки
        FError.FieldByName('ERROR_PLACE').AsString:=error_list[I].error_place;
        //Неправильное значение
        FError.FieldByName('WRONG_VALUE').AsString:=error_list[I].wrong_value;
        //Правильное значение
        FError.FieldByName('CORRECT_VALUE').AsString:=error_list[I].correct_value;
        //Название проверяемого элемента
        FError.FieldByName('CHECK_NAME').AsString:=error_list[I].check_name;
        //
        FError.FieldByName('DESCRIPTION').AsString:=error_list[I].description;
        //
        FError.FieldByName('IDENTIF').AsString:=error_list[I].identif;
        FError.Post;
      end;
   end;
end;

class procedure TGisunInterface.DocumentToLog(Log: TStrings; Doc: Document; Add: string);
begin
   if Doc<>nil then begin
      Log.Add(Format(Add+'access        =%s', [GetClassifierString(Doc.access)]));
      Log.Add(Format(Add+'document_type =%s', [GetClassifierString(Doc.document_type)]));
      Log.Add(Format(Add+'authority     =%s', [GetClassifierString(Doc.authority)]));
      Log.Add(Format(Add+'date_of_issue =%s', [GetDateString(Doc.date_of_issue)]));
      Log.Add(Format(Add+'expire_date   =%s', [GetDateString(Doc.expire_date)]));
      Log.Add(Format(Add+'series        =%s', [Doc.series]));
      Log.Add(Format(Add+'number        =%s', [Doc.number]));
      if Doc.act_data<>nil then begin
         Log.Add(Format(Add+'act_data/act_type  =%s', [GetClassifierString(Doc.act_data.act_type)]));
         Log.Add(Format(Add+'act_data/authority =%s', [GetClassifierString(Doc.act_data.authority)]));
         Log.Add(Format(Add+'act_data/date      =%s', [GetDateString(Doc.act_data.date)]));
         Log.Add(Format(Add+'act_data/number    =%s', [Doc.act_data.number]));
      end
      else begin
         Log.Add(Add+'act_data      =nil');
      end;
      Log.Add(Format(Add+'active        =%s', [MapBool[Doc.active]]));
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.AddressToLog(Log: TStrings; Adr: Address; Add: string);
begin
   if Adr<>nil then begin
      Log.Add(Format(Add+'access        =%s', [GetClassifierString(Adr.access)]));
      Log.Add(Format(Add+'country       =%s', [GetClassifierString(Adr.country)]));
      Log.Add(Format(Add+'area          =%s', [GetClassifierString(Adr.area)]));
      Log.Add(Format(Add+'region        =%s', [GetClassifierString(Adr.region)]));
      Log.Add(Format(Add+'soviet        =%s', [GetClassifierString(Adr.soviet)]));
      Log.Add(Format(Add+'locality_type =%s', [GetClassifierString(Adr.locality_type)]));
      Log.Add(Format(Add+'locality      =%s', [GetClassifierString(Adr.locality)]));
      Log.Add(Format(Add+'city_region   =%s', [GetClassifierString(Adr.city_region)]));
      Log.Add(Format(Add+'street_type   =%s', [GetClassifierString(Adr.street_type)]));
      Log.Add(Format(Add+'street        =%s', [GetClassifierString(Adr.street)]));
      Log.Add(Format(Add+'house         =%s', [Adr.house]));
      Log.Add(Format(Add+'building      =%s', [Adr.building]));
      Log.Add(Format(Add+'flat          =%s', [Adr.flat]));
      Log.Add(Format(Add+'reg_date      =%s', [GetDateString(Adr.reg_date)]));
      Log.Add(Format(Add+'reg_date_till =%s', [GetDateString(Adr.reg_date_till)]));
      Log.Add(Format(Add+'sign_away     =%s', [MapBool[Adr.sign_away]]));
      Log.Add(Format(Add+'active        =%s', [MapBool[Adr.active]]));
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.FamilyDataToLog(Log: TStrings; Family: FamilyData; Add: string);
var
   I: Integer;
begin
   if Family<>nil then begin
      FamilyInfoToLog(Log, Family.father, Add+'father/');
      FamilyInfoToLog(Log, Family.mather, Add+'mather/');
      FamilyInfoToLog(Log, Family.wife, Add+'wife/');
      FamilyInfoToLog(Log, Family.husband, Add+'husband/');
      if Length(Family.child)<>0 then begin
         for I:=Low(Family.child) to High(Family.child) do begin
            FamilyInfoToLog(Log, Family.child[I], Format(Add+'child[%d]/', [I]));
         end;
      end
      else begin
         Log.Add(Add+'child (0)');
      end;
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.DeathInfoToLog(Log: TStrings; D: DeathInfo; Add: string);
var
   I: Integer;
begin
   if D<>nil then begin
      DeathToLog(Log, D.death_data, Add+'death_data/');
      if Length(D.documents)<>0 then begin
         for I:=Low(D.documents) to High(D.documents) do begin
            DocumentToLog(Log, D.documents[I], Format(Add+'documents[%d]/', [I]));
         end;
      end
      else begin
         Log.Add(Add+'documents (0)');
      end;
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.DeathToLog(Log: TStrings; D: Death; Add: string);
begin
   if D<>nil then begin
      Log.Add(Format(Add+'access      =%s', [GetClassifierString(D.access)]));
      Log.Add(Format(Add+'death_cause =%s', [GetClassifierString(D.death_cause)]));
      Log.Add(Format(Add+'death_date  =%s', [D.death_date]));
      if D.decease_place<>nil then begin
         Log.Add(Format(Add+'decease_place/country_d    =%s', [GetClassifierString(D.decease_place.country_d)]));
         Log.Add(Format(Add+'decease_place/area_d       =%s', [D.decease_place.area_d]));
         Log.Add(Format(Add+'decease_place/area_d_bel   =%s', [D.decease_place.area_d_bel]));
         Log.Add(Format(Add+'decease_place/region_d     =%s', [D.decease_place.region_d]));
         Log.Add(Format(Add+'decease_place/region_d_bel =%s', [D.decease_place.region_d_bel]));
         Log.Add(Format(Add+'decease_place/type_city_d  =%s', [GetClassifierString(D.decease_place.type_city_d)]));
         Log.Add(Format(Add+'decease_place/city_d       =%s', [D.decease_place.city_d]));
         Log.Add(Format(Add+'decease_place/city_d_bel   =%s', [D.decease_place.city_d_bel]));
      end
      else begin
         Log.Add(Add+'decease_place=nil');
      end;
      Log.Add(Format(Add+'death_place  =%s', [D.death_place]));
      Log.Add(Format(Add+'burial_place =%s', [D.burial_place]));
      Log.Add(Format(Add+'active       =%s', [MapBool[D.active]]));
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

function TGisunInterface.GetClassifierCode(C: Classifier): string;
begin
   Result:='';
   if (C<>nil) then begin
      Result:=C.code;
   end;
end;

function TGisunInterface.GetClassifierLexema(C: Classifier): string;
begin
   Result:='';
   if (C<>nil) and (Length(C.lexema)>0) then begin
//      Result:=C.lexema[0].lang
      Result:=C.lexema[0].Text;
   end;
end;

class procedure TGisunInterface.CitizenshipToLog(Log: TStrings; C: Citizenship; Add: string);
begin
   if C<>nil then begin
      Log.Add(Format(Add+'access             =%s', [GetClassifierString(C.access)]));
      Log.Add(Format(Add+'citizenship_change =%s', [GetClassifierString(C.citizenship_change)]));
      Log.Add(Format(Add+'citizenship_type   =%s', [GetClassifierString(C.citizenship_type)]));
      Log.Add(Format(Add+'date_citizenship   =%s', [GetDateTimeString(C.date_citizenship)]));
      Log.Add(Format(Add+'active             =%s', [MapBool[C.active]]));
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.PensionToLog(Log: TStrings; P: Pension; Add: string);
begin
   if P<>nil then begin
      Log.Add(Format(Add+'access                  =%s', [GetClassifierString(P.access)]));
      Log.Add(Format(Add+'pension_type            =%s', [GetClassifierString(P.pension_type)]));
      Log.Add(Format(Add+'pension_awarding_date   =%s', [GetDateString(P.pension_awarding_date)]));
      Log.Add(Format(Add+'pension_suspension_date =%s', [GetDateString(P.pension_suspension_date)]));
      Log.Add(Format(Add+'active                  =%d', [P.active]));
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

function TGisunInterface.CreateRegisterPersonIdentifRequest(MessageType: string): register_person_identif_request;
begin
   //Запрос на получение данных из регистра по ф.и.о.
   Result:=register_person_identif_request.Create;
   //Заголовок запроса - сопроводительная информация к сообщению
   Result.cover:=CreateMessageCover(MessageType, '');
   //Запрос на получение персональных данных - ф.и.о. и дата рождения
   Result.request:=PersonIdentifRequest.Create;
   //Идентификатор запроса
   Result.request.request_id:=CreateId;
end;

function TGisunInterface.GetPersonIdentif(const registerPersonIdentifRequest: register_person_identif_request; var registerResponse: register_response; Log: TStrings; User, Pasw: string): Boolean;
var
   I: Integer;
   hdr: TSOAPHeader;
   Headers: ISOAPHeaders;
begin
   ClearError;
   Result:=False;
   try
      if GetService<>nil then begin
         if EnabledLog then begin
           Log.Add('');
           Log.Add('Выполняется запрос на получение данных из регистра:');
           Log.Add('');
           MessageCoverToLog(Log, registerPersonIdentifRequest.cover);
           Log.Add('');
           Log.Add('Запрос на получение пресональных данных register_person_identif_request:');
           Log.Add('');
           Log.Add(Format('register_person_identif_request/request_id =%s', [registerPersonIdentifRequest.request.request_id]));
           Log.Add(Format('register_person_identif_request/surname    =%s', [registerPersonIdentifRequest.request.surname]));
           Log.Add(Format('register_person_identif_request/name_      =%s', [registerPersonIdentifRequest.request.name_]));
           Log.Add(Format('register_person_identif_request/sname      =%s', [registerPersonIdentifRequest.request.sname]));
           Log.Add(Format('register_person_identif_request/bdate      =%s', [registerPersonIdentifRequest.request.bdate]));
         end;
         //выполнение запроса

         hdr:=nil;
         {$IFDEF MY_PROJECT}
         if IsCreateHeader then begin
         {$ELSE}
         if (User<>'') and (Pasw<>'') then begin
         {$ENDIF}
            hdr:=CreateHeader(User, Pasw);
            Headers:=FFService as ISOAPHeaders;
            Headers.Send(hdr);
         end;

         FCurLog:=Log;
         CoverMessageId:='';
//         CoverMessageTime:=0;
         registerResponse:=FFService.getPersonIdentif(registerPersonIdentifRequest);
         FCurLog:=nil;

         hdr.Free;
         if registerResponse<>nil then begin
           CoverMessageId:=Copy(registerResponse.cover.message_id,2,36);  //ID сообщения ответа
//           CoverMessageTime:=registerResponse.cover.message_time.AsDateTime;//время сообщения ответа
         end;

        if EnabledLog then begin
           Log.Add('');
           Log.Add('Получен ответ:');
           Log.Add('');
           MessageCoverToLog(Log, registerResponse.cover);
           Log.Add('');
           Log.Add(Format('Список персональных данных personal_data (%d):', [Length(registerResponse.response.personal_data)]));
           for I:=Low(registerResponse.response.personal_data) to High(registerResponse.response.personal_data) do begin
              Log.Add('');
              Log.Add(Format('personal_data/request_id =%s', [registerResponse.response.personal_data[I].request_id]));
              PersonalDataToLog(Log, registerResponse.response.personal_data[I].data, 'personal_data/');
           end;
         end;
         Result:=True;
      end
      else begin
         if EnabledLog then
           Log.Add('ОШИБКА: GetService=nil');
      end;
   except
      on E: Exception do begin
         HandleException(E, Log);
      end;
   end;
end;

procedure TGisunInterface.UpdateUrl(Value: string);
begin
   if FFService<>nil then begin
      FRIO.URL:=Value;
   end;
end;

class procedure TGisunInterface.FamilyInfoToLog(Log: TStrings; Family: FamilyInfo; Add: string);
var
   I: Integer;
begin
   if Family<>nil then begin
      PersonalDataToLog(Log, Family.person_data, Add+'person_data/');
      if Length(Family.documents)<>0 then begin
         for I:=Low(Family.documents) to High(Family.documents) do begin
            DocumentToLog(Log, Family.documents[I], Format(Add+'documents[%d]/', [I]));
         end;
      end
      else begin
         Log.Add(Add+'documents (0)');
      end;
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.PhotoToLog(Log: TStrings; P: PhotoInfo; Add: string);
var
   I: Integer;
begin
   if P<>nil then begin
      //photo: TByteDynArray
      if Length(P.documents)<>0 then begin
         for I:=Low(P.documents) to High(P.documents) do begin
            DocumentToLog(Log, P.documents[I], Format(Add+'documents[%d]/', [I]));
         end;
      end
      else begin
         Log.Add(Add+'documents (0)');
      end;
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.CourtListToLog(Log: TStrings; C: CourtList; Add: string);
var
   I: Integer;
begin
//{     необходимо исправлять
   try
     if C<>nil then begin
        if Length(C.deaths)<>0 then begin
           for I:=Low(C.deaths) to High(C.deaths) do begin
              Log.Add(Format(Add+'deaths[%d]/death_data/death_date        =%s', [I, GetDateString(C.deaths[I].death_data.death_date)]));
              Log.Add(Format(Add+'deaths[%d]/death_data/death_date_cancel =%s', [I, GetDateString(C.deaths[I].death_data.death_date_cancel)]));
           end;
        end
        else begin
           Log.Add(Add+'deaths (0)');
        end;

        if Length(C.absents)<>0 then begin
           for I:=Low(C.absents) to High(C.absents) do begin
              Log.Add(Format(Add+'absents[%d]/absent_data/absent_date        =%s', [I, GetDateString(C.absents[I].absent_data.absent_date)]));
              Log.Add(Format(Add+'absents[%d]/absent_data/absent_date_cancel =%s', [I, GetDateString(C.absents[I].absent_data.absent_date_cancel)]));
           end;
        end
        else begin
           Log.Add(Add+'absents (0)');
        end;

        if Length(C.unefficients)<>0 then begin
           for I:=Low(C.unefficients) to High(C.unefficients) do begin
              Log.Add(Format(Add+'unefficients[%d]/unefficient_data/unefficient_date        =%s', [I, GetDateString(C.unefficients[I].unefficient_data.unefficient_date)]));
              Log.Add(Format(Add+'unefficients[%d]/unefficient_data/unefficient_date_cancel =%s', [I, GetDateString(C.unefficients[I].unefficient_data.unefficient_date_cancel)]));
           end;
        end
        else begin
           Log.Add(Add+'unefficients (0)');
        end;

        if Length(C.restrict_efficients)<>0 then begin
           for I:=Low(C.restrict_efficients) to High(C.restrict_efficients) do begin
              Log.Add(Format(Add+'restrict_efficients[%d]/restrict_unefficient_date        =%s', [I, GetDateString(C.restrict_efficients[I].restrict_efficient_data.restrict_unefficient_date)]));
              Log.Add(Format(Add+'restrict_efficients[%d]/restrict_unefficient_date_cancel =%s', [I, GetDateString(C.restrict_efficients[I].restrict_efficient_data.restrict_unefficient_date_cancel)]));
           end;
        end
        else begin
           Log.Add(Add+'restrict_efficients (0)');
        end;

     end
     else begin
        Log.Add(Add+' =nil');
     end;
   except
     on E: sysutils.Exception do begin
       Log.Add(Add+'=error:'+E.Message);
     end;
   end;
 //  }
end;

class procedure TGisunInterface.EducationInfoToLog(Log: TStrings; E: EducationInfo; Add: string);
var
   I: Integer;
begin
{
   if E<>nil then begin
      EducationToLog(Log, E.education_data, Add+'education_data/');
      if Length(E.documents)<>0 then begin
         for I:=Low(E.documents) to High(E.documents) do begin
            DocumentToLog(Log, E.documents[I], Format(Add+'documents[%d]/', [I]));
         end;
      end
      else begin
         Log.Add(Add+'documents (0)');
      end;
   end
   else begin
      Log.Add(Add+' =nil');
   end;
   }
end;

class procedure TGisunInterface.EducationToLog(Log: TStrings; E: Education; Add: string);
begin
   if E<>nil then begin
      Log.Add(Format(Add+'access                   =%s', [GetClassifierString(E.access)]));
      Log.Add(Format(Add+'education_specialization =%s', [GetClassifierString(E.education_specialization)]));
      Log.Add(Format(Add+'education_department     =%s', [GetClassifierString(E.education_department)]));
      Log.Add(Format(Add+'education_begin_data     =%s', [GetDateString(E.education_begin_data)]));
      Log.Add(Format(Add+'education_end_data       =%s', [GetDateString(E.education_end_data)]));
      Log.Add(Format(Add+'education_record_number  =%d', [E.education_record_number]));
      Log.Add(Format(Add+'active                   =%s', [MapBool[E.active]]));
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.ScienceRankInfoToLog(Log: TStrings; R: ScienceRankInfo; Add: string);
var
   I: Integer;
begin
   if R<>nil then begin
      ScienceRankToLog(Log, R.science_rank_data, Add+'science_rank_data/');
      if Length(R.documents)<>0 then begin
         for I:=Low(R.documents) to High(R.documents) do begin
            DocumentToLog(Log, R.documents[I], Format(Add+'documents[%d]/', [I]));
         end;
      end
      else begin
         Log.Add(Add+'documents (0)');
      end;
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.ScienceRankToLog(Log: TStrings; R: ScienceRank; Add: string);
begin
   if R<>nil then begin
      Log.Add(Format(Add+'access               =%s', [GetClassifierString(R.access)]));
      Log.Add(Format(Add+'science_rank         =%s', [GetClassifierString(R.science_rank)]));
      Log.Add(Format(Add+'science_rank_date    =%s', [GetDateString(R.science_rank_date)]));
      Log.Add(Format(Add+'science_rank_number  =%s', [R.science_rank_number]));
      Log.Add(Format(Add+'active               =%s', [MapBool[R.active]]));
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.InsuranceInfoToLog(Log: TStrings; I: InsuranceInfo; Add: string);
var
   J: Integer;
begin
   if I<>nil then begin
      InsuranceToLog(Log, I.insurance_data, Add+'insurance_data/');
      if Length(I.documents)<>0 then begin
         for J:=Low(I.documents) to High(I.documents) do begin
            DocumentToLog(Log, I.documents[J], Format(Add+'documents[%d]/', [J]));
         end;
      end
      else begin
         Log.Add(Add+'documents (0)');
      end;
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.InsuranceToLog(Log: TStrings; I: Insurance; Add: string);
begin
   if I<>nil then begin
      Log.Add(Format(Add+'access                     =%s', [GetClassifierString(I.access)]));
      Log.Add(Format(Add+'insurance_awarding_date    =%s', [GetDateString(I.insurance_awarding_date)]));
      Log.Add(Format(Add+'insurance_suspension_date  =%s', [I.insurance_suspension_date]));
      Log.Add(Format(Add+'active                     =%s', [MapBool[I.active]]));
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.MilitaryInfoToLog(Log: TStrings; M: MilitaryInfo; Add: string);
var
   I: Integer;
begin
   if M<>nil then begin
      MilitaryToLog(Log, M.military_data, Add+'military_data/');
      if Length(M.documents)<>0 then begin
         for I:=Low(M.documents) to High(M.documents) do begin
            DocumentToLog(Log, M.documents[I], Format(Add+'documents[%d]/', [I]));
         end;
      end
      else begin
         Log.Add(Add+'documents (0)');
      end;
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.MilitaryToLog(Log: TStrings; M: Military; Add: string);
begin
   if M<>nil then begin
      Log.Add(Format(Add+'access                           =%s', [GetClassifierString(M.access)]));
      Log.Add(Format(Add+'military_service_awarding_date   =%s', [GetDateString(M.military_service_awarding_date)]));
      Log.Add(Format(Add+'military_service_suspension_date =%s', [GetDateString(M.military_service_suspension_date)]));
      Log.Add(Format(Add+'active                           =%s', [IntToStr(M.active)]));
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.ScienceDegreeInfoToLog(Log: TStrings; D: ScienceDegreeInfo; Add: string);
var
   I: Integer;
begin
   if D<>nil then begin
      ScienceDegreeToLog(Log, D.science_degree_data, Add+'science_degree_data/');
      if Length(D.documents)<>0 then begin
         for I:=Low(D.documents) to High(D.documents) do begin
            DocumentToLog(Log, D.documents[I], Format(Add+'documents[%d]/', [I]));
         end;
      end
      else begin
         Log.Add(Add+'documents (0)');
      end;
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.ScienceDegreeToLog(Log: TStrings; D: ScienceDegree; Add: string);
begin
   if D<>nil then begin
      Log.Add(Format(Add+'access                =%s', [GetClassifierString(D.access)]));
      Log.Add(Format(Add+'science_degree        =%s', [GetClassifierString(D.science_degree)]));
      Log.Add(Format(Add+'science_degree_date   =%s', [GetDateString(D.science_degree_date)]));
      Log.Add(Format(Add+'science_degree_number =%s', [D.science_degree_number]));
      Log.Add(Format(Add+'active                =%s', [MapBool[D.active]]));
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.TaxInfoToLog(Log: TStrings; T: TaxInfo; Add: string);
var
   I: Integer;
begin
   if T<>nil then begin
      TaxToLog(Log, T.tax_data, Add+'tax_data/');
      if Length(T.documents)<>0 then begin
         for I:=Low(T.documents) to High(T.documents) do begin
            DocumentToLog(Log, T.documents[I], Format(Add+'documents[%d]/', [I]));
         end;
      end
      else begin
         Log.Add(Add+'documents (0)');
      end;
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.TaxToLog(Log: TStrings; T: Tax; Add: string);
begin
   if T<>nil then begin
      Log.Add(Format(Add+'access             =%s', [GetClassifierString(T.access)]));
      Log.Add(Format(Add+'tax_awarding_date  =%s', [GetDateString(T.tax_awarding_date)]));
      Log.Add(Format(Add+'tax_number         =%s', [T.tax_number]));
      Log.Add(Format(Add+'tax_debt_data      =%d', [T.tax_debt_data]));
      Log.Add(Format(Add+'active             =%d', [T.active]));
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;

class procedure TGisunInterface.PensionInfoToLog(Log: TStrings; P: PensionInfo; Add: string);
var
   I: Integer;
begin
   if P<>nil then begin
      PensionToLog(Log, P.pension_data, Add+'pension_data/');
      if Length(P.documents)<>0 then begin
         for I:=Low(P.documents) to High(P.documents) do begin
            DocumentToLog(Log, P.documents[I], Format(Add+'documents[%d]/', [I]));
         end;
      end
      else begin
         Log.Add(Add+'documents (0)');
      end;
   end
   else begin
      Log.Add(Add+' =nil');
   end;
end;


//----------------------------------------------------------------------------------------------------
function TGisunInterface.RequestChangeClassif(nType: Integer;  dDateFrom: TDateTime; dsResult:TDataSet; Log:TStrings): Boolean;
var
   i,j: Integer;
   ss,sType:String;
   d:TXSDateTime;
{   clRequest:cl_request;
   clChange:cl_changes;
   r:ClRequestData;  }
   clRequest : getClassifierChange;
   clChange,res  : getClassifierChangeResponse;
   c:MessageCover;
   hdr: TSOAPHeader;
   Headers: ISOAPHeaders;
begin          
  Result := false;
  ClearError;
  try
    if GetService<>nil then begin
      Result := true;
      sType:=IntToStr(nType);
//      WriteTextLog('['+sType+'] запрос изменений с '+DatePropis(dDateFrom,3),LOG_GISUN);
      clRequest:=getClassifierChange.Create;
      clRequest.type_ := nType;
      d:=TXSDateTime.Create;
      d.AsDateTime:=dDateFrom;
      clRequest.date:=d;             

//      WriteTextLog('['+sType+'] выполнение getClassifierChange',LOG_GISUN);
      clChange:=Service.getClassifierChange(clRequest);
      {
      ClRequest.cover:=CreateMessageCover(sType, '', nType,nType);
      ClRequest.request:=r;

      hdr:=nil;

      if IsCreateHeader then begin
//      if (FUser<>'') and (FPasw<>'') then begin
         gisun.WriteTextLog('['+sType+'] CreateHeader',LOG_GISUN);
         hdr:=CreateHeader(FUser, FPasw, true);
         Headers:=FService as ISOAPHeaders;
         Headers.Send(hdr);
      end;
      gisun.WriteTextLog('['+sType+'] выполнение findClChanges',LOG_GISUN);
      clChange:=Service.findClChanges(clRequest);

      hdr.Free;
      }

      if (clChange<>nil)  then begin
        if Length(clChange)>0 then begin
          res:=clChange;
          Application.ProcessMessages;
//        gisun.WriteTextLog('['+sType+'] получено изменений ' + InttoStr(High(res)),LOG_GISUN);
//      ShowMessage(ClChange.cover.message_id+'   '+intToStr(High(res)));
          for I:=Low(res) to High(res) do begin
            dsResult.Append;
{
    property code:       WideString      Index (IS_OPTN) read Fcode write Setcode stored code_Specified;
    property type_:      Integer         Index (IS_OPTN) read Ftype_ write Settype_ stored type__Specified;
    property lexema:     LangValueList   Index (IS_OPTN) read Flexema write Setlexema stored lexema_Specified;
    property active:     Boolean         Index (IS_OPTN) read Factive write Setactive stored active_Specified;
    property begin_date: TXSDateTime     Index (IS_OPTN) read Fbegin_date write Setbegin_date stored begin_date_Specified;
    property end_date:   TXSDateTime     Index (IS_OPTN) read Fend_date write Setend_date stored end_date_Specified;
    property parents:    ClassifierList  Index (IS_OPTN) read Fparents write Setparents stored parents_Specified;
}
            dsResult.FieldByName('TYPESPR').AsInteger:=nType;
            dsResult.FieldByName('EXTCODE').AsString:=res[i].Code;
            for j:=Low(res[i].lexema) to High(res[i].lexema) do begin
              if j=0 then begin
                dsResult.FieldByName('LEX1').AsString:=res[i].lexema[0].Text;
              end else if j=1 then begin
                dsResult.FieldByName('LEX2').AsString:=res[i].lexema[1].Text;
              end else if j=2 then begin
                dsResult.FieldByName('LEX3').AsString:=res[i].lexema[2].Text;
              end else begin
               //Label3.Caption:='ERROR';      !!!!!
              end;
            end;
            dsResult.FieldByName('PARENT').AsString:=IntToStr(Length(res[i].parents));
            dsResult.FieldByName('EXTTYPE').AsString:=IntToStr(res[i].type_);
            dsResult.FieldByName('Active').AsBoolean:=res[i].active;
            if res[i].begin_date<>nil then dsResult.FieldByName('BEGINDATE').AsDateTime:=res[i].begin_date.AsDateTime;
            if res[i].end_date<>nil then dsResult.FieldByName('ENDDATE').AsDateTime:=res[i].end_date.AsDateTime;
            dsResult.Post;
          end;
          Result:=true;
        end else begin

        end;
      end else begin
//        gisun.WriteTextLog('['+sType+'] изменения не получены',LOG_GISUN);
      end;

      ClRequest.Free;
      SetLength(ClChange,0);
    end else begin
      FFaultError:='Ошибка подключение к сервису справочников';
      Result:=false;
    end;
  except
    on E: sysutils.Exception do begin
      Result:=false;
      HandleException(E,Log);
    end;
  end;
end;


end.//TGisunInterface
