program Project_tets03;

uses
  Forms,
  Unit_test03 in 'Unit_test03.pas' {Form1},
  usnap7 in 'usnap7.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
