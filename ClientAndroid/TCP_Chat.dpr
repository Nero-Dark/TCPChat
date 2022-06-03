program TCP_Chat;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main_Unit in 'Main_Unit.pas' {Form1},
  TCP_Thread in 'TCP_Thread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
