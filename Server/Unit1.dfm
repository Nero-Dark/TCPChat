object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = #1057#1077#1088#1074#1077#1088
  ClientHeight = 401
  ClientWidth = 730
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StaticText1: TStaticText
    Left = 463
    Top = 6
    Width = 116
    Height = 20
    Caption = #1055#1086#1076#1082#1083#1102#1095#1077#1085#1085#1099#1077':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindow
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 382
    Width = 730
    Height = 19
    Panels = <
      item
        Width = 80
      end
      item
        Width = 130
      end
      item
        Width = 50
      end>
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 449
    Height = 369
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object StringGrid1: TStringGrid
    Left = 463
    Top = 32
    Width = 258
    Height = 345
    ColCount = 3
    FixedCols = 0
    RowCount = 6
    TabOrder = 3
  end
  object MainMenu1: TMainMenu
    Left = 560
    Top = 344
    object N1: TMenuItem
      Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077
      object N2: TMenuItem
        Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1089#1077#1088#1074#1077#1088
        OnClick = N2Click
      end
      object N3: TMenuItem
        Caption = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1089#1077#1088#1074#1077#1088
        OnClick = N3Click
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object N5: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = N5Click
      end
    end
    object N6: TMenuItem
      Caption = #1055#1086#1084#1086#1097#1100
      object N7: TMenuItem
        Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
      end
    end
  end
  object ImageList1: TImageList
    Left = 608
    Top = 344
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 0
    OnConnect = IdTCPServer1Connect
    OnDisconnect = IdTCPServer1Disconnect
    OnExecute = IdTCPServer1Execute
    Left = 512
    Top = 344
  end
  object ADOConnection1: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=E:\Users\LORD\Deskt' +
      'op\TCP_Chat\Server\Win32\Debug\Users_DB.mdb;Persist Security Inf' +
      'o=False'
    Mode = cmShareDenyNone
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 512
    Top = 296
  end
  object ADOTable1: TADOTable
    Active = True
    Connection = ADOConnection1
    CursorType = ctStatic
    TableName = 'Users Table'
    Left = 560
    Top = 296
  end
  object IdDecoderXXE1: TIdDecoderXXE
    FillChar = '+'
    Left = 608
    Top = 296
  end
end
