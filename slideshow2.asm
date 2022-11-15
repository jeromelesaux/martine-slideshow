;
nolist
RUN start ;  pour winape
startApp    

pri equ #6800
sscr equ pri+4
splt equ pri+2

ORG #800

start 

	DI
	LD HL,#38
	LD DE,inter+1
	LDI:	LDI
	LD HL,#C9FB
	LD (#38),HL
	LD (pile+1),sp
;

	EXX:	EX AF,AF'
	PUSH AF:	PUSH BC
	PUSH DE:	PUSH HL

	IM 1

	CALL delock

;
	LD HL,#0130
	CALL crtc
	LD HL,#0232
	CALL crtc
	LD HL,#0622
	CALL crtc
	LD HL,#0723
	CALL crtc
; first part of the image must be loaded in C5 bank OUT &7F00,&C5 : LOAD"coca.go1",&4000
; second part of the image must be loaded in C0 bank OUT &7F00,&C0 : LOAD"coca.go2",&4000
	LD BC,#7FC5 
	OUT (C),C
	LD HL,#4000
	LD DE,#C000
	LD BC,#4000
	LDIR

	LD BC,#7FC0
	OUT (C),C
;
	LD HL,#c000; on efface la ligne impdraw
	LD DE,#c001; qui contient la zone 0-#40
	LD BC,#40; dans la partie haute de l'ecran
	LD (HL),L
	LDIR
;
	CALL asicon
	LD C,#8C; mode 0
	OUT (C),C
;  
	LD HL,palette1
	LD DE,#6400
	LD BC,#20
	LDIR
	LD HL,#00
	LD (#6420),HL

	CALL asicoff
	EI
;
; Boucle principale de la de?mo
;
main
	LD B,#F5
	IN A,(C)
	RRA
	JR NC,main+2

	CALL asicon
;                  
; Premiere partie de l'image en #c000
;

	LD HL,#3000
	LD BC,#BC0C
	OUT (C),C
	INC B
	OUT (C),H
	DEC B
	INC C
	OUT (C),C
	INC B
	OUT (C),L
;
	
;         
;   Deuxieme partie PAGE ecran  en #4000 (BANK #c0)
;
	LD A,167
	LD (#6800),A; pri
	LD (#6801),A; splt
	LD HL,#10
	LD (#6802),HL; ssa
;       
	CALL asicoff

;
space	LD BC,#F40E
	OUT (C),C
	LD BC,#F6C0
	OUT (C),C
    DW #71ED        ; out (c),0
	LD BC,#F792
	OUT (C),C
	LD BC,#F645
	OUT (C),C
	LD B,#F4
	IN A,(C)
	LD BC,#F782
	OUT (C),C
	BIT 7,A
	JP NZ,main
;
	DI
inter  

	LD HL,0
	LD (#38),HL
;

	POP HL:	POP DE
	POP BC:	POP AF
	EXX:	EX AF,AF'
;
pile	LD sp,0
;
	LD HL,#C000
	LD DE,#C001
	LD BC,#3FFF
	LD (HL),L
	LDIR
;                       
; Reinit des regiSTRes crtc utilises
;
	LD HL,#0128
	CALL crtc
	LD HL,#022E
	CALL crtc
	LD HL,#0619
	CALL crtc
	LD HL,#071E
	CALL crtc
	LD HL,#0C30
	CALL crtc
	LD HL,#0D00
	CALL crtc
;                    
	CALL #BCA7
;
	CALL asicon
	XOR A
	LD (#6800),A; pri a zero
	LD (#6801),A; splt a zero
	LD (#6C0F),A; dcsr a zero;
	LD (sscr),A; sscr a Z
;
; All Sprites Hard OFF
;
	LD HL,#6004
	LD DE,8
	LD B,16
loop_spr	LD (HL),D
	ADD HL,DE
	DJNZ loop_spr
;

	CALL asicoff
	EI
	RET 
;
crtc	LD B,#BC
	OUT (C),H
	INC B
	OUT (C),L
	RET 


; loadFile routine 
; HL contains the filename
; B contains the filename size
; DE contains the address where to store the file content
loadFile
	;LD HL,nom
	;LD B,fin-nom
	CALL #bc77
	LD HL,DE
	CALL #bc83
	CALL #bc7a
	RET 

; nextFile routine
; 
nextFile
selectFilePtr	ld hl,ScreenFilename
	push hl ; pointer of the first filename
	ld bc, #7fc5 ; switch bank c5
	out (c),c 
	ld de,#4000 ; will store the content file in #4000
	ld b,6 ; filenameSize
	call loadFile

	pop hl
	ld de,6
	add hl,de ; pointer of the second filename

	push hl
	ld bc, #7fc0 ; switch bank c0
	out (c),c
	ld de,#4000 ; will store the content file in #4000
	ld b,6  ; filenameSize
	call loadFile

	pop hl
	ld de,6
	add hl,de ; pointer of the next filename
	xor a 
	ld b,(hl)
	cp b 
	jp nz, resetScreenPtr
	ld hl,ScreenFilename
resetScreenPtr	ld (selectFilePtr+1),hl ; store the new file to the next routine call

ret 

ScreenFilename
	DW '1-1.GO', '1-2.GO', '2-1.GO', '2-2.GO', 0 
PaletteFilename
	DW palette1,PaletteFilename
filenameSize 
	DB 6

palette1
      DB #00,#00,#40,#00,#60,#00,#90,#00
      DB #B0,#00,#D0,#00,#F0,#00,#22,#02
      DB #90,#06,#B0,#09,#B2,#09,#D2,#0B
      DB #F4,#0D,#F6,#0D,#F6,#0F,#F9,#0F
;
delock
	LD HL,asic_seq
	LD BC,#BD11
	OUTI
	INC B
	DEC C
	Jp NZ,main
	RET 
;
asic_seq
      DB 255,0,255,119,179,81,168,212
      DB 98,57,156,70,43,21,138,205,238
;
asicon
	LD BC,#7FC0
	LD A,#B8
	OUT (C),C
	OUT (C),A
	RET 
asicoff
	LD BC,#7FA0
	OUT (C),C
	RET 

endApp 

SAVE'disc.bin',#800,endApp-startApp,DSK,'martine-slideshow.dsk'
