unit uGetSrvX;

interface

uses
  Classes,
  wsGisun,
  mGisun,
  uRestClient;

type
  TGetSrvX = class(TGisunInterface)
  private
    FRestClient : TRestClient;
  protected
    //получение ссылки не сервис
    function GetService: TRestClient; reintroduce;
  public
    function GetPersonIdentif(const registerPersonIdentifRequest: register_person_identif_request; var registerResponse: register_response; Log: TStrings; User, Pasw: string): Boolean; override;

  end;


implementation

uses
  SysUtils;

function TGetSrvX.GetService: TRestClient;
begin
  Result := nil;
end;

//
function TGetSrvX.GetPersonIdentif(const registerPersonIdentifRequest: register_person_identif_request; var registerResponse: register_response; Log: TStrings; User, Pasw: string): Boolean;
var
   I: Integer;
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


         FCurLog:=Log;
         CoverMessageId:='';
//         CoverMessageTime:=0;
         registerResponse:=FFService.getPersonIdentif(registerPersonIdentifRequest);
         FCurLog:=nil;

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





end.
