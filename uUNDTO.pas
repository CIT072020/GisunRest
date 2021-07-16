unit uUNDTO;

interface

uses
  SysUtils,
  Classes,
  DB,
  Variants,
  superobject,
  superdate,
  synautil,
  XSBuiltIns,
  FuncPr,
  uROCService;

const
  BPLC_WITH_BY  = 1;
  BPLC_RU_ONLY  = 2;
  BPLC_RU_NOCTZ = 3;

  UTC_FMT = 'yyyy-mm-dd';

type
  TActPostBoby = function(IDS : TDataSet) : string;
  TMakePostBoby = function(IDS : TDataSet) : string of object;

  // Справочное значение из SuperObject
  TNSIValue = record
  //
    NsiType : Integer;
    NsiCode : string;
    NsiName : string;
    FullFill : Boolean;
   end;


  // Классификатор
  TClassifier = class
  private
  public
    // Для конвертации DataSet -> String(JSON)
    class function SetCT(const ACode: string; AType: integer; IsBraces: Boolean = True): string;
    class function SetCTL(const ACode: string; AType: integer; const Lex : string; Lang : string = 'ru'; IsBraces: Boolean = True): string;

    // Для конвертации SuperObject -> DataSet
    class function FindRUName(LexValArr: ISuperObject; const ALang: string = 'RU'): string;
    class procedure SObj2DSSetTKN(SOClassif: ISuperObject; ODS: TDataSet; const
        Pfx: string; NeedType: Boolean = True);
    // Для конвертации SuperObject -> Record
    class function SObj2TKN(SOClassif: ISuperObject; NeedType: Boolean = True) : TNSIValue;
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

    class function SObj2DSErr(Err: ISuperObject; EDS: TDataSet) : integer;
    class procedure SObj2DSBurs(Burs: ISuperObject; ODS: TDataSet);
    //class procedure SObj2DSActDcs(ActDcs: ISuperObject; ODS: TDataSet);
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
    class function DeceaseDS2JsonDcData(IDS : TDataSet) : string;
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
  if (LexValArr <> nil) then begin
    try
      iMax := LexValArr.AsArray.Length - 1;
      for i := 0 to iMax do begin
        x := LexValArr.AsArray.O[i];
        if (UpperCase(x.S['lang']) = ALang) then begin
          Result := x.S['value'];
          Break;
        end;
      end;
    except
      Result := '';
    end;
  end;
end;




// Тип-код-наименование из справочника -> DataSet
class procedure TClassifier.SObj2DSSetTKN(SOClassif: ISuperObject; ODS:
    TDataSet; const Pfx: string; NeedType: Boolean = True);
begin
  if (SOClassif <> nil) then begin
    try
      if (NeedType) then
        ODS.FieldByName('T_' + Pfx).AsString := IntToStr(SOClassif.I['type']);
      ODS.FieldByName('K_' + Pfx).AsString := SOClassif.S['code'];
      ODS.FieldByName('N_' + Pfx).AsString := FindRUName(SOClassif.O['lexema.value']);
    except
      ODS.FieldByName('N_' + Pfx).AsString := '';
    end;
  end;
end;


// Тип-код-наименование из справочника -> Record
class function TClassifier.SObj2TKN(SOClassif: ISuperObject; NeedType: Boolean = True) : TNSIValue;
begin
  Result.FullFill := False;
  if (SOClassif <> nil) then begin
    try
      if (NeedType) then
        Result.NsiType := SOClassif.I['type'];
      Result.NsiCode := SOClassif.S['code'];
      Result.NsiName := FindRUName(SOClassif.O['lexema.value']);
      Result.FullFill := True;
    except
      Result.FullFill := False;
    end;
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
var
  i: Integer;
begin
  try
    with ODS do begin
      FieldByName('OBL_R').AsString     := SOPersData.S['area_b'];
      FieldByName('OBL_B_R').AsString   := SOPersData.S['area_b_bel'];
      FieldByName('RAION_R').AsString   := SOPersData.S['region_b'];
      FieldByName('RAION_B_R').AsString := SOPersData.S['region_b_bel'];

      FieldByName('GOROD_R').AsString   := SOPersData.S['city_b'];
      FieldByName('GOROD_B_R').AsString := SOPersData.S['city_b_bel'];

      TClassifier.SObj2DSSetTKN(SOPersData.O['country_b'], ODS, 'GOSUD_R');
      TClassifier.SObj2DSSetTKN(SOPersData.O['type_city_b'], ODS, 'TIP_GOROD_R');
      FieldByName('N_TIP_GOROD_B_R').AsString := TClassifier.FindRUName(SOPersData.O['type_city_b.lexema.value'], 'BE');

      TClassifier.SObj2DSSetTKN(SOPersData.O['city_b_ate'], ODS, 'ATE_R', False);
      FieldByName('N_ATE_R_B').AsString := TClassifier.FindRUName(SOPersData.O['city_b_ate.lexema.value'], 'BE');
    end;
  except
    i := 0;
  end;
