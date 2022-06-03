unit Connect_Win_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, TCP_Thread, IniFiles,
  IdCoder, IdCoder3to4, IdCoderBinHex4, IdBaseComponent, IdCoder00E, IdCoderXXE;

type
  TForm2 = class(TForm)
    Edit1: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button1: TButton;
    Label2: TLabel;
    Edit2: TEdit;
    IdEncoderXXE1: TIdEncoderXXE;
    IdDecoderXXE1: TIdDecoderXXE;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Edit2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit4KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit3KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  OptionsINI:TIniFile;

implementation

{$R *.dfm}

uses Main_Unit;

procedure TForm2.Button1Click(Sender: TObject);
var Host,pass:String;
    Port:Word;
begin
  if (Edit1.Text='') or (Edit2.Text='') or
     (Edit3.Text='') or (Edit4.Text='') then
    ShowMessage('Enter all data')
  else
    begin
      Main_Unit.Nickname:=Edit1.Text;
      Pass:=IdEncoderXXE1.Encode(Edit2.Text);
      Host:=Edit3.Text;
      Port:=StrToInt(Edit4.Text);
      Main_Unit.TCP_Thread.Connect(Main_Unit.Nickname, Pass, Host, Port);
      Main_Unit.Form1.Enabled:=true;
      Form1.StatusBar1.Panels[0].Text:='Connected to ' + Host;
      Form1.StatusBar1.Panels[1].Text:='Nickname: '+Main_Unit.Nickname;
      OptionsINI.WriteString('Options','Nick',Edit1.Text);
      OptionsINI.WriteString('Options','Password',IdEncoderXXE1.Encode(Edit2.Text));
      OptionsINI.WriteString('Options','IP',Edit3.Text);
      OptionsINI.WriteString('Options','Port',Edit4.Text);
      Form1.Connect1.Enabled:=false;
      Form1.Disconnect1.Enabled:=True;
      Form2.Close;
      Form1.ComboBox1.Enabled:=true;
    end;
end;

procedure TForm2.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_RETURN then
    Button1.Click;
end;

procedure TForm2.Edit2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_RETURN then
    Button1.Click;
end;

procedure TForm2.Edit3KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_RETURN then
    Button1.Click;
end;

procedure TForm2.Edit4KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_RETURN then
    Button1.Click;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form1.Enabled:=True;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  OptionsIni := TiniFile.Create(extractfilepath(paramstr(0))+'Options.ini');
  Edit1.Text:= OptionsINI.ReadString('Options','Nick',Edit1.Text);
  Edit2.Text:= IdDecoderXXE1.DecodeString(OptionsINI.ReadString('Options','Password',Edit2.Text));
  Edit3.Text:= OptionsINI.ReadString('Options','IP',Edit3.Text);
  Edit4.Text:= OptionsINI.ReadString('Options','Port',Edit4.Text);
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  Top:=Form1.Top+round(Form1.Height/2)-round(Height/2);
  Left:=Form1.Left+round(Form1.Width/2)-round(Width/2);
end;

end.
