{$M 35384,8192,655360}
Program DRS;
Uses Main, Variable, Overlay, Objects, Views, Drivers, App, Error, ColorSel
    , Viewer, ScrSav, Network, Files, Disk, Editor;

{$O HelpFile}
{$O Info}
{$O Tools}
{$O ColorSel}
{$O Options}
{$O FileFind}
{$O Antivirs}
{$O Viewer}
{$O ScrSav}
{$O Network}
{$O Files}
{$O Disk}
{$O Bitmap}
{$O Editor}

Var
    Doors : TDoors;

Begin

Asm
mov ah,10h
mov al,3
xor bl,bl
int 10h
End;

OvrInit('DRS.OVR');
if OvrResult <> 0 then OverlayError(OvrResult,2);
OvrInitEMS;
Doors.Init;
Doors.Run;
Doors.Done;
End.