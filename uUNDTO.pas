unit uUNDTO;

interface

uses
  SysUtils,
  Classes,
  DB,
  Variants,
  superobject,
  superdate,
  FuncPr,
  uROCService;

type
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
    FJSONStream.WriteString('"cover":{' + '"message_type":{"code": "88","type":-2},' + '"message_source":{"code": "7689","type": 80},' + '"agreement":{"operator_info": "Организация адрес", "target":"верификация персональных данных","rights": [201,703,208,480,481,482,490,491,527,528,252,465,466,516,517],' + '"issue_date": "2019-12-07T13:22:09.619+03:00", "expiry_date": "2023-12-07T13:22:09.619+03:00", "assignee_persons": ["инспектор Иванов", "начальник инспектора Петров"]},' + '"dataset": [15]}');
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






end.
 