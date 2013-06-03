Unit Base;
Interface
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function NovellInstaled : Boolean;
Function DecToHex(Number:Longint):String;
Function HexToDec(Number:String):Longint;
Function DecToBin(Number:Longint):String;
Function BinToDec(Number:String):Longint;
Function IntToStr(Int:Longint):String;
Function StrToInt(Str:String):Integer;
Function StrPas(Str: PChar): String;
Function DownCase(C : Char) : Char;
Function DownString(S : String) : String;
Function UpString(S : String) : String;
Function SetBit(Int:Longint;BitMask:Longint):Longint;
Function ClearBit(Int:Longint;BitMask:Longint):Longint;
Function GetTimer:Longint;
Function GetStartupPath:String;
Function FillToFront(S:String;Len:Byte;C:Char):String;
Function FillToLength(S:String;Len:Byte;C:Char):String;
Function Executable(Path:String):Boolean;
Function TruncString(Parametr,S:String;Len:Byte):String;
Function GetExtension(Path:String):String;
Function GetName(Path:String):String;
Function KanonizeFile(S:String;Attr:Word):String;
Function DriveValid(Drive: Char): Boolean;
Function FileMask (Name : String;Mask:String) : Boolean;
Function GetLastDirInPath(Path : String) : String;
Function Thousand(num:longint):string;
Procedure SetVerify ( Verify : Boolean);
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Implementation
Uses Dos;
Type
      THexTable = Array[0..15] Of Char;
Const
      HexTable  : THexTable = ('0','1','2','3','4','5','6','7','8'
                              ,'9','A','B','C','D','E','F');
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure SetVerify;Assembler;
asm
  mov ah,2eh
  mov al,Verify
  int 21h
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function Thousand;
var
  mark            : Boolean;
  strnum, strwork : string;
  pos             : ShortInt;
begin
  str(num, strnum);
  mark:=num<>abs(num);
  if mark then strnum:=copy(strnum, 2, length(strnum));
  strwork:=strnum;
  pos:=-1;
  while pos+4<length(strnum) do begin
    inc(pos, 3);
    insert(' ', strwork, length(strnum)-pos);
  end;                                        { dˆlej dokud je co rozdˆlovat }
  if mark then strwork:='-'+strwork;
  Thousand:=strwork;
end; { function ths }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function NovellInstaled ;
var
 mah  : byte;
begin
  asm
    mov ax, 7a00h
    int 2fh
    mov [mah], al
  end;
 If Mah=$FF Then NovellInstaled := True Else NovellInstaled:=False;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function FileMask ;
Var I      : Byte;
    Times  : Boolean;
    SChar  : Char;
    Back   : Byte;
    MI, NI : Byte;
    NotGood : Boolean;
Begin
  Mask:=Upstring(Mask);Name:=Upstring(Name);
  FileMask := False;Times := False;Schar:=#0;
  If (Length(Mask) = 0)  Or (Length(Name) = 0) Then Exit;
  I := 1;
  While I <> Length(Mask) Do
     If (Mask[I]='*') And ((Mask[I + 1]='*') Or (Mask[I + 1]='?')) Then
        Delete(Mask,I+1,1)
     Else Inc(I);
  I := Length(Mask);
  While I <> 1 Do
    Begin
     If (Mask[I]='*') And ((Mask[I - 1]='*') Or (Mask[I - 1]='?')) Then
        Delete(Mask,I-1,1);
        Dec(I);
    End;
  MI := 1; NI := 1;Times := False;NotGood := False;
  While (NI<=Length(Name)) and (MI<=Length(Mask)) Do
    Begin
     If (NI = Length(Name)) And (Mask[MI]='*') Then Begin Inc(Mi);Inc(Ni);Break;End;
     If (Mask[MI]='*') And Times Then Times := False;
     If (Not Times) And (Mask[MI]<>Name[NI]) And (Mask[MI]<>'?') And (Mask[MI]<>'*') Then Begin
                                                                                            Exit;
                                                                                            NotGood := True;
                                                                                          End
     Else If (Times) And (Mask[MI]<>Name[NI]) And (Mask[MI]<>'?')
                                              Then Begin
                                                    Times := False;
                                                    MI := Back;
                                                   End
     Else If (Mask[MI]='*') And (Name[NI]=Mask[Mi+1]) Then
            Begin
             Times := True;
             Back := MI;
             Inc(MI);
            End;
      Inc(NI);
      If (Mask[MI]='*') And (Not Times) Then
        Else Inc(MI);
    End;
  If (Not NotGood) And (Ni>Length(Name)) and (Mi>Length(Mask)) Then FileMask:=True;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function DriveValid;assembler;
asm
	MOV	AH,19H          { Save the current drive in BL }
        INT	21H
        MOV	BL,AL
 	MOV	DL,Drive	{ Select the given drive }
        SUB	DL,'A'
        MOV	AH,0EH
        INT	21H
        MOV	AH,19H		{ Retrieve what DOS thinks is current }
        INT	21H
        MOV	CX,0		{ Assume false }
        CMP	AL,DL		{ Is the current drive the given drive? }
	JNE	@@1
        MOV	CX,1		{ It is, so the drive is valid }
	MOV	DL,BL		{ Restore the old drive }
        MOV	AH,0EH
        INT	21H
@@1:	XCHG	AX,CX		{ Put the return value into AX }
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function GetExtension;
Var S : String;
    I : Integer;
