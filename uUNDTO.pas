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

const
  BPLC_WITH_BY  = 1;
  BPLC_RU_ONLY  = 2;
  BPLC_RU_NOCTZ = 3;

type
  TActPostBoby = function(IDS : TDataSet) : string;
  TMakePostBoby = function(IDS : TDataSet) : string of object;

  // Классификатор
  TClassifier = class
  private
  public
    // Для конвертации DataSet -> String(JSON)
    class function SetCT(const ACode: string; AType: integer; IsBraces: Boolean = True): string;
    class function SetCTL(const ACode: string; AType: integer; const Lex : string; Lang : string = 'ru'; IsBraces: Boolean = True): string;

    // Для конвертации SuperObject -> DataSet
    class function FindRUName(LexValArr: ISuperObject; const ALang: string = 'RU'): string;
    class procedure SObj2DSSetTKN(SOClsf: ISuperObject; ODS: TDataSet; const Pfx : string; NeedType : Boolean = True);
  end;

  // Базовый набор для преобразований DataSet -> JSON
  TDS2JSON = class
  private
  public
    class function CourtDec(IDS: TDataSet): string;
    class function MakeBirthPlace(IDS : TDataSet; Pfx : string = ''; Mode : integer = 1) : string;
    class function MakeActData(IDS : TDataSet; ActName : string; Pfx : string = 'ACT_') : string;
    class function MakeDocCertif(IDS : TDataSet; const DocName, DocType : string; Pfx : string = 'DOC_') : string;
  end;


  // Базовый набор реквизитов персональных данных
  TPersData = class
  private
  public
    // Для записи в JSON-строку
    class function DS2JsonMin(IDS: TDataSet; Pfx: string = ''): string;

    // Для записи в выходные DataSet

    class procedure SObj2DSErr(Err: ISuperObject; ODS: TDataSet);
    class procedure SObj2DSBurs(Burs: ISuperObject; ODS: TDataSet);
    class procedure SObj2DSActDcs(ActDcs: ISuperObject; ODS: TDataSet);
    class procedure SObj2DSDcsPlace(DcsPlace: ISuperObject; ODS: TDataSet);
    class procedure SObj2DSDeaths(Deaths: ISuperObject; ODS: TDataSet);
    class procedure SObj2DSAddress(SOPersData: ISuperObject; ODS: TDataSet);
    class procedure SObj2DSPasp(DocsArr: ISuperObject; ODS: TDataSet; ExactType : string = '');

    class procedure SObj2DSBPlace(SOPersData: ISuperObject; ODS: TDataSet);

    class procedure SObj2DSPersData(SOPersData: ISuperObject; ODS: TDataSet; FullSet : Boolean = True);
  end;

  // Свидетельство о рождении
  TActBirth = class(TPersData)
  private
    class function BirthDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string; Mode : Integer = 1) : string;
  public
    class function BirthDS2Json(IDS : TDataSet) : string;
  end;

  // Свидетельство об установлении отцовства
  TActAffil = class(TPersData)
  private
    class function AffilDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string; Mode : Integer = 1) : string;
  public
    class function AffilDS2Json(IDS : TDataSet) : string;
  end;

  // Свидетельство о браке
  TActMarr = class(TPersData)
  private
    class function MarrDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string) : string;
  public
    class function MarrDS2Json(IDS : TDataSet) : string;
  end;

  // Свидетельство о смерти
  TActDecease = class(TPersData)
  private
    class function DeceaseDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string; Mode : Integer = 1) : string;
    class function DeceaseDS2JsonDCD(IDS : TDataSet) : string;
  public
    class function DeceaseDS2Json(IDS : TDataSet) : string;
  end;
  // Свидетельство о расторжении брака
  TActDvrc = class(TPersData)
  private
    class function DvrcDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string) : string;
  public
    class function DvrcDS2Json(IDS : TDataSet) : string;
  end;

  // Свидетельство о смене ФИО
  TActChgName = class(TPersData)
  private
    class function ChgNameDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string) : string;
  public
    class function ChgNameDS2Json(IDS : TDataSet) : string;
  end;



implementation

// Код - тип из справочника
class function TClassifier.SetCT(const ACode: string; AType: integer; IsBraces: Boolean = True): string;
begin
  Result := Format('"code":"%s","type":%d', [ACode, AType]);
  if (IsBraces) then
    Result := '{' + Result + '}';
end;

// Код - тип - лексема из справочника
class function TClassifier.SetCTL(const ACode: string; AType: integer; const Lex : string; Lang : string = 'ru'; IsBraces: Boolean = True): string;
begin
  Result := Format('"code":"%s","type":%d,"lexema":{"value":["value":"%s","lang":"%s"]}', [ACode, AType, Lex, Lang]);
  if (IsBraces) then
    Result := '{' + Result + '}';
end;


// Поиск среди символьных наименований нужного языка
class function TClassifier.FindRUName(LexValArr: ISuperObject; const ALang: string = 'RU'): string;
var
  i, iMax: Integer;
  x: ISuperObject;
begin
  Result := '';
  iMax := LexValArr.AsArray.Length - 1;
  for i := 0 to iMax do begin
    x := LexValArr.AsArray.O[i];
    if (UpperCase(x.S['lang']) = ALang) then begin
      Result := x.S['value'];
      Break;
    end;
  end;
