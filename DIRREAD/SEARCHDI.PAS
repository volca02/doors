Uses Reader,Crt,Dos,Base;
Type
        TDirectoryItem = Record
                          Filename      : Array[1..8] Of Char;
                          Extension     : Array[1..3] Of Char;
                          Attrib        : Byte;
                          Reserved      : Array[1..10] Of Byte;
                          Time          : Word;
                          Date          : Word;
                          Cluster       : Word;
                          FileSize      : Longint;
                         End;
         PDSector = ^TDSector;
         TDSector = Array [1..16] Of TDirectoryItem;

Var I,Z,Q:Longint;
    Buf : TDSector;
    IsDir:Boolean;
    Hlava,Stopa,Sector:Word;
    HlavaMax,StopaMax,SectorMax:Word;
    S,E:String;
    Pos :Real;
Begin
I:=0;
Write('Zadej pocet hlav :');Readln(HlavaMax);
Write('Zadej pocet stop :');Readln(StopaMax);
Write('Zadej pocet sektoru na stopu :');Readln(SectorMax);
For Stopa:=0 To StopaMax-1 Do
For Hlava:=0 To HlavaMax-1 Do
For Sector:=1 To SectorMax Do Begin
Write(#13,((Stopa / StopaMax)*100):0:2,'%');
ReadSector(@Buf,$80,Hlava,Stopa,Sector,1);
IsDir:=True;
For Z:=1 To 16 Do Begin
                   For Q:=1 To 6 Do If Buf[Z].Reserved[Q]<>0 Then IsDir:=False;
                     If Buf[Z].Cluster=0 Then IsDir:=False;
                  End;
If isDir
 Then
 Begin
 Writeln(#13#10,'Searched');
 Writeln('Press any key to write');Readkey;
  For Z:=1 To 16 Do  Begin
                      Q:=1;S:='';
                      While (Buf[Z].FileName[Q]<>#32) and (Q<=9) Do Begin S:=S+Buf[Z].FileNAme[Q];Inc(q);End;
                      Q:=1;E:='';
                      While (Buf[Z].Extension[Q]<>#32) and (Q<=4) Do Begin E:=E+Buf[Z].Extension[Q];Inc(q);End;
                      If E<>'' Then S:=S+'.'+E;
                      If (Buf[Z].Attrib and Directory)=Directory
                      Then S:=UpString(S) Else S:=DownString(S);

                      Writeln(S);
                     End;
  Writeln;
 IsDir:=False;
 End;

End;
End.