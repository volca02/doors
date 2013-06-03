Unit Czech;
Interface
Uses Views;
 Type
        TConvertTable = Array [0..47] Of Char;
 Const
        AktualCzech   : Byte = 0;
        KeyboardType  : Boolean = False;
        KamenicCT : TConvertTable =('€','','‚','ƒ','„','…','†','‡','ˆ','‰'
                                  ,'Š','‹','Œ','','','','','‘','’','“'
                                  ,'”','•','–','—','˜','™','š','›','œ',''
                                  ,'','Ÿ',' ','¡','¢','£','¤','¥','¦','§'
                                  ,'¨','©','ª','«','¬','­','®','¯');

        Latin2CT : TConvertTable  =('¬','','‚','Ô','„','Ò','›','Ÿ','Ø','·'
                                  ,'‘','Ö','–','’','','µ','','§','¦','“'
                                  ,'”','à','…','é','ì','™','š','æ','•','í'
                                  ,'ü','œ',' ','¡','¢','£','å','Õ','Ş','â'
                                  ,'ç','ı','ê','è','Î','õ','®','¯');

        EECSCT : TConvertTable    =('È','ü','é','ï','ä','Ï','','è','ì','Ì'
                                  ,'Å','Í','¾','å','Ä','Á','É','','','ô'
                                  ,'ö','Ó','ù','Ú','ı','Ö','Ü','Š','¼','İ'
                                  ,'Ø','','á','í','ó','ú','ò','Ò','Ù','Ô'
                                  ,'š','ø','à','À',' ','§','«','»');

        IBMCT : TConvertTable     =('C','u','e','d','a','D','T','c','e','E'
                                  ,'L','I','l','l','A','A','E','z','Z','o'
                                  ,'o','O','u','U','y','O','U','S','L','Y'
                                  ,'R','t','a','i','o','u','n','N','U','O'
                                  ,'s','r','r','R','Î','õ','®','¯');

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure LoadFont;
Procedure CSString(Var S:String);
Procedure InitKeyBoard;
Procedure DoneKeyBoard;
Procedure SetCzech(Typ : Byte);
Procedure InvertKeyBoardType;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
 Implementation
  Uses Dos, Drivers;
  Type TFont=Array[1..4096] Of Byte;
Type
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  KeyboardBufer    = Array[1..$20] Of Char;
  ConvertTable     = Array[1..94] Of Char;
  ConvertDiakritic = Array[1..58] Of Char;
  DiakriticTable   = Array[1..3] Of ConvertDiakritic;
Const
  KamenicDT : DiakriticTable =
(('','B','C','D','','F','G','H','‹','J','K','L','M','N','•','P','Q','R','S','T'
 ,'—','V','W','X','','Z','[','\',']','^','_','`',' ','b','c','d','‚','f','g','h'
 ,'¡','j','k','l','m','n','¢','p','q','r','s','t','£','v','w','x','˜','z')
,('A','B','€','…','‰','F','G','H','I','J','K','L','M','¥','§','P','Q','','›','†'
 ,'¦','V','W','X','Y','’','[','\',']','^','_','`','a','b','‡','ƒ','ˆ','f','g','h'
 ,'i','j','k','l','m','¤','“','p','q','©','¨','Ÿ','–','v','w','x','y','‘')
,('','B','C','D','E','F','G','H','I','J','K','L','M','N','§','P','Q','R','S','T'
 ,'š','V','W','X','Y','Z','[','\',']','^','_','`','„','b','c','d','e','f','g','h'
 ,'i','j','k','l','m','n','“','p','q','r','s','t','','v','w','x','y','z'));
  Kamenic : ConvertTable =
{'!','"','#','$','%','&',''','(',')','*','+',',','-','.','/','0','1','2','3','4'}
('1','!','3','4','5','7','­','9','0','8','+',',','=','.','-','‚','+','ˆ','¨','‡'
{'5','6','7','8','9',':',';','<','=','>','?','@','A','B','C','D','E','F','G','H'}
,'©','‘','˜',' ','¡','"','–','?','=',':','_','2','A','B','C','D','E','F','G','H'
{'I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','[','\'}
,'I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','£','\'
{']','^','_','`','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p'}
,')','6','%','`','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p'
{'q','r','s','t','u','v','w','x','y','z','{','|','.','~'}
,'q','r','s','t','u','v','w','x','y','z','/','|','(',';');
  Latin2DT : DiakriticTable =
