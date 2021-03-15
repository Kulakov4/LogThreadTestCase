unit Settings;

interface

uses
  Xml.XMLIniFile, Xml.XMLIntf, SettingsInterface;

type
  TSettings = class(TInterfacedObject, ISettings)
  strict private
    function GetLoggerFileName: String; stdcall;
    function GetThreadPeriods: TArray<Integer>;
  private
    FLoggerFileName: string;
    FPeriods: TArray<Integer>;
  public
    constructor Create(const AFileName: string);
  end;

implementation

uses
  System.IOUtils, Xml.XMLDoc, System.IniFiles, System.SysUtils,
  System.Generics.Collections;

constructor TSettings.Create(const AFileName: string);
var
  ADocument: IXMLDocument;
  ALoggerFileNameNode: IXMLNode;
  AThreadListNode: IXMLNode;
  APeriodNode: IXMLNode;
  APeriods: TList<Integer>;
  ARootNode: IXMLNode;
  i: Integer;
begin
  if not TFile.Exists(AFileName) then
    raise Exception.CreateFmt('File %s is not exists', [AFileName]);
  ADocument := LoadXMLDocument(AFileName);
  ADocument.Active := True;
  ARootNode := ADocument.DocumentElement;
  if ARootNode.ChildNodes.Count <> 2 then
    raise Exception.Create('XML structure is invalid');

  ALoggerFileNameNode := ARootNode.ChildNodes[0];
  FLoggerFileName := ALoggerFileNameNode.Text;

  AThreadListNode := ARootNode.ChildNodes[1];
  if AThreadListNode.ChildNodes.Count = 0 then
    raise Exception.Create('Period node is not found');

  APeriods := TList<Integer>.Create();
  try

    for i := 0 to AThreadListNode.ChildNodes.Count - 1 do
    begin
      APeriodNode := AThreadListNode.ChildNodes[i];
      APeriods.Add(StrToInt(APeriodNode.Text));
    end;
    FPeriods := APeriods.ToArray;
  finally
    FreeAndNil(APeriods);
  end;
end;

function TSettings.GetLoggerFileName: String;
begin
  Result := FLoggerFileName;
end;

function TSettings.GetThreadPeriods: TArray<Integer>;
begin
  Result := FPeriods;
end;

end.
