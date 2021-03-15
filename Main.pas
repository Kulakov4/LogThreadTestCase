unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, LoggerInterface,
  ThreadManager, System.SyncObjs;

type
  TMainForm = class(TForm)
    Button1: TButton;
    Memo: TMemo;
    procedure Button1Click(Sender: TObject);
  strict private
    procedure UpdateLogMessages(AMessages: TArray<String>);
    procedure WaitLogUpdates;
  private
    FEvent: TEvent;
    FCancellationEvent: TEvent;
    FLoggerI: ILogger;
    FThreadManager: TThreadManager;
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
  Logger, AppSettings;

{$R *.dfm}

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;

  // Автосбрасываемое событие
  FEvent := TEvent.Create(nil, False, False, '');

  FLoggerI := TLogger.Create(TAppSettings.Settings.LoggerFileName, FEvent);

  FCancellationEvent := TEvent.Create;

  TThread.CreateAnonymousThread(
    procedure
    begin
      WaitLogUpdates;
    end).Start;
end;

destructor TMainForm.Destroy;
begin
  FCancellationEvent.SetEvent;
  if FThreadManager <> nil then
    FreeAndNil(FThreadManager);

  inherited;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  FThreadManager := TThreadManager.Create(FLoggerI,
    TAppSettings.Settings.ThreadPeriods);
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
    AWaitResult := TEvent.WaitForMultiple([FCancellationEvent, FEvent], 1000,
      False, ASignaledObject);

    // Если дождались
    if AWaitResult <> wrTimeout then
    begin
      if ASignaledObject = FEvent then
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
