unit SettingsInterface;

interface

type
  ISettings = interface(IInterface)
    function GetLoggerFileName: String; stdcall;
    function GetThreadPeriods: TArray<Integer>;
    property LoggerFileName: String read GetLoggerFileName;
    property ThreadPeriods: TArray<Integer> read GetThreadPeriods;
  end;

implementation

end.