(('µ','B','C','D','','F','G','H','Ö','J','K','L','M','N','à','P','Q','R','S','T'
 ,'é','V','W','X','í','Z','[','\',']','^','_','`',' ','b','c','d','‚','f','g','h'
 ,'¡','j','k','l','m','n','¢','p','q','r','s','t','£','v','w','x','ì','z')
,('A','B','¬','Ò','·','F','G','H','I','J','K','•','M','Õ','â','P','Q','ü','æ','›'
 ,'Ş','V','W','X','Y','¦','[','\',']','^','_','`','a','b','Ÿ','Ô','Ø','f','g','h'
 ,'i','j','k','–','m','å','o','p','q','ı','ç','œ','…','v','w','x','y','§')
,('','B','C','D','E','F','G','H','I','J','K','L','M','N','™','P','Q','R','S','T'
 ,'š','V','W','X','Y','Z','[','\',']','^','_','`','„','b','c','d','e','f','g','h'
 ,'i','j','k','l','m','n','”','p','q','r','s','t','','v','w','x','y','z'));
  Latin2   : ConvertTable =
{'!','"','#','$','%','&',''','(',')','*','+',',','-','.','/','0','1','2','3','4'}
('1','!','3','4','5','7','?','9','0','8','+',',','=','.','-','‚','+','Ø','ç','Ÿ'
{'5','6','7','8','9',':',';','<','=','>','?','@','A','B','C','D','E','F','G','H'}
,'ı','§','ì',' ','¡','"','…','?','=',':','_','2','A','B','C','D','E','F','G','H'
{'I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','[','\'}
,'I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','£','\'
{']','^','_','`','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p'}
,')','6','%','`','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p'
{'q','r','s','t','u','v','w','x','y','z','{','|','.','~'}
,'q','r','s','t','u','v','w','x','y','z','/','|','(',';');

Const
  CRightShift                = 1;
  CLeftShift                 = 2;
  CCapsLock                  = 64;
Var
  AktualDT                  : DiakriticTable;
  Aktual                    : ConvertTable;
  KbdIntVec                 : Procedure;
  DiakriticMode             : Boolean;
  OldBuferHead,OldBuferEnd  : Word;
  AktualScanCode,OldScanCode: Byte;
  OldCharCode,C             : Char;
  KeyDown                   : Boolean;
  Index                     : Byte;
  RightShift                : Boolean;
  LeftShift                 : Boolean;
  Shifts                    : Boolean;
  CapsLock                  : Boolean;
  OldShifts                 : Boolean;
  DScanCode                 : Byte;
  DShifts                   : Boolean;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{$F+,S-,W-}
Procedure LoadFont;
Const KamenicFont : TFont = ({$I INC\kamenic.inc});
      Latin2Font  : TFont = ({$I INC\latin2.inc});
Var   F     : File;
      R     : Registers;
      Data  : TFont;
Begin
  Case AktualCzech Of
     0 : Data := KamenicFont;
     1 : Data := Latin2Font;
       Else Data := KamenicFont;
  End;

