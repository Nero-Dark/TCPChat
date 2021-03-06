unit TCP_Thread;

interface

uses
  System.Classes, SysUtils, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,IdGlobal;

type
  TTCP_Thread = class(TThread)
    TCPClient: TIdTCPClient;
    RMessage, SMessage, state: string;
  public
    procedure Connect(Host,Nickname:string; Port:Word);
    procedure CreateTCP;
    procedure UpdateMessages;
    procedure UpdateList;
  protected
    procedure Execute; override;
  end;

implementation

uses Main_Unit;

procedure TTCP_Thread.Connect(Host,Nickname:string; Port:Word);
begin
  TCPClient.Host:=Host;
  TCPClient.Port:=Port;
  TCPClient.Connect;
  TCPClient.IOHandler.WriteLn(NickName);
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
            if Copy(RMessage,0,2)='$M' then
              begin
                Synchronize(UpdateMessages);
              end;
            if Copy(RMessage,0,2)='$C' then
              Begin
                state:='Connected';
                Synchronize(UpdateList);
              End;
            if Copy(RMessage,0,2)='$D' then
              Begin
                state:='Disconnected';
                Synchronize(UpdateList);
              End;
        end;
      sleep(10);
    End;

end;

procedure TTCP_Thread.UpdateList;
var i: Integer;
begin
  if state = 'Connected' then
    Form1.ListBox1.Items.Add(Copy(RMessage,4,Length(RMessage)-1));
  if state = 'Disconnected' then
    begin

    end;
end;

procedure TTCP_Thread.UpdateMessages;
begin
  if Copy(RMessage,4,Length(RMessage)-2) <> Main_Unit.SMessage then
    begin
      Form1.Memo1.Lines.Add(Copy(RMessage,4,Length(RMessage)-2) + ' [' + TimeToStr(Now) + '] ');
    end;
end;

end.
