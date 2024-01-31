# About

This folder provides a series of validation tests to enusre niimath performs equivalently to fslmaths. To run these tests, both [niimath](https://github.com/rordenlab/niimath) and [fslmaths](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation) must be installed and in your command line path.

# Validation Tests

These validation and regression tests apply the same image processing operations to the same images and compare the results of niimath and fslmaths. You run these tests from the command line:

```
git clone git@github.com:rordenlab/niimath_tests.git
cd niimath_tests
./conformance.sh
./close.sh 
```

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