end;

// Тип-код-наименование из справочника
class procedure TClassifier.SObj2DSSetTKN(SOClsf: ISuperObject; ODS: TDataSet; const Pfx : string; NeedType : Boolean = True);
begin
  with ODS do begin
    if (NeedType) then
      FieldByName('T_' + Pfx).AsString := IntToStr(SOClsf.I['type']);
    FieldByName('K_' + Pfx).AsString   := SOClsf.S['code'];
    FieldByName('N_' + Pfx).AsString   := FindRUName(SOClsf.O['lexema'].O['value']);
  end;
end;


// Место рождения
// 1 - использовать By, 2 - только русский
class function TDS2JSON.MakeBirthPlace(IDS : TDataSet; Pfx : string = ''; Mode : integer = BPLC_WITH_BY) : string;
var
  s : string;
begin
  s := '"country_b":' +
    TClassifier.SetCT(IDS.FieldByName(Pfx + 'GOSUD').AsString, 8);
  s := s + Format(',"area_b":"%s","region_b":"%s","city_b":"%s",',[
    IDS.FieldByName(Pfx + 'OBL').AsString,
    IDS.FieldByName(Pfx + 'RAION').AsString,
    IDS.FieldByName(Pfx + 'GOROD').AsString]);

  if (Mode = BPLC_WITH_BY) then
    s := s + Format('"area_b_bel":"%s","region_b_bel":"%s","city_b_bel":"%s",', [
      IDS.FieldByName(Pfx + 'OBL_B').AsString,
      IDS.FieldByName(Pfx + 'RAION_B').AsString,
      IDS.FieldByName(Pfx + 'GOROD_B').AsString]);

  Result := s + '"type_city_b":' + TClassifier.SetCT(IDS.FieldByName(Pfx + 'TIP_GOROD').AsString, 68);
end;

// Тип-орган-номер-дата Описание зафиксированного акта
class function TDS2JSON.MakeActData(IDS: TDataSet; ActName: string; Pfx: string = 'ACT_'): string;
var
  org, s: string;
begin
  s := Format('"%s":{"act_type":%s,', [ActName, TClassifier.SetCT(IDS.FieldByName(Pfx + 'TIP').AsString, 82)]);
  try
    org := IDS.FieldByName(Pfx + 'ORGAN').AsString;
    if (StrToInt(org) <= 0) then begin
      org := IDS.FieldByName(Pfx + 'ORGAN_LEX').AsString;
      org := TClassifier.SetCTL('0', 80, org);
    end
    else
      org := TClassifier.SetCT(org, 80);
  except
    org := '';
  end;

  if (Length(org) = 0) then
    org := TClassifier.SetCT('0', 80);

  Result := s + '"authority":' + org + ',' +
    Format('"date":"%s",', [FormatDateTime('yyyy-mm-dd', IDS.FieldByName(Pfx + 'DATE').AsDateTime)]) +
    Format('"number":"%s"}', [IDS.FieldByName(Pfx + 'NOMER').AsString]);
end;

// Тип-орган-номер-дата Описание подтверждающего документа
// Описание подтверждающего документа-сертификата
class function TDS2JSON.MakeDocCertif(IDS : TDataSet; const DocName, DocType : string; Pfx : string = 'DOC_') : string;
begin
  Result := Format('"%s":{"document":{"document_type":%s,"authority":%s,', [DocName,
    TClassifier.SetCT(DocType, 37), TClassifier.SetCT(IDS.FieldByName(Pfx + 'ORGAN').AsString, 80)]) +
    Format('"date_of_issue":"%s",', [FormatDateTime('yyyy-mm-dd', IDS.FieldByName(Pfx + 'DATE').AsDateTime) ]) +
    Format('"series":"%s",', [ IDS.FieldByName(Pfx + 'SERIA').AsString ]) +
    Format('"number":"%s"}}', [ IDS.FieldByName(Pfx + 'NOMER').AsString ]);
end;

// Решение суда
class function TDS2JSON.CourtDec(IDS: TDataSet): string;
var
  s: string;
begin
  try
    s := Format('{"court_name":"%s","court_decision_date":"%s","comment":"%s"}', [
      IDS.FieldByName('SUD_NAME').AsString,
      IDS.FieldByName('SUD_DATE').AsString,
      IDS.FieldByName('SUD_COMM').AsString]);
  except
    s := '';
  end;
  Result := s;
end;


class function TPersData.DS2JsonMin(IDS: TDataSet; Pfx: string = ''): string;
begin
  with IDS do begin
    Result := Format('"identif":"%s","last_name":"%s","name":"%s","patronymic":"%s","sex":%s,"birth_day":"%s"',
      [FieldByName(Pfx + 'IDENTIF').AsString, FieldByName(Pfx + 'FAMILIA').AsString, FieldByName(Pfx + 'NAME').AsString,
       FieldByName(Pfx + 'OTCH').AsString, TClassifier.SetCT(IDS.FieldByName(Pfx + 'POL').AsString, 32),
       FieldByName(Pfx + 'DATER').AsString]);

    Result := Result + Format(',"last_name_bel":"%s","name_bel":"%s","patronymic_bel":"%s"',
      [FieldByName(Pfx + 'FAMILIA_B').AsString, FieldByName(Pfx + 'NAME_B').AsString, FieldByName(Pfx + 'OTCH_B').AsString]);
  end;
