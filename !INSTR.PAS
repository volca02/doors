uses toasm;
const tfuj : array [1..5] of byte =($EA,00,00,00,00);
var
  s      : string;
  a      : byte;
begin
  Decode(@Tfuj, s, a);
  Writeln(s);
end.