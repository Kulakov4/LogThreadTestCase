unit LoggerInterface;

interface

type
  TMessageStatus = (msCritical, msWarning, msInfo);

  ILogger = interface (IInterface)
    procedure Add(AMessage: string; AMessageStatus: TMessageStatus);
    function GetLastMessages: TArray<String>;
  end;

implementation

end.
