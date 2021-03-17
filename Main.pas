unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, LoggerInterface,
  ThreadManager, System.SyncObjs;

type
  TMainForm = class(TForm)
    Memo: TMemo;
  strict private
    procedure UpdateLogMessages(AMessages: TArray<String>);
    procedure WaitLogUpdates;
  private

    FCancellationEvent: TEvent;
    FLoggerI: ILogger;
    FThreadManager: TThreadManager;
    FWaitLogUpdatesThread: TThread;
    procedure CreateWaitLogUpdatesThread;
    procedure TerminateWaitLogUpdatesThread;
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  AppSettings, AppLogger;

{$R *.dfm}

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  try
    FLoggerI := TAppLoger.Logger;

    CreateWaitLogUpdatesThread;

    FThreadManager := TThreadManager.Create(FLoggerI,
      TAppSettings.Settings.MessageThread);
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Application.ShowMainForm := False;
      Application.Terminate;
    end;
  end;
end;

destructor TMainForm.Destroy;
begin
  TerminateWaitLogUpdatesThread;

  if FThreadManager <> nil then
    FreeAndNil(FThreadManager);

  FLoggerI := nil;

  inherited;
end;

procedure TMainForm.CreateWaitLogUpdatesThread;
begin
  // Событие, которого будет ждать поток
  FCancellationEvent := TEvent.Create;

  FWaitLogUpdatesThread := TThread.CreateAnonymousThread(
    procedure
    begin
      WaitLogUpdates;
    end);
  FWaitLogUpdatesThread.FreeOnTerminate := False;
  FWaitLogUpdatesThread.Start;
end;

procedure TMainForm.TerminateWaitLogUpdatesThread;
begin
  if FCancellationEvent <> nil then
  begin
    FCancellationEvent.SetEvent;
    FWaitLogUpdatesThread.WaitFor;
    FreeAndNil(FWaitLogUpdatesThread);
    FreeAndNil(FCancellationEvent);
  end;
end;

procedure TMainForm.UpdateLogMessages(AMessages: TArray<String>);
var
  s: string;
begin
  Memo.Lines.BeginUpdate;
  try
    Memo.Clear;
    for s in AMessages do
    begin
      Memo.Lines.Add(s.Trim([#13, #10]));
    end;
  finally
    Memo.Lines.EndUpdate;
  end;
end;

procedure TMainForm.WaitLogUpdates;
var
  ASignaledObject: THandleObject;
  AWaitResult: TWaitResult;
  ALastMessages: TArray<String>;
begin
  while True do
  begin
    AWaitResult := TEvent.WaitForMultiple
      ([FCancellationEvent, FLoggerI.AddMessageEvent], 1000, False, ASignaledObject);

    // Если дождались
    if AWaitResult <> wrTimeout then
    begin
      if ASignaledObject = FLoggerI.AddMessageEvent then
      begin
        ALastMessages := FLoggerI.GetLastMessages;
        TThread.Synchronize(TThread.CurrentThread,
          procedure
          begin
            UpdateLogMessages(ALastMessages);
          end);
      end
      else
        // Если пора завершать
        if ASignaledObject = FCancellationEvent then
          break
    end;
  end;
end;

end.
