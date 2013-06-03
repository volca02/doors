Uses Ems;
Type
    PData = ^Tdata;
    TData = Array[1..16*1024] Of Char;
Var
    Handle:Word;
    Data:PData;
    I:Word;
Begin
If Installed Then Writeln('Ovladac Je instalovan');
Writeln(GetStatus);
Writeln(MaxAvail*16);Writeln(Avail*16);
If Avail<4 Then Halt(0);
Handle:=OpenHandle(2);Writeln(Error);
SaveStatus(Handle);
Writeln(Error);
Map(Handle,0,0);
Data:=GetDataPointer;
Writeln(Error);
For I:=1 To 1000 Do Data^[I]:='A';
Map(Handle,0,1);
Writeln(Error);
For I:=1 To 1000 Do Data^[I]:='B';
Map(Handle,0,0);
Writeln(Error);
For I:=1 To 1000 Do Write(Data^[I]);
RestoreStatus(Handle);
Writeln(Error);
CloseHandle(Handle);
Writeln(Error);
End.