end;


// Место рождения
class procedure TPersData.SObj2DSBPlace(SOPersData: ISuperObject; ODS: TDataSet);
begin
  with ODS do begin
    TClassifier.SObj2DSSetTKN(SOPersData.O['country_b'], ODS, 'GOSUD_R');

    FieldByName('OBL_R').AsString     := SOPersData.S['area_b'];
    FieldByName('OBL_B_R').AsString   := SOPersData.S['area_b_bel'];
    FieldByName('RAION_R').AsString   := SOPersData.S['region_b'];
    FieldByName('RAION_B_R').AsString := SOPersData.S['region_b_bel'];

    TClassifier.SObj2DSSetTKN(SOPersData.O['type_city_b'], ODS, 'TIP_GOROD_R');
    FieldByName('N_TIP_GOROD_B_R').AsString := TClassifier.FindRUName(SOPersData.O['type_city_b'].O['lexema'].O['value'], 'BE');

    FieldByName('GOROD_R').AsString   := SOPersData.S['city_b'];
    FieldByName('GOROD_B_R').AsString := SOPersData.S['city_b_bel'];

    TClassifier.SObj2DSSetTKN(SOPersData.O['cyty_b_ate'], ODS, 'ATE_R', False);
    FieldByName('N_ATE_R_B').AsString := TClassifier.FindRUName(SOPersData.O['city_b_ate'].O['lexema'].O['value'], 'BE');
  end;
end;


// Документ, удостоверяющий личность
class procedure TPersData.SObj2DSPasp(DocsArr: ISuperObject; ODS: TDataSet; ExactType: string = '');
var
  i, iMax: Integer;
  DocT: string;
  x: ISuperObject;
begin
  iMax := DocsArr.AsArray.Length - 1;
  with ODS do begin
    for i := 0 to iMax do begin
      x := DocsArr.AsArray.O[i];
      if (x.B['active'] = True) then begin
        DocT := x.O['document_type'].s['code'];
        if (DocT = ExactType) OR ((iMax = 0) AND (Length(ExactType) = 0)) then begin
      // документ считается подходящим под удостоверение личности
          TClassifier.SObj2DSSetTKN(x.O['document_type'], ODS, 'DOC_TYPE');
          TClassifier.SObj2DSSetTKN(x.O['authority'], ODS, 'DOC_ORGAN');
          FieldByName('DOC_SERIA').AsString := x.S['series'];
          FieldByName('DOC_NOMER').AsString := x.S['number'];
          FieldByName('DOC_DATE').AsDateTime := StrToDate(x.S['date_of_issue']);
        end;
      end;
    end;
  end;
end;



// Место проживания
class procedure TPersData.SObj2DSAddress(SOPersData: ISuperObject; ODS: TDataSet);
begin
  with ODS do begin
    TClassifier.SObj2DSSetTKN(SOPersData.O['country'], ODS, 'GOSUD');
    TClassifier.SObj2DSSetTKN(SOPersData.O['area'], ODS, 'OBL');
    FieldByName('N_OBL_B').AsString := TClassifier.FindRUName(SOPersData.O['area'].O['lexema'].O['value'], 'BE');
    TClassifier.SObj2DSSetTKN(SOPersData.O['region'], ODS, 'RAION');
    FieldByName('N_RAION_B').AsString := TClassifier.FindRUName(SOPersData.O['region'].O['lexema'].O['value'], 'BE');
    TClassifier.SObj2DSSetTKN(SOPersData.O['soviet'], ODS, 'SOVET');

    TClassifier.SObj2DSSetTKN(SOPersData.O['locality_type'], ODS, 'TIP_GOROD');
    FieldByName('N_TIP_GOROD_B').AsString := TClassifier.FindRUName(SOPersData.O['locality_type'].O['lexema'].O['value'], 'BE');
    TClassifier.SObj2DSSetTKN(SOPersData.O['locality'], ODS, 'GOROD');
    FieldByName('N_GOROD_B').AsString := TClassifier.FindRUName(SOPersData.O['locality'].O['lexema'].O['value'], 'BE');
    TClassifier.SObj2DSSetTKN(SOPersData.O['city_region'], ODS, 'RN_GOROD');
    FieldByName('N_RN_GOROD_B').AsString := TClassifier.FindRUName(SOPersData.O['city_region'].O['lexema'].O['value'], 'BE');

    TClassifier.SObj2DSSetTKN(SOPersData.O['street_type'], ODS, 'TIP_UL');
    FieldByName('N_TIP_UL_B').AsString := TClassifier.FindRUName(SOPersData.O['street_type'].O['lexema'].O['value'], 'BE');
    TClassifier.SObj2DSSetTKN(SOPersData.O['street'], ODS, 'UL');
    FieldByName('N_UL_B').AsString := TClassifier.FindRUName(SOPersData.O['street'].O['lexema'].O['value'], 'BE');

    FieldByName('DOM').AsString  := SOPersData.S['house'];
    FieldByName('KORP').AsString := SOPersData.S['buiding'];
    FieldByName('KV').AsString   := SOPersData.S['flat'];

    FieldByName('REG_DATE').AsDateTime      := StrToDate(SOPersData.S['reg_date']);
    FieldByName('REG_DATE_TILL').AsDateTime := StrToDate(SOPersData.S['reg_date_till']);
    FieldByName('SIGN_AWAY').AsBoolean      := SOPersData.B['sign_away'];
  end;
