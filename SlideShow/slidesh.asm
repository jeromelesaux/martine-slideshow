;
; Loader MultiScreen
; Code : AsT^iMPACT
;    08/04/2023
; 
      ORG #A000
;                 
;    NomS des Différents écrans à charger 
;    les uns à la suite des autres
;  

filename_size equ 11
start
poke_name ld hl,name
;
          ld bc,#BC01   ; On affiche QUE du border au début
          out (c),c        ; avant chaque chargement d'écran
          inc b
          out (c),0
;
          
;
          ld b,filename_size         ; Chaque nom de fichier comporte 12 lettres
          call #BC77    ; open_file

          jr nc,not_found ; Si le fichier n'est pas trouvé -> not_found
          ld hl,#0170   ; Le fichier i2 doit être loadé en #170
          call #BC83    ; load_file
          call #BC7A    ; close_file   
;

          ld a,(#184)           ; On récupère le mode Graphique à l'adresse #184
          add a,-#0E
          call #BC0E

          call #01AD    ; affiche écran Fullscreen iMPdraw
;   
; Gestion du prochain fichier à charger
;
          ld bc,filename_size ; chaque fichier prends 12 caractères de long
          ld hl,(poke_name+1)
          add hl,bc ; le prochain fichier se trouve donc 12 caractères plus loin.
          jr next_file
;
; If File is not Found
;                     
; On reset le nom du fichier
;
not_found
;          
          ld hl,name    ; on reset l'adresse du 1er nom
;
next_file ld (poke_name+1),hl
          jr poke_name
;
; Liste des écrans à charger, les uns à la suite des autres.
;
name  db 'SCREEN1.SCR'
          db 'SCREEN2.SCR'
          db 'SCREEN3.SCR'
          db 'SCREEN4.SCR'
          db 'SCREEN5.SCR'

end 
SAVE'loader.bin',#A000,end-start,DSK,'martine-slideshow.dsk'