Unit Control;
Interface
Type
TCoderHeader = Record
                RandSeed:Word;
                XorConst:Byte;
                CRC32 :Longint;
               End;

Procedure TestFiles(Con:String);
Procedure AddFile(S:String;S2:String);
Procedure UnCode(Var Variable;Size:Word);
Procedure Code(Var Variable;Size:Word);

Implementation
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{$IFDEF DPMI}
Uses Dos,Crt,WinApi;
{$ELSE}
Uses Dos,Crt;
{$ENDIF}
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Type
      TId          = String[20];
      TFileHeader = Record
                     CoderHeader:TCoderHeader;
                     Id:TId;
                     FileSize:Longint;
                     NumberOfFiles:Longint;
                     ProcesorType:Byte;
                     Coprocesor:Boolean;
                    End;
      TItem = Record
               CoderHeader:TcoderHeader;
               FileName:String[12];
               CRC32:Longint;
              End;
      THexTable = Array[0..15] Of Char;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Const
      CId : String [20] = 'SUPER CRC32!! SYSTEM.';
      HexTable  : THexTable = ('0','1','2','3','4','5','6','7','8'
                              ,'9','A','B','C','D','E','F');

Function GetProcesorType:Byte;
Begin
{$IFDEF DPMI}
If (GetWinFlags And wf_CPU086) = wf_CPU086 Then GetProcesorType:=0;
If (GetWinFlags And wf_CPU186) = wf_CPU186 Then GetProcesorType:=0;
If (GetWinFlags And wf_CPU286) = wf_CPU286 Then GetProcesorType:=1;
If (GetWinFlags And wf_CPU386) = wf_CPU386 Then GetProcesorType:=2;
If (GetWinFlags And wf_CPU486) = wf_CPU486 Then GetProcesorType:=2;
{$ELSE}
Case Test8086 Of
0: GetProcesorType:=0;
1:GetProcesorType:=1;
2:GetProcesorType:=2;
End;
{$ENDIF}
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Code(Var Variable;Size:Word);
Type TArray = Array [1..$FFFF] Of Byte;
Var PCoderHeader:^TcoderHeader;
    PArray:^TArray;
    Rand:Word;
    XorConst:Byte;
    I:Word;
    CRC32:Longint;
Begin
Randomize;XorConst:=Random(256);Rand:=Random($FFFF);
PCoderHeader:=@Variable;
RandSeed:=Rand;PcoderHeader^.RandSeed:=Rand;
PcoderHeader^.XorConst:=XorConst;
PArray:=@Variable;
CRC32:=0;For I:=1 To Size-11 Do CRC32:=CRC32 Xor PArray^[I+11];
PCoderHeader^.CRC32:=CRC32;
For I:=1 To Size-3 Do PArray^[I+3]:=PArray^[I+3] Xor XorConst Xor Random(256);
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure UnCode(Var Variable;Size:Word);
Type TArray = Array [1..$FFFF] Of Byte;
Var PCoderHeader:^TcoderHeader;
    PArray:^TArray;
    Rand:Word;
    XorConst:Byte;
    I:Word;
    CRC32:Longint;
Begin
PCoderHeader:=@Variable;
RandSeed:=PCoderHeader^.RandSeed;
XorConst:=PcoderHeader^.XorConst;
PArray:=@Variable;
For I:=1 To Size-3 Do PArray^[I+3]:=PArray^[I+3] Xor XorConst Xor Random(256);
CRC32:=0;
For I:=1 To Size-11 Do CRC32:=CRC32 Xor PArray^[I+11];
If PCoderHeader^.CRC32<>CRC32 Then Begin
                                   Writeln('CRC File corupted !!!');
                                   Halt(9);
                                   End;

End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function DecToHex(Number:Longint):String;
Var Swap:String;
    Zbytek:Longint;
Begin
Number:=Abs(Number);
Swap:='';While Number>0 Do Begin
                   Zbytek:=Number Mod 16;
                   Number:=Number Div 16;
                   Swap:=HexTable[Zbytek]+Swap;
                  End;
DecTohex:=Swap;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function GetCRC32(S : String):Longint;
Type Pbuf = ^Tbuf;
     TBuf = Array [1..64000] Of Byte;
Var F:File;
    Bufer:PBuf;
    Numread:Word;
    CRC32:Longint;
    I:Word;
    Search:SearchRec;
