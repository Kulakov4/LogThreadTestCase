unit AppSettings;

interface

uses
  SettingsInterface;

type
  TAppSettings = class(TObject)
  private
  class var
    FSettings: ISettings;
    class function GetSettings: ISettings; static;
  public
    class property Settings: ISettings read GetSettings;
  end;

implementation

uses
  Settings, System.IOUtils;

class function TAppSettings.GetSettings: ISettings;
var
  ASettingsFileName: String;
begin
  if FSettings = nil then
  begin
    ASettingsFileName := TPath.ChangeExtension(ParamStr(0), '.xml');
    FSettings := TSettings.Create(ASettingsFileName);
  end;

  Result := FSettings;
end;

end.
