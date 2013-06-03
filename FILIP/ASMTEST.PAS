uses ToAsm;

Function Tohex(l:longint):string;
const
 table:array[0..15] of char=
       ('0','1','2','3','4','5','6','7','8','9',
        'A','B','C','D','E','F');
var
 str:string;
begin
 str:='';
 repeat
  str:=table[l and $F]+str;
  l:=l shr 4;
 until l=0;
 if odd(length(str)) then str:='0'+str;
 Tohex:=str;
end;

const
  test : array [1..6] of byte = ($4F, $56, $56, $66 ,$00, $ff);
var
  s,st  : string;
  a,x  : byte;
  n  : byte;
  pos  : word;
  p  : ^pointer;
begin
  p:=@test;
  n:=0; pos:=100;
  repeat
    st:='';
    Write(pos+a:3,' ');
    for x:=1 to a do st:=st+tohex(byte(Ptr(Seg(p^),ofs(p^)+x)));
    Decode(p,s,a);
    Writeln(st:16,' ',s);
    pos:=pos+a;
    asm
      mov cl, a
      xor ch, ch
   @l: inc word ptr p
      loop @l
    end;
    inc(n);
  until n>=10;
end.