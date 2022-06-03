unit PopUpWin_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TForm3 = class(TForm)
    Timer1: TTimer;
    Timer2: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseLeave(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label1MouseEnter(Sender: TObject);
    procedure Label1MouseLeave(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure Label2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  i:integer = 0;
  AlphaShown:Byte;

implementation

uses Main_Unit;

{$R *.dfm}

procedure TForm3.FormClick(Sender: TObject);
begin
  Form3.Hide;
  Form1.FormStyle:=fsStayOnTop;
end;

procedure TForm3.FormHide(Sender: TObject);
begin
  Timer1.Enabled:=False;
  Timer2.Enabled:=False;
  Timer2.Interval:=1000;
  i:=0;
  Form3.AlphaBlendValue:=0;
  Form3.Top:=Screen.Height;
end;

procedure TForm3.FormMouseLeave(Sender: TObject);
begin
  Timer2.Enabled:=true;
  Form3.AlphaBlendValue:=AlphaShown;
end;

procedure TForm3.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Timer2.Enabled:=False;
  Form3.top:=Screen.Height-Form3.Height-50;
  Form3.AlphaBlendValue:=255;
  Timer2.Interval:=1;
end;

procedure TForm3.FormShow(Sender: TObject);
begin
  Form3.Top:=Screen.Height;
  Form3.left:=Screen.Width-Form3.Width;
  Timer1.Enabled:=true;
  Form3.FormStyle:=fsStayOnTop;
end;

procedure TForm3.Label1Click(Sender: TObject);
begin
  Form3.Hide;
end;

procedure TForm3.Label1MouseEnter(Sender: TObject);
begin
  Label1.Font.Style:=[fsBold];
end;

procedure TForm3.Label1MouseLeave(Sender: TObject);
begin
  Label1.Font.Style:=[];
end;

procedure TForm3.Label2Click(Sender: TObject);
begin
  Form3.Hide;
  Form1.Show;
  Form1.TrayIcon1.Visible:=False;
  Form1.FormStyle:=fsStayOnTop;
end;

procedure TForm3.Label2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Timer2.Enabled:=False;
  Form3.top:=Screen.Height-Form3.Height-50;
  Form3.AlphaBlendValue:=255;
  Timer2.Interval:=1;
end;

procedure TForm3.Timer1Timer(Sender: TObject);
begin
  Form3.top:=top-20;
  Form3.AlphaBlendValue:=Form3.AlphaBlendValue+20;
  if Form3.top <= Screen.Height-Form3.Height-50 then
    Begin
      timer1.Enabled:=false;
      timer2.Enabled:=true;
      AlphaShown:=Form3.AlphaBlendValue;
    End;

end;

procedure TForm3.Timer2Timer(Sender: TObject);
begin
  Inc(i);
  if i = 6 then
    begin
      Timer2.Interval:=1;
    end;
  if Timer2.Interval = 1 then
    Form3.AlphaBlendValue:=Form3.AlphaBlendValue-1;
  if Form3.AlphaBlendValue = 100 then
    begin
      i:=7;
      Timer2.Interval:=2;
    end;
  if i = 7 then
    begin
      Form3.Top:=Form3.Top+1;
    end;
  if Form3.top>=Screen.Height then
    begin
      Timer2.Enabled:=false;
      Timer2.Interval:=1000;
      i:=0;
      Form3.Hide;
    end;
end;

end.
