unit ThreadManager;

interface

uses
  System.Generics.Collections, System.Classes, LoggerInterface,
  System.SyncObjs, SettingsInterface;

type
  TThreadManager = class(TObject)
  private
    FCancellationEvent: TEvent;
    FMyThreadList: TList<TThread>;
    function CreateNewThread(ALoggerI: ILogger; AInterval: Cardinal): TThread;
  public
    constructor Create(const ALoggerI: ILogger; const ASettingsI:
        IMessageThreadSettings);
    destructor Destroy; override;
  end;

implementation

uses
  LoggerThread, System.SysUtils;

constructor TThreadManager.Create(const ALoggerI: ILogger; const ASettingsI:
    IMessageThreadSettings);
var
  AInterval: Cardinal;
begin
  if not Assigned(ALoggerI) then
    raise Exception.Create('Logger interface is not assigned');


  FCancellationEvent := TEvent.Create();
  FCancellationEvent.ResetEvent;

  FMyThreadList := TList<TThread>.Create;
  for AInterval in ASettingsI.Intervals do
    FMyThreadList.Add( CreateNewThread(ALoggerI, AInterval) );

end;

destructor TThreadManager.Destroy;
var
  AThread: TThread;
begin
  // устанавливаем событие завершения, которого ждут все потоки
  FCancellationEvent.SetEvent;
  for AThread in FMyThreadList  do
  begin
    AThread.WaitFor;    // ждём, когда поток завершится
    AThread.Free;
  end;

  inherited;
end;

function TThreadManager.CreateNewThread(ALoggerI: ILogger; AInterval:
    Cardinal): TThread;
begin
  Result := TLoggerThread.Create(ALoggerI, FCancellationEvent, AInterval)
end;

end.
