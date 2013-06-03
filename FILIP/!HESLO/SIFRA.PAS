uses dialogs, views, objects, app, drivers, crt, supply, msgbox, base;
const
  SIFRACommandOrigin                      =   200;
  mask                  = 134;
type
   PSIFRAData = ^TSIFRAData;
   TSIFRAData = record
               heslo                :  string[10];
           end;

var
  a, b, c, d  : word;
Procedure InitRnd;
begin
  a:=0;
  b:=11;
  c:=13;
  d:=21;
end;

Function GetRnd  : word;
begin
  a:=b xor c xor d;
  b:=c xor a shr 1 and d;
  c:=d xor (not c) shl 2 xor a;
  d:=a xor c and (not c);
  GetRnd:=(a xor b and c) shr 8;
end;

function SIFRA(var _Data : TSIFRAData; _SetData : Boolean; fajl: string): Word;
var
  D    : PDialog;
  C    : PView;
  R    : TRect;
  _DataPtr : PSIFRAData;
begin
  R.Assign(17,5,57,14);
  D:=New(PDialog,Init(R,'›ifrov n¡ soubor–'));
  with D^ do
       begin
          R.Assign(28,4,38,6);
          C:=New(PButton,Init(R,'~O~k',cmOk,bfDefault));
          Insert(C);

          R.Assign(28,6,38,8);
          C:=New(PButton,Init(R,'Zru¨it',cmCancel,bfNormal));
          Insert(C);

          R.Assign(10,4,22,5);
          C:=New(PInputLine,Init(R,10));
          Insert(C);

          R.Assign(3,4,9,5);
          C:=New(PStaticText,Init(R,'Heslo:'));
          Insert(C);

          R.Assign(5,2,35,3);
          C:=New(PStaticText,Init(R,'Zadej heslo pro "'+
                 GetName(fajl)+'.'+GetExtension(fajl)+'"'));
          Insert(C);

          SelectNext(False);
       end;

   _DataPtr:=@_Data;
   if not _SetData then FillChar(_Data,SizeOf(_Data),0);
   SIFRA:=Application^.ExecuteDialog(D,_DataPtr);
end;

{----------------------------------------------------------------------------}

const blocksize=16000;
      chn      =11;
      chead : array[1..chn] of char='DOORS CODED';
var
  g     : tsifradata;
  fajl  : string;
  f     : file;
  i,o   : array [0..blocksize] of char;
  num,x,pr, last : word;
  moje  : tapplication;
  crypted   : boolean;
  CRC       : word;
  header    : record
                head  : array[1..Chn] of char;
                CRC   : word;
              end;

Procedure Decrypt(nm: word);
begin
  for x:=0 to nm do
  begin
    o[x]:=
     Chr(Ord(i[x]) xor (ord(g.heslo[pr]) xor GetRnd+x xor mask
                +x shr 4+x shl 4) mod 256);
    inc(pr);
    if pr>length(g.heslo) then pr:=1;
  end;
end;

Function CountCRC  : word;
var
 a,b  : word;
begin
  pr:=1; InitRnd;
  if crypted then DeCrypt(x) else o:=i;
  a:=0;
  for b:=0 to x-1 do
  begin
    a:=a+ord(o[b]);
  end;
  CountCRC:=a;
  pr:=1;
  InitRnd;
end;

begin
  moje.init;
  fajl:='d:\fractal.pas';
  if Sifra(g,true,fajl)=cmok then
  begin
    g.Heslo:=Upstring(g.heslo);
    if g.Heslo='' then
    begin
      sound(1000);
      delay(100);
      nosound;
      MessageBox('Chybne Heslo.', nil,mfError+mfOkButton);
    end else
    begin
      { prevod }
      assign(f,fajl);
      {$I-} reset(f,1); {$I+}
      if ioresult=0 then
      begin
        {prevod}
        pr:=1;
        seek(f,filesize(f)-sizeof(header));
        blockread(f,header,sizeof(header));
        if header.head=chead then crypted:=true else crypted:=false;
        Seek(f,0);
        x:=32;
        if not crypted and (filesize(f)<x) then
                         x:=filesize(f);
        if crypted and (filesize(f)-sizeof(header)<x) then
                     x:=filesize(f)-sizeof(header);
         {max. 32 bajtu}
        Blockread(f,i,x); crc:=CountCRC;
        If crypted and (CRC<>header.crc) then
        begin
          MessageBox('Chybny kontrolni soucet,'+
                     #13#10'Spatne heslo.', nil,mfError+mfOkButton);
        end else
        begin
          if crypted then
          begin
            seek(f,filesize(f)-sizeof(header));
            Truncate(f);
          end;
          Seek(f,0);
          repeat
            if filesize(f)-filepos(f)>blocksize then num:=blocksize else
               num:=filesize(f)-filepos(f);
            blockread(f,i,num);
            Decrypt(num);
            seek(f,filepos(f)-num);
            blockwrite(f,o,num);
            Writeln(filepos(f)*100/filesize(f):4:0,'%');
          until filesize(f)-filepos(f)=0;
          if not Crypted then
          begin
            Move(chead,header.head,chn);
            Header.crc:=crc;
            Blockwrite(f,header,sizeof(header));
          end;
          close(f);
        end {if else};
      end else
      begin
        sound(1000);
        delay(100);
        nosound;
        MessageBox('Chyba pri otevirani souboru.',nil,mfError+ mfOkButton);
      end
    end;
  end;
  moje.done;
end.
