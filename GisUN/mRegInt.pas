unit mRegInt;

interface

{$I Task.inc}

uses
   Windows, Classes, SysUtils, Graphics, ActiveX, DB, Forms, ImgList, Controls, FuncPr, MetaTask, uTypes,
   {$IFDEF GIS_THREAD} TasksEx, AsyncCalls, {$ENDIF}
   Dialogs, StdCtrls, ExtCtrls, ShellApi, ComObj, Messages, TypInfo, mPermit, uPadegFIO,
   {$IFDEF ADD_WS_LOCAL}
     mLocal, wsLocal,
   {$ENDIF}
   uGetSrvX,
   kbmMemTable, mZags, wsZags, mGisun, wsGisun, XSBuiltIns;

type

//   0-all  1=deaths  2=absents 3=unefficients 4=restrict_efficients
//   1=Данные об объявлении физического лица умершим, об отмене соответствующего решения (Суды)
//   2=Данные о признании физического лица безвестно отсутствующим, об отмене соответствующего решения
//   3=Данные о признании физического лица недееспособным, об отмене соответствующего решения
//   4=Данные о признании физического лица ограниченно дееспособным, об отмене соответствующего решения
//   5=!!! Брак расторгнут                 getMartialStatus
//   6=!!! Брак признан недействительным   getMartialStatus
   TOneReshSud = ( rsDeaths, rsAbsents, rsUneff, rsRestrict, rsRastBrak, rsInvalidBrak );
   TListReshSud = set of TOneReshSud;

   TPersonalData_ = wsGisun.PersonalData;
   TDocument_= wsGisun.document2;
//   TArrDocuments_= array of wsGisun.document2; //wsGisun.document17;
   TLangValueList_ = wsGisun.LangValueList;

   TMartialStatus=record
     Status:Integer;
     NameStatus:String;
     TypeResh:Integer;
     Prefix:String;
     FIO:String;
     Text:String;
     Organ:String;
     Date:TDateTime;
     Doc:String;  // только инфа о документе для ON_SEM_DOK  ONA_SEM_DOK
   end;

   TRegDocument=record
     Active:Boolean;
     TypeName:String;
     TypeID:String;
     TypeSpr:Integer;
     AuthorName:String;
     AuthorID:String;
     AuthorSpr:Integer;
     DateIssue:TDateTime;
     DateExpire:TDateTime;
     Number:String;
     Seria:String;
   end;

   TObrPersonalData = procedure(data: TPersonalData_; dsOutPut:TDataSet; dsDokument:TDataSet; slPar:TStringList) of object;

   //Возможные результаты взаимодействия с регистром населения
   TRequestResult=(
      //До выполнения взаимодействия с регистром произошла непредвиденная ошибка
      //или ошибку обнаружила наша программа (например, во входных данных)
      rrBeforeError,
      //Произошёл обмен данными с регистром и при этом регистр не вернул ошибок
      rrOk,
      //Произошёл обмен данным с регистром, но регистр вернул ошибки
      rrError,
      //После обмена данными с регистром произошла непредвиденная ошибка
      //или ошибки обнаружила наша программа (например, в полученных из регистра данных)
      rrAfterError,
      //Не произошло взаимодействия с регистром в результате какого-либо сбоя
      //или отсутствия связи
      rrFault
   );

   //Типы актовых записей/запросов к регистру
   TActKind=(
      //Запрос на получение персональных данных (по идентификатору)
      akGetPersonalData,
      //Запрос на получение персональных данных (по ф.и.о.)
      akGetPersonIdentif,
      //Актовая запись о рождении
      akBirth,
      //Актовая запись об установлении отцовства
      akAffiliation,
      //Актовая запись о заключении брака
      akMarriage,
      //Актовая запись о смерти
      akDecease,
      //Актовая запись о расторжении брака
      akDivorce,
      //Актовая запись об усыновлении (удочерении)
      akAdoption,
      //Актовая запись о перемени имени
      akNameChange,
      //Информация об опеке
      akOpeka,
      //Информация о попечительстве
      akPopech,
      //Информация о захоронении
      akZah
   );

const
   //Типы сообщений (MessageCover.message_type)
   CMessageType: array [TActKind] of string=(
      //??? !!! существует ли такой тип
      '0001',   //Запрос на получение персональных данных по идентификатору (akGetPersonalData)
      '0001',   //Запрос на получение персональных данных по ф.и.о. (akGetPersonIdentif)
      '0100',   //Актовая запись о рождении (akBirth)
      '0200',   //Актовая запись об установлении отцовства (akAffiliation)  !!!  '0800' уст. материнства  !!!
      '0300',   //Актовая запись о заключении брака (akMarriage)
      '0400',   //Актовая запись о смерти (akDecease)
      '0500',   //Актовая запись о расторжении брака (akDivorce)
      '0600',   //Актовая запись об усыновлении (удочерении) (akAdoption)
      '0700',    //Актовая запись о перемени имени (akNameChange)
      '0100',    //akOpeka  ???  !!!   неизвестно
      '0100',    //akPopech    ???  !!!   неизвестно
      '0100'     //akZah    ???  !!!   неизвестно
   );

  USTMAT_MESSAGE_TYPE='0800';

type
   //Виды операций по обмену данными с регистром
   TOperation=(
      //Получение данных
      opGet,
      //Передача данных
      opPost
   );

   TRegField=class(TObject)
   private
      FName: string;
      FDataType: TFieldType;
      FSize: Integer;
      FComm: string;
      FGrupComm: string;
      FPath: string;
   public
      constructor Create;
      destructor Destroy; override;
   public
      property Name: string read FName write FName;
      property DataType: TFieldType read FDataType write FDataType;
      property Size: Integer read FSize write FSize;
      property Comm: string read FComm write FComm;
      property GrupComm: string read FGrupComm write FGrupComm;
      property Path: string read FPath write FPath;
   end;

   TRegFieldList=class(TObject)
   private
      FList: TList;
   private
      function GetCount: Integer;
      function GetItem(I: Integer): TRegField;
   public
      constructor Create;
      destructor Destroy; override;
      procedure Clear;
      function Add(Item: TRegField): Integer;
      function AddNew: TRegField;
      function GetByName(Name: string): TRegField;
   public
      property Count: Integer read GetCount;
      property Item[I: Integer]: TRegField read GetItem; default;
   end;

   TRegTable=class(TObject)
   private
      FComm: string;
      FIsInput: Boolean;
      FActKind: TActKind;
      FOperation: TOperation;
      FFieldList: TRegFieldList;
   public
      constructor Create;
      destructor Destroy; override;
      function CreateMemTable: TDataSet;
      function SetProp(Root: TObject; DataSet: TDataSet): Boolean;
      function GetProp(Root: TObject; DataSet: TDataSet): Boolean;
      procedure ChangePath(sOldPath,sNewPath:String);
   public
      property FieldList: TRegFieldList read FFieldList;
      property Comm: string read FComm write FComm;
      property IsInput: Boolean read FIsInput write FIsInput;
      property ActKind: TActKind read FActKind write FActKind;
      property Operation: TOperation read FOperation write FOperation;
   end;

   TRegTableList=class(TObject)
   private
      FList: TList;
   private
      function GetCount: Integer;
      function GetItem(I: Integer): TRegTable;
   public
      constructor Create;
      destructor Destroy; override;
      procedure Clear;
      function Add(Item: TRegTable): Integer;
      function AddNew: TRegTable;
      function Find(IsInput: Boolean; ActKind: TActKind; Operation: TOperation): TRegTable;
   public
      property Count: Integer read GetCount;
      property Item[I: Integer]: TRegTable read GetItem; default;
   end;

   //Интерфейс для обмена с регистром населения
   TRegInt=class(TObject)
   private
      FTextLog: string;
      //
      FError07: Boolean;
      //ПАРАМЕТРЫ:
      //Орган загса/источник сообщений - должна устанавливать вызывающая программа
      //(!) Этот параметр не может оставаться пустым
      FMessageSource: string;
      //Адрес веб-сервиса для передачи информации в регистр из органов местной власти
      FLocalUrl: string;
      FLocalProxy: string;
      //Адрес веб-сервиса для передачи информации в регистр из загса

      FZagsUrl: string;
      FZagsProxy: string;
      //Адрес веб-сервиса для зпроса информации из регистра

      FGisunUrl: string;
      FGisunProxy: string;
      //Формат даты применяемый для обмена данными с регистром
      //По умолчанию yyyymmdd
      //FDateFormat: string;
      //Служебные поля:
      FLog: TStringList;
      //Список таблиц используемых для обмена данными с регистром
      FTableList: TRegTableList;
      //Переводить строки в верхний регистр при передачи в регистр
      FPostIsUpper: Boolean;
      //Версия интерфейса регистра
      FVersion: Integer;
      //Имя пользователя
      FUsername: string;
      //Пароль пользователя
      FPassword: string;
      //ПИН-код пользователя
      FPIN: string;
      FDbUserAsGIS: Boolean;
      FPostUserName: Boolean;
   private
      procedure SetDbUserAsGIS(const Value: Boolean);
      procedure SetPostUserName(const Value: Boolean);
      //
      //
      //function FormatDate(DateTime: TDateTime): string;
      procedure SetMessageSource(Value: string);
      procedure SetLocalUrl(Value: string);
      procedure SetLocalProxy(const Value: string);
      procedure SetZagsUrl(Value: string);
      procedure SetZagsProxy(const Value: string);
      procedure SetGisunUrl(Value: string);
      procedure SetGisunProxy(const Value: string);
      //function StringToDate(DateTime: string): TDateTime;
      //procedure DataSetToActData(Prefix: string; act_data: wsZags.ActData; DataSet: TDataSet);
      //procedure DataSetToDocument(Prefix: string; doc: wsZags.Document; DataSet: TDataSet);
      procedure SetPostIsUpper(const Value: Boolean);
      procedure SetVersion(const Value: Integer);
      procedure SetPIN(const Value: string);
   protected
      //Текст сбоя или ошбки для последнего сеанса взаимодействия с регистром
      FFaultError: string;
      //Идентификатор последнего сообщения запроса данных из регистра
      FRequestMessageId: string;
      //Идентификатор последнего сообщения из регистра
      FCoverMessageId: string;
      //Дата и время последнего сообщения из регистра
      FCoverMessageTime: TDateTime;

      FFGisun : TGisunInterface;

      function CreateOutputTable(ActKind: TActKind): TDataSet;
      function GetGisun : TGisunInterface; virtual;
      procedure SetGisun(const Value: TGisunInterface); virtual;
   public
      {$IFDEF ADD_WS_LOCAL}
        //Сервис для передачи информации в регистр
        FLocal: TLocalInterface;
      {$ENDIF}
      //Сервис для передачи информации в регистр
      FZags: TZagsInterface;

      FObrPersonalData:TObrPersonalData;

      function GetDate(objDate:TXSDate):TDateTime;
      function GetPar(slPar:TStringList;sParam,sDefault: String): String;
      function GetLexema(Lexema : TLangValueList_; sLang:String): String;
      function GetDokument(data: TDocument_):TRegDocument;
      function GetDokumentFromArr(arrDoc : array of wsGisun.document2):TRegDocument; //array of document2):TRegDocument;
      function FindDokumentFromArr(arrDoc : array of wsGisun.document2; TypeID:String; TypeSpr:Integer):TRegDocument;
      function DokumentToStr(doc:TRegDocument; sDopName:String):String;

      function MartialStatus2Sem(n: Integer):Integer;

      function GetMartialStatus(data: TPersonalData_; sPar:String):TMartialStatus;
      function GetChildList(data: TPersonalData_; dsOutPut:TDataSet; objList:TObject; slPar:TStringList):Boolean;
      function GetCoursList(data: TPersonalData_; dsOutPut:TDataSet; objList:TObject; sTypes:String; slPar:TStringList):TListReshSud;
      function GetPersonalData(data: TPersonalData_; dsOutPut:TDataSet; objList:TObject; slPar:TStringList):Boolean;

      constructor Create(MessageSource: string);
      destructor Destroy; override;

      function CheckLogon:Boolean;

      //Функция читает метаинформацию, необходимую для создания таблиц, используемых
      //при вызове функций Get и Post
      //Эту функцию необходимо обязательно вызвать до первого вызова функций
      //CreateInputTable и CreateOutputTable
      //Входные параметры:
      //InputFile   - полный путь к файлу
      //OutputFile  - полный путь к файлу
      //Выходные параметры:
      //True        -
      //False       -
      function ReadMetaInfo(InputFile, OutputFile: string): Boolean;
      //Функция создаёт пустую таблицу, которую должна заполнить вызывающая процедура
      //перед тем как выполнить запрос данных из регистра с помощью функции Get
      //Входные параметры:
      //ActKind - Тип актовой записи, для которой требуется получить данные из регистра
      //          населения
      //Operation -
      //Выходные параметры:
      //Input   - Набор данных передаваемых в регистр. Структура этой таблицы
      //          зависит от типа актовой записи. После создания таблица открывается.
      function CreateInputTable(ActKind: TActKind; Operation: TOperation): TDataSet;
      //Функция для получения данных из регистра населения
      //Входные параметры:
      //ActKind - Тип актовой записи, для которой требуется получить данные из регистра
      //          населения
      //MessageType - Тип сообщения (код вида операции органа ЗАГС) <nnnn>
      //              На данный момент может оставаться пустым
      //Input   - Набор данных передаваемых в регистр. Структура этой таблицы
      //          зависит от типа актовой записи. Эта таблица создаётся, заполняется
      //          и уничтожается вызывающей процедурой. Для создания таблицы необходимо
      //          использовать функцию CreateInputTable. На момент вызова функции
      //          Get таблица должна быть открыта в режиме просмотра на первой записи.
      //Выходные параметры:
      //Output  - Набор данных получаемых из регистра. Структура этой таблицы
      //          зависит от типа актовой записи. Эта таблица создаётся и заполняется
      //          функцией Get. Уничтожать процедуру должна вызывающая процедура. На
      //          момент выхода из функции Get таблица должна быть открыта в режиме
      //          просмотра на первой записи. Таблица создаётся функцией
      //          Get, только при успешном получении данных из регистра, иначе
      //          возвращается nil.
      //Error   - Список ошибок возвращаемых регистром. Эта таблица создаётся и заполняется
      //          функцией Get. Уничтожать процедуру должна вызывающая процедура. На
      //          момент выхода из функции Get таблица должна быть открыта в режиме
      //          просмотра на первой записи.Таблица создаётся функцией
      //          Get, только при наличии ошибок, иначе возвращается nil.
      //Результат функции:
      //rrFault       - Не произошло взаимодействия с регистром в результате какого-либо
      //                сбоя или отсутствия связи. Выходные параметры Output и Error равны
      //                nil. Текст ошибки содержит поле FaultError
      //rrBeforeError - В данные момент аналогично rrFault
      //rrOk          - Произошёл обмен данными с регистром и при этом регистр не вернул
      //                ошибок. Выходной параметр Output содержит полученные данные,
      //                а Error равен nil
      //rrError       - Произошёл обмен данным с регистром, но регистр вернул ошибки
      //                Выходной параметр Output содержит полученные данные, а Error
      //                содержит список ошибок, которые вернул регистр.
      //rrAfterError  - После обмена данными с регистром произошла непредвиденная ошибка
      //                или ошибки обнаружила наша программа (например, в полученных из
      //                регистра данных). Выходной параметр Output содержит полученные
      //                данные, Error равен nil, FaultError содержит текст ошибки
      function Get(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument:TDataSet=nil; slPar:TStringList=nil): TRequestResult;
      //
      function Post(RequestMessageId: string; ActKind: TActKind; MessageType: string; const Input: TDataSet; var Error: TDataSet): TRequestResult;
      procedure DataSetAllFieldUpper(ds:TDataSet);
   public
      property FaultError: string read FFaultError;
      property RequestMessageId: string read FRequestMessageId;
      property CoverMessageId: string read FCoverMessageId;
      property CoverMessageTime: TDateTime read FCoverMessageTime;
      //ПАРАМЕТРЫ:
      property MessageSource: string read FMessageSource write SetMessageSource;
      property LocalUrl: string read FLocalUrl write SetLocalUrl;
      property LocalProxy: string read FLocalProxy write SetLocalProxy;
      property ZagsUrl: string read FZagsUrl write SetZagsUrl;
      property ZagsProxy: string read FZagsProxy write SetZagsProxy;
      property GisunUrl: string read FGisunUrl write SetGisunUrl;
      property GisunProxy: string read FGisunProxy write SetGisunProxy;
      property PostIsUpper:Boolean read FPostIsUpper write SetPostIsUpper;
      property Version:Integer read FVersion write SetVersion;
      //property DateFormat: string read FDateFormat write FDateFormat;
      //Журнал
      property Log: TStringList read FLog;
      //
      property TableList: TRegTableList read FTableList;
      property Username: string read FUsername write FUsername;
      property Password: string read FPassword write FPassword;
      property PIN: string read FPIN write SetPIN;
      property DbUserAsGIS : Boolean read FDbUserAsGIS write SetDbUserAsGIS;
      property PostUserName : Boolean read FPostUserName write SetPostUserName;
      property Error07: Boolean read FError07;
      property TextLog: string read FTextLog write FTextLog;

      //Сервис для получения информации из регистра
      property FGisun: TGisunInterface read GetGisun write SetGisun;

   end;

