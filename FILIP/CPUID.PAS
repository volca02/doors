var
  str  : string [12];
begin
{  Warning: je to pro pentium a vyzsi! }
  asm
    mov ax, ds
    mov es, ax
    mov di, offset str
    inc di
    db 66h,33h,0C0h { xor eax, eax}
    db 0Fh,0A2h    { CPUID }
    db 66h,26h,89h,1Dh { mov es:[di], eax }
    db 66h,26h,89h,55h,04h
    db 66h,26h,89h,4Dh,08h
  end;
  str[0]:=#12;
  Writeln(str);
end.