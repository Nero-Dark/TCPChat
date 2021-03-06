unit Main_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdTCPServer, INIFiles, IdGlobal, FileCtrl,
  IdContext,WinSock, IdCoder, IdCoder3to4, IdCoder00E, IdCoderXXE, Data.DB,System.StrUtils,
  Data.Win.ADODB;

type
  TConnectedUsers = record
    Nickname: string;
    clIP: string;
    Used: boolean;
    room: string;
  end;

type  TRooms = record
  RoomName: string;
  Users: array of TConnectedUsers;
  Used: boolean;
end;

type
  TTCP_Chat_Service = class(TService)
    IdTCPServer1: TIdTCPServer;
    ADOConnection1: TADOConnection;
    ADOTable1: TADOTable;
    IdDecoderXXE1: TIdDecoderXXE;
    procedure IdTCPServer1Connect(AContext: TIdContext);
    procedure IdTCPServer1Disconnect(AContext: TIdContext);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  TCP_Chat_Service: TTCP_Chat_Service;
  LogDir, ConUsLine: string;
  LogFile: TextFile;
  port: Word;
  ConnectedUsers: array of TConnectedUsers;

implementation

{$R *.dfm}

procedure AddLog(var add: string);
begin
  AssignFile(logfile, ExtractFileDir(ParamStr(0)) + '\log\[' + DateToStr(Now) + '].txt');
  if FileExists(ExtractFileDir(ParamStr(0)) + '\log\[' +  DateToStr(Now) + '].txt') then
    Append(logfile)
  else
    Rewrite(logfile);
  Writeln(logfile, add);
  CloseFile(logfile);
end;

function GetLocalIP: String;
const WSVer = $101;
var
  wsaData: TWSAData;
  P: PHostEnt;
  Buf: array [0..127] of Char;
begin
  Result := '';
  if WSAStartup(WSVer, wsaData) = 0 then
    begin
      if GetHostName(@Buf, 128) = 0 then
        begin
          P := GetHostByName(@Buf);
          if P <> nil then Result := iNet_ntoa(PInAddr(p^.h_addr_list^)^);
        end;
      WSACleanup;
    end;
end;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  TCP_Chat_Service.Controller(CtrlCode);
end;

function TTCP_Chat_Service.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TTCP_Chat_Service.IdTCPServer1Connect(AContext: TIdContext);
var
  IP, nick, add, pass, connectline: string;
  i, ConnectedCount: integer;
  separator: char;
begin
  ConUsLine:='';
  separator:=#9;
  ConnectedCount := 0;
  for i := 0 to High(ConnectedUsers) do
    if ConnectedUsers[i].Used then
      Inc(ConnectedCount);

  if ConnectedCount = Length(ConnectedUsers) then
  begin
    AContext.Connection.Socket.WriteLn('$F');
    AContext.Connection.Socket.Close;
  end
  else
  begin
    IP := AContext.Connection.Socket.Binding.PeerIP;
    ConnectLine := AContext.Connection.Socket.ReadLn();
    nick:=copy(ConnectLine,1,pos(Separator,ConnectLine)-1);
    delete(ConnectLine,1,pos(separator,ConnectLine));
    pass:=IdDecoderXXE1.DecodeString(Connectline);
    ConnectLine:='';

    ADOTable1.First;
    While not ADOTable1.Eof do
      begin
          if nick = ADOTable1.FieldByName('Nickname').AsString then
            begin
              if pass = ADOTable1.FieldByName('Pass').AsString then
                begin
                  for i := 0 to Length(ConnectedUsers) - 1 do
                    if not ConnectedUsers[i].Used then
                      begin
                        ConnectedUsers[i].clIP := IP;
                        ConnectedUsers[i].Nickname := nick;
                        ConnectedUsers[i].Used := True;
                        ConnectedUsers[i].room:='All';
                        break;
                      end;

                  add := '[' + TimeToStr(Now) + '] ?????? ?????????: ' + nick + ' ['
                          + IP + ']';
                  AddLog(add);
                  for I := 0 to High(ConnectedUsers) do
                    if ConnectedUsers[i].Nickname <> '' then
                      ConUsLine:=ConUsLine + ConnectedUsers[i].Nickname +#9;
                  with IdTCPServer1.Contexts.LockList do
                    try
                      for I := 0 to High(ConnectedUsers) do
                        if ConnectedUsers[i].Used then
                          begin
                            TIdContext(Items[i]).Connection.IOHandler.Destination:=ConnectedUsers[i].clIP;
                            TIdContext(Items[i]).Connection.IOHandler.WriteLn('$L ' + ConUsLine);
                          end;
                    finally
                      IdTCPServer1.Contexts.UnlockList;
                    end;

                  Exit;
                end
              else
                begin
                  AContext.Connection.Socket.WriteLn('%P');
                  AContext.Connection.Socket.Close;
                  Exit;
                end;
            end;
        ADOTable1.Next;
      end;

    AContext.Connection.Socket.WriteLn('%N');
    AContext.Connection.Socket.Close;
  end;
end;

procedure TTCP_Chat_Service.IdTCPServer1Disconnect(AContext: TIdContext);
var
  i: integer;
  add, nick, IP: string;
