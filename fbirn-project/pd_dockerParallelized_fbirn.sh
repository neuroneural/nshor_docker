#!/bin/bash
# The script expects the user to prepare a text file with a list of paths one line per subject. The list will be indexed by job number and is meant to be run on the entire list in slurm from start to end. If the jobs in slurm crash and restarted every subject needs to be re-processed.

set -x
set -e

SLURM_TASK_ID=$1
SUBJECTS_FILE=$2

echo "SLURM_TASK_ID is ${SLURM_TASK_ID}"
echo "1 is $1"
echo "2 is $2"

IFS=$'\n' a=($(cat ${SUBJECTS_FILE}))
#for i in $(seq ${#a[*]}); do
#    [[ ${a[$i-1]} = $name ]]
#done

#Creates subjectIDs
subjectID=${a[${SLURM_TASK_ID}]}
echo "subject ID is ${subjectID}"
subDataRead=/data/${subjectID}/ses_01
outputUniverse=/out
start=`date +%s`

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

#Marks the template to be used
template=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz
templatemask=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz

#Bias-Correction SBREF and EPI
mkdir -p  ${outputUniverse}/derivatives/$subjectID
mkdir -p ${outputUniverse}/derivatives/$subjectID/bias_field

#Generates directory names in the derivatives folders according to BIDS specifications
mocodir=${outputUniverse}/derivatives/${subjectID}/motion
coregdir=${outputUniverse}/derivatives/${subjectID}/coregistration
normdir=${outputUniverse}/derivatives/${subjectID}/normalization
procdir=${outputUniverse}/derivatives/${subjectID}/processed
anatdir=${outputUniverse}/derivatives/${subjectID}/anat

#Makes the directories
mkdir -p  ${coregdir}
mkdir -p ${mocodir}
mkdir -p  ${normdir}
mkdir -p ${procdir}
mkdir -p ${anatdir}


function epireg_set() {
        coregdir=$1
        vrefbrain=$2
        vepi=$3
        vout=$4
        vrefhead=$5
        echo "coregdir $coregdir"
        echo "vrefbrain $vrefbrain"
        echo "vepi $vepi"
        echo "vout $vout"
        cd ${coregdir}
        cp ../anat/${vrefbrain} .
        cp ../anat/${vrefhead} .
       
	echo "doing FSL fast"
        $FSLDIR/bin/fast -N -o ${vout}_fast ${vrefbrain}
	echo "done doing FSL fast"

	echo "doing FSLmaths"
        $FSLDIR/bin/fslmaths ${vout}_fast_pve_2 -thr 0.5 -bin ${vout}_fast_wmseg
	echo " done doing FSLmaths"

        echo "FLIRT pre-alignment"
        $FSLDIR/bin/flirt -ref ${vrefbrain} -in ${vepi} -dof 6 -omat ${vout}_init.mat
        $FSLDIR/bin/flirt -ref ${vrefhead} -in ${vepi} -dof 6 -cost bbr -wmseg ${vout}_fast_wmseg -init ${vout}_init.mat -omat ${vout}.mat -out ${vout} -schedule ${FSLDIR}/etc/flirtsch/bbr.sch
        $FSLDIR/bin/applywarp -i ${vepi} -r ${vrefhead} -o ${vout} --premat=${vout}.mat --interp=spline
        echo "finished epireg_set"
}

function skullstrip() {
    echo "function skullstrip was called"
    subDataRead=$1
    subjectID=$2
    anatdir=$3

    #Performs the N3/4 Bias correction on the T1 and Extracts the Brain
    N4BiasFieldCorrection -d 3 -i ${subDataRead}/anat/T1.nii -o ${anatdir}/T1_bc.nii.gz

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
	
	3dDespike -NEW -prefix Despike_${suffix}.nii.gz ${epi_in}
	echo "inside moco fucntion 4 - removed outliers with despike sucessfully"
    
	3dvolreg -verbose -zpad 1 -base ${ref_vol} -heptic -prefix moco_${suffix} -1Dfile ${subjectID}_motion.1D -1Dmatrix_save mat.${subjectID}.1D ${mocodir}/Despike_${suffix}.nii.gz
	echo "inside moco fucntion 6 - motion corrected using 3dvolreg successful"

    	3dresample -orient RPI -inset moco_${suffix}+tlrc.HEAD -prefix ${mocodir}/${subjectID}_rfMRI_moco_${suffix}.nii.gz
	echo "inside moco function 7 - data reorientation using 3dresample successful"
    	echo 'finish moco_sc'
}



vrefbrain=T1_bc_ss.nii.gz
vrefhead=T1_bc.nii.gz

vepi=rest.nii
vout=${subjectID}_rfMRI_v0_correg

epi_orig=${subDataRead}/func/rest.nii # should not be hardcoded
3dcalc -a0 ${epi_orig} -prefix ${coregdir}/${vepi} -expr 'a*1'
start=`date +%s`


echo "waiting for skull strip"
skullstrip ${subDataRead} ${subjectID} ${anatdir}
echo "done waiting for skull strip"


echo "now checking to see if script can find mask and template brain"
echo "checking for template MASK"
FILE=${templatemask}
if test -f "$FILE"; then
    echo "$FILE exists."
fi

echo "checking for template brain"
FILE=${template}
if test -f "$FILE"; then
    echo "$FILE exists."
else
    echo "$FILE is not there"
fi


echo "doing antsRegistration"
antsRegistrationSyN.sh -d 3 -n 16 -f ${template} -m ${anatdir}/T1_bc_ss.nii.gz -x ${templatemask} -o ${normdir}/${subjectID}_ANTsReg &
ANTS_PID=$! 
wait ${ANTS_PID}
echo "done doing antsRegistration"

epireg_set ${coregdir} ${vrefbrain} ${vepi} ${vout} ${vrefhead}  &
EPI_PID=$!
wait ${EPI_PID}


moco_sc ${epi_orig} ${coregdir}/${vepi} ${subjectID} rest &
SCMOCO_PID=$!
echo "waiting for moco"
wait $SCMOCO_PID
echo "done waiting for moco"

echo "trying mcflirt"
mcflirt -in ${epi_orig} -reffile ${coregdir}/${vepi} -out ${mocodir}/${subjectID}_rfMRI_moco.nii.gz -mats -plots -rmsrel -rmsabs -report &
MCFLIRT_PID=$!
wait ${MCFLIRT_PID}
echo "done trying mcflirt"

echo "now using c3d_affine_tool"
c3d_affine_tool -ref ${coregdir}/T1_bc_ss.nii.gz -src ${coregdir}/${vepi} ${coregdir}/${subjectID}_rfMRI_v0_correg.mat -fsl2ras -oitk ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt
echo "c3d_affine_tool complete"



echo "try antsApplyTransforms"
antsApplyTransforms -d 4 -e 3 -i ${mocodir}/${subjectID}_rfMRI_moco.nii.gz -r $template -n BSpline -t ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz -t ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat -t ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt -o ${procdir}/${subjectID}_rsfMRI_processed.nii.gz -v
ANTS_APPID=$!
wait ${ANTS_APPID}
echo "antsApplyTransformsComplete"


echo "now using WarpTimeSeriesMultiTransform tool"
WarpTimeSeriesImageMultiTransform 4 ${mocodir}/${subjectID}_rfMRI_moco_rest.nii.gz ${procdir}/${subjectID}_rsfMRI_processed_rest.nii.gz  -R ${template}  ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz  ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt &
Warp_PID1=$!
echo "WarpTimeSeriesMultiTransform complete"


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
