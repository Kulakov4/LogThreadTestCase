unit Settings;

interface

uses
  SettingsInterface, System.Classes, System.SysUtils;

type
  TMessageThreadSettings = class(TComponent, IMessageThreadSettings)
  strict private
    function GetIntervals: TArray<Cardinal>;
  private
    FIntervals: TArray<Cardinal>;
  public
    property Intervals: TArray<Cardinal> read FIntervals write FIntervals;
  end;

  TLoggerSettings = class(TComponent, ILoggerSettings)
  strict private
    function GetDataLifeTime: Cardinal;
    function GetFileName: string;
    function GetTruncateFileInterval: Cardinal;
  private
    FDataLifeTime: Cardinal;
    FFileName: String;
    FTruncateFileInterval: Integer;
  public
    property DataLifeTime: Cardinal read FDataLifeTime write FDataLifeTime;
    property FileName: String read FFileName write FFileName;
    property TruncateFileInterval: Integer read FTruncateFileInterval
      write FTruncateFileInterval;
  end;

  TSettings = class(TComponent, ISettings)
  private
    FLogger: TLoggerSettings;
    FMessageThread: TMessageThreadSettings;
    function GetLogger: ILoggerSettings;
    function GetMessageThread: IMessageThreadSettings;
    procedure ParseJSON(const AJsonStr: string);
  public
    constructor Create(AOwner: TComponent; const AFileName: String);
      reintroduce;
  end;

  EJSONSettings = class(Exception)
  public
    constructor Create(const AField: String);
  end;

implementation

uses
  System.JSON, System.IOUtils, System.Generics.Collections,
  Validator;

constructor TSettings.Create(AOwner: TComponent; const AFileName: String);
var
  AData: string;
begin
  inherited Create(AOwner);
  FLogger := TLoggerSettings.Create(Self);
  FMessageThread := TMessageThreadSettings.Create(Self);

  try
    AData := TFile.ReadAllText(AFileName)
  except
    raise Exception.CreateFmt('Error reading configuration from file %s',
      [AFileName]);
  end;

  ParseJSON(AData);
end;

function TSettings.GetLogger: ILoggerSettings;
begin
  Result := FLogger;
end;

function TSettings.GetMessageThread: IMessageThreadSettings;
begin
  Result := FMessageThread;
end;

procedure TSettings.ParseJSON(const AJsonStr: string);
var
  ADataLifeTime: Cardinal;
  AFileName: String;
  AInterval: Cardinal;
  AIntervals: TList<Cardinal>;
  ATruncateFileInterval: Cardinal;
  I: Integer;
  JSON: TJSONObject;
  JSONArray: TJSONArray;
  JsonNestedObject: TJSONObject;
  JsonValue: TJSONValue;
begin
  try
    JSON := TJSONObject.ParseJSONValue(AJsonStr) as TJSONObject;
    if JSON = nil then
      raise EAbort.Create('');
    try
      if not JSON.TryGetValue<TJSONObject>('Logger', JsonNestedObject) then
        raise EJSONSettings.Create('Logger');

      if not JsonNestedObject.TryGetValue<String>('FileName', AFileName) then
        raise EJSONSettings.Create('FileName');

      ValidateFilename(AFileName);

      if not JsonNestedObject.TryGetValue<Cardinal>('DataLifeTimeMin',
        ADataLifeTime) then
        raise EJSONSettings.Create('DataLifeTimeMin');

      if not JsonNestedObject.TryGetValue<Cardinal>('TruncateFileInterval',
        ATruncateFileInterval) then
        raise EJSONSettings.Create('TruncateFileInterval');

      FLogger.FileName := AFileName;
      FLogger.DataLifeTime := ADataLifeTime;
      FLogger.TruncateFileInterval := ATruncateFileInterval;

      if not JSON.TryGetValue<TJSONObject>('MessageThread', JsonNestedObject)
      then
        raise EJSONSettings.Create('MessageThread');

      if not JsonNestedObject.TryGetValue<TJSONArray>('Intervals', JSONArray)
      then
        raise EJSONSettings.Create('Intervals');

      AIntervals := TList<Cardinal>.Create();
      try
        for I := 0 to JSONArray.Count - 1 do
        begin
          if not JSONArray.Items[I].TryGetValue<Cardinal>(AInterval) then
            raise Exception.Create('Interval value is incorrect');
          AIntervals.Add(AInterval);
        end;
        FMessageThread.Intervals := AIntervals.ToArray;
      finally
        FreeAndNil(AIntervals);
      end;
    finally
      FreeAndNil(JSON);
    end;
  except
    on E: Exception do
      raise Exception.Create('Error reading configuration.' + sLineBreak +
        E.Message);
  end;
end;

function TMessageThreadSettings.GetIntervals: TArray<Cardinal>;
begin
  Result := FIntervals;
end;

function TLoggerSettings.GetDataLifeTime: Cardinal;
begin
  Result := FDataLifeTime;
end;

function TLoggerSettings.GetFileName: string;
begin
  Result := FFileName;
end;

function TLoggerSettings.GetTruncateFileInterval: Cardinal;
begin
  Result := FTruncateFileInterval;
end;

constructor EJSONSettings.Create(const AField: String);
begin
  inherited CreateFmt('%s value is undefined or invalid', [AField]);
end;

end.
