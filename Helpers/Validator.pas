unit Validator;

interface

procedure ValidateFilename(const FileName: string);

implementation

uses
  System.IOUtils, System.SysUtils;

procedure ValidateFilename(const FileName: string);
var
  ADirectory: string;
begin
  if not TPath.HasValidPathChars(FileName, False) then
      raise Exception.CreateFmt('Invalid file path "%s"', [FileName]);

  if not TPath.HasValidFileNameChars(TPath.GetFileName(FileName), False) then
      raise Exception.CreateFmt('Invalid file name "%s"', [FileName]);

  ADirectory := TPath.GetDirectoryName(FileName);

  if (ADirectory <> '') and not TDirectory.Exists(ADirectory) then
    raise Exception.CreateFmt('Directory "%s" is not exist', [ADirectory]);
end;

end.
