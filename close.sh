#!/bin/bash

#refexe is reference executable, e.g. validated copy of fslmaths
# we assume it is in the users path
# however, this could be set explicitly, e.g.
#  refexe="/Users/cr/fslmaths" batch.sh
refexe=${refexe:-fslmaths}

#newexe is new executable, e.g. we want to make sure if gives the same results as refexe
#  this could also be set explicitly, e.g.
#  refexe="/Users/cr/fslmaths" batch.sh
newexe=${newexe:-niimath}

#basedir is folder with "In" subfolder.
# we assume it is the same same folder as the script
# however, this could be set explicitly, e.g.
#   basedir="/Users/cr/niitest" batch.sh
if [ -z ${basedir:-} ]; then
    basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

#### no need to edit subsequent lines

# Fail if anything not planed to go wrong, goes wrong
# set -eu

# Test if command exists.
exists() {
    test -x "$(command -v "$1")"
}

# Check executables.
exists $refexe ||
    {
        echo >&2 "I require $refexe but it's not installed.  Aborting."
        exit 1
    }
exists $newexe ||
    {
        echo >&2 "I require $newexe but it's not installed.  Aborting."
        exit 1
    }

#folder paths
indir=${basedir}/In
newdir=${basedir}/New
refdir=${basedir}/Ref
if [ ! -d "$indir" ]; then
 echo "Error: Unable to find $indir"
 exit 1
fi
if [ ! -d "$refdir" ]; then
 mkdir $refdir
