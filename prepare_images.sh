#! /bin/bash

echo "renanimg images...."
dir="imgs/Convertion"
cp $dir/DDLM.GO1 $dir/1.GO1
cp $dir/DDLM.GO2 $dir/1.GO2

cp $dir/DIA.GO1 $dir/2.GO1
cp $dir/DIA.GO2 $dir/2.GO2

cp $dir/HULK.GO1 $dir/3.GO1
cp $dir/HULK.GO2 $dir/3.GO2


cp $dir/RAAG.GO1 $dir/4.GO1
cp $dir/RAAG.GO2 $dir/4.GO2

cp $dir/SKJOK.GO1 $dir/5.GO1
cp $dir/SKJOK.GO2 $dir/5.GO2

echo "creating images dsk...."
dsk -dsk images.dsk -format

echo "import images into dsk...."
dsk -dsk images.dsk -put -amsdosfile $dir/1.GO1 -type binary
dsk -dsk images.dsk -put -amsdosfile $dir/1.GO2 -type binary
dsk -dsk images.dsk -put -amsdosfile $dir/2.GO1 -type binary
dsk -dsk images.dsk -put -amsdosfile $dir/2.GO2 -type binary
dsk -dsk images.dsk -put -amsdosfile $dir/3.GO1 -type binary
dsk -dsk images.dsk -put -amsdosfile $dir/3.GO2 -type binary
dsk -dsk images.dsk -put -amsdosfile $dir/4.GO1 -type binary
dsk -dsk images.dsk -put -amsdosfile $dir/4.GO2 -type binary
dsk -dsk images.dsk -put -amsdosfile $dir/5.GO1 -type binary
dsk -dsk images.dsk -put -amsdosfile $dir/5.GO2 -type binary