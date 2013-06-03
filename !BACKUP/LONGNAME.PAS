Unit Longname;
Interface
Uses Objects;
Type
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
        PDirectoryRec = ^TDirectoryRec;
        TDirectoryRec = Record
                           Filename             : Array[1..8] Of Char;
                           Extension            : Array[1..3] Of Char;
                           Attrib               : Byte;
                           Reserved             : Array[1..10] Of Byte;
                           Time                 : Word;
                           Date                 : Word;
                           Cluster              : Word;
                           FileSize             : Longint;
                         End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
         PDSector = ^TDSector;
         TDSector = Array [1..16] Of TDirectoryRec;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
  PDiskInfo = ^TDiskInfo;
  TDiskInfo = Record
                   Drive              : Byte;
                   Reserved           : Byte;
                   SectorSize         : Word;
                   SectorPerCluster   : Byte;
                   ClusterPerSector   : Byte;
                   ReservedSectors    : Word;
                   NumberOfFAT        : Byte;
                   MaxRootDirEnteries : Word;
                   FirstDataSector    : Word;
                   MaxClusters        : Word;
                   FatSize            : Word;
                   RootSector         : Word;
                   Driver             : Pointer;
                   MediaDescriptor    : Byte;
                   AcessFlag          : Byte;
                   NextDiskInfo       : Pointer;
                 End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
   PDirectory = ^TDirectory;
   TDirectory = Object (TCollection)
                 procedure FreeItem(Item: Pointer); virtual;
                End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
 PLongNames = ^TLongNames;
 TLongNames = Object
               Drive         : Byte;
               { Informace o disku }
               FatStart          : Word;
               FatType           : Byte;
               FatSize           : Word;
               NumberOfFat       : Byte;
               SectorSize        : Word;
               Sectors           : Longint;
               SectorsPerCluster : Word;
               Clusters          : Longint;
               LogRootNum        : Word;
               RootEnteries      : Word;
               {-------------------}
               RootDirectory     : PDirectory;
               Constructor Init;
               Procedure ReadRootDirectory(Drv :Byte);
               Procedure ReadDirectory(Dir : String;Reread :Boolean);
               Function GetLongName(Name : String):String;
               Destructor Done;
              End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Implementation
Uses Dos, Reader;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Constructor TLongNames.Init;
Begin
  RootDirectory := Nil;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Destructor TLongNames.Done;
Begin
 If RootDirectory<>Nil Then Dispose(RootDirectory,Done);
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure TDirectory.FreeItem;
Begin
 Dispose(PDirectoryRec(Item));
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TLongNames.ReadDirectory;
Var NewDrive   : Byte;
    Drv        : Byte;
    DiskInfo   : PDiskInfo;
    BootSector : TBootSector;
    Reg        : Registers;
    Swap       : Real;
Begin
 If Dir[2]<>':' Then Exit;                            {Neni specifikovan disk}
 NewDrive := Ord(Dir[1]) - Ord('A');                          { Nacitany Disk}
 Drv := Drive; Drive :=$FF;
 { Nacteni zakladnich parametru o disku }
 If (Reread) or (Drv<>NewDrive) Then
   Begin
     FillChar(BootSector,SizeOf(BootSector),0);
     DosReadSector(0,NewDrive,@BootSector);
     If Reader.Error  Then Exit;                {Nelze nacist pozadovany disk}
     Reg.Ah := $32;
     Reg.Dl := NewDrive+1;
     Msdos(Reg);
     If Reg.Al <> 0 Then Exit;       {Pro tento disk nelze zobrazit dl. jmena}
     DiskInfo       := Ptr(Reg.Ds,Reg.Bx);
     FatSize        := BootSector.SectorsPerFat;
     NumberOfFat    := BootSector.NumberOfFat;
     SectorSize     := BootSector.BytesPerSector;
     Clusters       := DiskInfo^.MaxClusters;
     If BootSector.ExtendetSignature<>0 Then
      Sectors       := BootSector.BigTotalNumberOfSectors
       Else Sectors := BootSector.TotalSectors;
     FatStart       := BootSector.ReservedSectors;
     LogRootNum     := BootSector.ReservedSectors+(NumberOfFAT*FATSize);
     SectorsPerCluster := BootSector.SectorsPerCluster;
     Clusters       := (Sectors - LogRootNum )  div SectorsPerCluster ;
     If Clusters<$FFFF Then
     RootEnteries   := BootSector.RootDirectoryEnteries;
     Clusters       := DiskInfo^.MaxClusters;
     Swap := ((Longint(FatSize)*Longint(SectorSize))) / Clusters;
     If (Swap>=1.5) Then FatType:=12;            {Zjistovani typu FAT tabulky}
     If (Swap>=2.0) Then FatType:=16;
     If (Swap>=4.0) Then FatType:=32;
     If (Clusters<=4086) And (FatType>12) Then FatType := 12;
     If (Clusters>4086) And (FatType<12) Then FatType := 16;
     ReadRootDirectory(NewDrive);
   End;
 Drive := NewDrive;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TLongNames.ReadRootDirectory;
Const Out : Boolean=False;
Var
    DSector              : TDSector;
    I,C                  : Integer;
    Item                 : PDirectoryRec;
    NumSec               : Byte;
Begin
 If RootDirectory = Nil Then RootDirectory := New(PDirectory,Init(0,1));
 C:=0;Out := False;NumSec := ((RootEnteries * 32) div SectorSize);
 Repeat
   DosReadSector(LogRootNum+C,Drv,@DSector);
   For I:=1 To 16 Do If (Dsector[I].FileName[1]<>#0) And (Not Out) Then
                     Begin
                      New(Item);
                      Item^:=DSector[I];
                      RootDirectory^.Insert(Item);
                     End
                   Else Out:=True;
 Inc(C);
 Until (Out) Or (C=NumSec-1);
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function TLongNames.GetLongName;
Begin
 GetLongName := 'Pouze testovanici verze';
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
End.