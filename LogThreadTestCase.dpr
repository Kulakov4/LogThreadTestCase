program LogThreadTestCase;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  LoggerInterface in 'Interfaces\LoggerInterface.pas',
  Logger in 'Services\Logger.pas',
  LoggerThread in 'Thread\LoggerThread.pas',
  ThreadManager in 'Thread\ThreadManager.pas',
  SettingsInterface in 'Interfaces\SettingsInterface.pas',
  AppSettings in 'AppSettings.pas',
  Settings in 'Services\Settings.pas',
  AppLogger in 'AppLogger.pas',
  Validator in 'Helpers\Validator.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