{ Работа с таблицами }

function CreateMemTable(FieldList: array of const; AutoCreate, AutoOpen: Boolean): TkbmMemTable;
procedure CreateAndCopyMemTable(Src: TDataSet; Dst: TkbmMemTable);
function CreateErrorTable: TDataSet;

implementation

{$IFDEF MY_PROJECT}
  uses fLogon, fMain, uGisun;
{$ENDIF}

{ Работа с таблицами }

function CreateMemTable(FieldList: array of const; AutoCreate, AutoOpen: Boolean): TkbmMemTable;
var
   I: Integer;
   FieldName: string;
   FieldType: TFieldType;
   FieldSize: Integer;
   FieldDef: TFieldDef;

   function GetString(var VarRec: TVarRec): string;
   begin
      case VarRec.VType of
         vtAnsiString: Result:=VarRec.VPChar;
         vtChar: Result:=VarRec.VChar;
      else
         Result:='';
      end;
   end;

begin
   Result:=nil;
   if Length(FieldList) mod 3=0 then begin
      Result:=TkbmMemTable.Create(nil);
      for I:=Low(FieldList) to High(FieldList) div 3 do begin
         FieldName:=GetString(FieldList[I*3]);
         FieldType:=TFieldType(FieldList[I*3+1].VInteger);
         FieldSize:=FieldList[I*3+2].VInteger;
         FieldDef:=Result.FieldDefs.AddFieldDef;
         FieldDef.Name:=FieldName;
         FieldDef.DataType:=FieldType;
         if FieldType<>ftBoolean then begin
            FieldDef.Size:=FieldSize;
         end;
      end;
      if AutoCreate then begin
         Result.CreateTable;
         if AutoOpen then begin
            Result.Open;
         end;
      end;
   end;
end;

procedure CreateAndCopyMemTable(Src: TDataSet; Dst: TkbmMemTable);
var
   I: Integer;
   Field: TField;
   FieldDef: TFieldDef;
begin
   Dst.FieldDefs.Clear;
   for I:=0 to Pred(Src.Fields.Count) do begin
      Field:=Src.Fields[I];
      FieldDef:=Dst.FieldDefs.AddFieldDef;
      FieldDef.Name:=Field.FieldName;
      FieldDef.DataType:=Field.DataType;
      FieldDef.Size:=Field.Size;
      if Field is TFloatField then begin
         FieldDef.Precision:=TFloatField(Field).Precision;
      end;
   end;
   Dst.CreateTable;
   Dst.Open;
   Src.First;
   while not Src.Eof do begin
      Dst.Append;
      for I:=0 to Pred(Src.Fields.Count) do begin
         Dst.Fields[I].AsString:=Src.Fields[I].AsString;
      end;
      Dst.Post;
      Src.Next;
   end;
end;                                                                       

function CreateErrorTable: TDataSet;
begin
   //???значность
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

{ TRegInt }

function TRegInt.GetGisun : TGisunInterface;
begin
  Result := FFGisun;
end;

procedure TRegInt.SetGisun(const Value: TGisunInterface);
begin
  FFGisun := Value;
end;

constructor TRegInt.Create(MessageSource: string);
const
   CDefaultLocalUrl='';
   CDefaultZagsUrl='http://agat-system.by:4569/gisun/zags/ws';
   CDefaultGisunUrl='http://agat-system.by:4569/gisun/common/ws';
begin
   FObrPersonalData:=nil;
   FVersion:=4;
   FPostIsUpper:=false;
   FTableList:=TRegTableList.Create;
   FLog:=TStringList.Create;
   {$IFDEF ADD_WS_LOCAL}
     FLocal:=TLocalInterface.Create;
   {$ENDIF}
   FZags:=TZagsInterface.Create;
   FGisun:=TGisunInterface.Create;
//   FGisun.EnabledLog:=false;
   SetMessageSource(MessageSource);
   SetZagsUrl(CDefaultZagsUrl);
   SetGisunUrl(CDefaultGisunUrl);
   FUsername:='';
   FPassword:='';
   FDbUserAsGIS:=false;
   FPostUserName:=false;
   //FDateFormat:='yyyymmdd';
   //Проверка важных параметров
   Assert(MessageSource<>'', 'Метод TRegInt.Create. Не установлен параметр MessageSource');
end;

//--------------------------------------------------------------------------
procedure TRegInt.DataSetAllFieldUpper(ds:TDataSet);
var
  i:Integer;
begin
  if (ds<>nil) and FPostIsUpper then begin
    ds.Edit;
    for i:=0 to ds.FieldCount-1 do begin
      if ds.Fields[i].DataType=ftString then begin
        ds.Fields[i].AsString:=ANSIUpperCase(ds.Fields[i].AsString);
      end;
    end;
    ds.Post;
  end;
end;

function TRegInt.CreateInputTable(ActKind: TActKind; Operation: TOperation): TDataSet;
var
   Table: TRegTable;
begin
   Result:=nil;
   Table:=FTableList.Find(True, ActKind, Operation);
   if (Operation=opGet) and (ActKind<>akGetPersonIdentif) then begin
      Table:=FTableList.Find(True, akGetPersonalData, Operation);
   end;
   if Table<>nil then begin
      Result:=Table.CreateMemTable;
   end;
end;

function TRegInt.CreateOutputTable(ActKind: TActKind): TDataSet;
var
   Table: TRegTable;
begin
   Result:=nil;
   Table:=FTableList.Find(False, ActKind, opGet);
   if Table<>nil then begin
      Result:=Table.CreateMemTable;
   end;
end;

