unit ThreadManager;

interface

uses
  System.Generics.Collections, System.Classes, LoggerInterface, System.SyncObjs;

type
  TThreadManager = class(TObject)
  private
    FCancellationEvent: TEvent;
    FLoggerI: ILogger;
    FMyThreadList: TList<TThread>;
    function CreateNewThread(APeriod: Integer): TThread;
  public
    constructor Create(ALoggerI: ILogger; APeriodArr: TArray<Integer>);
    destructor Destroy; override;
  end;

implementation

uses
  LoggerThread;

constructor TThreadManager.Create(ALoggerI: ILogger; APeriodArr:
    TArray<Integer>);
var
  APeriod: Integer;
begin
  FLoggerI := ALoggerI;

  FCancellationEvent := TEvent.Create();
  FCancellationEvent.ResetEvent;

  FMyThreadList := TList<TThread>.Create;
  for APeriod in APeriodArr do
    FMyThreadList.Add( CreateNewThread(APeriod) );

end;

destructor TThreadManager.Destroy;
var
  AThread: TThread;
begin
  // устанавливаем событие, которо ждут все потоки
  FCancellationEvent.SetEvent;
  for AThread in FMyThreadList  do
  begin
    AThread.WaitFor;    // ждём, когда поток завершится
    AThread.Free;
  end;

  inherited;
end;

function TThreadManager.CreateNewThread(APeriod: Integer): TThread;
begin
  Result := TLoggerThread.Create(FLoggerI, FCancellationEvent, APeriod)
end;

end.
