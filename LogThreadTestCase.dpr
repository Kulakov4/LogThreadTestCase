program LogThreadTestCase;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  LoggerInterface in 'Interfaces\LoggerInterface.pas',
  Logger in 'Services\Logger.pas',
  LoggerThread in 'Thread\LoggerThread.pas',
  StrHelper in 'Helpers\StrHelper.pas',
  ThreadManager in 'Thread\ThreadManager.pas',
  Settings in 'Settings.pas',
  SettingsInterface in 'Interfaces\SettingsInterface.pas',
  AppSettings in 'AppSettings.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