end;


// Документ, удостоверяющий личность
class procedure TPersData.SObj2DSPasp(DocsArr: ISuperObject; ODS: TDataSet; ExactType: string = '');
var
  i, iMax: Integer;
  DocT: string;
  d: TDateTime;
  x: ISuperObject;
begin
  if (DocsArr <> nil) then begin
    try
      iMax := DocsArr.AsArray.Length - 1;
      for i := 0 to iMax do begin
        x := DocsArr.AsArray.O[i].O['document'];
        if (x.B['active'] = True) then begin
          DocT := x.S['document_type.code'];
          if (DocT = ExactType) OR ((iMax = 0) AND (Length(ExactType) = 0)) then begin
          // документ считается подходящим под удостоверение личности
            TClassifier.SObj2DSSetTKN(x.O['document_type'], ODS, 'DOC_TYPE');
            TClassifier.SObj2DSSetTKN(x.O['authority'], ODS, 'DOC_ORGAN');
            ODS.FieldByName('DOC_SERIA').AsString := x.S['series'];
            ODS.FieldByName('DOC_NOMER').AsString := x.S['number'];
            if ISO8601DateToDelphiDateTime(x.S['date_of_issue'], d) then
              ODS.FieldByName('DOC_DATE').AsDateTime := d;
          end;
        end;
      end;
    except
      iMax := 0;
    end;
  end;
end;











// Место проживания
class procedure TPersData.SObj2DSAddress(SOPersData: ISuperObject; ODS: TDataSet);
var
  d: TDateTime;
begin
  if (SOPersData <> nil) then begin
    try
      with ODS do begin
        TClassifier.SObj2DSSetTKN(SOPersData.O['country'], ODS, 'GOSUD');
        TClassifier.SObj2DSSetTKN(SOPersData.O['area'], ODS, 'OBL');
        FieldByName('N_OBL_B').AsString := TClassifier.FindRUName(SOPersData.O['area.lexema.value'], 'BE');
        TClassifier.SObj2DSSetTKN(SOPersData.O['region'], ODS, 'RAION');
        FieldByName('N_RAION_B').AsString := TClassifier.FindRUName(SOPersData.O['region.lexema.value'], 'BE');
        TClassifier.SObj2DSSetTKN(SOPersData.O['soviet'], ODS, 'SOVET');

        TClassifier.SObj2DSSetTKN(SOPersData.O['locality_type'], ODS, 'TIP_GOROD');
        FieldByName('N_TIP_GOROD_B').AsString := TClassifier.FindRUName(SOPersData.O['locality_type.lexema.value'], 'BE');
        TClassifier.SObj2DSSetTKN(SOPersData.O['locality'], ODS, 'GOROD');
        FieldByName('N_GOROD_B').AsString := TClassifier.FindRUName(SOPersData.O['locality.lexema.value'], 'BE');
        TClassifier.SObj2DSSetTKN(SOPersData.O['city_region'], ODS, 'RN_GOROD');
        FieldByName('N_RN_GOROD_B').AsString := TClassifier.FindRUName(SOPersData.O['city_region.lexema.value'], 'BE');

        TClassifier.SObj2DSSetTKN(SOPersData.O['street_type'], ODS, 'TIP_UL');
        FieldByName('N_TIP_UL_B').AsString := TClassifier.FindRUName(SOPersData.O['street_type.lexema.value'], 'BE');
        TClassifier.SObj2DSSetTKN(SOPersData.O['street'], ODS, 'UL');
        FieldByName('N_UL_B').AsString := TClassifier.FindRUName(SOPersData.O['street.lexema.value'], 'BE');

        FieldByName('DOM').AsString := SOPersData.S['house'];
        FieldByName('KORP').AsString := SOPersData.S['buiding'];
        FieldByName('KV').AsString := SOPersData.S['flat'];

        if ISO8601DateToDelphiDateTime(SOPersData.S['reg_date'], d) then
          FieldByName('REG_DATE').AsDateTime := d;
        if ISO8601DateToDelphiDateTime(SOPersData.S['reg_date_till'], d) then
          FieldByName('REG_DATE_TILL').AsDateTime := d;

        FieldByName('SIGN_AWAY').AsBoolean := SOPersData.B['sign_away'];
      end;
    except
      d := 0;
    end;
  end;
