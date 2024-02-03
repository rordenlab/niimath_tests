#!/bin/bash

#on MacOS use -l for maximum memory details
#/usr/bin/time -l  niimath test4D -add 0 tst

#exe is executable, e.g. fslmaths or niimath
# we assume it is in the users path
# however, this could be set explicitly, e.g.
#  exe="/Users/cr/fslmaths" canonical_make.sh
exe=${exe:-fslmaths}

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

# Check executables.
exists $exe ||
    {
        echo >&2 "I require $exe but it's not installed.  Aborting."
        exit 1
    }

#folder paths
indir=${basedir}/In
outdir=${basedir}/Canonical
refdir=${basedir}/Ref
if [ ! -d "$indir" ]; then
 echo "Error: Unable to find $indir"
 exit 1
fi
if [ ! -d "$refdir" ]; then
 echo "Error: Unable to find $refdir"
 exit 1
fi
if [ ! -d "$outdir" ]; then
 mkdir $outdir
fi
if [ ! -z "$(ls $outdir)" ]; then
 echo "Cleaning output directory: $outdir"
 rm $outdir/*
fi
refout="$refdir/"
newout="$outdir/"

inimg="$indir/trick"
op=demean
echo Creating ${op}
cmd="$exe $inimg -Tmean -mul -1 -add  $inimg ${newout}${op}"
$cmd

ops="thrp uthrp Tperc Xperc Yperc Zperc inm ing add sub mul div rem thr uthr max min"
inimg="$indir/trick"
family="BinaryEven"
for op in $ops; do
 echo Creating ${op}${family}
 cmd="$exe $inimg -$op 50 ${newout}${op}${family}"
 $cmd
done

ops="thrP uthrP"
inimg="$indir/trick"
family="BinaryPEven"
for op in $ops; do
 echo Creating ${op}${family}
 cmd="$exe $inimg -$op 50 ${newout}${op}${family}"
 $cmd
done

ops="Tperc Xperc Yperc Zperc inm ing add sub mul div rem thr uthr max min"
inimg="$indir/3vols"
family="BinaryOdd"
for op in $ops; do
 echo Creating ${op}${family}
 cmd="$exe $inimg -$op 50 ${newout}${op}${family}"
 $cmd
done

ops="Tmedian Xmedian Zmedian"
family="MedianOdd"
inimg="$indir/3vols"
for op in $ops; do
 echo Creating ${op}${family}
 cmd="$exe $inimg -$op ${newout}${op}${family}"
 $cmd
done

#ALMOST identical Xar1 Yar1 Zar1
ops="Tmedian Xmedian Zmedian Tar1 Tmean Tstd Tmax Tmaxn Tmin Tar1 Xmean Xstd Xmax Xmaxn Xmin Ymean Ystd Ymax Ymaxn Ymin Zmean Zstd Zmax Zmaxn Zmin"
family="ReduceEven"
inimg="$indir/trick"
for op in $ops; do
 echo Creating ${op}${family}
 cmd="$exe $inimg -$op ${newout}${op}${family}"
 $cmd
done

rx="AIL AIR ALI ALS ARI ARS ASL ASR IAL IAR ILA ILP IPL IPR IRA IRP LAI LAS LIA LIP LPI LPS LSA LSP PIL PIR PLI PLS PRI PRS PSL PSR RAI RAS RIA RIP RPI RPS RSA RSP SAL SAR SLA SLP SPL SPR SRA SRP"
## -roi <xmin> <xsize> <ymin> <ysize> <zmin> <zsize> <tmin> <tsize> zero outside roi
family="roi"
for op in $rx; do
 inimg="$indir/$op"
 echo Creating ${op}${family}
 cmd="$exe $inimg -roi 5 19 3 22 2 28 0 1 ${newout}${op}${family}"
 $cmd
done

echo Testing Binary Operations: with 2nd image
ops="add sub mul div max min rem"
inimg="$indir/trick"
modimg="$indir/trick3D"
family="Binary2Img"
for op in $ops; do
 echo Creating ${op}${family}
 cmd="$exe $inimg -$op $modimg ${newout}${op}${family}"
 $cmd
 # reverse order: not all operations are commutative
 cmd="$exe $modimg -$op $inimg ${newout}${op}${family}Rev"
 $cmd
done

# band pass temporal filtering
inimg="$indir/rest4D"
echo Creating bptf
op=bptfHighPass
cmd="$exe $inimg -bptf 25 -1 ${newout}${op}"
$cmd
op=bptfLowPass
cmd="$exe $inimg -bptf -1 5 ${newout}${op}"
$cmd
op=bptfBandPass
cmd="$exe $inimg -bptf 25 5 ${newout}${op}"
$cmd

ops="exp log sin cos tan asin acos atan sqr sqrt recip abs bin binv fillh fillh26 index edge nan nanm"
inimg="trick"
family="Unary"
for op in $ops; do
 echo Creating ${op}${family}
 cmd="$exe $indir/$inimg -$op ${newout}${op}${family}"
 $cmd
done

ops="dilM dilD dilF dilall ero eroF eroF fmedian fmean fmeanu subsamp2offc"
inimg="trick3D"
family="Filter"
for op in $ops; do
 echo Creating ${op}${family}
 cmd="$exe $indir/$inimg -$op ${newout}${op}${family}"
 $cmd
done

ops="rank ranknorm"
inimg="$indir/no_ties"
for op in $ops; do
 echo Creating ${op}
 cmd="$exe $inimg -$op ${newout}${op}"
 $cmd
done

echo SUCCESS
exit 0
