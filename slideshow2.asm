;
ORG #A000
RUN start ; 
startApp    

pri equ #6800
splt equ pri+1
ssa equ pri+2
sscr equ pri+4
dscr equ #6C0F

; load l'image en #170
; 
; memory #9FFFF
; load"monloader",#a0000
; call #a000



start 
	
	
; sauvergarde des interruptions
	DI
	LD HL,#38
	LD DE,inter+1
	LDI:	LDI
	LD HL,#C9FB
	LD (#38),HL
	LD (pile+1),sp

	EXX:	EX AF,AF'
	PUSH AF:	PUSH BC
	PUSH DE:	PUSH HL
	
	CALL delock
	
; mode 0 
	LD   BC,#7F8C ; mode 0
	OUT  (C),C

; formatage de l'écran 
	LD HL,#0130 ; r1 = 48 overscan 96 octets de large
	CALL crtc
	LD HL,#0232 ; r2 = 50
	CALL crtc
	LD HL,#0622 ; r6 = #22
	CALL crtc
	LD HL,#0723 ; r7 = #23
	CALL crtc
	LD HL,#0C0D ; r12 = #0D
	CALL crtc 
	LD HL,#0D00 ; r13 = 0
	CALL crtc 

	
	EI
	CALL initAmsdos
	CALL nextFile
;
; Boucle principale de la demo
;
main 
;

	LD B,#F5
	IN A,(C)
	RRA
	JR NC,main+2

	call asicon
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
	LD (pri),A; pri
	EI 
	HALT
	LD (splt),A; splt
	LD HL,#0010
	LD (ssa),HL; ssa
;       
	call asicoff

;
space	LD BC,#F40E
	OUT (C),C
	LD BC,#F6C0
	OUT (C),C
    DW #71ED        ; OUT (c),0
	LD BC,#F792
	OUT (C),C
	LD BC,#F645
	OUT (C),C
	LD B,#F4
	IN A,(C)
	LD BC,#F782
	OUT (C),C
	BIT 7,A
	brk
	JP NZ,main
	CALL nextFile
	JP main
; quit the program

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
	LD (pri),A; pri a zero
	LD (splt),A; splt a zero
	LD (dscr),A; dcsr a zero;
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


; initialize amsdos rom
; to access to drive 	
initAmsdos
	LD hl,(#be7d); recup du numero de lecteur dans a
	LD a,(hl)
    PUSH af
	LD c,7 ; init rom 7
	LD de,#40
	LD hl,#abff
	CALL #bcce
	POP af
	LD hl,(#be7d) ; restit du numero de lecteur
	LD (hl),a
RET

; loadFile rOUTine. 
; HL contains the filename.
; B contains the filename size. 
; DE contains the ADDress where to store the file content.
loadFile
	;LD HL,nom
	;LD B,fin-nom
	PUSH DE
	CALL #bc77
	POP DE : LD HL,DE
	CALL #bc83 ; load all the file in memory
	CALL #bc7a ; close the file
RET 


; nextFile rOUTine
; 
nextFile
; first part of the image must be loaded in C5 bank OUT &7F00,&C5 : LOAD"coca.go1",&4000
; second part of the image must be loaded in C0 bank OUT &7F00,&C0 : LOAD"coca.go2",&4000

selectFilePtr	LD hl,ScreenFilename
	PUSH hl ; pointer of the first filename
	LD bc, #7fc4 ; switch bank c4
	OUT (c),c 
	LD de,#4000 ; will store the content file in #4000
	LD b,5 ; filenameSize
	CALL loadFile

	POP hl
	LD A,5
	ADD A,L ; pointer of the second filename
	LD L,A
	PUSH hl
	LD bc, #7fc0 ; switch bank c0
	OUT (c),c
	LD de,#4000 ; will store the content file in #4000
	LD b,5  ; filenameSize

	CALL loadFile

	POP hl
	LD A,5
	ADD A,L ; pointer of the next filename
	LD L,A
	XOR a 
	LD b,(hl)
	CP b 

	JP nz, resetScreenPtr
	LD hl,ScreenFilename
resetScreenPtr	LD (selectFilePtr+1),hl ; store the new file to the next rOUTine CALL

	LD BC,#7FC4 
	OUT (C),C
	LD HL,#4000
	LD DE,#C000
	LD BC,#3FFF
	LDIR

	LD BC,#7FC0
	OUT (C),C

	CALL asicon
	LD C,#8C; mode 0
	OUT (C),C


	; load the palette
PalettePtr	LD hl,Palettes
	LD DE,#6400
	LD BC,#20
	LDIR
	LD a,(hl)
	CP #FF
	JP nz, dontResetPalettePtr
	LD hl,Palettes
dontResetPalettePtr	LD (PalettePtr+1),hl
	CALL asicoff
RET 

ScreenFilename
	DB '1.GO1', '1.GO2', '2.GO1', '2.GO2', '3.GO1', '3.GO2'
	DB '4.GO1', '4.GO2', '5.GO1', '5.GO2', 0
Palettes
	DW Palette1, Palette2, Palette3, Palette4, Palette5,#ff
filenameSize 
	DB 5

Palette1
    db #00, #00, #90, #00, #09, #00, #00, #09, #90, #09, #F0, #09, #09, #09, #F0, #00
	db #99, #00, #99, #09, #99, #0F, #F9, #0F, #9F, #09, #9F, #0F, #F9, #09, #FF, #0F
Palette2
	db #00, #00, #C0, #06, #C0, #09, #33, #03, #63, #09, #06, #03, #90, #00, #F3, #03
	db #03, #00, #0C, #06, #33, #03, #F3, #09, #C9, #09, #FC, #0C, #F3, #0C, #F9, #0C
Palette3
	db #00, #00, #33, #03, #33, #03, #63, #06, #30, #03, #63, #06, #33, #06, #33, #03
	db #93, #09, #93, #09, #00, #03, #63, #06, #F9, #0F, #33, #03, #63, #06, #93, #09
Palette4
	db #00, #00, #30, #00, #33, #03, #63, #03, #63, #06, #66, #06, #66, #06, #96, #09
	db #F6, #09, #F6, #09, #F6, #0C, #F9, #0C, #F9, #0C, #FC, #0F, #FC, #0F, #F9, #0F
Palette5
	db #FF, #0F, #00, #00, #CF, #0C, #66, #06, #CC, #0C, #69, #06, #33, #00, #FC, #0C
	db #66, #06, #CC, #0C, #33, #03, #9C, #09, #03, #00, #FF, #0F, #36, #03, #00, #00

; delock asic functions
delock
	LD HL,asic_seq
	LD BC,#BD11
loopDelock	OUTI
	INC B
	DEC C
	JP NZ,loopDelock
RET 

; asic delock sequence
asic_seq
    DB 255,0,255,119,179,81,168,212
    DB 98,57,156,70,43,21,138,205,238

; enable asic feature
asicon
	LD BC,#7FC0
	LD A,#B8
	OUT (C),C
	OUT (C),A
RET 

; diseable asic feature 
asicoff
	LD BC,#7FA0
	OUT (C),C
RET 

endApp 

SAVE'disc.bin',#A000,endApp-startApp,DSK,'martine-slideshow.dsk'
