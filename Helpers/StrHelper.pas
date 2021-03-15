unit StrHelper;

interface

function GenerateRandomWord(const Len: Integer=16; StartWithVowel: Boolean= FALSE): string;

implementation

function GenerateRandomWord(const Len: Integer=16; StartWithVowel: Boolean= FALSE): string;
CONST
   sVowels: string= 'AEIOUY';
   sConson: string= 'BCDFGHJKLMNPQRSTVWXZ';
VAR
   i: Integer;
   B: Boolean;
begin
  B:= StartWithVowel;
  SetLength(Result, Len);
  for i:= 1 to len DO
   begin
    if B
    then Result[i]:= sVowels[Random(Length(sVowels)) + 1]
    else Result[i]:= sConson[Random(Length(sConson)) + 1];
    B:= NOT B;
   end;
end;

end.
