PAGE  59,132

MouseIntAddr	equ	0CCh
Max		equ	8000h			
psp_envirn_seg	equ	2Ch

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

dn		proc	far

start:
		jmp	LoaderStart
		db	'ssssssssssssssssssssssssssssssss'
		db	'sssssssssssssssssssssssssssssss'

NewInt2F:
		cmp 	ah,99h
		je 	@CompareOk
Old2F:
		db	0EAh	;Skok Na Stary 2F
oldOffset2F	dw 	0000h
oldSegment2F	dw 	0000h
@CompareOk:	
		cmp 	al,06h
		ja	Old2F
		je	Loc_10
		cmp	al,05h
		je	Loc_9
		Cmp	Al,04h
		je	Loc_8
		or	Al,Al
		jne	Loc_5
		mov 	ax,cs:[Data_11]
		mov 	cl,cs:[Data_15]
		mov 	bx,0444Eh
		mov 	dx,02141h
		iret
	
loc_5:
		dec	al
		jnz	loc_6			; Jump if not zero
		mov	ax,cs
		mov	es,ax
		mov	bx,295h
		iret				; Interrupt return
loc_6:
		dec	al
		jnz	loc_7			; Jump if not zero
		mov	al,cl
		mov	ah,1
		mov	cs:data_14,ax
		iret				; Interrupt return
loc_7:
		mov	cs:data_16,cl
		iret				; Interrupt return
loc_8:
		mov	cs:data_17,cx
		mov	cs:data_18,dx
		iret				; Interrupt return
loc_9:
		mov	cx,cs:data_17
		mov	dx,cs:data_18
		xor	ax,ax			; Zero register
		mov	cs:data_17,ax
		mov	cs:data_18,ax
		iret				; Interrupt return
loc_10:
		mov	cx,cs:data_19
		xor	ax,ax			; Zero register
		test	dx,8000h
		jz	loc_ret_11		; Jump if zero
		mov	cs:data_19,dx

loc_ret_11:
		iret				; Interrupt return
		db	 44h, 4Eh
data_11		dw	101h
		db	0
data_14		dw	0
data_15		db	0
data_16		db	0
data_17		dw	0
data_18		dw	0
data_19		dw	0
loc_12:
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		mov	data_26,80h
		mov	data_27,ax
		mov	ax,cs:psp_envirn_seg
		mov	data_25,ax
		mov	dx,offset data_28
		mov	bx,offset data_25
		mov	ax,4B00h
		int	21h			; DOS Services  ah=function 4Bh
						;  run progm @ds:dx, parm @es:bx
		jc	loc_16			; Jump if carry Set
		mov	byte ptr cs:data_11+1,0
		sub	ax,ax
		xchg	ax,cs:data_14
		or	ah,ah			; Zero ?
		jnz	loc_13			; Jump if not zero
		mov	ah,4Dh			; 'M'
		int	21h			; DOS Services  ah=function 4Dh
						;  get return code info in ax
loc_13:
		cmp	al,1
		jne	loc_17			; Jump if not equal
		mov	ax,3301h
		mov	dl,1
		int	21h			; DOS Services  ah=function 33h
						;  set ctrl-break flag dl=off/on
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		sub	ax,ax
		xchg	al,data_16
		cmp	al,1
		jne	loc_14			; Jump if not equal
		mov	si,offset data_23
		int	2Eh			; Execute DOS command at DS:SI
						;  all regs & ss:sp destroyed
		sub	al,al
		jmp	short loc_15
loc_14:
		mov	al,data_23
		add	al,3
		mov	data_22,al
		mov	byte ptr data_23,20h	; ' '
		mov	bx,offset data_25
		mov	data_26,292h
		mov	dx,cs:data_20
		mov	ax,4B00h
		int	21h			; DOS Services  ah=function 4Bh
						;  run progm @ds:dx, parm @es:bx
		mov	ah,4Dh			; 'M'
		int	21h			; DOS Services  ah=function 4Dh
						;  get return code info in ax
loc_15:
		mov	cs:data_15,al
		mov	ax,3301h
		xor	dl,dl			; Zero register
		int	21h			; DOS Services  ah=function 33h
						;  set ctrl-break flag dl=off/on
		jmp	loc_12
loc_16:
		mov	dx,offset data_21	; ('Not able to run DN.PRG')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		mov	al,0FFh
loc_17:
		push	ax
		mov	ax,252Fh
		lds	dx,dword ptr cs:[148h]	; Load 32 bit ptr
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		pop	ax
		mov	ah,4Ch			; 'L'
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
data_20		dw	0
data_21		db	'Not able to run DN.PRG', 0Dh, 0Ah
		db	7, '$'
data_22		db	20h
		db	 2Fh, 43h
data_23		db	4
		db	 65h, 78h, 69h, 74h, 0Dh
		db	247 dup (0FAh)
data_25		dw	0
data_26		dw	80h
data_27		dw	0
		db	 5Ch, 00h
