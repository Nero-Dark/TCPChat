unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, System.StrUtils,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, System.ImageList,
  Vcl.ImgList, Vcl.StdCtrls, Vcl.ComCtrls, IdContext, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdTCPServer, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, WinSock, IdGlobal, Vcl.Grids, Data.DB, Data.Win.ADODB,
  IdCoder, IdCoder3to4, IdCoder00E, IdCoderXXE;

type
  TConnectedUsers = record
    Nickname: string;
    clIP: string;
    Used: boolean;
    room: string;
  end;

type
  TRooms = record
    RoomName: string;
    Users: array of TConnectedUsers;
    Used: boolean;
  end;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    ImageList1: TImageList;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    StaticText1: TStaticText;
    IdTCPServer1: TIdTCPServer;
    StatusBar1: TStatusBar;
    Memo1: TMemo;
    StringGrid1: TStringGrid;
    ADOConnection1: TADOConnection;
    ADOTable1: TADOTable;
    IdDecoderXXE1: TIdDecoderXXE;
    procedure FormCreate(Sender: TObject);
    procedure AddLog(var add: string);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure N5Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure IdTCPServer1Connect(AContext: TIdContext);
    procedure IdTCPServer1Disconnect(AContext: TIdContext);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  FileDir, port: string;
  logfile: textfile;
  ConnectedUsers: array of TConnectedUsers;
  ConUsLine: string;

implementation

{$R *.dfm}

function GetLocalIP: String;
const
  WSVer = $101;
var
  wsaData: TWSAData;
  P: PHostEnt;
  Buf: array [0 .. 127] of Char;
begin
  Result := '';
  if WSAStartup(WSVer, wsaData) = 0 then
  begin
    if GetHostName(@Buf, 128) = 0 then
    begin
      P := GetHostByName(@Buf);
      if P <> nil then
        Result := iNet_ntoa(PInAddr(P^.h_addr_list^)^);
    end;
    WSACleanup;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
  add: string;
begin
  IdTCPServer1.Active := false;
  add := '[' + TimeToStr(Now) + '] ????????? ??????? ';
  AddLog(add);
end;

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
begin
  FileDir := ExtractFilePath(Application.ExeName) + '\log\[' + DateToStr(Date)
    + '].txt';
  port := IntToStr(IdTCPServer1.DefaultPort);
  if not DirectoryExists(ExtractFilePath(Application.ExeName) + '\log\') then
    CreateDir('log');
  SetLength(ConnectedUsers,25);

  for i := 0 to Length(ConnectedUsers) - 1 do
    begin
      ConnectedUsers[i].clIP := '';
      ConnectedUsers[i].Nickname := '';
      ConnectedUsers[i].Used := False;
    end;
  StringGrid1.RowCount:=Length(ConnectedUsers);
  StringGrid1.ColWidths[0] := 70;
  StringGrid1.ColWidths[1] := 95;
  StringGrid1.Cells[0, 0] := '???????';
  StringGrid1.Cells[1, 0] := 'IP-?????';
  StringGrid1.Cells[2, 0] := '???????';

  N2.Click;
end;

procedure TForm1.IdTCPServer1Connect(AContext: TIdContext);
var
  IP, nick, add, pass, connectline: string;
  i, j, ConnectedCount: integer;
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
                  Memo1.Lines.add(add);
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

                  for i := 1 to StringGrid1.RowCount-1 do
                    begin
                      StringGrid1.Cells[0,i]:='';
                      StringGrid1.Cells[1,i]:='';
                    end;

                  for i := 0 to High(ConnectedUsers) do
                    begin
                      StringGrid1.Cells[0,i+1]:=ConnectedUsers[i].Nickname;
                      StringGrid1.Cells[1,i+1]:=ConnectedUsers[i].clIP;
                      StringGrid1.Cells[2,i+1]:=ConnectedUsers[i].room;
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

procedure TForm1.IdTCPServer1Disconnect(AContext: TIdContext);
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

  for i := 1 to StringGrid1.RowCount-1 do
    begin
      StringGrid1.Cells[0,i]:='';
      StringGrid1.Cells[1,i]:='';
      StringGrid1.Cells[2,i]:='';
    end;

  for i := 0 to High(ConnectedUsers) do
    begin
      StringGrid1.Cells[0,i+1]:=ConnectedUsers[i].Nickname;
      StringGrid1.Cells[1,i+1]:=ConnectedUsers[i].clIP;
      StringGrid1.Cells[2,i+1]:=ConnectedUsers[i].Room;
    end;

  add := '[' + TimeToStr(Now) + '] ?????? ????????: ' + nick + ' [' + IP + ']';
  AddLog(add);
  Memo1.Lines.add(add);

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

procedure TForm1.IdTCPServer1Execute(AContext: TIdContext);
var
  RMessage, add: string;
  i, j, m, n: integer;
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
                  Form1.AddLog(RMessage);
                  Form1.Memo1.Lines.Add(RMessage);
                end;
            end;
        finally
          IdTCPServer1.Contexts.UnlockList;
        end;
    end;

  sepS:='{';
  sepE:='}';
  if Copy(RMessage,pos(sepS,RMessage),1)= '{' then
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
      Form1.AddLog(RMessage);
      Form1.Memo1.Lines.Add(RMessage);
    end;


  if Copy(RMessage,1,2)= '$R' then
    Begin
      delete(RMessage,1,2);
      for I := 0 to High(ConnectedUsers) do
        if ConnectedUsers[i].clIP = AContext.Connection.Socket.Binding.PeerIP then
          ConnectedUsers[i].room:=RMessage;
      for i := 0 to High(ConnectedUsers) do
        begin
          StringGrid1.Cells[2,i+1]:=ConnectedUsers[i].Room;
        end;
    End
end;

procedure TForm1.N2Click(Sender: TObject);
var
  add: string;
begin
  N2.Enabled := false;
  N3.Enabled := True;
  IdTCPServer1.DefaultPort := 2005;
  IdTCPServer1.Active := True;
  add := '[' + TimeToStr(Now) + '] ?????? ???????. ';
  Memo1.Lines.add(add);
  AddLog(add);
  StatusBar1.Panels[0].Text := '???????';
  StatusBar1.Panels[1].Text := GetLocalIP + ':' +
    IntToStr(IdTCPServer1.DefaultPort);
  StatusBar1.Panels[2].Text := 'There are currently 0 client(s) connected';
end;

procedure TForm1.N3Click(Sender: TObject);
var
  add: string;
  i: integer;
begin
  N3.Enabled := false;
  N2.Enabled := True;
  IdTCPServer1.Active := false;
  add := '[' + TimeToStr(Now) + '] ????????? ??????? ';
  for i := 0 to StringGrid1.RowCount - 1 do
  begin
    StringGrid1.Cells[0, i] := '';
    StringGrid1.Cells[1, i] := '';
    StringGrid1.Cells[2, i] := '';
  end;
  Memo1.Lines.add(add);
  AddLog(add);
  StatusBar1.Panels[0].Text := '??????????';
  StatusBar1.Panels[1].Text := '';
  StatusBar1.Panels[2].Text := '';
end;

procedure TForm1.N5Click(Sender: TObject);
begin
  IdTCPServer1.Active := false;
  Close;
end;

procedure TForm1.AddLog(var add: string);
begin
  AssignFile(logfile, FileDir);
  if FileExists(FileDir) then
    Append(logfile)
  else
    Rewrite(logfile);
  Writeln(logfile, add);
  CloseFile(logfile);
end;

end.
