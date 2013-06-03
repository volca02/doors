 {$M $800,0,480}
 Uses Dos,Crt;

 Const run:byte=0;
      prflag:byte=0;

 Var  rg:registers;
      videomode,ncol,lrow:byte;
      dosflagptr:^byte;
      videoram:word;
      oldprscr,oldtimer,oldcriterr,olddossafe:procedure;
      myfile:file of byte;
      dirinfo:searchrec;

  Procedure printscreen;
  var
    x,y,mybyte:byte;
   begin
        prflag:=0;
        rg.ah:=$0f;
        intr($10,rg);
   videomode:=rg.al;
   ncol:=rg.ah;

       rg.ah:=$11;
       rg.al:=$30;
       rg.dl:=24;
      intr($10,rg);
   Lrow:=rg.dl;
      if videomode = 7 then videoram:=$b000
         else videoram:=$b800;

   assign(myfile,'prscreen.sav');
   rewrite(myfile);
    y:=0;
  For X:=0 To Lrow Do Begin
  For Y:=0 To Ncol-1 Do write(myfile,mem[videoram:X*2*ncol + Y*2]);
                         mybyte:=13;
                         write(myfile,mybyte);
                         mybyte:=10;
                         write(myfile,mybyte);
                        End;
   Close(myfile);
   end;

  procedure newcriterr(_flags,_cs,_ip,_ax,_bx,_cx,_dx,_si,_di,_ds,_es,_bp:word);interrupt;
  begin
  _ax:=(_ax and $ff00)+$03;
  end;
   procedure resident;
  begin
   run:=1;
   getintvec($24,@oldcriterr);
   setintvec($24,addr(newcriterr));
   printscreen;
   run:=0;
  end;

  procedure newprscr;interrupt;
  begin
  prflag:=1;
  end;

  procedure newtimer;interrupt;
  begin
  inline($9c);
  oldtimer;
  if (prflag =1 ) and (dosflagptr^=0) and (run=0) then resident;
  end;

  procedure newdossafe;interrupt;
  begin
  inline($9c);
  olddossafe;
  if (prflag=1) and (dosflagptr^=1) and (run=0) then resident;
  end;

  procedure install;
 begin
  rg.ah:=$34;
  msdos(rg);
  dosflagptr:=ptr(rg.es,rg.bx);
  getintvec($08,@oldtimer);
  getintvec($28,@olddossafe);
  getintvec($05,@oldprscr);
  setintvec($08,addr(newtimer));
  setintvec($28,addr(newdossafe));
  setintvec($05,addr(newprscr));
  Writeln('Done');
  keep(0);
 end;


begin
  write('Instalation check......');
  Install;
end.













