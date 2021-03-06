unit Main_Unit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Ani,
  FMX.StdCtrls, FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation, TCP_Thread,
  FMX.Edit, FMX.ScrollBox, FMX.Memo, IdGlobal, ControlMover;

type
  TForm1 = class(TForm)
    MainPanel: TPanel;
    DetailsBtn: TSpeedButton;
    FloatAnimation1: TFloatAnimation;
    MenuPanel: TPanel;
    ConnectBtn: TSpeedButton;
    DisconnectBtn: TSpeedButton;
    Memo1: TMemo;
    Edit1: TEdit;
    Button1: TButton;
    ListBox1: TListBox;
    procedure DetailsBtnClick(Sender: TObject);
    procedure ConnectBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DisconnectBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  SMessage:string;
  TCP_Thread: TTCP_Thread;
  Nickname:string;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if TCP_Thread.TCPClient.Connected then
    begin
      TCP_Thread.Suspend;
      Memo1.Lines.Add('[' + Nickname + ']: ' + Edit1.Text + ' [' + TimeToStr(Now) + ']');
      SMessage:='[' + Nickname + ']: ' + Edit1.Text;
      Edit1.Text:='';
      TCP_Thread.TCPClient.IOHandler.Writeln(SMessage, IndyTextEncoding_UTF8);
      TCP_Thread.Resume;
    end
  else
    ShowMessage('Connect to server first');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TCP_Thread:=TTCP_Thread.Create;
  TCP_Thread.CreateTCP;
  Nickname:='NERO';
  ///////////////////////////////////////////////////////////////////////////////
  DetailsBtn.Position.Y:=10;
  DetailsBtn.Position.X:=10;
  DetailsBtn.Height:=20;
  DetailsBtn.Width:=20;

  Memo1.Position.Y:=DetailsBtn.Position.Y+DetailsBtn.Height+10;
  Memo1.Position.X:=10;
  Memo1.Height:=MainPanel.Height-(DetailsBtn.Position.Y+DetailsBtn.Height+10)-60;
  Memo1.Width:=MainPanel.Width-20;                                                                //MainPanel

  Edit1.Position.Y:=Memo1.Position.Y+Memo1.Height+10;
  Edit1.Position.X:=10;
  Edit1.Height:=40;
  Edit1.Width:= MainPanel.Width-70;

  Button1.Position.Y:=Memo1.Position.Y+Memo1.Height+10;
  Button1.Position.X:=Edit1.Width+10;
  Button1.Height:=40;
  Button1.Width:=50;
  ////////////////////////////////////////////////////////////////////////////////

  ConnectBtn.Position.Y:=10;
  ConnectBtn.Position.X:=10;
  ConnectBtn.Height:=20;
  ConnectBtn.Width:=70;

  DisconnectBtn.Position.Y:=ConnectBtn.Position.Y+ConnectBtn.Height+10;
  DisconnectBtn.Position.X:=10;                                                                  //MenuPanel
  DisconnectBtn.Height:=20;
  DisconnectBtn.Width:=70;

  ListBox1.Position.Y:=DisconnectBtn.Position.Y+DisconnectBtn.Height+10;
  ListBox1.Position.X:=10;
  ListBox1.Height:=MenuPanel.Height-(DisconnectBtn.Position.Y+DisconnectBtn.Height+10);
  ListBox1.Width:=Self.ClientWidth - 80;
end;

procedure TForm1.DetailsBtnClick(Sender: TObject);

begin
  if (MainPanel.Position.X=Self.ClientWidth - 60) then
    begin
      FloatAnimation1.StartValue:= Self.ClientWidth - 60;
      FloatAnimation1.StopValue:= 0;
    end
  else
    begin
      FloatAnimation1.StartValue:= 0;
      FloatAnimation1.StopValue:= Self.ClientWidth - 60;
    end;
  FloatAnimation1.Start;
end;

procedure TForm1.ConnectBtnClick(Sender: TObject);
begin
  try
    TCP_Thread.Connect('192.168.88.107',Nickname,2005);
  finally
    FloatAnimation1.StartValue:= Self.ClientWidth - 60;
    FloatAnimation1.StopValue:=0;
    FloatAnimation1.Start;
  end;
end;

procedure TForm1.DisconnectBtnClick(Sender: TObject);
begin
  TCP_Thread.TCPClient.Disconnect;
end;

end.