end;


// Место смерти
class procedure TPersData.SObj2DSDcsPlace(DcsPlace: ISuperObject; ODS: TDataSet);
begin
  with ODS do begin
    FieldByName('S_GOSUD').AsString       := DcsPlace.S['country_d.code'];
    FieldByName('S_OBL').AsString         := DcsPlace.S['area_d'];
    FieldByName('S_OBL_B').AsString       := DcsPlace.S['area_d_bel'];
    FieldByName('S_RAION').AsString       := DcsPlace.S['region_d'];
    FieldByName('S_RAION_B').AsString     := DcsPlace.S['region_d_bel'];
    FieldByName('S_GOROD').AsString       := DcsPlace.S['city_d'];
    FieldByName('S_GOROD_B').AsString     := DcsPlace.S['city_d_bel'];

    FieldByName('S_TIP_GOROD').AsString   := DcsPlace.S['type_city_d.code'];
    FieldByName('S_TIP_GOROD_N').AsString := TClassifier.FindRUName(DcsPlace.O['type_city_d.lexema.value']);
  end;
end;


// Данные о смерти
class procedure TPersData.SObj2DSDeaths(Deaths: ISuperObject; ODS: TDataSet);
var
  GoodDoc: Boolean;
  NeedActType,
  NeedDocType,
  j, jMax, i, iMax: Integer;
  NeedActCode,
  NeedDocCode: string;
  d: TDateTime;
  OneD, DDocs: ISuperObject;
begin
  NeedActType := 82;
  NeedActCode := '0400';
  NeedDocType := 37;
  NeedDocCode := '54100009';
  try
    if (Assigned(Deaths) and (Not Deaths.IsType(stNull))) then begin
      iMax := Deaths.AsArray.Length - 1;
      with ODS do begin
        for i := 0 to iMax do begin
          OneD := Deaths.AsArray.O[i].O['death.death_data'];
          if (Assigned(OneD) and (Not OneD.IsType(stNull))) then begin
            // Флаг active отсутствует
            FieldByName('DATES').AsString   := OneD.S['death_date'];
            FieldByName('S_PLACE').AsString := OneD.S['death_place'];
            FieldByName('S_MESTO').AsString := OneD.S['burial_place'];
            TClassifier.SObj2DSSetTKN(OneD.O['death_cause'], ODS, 'CAUSE');

            // Место смерти
            SObj2DSDcsPlace(OneD.O['decease_place'], ODS);

            // Обработка массива документов
            DDocs := Deaths.AsArray.O[i].O['death.documents'];
            jMax := DDocs.AsArray.Length - 1;
            GoodDoc := True;
            for j := 0 to jMax do begin
              OneD := DDocs.AsArray.O[j].O['document'];
              GoodDoc := OneD.B['active'];
              if (GoodDoc = False) then
                Continue;
              if ( Not OneD.O['document_type'].IsType(stNull) ) then begin
                if (OneD.I['document_type.type'] = NeedActType) AND (OneD.S['document_type.code'] = NeedActCode) then begin
                // Запись акта о смерти
                  FieldByName('SM_AKT_T_DOC_TYPE').AsString := IntToStr(OneD.I['document_type.type']);
                  FieldByName('SM_AKT_K_DOC_TYPE').AsString := OneD.S['document_type.code'];
                  FieldByName('SM_AKT_N_DOC_TYPE').AsString := TClassifier.FindRUName(OneD.O['document_type.lexema.value']);

                  if ISO8601DateToDelphiDateTime(OneD.S['date_of_issue'], d) then
                    FieldByName('SM_AKT_DOC_DATE').AsDateTime := d;
                  FieldByName('SM_AKT_DOC_SERIA').AsString := OneD.S['series'];
                  FieldByName('SM_AKT_DOC_NOMER').AsString := OneD.S['number'];
                  try
                    FieldByName('SM_AKT_T_DOC_ORGAN').AsString := IntToStr(OneD.I['authority.type']);
                    FieldByName('SM_AKT_K_DOC_ORGAN').AsString := OneD.S['authority.code'];
                    FieldByName('SM_AKT_N_DOC_ORGAN').AsString := TClassifier.FindRUName(OneD.O['authority.lexema.value']);
                  except
                  end;

                end;
                if (OneD.I['document_type.type'] = NeedDocType) AND (OneD.S['document_type.code'] = NeedDocCode) then begin
                // Свидетельство о смерти
                  FieldByName('SM_SV_T_DOC_TYPE').AsString := IntToStr(OneD.I['document_type.type']);
                  FieldByName('SM_SV_K_DOC_TYPE').AsString := OneD.S['document_type.code'];
                  FieldByName('SM_SV_N_DOC_TYPE').AsString := TClassifier.FindRUName(OneD.O['document_type.lexema.value']);

                  if ISO8601DateToDelphiDateTime(OneD.S['date'], d) then
                    FieldByName('SM_SV_DOC_DATE').AsDateTime := d;
                  FieldByName('SM_SV_DOC_SERIA').AsString := OneD.S['series'];
                  FieldByName('SM_SV_DOC_NOMER').AsString := OneD.S['number'];

                  try
                    FieldByName('SM_SV_T_DOC_ORGAN').AsString := IntToStr(OneD.I['authority.type']);
                    FieldByName('SM_SV_K_DOC_ORGAN').AsString := OneD.S['authority.code'];
                    FieldByName('SM_SV_N_DOC_ORGAN').AsString := TClassifier.FindRUName(OneD.O['authority.lexema.value']);
                  except
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  except
    iMax := 0;
  end;
