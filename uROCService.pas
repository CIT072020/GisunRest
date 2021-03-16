unit uROCService;

interface

uses
 Classes, DB,
 StdCtrls,
 kbmMemTable,
 DBFunc,
 adstable, adsdata, adscnnct, ace,
 superdate, superobject, supertypes,
 {$IFDEF SYNA} httpsend,  {$ENDIF}
 SasaINiFile, FuncPr;

const
  CRLF     = string(#13#10);
  INI_NAME = 'ExchgPars.ini';

  // Секции INI-файла
  SCT_ADMIN   = 'ADMIN';
  SCT_HOST    = 'HOST';
  SCT_SECURE  = 'SECURE';
  // Секции INI-файла для описания таблиц
  SCT_TBL_INS = 'TABLE_INDNUM';
  SCT_TBL_DOC = 'TABLE_DOCSETDATA';
  SCT_TBL_CLD = 'TABLE_CHILD';
  SCT_TBL_NSI = 'TABLE_NSI';

  // функции запросов к серверу
  GET_LIST_ID  = 1;
  GET_LIST_DOC = 2;
  GET_NSI      = 3;
  POST_DOC     = 4;

  // Тип списочных данных для GET
  TLIST_FIO = Integer(1);
  TLIST_INS = Integer(2);

  RES_HOST     = 'https://a.todes.by:13555';
  RES_GENPOINT = '/village-council-service/api';
  RES_NSI      = '/kluni-service/api';
  RES_VER      = '/v1';

  RESOURCE_LISTID_PATH = '/movements';
  RESOURCE_LISTDOC_PATH  = '/data';
  RESOURCE_POSTDOC_PATH = '/data/save';
  RESOURCE_NSICNTT_PATH = '/kl_uni/with_links';


  // Имена таблиц
  MT_INS   = 'INS';
  MT_DOCS  = 'DOCS';
  MT_CHILD = 'CHILD';
  MT_NSI   = 'NSI';

  // Режим создания выходных парметров
  NO_DATA   = 1;
  DATA_ONLY = 2;
  NSI_ONLY  = 3;

  // Режим вывода очередной отладочной записи
{
  DEB_CLEAR    = 1;
  DEB_NEWLINE  = 2;
  DEB_SAMELINE = 3;
}

  // Режим формирования ЭЦП
  SIGN_WITH_DATA  = 1;
  SIGN_WITH_CERT  = 2;
  SIGN_ONLY       = 3;

  // Режим работы с RAW ЭЦП
  SIGN_WITH_ASN  = 1;
  SIGN_NO_ASN    = 2;


  // Коды ошибок
  UERR_GET_NSI = 600;
  UERR_CVRT_NSI = 650;
  UERR_GET_INDNOMS = 700;
  UERR_GET_DEPART = 800;
  UERR_GET_ACTUAL = 900;
  UERR_POST_REG = 1000;

type
  THostReg = class(TObject)
  // путь к сервису
    URL      : string;
    GenPoint : string;
    NsiURL   : string;
    NsiPoint : string;
    Ver      : string;
  end;
  
type
  TAHTTPSend = class(THTTPSend)
  public
    function AHTTPMethod(const Method, URL: string; Auth : string = '') : Boolean;
  end;


function CT(s: string) : string;
function UnixStrToDateTime(sDate:String):TDateTime;
function Delphi2JavaDate(d:TDateTime):SuperInt;
function MemStream2Str(const MS: TMemoryStream; const FullStream: Boolean = True; const ADefault: string = ''): string;

function CreateMemTable(sTableName: string; Meta : TSasaIniFile; MetaSect: String; AutoCreate: Boolean = True; AutoOpen: Boolean = True): TDataSet;
procedure ShowDeb(const s: string; const ClearAll: Boolean = True);
function FullPath(H : THostReg; Func : Integer; Pars : string) : string;

procedure LeaveOnly1(ds: TDataSet);
function SafeNewNsi(Path, TName: string; WorkF: string = ''): string;
function ADSTCreateOnDefs(TName : string; FDefs : TFieldDefs; var StrInStr : string) : string;

var
  ShowM : TMemo;

implementation

uses
  Types,
  SysUtils,
  FileUtil,
  StrUtils;


function TAHTTPSend.AHTTPMethod(const Method, URL: string; Auth : string = '') : Boolean;
begin
  if (Auth <> '') then
    Self.Headers.Add('Authorization:' + Auth);
  Result := inherited HTTPMethod(Method, URL);
end;


// Обработка имен полей
function CT(s: string): string;
begin
  Result := s;
end;

function UnixStrToDateTime(sDate:String):TDateTime;
begin
   Result := 0;
   if (sDate <> 'null') then
     Result := JavaToDelphiDateTime(StrToInt64(sDate));
end;

function Delphi2JavaDate(d:TDateTime):SuperInt;
begin
  Result := DelphiToJavaDateTime(d);
end;

function MemStream2Str(const MS: TMemoryStream; const FullStream: Boolean = True; const ADefault: string = ''): string;
var
  NeedLen: Integer;
begin
  if Assigned(MS) then
  try
    if (FullStream = True) then
      MS.Position := 0;
    NeedLen := MS.Size - MS.Position;
    SetLength(Result, NeedLen);
    MS.Read(Result[1], NeedLen);
  except
    Result := ADefault;
  end
  else
    Result := ADefault;
end;

//---------------------------------------------
function CreateMemTable(sTableName: string; Meta : TSasaIniFile; MetaSect: String; AutoCreate: Boolean = True; AutoOpen: Boolean = True): TDataSet;

function GetFieldSize(sLen: string): Integer;
begin
  if IsAllDigit(sLen) then
    Result := StrToIntDef(sLen, 0)
  else
    Result := Meta.ReadInteger('CONST', sLen, 0);
end;

var
  I, n, m: Integer;
  FLastError, FieldName, s, sOpis, sKomm: string;
  FieldType: TFieldType;
  FieldSize: Integer;
  FieldDef: TFieldDef;
  //fld: TField;
  tb: TkbmMemTable;
  arr, arrFields: TArrStrings;
  MetaDef,
  slAdd: TStringList;
begin
  FLastError := '';
  Result := nil;

  MetaDef := TStringList.Create;
  Meta.ReadSectionValues(MetaSect, MetaDef);

  if MetaDef.Count > 0 then begin
    slAdd := TStringList.Create;
    tb := TkbmMemTable.Create(nil);
    tb.Name := sTableName;
    tb.Tag := Integer(slAdd);
    tb.AutoIncMinValue := 1;

    for I := 0 to MetaDef.Count - 1 do begin
      FieldName := MetaDef.Names[I];
      s := MetaDef.ValueFromIndex[I];
      n := Pos('|', s);
      if n = 0 then begin
        sOpis := Trim(s);
        sKomm := '';
      end
      else begin
        sOpis := Trim(Copy(s, 1, n - 1));
        sKomm := Copy(s, n + 1, Length(s));
        n := Pos('[', sKomm);
        m := PosEx(']', sKomm, n + 1);
        if (n > 0) and (m > 0) then
          sKomm := Trim(Copy(sKomm, n + 1, m - n - 1))
        else
          sKomm := '';
      end;
      StrToArr(sOpis, arr, ',', false);
      SetLength(arr, 2);
      //FieldSize := 0;
      if StringToFieldType(arr[0], FieldType) then begin
        FieldSize := GetFieldSize(arr[1]);
        FieldDef := tb.FieldDefs.AddFieldDef;
        FieldDef.Name := FieldName;
        FieldDef.DataType := FieldType;
        if FieldType <> ftBoolean then
          FieldDef.Size := FieldSize;
        if (FieldDef.DataType = ftString) and (FieldSize = 0) then begin
          FLastError := MetaDef.Strings[I];
          break;
        end;
        if sKomm <> '' then
          slAdd.Add(FieldDef.name + '=' + sKomm);
      end
      else begin
        FLastError := MetaDef.Strings[I];
        break;
      end;
    end;


  if (Length(FLastError) = 0) then begin
    if AutoCreate then
      tb.CreateTable;
    if AutoOpen then
      tb.Open;
    Result := tb;
    //FListObject.AddObject(sTableName, tb);
  end
  else begin
    slAdd.Free;
    tb.Free;
  end;

  end
  else
    FLastError := 'Meta-Описание не найдено!';

  MetaDef.Free;
end;


// Вывод отладки в Memo
procedure ShowDeb(const s: string; const ClearAll: Boolean = True);
var
  AddS: string;
  //Pos  : TPoint;
begin
  AddS := '';
  if (ClearAll = True) then
    ShowM.Text := ''
  else
    AddS := CRLF;
  ShowM.Text := ShowM.Text + AddS + s;
  //Pos := ShowM.CaretPos;
end;

function FullPath(H : THostReg; Func : Integer; Pars : string) : string;
var
  UrlDefault,
  sr,
  s : string;
begin
  Result     := '';
  UrlDefault := H.URL;
  s          := H.GenPoint;
  case Func of
    GET_LIST_ID  : sr := RESOURCE_LISTID_PATH;
    GET_LIST_DOC : sr := RESOURCE_LISTDOC_PATH;
    POST_DOC     : sr := RESOURCE_POSTDOC_PATH;
  else
    if (Func = GET_NSI) then begin
      s  := H.NsiPoint;
      sr := RESOURCE_NSICNTT_PATH;
      UrlDefault := H.NsiURL;
    end;
  end;
  if ( Length(sr) > 0) then
    Result := UrlDefault + s + H.Ver + sr + Pars;

end;




procedure LeaveOnly1(ds: TDataSet);
var
  x : Variant;
begin

  x := DS.FieldValues['MID'];
  ds.First;
  while (ds.RecordCount > 1)AND(not ds.Eof) do begin
    if (ds.FieldValues['MID'] = x) then
      ds.Next
    else
      ds.Delete;
  end;
end;


function FieldType2StrSQL(T: TFieldType): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to ADS_MAX_FIELD_TYPE - 1 do
    if (AdsDataTypeMap[i] = T) then begin
      Result := ArrSootv[i].Name;
      Break;
    end;
end;

// Создание символьной строки с описанием структуры ADS-таблицы
// Result   - для SQL CREATE TABLE
// StrInStr - для AdsCreateTable
function ADSTCreateOnDefs(TName : string; FDefs : TFieldDefs; var StrInStr : string) : string;
var
  MaxF,
  i : Integer;
  sSizeSQL,
  sSizeACr,
  sACr,
  sSQL : string;
begin
  MaxF  := FDefs.Count;
  sSQL := '';
  sACr := '';
  for i := 0 to MaxF - 1 do begin
    case FDefs[i].DataType of
      ftString:
      begin
        sSizeSQL := Format('(%d)', [FDefs[i].Size]);
        sSizeACr := Format(',%d', [FDefs[i].Size]);
      end;
    else
      sSizeSQL := '';
      sSizeACr := '';
    end;
    sSQL := sSQL + Format('%s %s%s,', [ FDefs[i].Name, FieldType2StrSQL(FDefs[i].DataType), sSizeSQL]);
    sACr := sACr + Format('%s, %s %s;', [ FDefs[i].Name, ArrStr2Fld[Integer(FDefs[i].DataType)].Name, sSizeACr]);
  end;
  // Последней была запятая
  sSQL[Length(sSQL)] := ')';
  StrInStr := sACr;
  Result := Format('CREATE TABLE "%s" (%s AS FREE TABLE ', [TName, sSQL]);
end;

// Перезапись существующей таблицы
function SafeNewNsi(Path, TName: string; WorkF: string = ''): string;
const
  TMP_ADD = 'Upd';
var
  ErrDel: Boolean;
  RealName, TmpName : string;
begin
  Result := TName;
  try
    if (WorkF = '') then begin
      if (FileExists(Path + TName + '.adt') or FileExists(Path + TName + '.adm')) then begin
        Result := TMP_ADD + TName;
        ErrDel := DeleteFiles(Path + Result + '.ad?');
      end;
    end
    else begin
    // Переименовать при необходимости
      if (TName <> WorkF) then begin
        RealName := Path + TName;
        TmpName := Path + TMP_ADD + TName;
        ErrDel := DeleteFiles(RealName + '.ad?');
        ErrDel := RenameFile(TmpName + '.adt', RealName + '.adt');
        if FileExists(TmpName + '.adm') then begin
          ErrDel := RenameFile(TmpName + '.adm', RealName + '.adm');
        end;
      end;
    end;
  except
  end;
end;




end.
