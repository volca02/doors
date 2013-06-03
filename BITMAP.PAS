{$O+,F+}
unit BITMAP;
{DEFINE WRITE}
{$I-}
interface
uses base;
const errors: array [1..8] of string[30] =
                 ('Soubor nenalezen',
                  'Vadn˜ form t souboru'{BMP <> PCX},
                  'P©ed‡asn˜ konec souboru',
                  'Chybn  velikost souboru',
                  'Nenalezeno vhodn‚ rozli¨en¡',
                  'Nanalezen VESA BIOS',
                  'Neznam˜ typ komprese',
                  'Nepodpodporovan˜ form t souboru');

var
  Rx,Ry    : word;
  Fcol     : word;
  error    : string[30]; { papriku! Tohle je retezec kerej bude
                         obsahovat chybu pokud fce vrati true }
  bafrresult : integer;

Function ViewBMP(fil : string):String;
Function ViewPCX(fil : string):String;

implementation

{$I INC\VESA.INC}

const BI_RGB=0;
      BI_RLE8=1;
      BI_RLE4=2;

type
{------------------ BMP ------------------}
     tBMFH = record
               head       : word;  { BM ==> 4D42h }
               size       : longint;
               res1, res2 : word;
               bdoff      : longint; { zacatek aktualnich obrazovych dat }
             end;

     tBMCH = record
               size              : longint;
               ResX, ResY        : word;
               biplanes, BPP     : word;
             end;

     tBMIH = record
               size, ResX, ResY  : longint;
               biplanes, BPP     : word;
               bicompression, bisize  : longint;
               XperMtr, YperMtr       : longint;
               ClrUsed, ClrImportant  : longint;
             end;


     tRGBq = record
               b,g,r, res  : byte;
             end;
{------------------ PCX ------------------}
     tPXFH = record
               head          : word; { budeme cist ked $050A }
               compression   : byte; { budeme cist ked 1 (=PCX run length) }
               BPP           : byte;
               LowX, LowY,
               HiX, HiY      : word; { Odecteme }
               HRes, VRes    : word;
               { ... Nasleduje 16ti barevna paleta }
             end;
     tPXCH = record
               reserved      : byte; {0}
               planes        : byte;
               BPL           : word;
             end; { docist do 128 bajtu! (seek) }
     tRGBt = record
               R,G,B    : byte;
             end;
{------------------ PRO POTREBY URYCHLOVACE ------------------}
     pradek = ^tradek;
     tradek = array [0..65534] of byte;

{------------------ URYCHLOVACI CAST ------------------}
const
  cachesize = 32000;
var
  f        : file;
  bafr     : pradek;
  point    : word;
  endofbafr : word;

Procedure Chyba;
begin
  error:=errors[3];
  bafrresult:=1;
  asm
    mov ax, $3
    int 10h
  end;
end;

Procedure RereadBuffer;
var l  : longint;
begin
{$I-}
  seek(f,filepos(f)-(longint(endofbafr)-point));
  endofbafr:=cachesize;
  l:=filesize(f)-filepos(f);
  if l>0 then
  begin
    if l<cachesize then endofbafr:=l;
    Blockread(f,bafr^,endofbafr);
    if ioresult<>0 then Chyba;
  end else Chyba;
  point:=0;
{$I+}
end;

Procedure InitBafr;
begin
  Getmem(bafr, cachesize);
  endofbafr:=cachesize; point:=endofbafr;
  rereadbuffer;
end;

Procedure DoneBafr;
begin
  Dispose(bafr);
end;

Procedure CheckOverflow(bytes:word);
begin
  if point+bytes>endofbafr then
  begin
    RereadBuffer;
  end;
end;

Procedure BafrRead(var b; bytes  : word);
begin
  CheckOverflow(bytes);
  Move(bafr^[point],b,bytes);
  inc(point, bytes);
  if bafrresult<>0 then
  begin
    DoneBafr;
    Close(f);
  end;
end;

Procedure BufferSeek(where  : longint);
begin
  seek(f,where);
  point:=0;
  endofbafr:=0;
  RereadBuffer;
