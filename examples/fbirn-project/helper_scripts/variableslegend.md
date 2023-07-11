Variables legend for `pd_dockerParralelized_fbirn.sh`

|  Variable / Function Name |  Value |    Meaning |
| --- | --- | --- |
|`FSLDIR`  |  `/usr/share/fsl/5.0`| directory where FLS is installed on the docker container|
| `AFNIbinPATH` | `/usr/local/AFNIbin` | directory of AFNI binary executable files  |
| `subjectID` | `000300655084` | ID of the subject being processed at this thread in the current instance of the script |
| `subIDpath` | `/data/$subjectID` | path which contains the subject's data |
| `subPath` | `` `dirname ${subIDpath}` `` | executes the dirname utility to extract the subject's data directory (?) |
|`acqparams`|`${subPath}/derivatives/acqparams.txt`||
|`template`|`/usr/share/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz`|model brain used for other functions in the script|
|`templatemask`|`/usr/share/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz`|this is the mask associated with the model brain used for other functions |
|`mocodir`|`${subPath}/derivatives/${subjectID}/motion`|directory at which files associated with motion (?) are written as output of the script|
|`coregdir`|`${subPath}/derivatives/${subjectID}/coregistration`|directory at which files associated with coregistration are written as output of the script|
|`normdir`|`${subPath}/derivatives/${subjectID}/normalization`|directory at which files associated with normalization are written as output of the script|
|`procdir`|`${subPath}/derivatives/${subjectID}/processed`|directory at which any processed files are written as output of the script|
|`anatdir`|`${subPath}/derivatives/${subjectID}/anat`|directory at which any anatomical files are written as output of the script|
|`skullstrip`|N/A|"wrapper-function" that performs skull stripping|
|`N4BiasFieldCorrection`|N/A| tool by NIH Insight Toolkit used to perform bias field correction (removes smooth bias field signal which corrupts MRI images)|
|`./ROBEX`|N/A| Robust Brain Extraction, a tool used to do skull stripping|
|`moco_sc`|N/A| "wrapper-function" that uses AFNI to perform motion correction on the voxels|
|`epi_orig`|`${subIDpath}/func/rest.nii`|this is the bold signal for a task for the subject currently being processed by this instance of the script|
|`epi_in`| `epi_orig` | local variable for the `moco_sc` function, `epi_orig` is used as an argument to 
|`ref_vol`|||
|`suffix`|`rest`|this is suffix that should be placed in the file names associated with fMRI intermediate processing files (?)|
|`TR`|2|variable containing repetition time for the time sequence, TR is the length of time between corresponding consecutive points on a repeating series of pulses and echoes|
|`3dDespike`|N/A|removes 'spikes' from the 3D+time input dataset and writes a new dataset with the spike values replaced by something more pleasing to the eye.|
|`3dvolreg`|N/A|registers each 3D sub-brick from the input dataset to the base brick|
|`3dresample`|-orient RPI|an AFNI function used to reorient the axes to a new order, with `OR_CODE=RPI` this means orient the x axis as right to left, posterior to anterior for the y axis, and inferior to superior for the z axis |
|`vrefbrain`|`T1_bc_ss.nii.gz`|anatomical brain obtained from sMRI after performing bias corection and skull strip used to construct future images (?2)|
|`vrefhead`|`T1_bc.nii.gz`|anatomical head obtainted from sMRI scan of patient before skull stripping, used to construct future files involving head (?1)|
|`vepi`|`rest.nii`|file containing bold signal for one run of the current subject being processed at this thread in the current instance of the script|
|`vout`|`${subjectID}_rfMRI_v0_correg`|suffix used to name the output files associated with corregistration|
|`3dcalc`|N/A|This program does voxel-by-voxel arithmetic on 3D datasets|
|`1deval`|N/A|Evaluates an expression that may include columns of data from one or more text files and writes the result to stdout.|
|`SCMOCO_PID`|$!|captures the process id of the `moco_sc` right after it is called|
|`c3d_affine_tool`| N/A| special complementary tool built to work with ITK-Snap and convert3d to manipulate the transform file. The transform file contains a matrix representing a transform from the physical space of the reference image to the physical space of the moving image, (convert between FSL and ANTs transform matrix files) |
|`antsApplyTransforms`|N/A|applied to an input image, transforms it according to a reference image and a transform (or a set of transforms)|
|`WarpTimeSeriesImageMultiTransform`|N/A|warps fMRI data to the MNI template|
|`Warp_PID1`| $! | catches the process id of the `WarpTimeSeriesImageMultiTransform` function call so it can be passed to a wait function later|





