Unit math;
interface

Procedure DecB(var b:byte;min:byte);
Procedure IncB(var b:byte;max:byte);
Function Min(a,b:longint):longint;
Function Max(a,b:longint):longint;

implementation

Procedure DecB(var b:byte;min:byte);
begin
  if b>min then Dec(b);
end;

Procedure IncB(var b:byte;max:byte);
begin
  if b<max then Inc(b);
end;

Function Min(a,b:longint):longint;
begin
 if a<b then min:=a else min:=b;
end;

Function Max(a,b:longint):longint;
begin
 if a>b then max:=a else max:=b;
end;
end.