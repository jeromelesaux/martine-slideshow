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
	

	CALL asicoff
	EI
;
; Boucle principale de la de?mo
;
main
	call nextFile

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


; loadFile routine. 
; HL contains the filename.
; B contains the filename size. 
; DE contains the address where to store the file content.
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
	ld b,5 ; filenameSize
	call loadFile

	pop hl
	ld de,5
	add hl,de ; pointer of the second filename

	push hl
	ld bc, #7fc0 ; switch bank c0
	out (c),c
	ld de,#4000 ; will store the content file in #4000
	ld b,5  ; filenameSize
	call loadFile

	pop hl
	ld de,5
	add hl,de ; pointer of the next filename
	xor a 
	ld b,(hl)
	cp b 
	jp nz, resetScreenPtr
	ld hl,ScreenFilename
resetScreenPtr	ld (selectFilePtr+1),hl ; store the new file to the next routine call

	call asicon
	LD C,#8C; mode 0
	OUT (C),C


	; load the palette
PalettePtr	ld hl,Palettes
	LD DE,#6400
	LD BC,#20
	LDIR
	ld a,(hl)
	cp #FF
	jp nz, dontResetPalettePtr
	ld hl,Palettes
dontResetPalettePtr	ld (PalettePtr+1),hl
	call asicoff
ret 

ScreenFilename
	DW '1.GO1', '1.GO2', '2.GO1', '2.GO2', '3.GO1', '3.GO2'
	DW '4.GO1', '4.GO2', '5.GO1', '5.GO2', 0
Palettes
	DW DDLMPalette, DIAPalette, HULKPalette, RAAGPalette, SKJOKPalette,#ff
filenameSize 
	DB 5

DDLMPalette
    db #00, #00, #90, #00, #09, #00, #00, #09, #90, #09, #F0, #09, #09, #09, #F0, #00
	db #99, #00, #99, #09, #99, #0F, #F9, #0F, #9F, #09, #9F, #0F, #F9, #09, #FF, #0F
DIAPalette
	db #00, #00, #00, #00, #03, #00, #33, #03, #F3, #03, #63, #09, #90, #00, #C0, #06
	db #F3, #09, #F3, #0C, #06, #03, #C9, #09, #0C, #06, #C0, #09, #F9, #0C, #FC, #0C
HULKPalette
	db #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00
	db #00, #00, #00, #03, #30, #03, #33, #03, #33, #06, #63, #06, #93, #09, #F9, #0F
RAAGPalette
	db #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #30, #00, #33, #03, #63, #03
	db #63, #06, #66, #06, #96, #09, #F6, #09, #F6, #0C, #F9, #0C, #F9, #0F, #FC, #0F
SKJOKPalette
	db #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #03, #00, #33, #00, #33, #03
	db #36, #03, #66, #06, #69, #06, #9C, #09, #CC, #0C, #FC, #0C, #CF, #0C, #FF, #0F

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
