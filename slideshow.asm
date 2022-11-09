;
nolist
run start ;  pour winape
startApp    

pri equ #6800
sscr equ pri+4
splt equ pri+2

org #800

start 

          di
          ld hl,#38
          ld de,inter+1
          ldi:ldi
          ld hl,#C9FB
          ld (#38),hl
          ld (pile+1),sp
;

          exx:ex af,af'
          push af:push bc
          push de:push hl

	im 1
;                     
; initialisation Musique
;        
        
         

	call delock
        
;
          ld hl,#0130
          call crtc
          ld hl,#0232
          call crtc
          ld hl,#0622
          call crtc
          ld hl,#0723
          call crtc
;
          ld bc,#7FC5
          out (c),c
          ld hl,#4000
          ld de,#C000
          ld bc,#4000
          ldir
          ld bc,#7FC0
          out (c),c
;
	ld hl,#c000 ; on efface la ligne impdraw
	ld de,#c001 ; qui contient la zone 0-#40
	ld bc,#40 ; dans la partie haute de l'ecran
	ld (hl),l
	ldir
;
          call asicon
	ld c,#8C      ; mode 0
          out (c),c
;  
        ld hl,pal_coca
          ld de,#6400
          ld bc,#20
          ldir
          ld hl,#00
          ld (#6420),hl

	call asicoff 
          ei       
;
; Boucle principale de la de?mo
;
main
	ld b,#F5
	in a,(c)
	rra
	jr nc,main+2

	call asicon
;                  
; Premiere partie de l'image en #c000
;

          ld hl,#3000
          ld bc,#BC0C
          out (c),c
          inc b
          out (c),h
          dec b
          inc c
          out (c),c
          inc b
          out (c),l
;
	call makeondulation
	
;         
;   Deuxieme partie page ecran  en #4000 (bank #c0)
;
          ld a,167
          ld (#6800),a  ; pri
          ld (#6801),a  ; splt
          ld hl,#10
          ld (#6802),hl ; ssa   
;       
          call asicoff        
		
;
space     ld bc,#F40E
          out (c),c
          ld bc,#F6C0
          out (c),c
      DW #71ED        ; out (c),0
          ld bc,#F792
          out (c),c
          ld bc,#F645
          out (c),c
          ld b,#F4
          in a,(c)
          ld bc,#F782
          out (c),c
          bit 7,a
          jp nz,main
;
exit      di
inter  

         ld hl,0
          ld (#38),hl
;

          pop hl:pop de
          pop bc:pop af
          exx:ex af,af'
;
pile      ld sp,0
;
          ld hl,#C000
          ld de,#C001
          ld bc,#3FFF
          ld (hl),l
          ldir
;                       
; Reinit des registres crtc utilises
;
          ld hl,#0128
          call crtc
          ld hl,#022E
          call crtc
          ld hl,#0619
          call crtc
          ld hl,#071E
          call crtc
          ld hl,#0C30
          call crtc
          ld hl,#0D00
          call crtc
;                    
          call #BCA7
;
          call asicon
          xor a
          ld (#6800),a  ; pri a zero
          ld (#6801),a  ; splt a zero
          ld (#6C0F),a  ; dcsr a zero;
	ld (sscr),a ; sscr a Z
;
; All Sprites Hard OFF
;
	ld hl,#6004
	ld de,8
	ld b,16
loop_spr ld (hl),d 
	add hl,de
	djnz loop_spr
;

          call asicoff
          ei
          ret
;
crtc      ld b,#BC
          out (c),h
          inc b
          out (c),l
          ret

loadFile
Ld hl,nom
Ld b,fin-nom
Call #bc77
Ld hl,startadr 
Call #bc83
Call #bc7a
Ret
Nom defb « toto.bin »
Fin



pal_coca
      DB #00,#00,#40,#00,#60,#00,#90,#00
      DB #B0,#00,#D0,#00,#F0,#00,#22,#02
      DB #90,#06,#B0,#09,#B2,#09,#D2,#0B
      DB #F4,#0D,#F6,#0D,#F6,#0F,#F9,#0F
;
delock
          ld hl,asic_seq
          ld bc,#BD11
loop_delock outi
          inc b
          dec c
          jr nz,loop_delock
          ret
;
asic_seq
      DB 255,0,255,119,179,81,168,212
      DB 98,57,156,70,43,21,138,205,238
;
asicon
          ld bc,#7FC0
          ld a,#B8
          out (c),c
          out (c),a
          ret
asicoff
          ld bc,#7FA0
          out (c),c
          ret

endApp 

save'disc.bin',#800,endApp-startApp,DSK,'martine-slideshow.dsk'