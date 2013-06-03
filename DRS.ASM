;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ LOADER FOR DOORS ! ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ David Petrik, Brozikova 1405, Hradec Kralove 12, 50012                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
; 		       Telephone Number : +420603461079
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MouseInteruptAddr	equ	0CCh
Max		        equ	8000h			
PSPAddres	        equ	2Ch
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
@@CopyData Macro	     ; Pozor  napsana na tvrdo nelze prepisovat
		lodsb				; Loadni [si] do al
		stosb				; Uloz al do es:[di]
		or	al,al			
		loopnz	$-4		        ; Al = 0 ? Ne Tak Opakuj
          EndM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
@@SearchStringEnd Macro	     ; Pozor  napsana na tvrdo nelze prepisovat
		   lodsb			; Loadni [si] do al
		   or	  al,al			
		   loopnz $-3		        ; Al = 0 ? Ne Tak Opakuj
                  EndM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
execs struc
 PSPsegment	dw      00h
 OffsetCL      	dw      80h
 SegmentCl	dw      00h
execs ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DOORS		segment	byte public
		assume	cs:DOORS, ds:DOORS

		org	100h
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
drs		proc	far

start:
		jmp	@LoaderStart

@Stack		db	11 dup('DOORS!')   ; Vlastni zasobnik  (66 Bytes)
@StackEnd:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NewInt2F:
		cmp 	ah,99h		   ; 99 - Funkce Doors
		je 	@CompareOk
@Old2F:
		db	0EAh	           ; Skok Na Stary 2F
oldOffset2F	dw 	0000h
oldSegment2F	dw 	0000h
@CompareOk:
		cmp 	al,05h		   	; Jeli Al>5 => stara obsluha
		ja	@Old2F
		je	@GetTemp
		Cmp	Al,04h
		je	@SetTemp
		or	Al,Al
		jne	@GetAddresToBuffer
		
		mov 	ax,cs:[@RunFirst]	; Kontrola pritomnosti v pameti
		mov 	cl,cs:[@ReturnCode]
		mov 	bx,'DO'			; Do Bx dej 'DO' 'DOOR'
		mov 	dx,'OR'			; Do dx dej 'OR'
		iret

@GetAddresToBuffer:				; Sluzba Al - 1
		dec	al
		jnz	@SetRunNext
		mov	ax,cs			; Vrati adresu v ES:BX
		mov	es,ax
		mov	bx,offset @Exit
		iret 			   
@SetRunNext:					; Sluzba Al - 2
		dec	al
		jnz	@SetRunType
		mov	al,cl
		mov	ah,1
		mov	cs:@RunNext,ax
		iret				
@SetRunType:
		mov	cs:@RunType,cl           ; Napln data16 cl
		iret				; Ukonceni preruseni
@SetTemp:
		mov	cs:@Temp1,cx		; Temp1 <- cx
		mov	cs:@Temp2,dx		; Temp2 <- dx
		iret				; Ukonceni preruseni
@GetTemp:
		mov	cx,cs:@Temp1           ; Vrat Do cx Temp1
		mov	dx,cs:@Temp2		; Vrat Do dx Temp2
		xor	ax,ax			
		mov	cs:@Temp1,ax		; Vynuluj Data
		mov	cs:@Temp2,ax
		iret				; Ukonceni preruseni
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
@RunFirst	dw	101h
@RunNext	dw	0
@ReturnCode	db	0
@RunType	db	0
@Temp1		dw	0
@Temp2		dw	0
@RunDoors:
		mov	ax,cs			; Nastav segmentove registry
		mov	ds,ax
		mov	es,ax
		mov	ExecBlock.OffsetCL,80h
		mov	ExecBlock.SegmentCL,ax
		mov	ax,cs:PSPAddres
		mov	ExecBlock.PSPsegment,ax
		mov	dx,offset @ProgramPath  ; ds:dx - jmeno programu
		mov	bx,offset ExecBlock	; es:bx - parametry
		mov	ax,4B00h
		int	21h			; Spusteni Doors!

		jc	@CantRunDoors		; Nelze spustit doors !!
		mov	byte ptr cs:@RunFirst+1,0
		sub	ax,ax
		xchg	ax,cs:@RunNext
		or	ah,ah			
		jnz	@NoTestReturnCode	
		mov	ah,4Dh			
		int	21h			; Zjisti Return Code
						
