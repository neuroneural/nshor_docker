#!/bin/bash
# The script expects the user to prepare a text file with a list of paths one line per subject. The list will be indexed by job number and is meant to be run on the entire list in slurm from start to end. If the jobs in slurm crash and restarted every subject needs to be re-processed.
#TODO: make script only write intermediate files to docker container
#TODO: make script write out processed file to output mount, this is the only file that should be written out to the output mount, no intermediate files

set -x
set -e

func_file=$1
func_filepath=/func/${func_file}
echo "func_filepath is ${func_filepath}"
echo "func_file is ${func_file}"

anat_file=$2
anat_filepath=/anat/${anat_file}
echo "anat_filepath is ${anat_filepath}"
echo "anat_file is ${anat_file}"

spinlr_file=$3
spinlr_filepath=/func/${spinlr_file}
echo "spinlr_filepath is ${spinlr_filepath}"
echo "spinlr_file is ${spinlr_file}"

spinrl_file=$4
spinrl_filepath=/func/${spinrl_file}
echo "spinrl_filepath is ${spinrl_filepath}"
echo "spinrl_file is ${spinrl_file}"

biasch_file=$5
biasch_filepath=/func/${biasch_file}
echo "biasch_filepath is ${biasch_filepath}"
echo "biasch_file is ${biasch_file}"

biasbc_file=$6
biasbc_filepath=/func/${biasbc_file}
echo "biasbc_filepath is ${biasbc_filepath}"
echo "biasbc_file is ${biasbc_file}"

sbref_file=$7 
sbref_filepath=/func/${sbref_file}
echo "sbref_filepath is ${sbref_filepath}"
echo "sbref_file is ${sbref_file}"

out_filepath=$8
echo "out_filepath is ${out_filepath}"

path_ending_in_ID=$out_filepath
echo "path_ending_in_ID is ${path_ending_in_ID}"

subjectID=`basename $path_ending_in_ID`
echo "subjectID is ${subjectID}"

outputUniverse=/dev/shm
outputMount=/out

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
mkdir -p ${outputUniverse}/derivatives/$subjectID/SBRef

#make output directories
mocodir=${outputUniverse}/derivatives/${subjectID}/motion
coregdir=${outputUniverse}/derivatives/${subjectID}/coregistration
normdir=${outputUniverse}/derivatives/${subjectID}/normalization
procdir=${outputUniverse}/derivatives/${subjectID}/processed
anatdir=${outputUniverse}/derivatives/${subjectID}/anat

#Makes the directories
mkdir -p ${coregdir}
mkdir -p ${mocodir}
mkdir -p ${normdir}
mkdir -p ${procdir}
mkdir -p ${anatdir}

#sets the acquisition parameters to use for topup, this file should exist in the subject's func directory
touch ${outputUniverse}/derivatives/$subjectID/bias_field/acqparams.txt
acqparams=${outputUniverse}/derivatives/$subjectID/bias_field/acqparams.txt
echo -e "1 0 0 1\n-1 0 0 1" > $acqparams


function afni_set() {
    3dcalc -a ${biasch_filepath} -b ${biasbc_filepath} -prefix ${outputUniverse}/derivatives/$subjectID/bias_field/$subjectID\_bias_field.nii.gz -expr 'b/a'
    echo "function afni_set debug 1"

    3dWarp -deoblique -prefix ${outputUniverse}/derivatives/$subjectID/bias_field/$subjectID\_bias_field_deobl.nii.gz ${outputUniverse}/derivatives/$subjectID/bias_field/$subjectID\_bias_field.nii.gz
	if [ -f ${outputUniverse}/derivatives/$subjectID/bias_field/$subjectID\_bias_field_deobl.nii.gz ]; then
		echo "$subjectID\_bias_field_deobl.nii.gz file exists"
	else 
		echo "$subjectID\_bias_field_deobl.nii.gz file DOES NOT exist"
	fi
	if [ -f ${outputUniverse}/derivatives/$subjectID/bias_field/$subjectID\_bias_field.nii.gz ]; then
		echo "$subjectID\_bias_field.nii.gz file exists"
	else 
		echo "$subjectID\_bias_field.nii.gz file DOES NOT exist"
	fi
    echo "function afni_set debug 2"

    3dAutomask -dilate 2 -prefix ${outputUniverse}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz ${sbref_filepath}

    if [ -f ${outputUniverse}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz ]; then
	    echo "Brain mask created successfully."
    else
	    echo "Error: Brain mask creation failed."
    fi
    echo "function afni_set debug 3"


    3dWarp -oblique_parent /func/$subjectID\_3T_rfMRI_REST1_LR.nii.gz -gridset ${func_filepath} -prefix ${outputUniverse}/derivatives/$subjectID/bias_field/$subjectID\_biasfield_card2EPIoblN.nii.gz ${outputUniverse}/derivatives/$subjectID/bias_field/$subjectID\_bias_field_deobl.nii.gz
    echo "function afni_set debug 4"

    3dcalc -float -a ${func_filepath} -b ${outputUniverse}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz -c ${outputUniverse}/derivatives/$subjectID/bias_field/$subjectID\_biasfield_card2EPIoblN.nii.gz  -prefix ${outputUniverse}/derivatives/$subjectID/func/$subjectID\_3T_rfMRI_REST1_LR_DEBIAS.nii.gz -expr 'a*b*c'
    echo "function afni_set debug 5"

    3dcalc  -float  -a ${sbref_filepath} -b ${outputUniverse}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz -c ${outputUniverse}/derivatives/$subjectID/bias_field/$subjectID\_biasfield_card2EPIoblN.nii.gz  -prefix ${outputUniverse}/derivatives/$subjectID/func/$subjectID\_3T_rfMRI_REST1_LR_DEBIAS_SBRef.nii.gz -expr 'a*b*c'
    echo "function afni_set debug 6"
}

