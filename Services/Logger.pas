unit Logger;

interface

uses
  LoggerInterface, System.SyncObjs, System.Classes;

type
  TLogger = class(TInterfacedObject, ILogger)
  strict private
    procedure Add(AMessage: string; AMessageStatus: TMessageStatus);
    procedure TruncateLog;
    procedure WaitLogTruncateTime;
  private
    FTruncatePeriod: Cardinal;
    FCancellationEvent: TEvent;
    FCS: TCriticalSection;
    FEvent: TEvent;
    FFileName: string;
    FStringList: TStrings;
    function MessageStatusToStr(AMessageStatus: TMessageStatus): String;
  public
    constructor Create(const AFileName: string; AEvent: TEvent);
    destructor Destroy; override;
    function GetLastMessages: TArray<String>;
  end;

implementation

uses
  System.IOUtils, System.SysUtils, Winapi.Windows, System.DateUtils;

constructor TLogger.Create(const AFileName: string; AEvent: TEvent);
begin
  if AFileName.IsEmpty then
    raise Exception.Create('Empty filename');

  FEvent := AEvent;

  FCS := TCriticalSection.Create;
  FStringList := TStringList.Create;

  FFileName := AFileName;

  TFile.WriteAllText(AFileName, '');

  FCancellationEvent := TEvent.Create();
  FCancellationEvent.ResetEvent;

  FTruncatePeriod := 5000;
  TThread.CreateAnonymousThread(
    procedure
    begin
      WaitLogTruncateTime;
    end).Start;
end;

destructor TLogger.Destroy;
begin
  if FCancellationEvent <> nil then
  begin
    FCancellationEvent.SetEvent;
    FreeAndNil(FCancellationEvent);
  end;

  if FCS <> nil then
    FreeAndNil(FCS);

  if FStringList <> nil then
    FreeAndNil(FStringList);

  inherited;
end;

procedure TLogger.Add(AMessage: string; AMessageStatus: TMessageStatus);
var
  AStatus: String;
  AText: string;
  ATreadID: Cardinal;
begin
  FCS.Enter;
  try
    ATreadID := GetCurrentThreadId;
    AStatus := MessageStatusToStr(AMessageStatus);
    AText := Format('%s %s %s %s%s', [AMessage.PadRight(30),
      AStatus.PadRight(9), ATreadID.ToString.PadRight(10), DateTimeToStr(Now),
      sLineBreak]);

    TFile.AppendAllText(FFileName, AText);

    FStringList.Append(AText);
    if FStringList.Count > 10 then
      FStringList.Delete(0);

    FEvent.SetEvent;
  finally
    FCS.Leave;
  end;
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
    AWaitResult := FCancellationEvent.WaitFor(FTruncatePeriod);

    // Если не дождались
    if AWaitResult = wrTimeout then
    begin
      TruncateLog;
    end
    else
      break;
  end;
end;

function TLogger.MessageStatusToStr(AMessageStatus: TMessageStatus): String;
begin
  Result := '';
  case AMessageStatus of
    msCritical:
      Result := 'Critical';
    msWarning:
      Result := 'Warning';
    msInfo:
      Result := 'Info';
  end;
  if Result = '' then
    raise Exception.Create('Undefined message status');
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
    AMinDateTime := IncMinute(Now, -1);
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
    ;
  end;
end;

end.
