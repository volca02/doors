Echo off
Echo Vytvarim napovedu ....
tvhc drshelp.txt drs.hlp drshelp.pas
Echo Linkuji obj soubory ..
tasm cpu.asm >Nul
tasm sysint.asm >Nul
tasm format.asm >nul
Echo Sestavuji program ....
bpc drs.pas /b -$G+ -$V-
Echo Sestavuji loader .....
tasm drs.asm >Nul
tlink drs.obj /tc >Nul
del drs.prg
rename drs.exe drs.prg 