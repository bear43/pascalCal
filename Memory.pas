Unit Memory;

function GetCardinalFromPointer(p: pointer): cardinal;
var
  ip: ^cardinal;
begin
  ip := p;
  Result := ip^;
end;

function GetWordFromPointer(p: pointer): WORD;
var
  ip: ^WORD;
begin
  ip := p;
  Result := ip^;
end;

procedure SetCardinalFromPointer(p: pointer; c : cardinal);
var
  ip: ^cardinal;
begin
  ip := p;
  ip^ := c;
end;

procedure SetWordFromPointer(p: pointer; w : WORD);
var
  ip: ^WORD;
begin
  ip := p;
  ip^ := w;
end;

begin
end.