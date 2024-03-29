{$O+,F+}
Unit Error;
Interface
Procedure OverlayError(E,ExitCode:Integer);
Function SysError(ErrorCode: Integer; Drive: Byte): Integer;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Implementation
Uses Overlay, Drivers, Objects, Base, Dos, Czech;
const

  SCriticalError:  string[36] = 'Kritick� diskov� chyba v jednotce %c';
  SWriteProtected: string[42] = 'Disk v jednotce %c je chr쟮�n proti z쟰isu';
  SDiskNotReady:   string[37] = 'Disketov� jednotka %c nen� p�ipravena';
  SDataIntegrity:  string[32] = 'Chyba integrity dat v jednotce %c';
  SSeekError:      string[22] = 'Chyba vyhled쟶쟮� %c';
  SUnknownMedia:   string[31] = 'Nezn쟭� typ m괺ia v jednotce %c';
  SSectorNotFound: string[30] = 'Sector nenalezen v jednotce %c';
  SOutOfPaper:     string[22] = 'Chyb� pap죚 v tisk쟲n�';
  SWriteFault:     string[26] = 'Chyba z쟰isu na disk %c';
  SReadFault:      string[25] = 'Chyba 웪en� z disku %c';
  SGeneralFailure: string[28] = 'Technick� z쟶ada na disku %c';
  SBadImageOfFAT:  string[32] = 'Chybn� kopie tabulky FAT v opera웢� pam�ti';
  SDeviceError:    string[26] = 'Chyba v p爻stupu na za爻zen�';
  SInsertDisk:     string[30] = 'Vlo쬽e disketu do mechaniky %c';
  SRetryOrCancel:  string[28] = '~Enter~ Opakuj  ~Esc~ Zru�it';


  ErrorString: array[0..15] of Word = (
    Ofs(SWriteProtected),
    Ofs(SCriticalError),
    Ofs(SDiskNotReady),
    Ofs(SCriticalError),
    Ofs(SDataIntegrity),
    Ofs(SCriticalError),
    Ofs(SSeekError),
    Ofs(SUnknownMedia),
    Ofs(SSectorNotFound),
    Ofs(SOutOfPaper),
    Ofs(SWriteFault),
    Ofs(SReadFault),
    Ofs(SGeneralFailure),
    Ofs(SBadImageOfFAT),
    Ofs(SDeviceError),
    Ofs(SInsertDisk));

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure OverlayError;
Begin
 Case E Of
  ovrError       : Writeln('chyba spr쟶ce ovrlej�');
  ovrNotFound    : Writeln('ovrlejov� soubor nenalezen');
  ovrNoMemory    : Writeln('m쟫o pam�ti pro ovrleje');
  ovrIOError     : Writeln('chyba I/O ovr. souboru');
  ovrNoEMSDriver : Writeln('nen� instalov쟮 driver EMS');
  ovrNoEMSMemory : Writeln('nedostatek EMS pam�ti');
 End;
 Halt(ExitCode);
End;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure VideoInt; near; assembler;
asm
	PUSH	BP
	PUSH	ES
	INT	10H
	POP	ES
	POP	BP
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure SwapStatusLine(var Buffer); near; assembler;
asm
	MOV	CL,ScreenWidth
	XOR	CH,CH
	MOV	AL,ScreenHeight
	DEC	AL
	MUL	CL
	SHL	AX,1
	LES	DI,ScreenBuffer
	ADD	DI,AX
	PUSH	DS
	LDS	SI,Buffer
@@1:	MOV	AX,ES:[DI]
	MOVSW
	MOV	DS:[SI-2],AX
	LOOP	@@1
	POP	DS
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
function SelectKey: Integer; near; assembler;
asm
	MOV	AH,3
	MOV	BH,0
	CALL	VideoInt
	PUSH	CX
	MOV	AH,1
	MOV	CX,2000H
	CALL	VideoInt
@@1:	MOV	AH,1
	INT	16H
	PUSHF
	MOV	AH,0
	INT	16H
	POPF
	JNE	@@1
	XOR	DX,DX
	CMP	AL,13
	JE	@@2
	INC	DX
	CMP	AL,27
	JNE	@@1
@@2:	POP	CX
	PUSH	DX
	MOV	AH,1
	CALL	VideoInt
	POP	AX
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{$V-}
function SysError(ErrorCode: Integer; Drive: Byte): Integer;
var
  C: Word;
  P: Pointer;
  S: string[63];
  B: array[0..79] of Word;
  K: Integer;
begin
  if FailSysErrors then
  begin
    SysError := 1;
    Exit;
  end;

  if Lo(ScreenMode) = smMono then
    C := SysMonoAttr else
    C := SysColorAttr;
  P := Pointer(Drive + Ord('A'));
  DosError:=ErrorCode;
  FormatStr(S, PString(Ptr(DSeg, ErrorString[ErrorCode]))^, P);
  MoveChar(B, ' ', Byte(C), 80);
  MoveCStr(B[1], S, C);
  MoveCStr(B[79 - CStrLen(SRetryOrCancel)], SRetryOrCancel, C);
  SwapStatusLine(B);
  K := SelectKey;
  If K = 0 Then DosError:=0;
  SysError := K;
  SwapStatusLine(B);
end;
{$V+}
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Begin
  SysErrorFunc:=SysError;
End.