function epireg_set() {
        coregdir=$1
        vrefbrain=$2
        vepi=$3
        vout=$4
        vrefhead=$5
        cd ${coregdir}
        cp ../anat/${vrefbrain} .
        cp ../anat/${vrefhead} .
       
        $FSLDIR/bin/fast -N -o ${vout}_fast ${vrefbrain}

        $FSLDIR/bin/fslmaths ${vout}_fast_pve_2 -thr 0.5 -bin ${vout}_fast_wmseg

        $FSLDIR/bin/flirt -ref ${vrefbrain} -in ${vepi} -dof 6 -omat ${vout}_init.mat

        $FSLDIR/bin/flirt -ref ${vrefhead} -in ${vepi} -dof 6 -cost bbr -wmseg ${vout}_fast_wmseg -init ${vout}_init.mat -omat ${vout}.mat -out ${vout} -schedule ${FSLDIR}/etc/flirtsch/bbr.sch

        $FSLDIR/bin/applywarp -i ${vepi} -r ${vrefhead} -o ${vout} --premat=${vout}.mat --interp=spline
}

function skullstrip() {
    anatdir=$1

    #Performs the N3/4 Bias correction on the T1 and Extracts the Brain
    N4BiasFieldCorrection -d 3 -i $anat_filepath -o ${anatdir}/T1_bc.nii.gz

    cd /ROBEX

    ./ROBEX ${anatdir}/T1_bc.nii.gz ${anatdir}/T1_bc_ss.nii.gz
}

#MoCo means motion correction 
function moco_sc() {
        epi_in=$1
        ref_vol=$2
	subjectID=$3
        suffix=$4
        
    	cd ${mocodir}

	3dDespik -NEW -prefix Despike_${suffix}.nii.gz ${epi_in}
    
	3dvolreg -verbose -zpad 1 -base ${ref_vol} -heptic -prefix moco_${suffix} -1Dfile ${subjectID}_motion.1D -1Dmatrix_save mat.${subjectID}.1D ${mocodir}/Despike_${suffix}.nii.gz

    	3dresample -orient RPI -inset moco_${suffix}+tlrc.HEAD -prefix ${mocodir}/${subjectID}_rfMRI_moco_${suffix}.nii.gz
}



vrefbrain=T1_bc_ss.nii.gz
vrefhead=T1_bc.nii.gz

vepi=$func_filepath
vout=${subjectID}_rfMRI_v0_correg

epi_orig=$func_filepath


skullstrip ${anatdir}
afni_set &
AFNI_PID=$!


antsRegistrationSyN.sh -d 3 -n 16 -f ${template} -m ${anatdir}/T1_bc_ss.nii.gz -x ${templatemask} -o ${normdir}/${subjectID}_ANTsReg &
ANTS_PID=$! 

wait ${AFNI_PID}

3dcalc -a0 ${epi_orig} -prefix ${coregdir}/${func_file} -expr 'a*1'

epireg_set ${coregdir} ${vrefbrain} ${vepi} ${vout} ${vrefhead}  &
EPI_PID=$!


moco_sc ${epi_orig} ${coregdir}/${func_file} ${subjectID} rest &
SCMOCO_PID=$!

mcflirt -in ${epi_orig} -reffile ${coregdir}/${func_file} -out ${mocodir}/${subjectID}_rfMRI_moco.nii.gz -mats -plots -rmsrel -rmsabs -report &
MCFLIRT_PID=$!

wait $SCMOCO_PID
wait $EPI_PID

c3d_affine_tool -ref ${coregdir}/T1_bc_ss.nii.gz -src ${coregdir}/${func_file} ${coregdir}/${subjectID}_rfMRI_v0_correg.mat -fsl2ras -oitk ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt

wait $ANTS_PID

antsApplyTransforms -d 4 -e 3 -i ${mocodir}/${subjectID}_rfMRI_moco.nii.gz -r $template -n BSpline -t ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz -t ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat -t ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt -o ${procdir}/${subjectID}_rsfMRI_processed.nii.gz -v

WarpTimeSeriesImageMultiTransform 4 ${mocodir}/${subjectID}_rfMRI_moco_rest.nii.gz ${procdir}/${subjectID}_rsfMRI_processed_rest.nii.gz  -R ${template}  ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz  ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt

cp ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz ${procdir}
cp ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${procdir}
cp ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt ${procdir}
cp ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${procdir}
cp ${template} ${procdir}
cp ${coregdir}/${subjectID}_rfMRI_v0_correg.mat  ${procdir}
cp ${mocodir}/${subjectID}_rfMRI_moco_rest.nii.gz ${procdir}
cp ${anatdir}/T1_bc_ss.nii.gz  ${procdir}

mkdir -p ${outputMount}/processed
mtdPrcDir=${outputMount}/processed

cp ${procdir}/${subjectID}_rsfMRI_processed_rest.nii.gz ${mtdPrcDir}

end=`date +%s`
echo $((end-start)) >> ${procdir}/benchTime.txt