begin
  ConUsLine:='';
  IP := AContext.Connection.Socket.Binding.PeerIP;
  for i := 0 to High(ConnectedUsers) do
  begin
    if ConnectedUsers[i].clIP = IP then
    begin
      nick := ConnectedUsers[i].Nickname;
      ConnectedUsers[i].Nickname := '';
      ConnectedUsers[i].clIP := '';
      ConnectedUsers[i].Room:='';
      ConnectedUsers[i].Used := false;
    end;
  end;

  add := '[' + TimeToStr(Now) + '] ?????? ????????: ' + nick + ' [' + IP + ']';
  AddLog(add);
  for I := 0 to High(ConnectedUsers) do
    if ConnectedUsers[i].Nickname <> '' then
      ConUsLine:=ConUsLine + ConnectedUsers[i].Nickname +#9;
  with IdTCPServer1.Contexts.LockList do
    try
      for i := 0 to Count - 1 do
        TIdContext(Items[i]).Connection.IOHandler.WriteLn('$L ' + ConUsLine);
    finally
      IdTCPServer1.Contexts.UnlockList;
    end;

end;

procedure TTCP_Chat_Service.IdTCPServer1Execute(AContext: TIdContext);
var
  RMessage, add: string;
  i: integer;
  sepS,sepE: char;
  toUser,room,fromWho:string;
begin
  sepS:='(';
  sepE:=')';
  RMessage := AContext.Connection.Socket.ReadLn(IndyTextEncoding_UTF8);
  for i := 0 to High(ConnectedUsers) do
    begin
      if ConnectedUsers[i].clIP = AContext.Connection.Socket.Binding.PeerIP then
        fromWho:=ConnectedUsers[i].Nickname;
    end;
  if ContainsText(RMessage,sepS) then
    begin
      toUser:=copy(RMessage,pos(sepS,RMessage)+1,pos(SepE,RMessage)-pos(sepS,RMessage)-1);
      with IdTCPServer1.Contexts.LockList do
        try
          for I := 0 to High(ConnectedUsers) do
            begin
              if ConnectedUsers[i].Nickname = toUser then
                begin
                  TIdContext(Items[i]).Connection.IOHandler.Destination:=ConnectedUsers[i].clIP;
                  TIdContext(Items[i]).Connection.IOHandler.WriteLn('$P' + RMessage,IndyTextEncoding_UTF8);
                  System.Insert('-->',RMessage,pos(SepS,RMessage)-1);
                end;
            end;
        finally
          IdTCPServer1.Contexts.UnlockList;
        end;
      add:=RMessage + ' [' + TimeToStr(Now) + ']';
      AddLog(add);
    end;

  sepS:='{';
  sepE:='}';
  if ContainsText(RMessage,sepS) then
    begin
      room:=copy(RMessage,pos(sepS,RMessage)+1,pos(SepE,RMessage)-pos(sepS,RMessage)-1);
      with IdTCPServer1.Contexts.LockList do
        try
          for I := 0 to High(ConnectedUsers) do
            begin
              if (ConnectedUsers[i].room = room) and (fromWho <> ConnectedUsers[i].Nickname) then
                begin
                  TIdContext(Items[i]).Connection.IOHandler.Destination:=ConnectedUsers[i].clIP;
                  TIdContext(Items[i]).Connection.IOHandler.WriteLn('$M' + RMessage, IndyTextEncoding_UTF8);
                end;
            end;
        finally
          IdTCPServer1.Contexts.UnlockList;
        end;
      System.Insert('-->',RMessage,pos(SepS,RMessage)-1);
      add:=RMessage + ' [' + TimeToStr(Now) + ']';
      AddLog(add);
    end;


  if Copy(RMessage,1,2)= '$R' then
    Begin
      delete(RMessage,1,2);
      for I := 0 to High(ConnectedUsers) do
        if ConnectedUsers[i].clIP = AContext.Connection.Socket.Binding.PeerIP then
          ConnectedUsers[i].room:=RMessage;
    End
end;

procedure TTCP_Chat_Service.ServiceStart(Sender: TService;
  var Started: Boolean);
var add:string;
    OptionsINI: TINIFile;
    i,Count:integer;
begin
  OptionsINI:=TIniFile.Create(ExtractFileDir(ParamStr(0)) + '\Options.ini');
  Port:=OptionsINI.ReadInteger('Options','Port',Port);
  Count:=OptionsINI.ReadInteger('Options','Count_of_users',Count);
  SetLength(ConnectedUsers,Count);
  for i:=0 to Count-1 do
    begin
      ConnectedUsers[i].Nickname:='';
      ConnectedUsers[i].clIP:='';
      ConnectedUsers[i].Used:=False;
    end;
  IdTCPServer1.DefaultPort:=Port;
  IdTCPServer1.Active := True;
  add:='[' + TimeToStr(Now)+'] ?????? ???????. IP: ' + GetLocalIP + ' ????: ' + IntToStr(Port);
  Addlog(add);
end;

procedure TTCP_Chat_Service.ServiceStop(Sender: TService; var Stopped: Boolean);
var add:string;
begin
  IdTCPServer1.Active:=false;
  add:='[' + TimeToStr(Now)+'] ?????? ??????????';
  Addlog(add);
end;

end.
