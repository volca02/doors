Unit Base;
Interface
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function DecToHex(Number:Longint):String;
Function HexToDec(Number:String):Longint;
Function DecToBin(Number:Longint):String;
Function BinToDec(Number:String):Longint;
Function IntToStr(Int:Integer):String;
Function StrPas(Str: PChar): String;
Function DownCase(C : Char) : Char;
Function DownString(S : String) : String;
Function UpString(S : String) : String;
Function SetBit(Int:Longint;BitMask:Longint):Longint;
Function ClearBit(Int:Longint;BitMask:Longint):Longint;
Function GetStartupPath:String;
Function FillToLength(S:String;Len:Byte;C:Char):String;
Function Executable(Path:String):Boolean;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Implementation
Uses Dos;
Type
      THexTable = Array[0..15] Of Char;
Const
      HexTable  : THexTable = ('0','1','2','3','4','5','6','7','8'
                              ,'9','A','B','C','D','E','F');
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
Function Executable;
Var Position : Byte;
    E : String;
Begin
Executable:=False;
Position:=Pos('.',Path);
If Position<>0 Then Begin
                     E:=Copy(Path,Position,Length(Path)-Position+1);
                    IF (UpString(E)='.EXE') Or (UpString(E)='.COM') Then Executable:=True;
                    End;

End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
End.