{
procedure TRegInt.DataSetToActData(Prefix: string; act_data: wsZags.ActData; DataSet: TDataSet);
begin
   //Информация об актовой записи
   //1. Тип актовой записи
   act_data.act_type:=FZags.CreateClassifier(DataSet.FieldByName(Prefix+'TIP').AsString, ctActType);
   //2. Гос. орган, осуществивший актовую запись
   act_data.authority:=FZags.CreateClassifier(DataSet.FieldByName(Prefix+'ORGAN').AsString, ctZags);
   //3. Дата актовой записи
   act_data.date:=FZags.CreateDate(DataSet.FieldByName(Prefix+'DATE').AsDateTime);
   //4. Номер актовой записи
   act_data.number:=DataSet.FieldByName(Prefix+'NOMER').AsString;
end;
}
{
procedure TRegInt.DataSetToDocument(Prefix: string; doc: wsZags.Document; DataSet: TDataSet);
begin
   //Документ
   //6.1. Тип документа
   doc.document_type:=FZags.CreateClassifier(DataSet.FieldByName(Prefix+'TIP').AsString, ctDocType);
   //6.2. Гос. орган, выдавший документ
   doc.authority:=FZags.CreateClassifier(DataSet.FieldByName(Prefix+'ORGAN').AsString, ctZags);
   //6.3. Дата выдачи
   doc.date_of_issue:=FZags.CreateDate(DataSet.FieldByName(Prefix+'DATE').AsDateTime);
   //6.4. Срок действия документа
   //doc.expire_date
   //6.5. Серия документа
   doc.series:=DataSet.FieldByName(Prefix+'SERIA').AsString;
   //6.6. Номер документа
   doc.number:=DataSet.FieldByName(Prefix+'NOMER').AsString;
end;
}
destructor TRegInt.Destroy;
begin
   FZags.Free;
   FGisun.Free;
   FLog.Free;
   FTableList.Free;
   inherited;
end;

{
function TRegInt.FormatDate(DateTime: TDateTime): string;
begin
   Result:=FormatDateTime(FDateFormat, DateTime);
end;
}
//--------------------------------------------------------------------
function TRegInt.GetDate(objDate:TXSDate):TDateTime;
begin
  if objDate<>nil
    then Result:=objDate.AsDate
    else Result:=0;
end;
//--------------------------------------------------------------------
function TRegInt.GetPar(slPar:TStringList;sParam,sDefault: String): String;
begin
  Result:=sDefault;
  if (slPar<>nil) and (slPar.Count>0) then begin
    Result:=slPar.Values[sParam];
    if Result=''
      then Result:=sDefault;
  end;
end;
//--------------------------------------------------------------------
function TRegInt.GetLexema(Lexema : TLangValueList_; sLang:String): String;
var
  i:Integer;
begin
  Result:='';
  if Length(lexema)>0 then begin
    for i:=Low(lexema) to High(lexema) do begin
      if LowerCase(lexema[i].lang)=sLang then begin
        Result:=lexema[i].Text;
      end;
    end;
  end;
end;
//--------------------------------------------------------------------
function TRegInt.GetDokument(data: TDocument_):TRegDocument;
begin
  Result.AuthorID:=data.authority.code;
  Result.AuthorSpr:=data.authority.type_;
  Result.AuthorName:=GetLexema(data.authority.lexema, 'ru');
  Result.TypeID:=data.document_type.code;
  Result.TypeSpr:=data.document_type.type_;
  Result.TypeName:=GetLexema(data.document_type.lexema, 'ru');
  Result.Number:=data.number;
  Result.Seria:=data.series;
  Result.DateIssue:=GetDate(data.date_of_issue);
  Result.DateExpire:=GetDate(data.expire_date);
  Result.Active:=data.active;
end;
//--------------------------------------------------------------------
function TRegInt.FindDokumentFromArr(arrDoc : array of wsGisun.document2; TypeID:String; TypeSpr:Integer):TRegDocument;
var
  i:Integer;
  doc:TRegDocument;  
begin
  Result.Active:=false;
  for i:=Low(arrDoc) to High(arrDoc) do begin
    doc:=GetDokument(arrDoc[i]);
    if doc.Active and (doc.TypeID=TypeID) and (doc.TypeSpr=TypeSpr) then begin
      Result:=doc;
      break;
    end;
  end;
end;
//--------------------------------------------------------------------
function TRegInt.GetDokumentFromArr(arrDoc : array of wsGisun.document2):TRegDocument;
var
  i:Integer;
  doc:TRegDocument;
begin
  Result.Active:=false;
  for i:=Low(arrDoc) to High(arrDoc) do begin
    doc:=GetDokument(arrDoc[i]);
    if doc.Active then begin
      Result:=doc;
      break;
    end;
  end;
end;
//--------------------------------------------------------------------
function TRegInt.DokumentToStr(doc:TRegDocument; sDopName:String):String;
begin
  Result:=AnsiLowerCase(doc.TypeName)+' '+sDopName+' № '+doc.Number+' от '+DatePropis(doc.DateIssue,3); //+', '+doc.AuthorName;
end;
//--------------------------------------------------------------------
function TRegInt.MartialStatus2Sem(n: Integer):Integer;
begin
{[KEY_SEMF]
 1=состоит в браке
 2=в браке не состоял(а)
 3=вдовец(а)
 4=разведен(а)
 9=сведения не представлены }
  Result:=0;
  case n of
    0  : result:=SEM_NOT; //2
    11 : result:=SEM_DEATH;//3
    21,22 : result:=SEM_RAST; //4
    23 : result:=0;
    10 : result:=SEM_BRAK; //1
  end;
end;
//--------------------------------------------------------------------
// 0-нет данных,  10-состоит в браке  11-вдовец(вдова)
//  расторгнут: 21-з/а  22-по решению суда
//  23-признан недейств. по реш. суда
function TRegInt.GetMartialStatus(data: TPersonalData_; sPar:String):TMartialStatus;
var
  i:Integer;
  doc:TRegDocument;
  s,ss,sZAGS_A,sZAGS_S,sPol:String;
  lFIO,lSuprugDeath:Boolean;
begin
  if Pos('<FIO>', sPar)>0  then lFIO:=true  else lFIO:=false;
  Result.Status:=0;  // нет данных
  Result.Text:='нет данных';
  Result.NameStatus:='';
  Result.FIO:='';
  Result.Doc:='';
  lSuprugDeath:=false;

//  try
  if data.family<>nil then begin
    if data.family.martial_status<>nil then begin
      if (data.family.husband<>nil) then begin  // муж
        sPol:='м';
        Result.FIO:=data.family.husband.person_data.last_name+' '+data.family.husband.person_data.name_+' '+
              data.family.husband.person_data.patronymic;
        if data.family.husband.person_data.status.code<>ST_ACTIVE
          then lSuprugDeath:=true;
      end else if (data.family.wife<>nil) then begin  // жена
        sPol:='ж';
        Result.FIO:=FirstUpper(data.family.wife.person_data.last_name+' '+data.family.wife.person_data.name_+' '+
              data.family.wife.person_data.patronymic);
        if data.family.wife.person_data.status.code<>ST_ACTIVE
          then lSuprugDeath:=true;
      end;                                 
      if (Result.FIO<>'') and lFIO then s:=' c '+GetPadegFIO(Result.FIO, sPol, 'т') else s:='';
//      data.family.martial_status.cert_data.invalid_mrg_date  // дата решения суда о призаннии брака недействительным
//      data.family.martial_status.cert_data.dvc_date          // дата решения суда о расторжении брака
      sZAGS_S:='';
      sZAGS_A:='';
      for i:=Low(data.family.martial_status.documents) to HIGH(data.family.martial_status.documents) do begin
        if data.family.martial_status.documents[i].date_of_issue<>nil then begin
          doc:=GetDokument(data.family.martial_status.documents[i]);
          if doc.Active then begin
            //---- тип докум.: решение судов, автор: справочник судов
            if (doc.TypeSpr=ctTypeDokSud) and (doc.AuthorSpr=ctSud) then begin
              if data.family.martial_status.cert_data.invalid_mrg_date<>nil then begin
                Result.NameStatus:='брак'+s+' признан недейстительным';
                Result.Doc:='решение суда о признании брака недейстительным';
                Result.Status:=23;  // недействительный по суду
              end else if data.family.martial_status.cert_data.dvc_date<>nil then begin
                Result.NameStatus:='брак'+s+' расторгнут по решению суда';
                Result.Doc:='решение суда о расторжении брака';
                Result.Status:=22;  // расторгнут по суду
              end;
              Result.Text:='решение суда №'+doc.Number+' от '+DatePropis(doc.DateIssue,3)+'г '+doc.AuthorName;
            //---- тип докум.: свидетельство, автор: справочник органов ЗАГС
            end else if (doc.TypeSpr=ctSvidType) and (doc.AuthorSpr=ctZags) then begin
// 1 свид. о расторжении брака I-ЛЮ № 0093439 выд. отдел загса администрации Новобелицкого района г. Гомеля
//   а/з № 38 от 24.06.2017 г.
// 2 Решение суда о раст. брака Новобелицкого района г.Гомеля от 31.08.2012 г., вступ. в силу 11.09.2012 г.
              ss:='';
              if doc.TypeID=DOK_SVID_RAST then begin
                ss:='о раст. брака';
              end else if doc.TypeID=DOK_SVID_BRAK then begin
                ss:='о браке';
              end;
              sZAGS_S:='св-во '+ss+' '+doc.Seria+' №'+doc.Number+' от '+DatePropis(doc.DateIssue,3)+'г';
            //---- тип докум.: актовая запись, автор: справочник органов ЗАГС
            end else if (doc.TypeSpr=ctActType) and (doc.AuthorSpr=ctZags) then begin
              if doc.TypeID=ctActType_ZBrak then begin
                if lSuprugDeath then begin
                  Result.Status:=11;   // вдова(вдовец)
                  Result.NameStatus:='вдова(вдовец)';
                end else begin
                  Result.Status:=10;  // состоит в браке
                  Result.NameStatus:='cостоит в браке'+s;
                end;
              end else if doc.TypeID=ctActType_ZRast then begin
                Result.NameStatus:='брак'+s+' расторгнут';
                Result.Status:=21;  // расторгнут в ЗАГС
              end;
              sZAGS_A:='з/а №'+doc.Number+' от '+DatePropis(doc.DateIssue,3)+'г';
            end;
            Result.Organ:=doc.AuthorName;
          end;
        end;
      end;
      if (Result.Status=10) or (Result.Status=21) then begin  // орган принятия ЗАГС
        if sZAGS_A=''
          then ss:=sZAGS_S
          else if sZAGS_S='' then ss:=sZAGS_A else ss:=sZAGS_S+', '+sZAGS_A;
//        Result.Text:=sZAGS_S+sZAGS_A+' '+doc.AuthorName;
        Result.Text:=ss+' '+doc.AuthorName;  //   !!! doc.AuthorName надо брать для каждого документа свое !!!
      end else if (Result.Status=11) then begin // вдовец(а)
        Result.Text:=''; // нет записи акта о смерти
        Result.Doc:='';
      end;
    end;
  end;
//  except
//    Result:=-1;
//  end;
end;
//--------------------------------------------------------------------
// вернуть список детей
function TRegInt.GetChildList(data: TPersonalData_; dsOutPut:TDataSet; objList:TObject; slPar:TStringList):Boolean;
{
var
  i:Integer;
}
begin
  Result:=false;
{
  Result:=false;
  if data.family<>nil then begin
    if data.family.child<>nil then begin
      for i:=Low(data.family.child) to HIGH(data.family.child) do begin
        if GetPersonalData(data.family.child[i].person_data, dsOutPut, objList, slPar)
          then Result:=true;
      end;
    end;
  end;
//    property person_data:      PersonalData      Index (IS_OPTN) read Fperson_data write Setperson_data stored person_data_Specified;
//    property prnt_rights_info: parentRightsInfo  Index (IS_OPTN) read Fprnt_rights_info write Setprnt_rights_info stored prnt_rights_info_Specified;
//    property documents:        documents7        Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
}
end;
//--------------------------------------------------------------------
// данные о человеке
function TRegInt.GetPersonalData(data: TPersonalData_; dsOutPut:TDataSet; objList:TObject; slPar:TStringList):Boolean;
{
var

  i:Integer;
  dsList:TDataSet;
  slList:TStringList;
  doc:TRegDocument;
  d:TDateTime;
  s:String;
  fld:TField;
  procedure V2Fld(sVal:WideString; sField:String; sType:String);
  begin
    fld:=dsList.FindField(sField);
    if fld<>nil then begin
      if sType='C' then begin
        fld.AsString:=sVal;
      end else if sType='N' then begin
      end;
    end;
  end;
  }
