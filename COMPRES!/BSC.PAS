Unit BSC;
Interface
Uses Dos,Objects;

Type RR_Type  = Word;

Type  ComStr   = String[127];


{$I Struct.pas}

Const MaxCompressors     = 16;

Const ReadOnly           = $00;
      WriteOnly          = $01;
      ReadWrite          = $02;

      ShareCompatible    = $00;
      ShareDenyReadWrite = $10;
      ShareDenyWrite     = $20;
      ShareDenyRead      = $30;
      ShareDenyNone      = $40;

      Inheritance        = $80;
      DefaultFileMode    = ReadOnly+ShareCompatible;

Type
         TCompressor = Object
                        Files           : PStringCollection;
                        FileName        : ComStr;
                        FileSize        : Longint;
                        CompressorType  : CompressorID; { Unique short compressor ID  }
                        CompressorName  : NameString;   { Full compressor name        }
                        Magic           : MagicTypes;   { A unique number             }
                        WhereInFile     : LongInt;      { Filepointer                 }
                        ProtectedFile   : Boolean;      { Sec. Env. boolean           }
                        SelfExtractor   : Boolean;      { SelfExtractor boolean       }
                        ContainsPaths   : Boolean;      { Contains paths boolean      }
                        HasPassword     : Boolean;      { Password protected          }
                        SolidArchive    : Boolean;      { Is solid                    }
                        Locked          : Boolean;      { is Locked                   }
                        UnpackVersion   : Byte;         { Unpack version. 0 -> unknown}
                        HeaderTitle     : String[132];  { Title line for header       }
                        HeaderLines     : String[132];  { Second line for header      }
                        FileExtra       : String[132];  { Extra info found in the file}
                        Entry           : InfoBlock;    { Internal entry buffer       }

                        Platform        : PlatformID;   { Compressors platform        }
                        LastEntry       : Boolean;      { True if end of file         }
                        BeQuick         : Boolean;      { Don't show so don't conv.   }
                        PreviouseMode   : Byte;         { Memory byte last filemode   }

                        RR,RW           : RR_Type;      { RealRead variable for Blockread/write }

                        Constructor Init;

                        Procedure FindFirstEntry;         Virtual;
                        Procedure FindNextEntry;          Virtual;
                        Procedure LoadFiles;              Virtual;
                        Procedure CheckProtection;        Virtual;
                        Procedure PrintEntry;             Virtual;
                        Function IsThisTypeFile(Var B; Size : Word):Boolean; Virtual;
                        Procedure ReturnEntry(Var E);     Virtual;

                        Function WhichType:CompressorID;         { Return Compressor ID     }
                        Function WhichPlatform:PlatFormID;       { Return current platform  }
                        Function PlatformName:String;            { The name of the platform }
                        Procedure WriteHeader;                   { Write a header on screen }

                        Function Asciiz2String(Var A):String;
                        Function TimeStamp(Time : LongInt):TimeString;
                        Function UnixTime(Time : LongInt):TimeString;
                        Function Nr2Str(W : LongInt;Len : Byte):String;
                        Function HexWord(Number : Word):String;
                        Function HexLong(number : LongInt):String;
                        Function ShortFileName(FileSpec : ComStr):ComStr;
                        Function StripPath(F : ComStr):PathStr;
                        Function IsBitSet(Flag,Bit : Word):Boolean;
                        Function SearchBuffer(Var B;Size,Start,Stop:Word;Check : String;Var InFile: LongInt):Boolean;
                        Function IsEXEFile(Var B):Boolean;
                        Function LongSwap(L : LongInt):LongInt;

                        Procedure SetFileMode(Mode : Byte);
                        Procedure ResetFileMode;
                       End;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Create an array of pointers to compressionobjects.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

{Type ObjectList  = Array[1..MaxCompressors] of ^TCompressorObject;
Var  OList       : ObjectList;
     OPtr        : Byte;
     ExitSave    : Pointer;

Procedure AddToList(P : Pointer);}

Implementation


Constructor TCompressor.Init;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Initialize the object, fill all the fields.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
BeQuick      :=False;
LastEntry    :=False;
SelfExtractor:=False;
ProtectedFile:=False;
ContainsPaths:=False;
HasPassword  :=False;
SolidArchive :=False;
Locked       :=False;
UnpackVersion:=0;

CompressorType:='UNK';
CompressorName:='* Unknown *' ;
Magic         := None;

PlatForm    :=ID_IBM;
HeaderTitle :='Orig   Methode    Comp   Time     Date        CRC      Name             Sec';
HeaderLines :='ÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍ';
FileExtra   :='';
End;


{ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
  Virtual procedures and functions
 ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ}
Procedure TCompressor.FindFirstEntry;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Find the first entry in a compressed file.   VIRTUAL procedure
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
End;

Procedure TCompressor.FindNextEntry;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Find the next entry in a compressed file.    VIRTUAL procedure
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
End;

Procedure TCompressor.LoadFiles;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Find the first entry in a compressed file.   VIRTUAL procedure
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
End;


Procedure TCompressor.CheckProtection;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Check a file for protectionflags, paths etc. VIRTUAL procedure
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
End;


Procedure TCompressor.WriteHeader;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Write an header to the screen.       VIRTUAL procedure
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
WriteLn('Filename    : ',StripPath(FileName));
  Write('Ã Compressor: ',CompressorName);
If SelfExtractor
   Then Write('  (SelfExtractor)');
If UnpackVersion<>0
   Then WriteLn(' (MinVersion: ',UnpackVersion,')')
   Else WriteLn(' (MinVersion: unknown');
If FileExtra='' Then Write('À ') Else Write('Ã ');
WriteLn('Platform  : ',PlatformName);

If FileExtra<>''
   Then WriteLn('À ',FileExtra);
WriteLn;
WriteLn(HeaderTitle);
WriteLn(HeaderLines);
End;

Procedure TCompressor.PrintEntry;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Write an entry to the screen.    VIRTUAL procedure.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
With IBM(Entry) Do
 Begin
 Write(OriginalSize:6,' ');
 Write(CompressionName,' ');
 Write(CompressedSize:6,' ');
 Write(FileDate:20,' ');
 Write(FileCRC,' ');
 Write(ShortFileName(FileName));
 WriteLn(' ',SaveID);
 End;
End;

Procedure TCompressor.ReturnEntry(Var E);
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Return an entry as untyped variable.   VIRTUAL procedure.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
Move(IBM(Entry),E,SizeOf(Entry));
End;

Function TCompressor.IsThisTypeFile(Var B;Size : Word):Boolean;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Detect if the current file is of this type. VIRTUAL procedure
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
IsThisTypeFile:=False;
End;


Function TCompressor.WhichType:CompressorID;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Return the value of the CompressorType field.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
WhichType:=CompressorType;
End;

Function TCompressor.WhichPlatform:PlatFormID;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Return the value of the Platform field.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
WhichPlatform:=PlatForm;
End;


Function TCompressor.PlatformName:String;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Return a description of the platform
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
Case Platform Of
 ID_IBM      : PlatformName:='IBM or compatible';
 ID_MAC      : PlatformName:='Apple MacIntosh';
 ID_MULTI    : PlatformName:='Platform independend';
 Else          PlatformName:='Unknown platform';
End; {Case}
End;


{ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
  LowLevel utility routines.
 ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ}

Const  Months     : Array[0..12] of String[3]
                  = (
                    '???',
                    'Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'
                    );


Function TCompressor.Asciiz2String(Var A):String;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Convert an ASCIIZ string to a TP string.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Type Temp = Array[1..255] of Char;
Var S : String;
Begin
Move(Temp(A),S[1],255);

