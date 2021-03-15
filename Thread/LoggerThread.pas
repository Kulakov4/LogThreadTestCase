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
    FPeriod: Integer;
  class var
    FCount: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(ALoggerI: ILogger; ACancellationEvent: TEvent; APeriod:
        Integer);
  end;

implementation

uses
  System.SysUtils, StrHelper;

constructor TLoggerThread.Create(ALoggerI: ILogger; ACancellationEvent: TEvent;
    APeriod: Integer);
begin
  inherited Create;
  Inc(FCount);
  FID := FCount;
  if not Assigned(ALoggerI) then
    raise Exception.Create('Logger interface is not assigned');

  if APeriod < 0 then
    raise Exception.Create('Period is negative');

  FLoggerI := ALoggerI;
  FPeriod := APeriod;
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
    i := Random(Integer(AMessageStatusVar));
    AMessageStatus := TMessageStatus(i);

    FLoggerI.Add(AMessage, AMessageStatus);

    // ∆дЄм событи€ об отмене потока
    AWaitResult := FCancellationEvent.WaitFor(FPeriod);
    if AWaitResult <> wrTimeout then
    begin
      Terminate;
      break
    end;
  end;
end;

end.
