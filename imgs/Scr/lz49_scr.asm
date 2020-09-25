
bank 0
start_raag
incl49 'RAAG_noamsdosheader.SCR'
end_raag
save '1.scr',#170,end_raag-start_raag,DSK,'martine-slideshow-l49.dsk'

start_ddlm
incl49 'ddlm_noamsdosheader.SCR'
end_ddlm
save '2.scr',#170,end_ddlm-start_ddlm,DSK,'martine-slideshow-l49.dsk'

start_dia
incl49 'dia_noamsdosheader.SCR'
end_dia
save '3.scr',#170,end_dia-start_dia,DSK,'martine-slideshow-l49.dsk'

bank 1
start_hulk
incl49 'hulk_noamsdosheader.SCR'
end_hulk
save '4.scr',#170,end_dia-start_dia,DSK,'martine-slideshow-l49.dsk'


start_www
incl49 'www_noamsdosheader.SCR'
end_www
save '5.scr',#170,end_www-start_www,DSK,'martine-slideshow-l49.dsk'