S[0]:=#01;
While (Length(S)<255) And (S[Length(S)]<>#00) Do
 Inc(S[0]);
Dec(S[0]);
Asciiz2String:=S;
End;

Function TCompressor.TimeStamp(Time : Longint):TimeString;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Create a timestamp string from a MSdos timestamp longint.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Var DateRec : DateTime;
    TempStr : TimeString;
Begin
UnpackTime(Time,DAteRec);
TempStr:='';
With DateRec Do
 TempStr:= Nr2Str(Hour,2)+':'+Nr2Str(Min,2)+':'+Nr2Str(Sec,2)+' '+
           Nr2Str(Day,2)+'-'+Months[Month]+'-'+Nr2Str(Year,4);
TimeStamp:=TempStr;
End;

Function TCompressor.UnixTime(Time : LongInt):TimeString;
Begin
UnixTime:=' Unsupported format ';
End;


Function TCompressor.Nr2Str(W : LongInt;Len : Byte):String;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Convert a number to a string of a certain length.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Var Tmp : String[10];
    C   : Byte;
Begin
Str(W:Len,Tmp);
For C:=1 To Length(Tmp) Do
 If Tmp[C]=' '
    Then Tmp[C]:='0';
Nr2Str:=Tmp;
End;


Function TCompressor.HexWord(number : Word):String;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Convert a word to a HEX value.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Const HexNum : Array[0..15] Of Char = '0123456789ABCDEF';
Begin
HexWord:=HexNum[(Hi(Number) And $F0) Shr 4] + HexNum[(Hi(Number) And $0F)]+
         HexNum[(Lo(Number) And $F0) Shr 4] + HexNum[(Lo(Number) And $0F)];
End;

Function TCompressor.HexLong(number : LongInt):String;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Convert a longint to a HEX value.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Const HexNum : Array[0..15] Of Char = '0123456789ABCDEF';
Type  tLong = Record
        H,L : Word;
      End;
Begin
HexLong:=HexWord(tLong(Number).H)+HexWord(tLong(Number).L);
End;





Function TCompressor.ShortFileName(FileSpec : ComStr):ComStr;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Shorten a full filespecifier to a filename with pathindication
    F.e.: C:\TEST\PROG\BLABLA.PAS becomes
          ...\BLABLA.PAS
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Var Dum  : DirStr{ComStr};
    Name : NameStr{String[40]};
    Ext  : ExtStr{String[40]};
    Count: Byte;
Begin
For Count:=1 To Length(FileSpec) do
 If FileSpec[Count]='/'
    then FileSpec[Count]:='\';
FSplit(FileSpec,Dum,Name,Ext);
If Dum<>''
   Then Dum:='...\'+Name+Ext
   Else Dum:='    '+Name+Ext;
While Length(Dum)<=15 Do
 Dum:=Dum+' ';
ShortFileName:=Dum;
End;

Function TCompressor.StripPath(F : ComStr):PathStr;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Strip the path and return only the filename.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Var Dum   : Byte;
Begin
Dum:=Length(F);
Repeat
 Dec(Dum);
Until (Dum=0) Or (F[Dum] in ['\','/',':']);
If Dum>0
   Then Delete(F,1,Dum);
StripPath:=F;
End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  SearchBuffer searches a buffer of a certain size for a certain string.
  The Start and stop offset can be given to limit the search range.
  InFile returns the position of the string within the buffer if found.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

{$IfNDef UseASM}
Function TCompressor.SearchBuffer(Var B;
                                                Size  : Word;
                                                Start : Word;
                                                Stop  : Word;
                                                Check : String;
                                            Var InFile: LongInt
                                           ):Boolean;

Type TC = Array[0..$FFFE] of Char;
Var BufPtr : Word;
    Found  : Boolean;
    Ok     : Boolean;
    TmpPtr : Word;
Begin
SearchBuffer:=True;
BufPtr:=Start;
Found:=False;
While (Not Found) And (BufPtr<Stop) Do
  Begin
  If Check[1]=TC(B)[BufPtr]
     Then Begin
          Ok:=True;
          TmpPtr:=BufPtr+1;
          While Ok And ((TmpPtr-BufPtr)<Length(Check)) Do
            Begin
            Ok:=TC(B)[TmpPtr]=Check[TmpPtr-BufPtr+1];
            Inc(TmpPtr);
            End;
          Found:=Ok;
          End;

  Inc(BufPtr);
  End;
SearchBuffer:=Found;
InFile:=BufPtr-1;
End;

{$Else}

Function TCompressorObject.SearchBuffer(Var B;
                                                Size  : Word;
                                                Start : Word;
                                                Stop  : Word;
                                                Check : String;
                                            Var InFile: LongInt
                                                ):Boolean; External;
{$L .\SEARCH.OBJ}

{$EndIf}


Function TCompressor.IsEXEFile(Var B):Boolean;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Check if the file is an exe file.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Type Check = Array[0..1] of Char;
Begin
isEXEFile:=Check(B)='MZ';
End;

Function TCompressor.IsBitSet(Flag,Bit : Word):Boolean;
Begin
IsBitSet:=(Flag and Bit)=Bit;
End;

Function TCompressor.LongSwap(L : LongInt):LongInt;
Type TC = Record
           W1,W2 : Word;
          End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Swap a longint from INTEL to MOTEROLA format or vice versa
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Begin
LongSwap:=(LongInt(SWAP(TC(L).W1)) Shl 16) + LongInt(SWAP(TC(L).W2));
End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 Store, set and reset the filemode variable
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

Procedure TCompressor.SetFileMode(Mode : Byte);
Begin
PreviouseMode:=FileMode;
FileMode:=Mode;
End;

Procedure TCompressor.ResetFileMode;
Begin
FileMode:=PreviouseMode;
PreviouseMode:=DefaultFileMode;
End;

End.

