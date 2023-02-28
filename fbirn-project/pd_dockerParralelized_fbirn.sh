#!/bin/bash
  
set -x
set -e

#Sets FSL Paths
FSLDIR=/usr/share/fsl/5.0

#Sets path for ROBEX (For Skullstripping)
export PATH=$PATH:/usr/lib/ROBEX:/usr/lib/ants

#Sets path for ANTs tools (for normalization workflow)
export ANTSPATH=/usr/lib/ants

#Sets additional paths for AFNI and FSL
export AFNIbinPATH=/usr/local/AFNIbin
PATH=${AFNIbinPATH}:${PATH}
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh



#dirname = /data

#Creates subjectIDs
subjectID="000300655084"
subIDpath=/data/$subjectID
subPath=`dirname ${subIDpath}`
start=`date +%s`

#ImageTagging
acqparams=${subPath}/derivatives/acqparams.txt

#Marks the template to be used
template=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz
templatemask=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz

#Bias-Correction SBREF and EPI
mkdir -p  ${subPath}/derivatives/$subjectID
mkdir -p ${subPath}/derivatives/$subjectID/bias_field

#Generates directory names in the derivatives folders according to BIDS specifications
mocodir=${subPath}/derivatives/${subjectID}/motion
coregdir=${subPath}/derivatives/${subjectID}/coregistration
normdir=${subPath}/derivatives/${subjectID}/normalization
procdir=${subPath}/derivatives/${subjectID}/processed
anatdir=${subPath}/derivatives/${subjectID}/anat

#Makes the directories
mkdir -p  ${coregdir}
mkdir -p ${mocodir}
mkdir -p  ${normdir}
mkdir -p ${procdir}
mkdir -p ${anatdir}


#I don't think this function will work unless we have these bias_map and bias_field files
# need $subjectID\_3T_BIAS_32CH.nii.gz
# need $subjectID\_3T_BIAS_BC.nii.gz
# what/where are these for FBIRN dataset
function afni_set() {
    subIDpath=$1
    subPath=$2
    subjectID=$3
 
    echo "inside function afni_set 1: 3dcalc bias correction using division"   
    3dcalc -a ${subIDpath}/biasmaps/$subjectID\_3T_BIAS_32CH.nii.gz -b ${subIDpath}/biasmaps/$subjectID\_3T_BIAS_BC.nii.gz -prefix ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_bias_field.nii.gz -expr 'b/a'


    echo "inside function afni_set 2: 3dWarp1"
    3dWarp -deoblique -prefix ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_bias_field_deobl.nii.gz ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_bias_field.nii.gz
    mkdir -p  ${subPath}/derivatives/$subjectID/SBRef


    echo "inside function afni_set 3: 3dAutomask"
    3dAutomask -dilate 2 -prefix ${subPath}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz $subIDpath/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef.nii.gz


    echo "inside function afni_set 4: 3dWarp2"
    3dWarp -oblique_parent $subIDpath/func/$subjectID\_3T_rfMRI_REST1_LR.nii.gz -gridset $subIDpath/func/$subjectID\_3T_rfMRI_REST1_LR.nii.gz -prefix ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_biasfield_card2EPIoblN.nii.gz ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_bias_field_deobl.nii.gz
    mkdir -p ${subPath}/derivatives/$subjectID/func


    echo "inside function afni_set 5: 3dcalc biascorrection multiplication"
    3dcalc -float -a $subIDpath/func/$subjectID\_3T_rfMRI_REST1_LR.nii.gz -b ${subPath}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz -c ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_biasfield_card2EPIoblN.nii.gz  -prefix ${subPath}/derivatives/$subjectID/func/$subjectID\_3T_rfMRI_REST1_LR_DEBIAS.nii.gz -expr 'a*b*c'


    echo "inside function afni_set 6: 3dcalc more multiplication"
    3dcalc  -float  -a $subIDpath/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef.nii.gz -b ${subPath}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz -c ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_biasfield_card2EPIoblN.nii.gz  -prefix ${subPath}/derivatives/$subjectID/func/$subjectID\_3T_rfMRI_REST1_LR_DEBIAS_SBRef.nii.gz -expr 'a*b*c'
    echo 'finished afni_set'
}