mySegment	dw	0000h
		db 	6Ch, 00h
mySegment2	dw	0000h
		db 	0Eh
data_28		dw	80 dup (0)
data_29		db	0
		db	79 dup (0)
AboutProg	db	0Dh, 'Dos Navigator  Version 1.42'
		db	'  Copyright (C) 1991,96 RIT Research Labs'
                db      0Dh, 0Ah, '$'
erA		db	'(*)', 0Dh, 0Ah, '$'
erNoPath	db	'No path to main file.', 0Dh, 0Ah
		db	'$'
data_31		db	'Not enough memory.', 0Dh, 0Ah, '$'
		db	'Cannot find COMSPEC variable.', 0Dh
		db	0Ah, '$'
erFILES		db	'WARNING: Not enough file handles'
		db	'. Set at least FILES=20 in your '
		db	'CONFIG.SYS file.', 0Dh, 0Ah, '$'
data_32		db	'Unable to create flag file '
SetData		dw	40 dup (0)
data_34		dw	0

LoaderStart:
		mov	ah,9
		mov	dx,Offset AboutProg
		int	21h			; Vypis textu o programu

		mov	ah,52h
		int	21h			; Zjisti ukazatel na
						; seznam seznamu => es:bx
		les	bx,dword ptr es:[bx+4]	; Adresa prniho rez. driveru
		sub	ax,ax
NextDriver:
		add	ax,es:[bx+4]
		cmp	word ptr es:[bx],0FFFFh ; Je tam Null ?
		je	NoNextDriver		; je
		les	bx,dword ptr es:[bx]	
		jmp	short NextDriver
NoNextDriver:
		cmp	ax,14h
		jae	HandlesOK			
		mov	ah,9
		mov	dx,Offset erFiles
		int	21h			; Malo volnych handlu
						
HandlesOk:
		xor	ax,ax			
		mov	es,ax
		mov	bx,MouseIntAddr
		mov	ax,es:[bx]
		or	ax,es:[bx+2]		; Je tam nejaka adresa
		jz	NoMouseDriver		; Jestli ne tak pryc
		xor	ax,ax			
		int	33h			; Je instalovan Ovladac mysi
NoMouseDriver:
		mov	ah,99h
		sub	al,al
		int	2Fh			; nejsem nahodou uz v pameti
		cmp	bx,444Eh
		jne	NoInMemory		; jeste ne 
		mov	dx,offset erA			
		mov	ah,9
		int	21h			; Vypis Text
NoInMemory:
		mov	ax,352Fh
		int	21h			; Zjisti stare preruseni 2F
						;
		mov	ds:[OldOffset2F],bx
		mov	ds:[OldSegment2F],es
		mov	dx,offset NewInt2F		
		mov	ah,25h			; Nastav nove preruseni 2F
		int	21h			; 
		
		mov	ax,cs
		mov	es,ax
		mov	ds:[mySegment],ax
		mov	ds:[mySegment2],ax
		cld				
		mov	ax,cs:PSP_envirn_seg
		mov	ds,ax
		mov	cx,8000h
		xor	si,si			
FindNext:
		push	si
		lodsw				; Loadni word
		cmp	ax,4E44h		; Je tam DN
		jne	@NotSetSwapPath		; Promena neni nastavena
		lodsw				; Loadni word
		cmp	ax,5753h		; je tam SW
		je	@SetSwapPath		; Jestli jo tak
		sub	si,2
		lodsb				 
		cmp	al,3Dh			; '='
		jne	@NotSetSwapPath		
		pop	ax
		jmp	@SaveData		; DN=???
		db	90h
@SetSwapPath:
		lodsw				;
		cmp	ax,3D50h		; je tam P=
		jne	@NotSetSwapPath		
		pop	ax
		jmp	@SaveData
		db	90h
@NotSetSwapPath:
		pop	si

@FindZero:
		lodsb				; Loadni Byte
		or	al,al			
		loopnz	@FindZero		

		cmp	byte ptr [si],0
		je	@EndOfSets			
		cmp	si,max
		jb	FindNext		
@EndOfSets:
		jmp	short loc_35
		db	90h
@SaveData:
		mov	di,offset SetData

locloop_33:
		lodsb				; String [si] to al
		stosb				; Store al to es:[di]
		or	al,al			; Zero ?
		loopnz	locloop_33		; Loop if zf=0, cx>0

		dec	di
		cmp	byte ptr es:[di-1],5Ch	; '\'
		jne	loc_34			; Jump if not equal
		dec	di
loc_34:
		mov	ax,445Ch
		stosw				; Store ax to es:[di]
		mov	ax,2E4Eh
		stosw				; Store ax to es:[di]
		mov	ax,4C46h
		stosw				; Store ax to es:[di]
		mov	al,47h			; 'G'
		mov	ah,0
		stosw				; Store ax to es:[di]
loc_35:
		cld				; Clear direction
		mov	ax,cs:psp_envirn_seg
		mov	ds,ax
		mov	cx,8000h
		xor	si,si			; Zero register