end;


// Данные о захоронении
class procedure TPersData.SObj2DSBurs(Burs: ISuperObject; ODS: TDataSet);
var
  j, jMax, i, iMax: Integer;
  BData, OneD: ISuperObject;
begin
  try
    if (Assigned(Burs) and (Not Burs.IsType(stNull))) then begin
      iMax := Burs.AsArray.Length - 1;
      with ODS do begin
        for i := 0 to iMax do begin
          BData := Burs.AsArray.O[i].O['burial_info.burial_data'];

          FieldByName('ZH_N_OBL').AsString   := TClassifier.FindRUName(BData.O['area.lexema.value']);
          FieldByName('ZH_N_RAION').AsString := TClassifier.FindRUName(BData.O['region.lexema.value']);
          FieldByName('ZH_N_NP').AsString    := TClassifier.FindRUName(BData.O['city.lexema.value']);
          FieldByName('ZH_K_KLAD').AsString  := BData.S['burial_name.code'];
          FieldByName('ZH_N_KLAD').AsString  := TClassifier.FindRUName(BData.O['burial_name.lexema.value']);
          FieldByName('ZH_SECTOR').AsString  := BData.S['sector'];
          FieldByName('ZH_RAD').AsString     := BData.S['row'];
          FieldByName('ZH_UCH').AsString     := BData.S['place'];
          FieldByName('ZH_MOG').AsString     := BData.S['grave'];

          FieldByName('ZH_SKLEP').AsString   := BData.S['vault'];
          FieldByName('ZH_KLUM').AsString    := BData.S['wall_section'];
          FieldByName('ZH_STAKAN').AsString  := BData.S['wall_box'];

          BData := Burs.AsArray.O[i].O['burial_info.documents'];
          jMax := BData.AsArray.Length;
          for j := 0 to jMax - 1 do begin
            OneD := BData.AsArray.O[i].O['document'];
            if (OneD.B['active'] = True) then begin
              FieldByName('ZH_BOOK').AsString := OneD.S['number'];
              Break;
            end;
          end;
          Break;
        end;
      end;
    end;
  except
    iMax := -1;
  end;
end;








// Заполнить DataSet информацией об ошибках
class function TPersData.SObj2DSErr(Err: ISuperObject; EDS: TDataSet): integer;
var
  i, iMax: Integer;
  OneErr: ISuperObject;
begin
  iMax := 0;
  try
    Err := Err.O['error_list.error'];
    if (Assigned(Err) and (Not Err.IsType(stNull))) then begin
      iMax := Err.AsArray.Length;
        for i := 0 to iMax - 1 do begin
          OneErr := Err.AsArray.O[i];
          AddOneErr(EDS,
            OneErr.S['error_code.code'],
            TClassifier.FindRUName(OneErr.O['error_code.lexema.value']),
            OneErr.S['error_place'],
            OneErr.S['wrong_value'],
            OneErr.S['correct_value'],
            OneErr.S['check_name'],
            OneErr.S['description'],
            OneErr.S['identif']);
        end;
    end;
  except
    iMax := 0;
  end;
  Result := iMax;
end;


