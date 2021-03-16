unit LoggerThread;

interface

uses
  System.Classes, LoggerInterface, System.SyncObjs;

type
  TLoggerThread = class(TThread)
  private
    FCancellationEvent: TEvent;
    FID: Integer;
    FLoggerI: ILogger;
    FInterval: Cardinal;
  class var
    FCount: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(ALoggerI: ILogger; ACancellationEvent: TEvent; AInterval:
        Cardinal);
  end;

implementation

uses
  System.SysUtils;

constructor TLoggerThread.Create(ALoggerI: ILogger; ACancellationEvent: TEvent;
    AInterval: Cardinal);
begin
  inherited Create;
  Inc(FCount);
  FID := FCount;
  if not Assigned(ALoggerI) then
    raise Exception.Create('Logger interface is not assigned');

  FLoggerI := ALoggerI;
  FInterval := AInterval;
  FCancellationEvent := ACancellationEvent;
  FreeOnTerminate := False;
end;

procedure TLoggerThread.Execute;
var
  AMessage: string;
  AMessageStatus: TMessageStatus;
  AMessageStatusVar: TMessageStatus;
  i: Integer;
  AMessageCount: Integer;
  AWaitResult: TWaitResult;
begin

  AMessageCount := 0;
  while not Terminated do
  begin
    Inc(AMessageCount);
    AMessage := Format('Message %d in thread %d', [AMessageCount, FID]);
    AMessageStatusVar := High(TMessageStatus);
    i := Random(Integer(AMessageStatusVar) + 1);
    AMessageStatus := TMessageStatus(i);

    FLoggerI.Add(AMessage, AMessageStatus);

    // ∆дЄм событи€ об отмене потока
    AWaitResult := FCancellationEvent.WaitFor(FInterval);
    if AWaitResult <> wrTimeout then
    begin
      Terminate;
      break
    end;
  end;
end;

end.
