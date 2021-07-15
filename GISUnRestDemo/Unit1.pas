unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, DateUtils,
  nativexml,
  superdate, superobject,
  StdCtrls, Mask,
  DBCtrlsEh,
  DB, Grids, DBGridEh,
  XSBuiltIns,
  adsdata, adsfunc, adstable, adscnnct,
  HTTPSend,
  ssl_openssl, ssl_openssl_lib,
  funcpr,
  mRegInt,
  uGisun,
  uROCExchg,
  uRestClient,
  uRegIntX;

type
  TForm1 = class(TForm)
    edMemo: TMemo;
    gdIDs: TDBGridEh;
    DataSource1: TDataSource;
    gdDocs: TDBGridEh;
    dsDocs: TDataSource;
    gdChild: TDBGridEh;
    dsChild: TDataSource;
    btnGetDocs: TButton;
    dtBegin: TDBDateTimeEditEh;
    dtEnd: TDBDateTimeEditEh;
    edOrgan: TDBEditEh;
    edFirst: TDBEditEh;
    edCount: TDBEditEh;
    btnPostDoc: TButton;
    btnGetActual: TButton;
    lstINs: TListBox;
    edtIN: TDBEditEh;
    btnGetNSI: TButton;
    lblSSovCode: TLabel;
    lblIndNum: TLabel;
    edNsiType: TDBEditEh;
    lblNsiType: TLabel;
    gdNsi: TDBGridEh;
    dsNsi: TDataSource;
    edNsiCode: TDBEditEh;
    cbSrcPost: TDBComboBoxEh;
    cnctNsi: TAdsConnection;
    cbAdsCvrt: TDBCheckBoxEh;
    cbESTP: TDBCheckBoxEh;
    cbClearLog: TDBCheckBoxEh;
    lblFirst: TLabel;
    lblCount: TLabel;
    lblDepartFromDate: TLabel;
    lblINs: TLabel;
    lblDSD: TLabel;
    lblChilds: TLabel;
    lblNSI: TLabel;
    btnGetUN: TButton;
    btnGetPersData: TButton;
    btnPostMarr: TButton;
    btnPostBirth: TButton;
    btnPostAffil: TButton;
    btnPostDecease: TButton;
    btnPostDivr: TButton;
    btnPostChgFIO: TButton;
    btnIsoTime: TButton;
    procedure btnGetActualClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnGetDocsClick(Sender: TObject);
    procedure btnGetNSIClick(Sender: TObject);
    procedure btnGetPersDataClick(Sender: TObject);
    procedure btnGetUNClick(Sender: TObject);
    procedure btnIsoTimeClick(Sender: TObject);
    procedure btnPostAffilClick(Sender: TObject);
    procedure btnPostBirthClick(Sender: TObject);
    procedure btnPostChgFIOClick(Sender: TObject);
    procedure btnPostDeceaseClick(Sender: TObject);
    procedure btnPostDivrClick(Sender: TObject);
    procedure btnPostDocClick(Sender: TObject);
    procedure btnPostMarrClick(Sender: TObject);
  private
    { Private declarations }
    procedure PrepUNResult(r : TRestResponse);
  public
    { Public declarations }
  end;


var
  Form1: TForm1;
  ShowM : TMemo;
  RegInt : TRegIntX;
  BlackBox : TROCExchg;
  // для отладки POST
  //GETRes : TResultHTTP;

implementation

uses
  kbmMemTable,
  SasaINiFile,
  uAvest,
  uROCService,
  fPIN4Av;

{$R *.dfm}

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

procedure Create4UN;
var
  Ini : TSasaIniFile;
begin
  Ini := TSasaIniFile.Create(UN_INI_NAME);
  RegInt := TRegIntX.Create('1', Ini);
  RegInt.ReadMetaInfo(UN_IN_FILES, UN_OUT_FILES);
end;



procedure TForm1.FormCreate(Sender: TObject);
begin
  ShowM := edMemo;
  edOrgan.Text  := '26';