function skullstrip() {
    echo "function skullstrip was called"
    subIDpath=$1
    subPath=$2
    subjectID=$3
    anatdir=$4

    #Performs the N3/4 Bias correction on the T1 and Extracts the Brain
    N4BiasFieldCorrection -d 3 -i ${subIDpath}/anat/T1.nii -o ${anatdir}/T1_bc.nii.gz

    cd /ROBEX

    ./ROBEX ${anatdir}/T1_bc.nii.gz ${anatdir}/T1_bc_ss.nii.gz
    echo 'finished skullstrip'
}

#MoCo means motion correction 
function moco_sc() {
	echo "function moco_sc was called"
        epi_in=$1
        ref_vol=$2
        subjectID=$3
        suffix=$4
        
    	cd ${mocodir}

	TR=2
	
	#'Despikes' the data (removes outliers) prior to image registration
	3dDespike -NEW -prefix Despike_${suffix}.nii.gz ${epi_in}
	echo "inside moco fucntion 4 - removed outliers with despike sucessfully"
    
	#Performs realignment to the reference volume. Some call this "motion correction"
	3dvolreg -verbose -zpad 1 -base ${ref_vol} -heptic -prefix moco_${suffix} -1Dfile ${subjectID}_motion.1D -1Dmatrix_save mat.${subjectID}.1D ${mocodir}/Despike_${suffix}.nii.gz
	echo "inside moco fucntion 6 - motion corrected using 3dvolreg successful"

	#Reorients the data
    	3dresample -orient RPI -inset moco_${suffix}+tlrc.HEAD -prefix ${mocodir}/${subjectID}_rfMRI_moco_${suffix}.nii.gz
	echo "inside moco function 7 - data reorientation using 3dresample successful"
    	echo 'finish moco_sc'
}



vrefbrain=T1_bc_ss.nii.gz
vrefhead=T1_bc.nii.gz

vepi=rest.nii
vout=${subjectID}_rfMRI_v0_correg

epi_orig=${subIDpath}/func/rest.nii

3dcalc -a0 ${epi_orig} -prefix ${coregdir}/${vepi} -expr 'a*1'

start=`date +%s`

1deval -num 25 -expr t+10 > t0.1D


afni_set ${subIDpath} ${subPath} ${subjectID} &
AFNI_PID=$!

skullstrip ${subIDpath} ${subPath} ${subjectID} ${anatdir}&
SKULL_PID=$!
wait ${SKULL_PID}


echo "now using WarpTimeSeriesMultiTransform tool"
#Warps the 4d timeseries to template space in order of: EPI-to-T1 affine transformation, affine warp to template, Nonlinear deformation to template
WarpTimeSeriesImageMultiTransform 4 ${mocodir}/${subjectID}_rfMRI_moco_rest.nii.gz ${procdir}/${subjectID}_rsfMRI_processed_rest.nii.gz  -R ${template}  ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz  ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt &
Warp_PID1=$!
echo "antsApplyTransforms complete"


wait ${AFNI_PID}


moco_sc ${epi_orig} ${coregdir}/${vepi} ${subjectID} rest &
SCMOCO_PID=$!

echo "waiting for moco"
wait $SCMOCO_PID





echo "now using c3d_affine_tool"
c3d_affine_tool -ref ${anatdir}/T1_bc_ss.nii.gz -src ${coregdir}/${vepi} -o ${coregdir}/${subjectID}_rfMRI_v0_correg.mat -fsl2ras -oitk ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt
echo "c3d_affine_tool complete"


echo "now using antsApplyTransforms tool"
antsApplyTransforms -d 4 -e 3 -i ${mocodir}/${subjectID}_rfMRI_moco.nii.gz -r $template -n BSpline -t ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz -t ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat -t ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt -o ${procdir}/${subjectID}_rsfMRI_processed.nii.gz -v
echo "antsApplyTransforms complete"





wait $Warp_PID1
cp ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz ${procdir}
cp ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${procdir}
cp ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt ${procdir}
cp ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${procdir}
cp ${template} ${procdir}
cp ${coregdir}/${subjectID}_rfMRI_v0_correg.mat  ${procdir}
cp ${mocodir}/${subjectID}_rfMRI_moco_rest.nii.gz ${procdir}
cp ${anatdir}/T1_bc_ss.nii.gz  ${procdir}

end=`date +%s`
echo $((end-start)) >> ${procdir}/benchTime.txt
echo 'end of program'
