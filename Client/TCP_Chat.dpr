program TCP_Chat;

uses
  Vcl.Forms,
  Main_Unit in 'Main_Unit.pas' {Form1},
  Connect_Win_Unit in 'Connect_Win_Unit.pas' {Form2},
  PopUpWin_Unit in 'PopUpWin_Unit.pas' {Form3},
  TCP_Thread in 'TCP_Thread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
