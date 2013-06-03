{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ The ECT Libraries v1.1, Unit LXMSWork, Created 30.04.1996 in Hradec Kr lov‚}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
unit LXMSWork;
interface

const
  XMSError              : Byte = 0;
type
  EMMStructure          = Record
                            BytestoMoveLo,              { Low Word of Bytes to move. NB: Must be even! }
                            BytestoMoveHi,              { High Word of Bytes to move }
                            SourceHandle,               { Handle number of source (SH=0 => conventional memory) }
                            SourceoffsetLo,             { Low Word of source offset, or ofS if SH=0 }
                            SourceoffsetHi,             { High Word of source offset, or SEG if SH=0 }
                            DestinationHandle,          { Handle number of destination (DH=0 => conventional memory) }
                            DestinationoffsetLo,        { Low Word of destination offset, or ofS if DH=0 }
                            DestinationoffsetHi  :Word; { High Word of destination offset, or SEG if DH=0 }
                          end;
var
  XMSEntryPoint         : Pointer;                { Entry point of the XMS routine in memory }

  function NoXMS : Boolean;
  function XMSMaxAvail : Word;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
implementation
{Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä Ä }

function NoXMS : Boolean; assembler;
{ checks out if there is a XMS driver installed, and in Case it initialize the
  XMSEntryPoint Variable }
label JumpOver;
asm
  push es

  mov  ax,4300h                                  { AX = 4300h => inSTALLATION CHECK }
  int  2Fh                                       { use int 2Fh Extended MEMorY SPECifICATION (XMS) }
  mov  bl,1                                      { use BL as a flag to indicate success }
  cmp  al,80h                                    { is a XMS driver installed? }
  jne  JumpOver
  mov  ax,4310h                                  { AX = 4310h => GET DRIVER ADDRESS }
  int  2Fh
  mov  [Word ptr XMSEntryPoint+0],BX             { initialize low Word of XMSEntryPoint }
  mov  [Word ptr XMSEntryPoint+2],ES             { initialize high Word of XMSEntryPoint }
  mov  bl,0                                      { indicate success }
JumpOver:
  mov  al,bl                                     { make the Function return True (AH=1) or False (AH=0) }

  pop  es
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

function XMSMaxAvail : Word; assembler;
{ returns size of largest contiguous block of XMS in kilo (1024) Bytes }
label JumpOver;
asm
  mov  ah,08h                                    { 'Query free Extended memory' Function }
  mov  XMSError,0                                { clear error Variable }
  call [dWord ptr XMSEntryPoint]
  or   ax,ax                                     { check For error }
  jnz  JumpOver
  mov  XMSError,bl                               { errornumber stored in BL }
JumpOver:                                        { AX=largest contiguous block of XMS }
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

begin
end. { unit LXMSWork }