program ImageConverter;

uses
  Vcl.Forms,
  UIMain in 'UIMain.pas' {MainForm};

{$R *.res}

begin
   ReportMemoryLeaksOnShutdown := True;
   Application.Initialize;
   Application.MainFormOnTaskbar := True;
   Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