end;
{------------------ KONEC URYCHLOVACI CASTI ----------------------}
Function NiHi(b:byte):byte;
begin
  NiHi:=b and $F0 shr 4;
end;

Function NiLo(b:byte):byte;
begin
  NiLo:=b and $F;
end;

var x,y      : word;
    l        : longint;
    b        : byte;
    w        : word;
Procedure NextLine; begin x:=0; y:=y+1; end;

Function ViewBMP;
var
  hedr     : tbmfh;
  info     : tbmih;
  core     : tbmch;
  col      : tRGBq;
  to32     : byte;
  rle      : record
               b1, b2  : byte;
             end;


begin
  error:=''; {$I-} Bafrresult:=0;
  if not DETECTvesa then error:=errors[6] else
  begin
    assign(f,fil);
    reset(f,1);
    initbafr;
    if ioresult=0 then
    begin
      BafrRead(hedr,sizeof(tbmfh));          If BafrResult<>0 then exit;
      if ioresult=0 then
        if (hedr.head=$4D42) {and (hedr.size=filesize(f))} then
        begin
          BafrRead(l,4);                     If BafrResult<>0 then exit;
          point:=point-4; { l=12 ... Core header, l=40 normal header}
          if l=40 then BafrRead(info,sizeof(tbmih)) else
          if l=12 then
          begin {core header}
             BafrRead(core,sizeof(tbmch));   If BafrResult<>0 then exit;
             info.ResX:=core.resX;
             info.ResY:=core.resY;
             info.BPP:=core.BPP;
             info.Biplanes:=core.Biplanes;
             info.bicompression:=0;
          end else
          begin
            error:=errors[2];
            viewBMP:=Error;
            exit;
          end;
          { najdeme vhodne rozliseni? }
          b:=info.bpp;
          Fcol:=info.bpp;
          Rx:=info.ResX;
          Ry:=info.ResY;
          if b in [1,4] then b:=8;
          with info do x:=GetResolutionNumber(ResX,ResY,B);
          if x<>$FFFF then
          begin
            b:=3+byte(l=40);
            SetResolution(x);
            { nastavime si paletu }
            case info.bpp of
              1: for x:=0 to 1 do
                 begin
                   BafrRead(col,b);          If BafrResult<>0 then exit;
                   SetPal(x,col.r,col.g,col.b);
                 end;
              4: for x:=0 to 15 do
                 begin
                   BafrRead(col,b);          If BafrResult<>0 then exit;
                   SetPal(x,col.r,col.g,col.b);
                 end;
              8: for x:=0 to 255 do
                 begin
                   BafrRead(col,b);          If BafrResult<>0 then exit;
                   SetPal(x,col.r,col.g,col.b);
                 end;
            end; { case }
            { vykreslime }
            BufferSeek(hedr.bdoff);          If BafrResult<>0 then exit;
            if info.bpp=1 then{ 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1}
              for y:=0 to info.ResY-1 do
              begin
                For x:=0 to info.ResX-1 do
                begin
                  if (x and 7)=0 then
                    BafrRead(b,1);           If BafrResult<>0 then exit;
                  DrawPixel(x,info.Resy-y,b and $80 shr 7);
                  b:=b and $7F shl 1;
                end;
                {b:=(4-(info.resX mod 4))*byte(info.resX mod 4>0);
                BafrRead(l,b);} {!!!!!!!!!!!!!DODELAT!!!!!!!!!!!}
              end else
            if info.bpp=4 then { 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 }
            case info.bicompression of
               BI_RGB:
                begin
                  to32:=4 - (info.resX shr 1 + info.resX and 1) Mod 4;
                  If to32=4 Then to32:=0;
                  for y:=0 to info.ResY-1 do
                  begin
                    For x:=0 to info.ResX-1 do
                    begin
                      if odd(x+1) then
                        BafrRead(b,1);       If BafrResult<>0 then exit;
                      DrawPixel(x xor 1,info.Resy-y,NiLo(b));
                      b:=b shr 4;
                    end;
                    BafrRead(l,To32);           If BafrResult<>0 then exit;
                  end;
                end;
               BI_RLE4:
                  begin { RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE}
                    x:=0; y:=0;
                    repeat
                      BafrRead(rle,2);       If BafrResult<>0 then exit;
                      case rle.b1 of
                        00 :
                            case rle.b2 of
                              00: NextLine;
                              01: ;
                              02: begin
                                    BafrRead(rle,2); If BafrResult<>0 then exit;
                                    x:=x+rle.b1;
                                    y:=y+rle.b2;
                                  end;
                              else
                                begin
                                  for rle.b1:=1 to rle.b2 do
                                  begin
                                    if rle.b1 and 1=1 then BafrRead(b,1); If BafrResult<>0 then exit;
                                    DrawPixel(x,info.Resy-y,NiHi(b));
                                    b:=NiLo(b) shl 4;
                                    x:=x+1;
                                  end;
                                  rle.b2:=rle.b2 and 1+rle.b2 shr 1;
                                  if odd(rle.b2) then
                                       BafrRead(b,1); If BafrResult<>0 then exit;
                                end;
                            end;
                      else
                        begin
                          b:=rle.b2;
                          for l:=0 to rle.b1-1 do
                          begin
                            if l and 1=0 then
                              DrawPixel(x+l,info.Resy-y,NiHi(b)) else
                              DrawPixel(x+l,info.Resy-y,NiLo(b));
                          end;
                          x:=x+rle.b1;
                        end;
                      end;
                    until (rle.b1=0) and (rle.b2=1);
                  end; { RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE}
                else error:=errors[7];
            end else
            if info.bpp=8 then {8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8}
              case info.bicompression of
                BI_RGB:
                  Begin
                   to32:=(4-(info.resX mod 4))*byte(info.resX mod 4>0);
                   for y:=0 to info.ResY-1 do
                   begin
                     For x:=0 to info.ResX-1 do
                     begin
                       BafrRead(b,1);              If BafrResult<>0 then exit;
                       DrawPixel(x,info.Resy-y,b);
                     end;
                    BafrRead(l,To32);                 If BafrResult<>0 then exit;
                   end;
                  end;
                BI_RLE8:
                  begin { RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE}
                    x:=0; y:=0;
                    repeat
                      BafrRead(rle,2);               If BafrResult<>0 then exit;
                      case rle.b1 of
                        00 :
                            case rle.b2 of
                              00: NextLine;
                              01: ;
                              02: begin
                                    BafrRead(rle,2); If BafrResult<>0 then exit;
                                    x:=x+rle.b1;
                                    y:=y+rle.b2;
                                  end;
                              else
                                begin
                                  for rle.b1:=1 to rle.b2 do
                                  begin
                                    BafrRead(b,1);   If BafrResult<>0 then exit;
                                    DrawPixel(x,info.Resy-y,b);
                                    x:=x+1;
                                  end;
                                  if odd(rle.b2) then BafrRead(b,1); If BafrResult<>0 then exit;
                                end;
                            end;
                        else
                        begin
                          for l:=0 to rle.b1-1 do
                            DrawPixel(x+l,info.Resy-y,rle.b2);
                          x:=x+rle.b1;
                        end;
                      end;
                    until (rle.b1=0) and (rle.b2=1);
                  end; { RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE RLE}
                else error:=errors[7];
              end else
            if info.bpp=16 then { 16 16 16 16 16 16 16 16 16 16 16 16 16 16}
            begin
              to32:=RoundUp(info.resX,2)-info.resX-1;
              for y:=0 to info.ResY-1 do
                  begin
                    For x:=0 to info.ResX-1 do
                    begin
                      BafrRead(w,2);                 If BafrResult<>0 then exit;
                      DrawPixel(x,info.Resy-y,w);
                    end;
                    BafrRead(l,To32); If BafrResult<>0 then exit;
                  end;
            end else
            if info.bpp=24 then { 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24}
            begin
              to32:=RoundUp(info.resX*3,4)-info.resX*3;
              for y:=0 to info.ResY-1 do
                  begin
                    For x:=0 to info.ResX-1 do
                    begin
                      BafrRead(l,3);                 If BafrResult<>0 then exit;
                      DrawPixel(x,info.Resy-y,l);
                    end;
                    BafrRead(l,To32);                 If BafrResult<>0 then exit;
                  end;
            end else error:=errors[8];
          end { vykreslovani }
          else error:=errors[5]; { Vhodne rozliseni }
        end else else error:=errors[2]; { typ souboru }
    end else error:=errors[1]; { Nalezeni souboru }
  end;
  donebafr;
  close(f);
  viewbmp:=Error;