end;


// Место смерти
class procedure TPersData.SObj2DSDcsPlace(DcsPlace: ISuperObject; ODS: TDataSet);
begin
  with ODS do begin
    FieldByName('S_GOSUD').AsString := DcsPlace.O['country_d'].S['code'];
    FieldByName('S_OBL').AsString   := DcsPlace.S['area_d'];
    FieldByName('S_OBL_B').AsString := DcsPlace.S['area_d_bel'];
    FieldByName('S_RAION').AsString   := DcsPlace.S['region_d'];
    FieldByName('S_RAION_B').AsString := DcsPlace.S['region_d_bel'];

    FieldByName('S_TIP_GOROD').AsString := DcsPlace.O['type_city_d'].S['code'];
    FieldByName('S_TIP_GOROD_N').AsString := TClassifier.FindRUName(DcsPlace.O['type_city_d'].O['lexema'].O['value']);

    FieldByName('S_GOROD').AsString   := DcsPlace.S['city_d'];
    FieldByName('S_GOROD_B').AsString   := DcsPlace.S['city_d_bel'];
  end;
end;


// Запись акта о смерти
class procedure TPersData.SObj2DSActDcs(ActDcs: ISuperObject; ODS: TDataSet);
begin
  with ODS do begin
    FieldByName('SM_AKT_T_DOC_TYPE').AsString   := IntToStr(ActDcs.I['type']);
    FieldByName('SM_AKT_K_DOC_TYPE').AsString := ActDcs.S['code'];
    FieldByName('SM_AKT_N_DOC_TYPE').AsString := TClassifier.FindRUName(ActDcs.O['lexema'].O['value']);

    FieldByName('SM_AKT_T_DOC_ORGAN').AsString   := IntToStr(ActDcs.O['authority'].I['type']);
    FieldByName('SM_AKT_K_DOC_ORGAN').AsString := ActDcs.O['authority'].S['code'];
    FieldByName('SM_AKT_N_DOC_ORGAN').AsString := TClassifier.FindRUName(ActDcs.O['authority'].O['lexema'].O['value']);

    FieldByName('SM_AKT_DOC_DATE').AsDateTime := StrToDate(ActDcs.S['date']);
    FieldByName('SM_AKT_DOC_NOMER').AsString := ActDcs.S['number'];
  end;
end;


// Данные о смерти
class procedure TPersData.SObj2DSDeaths(Deaths: ISuperObject; ODS: TDataSet);
var
  GoodDoc: Boolean;
  NeedDocType, j, jMax, i, iMax: Integer;
  NeedDocCode : string;
  DocDcs, OneD, DDocs: ISuperObject;
begin
  NeedDocType := 37;
  NeedDocCode := '5400009';
  DocDcs := nil;

  iMax := Deaths.AsArray.Length - 1;
  with ODS do begin
    for i := 0 to iMax do begin
      DDocs := Deaths.AsArray.O[i].O['death'].O['documents'];

      jMax := DDocs.AsArray.Length - 1;
      GoodDoc := True;
      for j := 0 to jMax do begin
        OneD := Deaths.AsArray.O[j].O['document'];
        GoodDoc := OneD.B['active'];
        if (GoodDoc = False) then
          Break;
        if (OneD.O['document_type'].i['type'] = NeedDocType) AND (OneD.O['document_type'].s['code'] = NeedDocCode) then
          DocDcs := OneD;
      end;
      if (GoodDoc = False) then
        Continue;
      if (Assigned(DocDcs)) then begin
      // Все документы True и нужный тип присутствует
        OneD := Deaths.AsArray.O[i].O['death'].O['death_data'];
        TClassifier.SObj2DSSetTKN(OneD.O['death_cause'], ODS, 'CAUSE');
        FieldByName('DATES').AsString := OneD.S['death_date'];
        FieldByName('S_PLACE').AsString := OneD.S['death_place'];
        FieldByName('S_MESTO').AsString := OneD.S['death_place'];

      // Место смерти
        SObj2DSDcsPlace(OneD.O['decease_place'], ODS);
      // Запись акта о смерти
        SObj2DSActDcs(DocDcs.O['act_data'], ODS);

      // Свидетельство о смерти
        FieldByName('SM_SV_T_DOC_TYPE').AsString := IntToStr(DocDcs.I['type']);
        FieldByName('SM_SV_K_DOC_TYPE').AsString := DocDcs.S['code'];
        FieldByName('SM_SV_N_DOC_TYPE').AsString := TClassifier.FindRUName(DocDcs.O['lexema'].O['value']);

        FieldByName('SM_SV_T_DOC_ORGAN').AsString := IntToStr(DocDcs.O['authority'].i['type']);
        FieldByName('SM_SV_K_DOC_ORGAN').AsString := DocDcs.O['authority'].s['code'];
        FieldByName('SM_SV_N_DOC_ORGAN').AsString := TClassifier.FindRUName(DocDcs.O['authority'].O['lexema'].O['value']);

        FieldByName('SM_SV_DOC_DATE').AsDateTime := StrToDate(DocDcs.S['date']);
        FieldByName('SM_SV_DOC_SERIA').AsString := DocDcs.S['series'];
        FieldByName('SM_SV_DOC_NOMER').AsString := DocDcs.S['number'];
      end;
    end;
  end;
