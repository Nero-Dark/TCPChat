unit Main_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, TCP_Thread, Vcl.Menus, Vcl.StdCtrls, Connect_Win_Unit,IdGlobal,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    MainMenu1: TMainMenu;
    Main1: TMenuItem;
    Connect1: TMenuItem;
    Disconnect1: TMenuItem;
    N1: TMenuItem;
    exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    ListBox1: TListBox;
    RichEdit1: TRichEdit;
    TrayIcon1: TTrayIcon;
    Image1: TImage;
    Label1: TLabel;
    StatusBar1: TStatusBar;
    PopupMenu1: TPopupMenu;
    Show1: TMenuItem;
    N2: TMenuItem;
    exit2: TMenuItem;
    Dontdisturb1: TMenuItem;
    ComboBox1: TComboBox;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Connect1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure exit1Click(Sender: TObject);
    procedure Disconnect1Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Show1Click(Sender: TObject);
    procedure exit2Click(Sender: TObject);
    procedure Dontdisturb1Click(Sender: TObject);
    procedure ResetThread;
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  TCP_Thread: TTCP_Thread;
  Nickname, SMessage, Room:string;
  dnDist:boolean;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var i:integer;
    sepS,sepE:char;
begin
  if not TCP_Thread.TCPClient.Connected then
    begin
      ShowMessage('Connect first');
      Exit;
    end;

  TCP_Thread.Suspend;
  sepS:='(';
  sepE:=')';
  delete(SMessage,pos(sepS,SMessage)-1,pos(SepE,SMessage)-pos(sepS,SMessage)+2);
          delete(SMessage,1,3);
          SMessage:= '[Private message to ' + SMessage + ' [' +TimeToStr(Now) + ']';

  RichEdit1.Lines.Add('[' + Nickname + ']: ' + Edit1.Text + ' [' + TimeToStr(Now) + ']');
  if ComboBox1.Enabled then
    SMessage:='[' + Nickname + ']: ' +  '{' + ComboBox1.Text + '}' + Edit1.Text
  else
    SMessage:='[' + Nickname + ']: ' + Edit1.Text;
  ComboBox1.Enabled:=true;
  Edit1.Text:='';
  TCP_Thread.TCPClient.IOHandler.Writeln(SMessage, IndyTextEncoding_UTF8);
  TCP_Thread.Resume;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to ComboBox1.Items.Count-1 do
    if ComboBox1.Items[i]=ComboBox1.Text then
      begin
        room:=ComboBox1.Text;
        TCP_Thread.Suspend;
        TCP_Thread.TCPClient.IOHandler.Writeln('$R' + room);
        TCP_Thread.Resume;
      end;
end;

procedure TForm1.Connect1Click(Sender: TObject);
begin
  Form1.Enabled:=false;
  TCP_Thread.Resume;
  Connect_Win_Unit.Form2.Show;
end;

procedure TForm1.Disconnect1Click(Sender: TObject);
begin
  Form1.StatusBar1.Panels[0].Text:='Disconnected';
  Form1.StatusBar1.Panels[1].Text:='';
  Disconnect1.Enabled:=False;
  Connect1.Enabled:=True;
  TCP_Thread.TCPClient.Disconnect;
  Disconnect1.Enabled:=false;
  ComboBox1.Enabled:=False;
  RichEdit1.Text:='';
  ListBox1.Clear;
  ResetThread;
end;

procedure TForm1.Dontdisturb1Click(Sender: TObject);
begin
  if dnDist then
    begin
      dnDist:=false;
      PopupMenu1.Items[1].Checked:=false;
    end
  else
    begin
      dnDist:=true;
      PopupMenu1.Items[1].Checked:=true;
    end;
end;

procedure TForm1.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    Button1.Click;
end;

procedure TForm1.exit1Click(Sender: TObject);
begin
  if MessageDlg('Are you sure?',mtConfirmation,mbYesNo,0)=mrYes then
    Form1.Destroy;
end;

procedure TForm1.exit2Click(Sender: TObject);
begin
  if MessageDlg('Are you sure?',mtConfirmation,mbYesNo,0)=mrYes then
    Form1.Destroy;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action:=caNone;
  TrayIcon1.Visible:=True;
  TrayIcon1.ShowBalloonHint;
  Form1.Hide;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TCP_Thread:=TTCP_Thread.Create(True);
  TCP_Thread.Priority:=tpNormal;
  TCP_Thread.CreateTCP;

  Disconnect1.Enabled:=false;
  ComboBox1.Enabled:=False;
  Form1.StatusBar1.Panels[0].Text:='Disconnected';

  TrayIcon1.Icon:=Application.Icon;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if TCP_Thread.TCPClient.Connected then
    TCP_Thread.TCPClient.Disconnect;
  TCP_Thread.Terminate;
  Application.Terminate;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  if WindowState = wsMinimized then
    begin
      Form1.Hide;
      TrayIcon1.Visible := True;
      TrayIcon1.ShowBalloonHint;
    end;
end;

procedure TForm1.ListBox1DblClick(Sender: TObject);
var i:integer;
begin
  for i:=0 to ListBox1.Items.Count-1 do
    if ListBox1.Selected[i] then
      begin
        ComboBox1.Enabled:=false;
        Edit1.Text:='(' + ListBox1.Items[i] + ') ' + Edit1.Text;
      end;
end;

procedure TForm1.ResetThread;
begin
  TCP_Thread.Terminate;
  TCP_Thread:=TTCP_Thread.Create(True);
  TCP_Thread.Priority:=tpNormal;
  TCP_Thread.CreateTCP;

  Disconnect1.Enabled:=false;
end;

procedure TForm1.Show1Click(Sender: TObject);
begin
  TrayIcon1.Visible := False;
  Form1.Show();
  WindowState := wsNormal;
  Application.BringToFront();
end;

procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
  TrayIcon1.Visible := False;
  Form1.Show();
  WindowState := wsNormal;
  Application.BringToFront();
end;

procedure TForm1.TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if button = mbRight then
    PopupMenu1.Popup(x,y);
end;

end.