begin
  Result:=false;
{
  Result:=false;
  if objList is TStringList then slList:=TStringList(objList) else slList:=nil;
  if objList is TDataSet    then dsList:=TDataSet(objList)    else dsList:=nil;
//   ds := dbCreateMemTable('IDENTIF,Char,14;FAMILIA,Char,100;NAME,Char,50;OTCH,Char,60;POL,Char,1;DATER,Date;TYPEDATER,Integer;DATES,Date;'+
//         'FAMILIA_B,Char,100;NAME_B,Char,50;OTCH_B,Char,60;GRAG,Integer;STATUS,Char,1;'+
//         'DOK_TYPE,Integer;DOK_ORGAN,Char,10;DOKUMENT,Memo;DOK_SERIA,Char,11;DOK_NOMER,Char,11;DOK_DATE,Date;'+
//         'GOSUD_R,Integer;B_OBL_R,Logical;OBL_R,Char,100;OBL_B_R,Char,100;RAION_R,Char,100;RAION_B_R,Char,100;TYPE_GOROD_R,Integer;GOROD_R,Char,100;GOROD_B_R,Char,100;'+
//         'GOSUD_G,Integer;OBL_G,Char,100;RAION_G,Char,100;TYPE_GOROD_G,Integer;GOROD_G,Char,100;GOROD_R_G,Char,150;'+
//         'OBL_B_G,Char,100;RAION_B_G,Char,100;GOROD_B_G,Char,100;GOROD_R_B_G,Char,150;RNGOROD_B_G,Char,100;ULICA_B_G,Char,100;'+
//         'ULICA_G,Char,100;DOM_G,Char,10;KORP_G,Char,10;KV_G,Char,10;RNGOROD_G,Char,100;SOATO_G,Char,10;FIO,Char,150;ADRES_R,Memo;ADRES_G,Memo;DOC_NAME,Memo;REG_DATE,Date;REG_DATE_TILL,Date;','');

  if data<>nil then begin
    // место рождения
    V2Fld(data.birth_place.area_b,'OBL_R','C');
    s:=data.birth_place.country_b.code;
    // документы
    s:=data.document[i].document_type.code;
    //-------
    s:=data.sex.code;
    s:=data.identif;
    s:=data.last_name;
    s:=data.last_name_bel;
    s:=data.name_;
    s:=data.name_bel;
    s:=data.patronymic;
    s:=data.patronymic_bel;
    s:=data.birth_day;
    if data.document<>nil then begin
      for i:=Low(data.document) to High(data.document) do begin
        s:=data.document[i].document_type.code;
      end;
    end;
  end;
//    property person_data:      PersonalData      Index (IS_OPTN) read Fperson_data write Setperson_data stored person_data_Specified;
//    property prnt_rights_info: parentRightsInfo  Index (IS_OPTN) read Fprnt_rights_info write Setprnt_rights_info stored prnt_rights_info_Specified;
//    property documents:        documents7        Index (IS_OPTN) read Fdocuments write Setdocuments stored documents_Specified;
}
{
<child>
<person_data>
<identif>7096551A001PB2</identif>
<last_name>ИВАНОВ</last_name>
<last_name_bel>ІВАНОЎ</last_name_bel>
<name>СТЕПАН</name>
<name_bel>СЦЯПАН</name_bel>
<patronymic>НИКОЛАЕВИЧ</patronymic>
<patronymic_bel>МІКАЛАЕВІЧ</patronymic_bel>
</child>
}
end;

//--------------------------------------------------------------------
// вернуть решения суда
function TRegInt.GetCoursList(data: TPersonalData_; dsOutPut:TDataSet; objList:TObject; sTypes:String; slPar:TStringList):TListReshSud;
var
  i:Integer;
  dsList:TDataSet;
  slList:TStringList;
  doc:TRegDocument;
  lAll,lDeaths,lAbsents,lUneff,lRestrict:Boolean;
  d,dDateBegin,dDateEnd:TDateTime;
  s,ss:String;
  procedure AddReshSud(nType:TOneReshSud; lOtmena:Boolean; dDate:TDateTime);
  begin
    if lOtmena then s:='об отмене признания ' else s:='о признании ';
    ss:='физического лица ';
    case nType of
      rsUneff    : ss:=ss+'недееспособным';
      rsDeaths   : ss:=ss+'умершим';
      rsAbsents  : ss:=ss+'безвестно отсутствующим';
      rsRestrict : ss:=ss+'ограниченно дееспособным';
    end;
    if dsList<>nil then begin
      dsList.Append;
      dsList.FieldByName('ID').AsString:=dsOutPut.FieldByName('PREFIX').AsString;
      dsList.FieldByName('FIO').AsString:=dsOutPut.FieldByName('FAMILIA').AsString+' '+dsOutPut.FieldByName('NAME').AsString+' '+dsOutPut.FieldByName('OTCH').AsString;
      dsList.FieldByName('TYPE_RESH').AsInteger:=Integer(nType);
      dsList.FieldByName('DATE_RESH').AsDateTime:=dDate;
      dsList.FieldByName('TEXT').AsString:=DokumentToStr(doc,s+ss);
      dsList.FieldByName('SUD').AsString:=doc.AuthorName;
      dsList.FieldByName('CANCEL').AsBoolean:=lOtmena;
      dsList.Post;
    end else begin
      slList.Add(IntToStr(Integer(nType))+'='+DokumentToStr(doc,s+ss));
    end;
  end;
begin
  Result:=[];
  if objList is TStringList then slList:=TStringList(objList) else slList:=nil;
  if objList is TDataSet    then dsList:=TDataSet(objList) else dsList:=nil;
//  sID:=getPar(slPar,'ID','0');
//   0-all  1=deaths  2=absents 3=unefficients 4=restrict_efficients
//   1=Данные об объявлении физического лица умершим, об отмене соответствующего решения (Суды)
//   2=Данные о признании физического лица безвестно отсутствующим, об отмене соответствующего решения
//   3=Данные о признании физического лица недееспособным, об отмене соответствующего решения
//   4=Данные о признании физического лица ограниченно дееспособным, об отмене соответствующего решения
  if sTypes='' then lAll:=true else lAll:=false;
  if Pos('deat',sTypes)>0 then lDeaths:=true   else lDeaths:=false;
  if Pos('absen',sTypes)>0  then lAbsents:=true  else lAbsents:=false;
  if Pos('unef',sTypes)>0   then lUneff:=true    else lUneff:=false;
  if Pos('rest',sTypes)>0   then lRestrict:=true else lRestrict:=false;

  if (data.courts<>nil) then begin
    // о признании недееспособным -----------------------------------------
    if (lAll or lUneff) and (data.courts.unefficients<>nil) then begin
      dDateBegin:=0;
      dDateEnd:=0;
      for i:=Low(data.courts.unefficients) to HIGH(data.courts.unefficients) do begin
        if data.courts.unefficients[i].unefficient_data.unefficient_date<>nil then begin
          d:=data.courts.unefficients[i].unefficient_data.unefficient_date.AsDate;
          if d>dDateBegin then dDateBegin:=d;
          doc:=GetDokumentFromArr(data.courts.unefficients[i].documents);
          AddReshSud(rsUneff, false, d);
        end;
        if data.courts.unefficients[i].unefficient_data.unefficient_date_cancel<>nil then begin
          d:=data.courts.unefficients[i].unefficient_data.unefficient_date_cancel.AsDate;
          if d>dDateEnd then dDateEnd:=d;
          doc:=GetDokumentFromArr(data.courts.unefficients[i].documents);
          AddReshSud(rsUneff, true, d);
        end;
      end;
      if dDateBegin>dDateEnd then begin
        Result:=Result+[rsUneff];
      end;
    end;
    // о признании ограниченно дееспособнам -----------------------------------------
    if (lAll or lRestrict) and (data.courts.restrict_efficients<>nil) then begin
      dDateBegin:=0;
      dDateEnd:=0;
      for i:=Low(data.courts.restrict_efficients) to HIGH(data.courts.restrict_efficients) do begin
        if data.courts.restrict_efficients[i].restrict_efficient_data.restrict_unefficient_date<>nil then begin
          d:=data.courts.restrict_efficients[i].restrict_efficient_data.restrict_unefficient_date.AsDate;
          if d>dDateBegin then dDateBegin:=d;
          doc:=GetDokumentFromArr(data.courts.restrict_efficients[i].documents);
          AddReshSud(rsRestrict, false, d);
        end;
        if data.courts.restrict_efficients[i].restrict_efficient_data.restrict_unefficient_date_cancel<>nil then begin
          d:=data.courts.restrict_efficients[i].restrict_efficient_data.restrict_unefficient_date_cancel.AsDate;
          if d>dDateEnd then dDateEnd:=d;
          doc:=GetDokumentFromArr(data.courts.restrict_efficients[i].documents);
          AddReshSud(rsRestrict, true, d);
        end;
      end;
      if dDateBegin>dDateEnd then begin
        Result:=Result+[rsRestrict];
      end;
    end;
    // о признании пропавшим безвести -----------------------------------------
    if (lAll or lAbsents) and (data.courts.absents<>nil) then begin
      dDateBegin:=0;
      dDateEnd:=0;
      for i:=Low(data.courts.absents) to HIGH(data.courts.absents) do begin
        if data.courts.absents[i].absent_data.absent_date<>nil then begin
          d:=data.courts.absents[i].absent_data.absent_date.AsDate;
          if d>dDateBegin then dDateBegin:=d;
          doc:=GetDokumentFromArr(data.courts.absents[i].documents);
          AddReshSud(rsAbsents, false, d);
        end;
        if data.courts.absents[i].absent_data.absent_date_cancel<>nil then begin
          d:=data.courts.absents[i].absent_data.absent_date_cancel.AsDate;
          if d>dDateEnd then dDateEnd:=d;
          doc:=GetDokumentFromArr(data.courts.absents[i].documents);
          AddReshSud(rsAbsents, true, d);
        end;
      end;
      if dDateBegin>dDateEnd then begin
        Result:=Result+[rsAbsents];
      end;
    end;
    // о признании умершим -----------------------------------------
    if (lAll or lDeaths) and (data.courts.deaths<>nil) then begin
      dDateBegin:=0;
      dDateEnd:=0;
      for i:=Low(data.courts.deaths) to HIGH(data.courts.deaths) do begin
        if data.courts.deaths[i].death_data.death_date<>nil then begin
          d:=data.courts.deaths[i].death_data.death_date.AsDate;
          if d>dDateBegin then dDateBegin:=d;
          doc:=GetDokumentFromArr(data.courts.deaths[i].documents);
          AddReshSud(rsDeaths, false, d);
        end;
        if data.courts.deaths[i].death_data.death_date_cancel<>nil then begin
          d:=data.courts.deaths[i].death_data.death_date_cancel.AsDate;
          if d>dDateEnd then dDateEnd:=d;
          doc:=GetDokumentFromArr(data.courts.deaths[i].documents);
          AddReshSud(rsDeaths, true, d);
        end;
      end;
      if dDateBegin>dDateEnd then begin
        Result:=Result+[rsDeaths];
      end;
    end;

  end;
