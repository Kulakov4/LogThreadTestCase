unit LoggerInterface;

interface

uses
  System.SyncObjs;

type
  TMessageStatus = (msCritical, msWarning, msInfo);

  ILogger = interface (IInterface)
    procedure Add(AMessage: string; AMessageStatus: TMessageStatus);
    function GetAddMessageEvent: TEvent;
    function GetLastMessages: TArray<String>;
    property AddMessageEvent: TEvent read GetAddMessageEvent;
  end;

implementation

end.
