Uses App, Dialogs, Objects, Views, Reader, Dos, MsgBox,Crt, Drivers;
Type
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
Type
   TFatMap   = Array [1..17,1..75] Of Byte;
   PFatData  = ^TFatData;
   TFatData  = Array [1.. SizeOf(TFatMap)] Of Char;
   TFatSector = Array [1..512] Of Byte;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Type
     PDiskMapDialog = ^TDiskMapDialog;
     TDiskMapDialog = Object(TDialog)
                       Procedure Draw;Virtual;
                      End;
Var FatMap     : TFatMap;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure TDiskMapDialog.Draw;
Var MaxX, MaxY : Byte;
    Buf : TDrawBuffer;
    Counter : Byte;
    X, Y : Byte;
Begin
 Inherited Draw;
 If SizeOf(FatMap[1])<Size.X-2 Then MaxX:=SizeOf(FatMap[1]) Else MaxX := Size.X-2;
 MaxY := SizeOf(FatMap) Div SizeOf(FatMap[1]);
 If Size.Y-2<MaxY Then MaxY := Size.Y-2;
 Counter := 0;
 For Y:=1 To MaxY Do Begin
 For X:=2 To MaxX Do Begin
                           MoveChar(Buf[Counter],Chr(FatMap[Y,(X-1)]),GetColor(1),1);
                           Inc(Counter);
                         End;
                   WriteBuf(2,Y,Counter,1,Buf);
                   Counter := 0;
                   End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function DiskMap( Dr : Char ): Word;
var
  D          : PDiskMapDialog;
  C          : PView;
  R          : TRect;
  DataPtr    : Pointer;
  BootSector : PBootSector;
  FatType    : Byte;
  Drive      : Byte;
  Reg        : Registers;
  DiskInfo   : PDiskInfo;
  Swap       : Real;
  FatStart   : Longint;
  I, Z       : Word;

  FatData    : PFatData;
  ClustersPerBlock : Byte;
  NumberOfBlocks : Word;
  AktualFatSector : Word;
  SectorInFat : Word;
  OffsetInSector : Word;
  ClustersInFatSector : Word;
  FatSector : TFatSector;
  Ofset : Word;
  Data  : Word;
begin
  FillChar(FatMap,SizeOf(FatMap),#32);
  Drive := Ord(Dr) - Ord('A')+1;
  Reg.Ah := $32;
  Reg.Dl := Drive;
  Msdos(Reg);
  DiskInfo := Ptr( Reg.Ds, Reg.Bx );
  If Reg.Al = 0 Then
   Begin
     With DiskInfo^ Do Begin
                         Swap:=((Longint(FatSize)*Longint(SectorSize))) / Longint(MaxClusters);
                         If (Swap>=1.5) Then FatType:=12;
                         If (Swap>=2.0) Then FatType:=16;
                         If (Swap>=4.0) Then FatType:=32;
                       End;
     FatStart := DiskInfo^.ReservedSectors;
     ClustersPerBlock := (DiskInfo^.MaxClusters Div SizeOf(FatMap))+1;
     NumberOfBlocks := DiskInfo^.MaxClusters Div ClustersPerBlock;
     Case FatType Of
       12: ClustersInFatSector := Trunc(DiskInfo^.SectorSize / 1.5);
       16: ClustersInFatSector := Trunc(DiskInfo^.SectorSize / 2);
       32: ClustersInFatSector := Trunc(DiskInfo^.SectorSize / 4);
       End;
     FatData:=@FatMap;
     AktualFatSector:=$FFFF;
     For I:=1 To NumberOfBlocks Do
       Begin
         SectorInFat:=((I-1)*ClustersPerBlock) Div (ClustersInFatSector);
         OffsetInSector:=((I-1)*ClustersPerBlock) Mod (ClustersInFatSector);
         If AktualFatSector <> SectorInFat Then
           Begin
            AktualFatSector:=SectorInFat;
            DosReadSector(FatStart+AktualFatSector,Drive-1,@FatSector);
           End;
         Case FatType Of
          12: Begin
               Ofset := Trunc(OffsetInSector * 1.5);
               Data := FatSector[Ofset] + ($FF * FatSector[Ofset+1]);
               If (Ofset Mod 2) = 0 Then Data := Data And $0FFF
                Else Data := Data Shr 4;
               Case Data Of
               $0FF7 : FatData^[I]:='B';
               $0000 : FatData^[I]:='°';
               Else FatData^[I]:='Û';
                End;
              End;
          16: Begin
               Ofset := Trunc(OffsetInSector * 2);
               If (FatSector[Ofset]=0) And (FatSector[Ofset+1]=0) Then FatData^[I]:='°'
                 Else FatData^[I]:='Û'
              End;
          32: Ofset := Trunc(OffsetInSector * 4);
         End;
       End;
     {----------------------------------}
     R.Assign(1,1,79,23);
     D:=New(PDiskMapDialog,Init(R,'Mapa disku'));
     with D^ do
       begin
          SelectNext(False);
       end;

     DataPtr:=Nil;
     DiskMap:=Application^.ExecuteDialog(D,DataPtr);
  End
Else MessageBox(#3+'Pro tento disk nelze zobrazit'+#13#3+'diskovu mapu',Nil,mfError+MfOkButton);
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Var New:TApplication;
Begin
New.Init;
DiskMap('E');
New.Done;
End.