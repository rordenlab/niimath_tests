#!/bin/sh

#please get data from https://osf.io/y84gq/

# export FSLOUTPUTTYPE=NIFTI

for exe in niimath fslmaths; do
  echo $exe spatially smooth image:
  time $exe rest -s 2.548 out
  echo $exe dilate image:
  time $exe t1 -kernel boxv 7 -dilM out
  echo $exe baseline correct image:
  time $exe rest -Tmean -mul -1 -add rest out
  echo $exe temporally smooth image:
  time $exe rest -bptf 77 8.68 out
done 