end;
//----------------------------------------------------------------
function TRegInt.Get(ActKind: TActKind; MessageType: string; const Input: TDataSet; var Output, Error: TDataSet; const Dokument:TDataSet; slPar:TStringList): TRequestResult;
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
   FLog.Clear;
   Output:=nil;
   Error:=nil;
   FRequestMessageId:='';
   FFaultError:='';
   if MessageType='' then begin
      MessageType:=CMessageType[ActKind];
   end;
   Result:=rrFault;
   if not CheckLogon then begin
     FFaultError:='Отказ от взаимодействия.';
     FLog.Add('Отказ от взаимодействия.');
     exit;
   end;
   case ActKind of
      //Запрос на получение персональных данных по ф.и.о.
      akGetPersonIdentif: begin
//------------------- стало  16.03.2021   по просьбе МВД
         FGisun.TypeMessageCover:=0;
         // при запросе данных для захоронений и опеки
         if (MessageType=QUERY_INFO) or (ActKind=akZah) or (ActKind=akOpeka) or (ActKind=akPopech) then begin
           old:=FGisun.TypeMessageCover;
           FGisun.TypeMessageCover:=-2;
           MessageType:=QUERY_INFO;
         end;
         registerPersonIdentifRequest:=FGisun.CreateRegisterPersonIdentifRequest(MessageType);
         FGisun.TypeMessageCover:=0;
//-------------------
// было         registerPersonIdentifRequest:=FGisun.CreateRegisterPersonIdentifRequest(MessageType);
//-------------------
         FRequestMessageId:=registerPersonIdentifRequest.cover.message_id;
         //скопировать данные из входной таблицы в свойства объекта
         Table:=FTableList.Find(True, akGetPersonIdentif, opGet);
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
              lOk:=FGisun.GetPersonIdentif(registerPersonIdentifRequest, registerResponse, FLog, FUsername, FPassword);
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
                  FLog.Add('!ОШИБКА: не совпадают идентификаторы сообщений')
               end;
               Table:=FTableList.Find(False, akGetPersonalData, opGet); //akGetPersonIdentif
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
                     FLog.Add('!ОШИБКА: не совпадают идентификаторы запросов персональных данных')
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

         FGisun.TypeMessageCover:=0;
         // при запросе данных для захоронений и опеки
         if (MessageType=QUERY_INFO) or (ActKind=akZah) or (ActKind=akOpeka) or (ActKind=akPopech) then begin
           old:=FGisun.TypeMessageCover;
           FGisun.TypeMessageCover:=-2;
           MessageType:=QUERY_INFO;
         end;
         registerRequest:=FGisun.CreateRegisterRequest(MessageType, PersonCount, IdentifierCount);
         FGisun.TypeMessageCover:=0;

         FRequestMessageId:=registerRequest.cover.message_id;
         //
         Table:=FTableList.Find(True, akGetPersonalData, opGet);
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
              lOk:=FGisun.GetPersonalData(registerRequest, registerResponse, FLog, FUsername, FPassword);
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
                  FLog.Add('!ОШИБКА: не совпадают идентификаторы сообщений')
               end;
               //
               FCoverMessageId:=Copy(registerResponse.cover.message_id,2,36);     //GUID сообщения ответа
               FCoverMessageTime:=registerResponse.cover.message_time.AsDateTime; //время сообщения ответа
               Table:=FTableList.Find(False, akGetPersonalData, opGet);
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
                        FLog.Add('!ОШИБКА: не совпадают идентификаторы запросов персональных данных')
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
                        FLog.Add('!ОШИБКА: не совпадают идентификаторы запросов личного номера')
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

//---------------------------------------------------------------------------------
function TRegInt.Post(RequestMessageId: string; ActKind: TActKind; MessageType: string; const Input: TDataSet; var Error: TDataSet): TRequestResult;
var
   birthActRequest: wsZags.birth_act;
   affActRequest: wsZags.affiliation_act;
   mrgActRequest: wsZags.marriage_act;
   dvcActRequest: wsZags.divorce_act;
   adpActRequest: wsZags.adoption_act;
   dcsActRequest: wsZags.decease_act;
   cngActRequest: wsZags.name_change_act;
   ReturnCode: wsZags.WsReturnCode;
   {$IFDEF ADD_WS_LOCAL}
   burialRequest: wsLocal.burial_request;
   opekaRequest: wsLocal.guardianship_data_request;
   popechRequest: wsLocal.trusteeship_data_request;
   ReturnCodeLocal: wsLocal.wsReturnCode;
   {$ENDIF}
   Temp: TkbmMemTable;
   Table: TRegTable;

  //---------------------------------------------------------------------------------
  function CheckError(cover: MessageCover): TRequestResult;
  begin
    FError07:=false;
    if (ReturnCode<>nil) and (Length(ReturnCode.error_list)=0) then begin
       Result:=rrOk;
       if ReturnCode.cover.parent_message_id<>cover.message_id then begin
          Result:=rrAfterError;
          FFaultError:='Ошибка обмена с регистром. Не совпадают идентификаторы сообщений запроса и ответа.';
          FLog.Add('!ОШИБКА: не совпадают идентификаторы сообщений')
       end;
    end
    else begin
       if (ReturnCode<>nil) and (Length(ReturnCode.error_list)<>0) then begin
          //если дублирование
          if (Length(ReturnCode.error_list)=1) and (ReturnCode.error_list[0].error_code.code='07') then begin
             FError07:=true;
             Result:=rrOk;
          end
          else Result:=rrError;
       end
       else begin
          Result:=rrFault;
       end;
       Temp:=TkbmMemTable.Create(nil);
       CreateAndCopyMemTable(FZags.Error, Temp);
       Error:=TDataSet(Temp);
       FFaultError:=FZags.FaultError;
    end;
  end;
  //-----------------------------------------------------------------------------------
  {$IFDEF ADD_WS_LOCAL}
  function CheckErrorLocal(cover: wsLocal.MessageCover): TRequestResult;
  begin
    FError07:=false;
    if (ReturnCodeLocal<>nil) and (Length(ReturnCodeLocal.error_list)=0) then begin
       Result:=rrOk;
       if ReturnCodeLocal.cover.parent_message_id<>cover.message_id then begin
          Result:=rrAfterError;
          FFaultError:='Ошибка обмена с регистром. Не совпадают идентификаторы сообщений запроса и ответа.';
          FLog.Add('!ОШИБКА: не совпадают идентификаторы сообщений')
       end;
    end
    else begin
       if (ReturnCodeLocal<>nil) and (Length(ReturnCodeLocal.error_list)<>0) then begin
          //если дублирование
          if (Length(ReturnCodeLocal.error_list)=1) and (ReturnCodeLocal.error_list[0].error_code.code='07') then begin
             FError07:=true;
             Result:=rrOk;
          end
          else Result:=rrError;
       end
       else begin
          Result:=rrFault;
       end;
       Temp:=TkbmMemTable.Create(nil);
       CreateAndCopyMemTable(FLocal.Error, Temp);
       Error:=TDataSet(Temp);
       FFaultError:=FLocal.FaultError;
    end;
  end;
  //-----------------------------------------------------------------------------------
  {$ENDIF}
begin
   FLog.Clear;
   Error:=nil;
   FError07:=false;
   FFaultError:='';
   if MessageType='' then begin
      MessageType:=CMessageType[ActKind];
   end;
   FError07:=false;
   Result:=rrFault;

   {$IFDEF MY_PROJECT}
   if FTextLog<>''
     then gisun.WriteTextLog('регистрация '+FTextLog,LOG_GISUN);
   {$ENDIF}

   {$IFDEF LAIS}
     {$IFDEF ADD_WS_LOCAL}
       // чистим имя пользователя и пароль, если установлен ZGS... ,а передаем опеку или попечительство
       if ((ActKind=akOpeka) or (ActKind=akPopech)) and (Copy(Username,1,1)='Z') then begin
         Gisun.SetUserNameToken('','','not_change!');
         GlobalTask.SetLastValueAsString('LAST_USER_GIS','');
       end;
       // чистим имя пользователя и пароль, если установлен OPEK... ,а передаем загс или захоронения
       if ((ActKind<>akOpeka) and (ActKind<>akPopech)) and (Copy(Username,1,1)='O') then begin
         Gisun.SetUserNameToken('','','not_change!');
         GlobalTask.SetLastValueAsString('LAST_USER_GIS','');
       end;
     {$ENDIF}
   {$ENDIF}

   if not CheckLogon then begin
     FFaultError:='Отказ от взаимодействия.';
     FLog.Add('Отказ от взаимодействия.');
     exit;
   end;
   Table:=FTableList.Find(True, ActKind, opPost);

   {$IFDEF MY_PROJECT}
   SetOwnerForm(gisun.CurAkt);
   {$ENDIF}
   OpenMessage('       Регистрация ...       ','',0);
   try

   // в зависимомти от параметра FPostIsUpper перевести все строковые поля в верхний регистр
   DataSetAllFieldUpper(Input);
   case ActKind of
      {$IFDEF ADD_WS_LOCAL}
      //Информация о захоронении
      akZah: begin
         //Заполнение данных для передачи в регистр
         burialRequest:=FLocal.CreateBurialRequest(MessageType, RequestMessageId);
         if Table<>nil then begin
            Table.SetProp(burialRequest, Input)
         end;
         ReturnCode:=nil;
         try
            ReturnCodeLocal:=FLocal.PostBurialCertificate(burialRequest, FLog, FUsername, FPassword);
            Result:=CheckErrorLocal(burialRequest.cover);
         finally
            burialRequest.Free;
            ReturnCode.Free;
         end;
      end;

      //Информация об опеке
      akOpeka: begin
         //Заполнение данных для передачи в регистр
         opekaRequest:=FLocal.CreateGuardRequest(MessageType, RequestMessageId);
         if Table<>nil then begin
            Table.SetProp(opekaRequest, Input)
         end;
         ReturnCode:=nil;
         try
            ReturnCodeLocal:=FLocal.PostGuardCertificate(opekaRequest, FLog, FUsername, FPassword);
            Result:=CheckErrorLocal(opekaRequest.cover);
         finally
            opekaRequest.Free;
            ReturnCode.Free;
         end;
      end;
      //Информация о попечительстве
      akPopech: begin
         //Заполнение данных для передачи в регистр
         popechRequest:=FLocal.CreateTrusteeRequest(MessageType, RequestMessageId);
         if Table<>nil then begin
            Table.SetProp(popechRequest, Input)
         end;
         ReturnCode:=nil;
         try
            ReturnCodeLocal:=FLocal.PostTrusteedCertificate(popechRequest, FLog, FUsername, FPassword);
            Result:=CheckErrorLocal(popechRequest.cover);
         finally
            popechRequest.Free;
            ReturnCode.Free;
         end;
      end;
      {$ENDIF}
      //Актовая запись о рождении
      akBirth: begin
         //Заполнение данных для передачи в регистр
         birthActRequest:=FZags.CreateBirthActRequest(MessageType, RequestMessageId);
         if Table<>nil then begin
            Table.SetProp(birthActRequest, Input)
         end;
         ReturnCode:=nil;
         try
            ReturnCode:=FZags.PostBirthCertificate(birthActRequest, FLog, FUsername, FPassword);
            Result:=CheckError(birthActRequest.cover);
         finally
            birthActRequest.Free;
            ReturnCode.Free;
         end;
      end;
      //-------------Актовая запись об установлении отцовства-------------------------------------------------------
      akAffiliation: begin
         affActRequest:=FZags.CreateAffActRequest(MessageType, RequestMessageId);
         if Table<>nil then begin
            Table.SetProp(affActRequest, Input)
         end;
         ReturnCode:=nil;
         try
            ReturnCode:=FZags.PostAffiliationCertificate(affActRequest, FLog, FUsername, FPassword);
            Result:=CheckError(affActRequest.cover);
         finally
            affActRequest.Free;
            ReturnCode.Free;
         end;
      end;
      //Актовая запись о заключении брака
      akMarriage: begin
         mrgActRequest:=FZags.CreateMarriageActRequest(MessageType, RequestMessageId);
         if Table<>nil then begin
            Table.SetProp(mrgActRequest, Input)
         end;
         ReturnCode:=nil;
         try
            ReturnCode:=FZags.PostMarriageCertificate(mrgActRequest, FLog, FUsername, FPassword);
            Result:=CheckError(mrgActRequest.cover);
         finally
            mrgActRequest.Free;
            ReturnCode.Free;
         end;
      end;
      //Актовая запись о смерти
      akDecease: begin
         dcsActRequest:=FZags.CreateDeceaseActRequest(MessageType, RequestMessageId);
         if Table<>nil then begin
            Table.SetProp(dcsActRequest, Input)
         end;
         ReturnCode:=nil;
         try
            ReturnCode:=FZags.PostDeceaseCertificate(dcsActRequest, FLog, FUsername, FPassword);
            Result:=CheckError(dcsActRequest.cover);
         finally
            dcsActRequest.Free;
            ReturnCode.Free;
         end;
      end;
      //Актовая запись о расторжении брака
      akDivorce: begin
         dvcActRequest:=FZags.CreateDivorceActRequest(MessageType, RequestMessageId);
         if Table<>nil then begin
            Table.SetProp(dvcActRequest, Input)
         end;
         ReturnCode:=nil;
         try
            ReturnCode:=FZags.PostDivorceCertificate(dvcActRequest, FLog, FUsername, FPassword);
            Result:=CheckError(dvcActRequest.cover);
         finally
            dvcActRequest.Free;
            ReturnCode.Free;
         end;
      end;
      //Актовая запись об усыновлении (удочерении)
      akAdoption: begin
         adpActRequest:=FZags.CreateAdoptionActRequest(MessageType, RequestMessageId);
         if Table<>nil then begin
            Table.SetProp(adpActRequest, Input)
         end;
         ReturnCode:=nil;
         try
            ReturnCode:=FZags.PostAdoptionCertificate(adpActRequest, FLog, FUsername, FPassword);
            Result:=CheckError(adpActRequest.cover);
         finally
            adpActRequest.Free;
            ReturnCode.Free;
         end;
      end;
      //Актовая запись о перемени имени
      akNameChange: begin
         cngActRequest:=FZags.CreateNameChangeActRequest(MessageType, RequestMessageId);
         if Table<>nil then begin
            Table.SetProp(cngActRequest, Input)
         end;
         ReturnCode:=nil;
         try
            ReturnCode:=FZags.PostNameChangeCertificate(cngActRequest, FLog, FUsername, FPassword);
            Result:=CheckError(cngActRequest.cover);
         finally
            cngActRequest.Free;
            ReturnCode.Free;
         end;
      end;
   end;

   finally
     CloseMessage;
     {$IFDEF MY_PROJECT}
     gisun.CheckMainForm;
     {$ENDIF}
   end;

   {$IFDEF MY_PROJECT}
   if gisun.FEnableTextLog then begin
     if FFaultError<>'' then begin
       gisun.WriteTextLog('            ошибка: '+FFaultError, LOG_GISUN);
     end else if (Result=rrOk) then begin
       if FError07
         then gisun.WriteTextLog('регистрация в предыдущем сеансе (дублирование данных)', LOG_GISUN)
         else gisun.WriteTextLog('регистрация успешно завершена', LOG_GISUN);
     end else begin
       gisun.WriteTextLog('            ошибка', LOG_GISUN);
     end;
   end;
   {$ENDIF}