Begin
I:=Pos('.',Path);
If I <>0 Then GetExtension:=Copy(Path,I+1,Length(Path)-I)
  Else GetEXtension:='';
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function GetName;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
FSplit(Path, D, N, E);
GetName := N;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function KanonizeFile;
Var  Ext : String[3];
     Name : String[8];
     C : Char;
     Str : String;
Begin
If S<>'..' Then Begin
  Ext:=GetExtension(S);Name:=GetName(S);C:=#32;
   If (Attr And ReadOnly) = ReadOnly Then C:='ú';
   If (Attr And Hidden) = Hidden Then C:='±';
   Str := FillToLength(Name,8,#32) + C + FillToLength(Ext,3,#32);
   KanonizeFile:=DownString(Str);
   If (Attr And Directory)= Directory Then KanonizeFile:=UpString(Str);
                  End
  Else KanonizeFile:='..          '
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function TruncString;
Var Old : Byte;
Begin
Old := Length(S);
If Length(Parametr)+Length(S)> Len Then
  Begin
   Delete(S,1,(Length(Parametr)+Length(S))-Len);
  End;
If Old<>Length(S) Then TruncString:=Parametr+S
  Else TruncString:=S;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function DecToHex;
Var Swap:String;
    Zbytek:Longint;
Begin
Swap:='';While Number>0 Do Begin
                   Zbytek:=Number Mod 16;
                   Number:=Number Div 16;
                   Swap:=HexTable[Zbytek]+Swap;
                  End;
DecTohex:=Swap;

End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function HexToDec;
Var I,Size:Byte;
    Vaha,Swap:Longint;
Begin
Vaha:=1;Swap:=0;For I:=Length(Number) DownTo 1 Do Begin
                                      Size:=0;While HexTable[Size]<>Number[I] Do Inc(Size);
                                      Swap:=Swap+(Size*Vaha);
                                      Vaha:=Vaha*16;
                                      End;
HexToDec:=Swap;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function DecToBin;
Var Swap:String;
    Zbytek:Longint;
Begin
Swap:='';While Number>0 Do Begin
                   Zbytek:=Number Mod 2;
                   Number:=Number Div 2;
                   Swap:=HexTable[Zbytek]+Swap;
                  End;
DecToBin:=Swap;

End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function BinToDec;
Var I,Size:Byte;
    Vaha,Swap:Longint;
Begin
Vaha:=1;Swap:=0;For I:=Length(Number) DownTo 1 Do Begin
                                      Size:=0;While HexTable[Size]<>Number[I] Do Inc(Size);
                                      Swap:=Swap+(Size*Vaha);
                                      Vaha:=Vaha*2;
                                      End;
BinToDec:=Swap;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function DownCase;
Begin
 If ((Ord(C)>64) And (Ord(C)<91)) Then DownCase:=Chr(Ord(C)+32)
  Else DownCase:=C;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function DownString;
Var I : Integer;
Begin
 For I:=1 To Length(S) Do S[I]:=DownCase(S[I]);
 DownString:=S;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function UpString;
Var I : Integer;
Begin
 For I:=1 To Length(S) Do S[I]:=UpCase(S[I]);
 UpString:=S;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{$W+,S-}
Function StrPas(Str: PChar): String; assembler;
asm
	PUSH	DS
	CLD
	LES	DI,Str
	MOV	CX,0FFFFH
	XOR	AL,AL
	REPNE	SCASB
	NOT	CX
	DEC	CX
	LDS	SI,Str
	LES	DI,@Result
	MOV	AL,CL
	STOSB
	REP	MOVSB
	POP	DS
end;
{$W-,S+}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function IntToStr;
Var S : String;
Begin
 Str(Int,S);IntToStr:=S;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function StrToInt;
Var S : String;
    I : Longint;
    Code : Integer;
Begin
 Val(Str,I,Code);
 If Code = 0 Then StrToInt:=I Else StrToInt:=0;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function SetBit;
Begin
 Setbit:=Int or BitMask;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function ClearBit;
Begin
 Clearbit:=Int and (Not BitMask);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function GetStartupPath:String;
var
  ExeFileName: String;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  ExeFileName := ParamStr(0);
  ExeFileName := FExpand(ExeFileName);
  FSplit(ExeFileName, D, N, E);
  GetStartupPath := D;
end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function FillToLength;
Var I:Integer;
Begin
While Length(S)<Len Do S:=S+C;
FillToLength:=S;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function FillToFront;
Var I:Integer;
Begin
While Length(S)<Len Do S:=C+S;
FillToFront:=S;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function Executable;
Var  E : String [3];
Begin
Executable:=False;
E:=UpString(GetExtension(Path));
IF (E = 'EXE') Or (E = 'COM') Or  (E = 'BAT') Then Executable:=True;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function GetLastDirInPath;
Var I : Integer;
Begin
 GetLastDirInPath :='';
 For I:= Length(Path) DownTo 1 Do If Path[I]='\' Then Break;
 If I=Length(Path) Then Exit;
 If Path[I]='\' Then GetLastDirInPath:=Copy(Path,I+1,Length(Path)-I);
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function GetTimer;
Var R: Registers;
Begin
 R.Ah := 0;
 Intr($1A, R);
 GetTimer := (Longint(R.Cx)*$10000) + R.DX;
End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
End.