fi
if [ ! -z "$(ls $refdir)" ]; then
 echo "Cleaning output directory: $refdir"
 rm $refdir/*
fi
if [ ! -d "$newdir" ]; then
 mkdir $newdir
fi
if [ ! -z "$(ls $newdir)" ]; then
 echo "Cleaning output directory: $newdir"
 rm $newdir/*
fi
# Convert images.
refout="$refdir/img"
newout="$newdir/img"

echo Testing Bandpass temporal filter
inimg="$indir/rest4D"
# high pass
 cmd="$refexe $inimg -bptf 25 -1 $refout"
 echo $cmd
 $cmd
 cmd="$newexe $inimg -bptf 25 -1 $newout"
 echo $cmd
 $cmd
 tst="$newexe $refout --compare $newout"
 echo $tst
 $tst
# low pass
 cmd="$refexe $inimg -bptf -1 5 $refout"
 echo $cmd
 $cmd
 cmd="$newexe $inimg -bptf -1 5 $newout"
 echo $cmd
 $cmd
 tst="$newexe $refout --compare $newout"
 echo $tst
 $tst
# band pass
 cmd="$refexe $inimg -bptf 25 5 $refout"
 echo $cmd
 $cmd
 cmd="$newexe $inimg -bptf 25 5 $newout"
 echo $cmd
 $cmd
 tst="$newexe $refout --compare $newout"
 echo $tst
 $tst

echo ALL TESTS DONE
exit 0

echo Testing Basic statistical operations: ties impact rank and ranknorm
ops="rank ranknorm"
inimg="$indir/no_ties"
for op in $ops; do
 cmd="$refexe $inimg -$op $refout"
 echo $cmd
 $cmd
 cmd="$newexe $inimg -$op $newout"
 echo $cmd
 $cmd
 tst="$newexe $refout --compare $newout"
 echo $tst
 $tst
done 

echo Testing Kernel operations: dilD and dilall are not exact
ops="fmedian dilM dilF ero eroF  fmean fmeanu dilD dilall"
inimg="$indir/trick"
for op in $ops; do
 cmd="$refexe $inimg -$op $refout"
 echo $cmd
 $cmd
 cmd="$newexe $inimg -$op $newout"
 echo $cmd
 $cmd
 tst="$newexe $refout --compare $newout"
 echo $tst
 $tst
 #test with spherical kernal
 cmd="$refexe $inimg -kernel sphere 8 -$op $refout"
 echo $cmd
 $cmd
 cmd="$newexe $inimg -kernel sphere 8 -$op $newout"
 echo $cmd
 $cmd
 tst="$newexe $refout --compare $newout"
 echo $tst
 $tst 
done 

ops="fmedian dilM dilD dilF dilall ero eroF  fmean fmeanu"
inimg="$indir/trick"
for op in $ops; do
 cmd="$refexe $inimg -$op $refout"
 echo $cmd
 $cmd
 cmd="$newexe $inimg -$op $newout"
 echo $cmd
 $cmd
 tst="$newexe $refout --compare $newout"
 echo $tst
 $tst
done 

imgs="tfLAS tfRAS"
echo Testing TFCE
for img in $imgs; do
 inimg="$indir/$img"
 cmd="$refexe $inimg -tfce 2 0.5 6 $refout"
 echo $cmd
 $cmd
 cmd="$newexe $inimg -tfce 2 0.5 6 $newout"
 echo $cmd
 $cmd
 tst="$newexe $refout --compare $newout"
 echo $tst
 $tst
 cmd="$refexe $inimg -tfceS 0.01 0.5 6 59 47 61 0.01 $refout"
 echo $cmd
 $cmd
 cmd="$newexe $inimg -tfceS 0.01 0.5 6 59 47 61 0.01 $newout"
 echo $cmd
 $cmd
 tst="$newexe $refout --compare $newout"
 echo $tst
 $tst
done 

#ALMOST subsampling
ops="subsamp2 subsamp2offc"
imgs="LAS RAS LAS1 RAS1"
echo Testing Dimensionality reduction
for op in $ops; do
 for img in $imgs; do
  inimg="$indir/$img"
  cmd="$refexe $inimg -$op $refout"
  echo $cmd
  $cmd
  cmd="$newexe $inimg -$op $newout"
  echo $cmd
  $cmd
  tst="$newexe $refout --compare $newout"
  echo $tst
  $tst
 done
done 


#ALMOST identical Xar1 Yar1 Zar1
ops="Xar1 Yar1 Zar1"
echo Testing Dimensionality reduction
for op in $ops; do
 inimg="$indir/trick"
 cmd="$refexe $inimg -$op $refout"
 echo $cmd
 $cmd
 cmd="$newexe $inimg -$op $newout"
 echo $cmd
 $cmd
 tst="$newexe $refout --compare $newout"
 echo $tst
 $tst
done 


echo Testing Gaussian blur
 inimg="$indir/trick"
 cmd="$refexe $inimg -s 2.26 $refout"
 echo $cmd
 $cmd
 cmd="$newexe $inimg -s 2.26 $newout"
 echo $cmd
 $cmd
 tst="$newexe $refout --compare $newout"
 echo $tst
 $tst

#diffusion
imgs="tensorRAS tensorLAS"
echo Testing Dimensionality reduction
for img in $imgs; do
 inimg="$indir/$img"
 cmd="$refexe $inimg -tensor_decomp $refout"
 echo $cmd
 $cmd
 cmd="$newexe $inimg -tensor_decomp $newout"
 echo $cmd
 $cmd
 tst="$newexe $refout --compare $newout"
 echo $tst
 $tst
 tst="$newexe ${refout}_V1 --compare ${newout}_V1"
 echo $tst
 $tst
 tst="$newexe ${refout}_V2 --compare ${newout}_V2"
 echo $tst
 $tst
 tst="$newexe ${refout}_V3 --compare ${newout}_V3"
 echo $tst
 $tst 
 tst="$newexe ${refout}_MO --compare ${newout}_MO"
 echo $tst
 $tst 
done 

ops="Tar1 Xar1 Yar1 Zar1"
echo Testing Dimensionality reduction
for op in $ops; do
 inimg="$indir/trick"
 cmd="$refexe $inimg -$op $refout"
 echo $cmd
 $cmd
 cmd="$newexe $inimg -$op $newout"
 echo $cmd
 $cmd
 tst="$newexe $refout --compare $newout"
 echo $tst
 $tst
done 

echo Testing Basic Statistical Operations
inimg="$indir/stat3D"
cmd="$refexe $inimg -ztop $refout"
echo $cmd
$cmd
cmd="$newexe $inimg -ztop $newout"
echo $cmd
$cmd
tst="$newexe $refout --compare $newout"
echo $tst
$tst
refoutz="$refdir/refz"
newoutz="$newdir/newz"
inimg="$indir/stat3D"
cmd="$refexe $refout -ptoz $refoutz"
echo $cmd
$cmd
cmd="$newexe $newout -ptoz $newoutz"
echo $cmd
$cmd
tst="$newexe $refoutz --compare $newoutz"
echo $tst
$tst

echo ALL TESTS DONE
exit 0
