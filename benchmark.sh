#!/bin/bash

#on MacOS use -l for maximum memory details
#/usr/bin/time -l  niimath test4D -add 0 tst

#exe is executable to benchmark
#  this could also be set explicitly, e.g.
#  time exe="~/fsl/share/fsl/bin/fslmaths" ./benchmark.sh
exe=${exe:-niimath}

#basedir is folder with "In" subfolder.
# we assume it is the same same folder as the script
# however, this could be set explicitly, e.g.
#   basedir="/Users/cr/niitest" batch.sh
if [ -z ${basedir:-} ]; then
    basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

#### no need to edit subsequent lines

# Fail if anything not planed to go wrong, goes wrong
set -eu

# Test if command exists.
exists() {
    test -x "$(command -v "$1")"
}

# Check executable.
exists $exe ||
    {
        echo >&2 "I require $exe but it's not installed.  Aborting."
        exit 1
    }

#folder paths
indir=${basedir}/In
newdir=${basedir}/New
if [ ! -d "$indir" ]; then
 echo "Error: Unable to find $indir"
 exit 1
fi
if [ ! -d "$newdir" ]; then
 mkdir $newdir
fi
if [ ! -z "$(ls $newdir)" ]; then
 echo "Cleaning output directory: $newdir"
 rm $newdir/*
fi
# Convert images.
newout="$newdir/new"

echo Testing Operation Comibinations: demean
# fslmaths 4D_inputVolume -Tmean -mul -1 -add 4D_inputVolume demeaned_4D_inputVolume
inimg="$indir/trick"
cmd="$exe $inimg -Tmean -mul -1 -add  $inimg $newout"
echo $cmd
$cmd

echo Testing Binary Operations: with fixed value
#ops="add sub mul div rem thr thrp thrP uthr uthrp uthrP max min"
ops="thrp thrP uthrp uthrP Tperc Xperc Yperc Zperc inm ing add sub mul div rem thr uthr max min"
inimg="$indir/trick"
for op in $ops; do
 cmd="$exe $inimg -$op 50 $newout"
 echo $cmd
 $cmd
done 

echo Testing Binary Operations: with fixed value with odd number of volumes
#ops="add sub mul div rem thr thrp thrP uthr uthrp uthrP max min"
ops="Tperc Xperc Yperc Zperc inm ing add sub mul div rem thr uthr max min"
 inimg="$indir/3vols"
for op in $ops; do
 cmd="$exe $inimg -$op 50 $newout"
 echo $cmd
 $cmd
done

ops="Tmedian Xmedian Zmedian"
echo Median with odd number of volumes
for op in $ops; do
 inimg="$indir/3vols"
 cmd="$exe $inimg -$op $newout"
 echo $cmd
 $cmd
done 

#ALMOST identical Xar1 Yar1 Zar1
ops="Tmedian Xmedian Zmedian Tar1 Tmean Tstd Tmax Tmaxn Tmin Tar1 Xmean Xstd Xmax Xmaxn Xmin Ymean Ystd Ymax Ymaxn Ymin Zmean Zstd Zmax Zmaxn Zmin"
echo Testing Dimensionality reduction
for op in $ops; do
 inimg="$indir/trick"
 cmd="$exe $inimg -$op $newout"
 echo $cmd
 $cmd
done 

rx="AIL AIR ALI ALS ARI ARS ASL ASR IAL IAR ILA ILP IPL IPR IRA IRP LAI LAS LIA LIP LPI LPS LSA LSP PIL PIR PLI PLS PRI PRS PSL PSR RAI RAS RIA RIP RPI RPS RSA RSP SAL SAR SLA SLP SPL SPR SRA SRP"
## -roi <xmin> <xsize> <ymin> <ysize> <zmin> <zsize> <tmin> <tsize> zero outside roi
for img in $rx; do
 inimg="$indir/$img"
 cmd="$exe $inimg -roi 5 19 3 22 2 28 0 1 $newout"
 echo $cmd
 $cmd
done

echo Testing Binary Operations: with 2nd image
#ops="add sub mul div rem thr thrp thrP uthr uthrp uthrP max min"
ops="add sub mul div thr uthr  max min rem"
inimg="$indir/trick"
modimg="$indir/trick3D"
for op in $ops; do
 cmd="$exe $inimg -$op $modimg $newout"
 echo $cmd
 $cmd
 # reverse order: not all operations are commutative
 cmd="$exe $modimg -$op $inimg $newout"
 echo $cmd
 $cmd
done 

ops="exp log sin cos tan asin acos atan sqr sqrt recip abs bin binv fillh fillh26 index edge nan nanm"
inimg="trick"
for op in $ops; do
 cmd="$exe $indir/$inimg -$op $newout"
 #echo $cmd
 $cmd
done 

echo SUCCESS
exit 0
