object TCP_Chat_Service: TTCP_Chat_Service
  OldCreateOrder = False
  AllowPause = False
  DisplayName = 'TCP_Chat_Service'
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 74
  Width = 205
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 5060
    OnConnect = IdTCPServer1Connect
    OnDisconnect = IdTCPServer1Disconnect
    OnExecute = IdTCPServer1Execute
    Left = 24
    Top = 16
  end
  object ADOConnection1: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=Users_DB.mdb;Persis' +
      't Security Info=False'
    Mode = cmShareDenyNone
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 64
    Top = 16
  end
  object ADOTable1: TADOTable
    Connection = ADOConnection1
    TableName = 'Users Table'
    Left = 104
    Top = 16
  end
  object IdDecoderXXE1: TIdDecoderXXE
    FillChar = '+'
    Left = 144
    Top = 16
  end
end