loc_36:
		push	si
		lodsw				; String [si] to ax
		cmp	ax,4F43h
		jne	loc_38			; Jump if not equal
		lodsw				; String [si] to ax
		cmp	ax,534Dh
		jne	loc_38			; Jump if not equal
		lodsw				; String [si] to ax
		cmp	ax,4550h
		jne	loc_38			; Jump if not equal
		lodsw				; String [si] to ax
		cmp	ax,3D43h
		jne	loc_38			; Jump if not equal
		mov	di,offset data_29

locloop_37:
		lodsb				; String [si] to al
		stosb				; Store al to es:[di]
		or	al,al			; Zero ?
		loopnz	locloop_37		; Loop if zf=0, cx>0

		pop	ax
		dec	si
		jmp	short loc_41
		db	90h
loc_38:
		pop	si

locloop_39:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		loopnz	locloop_39		; Loop if zf=0, cx>0

		cmp	si,max
		jb	loc_36			; Jump if below
		mov	dx,50Ch
		jmp	loc_53
loc_40:
		jmp	loc_51
loc_41:
		mov	di,offset data_28

locloop_42:
		lodsb				; String [si] to al
		or	al,[si]
		loopnz	locloop_42		; Loop if zf=0, cx>0

		jcxz	loc_40			; Jump if cx=0
		lodsw				; String [si] to ax
		lodsb				; String [si] to al
loc_43:
		lodsb				; String [si] to al
		stosb				; Store al to es:[di]
		or	al,al			; Zero ?
		jnz	loc_43			; Jump if not zero
		sub	di,4
		mov	ax,5250h
		stosw				; Store ax to es:[di]
		mov	al,47h			; 'G'
		stosb				; Store al to es:[di]
		inc	di
		mov	ax,cs
		mov	ds,ax
		mov	data_20,di
		mov	si,offset data_29

locloop_44:
		lodsb				; String [si] to al
		stosb				; Store al to es:[di]
		or	al,al			; Zero ?
		loopnz	locloop_44		; Loop if zf=0, cx>0

		inc	di
		push	di
		mov	si,offset data_28
		mov	di,offset Setdata
		cmp	word ptr es:[di],0
		jne	loc_46			; Jump if not equal
		cld				; Clear direction
loc_45:
		lodsb				; String [si] to al
		stosb				; Store al to es:[di]
		or	al,al			; Zero ?
		jnz	loc_45			; Jump if not zero
		sub	di,4
		mov	ax,4C46h
		stosw				; Store ax to es:[di]
		mov	al,47h			; 'G'
		stosb				; Store al to es:[di]
loc_46:
		mov	dx,offset Setdata
		mov	ax,3D42h
		int	21h			; DOS Services  ah=function 3Dh
						;  open file, al=mode,name@ds:dx
		mov	data_34,ax
		jnc	loc_48			; Jump if carry=0
		mov	ah,3Ch			; '<'
		sub	cx,cx
		int	21h			; DOS Services  ah=function 3Ch
						;  create/truncate file @ ds:dx
		mov	data_34,ax
		jnc	loc_49			; Jump if carry=0
		mov	si,offset Setdata
loc_47:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jnz	loc_47			; Jump if not zero
		mov	word ptr [si-1],0A0Dh
		mov	byte ptr [si+1],24h	; '$'
		mov	dx,offset data_32	; ('Unable to create flag fi')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		jmp	short loc_50
		db	90h
loc_48:
		mov	bx,data_34
		mov	cx,1
		mov	dx,offset data_11
		mov	ah,3Fh			; '?'
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		inc	byte ptr data_11
loc_49:
		mov	bx,data_34
		mov	ax,4200h
		sub	cx,cx
		mov	dx,cx
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		mov	bx,data_34
		mov	ah,40h			; '@'
		mov	dx,offset data_11
		mov	cx,1
		mov	ah,40h			; '@'
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		mov	bx,data_34
		mov	ah,3Eh			; '>'
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
loc_50:
		pop	di
		mov	ax,cs
		mov	ss,ax
		mov	sp,140h
		mov	bx,di
		add	bx,10h
		mov	cl,4
		shr	bx,cl			; Shift w/zeros fill
		mov	ah,4Ah			; 'J'
		int	21h			; DOS Services  ah=function 4Ah
						;  change memory allocation
						;   bx=bytes/16, es=mem segment
		jc	loc_52			; Jump if carry Set
		jmp	loc_12
loc_51:
		mov	dx,4DFh
		jmp	short loc_53
		db	90h
loc_52:
		mov	dx,offset data_31	; ('Not enough memory.')
loc_53:
		mov	ah,9
		int	21h			; Vypis Text
						
		mov	ax,252Fh
		lds	dx,dword ptr cs:[OldOffset2F]
		int	21h			; Nastav spatky 2F
						
		mov	ax,4C01h
		int	21h			; Ukonceni programu
						; Al=1 

dn		endp

seg_a		ends



		end	start