Begin
CRC32:=0;
New(Bufer);
FindFirst(S,Archive,Search);
If DosError<>0 Then Begin Writeln('File not exist !!!!');Halt(3);End;
Assign(F,S);
Reset(F,1);
Repeat
BlockRead(F,Bufer^,SizeOf(Bufer^),Numread);
For I:=1 To Numread Do CRC32:=CRC32+((Longint(Bufer^[I])) Xor $80053053);
Until Numread=0;
Close(F);
Dispose(Bufer);
CRC32:=CRC32 Xor $3A163B92;
GetCRC32:=CRC32;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function InsertSpace(S:String;Number:Byte):String;
Begin
While Length(S)<Number Do S:=S+#32;
InsertSpace:=S;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TestFiles;
Var
    CRC:Longint;
    FHead:TFileHeader;
    Item:Titem;
    F:File;
    Z:Integer;
    S:SearchRec;
    Old:Word;
Begin
FindFirst(Con,Archive,S);
If DosError<>0 Then Begin Writeln('CRC file not exist !!!!');Halt(4);End;
Assign(F,Con);
Reset(F,1);
BlockRead(F,FHead,SizeOf(FHead));
Uncode(FHead,SizeOf(FHead));
Write('{Computer}');
If Fhead.ProcesorType<>GetProcesorType Then Begin
                               Writeln('Nelegalni kopie programu !!!');
                               Halt(10);
                               End;
Writeln('          OK!');
If (Fhead.Id<>CID) Or (FHead.FileSize<>FileSize(F)) Then Begin
                       Writeln('CRC file corupted !!!!');Halt(4);
                       End;
For Z:=1 To FHead.NumberOfFiles Do Begin
  BlockRead(F,Item,SizeOf(Item));
  Uncode(Item,SizeOf(Item));
  Write(InsertSpace(Item.FileName,20));
  Old:=TextAttr;TextAttr:=$0A;
  Write(InsertSpace('['+DECTOHEX(Item.CRC32)+']',13));
  TextAttr:=Old;
  If Item.CRC32<>GetCrc32(Item.FileName) Then Begin
                                               Writeln (#7'CRC32 ERROR !!!!');
                                               Halt(5);
                                              End
   Else Writeln ('CRC32 OK!');
                                End;
Close(F);
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure AddFile;
Var CRCFile       : File;
    DirInfo       : SearchRec;
    FHead         : TFileHeader;
    Item          : Titem;
    Directory     : DirStr;
    Name          : NameStr;
    Extension     : ExtStr;
Begin
FindFirst(S2, Archive, DirInfo);
If DosError<>0 Then Begin
                    Assign(CRCFile, S2);
                    Rewrite(CRCFile, 1);
                    Fhead.Id:=CId;
                    Fhead.NumberOfFiles:=1;
                    BlockWrite(CRCFile, FHead, SizeOf(FHead));
                    FSplit(S, Directory, Name, Extension);
                    Item.FileName:=Name+Extension;
                    Item.CRC32:=GetCRC32(S);
                    Code(Item,SizeOf(Item));
                    BlockWrite(CRCFile,Item,SizeOf(Item));
                    Close(CRCFile);
                    Assign(CRCFile,S2);
                    Reset(CRCFile,1);
                    FHead.FileSize:=FileSize(CRCFile);
                    Fhead.ProcesorType:=GetProcesorType;
                    Code(Fhead, SizeOF(FHead));
                    BlockWrite(CRCFile,FHead,SizeOf(FHead));
                    Close(CRCFile);
                    End
Else Begin
      Assign(CRCFile,S2);
      Reset(CRCFile,1);
      If FileSize(CRCFile)<SizeOf(FHead) + SizeOf(Item) Then
         Begin
         Close(CRCFile);
         Writeln('Control file is corupted');Halt(2);
         End;
      BlockRead(CRCFile,FHead,SizeOf(FHead));
      Uncode(FHead,SizeOf(Fhead));
      If Fhead.ID<>CId Then        Begin
                                    Close(CRCFile);
                                    Writeln('Control file is corupted');
                                    Halt(2);
                                   End;
      Seek(CRCFile,SizeOf(FHead)+(FHead.NumberOfFiles*SizeOf(Item)));
      FSplit(S, Directory, Name, Extension);
      Item.FileName:=Name + Extension;
      Item.CRC32:=GetCRC32(S);
      Code(Item,SizeOf(Item));
      BlockWrite(CRCFile,Item,SizeOf(Item));
      Close(CRCFile);
      Assign(CRCFile,S2);
      Reset(CRCFile,1);
      Fhead.NumberOfFiles:=Fhead.NumberOfFiles+1;
      FHead.FileSize:=FileSize(CRCFile);
      Code(FHead,SizeOf(FHead));
      BlockWrite(CRCFile,FHead,SizeOf(FHead));
      Close(CRCFile);
     End;
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
End.