end;


// Данные о захоронении
class procedure TPersData.SObj2DSBurs(Burs: ISuperObject; ODS: TDataSet);
var
  j, jMax, i, iMax: Integer;
  BData, OneD: ISuperObject;
begin
  iMax := Burs.AsArray.Length - 1;
  with ODS do begin
    for i := 0 to iMax do begin
      BData := Burs.AsArray.O[i].O['burial_info'].O['burial_data'];
      if (BData.B['active'] = True) then begin

        FieldByName('ZH_N_OBL').AsString := TClassifier.FindRUName(BData.O['area'].O['lexema'].O['value']);
        FieldByName('ZH_N_RAION').AsString := TClassifier.FindRUName(BData.O['region'].O['lexema'].O['value']);
        FieldByName('ZH_N_NP').AsString := TClassifier.FindRUName(BData.O['city'].O['lexema'].O['value']);
        FieldByName('ZH_K_KLAD').AsString := BData.O['burial_name'].s['code'];
        FieldByName('ZH_N_KLAD').AsString := TClassifier.FindRUName(BData.O['burial_name'].O['lexema'].O['value']);
        FieldByName('ZH_SECTOR').AsString := BData.S['sector'];
        FieldByName('ZH_RAD').AsString := BData.S['row'];
        FieldByName('ZH_UCH').AsString := BData.S['place'];
        FieldByName('ZH_MOG').AsString := BData.S['grave'];

        FieldByName('ZH_SKLEP').AsString := BData.S['vault'];
        FieldByName('ZH_KLUM').AsString := BData.S['wall_section'];
        FieldByName('ZH_STAKAN').AsString := BData.S['wall_box'];

        jMax := Burs.AsArray.O[i].O['burial_info'].O['documents'].AsArray.Length - 1;
        for j := 0 to jMax do begin
          OneD := Burs.AsArray.O[i].O['burial_info'].O['documents'].AsArray.O[j];
          if (OneD.B['active'] = True) then begin
            FieldByName('ZH_BOOK').AsString := OneD.S['number'];
            Break;
          end;
        end;
        Break;
      end;
    end;
  end;
end;


// Заполнить информацией об ошибках
class procedure TPersData.SObj2DSErr(Err: ISuperObject; ODS: TDataSet);
var
  j, jMax, i, iMax: Integer;
  s: string;
  OneErr, OneD: ISuperObject;
begin
  iMax := Err.AsArray.Length - 1;
  with ODS do begin
    for i := 0 to iMax do begin
      OneErr := Err.AsArray.O[i];
      Append;
      FieldByName('ERROR_CODE').AsString := OneErr.O['error_code'].s['code'];
      FieldByName('ERROR_TEXT').AsString := TClassifier.FindRUName(OneErr.O['error_code'].O['lexema'].O['value']);
      FieldByName('ERROR_PLACE').AsString := OneErr.S['error_place'];
      FieldByName('WRONG_VALUE').AsString := OneErr.S['wrong_value'];
      FieldByName('CORRECT_VALUE').AsString := OneErr.S['correct_value'];
      FieldByName('CHECK_NAME').AsString := OneErr.S['check_name'];
      FieldByName('DESCRIPTION').AsString := OneErr.S['description'];
      FieldByName('IDENTIF').AsString := OneErr.S['identif'];
      Post;
    end;
  end;
end;


















// Полный список персональных данных
class procedure TPersData.SObj2DSPersData(SOPersData: ISuperObject; ODS: TDataSet; FullSet : Boolean = True);
var
  s: string;
begin
  with ODS do begin
    FieldByName('IDENTIF').AsString := SOPersData.S['identif'];
    FieldByName('FAMILIA').AsString := SOPersData.S['last_name'];
    FieldByName('NAME').AsString    := SOPersData.S['name'];
    FieldByName('OTCH').AsString    := SOPersData.S['patronymic'];
    FieldByName('DATER').AsString   := SOPersData.S['birth_day'];
    if (NOT FullSet) then
      Exit;

    FieldByName('FAMILIA_B').AsString := SOPersData.S['last_name_bel'];
    FieldByName('NAME_B').AsString    := SOPersData.S['name_bel'];
    FieldByName('OTCH_B').AsString    := SOPersData.S['patronymic_bel'];

    TClassifier.SObj2DSSetTKN(SOPersData.O['sex'], ODS, 'POL');
    // Место рождения
    SObj2DSBPlace(SOPersData.O['birth_place'], ODS);
    // Гражданство
    TClassifier.SObj2DSSetTKN(SOPersData.O['citizenship'], ODS, 'GRAJD');
    TClassifier.SObj2DSSetTKN(SOPersData.O['status'], ODS, 'STATUS');

    // Документ, удостоверяющий личность
    SObj2DSPasp(SOPersData.O['documents'], ODS);
    // Адрес проживания
    SObj2DSAddress(SOPersData.O['address'], ODS);
    // Сведения о смерти
    SObj2DSDeaths(SOPersData.O['deaths'], ODS);
    // Данные о захоронении
    SObj2DSBurs(SOPersData.O['deaths'], ODS);
  end;
