unit AppLogger;

interface

uses
  LoggerInterface;

type
  TAppLoger = class(TObject)
  private
    class function GetLogger: ILogger; static;
  public
    class property Logger: ILogger read GetLogger;
  end;

implementation

uses
  Logger, AppSettings, System.SysUtils;

var
  FLogger: TLogger = nil;

class function TAppLoger.GetLogger: ILogger;
begin
  if FLogger = nil then
    FLogger := TLogger.Create(nil, TAppSettings.Settings.Logger);

  Result := FLogger;
end;

initialization

finalization
  if FLogger <> nil then
    FreeAndNil(FLogger);

end.
