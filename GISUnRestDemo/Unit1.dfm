object Form1: TForm1
  Left = 566
  Top = 99
  Width = 1237
  Height = 812
  Caption = 'ile'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblSSovCode: TLabel
    Left = 16
    Top = 9
    Width = 83
    Height = 13
    Caption = #1050#1086#1076' '#1086#1090#1076#1077#1083#1072' '#1043#1080#1052
  end
  object lblIndNum: TLabel
    Left = 304
    Top = 9
    Width = 105
    Height = 13
    Caption = #1048#1085#1076#1080#1074#1080#1076#1091#1072#1083#1100#1085#1099#1081' '#8470
  end
  object lblNsiType: TLabel
    Left = 160
    Top = 9
    Width = 88
    Height = 13
    Caption = #1050#1086#1076' '#1089#1087#1088#1072#1074#1086#1095#1085#1080#1082#1072
  end
  object lblFirst: TLabel
    Left = 16
    Top = 112
    Width = 60
    Height = 13
    Caption = #1053#1072#1095#1072#1090#1100' '#1089' ...'
  end
  object lblCount: TLabel
    Left = 160
    Top = 112
    Width = 87
    Height = 13
    Caption = #1042#1099#1073#1088#1072#1090#1100' '#1079#1072#1087#1080#1089#1077#1081
  end
  object lblDepartFromDate: TLabel
    Left = 16
    Top = 64
    Width = 70
    Height = 13
    Caption = #1059#1073#1099#1074#1096#1080#1077' '#1089' ...'
  end
  object lblINs: TLabel
    Left = 472
    Top = 9
    Width = 85
    Height = 13
    Caption = #1057#1087#1080#1089#1086#1082' '#1091#1073#1099#1074#1096#1080#1093
  end
  object lblDSD: TLabel
    Left = 472
    Top = 195
    Width = 126
    Height = 13
    Caption = #1057#1074#1077#1076#1077#1085#1080#1103' '#1086' '#1088#1077#1075#1080#1089#1090#1088#1072#1094#1080#1080
  end
  object lblChilds: TLabel
    Left = 472
    Top = 396
    Width = 26
    Height = 13
    Caption = #1044#1077#1090#1080
  end
  object lblNSI: TLabel
    Left = 472
    Top = 556
    Width = 61
    Height = 13
    Caption = #1057#1087#1088#1072#1074#1086#1095#1085#1080#1082
  end
  object edMemo: TMemo
    Left = 16
    Top = 328
    Width = 425
    Height = 281
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object gdIDs: TDBGridEh
    Left = 472
    Top = 30
    Width = 721
    Height = 143
    DataSource = DataSource1
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'Tahoma'
    FooterFont.Style = []
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object gdDocs: TDBGridEh
    Left = 472
    Top = 216
    Width = 721
    Height = 169
    DataSource = dsDocs
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'Tahoma'
    FooterFont.Style = []
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object gdChild: TDBGridEh
    Left = 472
    Top = 419
    Width = 721
    Height = 128
    DataSource = dsChild
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'Tahoma'
    FooterFont.Style = []
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object btnGetDocs: TButton
    Left = 16
    Top = 195
    Width = 121
    Height = 25
    Caption = ' --- '
    TabOrder = 4
    OnClick = btnGetDocsClick
  end
  object dtBegin: TDBDateTimeEditEh
    Left = 16
    Top = 84
    Width = 121
    Height = 21
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 5
    Visible = True
  end
  object dtEnd: TDBDateTimeEditEh
    Left = 160
    Top = 84
    Width = 121
    Height = 21
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 6
    Visible = True
  end
  object edOrgan: TDBEditEh
    Left = 16
    Top = 30
    Width = 121
    Height = 21
    EditButtons = <>
    TabOrder = 7
    Text = '11'
    Visible = True
  end
  object edFirst: TDBEditEh
    Left = 16
    Top = 130
    Width = 121
    Height = 21
    EditButtons = <>
    TabOrder = 8
    Text = '1'
    Visible = True
  end
  object edCount: TDBEditEh
    Left = 160
    Top = 130
    Width = 121
    Height = 21
    EditButtons = <>
    TabOrder = 9
    Text = '14'
    Visible = True
  end
  object btnPostDoc: TButton
    Left = 160
    Top = 235
    Width = 119
    Height = 25
    Caption = ' --- '
    TabOrder = 10
  end
  object btnGetActual: TButton
    Left = 160
    Top = 195
    Width = 121
    Height = 25
    Caption = ' --- '
    TabOrder = 11
  end
  object lstINs: TListBox
    Left = 304
    Top = 80
    Width = 121
    Height = 73
    ItemHeight = 13
    MultiSelect = True
    TabOrder = 12
  end
  object edtIN: TDBEditEh
    Left = 304
    Top = 30
    Width = 121
    Height = 21
    EditButtons = <>
    TabOrder = 13
    Text = '3141066C030PB2'
    Visible = True
  end
  object btnGetNSI: TButton
    Left = 304
    Top = 195
    Width = 121
    Height = 25
    Caption = ' --- '
    TabOrder = 14
  end
  object edNsiType: TDBEditEh
    Left = 160
    Top = 30
    Width = 65
    Height = 21
    EditButtons = <>
    TabOrder = 15
    Visible = True
  end
  object gdNsi: TDBGridEh
    Left = 472
    Top = 576
    Width = 721
    Height = 121
    DataSource = dsNsi
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'Tahoma'
    FooterFont.Style = []
    TabOrder = 16
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object edNsiCode: TDBEditEh
    Left = 240
    Top = 30
    Width = 41
    Height = 21
    EditButtons = <>
    TabOrder = 17
    Visible = True
  end
  object cbSrcPost: TDBComboBoxEh
    Left = 16
    Top = 237
    Width = 121
    Height = 21
    EditButtons = <>
    Items.Strings = (
      #1058#1077#1082#1091#1097#1080#1081' DSD'
      #1042#1089#1077' DSD'
      'J4Post.json'
      'J4PostNoPasp.json'
      'J4PostNoIN.json')
    TabOrder = 18
    Text = 'cbSrcPost'
    Visible = True
  end
  object cbAdsCvrt: TDBCheckBoxEh
    Left = 304
    Top = 238
    Width = 97
    Height = 17
    Caption = 'ADS-'#1082#1086#1087#1080#1103
    TabOrder = 19
    ValueChecked = 'True'
    ValueUnchecked = 'False'
  end
  object cbESTP: TDBCheckBoxEh
    Left = 16
    Top = 270
    Width = 121
    Height = 17
    Caption = #1069#1062#1055' '#1076#1083#1103' POST'
    TabOrder = 20
    ValueChecked = 'True'
    ValueUnchecked = 'False'
  end
  object cbClearLog: TDBCheckBoxEh
    Left = 344
    Top = 296
    Width = 97
    Height = 17
    Caption = #1054#1095#1080#1089#1090#1082#1072' '#1083#1086#1075#1072
    Checked = True
    State = cbChecked
    TabOrder = 21
    ValueChecked = 'True'
    ValueUnchecked = 'False'
  end
  object btnGetUN: TButton
    Left = 16
    Top = 626
    Width = 127
    Height = 25
    Caption = 'UN - GET IN (by FIO)'
    TabOrder = 22
    OnClick = btnGetUNClick
  end
  object btnGetPersData: TButton
    Left = 16
    Top = 668
    Width = 127
    Height = 25
    Caption = 'UN - GET PersData'
    TabOrder = 23
    OnClick = btnGetPersDataClick
  end
  object btnPostMarr: TButton
    Left = 162
    Top = 626
    Width = 127
    Height = 25
    Caption = 'UN - '#1056#1077#1075#1080#1089#1090#1088'. '#1073#1088#1072#1082#1072
    TabOrder = 24
    OnClick = btnPostMarrClick
  end
  object btnPostBirth: TButton
    Left = 162
    Top = 659
    Width = 127
    Height = 25
    Caption = 'UN - '#1056#1077#1075#1080#1089#1090#1088'. '#1088#1086#1078#1076'.'
    TabOrder = 25
    OnClick = btnPostBirthClick
  end
  object btnPostAffil: TButton
    Left = 162
    Top = 695
    Width = 127
    Height = 25
    Caption = 'UN - '#1056#1077#1075#1080#1089#1090#1088'. '#1086#1090#1094#1086#1074#1089#1090#1074#1072
    TabOrder = 26
    OnClick = btnPostAffilClick
  end
  object btnPostDecease: TButton
    Left = 162
    Top = 732
    Width = 127
    Height = 25
    Caption = 'UN - '#1056#1077#1075#1080#1089#1090#1088'. '#1089#1084#1077#1088#1090#1080
    TabOrder = 27
    OnClick = btnPostDeceaseClick
  end
  object btnPostDivr: TButton
    Left = 295
    Top = 626
    Width = 127
    Height = 25
    Caption = 'UN - '#1056#1077#1075#1080#1089#1090#1088'. '#1088#1072#1089#1090#1086#1088#1078'.'
    TabOrder = 28
    OnClick = btnPostDivrClick
  end
  object btnPostChgFIO: TButton
    Left = 295
    Top = 659
    Width = 127
    Height = 25
    Caption = 'UN - '#1056#1077#1075#1080#1089#1090#1088'. '#1089#1084#1077#1085#1072' '#1060#1048#1054
    TabOrder = 29
    OnClick = btnPostChgFIOClick
  end
  object btnIsoTime: TButton
    Left = 335
    Top = 731
    Width = 82
    Height = 25
    Caption = 'Time ='
    TabOrder = 30
    OnClick = btnIsoTimeClick
  end
  object btnGetNewIN: TButton
    Left = 16
    Top = 706
    Width = 127
    Height = 25
    Caption = 'UN - GET '#1053#1086#1074#1099#1081' '#1048#1053
    TabOrder = 31
    OnClick = btnGetNewINClick
  end
  object btnPostBurial: TButton
    Left = 472
    Top = 732
    Width = 169
    Height = 25
    Caption = 'UN - '#1052#1077#1089#1090#1085'-'#1047#1072#1093#1086#1088#1086#1085#1077#1085#1080#1077
    TabOrder = 32
    OnClick = btnPostBurialClick
  end
  object btnPostOpek: TButton
    Left = 664
    Top = 732
    Width = 169
    Height = 25
    Caption = 'UN - '#1052#1077#1089#1090#1085'-'#1054#1087#1077#1082#1072
    TabOrder = 33
    OnClick = btnPostOpekClick
  end
  object btnPostTrust: TButton
    Left = 840
    Top = 732
    Width = 169
    Height = 25
    Caption = 'UN - '#1052#1077#1089#1090#1085'-'#1055#1086#1087#1077#1095
    TabOrder = 34
    OnClick = btnPostTrustClick
  end
  object btnGetNsiUN: TButton
    Left = 15
    Top = 739
    Width = 127
    Height = 25
    Caption = 'UN - GET NSI'
    TabOrder = 35
    OnClick = btnGetNsiUNClick
  end
  object DataSource1: TDataSource
    Left = 664
    Top = 74
  end
  object dsDocs: TDataSource
    Left = 592
    Top = 309
  end
  object dsChild: TDataSource
    Left = 648
    Top = 469
  end
  object dsNsi: TDataSource
    Left = 633
    Top = 633
  end
  object cnctNsi: TAdsConnection
    ConnectPath = 'D:\App\'#1051#1040#1048#1057#1095'\Spr\ROC\'
    AdsServerTypes = [stADS_LOCAL]
    Left = 584
    Top = 640
  end
end
