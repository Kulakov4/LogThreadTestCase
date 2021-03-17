unit Logger;

interface

uses
  LoggerInterface, System.SyncObjs, System.Classes, SettingsInterface,
  System.Generics.Collections;

type
  TLogger = class(TComponent, ILogger)
  strict private
    procedure Add(AMessage: string; AMessageStatus: TMessageStatus);
    function GetAddMessageEvent: TEvent;
    procedure TruncateLog;
    procedure WaitLogTruncateTime;
  private
    FCancellationEvent: TEvent;
    FCS: TCriticalSection;
    FAddMessageEvent: TEvent;
    FDataLifeTime: Cardinal;
    FFileName: string;
    FMessageStatus: TDictionary<TMessageStatus, String>;
    FStringList: TStrings;
    FTruncateFileInterval: Cardinal;
    FTruncateThread: TThread;
    procedure CreateTruncateLogThread;
    procedure TerminateTruncateLogThread;
  public
    constructor Create(AOwner: TComponent;
      const ALoggerSettingsI: ILoggerSettings); reintroduce;
    destructor Destroy; override;
    function GetLastMessages: TArray<String>;
  end;

implementation

uses
  System.IOUtils, System.SysUtils, Winapi.Windows, System.DateUtils;

constructor TLogger.Create(AOwner: TComponent;
  const ALoggerSettingsI: ILoggerSettings);
begin
  if not Assigned(ALoggerSettingsI) then
    raise Exception.Create('Logger settings interface is not assigned');

  inherited Create(AOwner);

  FMessageStatus := TDictionary<TMessageStatus, String>.Create;
  FMessageStatus.Add(msCritical, 'Critical');
  FMessageStatus.Add(msWarning, 'Warning');
  FMessageStatus.Add(msInfo, 'Info');

  FCS := TCriticalSection.Create;
  FStringList := TStringList.Create;

  // Запоминаем свои настройки
  FFileName := ALoggerSettingsI.FileName;
  FDataLifeTime := ALoggerSettingsI.DataLifeTime;
  FTruncateFileInterval := ALoggerSettingsI.TruncateFileInterval;

  TFile.WriteAllText(ALoggerSettingsI.FileName, '');

  // Автосбрасываемое событие
  // Логгер будет устанавливать это событие после добавления сообщения
  FAddMessageEvent := TEvent.Create(nil, False, False, '');

  // Запускаем поток, который будет обрезать файл
  CreateTruncateLogThread;
end;

destructor TLogger.Destroy;
begin
  TerminateTruncateLogThread;

  if FCS <> nil then
    FreeAndNil(FCS);

  if FStringList <> nil then
    FreeAndNil(FStringList);

  if FMessageStatus <> nil then
    FreeAndNil(FMessageStatus);

  if FAddMessageEvent <> nil then
    FreeAndNil(FAddMessageEvent);

  inherited;
end;

procedure TLogger.Add(AMessage: string; AMessageStatus: TMessageStatus);
var
  AStatus: String;
  AText: string;
  ATreadID: Cardinal;
begin
  if not FMessageStatus.TryGetValue(AMessageStatus, AStatus) then
    raise Exception.Create('Undefined message status');

  ATreadID := GetCurrentThreadId;
  AText := Format('%s %s %s %s%s', [AMessage.PadRight(30), AStatus.PadRight(9),
    ATreadID.ToString.PadRight(10), DateTimeToStr(Now), sLineBreak]);

  FCS.Enter;
  try
    TFile.AppendAllText(FFileName, AText);

    FStringList.Append(AText);
    if FStringList.Count > 10 then
      FStringList.Delete(0);

    FAddMessageEvent.SetEvent;
  finally
    FCS.Leave;
  end;
end;

procedure TLogger.CreateTruncateLogThread;
begin
  // Событие, которого будет ждать поток
  FCancellationEvent := TEvent.Create();
  FCancellationEvent.ResetEvent;

  FTruncateThread := TThread.CreateAnonymousThread(
    procedure
    begin
      WaitLogTruncateTime;
    end);

  FTruncateThread.FreeOnTerminate := False;
  FTruncateThread.Start;
end;

function TLogger.GetAddMessageEvent: TEvent;
begin
  Result := FAddMessageEvent;
end;

function TLogger.GetLastMessages: TArray<String>;
begin
  FCS.Enter;
  try
    Result := FStringList.ToStringArray;
  finally
    FCS.Leave;
  end;
end;

procedure TLogger.WaitLogTruncateTime;
var
  AWaitResult: TWaitResult;
begin
  while True do
  begin
    // Ждём события завершения
    AWaitResult := FCancellationEvent.WaitFor(FTruncateFileInterval);

    // Если события завершения не дождались
    if AWaitResult = wrTimeout then
    begin
      TruncateLog;
    end
    else
      break;
  end;
end;

procedure TLogger.TerminateTruncateLogThread;
begin
  if FCancellationEvent <> nil then
  begin
    FCancellationEvent.SetEvent;
    FTruncateThread.WaitFor; // Ждём завершения потока
    FreeAndNil(FTruncateThread);
    FreeAndNil(FCancellationEvent);
  end;
end;

procedure TLogger.TruncateLog;
var
  ADateTime: TDateTime;
  ADateTimeStr: string;
  ALine: string;
  AMinDateTime: TDateTime;
  ANowStr: string;
  AStreamReader: TStreamReader;
  AFoundOldRecord: Boolean;
  ANewFileContents: string;
begin
  try
    ANewFileContents := '';
    AMinDateTime := IncMinute(Now, -1 * FDataLifeTime);
    ANowStr := DateTimeToStr(AMinDateTime);

    FCS.Enter;
    try
      AStreamReader := TFile.OpenText(FFileName);
      try
        AFoundOldRecord := False;
        while not AStreamReader.EndOfStream do
        begin
          ALine := AStreamReader.ReadLine;
          ADateTimeStr := ALine.Substring(ALine.Length - ANowStr.Length);
          ADateTime := StrToDateTime(ADateTimeStr);
          // если запись в логе старая
          if ADateTime < AMinDateTime then
          begin
            AFoundOldRecord := True;
            continue;
          end
          else
          begin
            if not AFoundOldRecord then
              break; // Похоже все записи в логе свежие

            ANewFileContents := ALine + sLineBreak + AStreamReader.ReadToEnd;
          end;
        end;

      finally
        AStreamReader.Close;
      end;
      // Если лог нужно перезаписать
      if ANewFileContents <> '' then
        TFile.WriteAllText(FFileName, ANewFileContents);
    finally
      FCS.Release;
    end;
  except
    ; // Не получилось обновить файл. Может быть получится в следующий раз.
  end;
end;

end.
