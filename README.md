# nshor_docker
## Dockerfile
The docker file may be built using the following example command from inside the directory containing the dockerfile and the robex tar
          docker build -t yourname/yourproject .

## Singularity sif file
Once you have built the dockerfile into a docker image, you may build the docker image into a sif file using singularity commands 
          singularity build output.sif docker-daemon://yourname/yourproject-latest

## Running the Slurm script
          sbatch --array=1-12 submit.sh
the array number corresponds to the subject number.

## More information
we attempted to keep a log of our activities in #docker-projects slack channel
Thomas deramus also knows more as does nicholas shor
Also sergey oversaw this project


## Code api calls documentation
AFNI 
  3dcalc docs
  https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dcalc.html

  3dwarp
  https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dWarp.html

  3dAutomask
  https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dAutomask.html
  
  abids_json_info.py
  https://afni.nimh.nih.gov/pub/dist/doc/program_help/abids_json_info.py.html
  
  3dDespike
  https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dDespike.html
  
  3dTshift
  https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dTshift.html
  
  3dvolreg
  https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dvolreg.html
  
  3dresample
  https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dresample.html
  
  1deval
  https://afni.nimh.nih.gov/pub/dist/doc/program_help/1deval.html
  
  
FSL
  fslmerge
  https://rdrr.io/cran/fslr/man/fslmerge.html
    
  topup
  https://rdrr.io/github/neuroconductor-devel-releases/fslr/man/topup.html

  applytopup
  https://rdrr.io/github/neuroconductor/fslr/man/applytopup.html

  fast
  https://rdrr.io/github/neuroconductor-devel/fslr/man/fast.html
  
  fslmaths
  https://rdrr.io/github/neuroconductor/fslr/man/fslmaths.html
  
  flirt
  https://rdrr.io/github/neuroconductor-releases/fslr/man/flirt.html
  
  applywarp

                    ***************************************************
                    The following COMPULSORY options have not been set:
                            -i,--in filename of input image (to be warped)
                            -r,--ref        filename for reference image
                            -o,--out        filename for output (warped) image
                    ***************************************************

                    Part of FSL (build 509)
                    applywarp

                                        Usage:
                                        applywarp -i invol -o outvol -r refvol -w warpvol
                                        applywarp -i invol -o outvol -r refvol -w coefvol


                                        Compulsory arguments (You MUST set one or more of):
                                                -i,--in filename of input image (to be warped)
                                                -r,--ref        filename for reference image
                                                -o,--out        filename for output (warped) image

                                        Optional arguments (You may optionally specify one or more of):
                                                -w,--warp       filename for warp/coefficient (volume)
                                                --abs           treat warp field as absolute: x' = w(x)
                                                --rel           treat warp field as relative: x' = x + w(x)
                                                -d,--datatype   Force output data type [char short int float double].
                                                -s,--super      intermediary supersampling of output, default is off
                                                --superlevel    level of intermediary supersampling, a for 'automatic' or integer level. Default = 2
                                                --premat        filename for pre-transform (affine matrix)
                                                --postmat       filename for post-transform (affine matrix)
                                                -m,--mask       filename for mask image (in reference space)
                                                --interp        interpolation method {nn,trilinear,sinc,spline}
                                                --paddingsize   Extrapolates outside original volume by n voxels
                                                -v,--verbose    switch on diagnostic messages
                                                -h,--help       display this message

                       mcflirt

                              mcflirt -in <infile> [options]

                                Available options are:
                                      -out, -o <outfile>               (default is infile_mcf)
                                      -cost {mutualinfo,woods,corratio,normcorr,normmi,leastsquares}        (default is normcorr)
                                      -bins <number of histogram bins>   (default is 256)
                                      -dof  <number of transform dofs>   (default is 6)
                                      -refvol <number of reference volume> (default is no_vols/2)- registers to (n+1)th volume in series
                                      -reffile, -r <filename>            use a separate 3d image file as the target for registration (overrides refvol option)
                                      -scaling <num>                             (6.0 is default)
                                      -smooth <num>                      (1.0 is default - controls smoothing in cost function)
                                      -rotation <num>                    specify scaling factor for rotation optimization tolerances
                                      -verbose <num>                     (0 is least and default)
                                      -stages <number of search levels>  (default is 3 - specify 4 for final sinc interpolation)
                                      -fov <num>                         (default is 20mm - specify size of field of view when padding 2d volume)
                                      -2d                                Force padding of volume
                                      -sinc_final                        (applies final transformations using sinc interpolation)
                                      -spline_final                      (applies final transformations using spline interpolation)
                                      -nn_final                          (applies final transformations using Nearest Neighbour interpolation)
                                      -init <filename>                   (initial transform matrix to apply to all vols)
                                      -gdt                               (run search on gradient images)
                                      -meanvol                           register timeseries to mean volume (overrides refvol and reffile options)
                                      -stats                             produce variance and std. dev. images
                                      -mats                              save transformation matricies in subdirectory outfilename.mat
                                      -plots                             save transformation parameters in file outputfilename.par
                                      -report                            report progress to screen
                                      -help
                    Ants
                      N4BiasFieldCorrection
                      https://github.com/ANTsX/ANTs/wiki/N4BiasFieldCorrection

                                COMMAND:
                                   N4BiasFieldCorrection
                                        N4 is a variant of the popular N3 (nonparameteric nonuniform normalization)
                                        retrospective bias correction algorithm. Based on the assumption that the
                                        corruption of the low frequency bias field can be modeled as a convolution of
                                        the intensity histogram by a Gaussian, the basic algorithmic protocol is to
                                        iterate between deconvolving the intensity histogram by a Gaussian, remapping
                                        the intensities, and then spatially smoothing this result by a B-spline modeling
                                        of the bias field itself. The modifications from and improvements obtained over
                                        the original N3 algorithm are described in the following paper: N. Tustison et
                                        al., N4ITK: Improved N3 Bias Correction, IEEE Transactions on Medical Imaging,
                                        29(6):1310-1320, June 2010.

                              OPTIONS:
                                   -d, --image-dimensionality 2/3/4
                                        This option forces the image to be treated as a specified-dimensional image. If
                                        not specified, N4 tries to infer the dimensionality from the input image.

                                   -i, --input-image inputImageFilename
                                        A scalar image is expected as input for bias correction. Since N4 log transforms
                                        the intensities, negative values or values close to zero should be processed
                                        prior to correction.

                                   -x, --mask-image maskImageFilename
                                        If a mask image is specified, the final bias correction is only performed in the
                                        mask region. If a weight image is not specified, only intensity values inside
                                        the masked region are used during the execution of the algorithm. If a weight
                                        image is specified, only the non-zero weights are used in the execution of the
                                        algorithm although the mask region defines where bias correction is performed in
                                        the final output. Otherwise bias correction occurs over the entire image domain.
                                        See also the option description for the weight image. If a mask image is *not*
                                        specified then the entire image region will be used as the mask region. Note
                                        that this is different than the N3 implementation which uses the results of Otsu
                                        thresholding to define a mask. However, this leads to unknown anatomical regions
                                        being included and excluded during the bias correction.

                                   -r, --rescale-intensities 0/(1)
                                        At each iteration, a new intensity mapping is calculated and applied but there
                                        is nothing which constrains the new intensity range to be within certain values.
                                        The result is that the range can "drift" from the original at each iteration.
                                        This option rescales to the [min,max] range of the original image intensities
                                        within the user-specified mask.

                                   -w, --weight-image weightImageFilename
                                        The weight image allows the user to perform a relative weighting of specific
                                        voxels during the B-spline fitting. For example, some studies have shown that N3
                                        performed on white matter segmentations improves performance. If one has a
                                        spatial probability map of the white matter, one can use this map to weight the
                                        b-spline fitting towards those voxels which are more probabilistically
                                        classified as white matter. See also the option description for the mask image.

                                   -s, --shrink-factor 1/2/3/(4)/...
                                        Running N4 on large images can be time consuming. To lessen computation time,
                                        the input image can be resampled. The shrink factor, specified as a single
                                        integer, describes this resampling. Shrink factors <= 4 are commonly used.Note
                                        that the shrink factor is only applied to the first two or three dimensions
                                        which we assume are spatial.

                                   -c, --convergence [<numberOfIterations=50x50x50x50>,<convergenceThreshold=0.0>]
                                        Convergence is determined by calculating the coefficient of variation between
                                        subsequent iterations. When this value is less than the specified threshold from
                                        the previous iteration or the maximum number of iterations is exceeded the
                                        program terminates. Multiple resolutions can be specified by using 'x' between
                                        the number of iterations at each resolution, e.g. 100x50x50.

                                   -b, --bspline-fitting [splineDistance,<splineOrder=3>]
                                                         [initialMeshResolution,<splineOrder=3>]
                                        These options describe the b-spline fitting parameters. The initial b-spline
                                        mesh at the coarsest resolution is specified either as the number of elements in
                                        each dimension, e.g. 2x2x3 for 3-D images, or it can be specified as a single
                                        scalar parameter which describes the isotropic sizing of the mesh elements. The
                                        latter option is typically preferred. For each subsequent level, the spline
                                        distance decreases in half, or equivalently, the number of mesh elements doubles
                                        Cubic splines (order = 3) are typically used. The default setting is to employ a
                                        single mesh element over the entire domain, i.e., -b [1x1x1,3].

                                   -t, --histogram-sharpening [<FWHM=0.15>,<wienerNoise=0.01>,<numberOfHistogramBins=200>]
                                        These options describe the histogram sharpening parameters, i.e. the
                                        deconvolution step parameters described in the original N3 algorithm. The
                                        default values have been shown to work fairly well.

                                   -o, --output correctedImage
                                                [correctedImage,<biasField>]
                                        The output consists of the bias corrected version of the input image.
                                        Optionally, one can also output the estimated bias field.

                                   --version
                                        Get Version Information.

                                   -v, --verbose (0)/1
                                        Verbose output.

                                   -h
                                        Print the help menu (short version).

                                   --help
                                        Print the help menu.
  
  antsRegistrationSyN.sh
  
          https://github.com/ANTsX/ANTs/blob/master/Scripts/antsRegistrationSyN.sh
  WarpTimeSeriesImageMultiTransform
  
          https://manpages.ubuntu.com/manpages/trusty/man1/WarpTimeSeriesImageMultiTransform.1.html

ROBEX

                    It's a skull-stripping tool:
                    https://www.nitrc.org/projects/robex
                    And it's finicky, you need to be in the directory in which ROBEX.sh exists (otherwise it won't work even if the path is mapped), and THEN call the data you want to skull strip.

C3D
   c3d_affine_tool
   