end;



// Свидетельство о рождении (ребенок или родитель)
class function TActBirth.BirthDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string; Mode : Integer = 1) : string;
begin
  Result := Format(
    '"%s":{%s,' +
      '"birth_place":{%s},' +
      '"citizenship":%s,' +
      '"status":%s}', [
    ObjName, DS2JsonMin(IDS,Pfx),
     TDS2JSON.MakeBirthPlace(IDS, Pfx, Mode),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'GRAJD').AsString, 8),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18)]);
end;


// Свидетельство о рождении
class function TActBirth.BirthDS2Json(IDS : TDataSet) : string;
var
  org,
  r,
  s : string;
begin
  s := '"birth_cert_data":{' +
    BirthDS2JsonOne(IDS, '', 'child_data') + ',';
  s := s +
    BirthDS2JsonOne(IDS, 'ONA_', 'mother_data', BPLC_RU_ONLY) + ',';
  s := s +
    BirthDS2JsonOne(IDS, 'ON_', 'father_data', BPLC_RU_ONLY) + ',';

  s := s + '"birth_act_data":{' +
               '"act_type":' + TClassifier.SetCT(IDS.FieldByName('ACT_TIP').AsString, 82) + ',';
  org := IDS.FieldByName('ACT_ORGAN').AsString;
  org := Iif( StrToInt(org) > 0, TClassifier.SetCT(org, 80), TClassifier.SetCTL('', 80, IDS.FieldByName('ACT_ORGAN_LEX').AsString) );
  s := s + '"authority":' + org + ',';
               r := Format('"date":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('ACT_DATE').AsDateTime) ]);
               s := s + r;
               r := Format('"number":"%s"},', [ IDS.FieldByName('ACT_NOMER').AsString ]);
               s := s + r;
  s := s + '"birth_certificate_data":{"document":{' +
               '"document_type":' + TClassifier.SetCT('54100005', 37) + ',' +
               '"authority":' + TClassifier.SetCT(IDS.FieldByName('DOC_ORGAN').AsString, 80) + ',' +
               Format('"date_of_issue":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('DOC_DATE').AsDateTime) ]) +
               Format('"series":"%s",', [ IDS.FieldByName('DOC_SERIA').AsString ]) +
               Format('"number":"%s"}}}', [ IDS.FieldByName('DOC_NOMER').AsString ]);
  Result := s;
end;


// Свидетельство об установлении отцовства
class function TActAffil.AffilDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string; Mode : Integer = 1) : string;
var
  sF,
  sCtz,
  s : string;
begin

  if (Mode = BPLC_RU_NOCTZ) then
    sCtz := '0'
  else
    sCtz := IDS.FieldByName(Pfx + 'GRAJD').AsString;

  sF := '"%s":{%s,' +
        '"birth_place":{%s},' +
        '"citizenship":%s,' +
        '"status":%s}';

  s := Format(sF,
    [ObjName,
     DS2JsonMin(IDS,Pfx),
     TDS2JSON.MakeBirthPlace(IDS, Pfx, Mode),
     TClassifier.SetCT(sCtz, 8),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18)]);
  Result := s;
end;


// Свидетельство об установлении отцовства
class function TActAffil.AffilDS2Json(IDS : TDataSet) : string;
var
  org,
  r,
  s : string;
begin
  s := '"aff_cert_data":{' +
    '"aff_person":{' +
      '"birth_act_data":{' +
        '"act_type":' + TClassifier.SetCT(IDS.FieldByName('R_TIP').AsString, 82) + ',' +
        '"authority":' + TClassifier.SetCT(IDS.FieldByName('R_ORGAN').AsString, 80) + ',';
  s := s + Format(
        '"date":"%s","number":"%s"},', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('R_DATE').AsDateTime), IDS.FieldByName('R_NOMER').AsString ]);
  s := s + AffilDS2JsonOne(IDS, 'DO_', 'before_aff_person_data', BPLC_RU_NOCTZ) + ',';
  s := s + AffilDS2JsonOne(IDS, 'PO_', 'after_aff_person_data', BPLC_RU_NOCTZ) +
    '},'; // aff_person made
  s := s +
    AffilDS2JsonOne(IDS, 'ONA_', 'mother_data', BPLC_RU_ONLY) + ',';
  s := s +
    AffilDS2JsonOne(IDS, 'ON_', 'father_data', BPLC_RU_ONLY) + ',';

  s := s + '"aff_act_data":{' +
               '"act_type":' + TClassifier.SetCT(IDS.FieldByName('ACT_TIP').AsString, 82) + ',';
  org := IDS.FieldByName('ACT_ORGAN').AsString;
  org := Iif( StrToInt(org) > 0, TClassifier.SetCT(org, 80), TClassifier.SetCTL('', 80, IDS.FieldByName('ACT_ORGAN_LEX').AsString) );
  s := s + '"authority":' + org + ',';
               r := Format('"date":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('ACT_DATE').AsDateTime) ]);
               s := s + r;
               r := Format('"number":"%s"},', [ IDS.FieldByName('ACT_NOMER').AsString ]);
               s := s + r;
  s := s + '"aff_mother_certificate_data":{"document":{' +
               '"document_type":' + TClassifier.SetCT('54100027', 37) + ',' +
               '"authority":' + TClassifier.SetCT(IDS.FieldByName('DOC_ONA_ORGAN').AsString, 80) + ',' +
               Format('"date_of_issue":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('DOC_ONA_DATE').AsDateTime) ]) +
               Format('"series":"%s",', [ IDS.FieldByName('DOC_ONA_SERIA').AsString ]) +
               Format('"number":"%s"}},', [ IDS.FieldByName('DOC_ONA_NOMER').AsString ]);
  s := s + '"aff_father_certificate_data":{"document":{' +
               '"document_type":' + TClassifier.SetCT('54100026', 37) + ',' +
               '"authority":' + TClassifier.SetCT(IDS.FieldByName('DOC_ON_ORGAN').AsString, 80) + ',' +
               Format('"date_of_issue":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('DOC_ON_DATE').AsDateTime) ]) +
               Format('"series":"%s",', [ IDS.FieldByName('DOC_ON_SERIA').AsString ]) +
               Format('"number":"%s"}}', [ IDS.FieldByName('DOC_ON_NOMER').AsString ]);
  r := TDS2JSON.CourtDec(IDS);
  if (Length(r) > 0) then
    s := s + ',"court_decision":' + r;
  s := s + '}';
  Result := s;
end;



// Свидетельство о браке для одного супруга
class function TActMarr.MarrDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string) : string;
begin
  Result := Format('"%s":{%s,' +
    '"birth_place":{%s},' +
    '"citizenship":%s,' +
    '"status":%s},' +
    '"old_last_name":"%s"', [ObjName, DS2JsonMin(IDS,Pfx),
     TDS2JSON.MakeBirthPlace(IDS, Pfx),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'GRAJD').AsString, 8),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18),
     IDS.FieldByName(Pfx + 'FAMILIA_OLD').AsString]);
