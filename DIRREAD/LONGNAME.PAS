Unit LongName;
Interface
Type
        PBootSector = ^TBootSector;
        TBootSector = Record
                         Jump                   : Array [1..3] Of Byte;
                         OEM                    : Array [1..8] Of Char;
                         BytesPerSector         : Word;
                         SectorsPerCluster      : Byte;
                         ReservedSectors        : Word;
                         NumberOfFAT            : Byte;
                         RootDirectoryEnteries  : Word;
                         TotalSectors           : Word;
                         MediaDescription       : Byte;
                         SectorsPerFAT          : Word;
                         SectorsPerCylinder     : Word;
                         NumberOfHead           : Word;
                         NumberOfHidenSectors   : Word;
                         OtherData              : Array [1..482] Of Byte;
                       End;

        PLFN           = ^TLFN;
        TLFN           = Record
                           Name                 : Array[1..13] Of Char;
                           Ordinal              : Byte;
                           Last                 : Boolean;
                           Typ                  : Byte;
                           CheckSum             : Byte;
                           Linked               : Boolean;
                         End;

        PDirectoryItem = ^TDirectoryItem;
        TDirectoryItem = Record
                           Filename             : Array[1..8] Of Char;
                           Extension            : Array[1..3] Of Char;
                           Attrib               : Byte;
                           Reserved             : Array[1..10] Of Byte;
                           Time                 : Word;
                           Date                 : Word;
                           Cluster              : Word;
                           FileSize             : Longint;
                         End;

         PDSector = ^TDSector;
         TDSector = Array [1..16] Of TDirectoryItem;

         PDirectory = ^TDirectory;
         TDirectory = Record
                       Item                     : PDirectoryItem;
                       Next                     : PDirectory;
                       Previous                 : PDirectory;
                      End;

Procedure FreeMemory;
Procedure ReadDirectory(Dir:String);
Procedure ReadRootDirectory(Var D:Pdirectory);
Procedure LogToFyz(Log:Longint;Var Hlava,Stopa,Sektor:Byte;SektoCyl,NumHead:Word);
Function GetLFN(FileName:String):String;

Const
    Error       : Boolean=False;
    AktualDrive : Byte = 2;

    BootSector  : PBootSector = Nil;
    Directory   : PDirectory  = Nil;

Implementation
  Uses Dos, Crt, Reader, Base;
  Var  X   : Array[1..512] OF Char;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure LogToFyz;
Begin
  Hlava:=(Log div SekToCyl) mod NumHead;
  Stopa:=Log div (SekToCyl*NumHead);
  Sektor:=1+(Log mod SekToCyl);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure ConvertLogSec(LogSec:Integer;Var Hd,Tr,Se:Byte;Sec_Tr,NumbHeads:Word);
Begin
  Hd:=((LogSec-1) Div Sec_Tr) Mod NumbHeads;
  Tr:=LogSec div (Sec_Tr*NumbHeads);
  Tr:=Tr Div NumbHeads-Tr Mod NumbHeads;
  Se:=(LogSec -1) Mod Sec_Tr;
  Se:=Se+1;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function SeekNextCluster(Log:Longint;Cluster:Longint):Word;
Type
    PFat=^TFat;
    TFat=Array[1..256] Of Word;
Var Hlava,Stopa,Sektor:Byte;
    Fat:PFat;
    SektorInFat:Word;
    Xpos:Integer;
Begin
  New(Fat);
  SektorInFAt:=((Cluster*2) Div 512);
  XPos:=(((Cluster*2) Mod 512) Div 2);
  DosReadSector(Log+SektorInFAT,AktualDrive,Fat);
  SeekNextCluster:=Fat^[Xpos+1];
  Dispose(Fat);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function IsLFN(Item:PDirectoryItem):Boolean;
Begin
  IsLFN:=False;
  If (Item^.Cluster=$0) And (Item^.Attrib=$0F) Then IsLFN:=True;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure ItemToLFN(Item:PdirectoryItem;LFN:PLFN);
Type TData  = Array[1..32] Of Char;
     PData  = ^Tdata;
     TData2 = Array[1..32] Of Byte;
     PData2 = ^Tdata2;

Var Data    : PData;
    Data2   : Pdata2;