//  dtBegin.Value := StrToDate('01.01.2021');
//  dtEnd.Value   := StrToDate('10.01.2021');
  dtBegin.Value := StrToDate('09.10.2020');
  dtEnd.Value   := StrToDate('01.01.2021');
  edFirst.Text  := '0';
  edCount.Text  := '10';
  cbSrcPost.ItemIndex := 0;

  BlackBox := TROCExchg.Create('..\..\Lais7\Service\' + INI_NAME);
  Self.Caption := 'Обмен с адресом: ' + BlackBox.Host.URL;
  Create4UN;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
end;


// Уехавшие из Sys_Organ
procedure TForm1.btnGetDocsClick(Sender: TObject);
var
  First, Count : Integer;
  D1, D2: TDateTime;
  P: TParsGet;
begin
  D1 := dtBegin.Value;
  D2 := dtEnd.Value;
  try
    First := Integer(edFirst.Value);
    except
    First := 0;
      end;

  try
    Count := Integer(edCount.Value);
    except
    Count := 0;
      end;

  if (First = 0) AND (Count = 0) then
    BlackBox.ResHTTP := BlackBox.GetDeparted(D1, D2, edOrgan.Text)
  else begin
    P := TParsGet.Create(D1, D2, edOrgan.Text);
    P.First := First;
    P.Count := Count;
    BlackBox.ResHTTP := BlackBox.GetDeparted(P);
  end;
  //GETRes := BlackBox.ResHTTP;
  ShowDeb(IntToStr(BlackBox.ResHTTP.ResCode) + ' ' + BlackBox.ResHTTP.ResMsg, cbClearLog.Checked);

  if (BlackBox.ResHTTP.INs.RecordCount > 0) then begin
    DataSource1.DataSet := BlackBox.ResHTTP.INs;
    dsDocs.DataSet := BlackBox.ResHTTP.Docs;
    dsChild.DataSet := BlackBox.ResHTTP.Child;
    BlackBox.ResHTTP.INs.First;
    while (NOT BlackBox.ResHTTP.INs.Eof) do begin
      if (BlackBox.ResHTTP.INs.Bof) then
        lstINs.Clear;
      lstINs.Items.Add(BlackBox.ResHTTP.INs.FieldValues['IDENTIF']);
      BlackBox.ResHTTP.INs.Next;
    end;

  end;

end;


// Актуальные установочные данные для ИН
procedure TForm1.btnGetActualClick(Sender: TObject);
var
  i: Integer;
  IndNums: TStringList;
  P: TParsGet;
begin
  if (lstINs.SelCount > 0) then begin
    if (lstINs.SelCount = 1) then
      // Выбран единственный - передается строка
      BlackBox.ResHTTP := BlackBox.GetActualReg(lstINs.Items[lstINs.ItemIndex])
    else begin
      // Выбрано несколько - передается список
      IndNums := TStringList.Create;
      for i := 1 to lstINs.SelCount do begin
        if (lstINs.Selected[i]) then
          IndNums.Add(lstINs.Items[i]);
      end;
      BlackBox.ResHTTP := BlackBox.GetActualReg(IndNums);
    end;
  end
  else
      // Ничего не выбрано, берем из TextBox
    BlackBox.ResHTTP := BlackBox.GetActualReg(edtIN.Text);
  ShowDeb(IntToStr(BlackBox.ResHTTP.ResCode) + ' ' + BlackBox.ResHTTP.ResMsg, cbClearLog.Checked);
  if (Assigned(BlackBox.ResHTTP)) then begin
    dsDocs.DataSet := BlackBox.ResHTTP.Docs;
    dsChild.DataSet := BlackBox.ResHTTP.Child;
  end;

end;

// Сохранить PIN
function SetAvestPass(Avest: TAvest): Boolean;
var
  sPin: string;
begin
  Result := False;
  if (Length(Avest.Password) = 0)
    OR (Avest.hDefSession = nil) then begin
    // Подключаться еще не пытались, нужен PIN
    fPINGet := TfPINGet.Create(nil);
    try
      if (fPINGet.ShowModal = mrOk) then begin
        fPINGet.SetResult(sPin);
        if (Length(sPin) > 0) then begin
          Avest.SetLoginParams(sPin, '');
          Result := True;
        end;
      end;
    finally
      fPINGet.Free;
      fPINGet := nil;
    end;
  end
  else
    Result := True;
end;


// Записать Актуальные установочные данные для ИН
procedure TForm1.btnPostDocClick(Sender: TObject);
const
  exmSign = 'amlsnandwkn&@871099udlaukbdeslfug12p91883y1hpd91h';
  exmSert = '109uu21nu0t17togdy70-fuib';
var
  iSrc: Integer;
  PPost: TParsPost;
  Res: TResultHTTP;
begin
  //edMemo.Clear;
  PPost := TParsPost.Create(exmSign, exmSert);
  iSrc := cbSrcPost.ItemIndex;
  if (cbSrcPost.ItemIndex in [0..1]) then begin
    // из MemTable
    PPost.JSONSrc := '';
    PPost.Docs := BlackBox.ResHTTP.Docs;
    PPost.Child := BlackBox.ResHTTP.Child;
    if (cbSrcPost.ItemIndex = 0) then
    // передача только текущей
      LeaveOnly1(dsDocs.DataSet);
  end
  else begin
    // из JSON-файла
    PPost.JSONSrc := cbSrcPost.Items[cbSrcPost.ItemIndex];
    //PPost.Docs := nil;
  end;

  BlackBox.Secure.SignPost := cbESTP.Checked;
  if (BlackBox.Secure.SignPost = True) then
    if (SetAvestPass(BlackBox.Secure.Avest) = False) then
      Exit;

  BlackBox.Secure.Avest.Debug := True;
  BlackBox.ResHTTP := BlackBox.PostRegDocs(PPost);
  ShowDeb(IntToStr(BlackBox.ResHTTP.ResCode) + ' ' + BlackBox.ResHTTP.ResMsg, cbClearLog.Checked);

end;


// Справочник ROC
procedure TForm1.btnGetNSIClick(Sender: TObject);
var
  ValidPars: Boolean;
  NsiCode, NsiType: integer;
  Path2Nsi : string;
  ParsNsi : TParsNsi;
begin
  try
    NsiType := StrToInt(edNsiType.Text);
    if (Length(edNsiCode.Text) > 0) then
      // только один элемент справочника
      NsiCode := StrToInt(edNsiCode.Text)
    else
      NsiCode := 0;
    ValidPars := True;
  except
    ValidPars := False;
  end;
  if (ValidPars = True) then begin
      cnctNsi.IsConnected := False;
      cnctNsi.ConnectPath := IncludeTrailingBackslash(BlackBox.Meta.ReadString(SCT_ADMIN, 'ADSPATH', '.'));
    ParsNsi := TParsNsi.Create(NsiType, cnctNsi);
    ParsNsi.ADSCopy := cbAdsCvrt.Checked;
    ParsNsi.NsiCode := NsiCode;
    BlackBox.ResHTTP := BlackBox.GetNSI(ParsNsi);
    if (BlackBox.ResHTTP.ResCode = 0) then begin
      dsNsi.DataSet := BlackBox.ResHTTP.Nsi;
      BlackBox.ResHTTP.Nsi.First;
    end;
    ShowDeb(IntToStr(BlackBox.ResHTTP.ResCode) + ' ' + BlackBox.ResHTTP.ResMsg, cbClearLog.Checked);
  end;
end;



procedure TForm1.PrepUNResult(r : TRestResponse);
begin
  ShowDeb(IntToStr(r.RetCode) + ' ' + r.RetMsg, cbClearLog.Checked);
  DataSource1.DataSet := r.OutDS;
  dsNsi.DataSet       := r.ErrDS;
  dsDocs.DataSet      := r.CourtDS;
  //RegInt.
end;



// GET Personal Data
procedure TForm1.btnGetPersDataClick(Sender: TObject);
var
  b : Boolean;
  i : Integer;
  s : string;
  dsRSud,
  dsDoc,
  dsOut,
  dsErr,
  d : TDataSet;
  sp : TStringList;
  r : TRestResponse;
  RetSOAP : TRequestResult;
begin
  sp := TStringList.Create;
  d := RegInt.CreateInputTable(akGetPersonalData, opGet);
  d.Append;
  d['IS_PERSON']  := True;
  //d['IDENTIF']    := '7172252A001PB3';
  d['IDENTIF']    := '3260578B005PB1';
  d['REQUEST_ID'] := NewGUID;
  d.Post;
  d.Append;
  d['IS_PERSON']  := True;
  d['IDENTIF']    := '4230478A031PB8';
  d['REQUEST_ID'] := NewGUID;
  d.Post;
  d.Append;
  d['IS_PERSON']  := False;
  d['POL']        := 'F';
  d['DATER']      := '20010511';
  d['REQUEST_ID'] := NewGUID;
  d.Post;
  d.Append;
  d['IS_PERSON']  := False;
  d['POL']        := 'M';
  d['DATER']      := '20020612';
  d['REQUEST_ID'] := NewGUID;
  d.Post;

  sp.Add('father=1');
  sp.Add('child=1');
  dsRSud := TRestResponse.CreateCourts;
  dsRSud.Open;
  sp.AddObject(PGET_SUD, dsRSud);

  RetSOAP := RegInt.Get(akGetPersonalData, QUERY_INFO, d, dsOut, dsErr, dsDoc, sp);
  PrepUNResult(RegInt.Response);
end;

// GET IN by FIO
procedure TForm1.btnGetUNClick(Sender: TObject);
var
  i : Integer;
  s : string;
  dsOut,
  dsErr,
  d : TDataSet;
  r : TRestResponse;
  RetSOAP : TRequestResult;
begin
  d := RegInt.CreateInputTable(akGetPersonIdentif, opGet);
  d.Append;
  d['FAMILIA'] := 'ИВАНОВ';
  d['NAME']    := 'ИВАН';
  d['OTCH']    := 'ИВАНОВИЧ';
  d['DATER']   := '20120511';
  d.Post;
  RetSOAP := RegInt.Get(akGetPersonIdentif, QUERY_INFO, d, dsOut, dsErr);
  PrepUNResult(RegInt.Response);
end;









// Установление отцовства
procedure TForm1.btnPostAffilClick(Sender: TObject);
var
  i : Integer;
  s : string;
  dsOut,
  dsErr,
  d : TDataSet;
  r : TRestResponse;
  RetSOAP : TRequestResult;
begin
  d := RegInt.CreateInputTable(akAffiliation, opPost);
  d.Append;

  d['R_TIP']       := '0100';
  d['R_ORGAN']     := '0';
  d['R_DATE']      := StrToDate('09.12.2015');
  d['R_NOMER']     := '12';

  // ребенок
  d['DO_IDENTIF']       := '7572323A001PB2';
  d['DO_FAMILIA']       := 'ИВАНОВА';
  d['DO_NAME']          := 'ИНГА';
  d['DO_OTCH']          := 'ВИКТОРОВНА';
  d['DO_FAMILIA_B']     := 'ІВАНОВА';
  d['DO_NAME_B']        := 'ІНГА';
  d['DO_OTCH_B']        := 'ВІКТАРАЎНА';
  d['DO_POL']           := 'F';
  d['DO_DATER']         := '20130621';

  //d['DO_GRAJD']     := 'BLR';
  d['DO_STATUS']    := '1';

  d['DO_GOSUD']    := 'BLR';
  d['DO_OBL']      := 'БРЕСТСКАЯ';
  //d['OBL_B']    := 'БРЭСЦКАЯ';
  d['DO_RAION']    := 'ВОЛОЖИНСКИй';
  //d['RAION_B']  := 'ВАЛОЖЫНСКІ';
  d['DO_TIP_GOROD'] := '11100002';
  d['DO_GOROD']    := 'Брест';
  //d['GOROD_B']  := 'Брэст';

  // ребенок ПОСЛЕ
  d['PO_IDENTIF']       := '7572323A001PB2';
  d['PO_FAMILIA']       := 'ИВАНОВА';
  d['PO_NAME']          := 'ИНГА';
  d['PO_OTCH']          := 'ВИКТОРОВНА';
  d['PO_FAMILIA_B']     := 'ІВАНОВА';
  d['PO_NAME_B']        := 'ІНГА';
  d['PO_OTCH_B']        := 'ВІКТАРАЎНА';
  d['PO_POL']           := 'F';
  d['PO_DATER']         := '20130621';

  //d['DO_GRAJD']     := 'BLR';
  d['PO_STATUS']    := '1';

  d['PO_GOSUD']    := 'BLR';
  d['PO_OBL']      := 'БРЕСТСКАЯ';
  //d['OBL_B']    := 'БРЭСЦКАЯ';
  d['PO_RAION']    := 'ВОЛОЖИНСКИй';
  //d['RAION_B']  := 'ВАЛОЖЫНСКІ';
  d['PO_TIP_GOROD'] := '11100002';
  d['PO_GOROD']    := 'Брест';
  //d['GOROD_B']  := 'Брэст';

  // мать
  d['ONA_IDENTIF']   := '7310278A001PB3';
  d['ONA_FAMILIA']   := 'ДЗИЧКОВСКАЯ';
  d['ONA_NAME']      := 'АНАСТАСИЯ';
  d['ONA_OTCH']      := 'ГЕОРГИЕВНА';
  d['ONA_FAMILIA_B'] := 'ДЗІЧКОЎСКАЯ';
  d['ONA_NAME_B']    := 'АНАСТАСІЯ';
  d['ONA_OTCH_B']    := 'ГЕОРГІЕЎНА';
  d['ONA_POL']       := 'F';
  d['ONA_DATER']     := '19830909';

  d['ONA_GRAJD']     := 'BLR';
  d['ONA_STATUS']    := '1';

  d['ONA_GOSUD']    := 'BLR';
  d['ONA_OBL']      := 'Минская';
  //d['ONA_OBL_B']    := 'Мiнская';
  d['ONA_RAION']    := 'Узденский';
  //d['ONA_RAION_B']  := 'Узденскi';
  d['ONA_TIP_GOROD'] := '11100001';
  d['ONA_GOROD']    := 'ГОМЕЛЬ';
  //d['ONA_GOROD_B']  := 'ГОМЕЛЬ';

  // отец
  d['ON_IDENTIF']   := '3021285A031PB5';
  d['ON_FAMILIA']   := 'ГРОМОВИЧ';
  d['ON_NAME']      := 'ПАВЕЛ';
  d['ON_OTCH']      := 'ИГОРЕВИЧ';
  d['ON_FAMILIA_B'] := 'ГРАМОВІЧ';
  d['ON_NAME_B']    := 'ПАВЕЛ';
  d['ON_OTCH_B']    := 'ІГАРАВІЧ';
  d['ON_POL']       := 'M';
  d['ON_DATER']     := '19851202';

  d['ON_GRAJD']     := 'BLR';
  d['ON_STATUS']    := '4';

  d['ON_GOSUD']   := 'BLR';
  d['ON_OBL']     := 'Минская';
  //d['ON_OBL_B']   := 'Мiнская';
  d['ON_RAION']   := 'Узденский';
  //d['ON_RAION_B'] := 'Узденскi';
  d['ON_TIP_GOROD'] := '11100001';
  d['ON_GOROD']   := 'МИНСК';
  //d['ON_GOROD_B'] := 'МІНСК';

  // Решение суда
  d['SUD_NAME']     := 'Просто суд';
  d['SUD_DATE']      := '19851202';
  d['SUD_COMM']     := '18108';

  d['ACT_TIP']       := '0100';
  d['ACT_ORGAN']     := '18108';
  d['ACT_ORGAN_LEX'] := 'ЗАГС районный';
  d['ACT_DATE']      := StrToDate('22.06.2013');
  d['ACT_NOMER']     := '1243';

  d['DOC_ONA_TIP']       := '54100027';
  d['DOC_ONA_ORGAN']     := '18108';
  d['DOC_ONA_DATE']      := StrToDate('23.06.2013');
  d['DOC_ONA_SERIA']     := 'I-АЛ';
  d['DOC_ONA_NOMER']     := '2222225';

  d['DOC_ON_TIP']       := '54100026';
  d['DOC_ON_ORGAN']     := '18108';
  d['DOC_ON_DATE']      := StrToDate('23.06.2013');
  d['DOC_ON_SERIA']     := 'I-АЛ';
  d['DOC_ON_NOMER']     := '2222225';

  d.Post;
  s := NewGUID;
  RetSOAP := RegInt.Post(s, akAffiliation, '0200', d, dsErr);
end;

// Свидетельство о рождении
procedure TForm1.btnPostBirthClick(Sender: TObject);
var
  i : Integer;
  s : string;
  dsOut,
  dsErr,
  d : TDataSet;
  r : TRestResponse;
  RetSOAP : TRequestResult;
begin
  d := RegInt.CreateInputTable(akBirth, opPost);
  d.Append;

  // ребенок
  d['IDENTIF']       := '7027566A001PB8';
  d['FAMILIA']       := 'ИВАНОВА';
  d['NAME']          := 'ИНГА';
  d['OTCH']          := 'ВИКТОРОВНА';
  d['FAMILIA_B']     := 'ІВАНОВА';
  d['NAME_B']        := 'ІНГА';
  d['OTCH_B']        := 'ВІКТАРАЎНА';
  d['POL']           := 'F';
  d['DATER']         := '20130621';

  d['GRAJD']     := 'BLR';
  d['STATUS']    := '1';

  d['GOSUD']    := 'BLR';
  d['OBL']      := 'БРЕСТСКАЯ';
  d['OBL_B']    := 'БРЭСЦКАЯ';
  d['RAION']    := 'ВОЛОЖИНСКИй';
  d['RAION_B']  := 'ВАЛОЖЫНСКІ';
  d['TIP_GOROD'] := '11100002';
  d['GOROD']    := 'Брест';
  d['GOROD_B']  := 'Брэст';

  d['K_ATE_R'] := '111000';

  // мать
  d['ONA_IDENTIF']   := '7310278A001PB3';
  d['ONA_FAMILIA']   := 'ДЗИЧКОВСКАЯ';
  d['ONA_NAME']      := 'АНАСТАСИЯ';
  d['ONA_OTCH']      := 'ГЕОРГИЕВНА';
  d['ONA_FAMILIA_B'] := 'ДЗІЧКОЎСКАЯ';
  d['ONA_NAME_B']    := 'АНАСТАСІЯ';
  d['ONA_OTCH_B']    := 'ГЕОРГІЕЎНА';
  d['ONA_POL']       := 'F';
  d['ONA_DATER']     := '19830909';

  d['ONA_GRAJD']     := 'BLR';
  d['ONA_STATUS']    := '1';

  d['ONA_GOSUD']    := 'BLR';
  d['ONA_OBL']      := 'Минская';
  //d['ONA_OBL_B']    := 'Мiнская';
  d['ONA_RAION']    := 'Узденский';
  //d['ONA_RAION_B']  := 'Узденскi';
  d['ONA_TIP_GOROD'] := '11100001';
  d['ONA_GOROD']    := 'ГОМЕЛЬ';
  //d['ONA_GOROD_B']  := 'ГОМЕЛЬ';

  // отец
  d['ON_IDENTIF']   := '3021285A031PB5';
  d['ON_FAMILIA']   := 'ГРОМОВИЧ';
  d['ON_NAME']      := 'ПАВЕЛ';
  d['ON_OTCH']      := 'ИГОРЕВИЧ';
  d['ON_FAMILIA_B'] := 'ГРАМОВІЧ';
  d['ON_NAME_B']    := 'ПАВЕЛ';
  d['ON_OTCH_B']    := 'ІГАРАВІЧ';
  d['ON_POL']       := 'M';
  d['ON_DATER']     := '19851202';

  d['ON_GRAJD']     := 'BLR';
  d['ON_STATUS']    := '4';

  d['ON_GOSUD']   := 'BLR';
  d['ON_OBL']     := 'Минская';
  //d['ON_OBL_B']   := 'Мiнская';
  d['ON_RAION']   := 'Узденский';
  //d['ON_RAION_B'] := 'Узденскi';
  d['ON_TIP_GOROD'] := '11100001';
  d['ON_GOROD']   := 'МИНСК';
  //d['ON_GOROD_B'] := 'МІНСК';

  d['ACT_TIP']       := '0100';
  d['ACT_ORGAN']     := '18108';
  d['ACT_ORGAN_LEX'] := 'ЗАГС районный';
  d['ACT_DATE']      := StrToDate('22.06.2013');
  d['ACT_NOMER']     := '1243';

  d['DOC_TIP']       := '54100005';
  d['DOC_ORGAN']     := '18108';
  d['DOC_DATE']      := StrToDate('23.06.2013');
  d['DOC_SERIA']     := 'I-АЛ';
  d['DOC_NOMER']     := '2222225';

  d.Post;
  s := NewGUID;
  RetSOAP := RegInt.Post(s, akBirth, '0160', d, dsErr);
end;



// Свидетельство о браке
procedure TForm1.btnPostMarrClick(Sender: TObject);
var
  i : Integer;
  s : string;
  dsOut,
  dsErr,
  d : TDataSet;
  r : TRestResponse;
  RetSOAP : TRequestResult;
begin
  d := RegInt.CreateInputTable(akMarriage, opPost);
  d.Append;

  d['ONA_IDENTIF']   := '7172252A001PB3';
  d['ONA_FAMILIA']   := 'СТАНКЕВИЧ';
  d['ONA_NAME']      := 'СВЕТЛАНА';
  d['ONA_OTCH']      := 'ПЕТРОВНА';
  d['ONA_FAMILIA_B'] := 'СТАНКЕВІЧ';
  d['ONA_NAME_B']    := 'СВЯТЛАНА';
  d['ONA_OTCH_B']    := 'ПЯТРОЎНА';
  d['ONA_POL']       := 'F';
  d['ONA_DATER']     := '20120511';

  d['ONA_GRAJD']     := 'BLR';
  d['ONA_STATUS']    := '1';

  d['ONA_GOSUD']    := 'BLR';
  d['ONA_OBL']      := 'Минская';
  d['ONA_OBL_B']    := 'Мiнская';
  d['ONA_RAION']    := 'Узденский';
  d['ONA_RAION_B']  := 'Узденскi';
  d['ONA_TIP_GOROD'] := '11100001';
  d['ONA_GOROD']    := 'Брест';
  d['ONA_GOROD_B']  := 'Брэст';

  d['ONA_FAMILIA_OLD'] := 'RERE';

  d['ON_IDENTIF']   := '3010182A132PB7';
  d['ON_FAMILIA']   := 'ЮРЧЕНКО';
  d['ON_NAME']      := 'НИКОЛАЙ';
  d['ON_OTCH']      := 'НИКОЛАЕВИЧ';
  d['ON_FAMILIA_B'] := 'ЮРЧАНКА';
  d['ON_NAME_B']    := 'МІКАЛАЙ';
  d['ON_OTCH_B']    := 'МІКАЛАЕВІЧ';
  d['ON_POL']       := 'M';
  d['ON_DATER']     := '20120511';

  d['ON_GRAJD']     := 'BLR';
  d['ON_STATUS']    := '1';

  d['ON_GOSUD']   := 'BLR';
  d['ON_OBL']     := 'Минская';
  d['ON_OBL_B']   := 'Мiнская';
  d['ON_RAION']   := 'Узденский';
  d['ON_RAION_B'] := 'Узденскi';
  d['ON_TIP_GOROD'] := '11100001';
  d['ON_GOROD']   := 'Брест';
  d['ON_GOROD_B'] := 'Брэст';

  d['ON_FAMILIA_OLD'] := '---';

  d['ACT_TIP']       := '0300';
  d['ACT_ORGAN']     := '617';
  d['ACT_ORGAN_LEX'] := 'ЗАГС районный';
  d['ACT_DATE']      := StrToDate('08.08.2013');
  d['ACT_NOMER']     := '12';

  d['DOC_TIP']       := '54100006';
  d['DOC_ORGAN']     := '617';
  d['DOC_DATE']      := StrToDate('11.08.2013');
  d['DOC_SERIA']     := 'I-АЛ';
  d['DOC_NOMER']     := '0221734';

  d.Post;
  s := NewGUID;
  RetSOAP := RegInt.Post(s, akMarriage, '0300', d, dsErr);
end;

// Свидетельство о смерти
procedure TForm1.btnPostDeceaseClick(Sender: TObject);
var
  i : Integer;
  s : string;
  dsOut,
  dsErr,
  d : TDataSet;
  r : TRestResponse;
  RetSOAP : TRequestResult;
begin
  d := RegInt.CreateInputTable(akDecease, opPost);
  d.Append;

  //
  d['IDENTIF']       := '7027566A001PB8';
  d['FAMILIA']       := 'ИВАНОВА';
  d['NAME']          := 'ИНГА';
  d['OTCH']          := 'ВИКТОРОВНА';
  d['FAMILIA_B']     := 'ІВАНОВА';
  d['NAME_B']        := 'ІНГА';
  d['OTCH_B']        := 'ВІКТАРАЎНА';
  d['POL']           := 'F';
  d['DATER']         := '20130621';
  d['GRAJD']     := 'BLR';
  d['STATUS']    := '1';

  // Место рождения
  d['GOSUD_R']    := 'BLR';
  d['OBL_R']      := 'БРЕСТСКАЯ';
  d['RAION_R']    := 'ВОЛОЖИНСКИй';
  d['TIP_GOROD'] := '11100002';
  d['GOROD']    := 'Брест';

  // Место смерти
  d['GOSUD']    := 'BLR';
  d['OBL']      := 'БРЕСТСКАЯ';
  d['OBL_B']    := 'БРЭСЦКАЯ';
  d['RAION']    := 'ВОЛОЖИНСКИй';
  d['RAION_B']  := 'ВАЛОЖЫНСКІ';
  d['TIP_GOROD'] := '11100002';
  d['GOROD']    := 'Брест';
  d['GOROD_B']  := 'Брэст';

  d['SM_PRICH']      := 'A06.9';
  d['SM_DATE']       := '20160307';
  d['SM_GDE']        := 'Перекресток';
  d['SM_MESTO']      := 'Кладбище';

  d['SM_DOC']        := 'Справка';

  d['ACT_TIP']       := '0400';
  d['ACT_ORGAN']     := '18108';
  d['ACT_ORGAN_LEX'] := 'ЗАГС районный';
  d['ACT_DATE']      := StrToDate('22.06.2013');
  d['ACT_NOMER']     := '1243';

  d['DOC_TIP']       := '54100009';
  d['DOC_ORGAN']     := '18108';
  d['DOC_DATE']      := StrToDate('23.06.2013');
  d['DOC_SERIA']     := 'I-АЛ';
  d['DOC_NOMER']     := '2222225';

  d.Post;
  s := NewGUID;
  RetSOAP := RegInt.Post(s, akDecease, '0400', d, dsErr);
end;

// Свидетельство о расторжении брака
procedure TForm1.btnPostDivrClick(Sender: TObject);
var
  i : Integer;
  s : string;
  dsOut,
  dsErr,
  d : TDataSet;
  r : TRestResponse;
  RetSOAP : TRequestResult;
begin
  d := RegInt.CreateInputTable(akDivorce, opPost);
  d.Append;

  d['ONA_IDENTIF']   := '7172252A001PB3';
  d['ONA_FAMILIA']   := 'СТАНКЕВИЧ';
  d['ONA_NAME']      := 'СВЕТЛАНА';
  d['ONA_OTCH']      := 'ПЕТРОВНА';
  d['ONA_FAMILIA_B'] := 'СТАНКЕВІЧ';
  d['ONA_NAME_B']    := 'СВЯТЛАНА';
  d['ONA_OTCH_B']    := 'ПЯТРОЎНА';
  d['ONA_POL']       := 'F';
  d['ONA_DATER']     := '20120511';

  d['ONA_GRAJD']     := 'BLR';
  d['ONA_STATUS']    := '1';

  d['ONA_GOSUD']    := 'BLR';
  d['ONA_OBL']      := 'Минская';
  //d['ONA_OBL_B']    := 'Мiнская';
  d['ONA_RAION']    := 'Узденский';
  //d['ONA_RAION_B']  := 'Узденскi';
  d['ONA_TIP_GOROD'] := '11100001';
  d['ONA_GOROD']    := 'Брест';
  //d['ONA_GOROD_B']  := 'Брэст';

  d['ONA_FAMILIA_OLD'] := 'RERE';

  d['ON_IDENTIF']   := '3010182A132PB7';
  d['ON_FAMILIA']   := 'ЮРЧЕНКО';
  d['ON_NAME']      := 'НИКОЛАЙ';
  d['ON_OTCH']      := 'НИКОЛАЕВИЧ';
  d['ON_FAMILIA_B'] := 'ЮРЧАНКА';
  d['ON_NAME_B']    := 'МІКАЛАЙ';
  d['ON_OTCH_B']    := 'МІКАЛАЕВІЧ';
  d['ON_POL']       := 'M';
  d['ON_DATER']     := '20120511';

  d['ON_GRAJD']     := 'BLR';
  d['ON_STATUS']    := '1';

  d['ON_GOSUD']   := 'BLR';
  d['ON_OBL']     := 'Минская';
  //d['ON_OBL_B']   := 'Мiнская';
  d['ON_RAION']   := 'Узденский';
  //d['ON_RAION_B'] := 'Узденскi';
  d['ON_TIP_GOROD'] := '11100001';
  d['ON_GOROD']   := 'Брест';
  //d['ON_GOROD_B'] := 'Брэст';

  d['ON_FAMILIA_OLD'] := '---';

  d['BRAK_TIP']       := '0300';
  d['BRAK_ORGAN']     := '617';
  d['BRAK_DATE']      := StrToDate('08.08.2013');
  d['BRAK_NOMER']     := '7712';

  // Решение суда
  d['SUD_NAME']     := 'Просто суд';
  d['SUD_DATE']      := '19851202';
  d['SUD_COMM']     := '18108';

  d['ACT_TIP']       := '0300';
  d['ACT_ORGAN']     := '617';
  d['ACT_ORGAN_LEX'] := 'ЗАГС районный';
  d['ACT_DATE']      := StrToDate('08.08.2013');
  d['ACT_NOMER']     := '12';

  d['ONA_TIP']       := '54100007';
  d['ONA_ORGAN']     := '617';
  d['ONA_DATE']      := StrToDate('11.08.2013');
  d['ONA_SERIA']     := 'I-АЛ';
  d['ONA_NOMER']     := '0221734';

  d['ON_TIP']       := '54100008';
  d['ON_ORGAN']     := '617';
  d['ON_DATE']      := StrToDate('11.08.2013');
  d['ON_SERIA']     := 'I-АЛ';
  d['ON_NOMER']     := '0221734';

  d.Post;
  s := NewGUID;
  RetSOAP := RegInt.Post(s, akDivorce, '0500', d, dsErr);
end;

procedure TForm1.btnPostChgFIOClick(Sender: TObject);
var
  i : Integer;
  s : string;
  dsOut,
  dsErr,
  d : TDataSet;
  r : TRestResponse;
  RetSOAP : TRequestResult;
begin
  d := RegInt.CreateInputTable(akNameChange, opPost);
  d.Append;

  //
  d['IDENTIF']       := '7027566A001PB8';
  d['FAMILIA']       := 'ИВАНОВА';
  d['NAME']          := 'ИНГА';
  d['OTCH']          := 'ВИКТОРОВНА';
  d['FAMILIA_B']     := 'ІВАНОВА';
  d['NAME_B']        := 'ІНГА';
  d['OTCH_B']        := 'ВІКТАРАЎНА';
  d['POL']           := 'F';
  d['DATER']         := '20130621';

  d['GRAJD']     := 'BLR';
  d['STATUS']    := '1';

  d['GOSUD']    := 'BLR';
  d['OBL']      := 'БРЕСТСКАЯ';
  d['OBL_B']    := 'БРЭСЦКАЯ';
  d['RAION']    := 'ВОЛОЖИНСКИй';
  d['RAION_B']  := 'ВАЛОЖЫНСКІ';
  d['TIP_GOROD'] := '11100002';
  d['GOROD']    := 'Брест';
  d['GOROD_B']  := 'Брэст';

  // Предыдущее
  d['DO_FAMILIA']   := 'ДЗИЧКОВСКАЯ';
  d['DO_NAME']      := 'АНАСТАСИЯ';
  d['DO_OTCH']      := 'ГЕОРГИЕВНА';

  d['R_TIP']       := '0100';
  d['R_ORGAN']     := '0';
  d['R_DATE']      := StrToDate('09.12.2015');
  d['R_NOMER']     := '12';

  d['OSNOV']     := '12';

  d['ACT_TIP']       := '0100';
  d['ACT_ORGAN']     := '18108';
  d['ACT_ORGAN_LEX'] := 'ЗАГС районный';
  d['ACT_DATE']      := StrToDate('22.06.2013');
  d['ACT_NOMER']     := '1243';

  d['DOC_TIP']       := '54100005';
  d['DOC_ORGAN']     := '18108';
  d['DOC_DATE']      := StrToDate('23.06.2013');
  d['DOC_SERIA']     := 'I-АЛ';
  d['DOC_NOMER']     := '2222225';

  d.Post;
  s := NewGUID;
  RetSOAP := RegInt.Post(s, akNameChange, '0700', d, dsErr);
end;












function IsoTime(const Value: String): TDateTime;
var
  d : TDateTime;
begin
  with XSBuiltIns.TXSDateTime.Create do
  try
    XSToNative(Value);
    //Result := AsUTCDateTime;
    Result := AsDateTime;
  finally
    Free;
  end;

end;

procedure TForm1.btnIsoTimeClick(Sender: TObject);
var
  b : Boolean;
  t : string;
  d : TDateTime;
  ds : TDataSet;
begin
  t := '2000-07-20T00:00:00.000+03:00';
  d := IsoTime(t);
  //d := IncHour(d, 3);
  ISO8601DateToDelphiDateTime(t, d);

  b := ds is TDataSet;
  if (b) then
    t := 'Really DataSet'
  else
    t := 'Something...';

  TButton(Sender).Caption := t + '===Date: ' + FormatDateTime('yyyy-mm-dd hh:MM:ss', d);
end;

//
end.
