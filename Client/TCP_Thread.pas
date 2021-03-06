unit TCP_Thread;

interface

uses
  System.Classes, SysUtils, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,IdGlobal, Dialogs, System.StrUtils;

type
  TTCP_Thread = class(TThread)
    TCPClient: TIdTCPClient;
    RMessage, SMessage: string;
  public
    procedure Connect(Nickname, Pass, Host:string; Port:Word);
    procedure CreateTCP;
    procedure UpdateMessages;
    procedure UpdateList;
    procedure UpdateConnection;
    procedure UpdateLogin;
  protected
    procedure Execute; override;
  end;

implementation

uses Main_Unit,PopUpWin_Unit;

procedure TTCP_Thread.Connect(Nickname, Pass, Host:string; Port:Word);
begin
  TCPClient.Host:=Host;
  TCPClient.Port:=Port;
  TCPClient.Connect;
  TCPClient.IOHandler.WriteLn(NickName + #9 + Pass);
end;

procedure TTCP_Thread.CreateTCP;
begin
  TCPClient:=TIdTCPClient.Create();
end;

procedure TTCP_Thread.Execute;
begin
  NameThreadForDebugging('TCP_Thread');

  while not Terminated do
    Begin
      if TCPClient.Connected then
        begin
          RMessage:= TCPClient.IOHandler.ReadLn(IndyTextEncoding_UTF8);
          if RMessage <> '' then
            if (Copy(RMessage,0,2)='$M') or (Copy(RMessage,0,2)='$P') then
              begin
                Synchronize(UpdateMessages);
              end;
            if Copy(RMessage,0,2)='$L' then
              Begin
                Synchronize(UpdateList);
              End;
            if RMessage='$F' then
              begin
                Synchronize(UpdateConnection);
              end;
            if (RMessage='%N') or (RMessage='%P') then
              begin
                Synchronize(UpdateLogin);
              end;
        end;
      sleep(10);
    End;

end;

procedure TTCP_Thread.UpdateConnection;
begin
  ShowMessage('??? ????????? ???? ?? ???????');
  Form1.ResetThread;
end;

procedure TTCP_Thread.UpdateList;
var i: Integer;
    Nick:string;
    separator: char;
begin
  separator:=#9;
  Form1.ListBox1.Clear;
  delete(RMessage,1,3);
  i:=Length(RMessage);
  for i := 1 to Length(RMessage) do
    begin
      if RMessage[i]<>#9 then
        begin
          Nick:=Nick+RMessage[i];
          RMessage[i]:=#0;
        end
      else
        begin
          Form1.ListBox1.Items.Add(Nick);
          Nick:='';
        end;
    end;
end;

procedure TTCP_Thread.UpdateLogin;
begin
  if RMessage = '%N' then
    ShowMessage('No such User');
  if RMessage = '%P' then
    ShowMessage('Wrong password');
  Form1.ResetThread;
end;

procedure TTCP_Thread.UpdateMessages;
var fromUser:string;
    sepS,sepE: char;
begin
  if Copy(RMessage,0,2)='$P' then
    begin
      sepS:='(';
      sepE:=')';
      if ContainsText(RMessage,sepS) then
        begin
          fromUser:=Copy(RMessage,pos(sepS,RMessage)+1,pos(SepE,RMessage)-pos(sepS,RMessage)-1);
          delete(RMessage,pos(sepS,RMessage)-1,pos(SepE,RMessage)-pos(sepS,RMessage)+2);
          delete(RMessage,1,3);
          RMessage:= '[Private message from ' + RMessage + ' [' +TimeToStr(Now) + ']';
          Form1.RichEdit1.Lines.Add(RMessage);
          Form3.Label1.Caption:=RMessage;
        end;
    end;
  if Copy(RMessage,0,2)='$M' then
  begin
    sepS:='{';
    sepE:='}';
    if ContainsText(RMessage,sepS) then
      begin
        delete(RMessage,pos(sepS,RMessage),pos(SepE,RMessage)-pos(sepS,RMessage));
        RMessage:= RMessage + ' [' +TimeToStr(Now) + ']';
        Form1.RichEdit1.Lines.Add( RMessage + TimeToStr(Now));
        Form3.Label1.Caption:=RMessage;
      end;
      
    if (not Main_Unit.dnDist) and (Form1.TrayIcon1.Visible) then
      Form3.Show;
  end;
end;

end.
