
bank 0
start_raag
inczx7 'RAAG_noamsdosheader.SCR'
end_raag
save '1.scr',#170,end_raag-start_raag,DSK,'martine-slideshow-zx7.dsk'

start_ddlm
inczx7 'ddlm_noamsdosheader.SCR'
end_ddlm
save '2.scr',#170,end_ddlm-start_ddlm,DSK,'martine-slideshow-zx7.dsk'

start_dia
inczx7 'dia_noamsdosheader.SCR'
end_dia
save '3.scr',#170,end_dia-start_dia,DSK,'martine-slideshow-zx7.dsk'

bank 1
start_hulk
inczx7 'hulk_noamsdosheader.SCR'
end_hulk
save '4.scr',#170,end_dia-start_dia,DSK,'martine-slideshow-zx7.dsk'


start_www
inczx7 'www_noamsdosheader.SCR'
end_www
save '5.scr',#170,end_www-start_www,DSK,'martine-slideshow-zx7.dsk'