end;


// Свидетельство о браке
class function TActMarr.MarrDS2Json(IDS : TDataSet) : string;
var
  org,
  r,
  s : string;
begin
  s := '"mrg_cert_data":{' +
    '"bride":{' +
    MarrDS2JsonOne(IDS, 'ONA_', 'bride_data') +
    '},"bridegroom":{' +
    MarrDS2JsonOne(IDS, 'ON_', 'bridegroom_data') + '},';

  Result := s +
    TDS2JSON.MakeActData(IDS, 'mrg_act_data') + ',' +
    TDS2JSON.MakeDocCertif(IDS, 'mrg_certificate_data', IDS.FieldByName('DOC_TIP').AsString) + '}';
end;



// Свидетельство о смерти
class function TActDecease.DeceaseDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string; Mode : Integer = 1) : string;
var
  s : string;
begin
// Место рождения
  s := '"country_b":' +
    TClassifier.SetCT(IDS.FieldByName(Pfx + 'GOSUD_R').AsString, 8);
  s := s + Format(',"area_b":"%s","region_b":"%s","city_b":"%s",',[
    IDS.FieldByName(Pfx + 'OBL_R').AsString,
    IDS.FieldByName(Pfx + 'RAION_R').AsString,
    IDS.FieldByName(Pfx + 'GOROD_R').AsString]);
  s := s + '"type_city_b":' + TClassifier.SetCT(IDS.FieldByName(Pfx + 'TIP_GOROD_R').AsString, 68);

  Result := Format('"%s":{%s,' +
        '"birth_place":{%s},' +
        '"citizenship":%s,' +
        '"status":%s}', [
     ObjName, DS2JsonMin(IDS,Pfx),
     s,
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'GRAJD').AsString, 8),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18)]);
end;


// Свидетельство о смерти
class function TActDecease.DeceaseDS2JsonDCD(IDS : TDataSet) : string;
var
  sD,
  sP  : string;
begin

  sD :=
    '"death_cause":' +
      TClassifier.SetCT(IDS.FieldByName('SM_PRICH').AsString, 81) + ',' +
    '"death_date":"' + IDS.FieldByName('SM_DATE').AsString + '",';

  // Место смерти
  sP := Format('"country_d":%s,"area_d":"%s","region_d":"%s","city_d":"%s",',[
    TClassifier.SetCT(IDS.FieldByName('GOSUD').AsString, 8),
    IDS.FieldByName('OBL').AsString,
    IDS.FieldByName('RAION').AsString,
    IDS.FieldByName('GOROD').AsString]);

  sP := sP + Format('"area_d_bel":"%s","region_d_bel":"%s","city_d_bel":"%s","type_city_d":%s', [
      IDS.FieldByName('OBL_B').AsString,
      IDS.FieldByName('RAION_B').AsString,
      IDS.FieldByName('GOROD_B').AsString,
      TClassifier.SetCT(IDS.FieldByName('TIP_GOROD').AsString, 68)]);

  Result := Format('"decease_data":{%s' +
        '"decease_place":{%s}}',[sD, sP]);
end;


// Свидетельство о смерти
class function TActDecease.DeceaseDS2Json(IDS : TDataSet) : string;
var
  org,
  r,
  s : string;
