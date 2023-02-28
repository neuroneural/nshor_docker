Variables legend for `pd_dockerParralelized_fbirn.sh`

|  Variable / Function Name |  Value |    Meaning |
| --- | --- | --- |
|`FSLDIR`  |  `/usr/share/fsl/5.0`| directory where FLS is installed on the docker container|
| `AFNIbinPATH` | `/usr/local/AFNIbin` | directory of AFNI binary executable files  |
| `subjectID` | `000300655084` | ID of the subject being processed at this thread in the current instance of the script |
| `subIDpath` | `/data/$subjectID` |  |
| `subPath` | `` `dirname ${subIDpath}` `` | |
|`acqparams`|`${subPath}/derivatives/acqparams.txt`||
|`template`|`/usr/share/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz`||
|`templatemask`|`/usr/share/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz`||
|`mocodir`|`${subPath}/derivatives/${subjectID}/motion`||
|`coregdir`|`${subPath}/derivatives/${subjectID}/coregistration`||
|`normdir`|`${subPath}/derivatives/${subjectID}/normalization`||
|`procdir`|`${subPath}/derivatives/${subjectID}/processed`||
|`anatdir`|`${subPath}/derivatives/${subjectID}/anat`||
|`skullstrip`|N/A|function that performs skull stripping||
|`N4BiasFieldCorrection`|N/A||
|`./ROBEX`|N/A|||
|`moco_sc`|N/A||
|`epi_in`|||
|`ref_vol`|||
|`suffix`|||
|`TR`|||
|`3dDespike`|||
|`3dvolreg`|||
|`3dresample`|||
|`vrefbrain`|||
|`vrefhead`|||
|`vepi`|||
|`vout`|||
|`epi_orig`|||
|`3dcalc`|||
|`1deval`|||
|`SCMOCO_PID`|||
|`c3d_affine_tool`|||
|`antsApplyTransforms`|||
|`WarpTimeSeriesImageMultiTransform`|||
|`Warp_PID1`|||