@NoTestReturnCode:
		cmp	al,1
		jne	@ExitLoader
		mov	ax,3301h
		mov	dl,1
		int	21h			; Zapti testovani CTRL - BREAK
						
		mov	ax,cs                   ; Nastav Segmentove registry
		mov	ds,ax
		mov	es,ax
		sub	ax,ax
		xchg	al,@RunType
		cmp	al,1
		jne	@Run21
		mov	si,offset @exit
		int	2Eh			; Spusteni prikazu dosu
						; Vsechny reg & ss:sp zniceny
		sub	al,al			
		jmp	@EndOfExecute
@Run21:
		mov	al,@exit
		add	al,3
		mov	@param,al
		mov	byte ptr @exit,20h
		mov	bx,offset ExecBlock.PSPsegment
		mov	ExecBlock.OffsetCl,offset @Param
		mov	dx,cs:@SaveDi
		mov	ax,4B00h
		int	21h			; Spusteni programu
						
		mov	ah,4Dh			
		int	21h			; Zjisti return code
						
@EndOfExecute:
		mov	cs:@ReturnCode,al
		mov	ax,3301h
		xor	dl,dl			
		int	21h			; Vypni testovani CTRL-BREAK
						
		jmp	@RunDoors
@CantRunDoors:
		mov	dx,offset @erNotRun	; ('Nelze sputit hlavni prog)
		mov	ah,9
		int	21h			

		mov	al,0FFh
@ExitLoader:
		push	ax
		mov	ax,252Fh
		lds	dx,dword ptr cs:[oldOffset2F]
		int	21h			; Nastav spatky preruseni 2F

		pop	ax
		mov	ah,4Ch			
		int	21h			 
						;  Ukonceni programu
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
@SaveDi		dw	0
@erNotRun	db	'Nelze nalezt DRS.PRG', 0Dh, 0Ah, 07h, '$'
@param		db	' /C'
@exit		db	04h,'exit',0Dh
		db	50 dup ('DOORS')
ExecBlock 	execs   <>
		db	 5Ch, 00h
mySegment	dw	0000h
		db 	6Ch, 00h
mySegment2	dw	0000h
		db 	0Eh
@ProgramPath	db	20 dup ('DOORS!!!')
@RunBuffer	db	10 dup ('DOORS!!!')
AboutProg	db	0Dh,'DOORS! v1.09 (C) 1997/98 David Petrik & Filip Volejnik',0Dh,0Ah,'$'
waAlreadyInMem	db	'VAROVANI: Program je jiz spusten',0Dh,0Ah,'$'
erNoPath	db	'Nenalezena cesta k hlavnimu programu.',0Dh,0Ah,'$'
erNoMemory	db	'Nedostatek pameti.',0Dh,0Ah,'$'
erCOMSPEC	db	'Nelze nalezt COMMAND.COM',0Dh,0Ah,'$'
waHandle	db	'VAROVANI: Prilis mnoho otevrenych souboru, nastavte hodnotu FILES nejmene na 20.',0Dh,0Ah,'$'
waRunInWin	db      'Program je spusten pod Microsoft Windows (R)',0Dh,0Ah,'$'
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
@LoaderStart:
		mov	ah,9
		mov	dx,Offset AboutProg
		int	21h			; Vypis textu o programu

		mov	ah,52h
		int	21h			; Zjisti ukazatel na
						; seznam seznamu => es:bx
		les	bx,dword ptr es:[bx+4]	; Adresa prniho rez. driveru
		sub	ax,ax
@NextDriver:
		add	ax,es:[bx+4]
		cmp	word ptr es:[bx],0FFFFh ; Je tam Null ?
		je	@NoNextDriver		; je
		les	bx,dword ptr es:[bx]
		jmp	short @NextDriver
@NoNextDriver:
		cmp	ax,14h
		jae	@HandleOK
		mov	ah,9
		mov	dx,Offset waHandle       ; Malo volnych handlu
		int	21h
@HandleOk:
		xor	ax,ax			
		mov	es,ax
		mov	bx,MouseInteruptAddr
		mov	ax,es:[bx]
		or	ax,es:[bx+2]		; Je tam nejaka adresa
		jz	@NoMouseDriver		; Jestli ne tak pryc
		xor	ax,ax			
		int	33h			; Je instalovan Ovladac mysi
@NoMouseDriver:
		mov	ah,99h
		sub	al,al
		int	2Fh			; nejsem nahodou uz v pameti
		cmp	bx,'DO'
		jne	@NoInMemory		; jeste ne 
		mov	dx,offset waAlreadyInMem
		mov	ah,9
		int	21h
@NoInMemory:
		mov 	ax,01600h
		int     2Fh
		cmp     al,00h
		je      @NoRunWindows
		cmp     al,80h
		je      @NoRunWindows
		mov	dx,offset waRunInWin
		mov	ah,9
		int	21h

@NoRunWindows:		
		mov	ax,352Fh
		int	21h			; Zjisti stare preruseni 2F
		mov	ds:[OldOffset2F],bx
		mov	ds:[OldSegment2F],es
		mov	dx,offset NewInt2F
		mov	ah,25h			; Nastav nove preruseni 2F
		int	21h
		mov	ax,cs
		mov	es,ax
		mov	ds:[mySegment],ax
		mov	ds:[mySegment2],ax
		cld				
		mov	ax,cs:PSPAddres
		mov	ds,ax
		mov	cx,Max
		xor	si,si			

		cld				
		mov	ax,cs:PSPAddres
		mov	ds,ax
		mov	cx,Max
		xor	si,si			; Vynuluj si
@SearchNext:
		push	si
		lodsw				; Loadni [si] do ax
		cmp	ax,4F43h		; Je v ax 'CO' ?
		jne	@NotCOMSPEC		; Neni tak hledej znovu
		lodsw				; Loadni [si] do ax
		cmp	ax,534Dh		; Je v ax 'MS' ?
		jne	@NotCOMSPEC		; Neni tak hledej znovu
		lodsw				; Loadni [si] do ax
		cmp	ax,4550h		; Je v ax 'PE' ?
		jne	@NotCOMSPEC		; Neni tak hledej znovu
		lodsw				; Loadni [si] do ax
		cmp	ax,3D43h		; Je v Ax 'C='
		jne	@NotCOMSPEC		; Neni tak hledej znovu
		mov	di,offset @RunBuffer
                
		@@CopyData			; Macro !!!!                

		pop	ax
		dec	si
		jmp	short @COSPECSearched
@NotCOMSPEC:
		pop	si

		@@SearchStringEnd

		cmp	si,max			; NENALEZENO COMSPEC =
		jb	@SearchNext
		mov	dx,offset erCOMSPEC     ; Do Dx Offset erCOMSPEC
		jmp	@WriteText
@ErrorFindPath:
		jmp	@WriteNoPath		; Vypis Nenalezena Cesta
@COSPECSearched:
		mov	di,offset @ProgramPath

@SearchDoubleZero:
		lodsb			        ; Loadni [si] do al
	        or	  al,[si]			
	        loopnz @SearchDoubleZero        ; Al = 0 ? Ne Tak Opakuj

		jcxz	@ErrorFindPath		; Nelze nalezt cestu
		lodsw				; Loadni [si] do ax
		lodsb				; Loadni [si] do al

@Copy:						; Zvlastni Kopirovani
		lodsb				 
		stosb				 
		or	al,al			
		jnz	@Copy			
		
		sub	di,4
		mov	ax,'RP'			; Do Ax Dej 'PR'
		stosw				; Uloz ax do es:[di]
		mov	al,'G'			; Do Ax dej 'G'
		stosb				; Uloz al do es:[di]
		inc	di
		mov	ax,cs
		mov	ds,ax
		mov	@SaveDi,di
		mov	si,offset @RunBuffer

		@@CopyData

		inc	di
		mov	ax,cs
		mov	ss,ax
		mov	sp,Offset @StackEnd     ; Nastaveni Zasobniku
		mov	bx,di
		add	bx,10h
		mov	cl,4
		shr	bx,cl			; Bx vydel 4
		mov	ah,4Ah			; Realokuj pamet
		int	21h			 
						
		jc	@NoMem			; Chyba neni pamet ->
		jmp	@RunDoors
@WriteNoPath:
		mov	dx,Offset erNoPath
		jmp	short @WriteText
@NoMem:
		mov	dx,offset erNoMemory	;Neni pamet
@WriteText:
		mov	ah,9
		int	21h			; Vypis Text
						
		mov	ax,252Fh
		lds	dx,dword ptr cs:[OldOffset2F]
		int	21h			; Nastav spatky 2F
						
		mov	ax,4C01h
		int	21h			; Ukonceni programu
						; Al=1 

drs		endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DOORS		ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		end	start