// Полный список персональных данных
class procedure TPersData.SObj2DSPersData(SOPersData: ISuperObject; ODS: TDataSet; FullSet: Boolean = True);
var
  s: string;
begin
  try

    if (Assigned(SOPersData) and (Not SOPersData.IsType(stNull))) then begin

      with ODS do begin
        Append;
        try
          FieldByName('IS_PERSON').AsBoolean := FullSet;
          FieldByName('IDENTIF').AsString := SOPersData.S['identif'];
          FieldByName('FAMILIA').AsString := SOPersData.S['last_name'];
          FieldByName('NAME').AsString := SOPersData.S['name'];
          FieldByName('OTCH').AsString := SOPersData.S['patronymic'];
          FieldByName('DATER').AsString := SOPersData.S['birth_day'];
          if (FullSet) then begin

            FieldByName('FAMILIA_B').AsString := SOPersData.S['last_name_bel'];
            FieldByName('NAME_B').AsString := SOPersData.S['name_bel'];
            FieldByName('OTCH_B').AsString := SOPersData.S['patronymic_bel'];

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
            SObj2DSBurs(SOPersData.O['burials'], ODS);
          end;
        finally
          Post;
        end;
      end;
    end;
  except
    s := 'Ошибка конвертации JSON-данных';
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
  s : string;
begin
  s := '"birth_cert_data":{' +
    BirthDS2JsonOne(IDS, '', 'child_data') + ',';
  s := s +
    BirthDS2JsonOne(IDS, 'ONA_', 'mother_data', BPLC_RU_ONLY) + ',';
  s := s +
    BirthDS2JsonOne(IDS, 'ON_', 'father_data', BPLC_RU_ONLY) + ',';

  Result := s +
    TDS2JSON.MakeActData(IDS, 'birth_act_data') + ',' +
    TDS2JSON.MakeDocCertif(IDS, 'birth_certificate_data', IDS.FieldByName('DOC_TIP').AsString) + '}';
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
    TDS2JSON.MakeActData(IDS, 'birth_act_data', 'R_') + ',';

  s := s + AffilDS2JsonOne(IDS, 'DO_', 'before_aff_person_data', BPLC_RU_NOCTZ) + ',';
  s := s + AffilDS2JsonOne(IDS, 'PO_', 'after_aff_person_data', BPLC_RU_NOCTZ) +
    '},'; // aff_person made
  s := s +
    AffilDS2JsonOne(IDS, 'ONA_', 'mother_data', BPLC_RU_ONLY) + ',';
  s := s +
    AffilDS2JsonOne(IDS, 'ON_', 'father_data', BPLC_RU_ONLY) + ',';

  s := s +
    TDS2JSON.MakeActData(IDS, 'aff_act_data') + ',' +
    TDS2JSON.MakeDocCertif(IDS, 'aff_mother_certificate_data', IDS.FieldByName('DOC_ONA_TIP').AsString, 'DOC_ONA_') + ',' +
    TDS2JSON.MakeDocCertif(IDS, 'aff_father_certificate_data', IDS.FieldByName('DOC_ON_TIP').AsString, 'DOC_ON_');

  r := TDS2JSON.CourtDec(IDS);
  if (Length(r) > 0) then
    s := s + ',"court_decision":' + r;
  Result := s + '}';
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


// Свидетельство о смерти (персональные данные)
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


// Свидетельство о смерти (decease_data)
class function TActDecease.DeceaseDS2JsonDcData(IDS : TDataSet) : string;
var
  sD,
  sP  : string;
begin

  sD :=
    '"death_cause":' +
      TClassifier.SetCT(IDS.FieldByName('SM_PRICH').AsString, 81) + ',' +
    '"death_date":"' + IDS.FieldByName('SM_DATE').AsString + '",' +
    '"death_place":"' + IDS.FieldByName('SM_GDE').AsString + '",' +
    '"burial_place":"' + IDS.FieldByName('SM_MESTO').AsString + '",';

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
begin
  Result := '"dcs_cert_data":{' +
    DeceaseDS2JsonOne(IDS, '', 'person_data') + ',' +
    DeceaseDS2JsonDcData(IDS) + ',' +
    '"reason":"' + IDS.FieldByName('SM_DOC').AsString + '",' +
    TDS2JSON.MakeActData(IDS, 'dcs_act_data') + ',' +
    TDS2JSON.MakeDocCertif(IDS, 'dcs_certificate_data', IDS.FieldByName('DOC_TIP').AsString) + '}';
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
begin
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