end;

{============================================================================}
{=============================== tlusta cara ne =============================}
{============================================================================}
Function ViewPCX;
var
 hedr  : tPXFH;
 c     : tRGBt;
 planes  : byte;
 plane   : byte;
 bpl     : word;
{$IFDEF WRITE} txt  : text;{$ENDIF}
begin
  error:=''; Bafrresult:=0;
  if not DETECTvesa then error:=errors[6] else
  begin
    Assign(f,fil);
    Reset(f,1);
    if ioresult=0 then
    begin
      InitBafr;
      BafrRead(hedr,sizeof(hedr));           If BafrResult<>0 then exit;
      if hedr.head=$050A then
      begin
        hedr.HiX:=Hedr.HiX-Hedr.LowX+1*(Hedr.HiX and 1 xor 1)+1;
        hedr.HiY:=Hedr.HiY-Hedr.LowY+1;
        b:=hedr.bpp;
        if b<8 then b:=8;
        with hedr do x:=GetResolutionNumber(HiX,HiY,B);
        if x<>$FFFF then
        begin
          SetResolution(x);
          BufferSeek(65);                    If BafrResult<>0 then exit;
          BafrRead(planes,1);                If BafrResult<>0 then exit;
          BafrRead(bpl,2);                   If BafrResult<>0 then exit;
          if hedr.bpp*planes=4 then
          begin
            BufferSeek(16);
            for x:=0 to 15 do
            begin
              BafrRead(c,3);                 If BafrResult<>0 then exit;
              SetPal(x,c.r,c.g,c.b);
            end;
          end; {bpp=4}
          if hedr.bpp=8 then
          begin
            BufferSeek(Filesize(f)-768);
            for x:=0 to 255 do
            begin
              BafrRead(c,3);                 If BafrResult<>0 then exit;
              SetPal(x,c.r,c.g,c.b);
            end;
          end; {bpp=8}
          BufferSeek(128);
          { vykreslime }
          l:=0;
          if planes>1 then
          begin
           for y:=0 to hedr.HiY-1 do
            for plane:=0 to planes-1 do
             for x:=0 to BPL-1 do
               begin
                 if l=0 then
                 begin
                   Bafrread(b,1); l:=1;      If BafrResult<>0 then exit;
                   if b and $C0=$C0 then
                   begin
                     l:=b and 63;
                     BafrRead(b,1);          If BafrResult<>0 then exit;
                   end;
                end;
                for w:=0 to 7 do
                  if (b and ($80 shr w))>0 then { pokud je bit nastaven }
                      SetBits(x*8+w,y,1 shl plane); { bude i tady }
                dec(l);
               end
          end else
           if hedr.bpp=8 then
           for y:=0 to hedr.HiY-1 do
            for x:=0 to hedr.HiX-1 do
            begin
              if l=0 then
              begin
                Bafrread(b,1); l:=1;         If BafrResult<>0 then exit;
                if b and $C0=$C0 then
                begin
                  l:=b and 63;
                  BafrRead(b,1);
                end;
              end;
              DrawPixel(x,y,b);
              dec(l);
            end else
            if hedr.bpp=1 then
            for y:=0 to hedr.HiY-1 do
            for x:=1 to hedr.HiX div 8 do
            begin
              if l=0 then
              begin
                Bafrread(b,1); l:=1;         If BafrResult<>0 then exit;
                if b and $C0=$C0 then
                begin
                  l:=b and 63;
                  BafrRead(b,1);
                end;
              end;
              for w:=0 to 7 do
                   if (b and ($80 shr w))>0 then { pokud je bit nastaven }
                       DrawPixel((x-1)*8+w,y,15); { bude i tady }
              dec(l);
            end else error:=errors[8];
        end else error:=errors[5];
      end else error:=errors[2];
    end else error:=errors[1];
  end;
  ViewPCX:=Error;
end;

end.