R.Ax:=$1100;
R.bx:=$1000;
R.Bp:=Ofs(Data);
R.Cx:=256;
R.Dx:=0;
R.es:=Seg(Data);
Intr($10,R);
End;
{$F-,S+}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  Procedure CSString;
   Var I,C,Z:Word;
       FromC,ToC : TConvertTable;
    Begin
     FromC:=KamenicCT;
    Case AktualCzech Of
     0 : ToC:= KamenicCT;
     1 : ToC:= Latin2CT;
     2 : ToC:= IBMCT;
     3 : ToC:= EECSCT;
    End;

     For C:=0 To Length(S) Do
     If (Ord(S[C])>127) And (Ord(S[C])<128+SizeOf(FromC))
      Then S[C]:=ToC[C];
 End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{$F+}
procedure Keyclick; interrupt;
Var OutChar                   : ^Char;
    BuferHead,BuferEnd        : ^Word;
    KeyFlags                  : ^Byte;
begin
If Not KeyBoardType Then Begin
                          inline ($9C);
                          KbdIntVec;
                          Exit;
                         End;
OldScanCode:=AktualScanCode;
AktualScanCode:=Port[$60];
If (AktualScanCode<>$D) and (AktualScanCode<>41) Then
Begin
      inline ($9C);                    {Zavolej starou obsluhu klavesnice   }
      KbdIntVec;
 KeyFlags:=Ptr(SEG0040,$17);
 OldShifts:=Shifts;CapsLock:=False;LeftShift:=False;RightShift:=False;
 If (Keyflags^ and CCapslock)=CCapsLock Then Capslock:=True;
 If (Keyflags^ and CLeftShift)=CLeftShift Then LeftShift:=True;
 If (Keyflags^ and CRightShift)=CRightShift Then RightShift:=True;
 Shifts:=LeftShift or RightShift;
 BuferHead := Ptr(SEG0040,$1A);        {Ukazatel na TOP Buferu klavesnice   }
 BuferEnd  := Ptr(SEG0040,$1C);        {Ukazatel na konec Buferu klavesnice }
 OutChar   := Ptr(SEG0040,BuferHead^); {Ukazatel na posledni pismeno v bufe.}
 C         := OutChar^;
 If ((AktualScanCode<$47) or (AktualScanCode>$55)) and (AktualScanCode<$80)
  And (AktualScanCode<>55) And (OldScanCode<>$e0) Then Begin
  If (Ord(C)>32) and (Ord(C)<=32+SizeOf(ConvertTable)) Then
             Begin
               C:=(Aktual[Ord(C)-32]);OutChar^:=C;
             End;
  If (DiakriticMode) Then
       Begin
        iF (AktualScanCode<>13) and (AktualScanCode<>$2a) Then Begin
        If DScanCode=41 Then Index:=3
        Else If DShifts Then Index:=2
        Else Index:=1;
        If (Ord(C)>64) and (Ord(C)<=64+SizeOf(ConvertDiakritic)) Then
           C:=(AktualDT[Index][Ord(C)-64]);DiakriticMode:=False;OutChar^:=C;
           End;
        End;End;

End
Else
     Begin
     asm
         mov al,20h
         out 20h,al
     end;DiakriticMode:=True;Dshifts:=Shifts;DScanCode:=AktualScanCode;End;
End;
{$F-}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure InitKeyBoard;
Begin
GetIntVec($9,@KbdIntVec);
SetIntVec($9,Addr(Keyclick));
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure DoneKeyBoard;
Begin
SetIntVec($9,@KbdIntVec);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure SetCzech;
Begin
 Case Typ Of
   0 : Begin AktualCzech:=0;Aktual:=Kamenic;AktualDt:=KamenicDT;End;
   1 : Begin AktualCzech:=1;Aktual:=Latin2;AktualDT:=Latin2DT End;
   2 : Begin AktualCzech:=2;Aktual:=Kamenic;AktualDt:=KamenicDT;End;
   3 : Begin AktualCzech:=3;Aktual:=Latin2;AktualDT:=Latin2DT End;
  End;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure InvertKeyBoardType;
Begin
  KeyBoardType := Not KeyBoardType;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
End.