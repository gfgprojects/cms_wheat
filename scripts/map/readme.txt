#run the following

r_origin.R
r_write_import_network_for_gephi.R
r_makeExportMap2.R


#ralize gif

convert -delay 120 -loop 0 -crop 1374x968+128+202 +repage Screen*  -transparent '#eeeeee' animated.gif


convert -delay 120 -loop 0 -crop 1622x1004+124+200 +repage Screen\ Shot\ 2018-06-17\ at\ 14.*.png animated.gif
#per avere informazioni

identify animated.gif

#crop
convert -crop 1374x968+128+202 +repage input output

#cambiare un colore
convert image -fuzz XX% -fill red -opaque white result

#aggiungere label
convert spain.png -fill red -font Times-New-Roman -pointsize 50 -gravity north -annotate +0+100 "NorthWest" tmp.png

#comando finale
convert case.png -crop 1622x804+124+400 +repage -fill '#ca0c11' -font Times-New-Roman -pointsize 50 -gravity north -annotate +0+0 "year" -transparent '#eeeeee' tmp.png