end;

function TRegInt.ReadMetaInfo(InputFile, OutputFile: string): Boolean;
var
   Struct: TStringList;

   function NextToken(var S: string): string;
   begin
      if Pos(' ', S)<>0 then begin
         Result:=Copy(S, 1, Pred(Pos(' ', S)));
         Delete(S, 1, Pos(' ', S));
         S:=Trim(S);
      end
      else begin
         Result:=S;
      end;
   end;

   procedure ReadStruct(Struct: TStringList; IsInput: Boolean);
   var
      Ind: Integer;
      S: string;
      Table: TRegTable;
      Field: TRegField;
   begin
      Ind:=0;
      repeat
         if Struct.Count<(Ind+3) then begin
            Break;
         end;
         Table:=FTableList.AddNew;
         Table.IsInput:=IsInput;
         S:=Trim(Struct[Ind]);
         Delete(S, 1, 1);
         Table.Comm:=S;
         Inc(Ind);
         S:=Trim(Struct[Ind]);
         Table.ActKind:=TActKind(GetEnumValue(TypeInfo(TActKind), NextToken(S)));
         if IsInput then begin
            Table.Operation:=TOperation(GetEnumValue(TypeInfo(TOperation), S));
         end
         else begin
            Table.Operation:=opGet;
         end;
         Inc(Ind);
         while (Ind<Struct.Count) and (Struct[Ind]<>'') do begin
            S:=Trim(Struct[Ind]);
            if (Length(S)>1) and (Copy(S, 1, 1)<>';') then begin
               Field:=Table.FieldList.AddNew;
               Field.Name:=NextToken(S);
               Field.DataType:=TFieldType(GetEnumValue(TypeInfo(TFieldType), NextToken(S)));
               if not (Field.DataType in [ftBoolean, ftInteger]) then begin
                  Field.Size:=StrToInt(NextToken(S));
               end
               else begin
                  NextToken(S);
               end;
               Field.Path:=NextToken(S);
               Delete(S, 1, 1);
               Field.Comm:=S;
            end;
            Inc(Ind)
         end;
         Inc(Ind);
      until Ind>=Struct.Count;
   end;

begin
   Result:=False;
   //Проверка входных параметров
   if not FileExists(InputFile) then begin
      MessageDlg(Format('Не найден файл "%s"', [InputFile]), mtError, [mbOk], 0);
      Exit;
   end;
   if not FileExists(OutputFile) then begin
      MessageDlg(Format('Не найден файл "%s"', [OutputFile]), mtError, [mbOk], 0);
      Exit;
   end;
   //Чтение информации о структуре таблиц
   FTableList.Clear;
   Struct:=TStringList.Create;
   try
      Struct.LoadFromFile(InputFile);
      ReadStruct(Struct, True);
      Struct.LoadFromFile(OutputFile);
      ReadStruct(Struct, False);
      Result:=True;
   finally
      Struct.Free;
   end;
end;

procedure TRegInt.SetGisunProxy(const Value: string);
begin
   FGisun.Proxy:=Value;
   FGisunProxy:=Value;
end;

procedure TRegInt.SetGisunUrl(Value: string);
begin
   FGisun.Url:=Value;
   FGisunUrl:=Value;
   FGisun.UpdateUrl(Value);
end;

procedure TRegInt.SetMessageSource(Value: string);
begin
   FMessageSource:=Value;
   FZags.MessageSource:=Value;
   FGisun.MessageSource:=Value;
   {$IFDEF ADD_WS_LOCAL}
     FLocal.MessageSource:=Value;
   {$ENDIF}
end;

procedure TRegInt.SetPostIsUpper(const Value: Boolean);
begin
  FPostIsUpper := Value;
end;

procedure TRegInt.SetZagsProxy(const Value: string);
begin
   FZags.Proxy:=Value;
   FZagsProxy:=Value;
end;

procedure TRegInt.SetZagsUrl(Value: string);
begin
   FZags.Url:=Value;
   FZagsUrl:=Value;
   FZags.UpdateUrl(Value);
end;

procedure TRegInt.SetLocalProxy(const Value: string);
begin
{$IFDEF ADD_WS_LOCAL}
  FLocal.Proxy:=Value;
  FLocalProxy:=Value;
{$ENDIF}
end;

procedure TRegInt.SetLocalUrl(Value: string);
begin
{$IFDEF ADD_WS_LOCAL}
   FLocal.Url:=Value;
   FLocalUrl:=Value;
   if FLocal.FService<>nil then begin
     FLocal.FRIO.URL:=Value;
   end;
{$ENDIF}
end;

{function TRegInt.StringToDate(DateTime: string): TDateTime;
var
   Year: Word;
   Month: Word;
   Day: Word;
begin
   Year:=StrToInt(Copy(DateTime, 1, 4));
   Month:=StrToInt(Copy(DateTime, 5, 2));
   Day:=StrToInt(Copy(DateTime, 7, 2));
   Result:=EncodeDate(Year, Month, Day);
end;}

//---------------------------------------------------------
procedure TRegInt.SetVErsion(const Value: Integer);
begin
   FVersion:=Value;
end;

//---------------------------------------------------------
procedure TRegInt.SetDbUserAsGIS(const Value: Boolean);
begin
  FDbUserAsGIS := Value;
end;
//---------------------------------------------------------
procedure TRegInt.SetPIN(const Value: String);
begin
  FPin:=Value;
end;
//---------------------------------------------------------
procedure TRegInt.SetPostUserName(const Value: Boolean);
begin
  FPostUserName := Value;
end;

//---------------------------------------------------------
function TRegInt.CheckLogon: Boolean;
begin
{$IFDEF MY_PROJECT}
  Result:=Gisun.CheckLogon;
{$ELSE}
  Result:=true;
{$ENDIF}
end;

{ TRegFieldList }

function TRegFieldList.Add(Item: TRegField): Integer;
begin
   Result:=FList.Add(Item);
end;
//------------------------------------------------------------
function TRegFieldList.AddNew: TRegField;
begin
   Result:=TRegField.Create;
   Add(Result);
end;
//------------------------------------------------------------
procedure TRegFieldList.Clear;
var
   I: Integer;
   Item: TRegField;
begin
   for I:=0 to Pred(GetCount) do begin
      Item:=GetItem(I);
      if Item<>nil then begin
         Item.Free;
      end;
   end;
   FList.Clear;
end;
//------------------------------------------------------------
constructor TRegFieldList.Create;
begin
   FList:=TList.Create;
end;
//------------------------------------------------------------
destructor TRegFieldList.Destroy;
begin
   Clear;
   FList.Free;
   inherited;
end;

function TRegFieldList.GetByName(Name: string): TRegField;
var
   I: Integer;
   Item: TRegField;
begin
   Result:=nil;
   for I:=0 to Pred(GetCount) do begin
      Item:=GetItem(I);
      if (Item<>nil) and SameText(Name, Item.Name) then begin
         Result:=Item;
         Break;
      end;
   end;
end;

function TRegFieldList.GetCount: Integer;
begin
   Result:=FList.Count;
end;
//------------------------------------------------------------
function TRegFieldList.GetItem(I: Integer): TRegField;
begin
   Result:=TRegField(FList[I]);
end;

{ TRegField }

constructor TRegField.Create;
begin

end;

destructor TRegField.Destroy;
begin
   inherited;
end;

{ TRegTable }

constructor TRegTable.Create;
begin
   FFieldList:=TRegFieldList.Create;
end;

function TRegTable.CreateMemTable: TDataSet;
var
   I,m: Integer;
   FieldDef: TFieldDef;
