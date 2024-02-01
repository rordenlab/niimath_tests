# About

This folder provides a series of validation tests to enusre niimath performs equivalently to fslmaths. To run these tests, both [niimath](https://github.com/rordenlab/niimath) and [fslmaths](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation) must be installed and in your command line path.

# Validation Tests Against Reference Solutions

The script `canonical_test` compares the performance of a version of fslmaths clone to 163 images created by fslmaths 6.0.X compiled for the ARM architecture using MacOS 13.6. These images are stored in the `Canonical` folder and are designed check a full battery of binary, unary and other operations using images that exhibit edge cases (containing ties, even and odd numbers of images, etc). To run the script you can use: 

```
git clone git@github.com:rordenlab/niimath_tests.git
cd niimath_tests
./canonical_test.sh
```

By default, this script tests the version of `niimath` that is in your path (e.g. `which niimath`). However, you can set a custom fslmaths clone to evaluate (`exe="/Users/share/fsl/bin/fslmaths" canonical_test.sh`) Note that niimath must be in your path (as it has the `compare` function that detects if newly generated images match the canonical images). 
The script `canonical_make` will recreate a new set of canonical images using the version of fslmaths in your path.

# Validation Tests Between Two Executables

These validation and regression tests apply the same image processing operations to the same images and compare the results of niimath and fslmaths. You run these tests from the command line:

```
git clone git@github.com:rordenlab/niimath_tests.git
cd niimath_tests
./conformance.sh
./close.sh 
```

Tperc Xperc Yperc Zperc inm ing add sub mul div rem thr uthr max min

Tmedian Xmedian Zmedian Tar1 Tmean Tstd Tmax Tmaxn Tmin Tar1 Xmean Xstd Xmax Xmaxn Xmin Ymean Ystd Ymax Ymaxn Ymin Zmean Zstd Zmax Zmaxn Zmin

Binary Operations: with 2nd image
#ops="add sub mul div rem thr thrp thrP uthr uthrp uthrP max min"

unary operations
ops="exp log sin cos tan asin acos atan sqr sqrt recip abs bin binv fillh fillh26 index edge nan nanm"

Spatial Filtering operations
"dilM dilD dilF dilall ero eroF eroF fmedian fmean fmeanu subsamp2offc"

--
bptf
 ties
rank ranknorm

kernel 
 fmedian dilM dilF ero eroF  fmean fmeanu dilD dilall


The `conformance` script applies operations where the results should be identical. The `close` script is [equivalent but not identical results](https://github.com/rordenlab/niimath?tab=readme-ov-file#identical-versus-equivalent-results). For example, the `bandpass temporal filtering` function (bptf) result in virtually identical results, with the most significantly different voxel being 1.90735e-06 brighter in one method versus the other:

```
fslmaths /Users/chris/src/niimath_tests/In/rest4D -bptf 25 -1 /Users/chris/src/niimath_tests/Ref/img
niimath /Users/chris/src/niimath_tests/In/rest4D -bptf 25 -1 /Users/chris/src/niimath_tests/New/img
niimath /Users/chris/src/niimath_tests/Ref/img --compare /Users/chris/src/niimath_tests/New/img
Images Differ: Correlation r = 1, identical voxels 99%
  Most different voxel -15.5066 vs -15.5066 (difference 1.90735e-06)
  Most different voxel location 25x25x8 volume 29
Image 1 Descriptives
 Range: -433.738..611.313 Mean -3.35224e-11 StDev 9.49224
Image 2 Descriptives
 Range: -433.738..611.313 Mean 6.9696e-10 StDev 9.49224
```

# Benchmarking Tests

These tests compare the speed of niimath versus fslmath in performing the same operations. The `benchmark` script only processes the tiny images provided with the repository. This script requires you to specify the executable to test (it will use `niimath` by default). For a more realistic test for the large images typical of the neuroimaging domain, you need to [download the rest.nii.gz and t1.nii.gz](https://osf.io/y84gq/files/osfstorage) images and place these files (still in gz format) into the `niimath_tests` folder before running the benchmarks. Note that the script can also be modified to specify the [FslEnvironmentVariables](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslEnvironmentVariables). In particular, you could set `FSLOUTPUTTYPE=NIFTI` or `FSLOUTPUTTYPE=NIFTI_GZ` to explore the influence of image compression.

:

```
git clone git@github.com:rordenlab/niimath_tests.git
cd niimath_tests
time ./benchmark.sh
time exe="fslmaths" ./benchmark.sh
# download rest.nii.gz and place in niimath_tests folder 
./slow_benchmark.sh
```

# Expected Differences

 - `rank` and `ranknorm` convert data to sorted ranks. Voxels that have identical intensities (ties) can report different ranks.



