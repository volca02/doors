Uses LongName,Crt, Dos;
Const Path = 'C:\';
Var Old:Longint;
    DirInfo: SearchRec;
    S : String;

begin
  Old:=MemAvail;
  ReadDirectory(Path);
  FindFirst(Path+'*.*', Anyfile, DirInfo);
  while DosError = 0 do
  begin
    Write(DirInfo.Name);
    S:=GetLFN(DirInfo.Name);
    If S<>'' Then Write(' Long file name :',S);
    Writeln;
    FindNext(DirInfo);
  end;
  FreeMemory;
  Writeln(Old-MemAvail);
End.