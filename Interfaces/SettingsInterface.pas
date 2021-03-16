unit SettingsInterface;

interface

type
  ILoggerSettings = interface(IInterface)
    function GetDataLifeTime: Cardinal;
    function GetFileName: string;
    function GetTruncateFileInterval: Cardinal;
    property DataLifeTime: Cardinal read GetDataLifeTime;
    property FileName: string read GetFileName;
    property TruncateFileInterval: Cardinal read GetTruncateFileInterval;
  end;

  IMessageThreadSettings = interface(IInterface)
    function GetIntervals: TArray<Cardinal>;
    property Intervals: TArray<Cardinal> read GetIntervals;
  end;

  ISettings = interface(IInterface)
    function GetLogger: ILoggerSettings;
    function GetMessageThread: IMessageThreadSettings;
    property Logger: ILoggerSettings read GetLogger;
    property MessageThread: IMessageThreadSettings read GetMessageThread;
  end;


implementation

end.
