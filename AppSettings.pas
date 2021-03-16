unit AppSettings;

interface

uses
  SettingsInterface;

type
  TAppSettings = class(TObject)
  private
    class function GetSettings: ISettings; static;
  public
    class property Settings: ISettings read GetSettings;
  end;

implementation

uses
  Settings, System.IOUtils, System.SysUtils;

var
  FSettings: TSettings = nil;

class function TAppSettings.GetSettings: ISettings;
var
  ASettingsFileName: String;
begin
  if FSettings = nil then
  begin
    ASettingsFileName := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)),
      'appsettings.json');
    FSettings := TSettings.Create(nil, ASettingsFileName);
  end;

  Result := FSettings;
end;

initialization

finalization
  if FSettings <> nil then
    FreeAndNil(FSettings);

end.