begin
   Result:=TkbmMemTable.Create(nil);
   for I:=0 to Pred(FFieldList.Count) do begin
      FieldDef:=Result.FieldDefs.AddFieldDef;
      FieldDef.Name:=FFieldList[I].Name;
      FieldDef.DataType:=FFieldList[I].DataType;
      if not (FieldDef.DataType in [ftBoolean, ftInteger]) then begin
         FieldDef.Size:=FFieldList[I].Size;
      end;
   end;
   {
   FieldDef:=Result.FieldDefs.AddFieldDef;
   FieldDef.Name:='COVER_MESSAGE_ID';
   FieldDef.DataType:=ftString;
   FieldDef.Size:=36;
   FieldDef:=Result.FieldDefs.AddFieldDef;
   FieldDef.Name:='COVER_MESSAGE_TIME';
   FieldDef.DataType:=ftDateTime;  }

   TkbmMemTable(Result).CreateTable;
//   m:=Result.FieldCount-3; // !!!

   for I:=0 to Pred(Result.FieldCount) do begin
//   for I:=0 to m do begin
      Result.Fields[I].DisplayLabel:=FFieldList[I].Comm;
   end;
//   Result.FieldByName('COVER_MESSAGE_ID').DisplayLabel:='Идентификатор сообщения';
//   Result.FieldByName('COVER_MESSAGE_TIME').DisplayLabel:='Дата и время сообщения';
   Result.Open;
end;

destructor TRegTable.Destroy;
begin
   FFieldList.Free;
   inherited;
end;

procedure TRegTable.ChangePath(sOldPath,sNewPath:String);
var
  i,n:Integer;
begin
   n:=Length(sOldPath);
   for i:=0 to Pred(FFieldList.Count) do begin
     if SameText(Copy(FFieldList[i].Path,1,n), sOldPath) then begin
       FFieldList[i].Path:=sNewPath+Copy(FFieldList[i].Path,n+1,Length(FFieldList[i].Path));
     end;
   end;
end;

function TRegTable.GetProp(Root: TObject; DataSet: TDataSet): Boolean;
var
   First: TObject;
   I: Integer;
   J,K: Integer;
   PropName: string;
   PropInfo: PPropInfo;
   PropType: PPTypeInfo;
   ClassName: string;
   DataField: TField;
   PropClass: TClass;
   Obj: TObject;
   IsGet: Boolean;
   sArrInd: string;
   cCode: string;
   cType: Integer;
   //
   Documents: wsGisun.documents;       //потому что массив document2
   ArrDoc: wsGisun.Array_Of_Document;  //а это массив document (раньше было одинаково)
   Lexema: wsGisun.LangValueList;
   Deaths: wsGisun.deaths;
   Burials: wsGisun.burials;

   function NextProp(var S: string): string;
   var
      I,j: Integer;
      P: Integer;
   begin
      sArrInd:='';
      cCode:='';
      cType:=0;
      Result:='';
      for I:=1 to Length(S) do begin
         if IsDelimiter('/\.', S, I) then begin
            Result:=Copy(S, 1, Pred(I));
            Delete(S, 1, I);
            j:=Pos('[',Result);
            if j>0 then begin
              sArrInd:=Copy(Result,j+1,Length(Result)-j-1);
              Result:=Copy(Result,1,j-1);
              P:=Pos(',', sArrInd);
              if P<>0 then begin
                cType:=StrToIntDef(Trim(Copy(sArrInd, 1, Pred(P))), 0);
                cCode:=Trim(Copy(sArrInd, Succ(P), Length(sArrInd)-P));
              end else begin
                cCode:=Trim(sArrInd);
              end;
            end;
            Break;
         end;
      end;
   end;

begin
   Deaths:=nil;
   Documents:=nil;
   Lexema:=nil;
   Result:=False;   
   First:=Root;
   for I:=0 to Pred(FFieldList.Count) do begin
      PropName:=FFieldList[I].Path;
      if PropName<>'X' then begin
         IsGet:=False;
         ClassName:=NextProp(PropName);
         if SameText(ClassName, First.ClassName) then begin
            Root:=First;
            repeat
               ClassName:=NextProp(PropName);
               if ClassName<>'' then begin
                  PropInfo:=GetPropInfo(Root, ClassName);
                  if PropInfo<>nil then begin
                     PropType:=PropInfo.PropType;
                     case PropType^.Kind of
                        tkDynArray: begin
                           if PropType^=TypeInfo(wsGisun.deaths) then begin
                             Deaths:=wsGisun.deaths(GetOrdProp(Root, PropInfo));
                             Root:=nil;
                             if (Deaths<>nil) and (Length(Deaths)>0) then begin
                               for J:=High(Deaths) downto Low(Deaths) do begin
                                 // в списке документов по смерти ищем активный документ
                                 for k:=Low(Deaths[J].documents) to High(Deaths[J].documents) do begin
                                   if Deaths[J].documents[k].active then begin
                                     Root:=Deaths[J];
                                     Break;
                                   end;
                                 end;
                                  {   было до 07.04.2016
                                    Root:=Deaths[J];
                                    Break;
                                  }
                               end;
                               if Root=nil
                                 then Root:=Deaths[High(Deaths)];
                             end;
                           end             
                           else if PropType^=TypeInfo(wsGisun.burials) then begin
                             Burials:=wsGisun.burials(GetOrdProp(Root, PropInfo));
                             Root:=nil;
                             if (Burials<>nil) and (Length(Burials)>0) then begin
                               for J:=High(Burials) downto Low(Burials) do begin
                                 // в списке документов по смерти ищем активный документ
                                 for k:=Low(Burials[J].documents) to High(Burials[J].documents) do begin
                                   if Burials[J].documents[k].active then begin
                                     Root:=Burials[J];
                                     Break;
                                   end;
                                 end;
                               end;                    
                               if Root=nil
                                 then Root:=Burials[High(Burials)];
                             end;
                           end
                           else if GetTypeData(PropType^)^.elType2^=TypeInfo(wsGisun.document) then begin
                              ArrDoc:=wsGisun.Array_Of_Document(GetOrdProp(Root, PropInfo));
                              Root:=nil;
                              if (ArrDoc<>nil) and (Length(ArrDoc)>0) then begin
                                 if cCode='' then begin
                                    Root:=ArrDoc[0];
                                 end
                                 else begin
                                    for J:=Low(ArrDoc) to High(ArrDoc) do begin
                                       if ((cType=0) or (cType=ArrDoc[J].document_type.type_)) and SameText(ArrDoc[J].document_type.code, cCode) then begin
//                                          if ArrDoc[J].active then begin
                                            Root:=ArrDoc[J];
                                            Break;
//                                          end;
                                       end;
                                    end;
                                 end;
                              end;
                           end
                           else if GetTypeData(PropType^)^.elType2^=TypeInfo(wsGisun.document2) then begin
                              Documents:=wsGisun.documents(GetOrdProp(Root, PropInfo));
                              Root:=nil;
                              if (Documents<>nil) and (Length(Documents)>0) then begin
                                 if cCode='' then begin
                                    Root:=Documents[0];
                                 end
                                 else begin
                                    for J:=Low(Documents) to High(Documents) do begin
                                       if ((cType=0) or (cType=Documents[J].document_type.type_)) and SameText(Documents[J].document_type.code, cCode) then begin
                                          Root:=Documents[J];
                                          Break;
                                       end;
                                    end;
                                 end;
                              end;
                           end
                           else if PropType^=TypeInfo(wsGisun.LangValueList) then begin
                              Lexema:=wsGisun.LangValueList(GetOrdProp(Root, PropInfo));
                              Root:=nil;
                              if (Lexema<>nil) and (Length(Lexema)>0) then begin
                                 if sArrInd='' then sArrInd:='RU';
                                 for J:=Low(Lexema) to High(Lexema) do begin
                                    if SameText(Lexema[J].lang, sArrInd) then begin
                                       Root:=Lexema[J];
                                       Break;
                                    end;
                                 end;
                              end;
                           end
                           else begin
                              Root:=nil;
                              ShowMessage(PropType^.Name+' '+FFieldList[I].Path);
                           end;
                        end;
                        tkClass: begin
                           Root:=GetObjectProp(Root, ClassName);
                        end;
                     else
                        Root:=nil;
                     end;
                  end
                  else begin
                     Root:=nil;
                  end;
               end;
            until (ClassName='') or (Root=nil);
            if (PropName<>'') and (Root<>nil) then begin
               DataField:=DataSet.FieldByName(FFieldList[I].Name);
               PropInfo:=GetPropInfo(Root, PropName);
               if PropInfo<>nil then begin
                  PropType:=PropInfo.PropType;
                  case PropType^.Kind of
                     //???tkEnumeration
                     //MarrFlag
                     //ParentsFlag
                     tkEnumeration: begin
                        Result:=True;
                        if GetTypeData(PropInfo^.PropType^)^.BaseType^=TypeInfo(Boolean) then begin
                           DataField.AsBoolean:=Boolean(GetOrdProp(Root, PropInfo));
                        end
                        else begin
                           DataField.AsInteger:=GetOrdProp(Root, PropInfo);
                        end;
                        IsGet:=True;
                     end;
                     tkInteger: begin
                        Result:=True;
                        DataField.AsInteger:=GetOrdProp(Root, PropInfo);
                        IsGet:=True;
                     end;
                     tkInt64: begin
                        Result:=True;
		        DataField.AsVariant:=GetInt64Prop(Root, PropInfo);
                        IsGet:=True;
                     end;
                     tkString, tkWChar, tkLString, tkWString: begin
                        Result:=True;
                        DataField.AsString:=GetStrProp(Root, PropInfo);
                        IsGet:=True;
                     end;
                     tkClass: begin
                        PropClass:=GetObjectPropClass(PropInfo);
                        Obj:=GetObjectProp(Root, PropInfo);
                        if (PropClass=wsGisun.Classifier) then begin
                           if Obj<>nil then begin
                              Result:=True;
                              DataField.AsString:=GetStrProp(Obj, 'Code');
                              IsGet:=True;
                           end;
                        end
                        else if PropClass=TXSDate then begin
                           if Obj<>nil then begin
                              Result:=True;
                              DataField.AsDateTime:=TXSDate(Obj).AsDate;
                              IsGet:=True;
                           end;
                        end
                        else begin
                           ShowMessage(GetEnumName(TypeInfo(TTypeKind), Ord(PropType^.Kind))+' '+FFieldList[I].Path);
                        end;
                     end;
                  else
                     ShowMessage(GetEnumName(TypeInfo(TTypeKind), Ord(PropType^.Kind))+' '+FFieldList[I].Path);
                  end;
               end;
            end;
         end;
         if not IsGet then begin
            //--ShowMessageFmt('Name="%s" Path="%s"', [FFieldList[I].Name, FFieldList[I].Path]);
         end;
      end;
   end;
end;