begin
  s := '"dcs_cert_data":{' +
    DeceaseDS2JsonOne(IDS, '', 'person_data') + ',';
  s := s +
    DeceaseDS2JsonDCD(IDS) + ',' +
    '"reason":"' + IDS.FieldByName('SM_DOC').AsString + '",';

  s := s + '"dcs_act_data":{' +
               '"act_type":' + TClassifier.SetCT(IDS.FieldByName('ACT_TIP').AsString, 82) + ',';
  org := IDS.FieldByName('ACT_ORGAN').AsString;
  org := Iif( StrToInt(org) > 0, TClassifier.SetCT(org, 80), TClassifier.SetCTL('', 80, IDS.FieldByName('ACT_ORGAN_LEX').AsString) );
  s := s + '"authority":' + org + ',';
               r := Format('"date":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('ACT_DATE').AsDateTime) ]);
               s := s + r;
               r := Format('"number":"%s"},', [ IDS.FieldByName('ACT_NOMER').AsString ]);
               s := s + r;
  s := s + '"dcs_certificate_data":{"document":{' +
               '"document_type":' + TClassifier.SetCT('54100009', 37) + ',' +
               '"authority":' + TClassifier.SetCT(IDS.FieldByName('DOC_ORGAN').AsString, 80) + ',' +
               Format('"date_of_issue":"%s",', [ FormatDateTime('yyyy-mm-dd', IDS.FieldByName('DOC_DATE').AsDateTime) ]) +
               Format('"series":"%s",', [ IDS.FieldByName('DOC_SERIA').AsString ]) +
               Format('"number":"%s"}}}', [ IDS.FieldByName('DOC_NOMER').AsString ]);
  Result := s;
end;


// Свидетельство о расторжении брака для одного супруга
class function TActDvrc.DvrcDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string) : string;
var
  sD,
  s : string;
begin
  Result := Format('"%s":{%s,' +
    '"birth_place":{%s},' +
    '"citizenship":%s,' +
    '"status":%s},' +
    '"old_last_name":"%s"',
    [ObjName, DS2JsonMin(IDS,Pfx),
     TDS2JSON.MakeBirthPlace(IDS, Pfx, BPLC_RU_ONLY),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'GRAJD').AsString, 8),
     TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18),
     IDS.FieldByName(Pfx + 'FAMILIA_OLD').AsString]);
end;

// Свидетельство о расторжении брака
class function TActDvrc.DvrcDS2Json(IDS : TDataSet) : string;
var
  org,
  r,
  s : string;
begin
  s := '"dvc_cert_data":{' +
    '"wife":{' + DvrcDS2JsonOne(IDS, 'ONA_', 'wife_data') +
    '},"husband":{' + DvrcDS2JsonOne(IDS, 'ON_', 'husband_data') + '},';
  s := s +
    TDS2JSON.MakeActData(IDS, 'mrg_act_data', 'BRAK_') + ',';
  r := TDS2JSON.CourtDec(IDS);
  if (Length(r) > 0) then
    s := s + '"court_decision":' + r + ',';

  Result := s +
    TDS2JSON.MakeActData(IDS, 'dvc_act_data') + ',' +
    TDS2JSON.MakeDocCertif(IDS, 'dvc_wm_certificate_data', IDS.FieldByName('ONA_TIP').AsString, 'ONA_') + ',' +
    TDS2JSON.MakeDocCertif(IDS, 'dvc_mn_certificate_data', IDS.FieldByName('ON_TIP').AsString, 'ONA_') + '}';
end;

// Свидетельство о смене ФИО
class function TActChgName.ChgNameDS2JsonOne(IDS : TDataSet; Pfx, ObjName : string) : string;
var
  sD,
  s : string;
begin

s := DS2JsonMin(IDS,Pfx);
s :=      TDS2JSON.MakeBirthPlace(IDS, Pfx);
s :=      TClassifier.SetCT(IDS.FieldByName(Pfx + 'GRAJD').AsString, 8);
s :=      TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18);


  Result := Format('"%s":{%s,' +
    '"birth_place":{%s},' +
    '"citizenship":%s,' +
    '"status":%s}', [
    ObjName, DS2JsonMin(IDS,Pfx),
    TDS2JSON.MakeBirthPlace(IDS, Pfx),
    TClassifier.SetCT(IDS.FieldByName(Pfx + 'GRAJD').AsString, 8),
    TClassifier.SetCT(IDS.FieldByName(Pfx + 'STATUS').AsString, -18)]);
end;


// Свидетельство о смене ФИО
class function TActChgName.ChgNameDS2Json(IDS : TDataSet) : string;
var
  org,
  r,
  s : string;
begin
  s := '"cng_cert_data":{' +
    '"person":{' + ChgNameDS2JsonOne(IDS, '', 'person_data') + ',';
  s := s +
    TDS2JSON.MakeActData(IDS, 'birth_act_data', 'R_') + ',';

  s := s + Format('"old_last_name":"%s","old_name":"%s","old_patronymic":"%s"},', [
    IDS.FieldByName('DO_FAMILIA').AsString,
    IDS.FieldByName('DO_NAME').AsString,
    IDS.FieldByName('DO_OTCH').AsString]);
  s := s + '"reason":"' + IDS.FieldByName('OSNOV').AsString + '",';

  Result := s +
    TDS2JSON.MakeActData(IDS, 'cng_act_data') + ',' +
    TDS2JSON.MakeDocCertif(IDS, 'cng_certificate_data', IDS.FieldByName('DOC_TIP').AsString) + '}';
end;


end.