Begin
  FillChar(LFN^,SizeOF(LFN),#0);
  Data:=Addr(Item^);Data2:=Addr(Item^);
  If isLFN(Item) Then
    With LFN^ Do
      Begin
        Name[1]:=Data^[2];Name[2]:=Data^[4];Name[3]:=Data^[6];
        Name[4]:=Data^[8];Name[5]:=Data^[10];Name[6]:=Data^[15];
        Name[7]:=Data^[17];Name[8]:=Data^[19];Name[9]:=Data^[21];
        Name[10]:=Data^[23];Name[11]:=Data^[25];Name[12]:=Data^[29];Name[13]:=Data^[31];
        If (Ord(Data^[1]) And $40) = $40 Then Last:=True
          Else Last:=False;
        Ordinal:=Ord(Data^[1]) And $F;
        CheckSum:=Ord(Data^[14]);
        Data:=Nil;
      End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function GetName(Item:PDirectoryItem):String;
Var Name      : String[8];
    Extension : String[3];
    I         : Integer;
    P         : Byte;
Begin
  Name[0]:=#8;For I:=1 To 8 Do Name[I]:=Item^.FileName[I];
  P:=Pos(' ',Name);If P>0 Then Name[0]:=Chr(P-1);
  Extension[0]:=#3;For I:=1 To 3 Do Extension[I]:=Item^.Extension[I];
  P:=Pos(' ',Extension);If P>0 Then Extension[0]:=Chr(P-1);
  If Length(Extension)>0 Then Getname:=Name+'.'+Extension
    Else GetName:=Name;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function GetLFNName(LFN:PLFN):String;
Var S : String[13];
    I : Byte;
    P : Byte;
Begin
  S[0]:=#13;For I:=1 To 13 Do S[I]:=LFN^.Name[I];
  P:=Pos(#0,S);If P>0 Then S[0]:=Chr(P-1);
  GetLFNName:= S;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function GetLFN(FileName:String):String;
Var Search : PDirectory;
    Out    : Boolean;
    LFN    : PLFN;
    S      : String;
Begin
  Search:=Directory;
  If Search<>Nil Then Begin
  Out:=False;S:='';
  While (Not (Search^.Next=Nil)) Do Search:=Search^.Next;
  Repeat
   If UpString(GetName(Search^.Item))=UpString(FileName)
     Then Begin
            Search:=Search^.Previous;
            IF  IsLFN(Search^.Item) Then
               Repeat
                 ItemToLFN(Search^.Item,LFN);
                 S:=S+GetLFNName(LFN);
                 Search:=Search^.Previous;
               Until LFN^.Last;
            Out:=True;
          End;
    Search:=Search^.Previous;
    GetLFN:=S;
  Until (Search^.Previous=Nil) Or Out;
                End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure FreeDirectory(Var D:PDirectory); {Uvolni seznam adresaru}
Begin
 If D<>Nil Then Begin
                 While D^.Next<>Nil Do D:=D^.Next;
                 If D^.Previous<>Nil Then
                  While D^.Previous<>Nil Do Begin
                                             D:=D^.Previous;
                                             Dispose(D^.Next^.Item);
                                             Dispose(D^.Next);
                                            End;
                 If D^.Item<>Nil Then Dispose(D^.Item);
                 Dispose(D);D:=Nil;
                End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure FreeMemory;
Begin
If BootSector<>Nil Then Begin Dispose(BootSector);BootSector:=Nil;End;
If Directory<>Nil Then FreeDirectory(Directory);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure ReadRootDirectory(Var D:PDirectory);
Type TX  =  Array[1..512] Of Char;
     Txn =  Array[1..32] Of Char;
Const Out : Boolean=False;
Var LogRootNum,FatStart  : Word;
    Hlava,Stopa,Sektor   : Byte;
    DSector              : PDSector;
    I,C                  : Integer;
    Prev                 : PDirectory;
Begin
 Out := False;
 If BootSector = Nil Then New(BootSector);
 New(DSector);
 If D<>Nil Then FreeDirectory(D);New(D);
 D^.Next:=Nil;D^.Previous:=Nil;D^.Item:=Nil;
 DosReadSector(0,AktualDrive,BootSector);
 If Reader.Error Then Begin Dispose(DSector);FreeMemory;Error:=True;Exit; End;
 With BootSector^ Do Begin
 LogRootNum:=ReservedSectors+(NumberOfFAT*SectorsPerFAT);
 FatStart:=ReservedSectors;
 C:=0;
 Repeat
   DosReadSector(LogRootNum+C,AktualDrive,DSector);
   For I:=1 To 16 Do If (Dsector^[I].FileName[1]<>#0) And (Not Out) Then
                     Begin
                      New(D^.Item);
                      D^.Item^:=DSector^[I];
                      Prev:=D;
                      New(D^.Next);
                      D:=Directory^.Next;
                      D^.Previous:=Prev;
                      D^.Next:=Nil;
                     End
                   Else Out:=True;
 Inc(C);
 Until Out;
 D:=D^.Previous;
 Dispose(D^.Next);D^.Next:=Nil;
                     End;
 Dispose(DSector);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function SearchDirCluster(D:Pdirectory;DirName:String):Longint;
Var Search:PDirectory;
Begin
Search:=D;
If Search<> Nil Then
 Begin
  While Search^.Previous<>Nil Do Begin
                                  If (DirName=GetName(Search^.Item)) And
                                  ((Search^.Item^.Attrib And $10)=$10) Then
                                   SearchDirCluster:=Search^.Item^.Cluster;
                                  Search:=Search^.Previous;
                                 End;
 End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function ClusterToLog(C:Longint):Longint;
Var VS:Longint;
Begin
With BootSector^ Do Begin
VS:=ReservedSectors+(SectorsPerFat*NumberOfFAT) +
 + ((RootDirectoryEnteries*32) Div BytesPerSector);
ClusterToLog:=((C-2)*SectorsPerCluster) + VS
                   End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure GetDirectory(Var D:Pdirectory;C:Longint);
Var LogSector:Word;
Var LogDirNum:Longint;
    Hlava,Stopa,Sektor:Byte;
    DSector:PDSector;
    I,Count:Integer;
    Prev:PDirectory;
    Old:Longint;
    Out:Boolean;
Begin
 LogDirNum:=ClusterToLog(C);Error:=False;
 New(DSector);New(D);
 D^.Next:=Nil;D^.Previous:=Nil;
 With BootSector^ Do Begin
 Count:=0;Out:=False;
 Repeat
   DosReadSector(LogDirNum+Count,AktualDrive,DSector);

   For I:=1 To 16 Do If (Dsector^[I].FileName[1]<>#0) And (Not Out) Then
                     Begin
                      New(D^.Item);
                      D^.Item^:=DSector^[I];
                      Prev:=D;
                      New(D^.Next);
                      D:=D^.Next;
                      D^.Previous:=Prev;
                      D^.Next:=Nil;
                     End
                   Else Out:=True;
 Inc(Count);
 If Count=SectorsPerCluster Then Out:=True;
 Until Out;
 D:=D^.Previous;
 Dispose(D^.Next);D^.Next:=Nil;
                     End;
 Dispose(DSector);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure ReadDirectory(Dir:String); {Nacte Obsah adresare do seznamu}
Var DownDir        : String;
    I              : Byte;
    Cluster        : Longint;
    SubDirectory   : PDirectory;
    Search         : PDirectory;
    Ok             : Boolean;
    NewDrive       : Byte;
Begin
 Directory:=Nil;Dir:=UpString(Dir);
 If Directory<>Nil Then FreeDirectory(Directory);
 If Dir[2]=':' Then Begin
                      NewDrive:=Ord(UpCase(Dir[1]))-65;
                      If NewDrive<>AktualDrive Then AktualDrive := NewDrive;
                      Delete(Dir,1,2);
                    End;
 ReadRootDirectory(Directory);
 If Error Then Exit;
 If Dir[1]='\' Then Begin Delete(Dir,1,1);End;
 While Length(Dir)<>0 Do
  Begin
   I:=1;
   DownDir:='';
   While (Dir[I]<>'\') And (I<>Length(Dir)+1) Do Begin
                                                  DownDir:=DownDir+Dir[I];
                                                  Inc(I);
                                                 End;

   Cluster:=SearchDirCluster(Directory,DownDir);
   GetDirectory(SubDirectory,Cluster);
   Search:=SubDirectory;
   FreeDirectory(Directory);
   Directory:=SubDirectory;
   Delete(Dir,1,I);
  End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
End.