function TRegTable.SetProp(Root: TObject; DataSet: TDataSet): Boolean;
var
   First: TObject;
   I,cType,n,m, nTypeCode: Integer;
   PropName: string;
   sCode: string;
   PropInfo: PPropInfo;
   PropType: PPTypeInfo;
   ClassName,sArrInd,cCode: string;
   IsSet: Boolean;
   {
   Obj: TObject;
   }
   DataField: TField;
   PropClass: TClass;

   function NextProp(var S: string): string;
   var
      I,J,P: Integer;
   begin
      Result:='';
      sArrInd:='';
      cCode:='';
      cType:=0;
      for I:=1 to Length(S) do begin
         if IsDelimiter('/\.', S, I) then begin
            Result:=Copy(S, 1, Pred(I));
            Delete(S, 1, I);
            j:=Pos('[',Result);
            if j>0 then begin
              sArrInd:=Copy(Result,j+1,Length(Result)-j-1);
              Result:=Copy(Result,1,j-1);
              P:=Pos(',', sArrInd);
              if P<>0 then begin
                 cType:=StrToIntDef(Trim(Copy(sArrInd, 1, Pred(P))), 0);
                 cCode:=Trim(Copy(sArrInd, Succ(P), Length(sArrInd)-P));
              end else begin
                 cCode:=Trim(sArrInd);
              end;
            end;
            Break;
         end;
      end;      
      if (S<>'') and (Result='') then begin
        j:=Pos('[',S);
        if j>0 then begin
          sArrInd:=Copy(S,j+1,Length(S)-j-1);
          S:=Copy(S, 1, j-1);
          P:=Pos(',', sArrInd);
          if P<>0 then begin
             cType:=StrToIntDef(Trim(Copy(sArrInd, 1, Pred(P))), 0);
             cCode:=Trim(Copy(sArrInd, Succ(P), Length(sArrInd)-P));
          end else begin
             cCode:=Trim(sArrInd);
          end;
        end;
      end;
   end;

   function GetObject(Root: TObject; PropName: string): TObject; overload;
   begin
      Result:=GetObjectProp(Root, PropName);
      if Result=nil then begin
         Result:=GetObjectPropClass(Root, PropName).Create;
         SetObjectProp(Root, PropName, Result);
      end;
   end;

   function GetObject(Root: TObject; PropInfo: PPropInfo): TObject; overload;
   begin
      Result:=GetObjectProp(Root, PropInfo);
      if Result=nil then begin
         Result:=GetObjectPropClass(PropInfo).Create;
         SetObjectProp(Root, PropInfo, Result);
      end;
   end;

   procedure SetClassNameLex;
   var
      Field: TField;
      c: wsGisun.Classifier;
      lexema: wsGisun.LangValueList;
   begin
      if DataField.AsString='0' then begin
         Field:=DataSet.FindField(DataField.FieldName+'_LEX');
         if (Field<>nil) and (Trim(Field.AsString)<>'') then begin
           //------ RU ----------___------------------------------
           c:=wsGisun.Classifier(GetObject(Root, PropInfo));
           SetLength(lexema, 1);
           lexema[0]:=wsGisun.value.Create;
           lexema[0].Text:=Trim(Field.AsString);
           lexema[0].lang:='ru';
           {
           //------ BE -------------------------------------------
           Field:=DataSet.FindField(DataField.FieldName+'_LEX_B');
           if (Field<>nil) and (Trim(Field.AsString)<>'') then begin
             SetLength(lexema, 2);
             lexema[1]:=wsGisun.value.Create;
             lexema[1].Text:=Trim(Field.AsString);
             lexema[1].lang:='be';
           end;
           }
           c.lexema:=lexema;
         end;
      end;
   end;
begin
   Result:=False;
   First:=Root;
   for I:=0 to Pred(FFieldList.Count) do begin
      PropName:=FFieldList[I].Path;
      DataField:=DataSet.FieldByName(FFieldList[I].Name);
      //---- !!! -------------------------------------------------
      if Pos('_certificate_data.', PropName)> 0 then begin        // для невыгрузки пустого свидетельства
        if DataField.IsNull or (DataField.AsString='') then begin
          continue;
        end;
      end;
      //----------------------------------------------------------

      if PropName<>'X' then begin
         IsSet:=False;
         ClassName:=NextProp(PropName);
         if SameText(ClassName, First.ClassName) then begin
            Root:=First;
            repeat
               ClassName:=NextProp(PropName);
               if ClassName<>'' then begin
                  //нет проверки, что это tkClass
                  Root:=GetObject(Root, ClassName);
                  {
                  Obj:=GetObjectProp(Root, ClassName);
                  if Obj=nil then begin
                     Obj:=GetObjectPropClass(Root, ClassName).Create;
                     SetObjectProp(Root, ClassName, Obj);
                  end;
                  Root:=Obj;
                  }
               end;
            until ClassName='';
            if PropName<>'' then begin
               PropInfo:=GetPropInfo(Root, PropName);
               if PropInfo<>nil then begin
                  PropType:=PropInfo.PropType;
                  case PropType^.Kind of
                     tkEnumeration: begin
                        Result:=True;
                        SetOrdProp(Root, PropInfo, DataField.AsInteger);
                        IsSet:=True;
                     end;
                     tkInteger: begin
                        Result:=True;
                        SetOrdProp(Root, PropInfo, DataField.AsInteger);
                        IsSet:=True;
                     end;
                     tkString, tkWChar, tkLString, tkWString: begin
                        Result:=True;
                        SetStrProp(Root, PropInfo, DataField.AsString);
                        IsSet:=True;
                     end;
                     tkClass: begin
                        PropClass:=GetObjectPropClass(PropInfo);
                        {$IFDEF ADD_WS_LOCAL}
                        if (PropClass=wsGisun.Classifier) or (PropClass=wsLocal.Classifier) then begin
                        {$ELSE}
                        if (PropClass=wsGisun.Classifier) then begin
                        {$ENDIF}
                           {
                           Obj:=GetObjectProp(Root, PropInfo);
                           if Obj=nil then begin
                              Obj:=PropClass.Create;
                              SetObjectProp(Root, PropInfo, Obj);
                           end;
                           SetStrProp(Obj, 'Code', DataField.AsString);
                           }
                           IsSet:=True;
                           if DataField.AsString<>'' then begin
                             m:=Pos('#',DataField.AsString);   //  "1363636#131"
                             if m>0 then begin
                               sCode:=Trim(Copy(DataField.AsString,1,m-1));
                               nTypeCode:=StrToIntDef(Trim(Copy(DataField.AsString,m+1,Length(DataField.AsString))),0);
                             end else begin
                               sCode:=DataField.AsString;
                               nTypeCode:=0;
                             end;
                             SetStrProp(GetObject(Root, PropInfo), 'Code', sCode);
                             if nTypeCode=0 then begin  // !!! если тип не определен в самом коде !!!
                               if SameText(PropName, 'message_type') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctActType);
                               end else if SameText(PropName, 'message_source') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctZags);
                               end else if SameText(PropName, 'act_type') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctActType);
                               end else if SameText(PropName, 'authority') then begin
                                  //ctMVD
  //                                ShowMessage(inttostr(Integer(ActKind)));
                                  if sArrInd='' then begin     //   authority или authority[ms] или authority[141]
                                    n:=ctZags;
                                  end else begin
                                    if sArrInd='ms' then begin  // источник messagesource
                                      {$IF Defined(LAIS) or Defined(ZAGS) }
                                        n:=TYPESOURCE_ZAGS;
                                      {$ELSE}
                                         {$IFDEF ZAH}
                                           n:=TYPESOURCE_ZAH;
                                         {$ELSE}
                                           {$IFDEF OPEKA}
                                              n:=TYPESOURCE_OPEKA;
                                           {$ENDIF}
                                         {$ENDIF}
                                      {$IFEND}
                                    end else begin
                                      n:=StrToInt(sArrInd);       // !!!  тип классификатора в sArrInd [131]
                                    end;
                                  end;
                                  if (Root is wsGisun.Document) then begin    // !!!
                                    SetOrdProp(GetObject(Root, PropInfo), 'Type_', n);
                                    SetClassNameLex;
                                  end else if (Root is wsGisun.ActData) then begin
                                    SetOrdProp(GetObject(Root, PropInfo), 'Type_', n);
                                    SetClassNameLex;
                                  end else begin
                                    SetOrdProp(GetObject(Root, PropInfo), 'Type_', n);
                                  end;
                               end else if SameText(PropName, 'document_type') then begin
                                 if sArrInd='' then n:=ctDocType else n:=StrToInt(sArrInd);       // !!!  тип классификатора в sArrInd [131]
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', n)
                               end else if SameText(PropName, 'sex') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctPol);
                               end else if SameText(PropName, 'citizenship') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctCountry);
                               end else if SameText(PropName, 'status') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctStatus);
                               end else if SameText(PropName, 'country_b') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctCountry);
                                 //SetClassNameLex;
                               end else if SameText(PropName, 'type_city_b') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctTypeCity);
                               end else if SameText(PropName, 'death_cause') then begin
                                  SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctDeathCause);
    //                              if Pos('.',DataField.AsString)=0
    //                                then SetOrdProp(GetObject(Root, PropInfo), 'Type_', 85)             // !!!
    //                                else SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctDeathCause);
                               end else if SameText(PropName, 'country_d') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctCountry);
                               end else if SameText(PropName, 'type_city_d') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctTypeCity);
                               // burial (захоронение)
                               end else if SameText(Copy(PropName,1,7), 'country') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctCountry);
                               end else if SameText(PropName, 'area') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctObl);
                               end else if SameText(PropName, 'region') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctRaion);
                               end else if SameText(PropName, 'soviet') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctSelsovet);
                               end else if SameText(PropName, 'city') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctNP);
                               end else if SameText(PropName, 'burial_name') then begin
                                 SetOrdProp(GetObject(Root, PropInfo), 'Type_', ctZah);
                               end;
                             end else begin
                               SetOrdProp(GetObject(Root, PropInfo), 'Type_', nTypeCode);
                             end; // end nTypeCode=0
                           end;
                        end
                        else if PropClass=TXSDate then begin
                           if DataField.IsNull then begin
//                             TXSDate(GetObject(Root, PropInfo)).XSToNative('');
                           end else begin
                             TXSDate(GetObject(Root, PropInfo)).AsDate:=DataField.AsDateTime;
                           end;
                           //SetFloatProp(GetObject(Root, PropInfo), 'AsDate', DataField.AsDateTime);
                           IsSet:=True;
                        end
                        else begin
                           ShowMessage(GetEnumName(TypeInfo(TTypeKind), Ord(PropType^.Kind))+' '+FFieldList[I].Path);
                        end;
                     end;
                  else
                     ShowMessage(GetEnumName(TypeInfo(TTypeKind), Ord(PropType^.Kind))+' '+FFieldList[I].Path);
                  end;
               end;
            end;
         end;
         if not IsSet then begin
            //--ShowMessageFmt('Name="%s" Path="%s"', [FFieldList[I].Name, FFieldList[I].Path]);
         end;
      end;
   end;
end;

{ TRegTableList }

function TRegTableList.Add(Item: TRegTable): Integer;
begin
   Result:=FList.Add(Item);
end;

function TRegTableList.AddNew: TRegTable;
begin
   Result:=TRegTable.Create;
   Add(Result);
end;

procedure TRegTableList.Clear;
var
   I: Integer;
   Item: TRegTable;
begin
   for I:=0 to Pred(GetCount) do begin
      Item:=GetItem(I);
      if Item<>nil then begin
         Item.Free;
      end;
   end;
   FList.Clear;
end;

constructor TRegTableList.Create;
begin
   FList:=TList.Create;
end;

destructor TRegTableList.Destroy;
begin
   Clear;
   FList.Free;
   inherited;
end;

function TRegTableList.Find(IsInput: Boolean; ActKind: TActKind; Operation: TOperation): TRegTable;
var
   I: Integer;
   Item: TRegTable;
begin
   Result:=nil;
   for I:=0 to Pred(GetCount) do begin
      Item:=GetItem(I);
      if (Item<>nil) and (Item.IsInput=IsInput) and (Item.ActKind=ActKind) and (Item.Operation=Operation) then begin
         Result:=Item;
         Break;
      end;
   end;
end;

function TRegTableList.GetCount: Integer;
begin
   Result:=FList.Count;
end;

function TRegTableList.GetItem(I: Integer): TRegTable;
begin
   Result:=TRegTable(FList[I]);
end;

end.
