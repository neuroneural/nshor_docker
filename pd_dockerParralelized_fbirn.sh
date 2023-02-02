#!/bin/bash
  
set -x
set -e
#Sets FSL Paths
FSLDIR=/usr/share/fsl/5.0

#Sets path for ROBEX (For Skullstripping)
#export PATH=$PATH:/usr/lib/afni/bin:/usr/lib/ROBEX:/usr/lib/ants
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

echo "subIDpath: $subIDpath"
echo "subPath: $subPath"
echo "subjectID: $subjectID"
#Module Loading
#module load Image_Analysis/AFNI
#cd /data/mialab/users/tderamus/Track1_HCP_Brainhack

#ImageTagging
#subjectID=`sed -n ${SLURM_ARRAY_TASK_ID}p ${subIDpath}/derivatives/sublist.txt`
#subPath=${subIDpath}/$subjectID
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
echo "mocodir:" $mocodir
echo "coregdir:" $coregdir
echo "normdir:" $normdir
echo "procdir:" $procdir
echo "anatdir:" $anatdir
#Makes the directories
mkdir -p  ${coregdir}
mkdir -p ${mocodir}
mkdir -p  ${normdir}
mkdir -p ${procdir}
mkdir -p ${anatdir}

function afni_set() {
    echo "function afni_set was called"
    subIDpath=$1
    subPath=$2
    subjectID=$3
   
    echo "subIDpath inside afni_set is $subIDpath"
    echo "argument 1 is $1"

    echo "subPath inside afni_set is $subPath"
    echo "argument 2 is $2"

    echo "subIDpath inside afni_set is $subjectID"
    echo "argument 3 is $3"

    3dcalc -a ${subIDpath}/biasmaps/$subjectID\_3T_BIAS_32CH.nii.gz -b ${subIDpath}/biasmaps/$subjectID\_3T_BIAS_BC.nii.gz -prefix ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_bias_field.nii.gz -expr 'b/a'

    echo "made it past 3dcalc-1 in afni_set"

    3dWarp -deoblique -prefix ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_bias_field_deobl.nii.gz ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_bias_field.nii.gz
    mkdir -p  ${subPath}/derivatives/$subjectID/SBRef

    echo "made it past 3dWarp-1 in afni_set"

    3dAutomask -dilate 2 -prefix ${subPath}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz $subIDpath/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef.nii.gz

    echo "made it past 3dAutomask in afni_set"


    3dWarp -oblique_parent $subIDpath/func/$subjectID\_3T_rfMRI_REST1_LR.nii.gz -gridset $subIDpath/func/$subjectID\_3T_rfMRI_REST1_LR.nii.gz -prefix ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_biasfield_card2EPIoblN.nii.gz ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_bias_field_deobl.nii.gz
    mkdir -p ${subPath}/derivatives/$subjectID/func

    echo "made it past 3dWarp-2 in afni_set"


    3dcalc -float -a $subIDpath/func/$subjectID\_3T_rfMRI_REST1_LR.nii.gz -b ${subPath}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz -c ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_biasfield_card2EPIoblN.nii.gz  -prefix ${subPath}/derivatives/$subjectID/func/$subjectID\_3T_rfMRI_REST1_LR_DEBIAS.nii.gz -expr 'a*b*c'

    echo "made it past 3dcalc-2 in afni_set"


    3dcalc  -float  -a $subIDpath/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef.nii.gz -b ${subPath}/derivatives/$subjectID/SBRef/$subjectID\_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz -c ${subPath}/derivatives/$subjectID/bias_field/$subjectID\_biasfield_card2EPIoblN.nii.gz  -prefix ${subPath}/derivatives/$subjectID/func/$subjectID\_3T_rfMRI_REST1_LR_DEBIAS_SBRef.nii.gz -expr 'a*b*c'

    echo "made it past 3dcalc-3 in afni_set"

    echo 'finished afni_set'
}


function topup_set() {
    echo "function topup_set was called"
    subIDpath=$1
    subPath=$2
    subjectID=$3
    
    #Field Distortion Correction
    mkdir -p ${subPath}/derivatives/$subjectID/fieldmap/

    fslmerge -t ${subPath}/derivatives/$subjectID/fieldmap/${subjectID}_3T_Phase_Map.nii.gz $subIDpath/fieldmaps/${subjectID}_3T_SpinEchoFieldMap_LR.nii.gz $subIDpath/fieldmaps/${subjectID}_3T_SpinEchoFieldMap_RL.nii.gz

    topup --imain=${subPath}/derivatives/$subjectID/fieldmap/${subjectID}_3T_Phase_Map.nii.gz --datain=$acqparams --out=${subPath}/derivatives/$subjectID/fieldmap/$subjectID\_TOPUP --fout=${subPath}/derivatives/$subjectID/fieldmap/$subjectID\_TOPUP_FIELDMAP.nii.gz --iout=${subPath}/derivatives/$subjectID/fieldmap/${subjectID}_TOPUP_CORRECTION.nii.gz

    if [ -f ${subPath}/derivatives/$subjectID/fieldmap/${subjectID}_TOPUP_FIELDMAP.nii.gz ]; then
	echo   "TOPUP SUCCESS"
    fi

    applytopup --imain=${subPath}/derivatives/${subjectID}/func/${subjectID}_3T_rfMRI_REST1_LR_DEBIAS.nii.gz --inindex=1 --method=jac --datain=$acqparams --topup=${subPath}/derivatives/${subjectID}/fieldmap/${subjectID}_TOPUP --out=${subPath}/derivatives/${subjectID}/func/${subjectID}_3T_rfMRI_REST1_LR_DEBIAS_UNWARPED.nii.gz &
    
    topup1_PID=$!
 
    applytopup --imain=${subPath}/derivatives/$subjectID/func/${subjectID}_3T_rfMRI_REST1_LR_DEBIAS_SBRef.nii.gz --inindex=1 --method=jac --datain=$acqparams --topup=${subPath}/derivatives/$subjectID/fieldmap/${subjectID}_TOPUP --out=${subPath}/derivatives/$subjectID/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED.nii.gz &
    topup2_PID=$!
    echo 'finished topup'
    wait $topup1_PID
    wait $topup2_PID
}

function skullstrip() {
    echo "function skullstrip was called"
    subIDpath=$1
    subPath=$2
    subjectID=$3
    anatdir=$4
    
	#Performs the N3/4 Bias correction on the T1 and Extracts the Brain
    #N4BiasFieldCorrection -d 3 -i ${subIDpath}/anat/${subjectID}_run-01_T1w.nii.gz -o ${anatdir}/${subjectID}_run-01_T1w_bc.nii.gz
    N4BiasFieldCorrection -d 3 -i ${subIDpath}/anat/Sm6mwc1pT1.nii -o ${anatdir}/Sm6mwc1pT1.nii
    #above is no longer raw so anatdir is better.
    echo "anatdir" ${anatdir}
    echo "subjectID" ${subjectID}
    cd /ROBEX
    #./ROBEX ${anatdir}/${subjectID}_run-01_T1w_bc.nii.gz ${anatdir}/${subjectID}_run-01_T1w_bc_ss.nii.gz
    ./ROBEX ${anatdir}/Sm6mwc1pT1.nii ${anatdir}/Sm6mwc1pT1.nii
    echo 'finished skullstrip'
}

# epi_reg SPLIT
function epireg_set() {
	echo "funcion epireg_set was called"
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
        ln -s ../anat/${vrefbrain} .
	ln -s ../anat/${vrefhead} .
        #  ln -s ../SBRef/${vepi} .
        
        $FSLDIR/bin/fast -N -o ${vout}_fast ${vrefbrain}
        $FSLDIR/bin/fslmaths ${vout}_fast_pve_2 -thr 0.5 -bin ${vout}_fast_wmseg

        echo "FLIRT pre-alignment"
        $FSLDIR/bin/flirt -ref ${vrefbrain} -in ${vepi} -dof 6 -omat ${vout}_init.mat
        $FSLDIR/bin/flirt -ref ${vrefhead} -in ${vepi} -dof 6 -cost bbr -wmseg ${vout}_fast_wmseg -init ${vout}_init.mat -omat ${vout}.mat -out ${vout} -schedule ${FSLDIR}/etc/flirtsch/bbr.sch
        $FSLDIR/bin/applywarp -i ${vepi} -r ${vrefhead} -o ${vout} --premat=${vout}.mat --interp=spline
        echo "finished epireg_set"
}

#MoCo means motion correction 
function moco_sc() {
	echo "function moco_sc was called"
        epi_in=$1
        ref_vol=$2
        subjectID=$3
        suffix=$4
        
    cd ${mocodir}
	#Metadata extraction
	
		#Pulls the Slice timing info from the json file
		abids_json_info.py -field SliceTiming -json ${subIDpath}/func/${sdir}_task-rest_run-04_bold.json | sed 's/[][]//g' | tr , '\n' | sed 's/ //g' > tshiftparams.1D
		#Finds the number where the slice value is 0 in the slice timing
		SliceRef=`cat tshiftparams.1D | grep -m1 -n -- "0$" | cut -d ":" -f1`
	
		#Pulls the TR from the json file. This tells 3dTshift what the scaling factor is
		TR=`abids_json_info.py -field RepetitionTime -json ${subIDpath}/func/${sdir}_task-rest_run-04_bold.json`
	
	
	#'Despikes' the data (removes outliers) prior to image registration
	3dDespike -NEW -prefix Despike_${suffix}.nii.gz ${epi_in}
	
	#Timeshifts the data. It's SliceRef-1 because AFNI indexes at 0 so 1=0, 2=1, 3=2, ect
	3dTshift -tzero $(($SliceRef-1)) -tpattern @tshiftparams.1D -TR ${TR} -quintic -prefix tshift_Despiked_${suffix}.nii.gz Despike_${suffix}.nii.gz
        #3dTshift -tzero 0 -tpattern '${Tshiftparams} ' -quintic -prefix tshift_${suffix} ${epi_in}
        #commented out by will after talking to thomas--rest data probably doesn't need this        
        #3dvolreg -verbose -zpad 1 -base ${ref_vol} -heptic -prefix moco_${suffix} -1Dfile ${subjectID}_motion.1D -1Dmatrix_save mat.${subjectID}.1D tshift_${suffix}+orig        
    
	#Performs realignment to the reference volume. Some call this "motion correction"
	3dvolreg -verbose -zpad 1 -base ${ref_vol} -heptic -prefix moco_${suffix} -1Dfile ${subjectID}_motion.1D -1Dmatrix_save mat.${subjectID}.1D tshift_Despiked_${suffix}.nii.gz

	#Reorients the data
    3dresample -orient RPI -inset moco_${suffix}+orig.HEAD -prefix ${mocodir}/${subjectID}_rfMRI_moco_${suffix}.nii.gz
    echo 'finish moco_sc'
}


#afni_set ${subIDpath} ${subPath} ${subjectID} &
AFNI_PID=$!
#topup_set ${subIDpath} ${subPath} ${subjectID} & #will--why did we remove this? 
TOPUP_PID=$!
skullstrip ${subIDpath} ${subPath} ${subjectID} ${anatdir}&
SKULL_PID=$!
 
wait ${SKULL_PID}

#Computes the warping parameters to get the skullstripped data to template space
#antsRegistrationSyN.sh -d 3 -n 16 -f ${template} -m ${anatdir}/${subjectID}_run-01_T1w_bc_ss.nii.gz -x ${templatemask} -o ${normdir}/${subjectID}_ANTsReg &
antsRegistrationSyN.sh -d 3 -n 16 -f ${template} -m ${anatdir}/Sm6mwc1pT1.nii -x ${templatemask} -o ${normdir}/${subjectID}_ANTsReg &
ANTS_PID=$! 

wait ${AFNI_PID}
##wait ${TOPUP_PID}

vrefbrain=Sm6mwc1pT1.nii
vrefhead=Sm6mwc1pT1.nii
#vepi=${subjectID}_r01_restpre_v0.nii.gz

#i think think is better : will : the bold is better, we have this data
vepi=${subjectID}_task-rest_run-01_bold.nii.gz
vout=${subjectID}_rfMRI_v0_correg

#epi_orig=${subIDpath}${subjectID}_r01_restpre.nii.gz
#less sure about epi_orig: will 
epi_orig=${subIDpath}/func/${subjectID}_task-rest_run-01_bold.nii.gz
echo vepi $vepi
echo epi_orig $epi_orig
3dcalc -a0 ${epi_orig} -prefix ${coregdir}/${vepi} -expr 'a*1'

epireg_set ${coregdir} ${vrefbrain} ${vepi} ${vout} ${vrefhead}  &

EPI_PID=$!
 
start=`date +%s`

echo "AA"
#exit 1
1deval -num 25 -expr t+10 > t0.1D
echo "AAA"
moco_sc ${epi_orig} ${coregdir}/${vepi} ${subjectID} rest &
#1dplot -one t0.1D t.shift.1D -jpeg slice_timing_check
SCMOCO_PID=$!
echo "AAAA"
#task_epi1=${subIDpath}/${subjectID}_r01_pre.nii.gz
#task_epi2=${subIDpath}/${subjectID}_r02_pre.nii.gz
#task_epi3=${subIDpath}/${subjectID}_r03_pre.nii.gz
#task_epi4=${subIDpath}/${subjectID}_r04_pre.nii.gz

#moco_sc ${task_epi1} ${coregdir}/${vepi} ${subjectID} r01 &
#SCMOCO_PID1=$!
#moco_sc ${task_epi2} ${coregdir}/${vepi} ${subjectID} r02 &
#SCMOCO_PID2=$!
#moco_sc ${task_epi3} ${coregdir}/${vepi} ${subjectID} r03 &
#SCMOCO_PID3=$!
#moco_sc ${task_epi4} ${coregdir}/${vepi} ${subjectID} r04 &
#SCMOCO_PID4=$!

#mcflirt -in ${epi_orig} -reffile ${coregdir}/${vepi} -out ${mocodir}/${subjectID}_rfMRI_moco.nii.gz -mats -plots -rmsrel -rmsabs -report &
#MCFLIRT_PID=$!
echo "waiting for moco and epi"
wait $SCMOCO_PID
wait $EPI_PID
echo after epi_pid wait
#exit 0
#Converts the epi_to_T1 registration parameters from FSL to ANTs format
#https://neurostars.org/t/epi-to-t1-registration/2677
c3d_affine_tool -ref ${coregdir}/${subjectID}_run-01_T1w_bc_ss.nii.gz -src ${coregdir}/${vepi} ${coregdir}/${subjectID}_rfMRI_v0_correg.mat -fsl2ras -oitk ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt

echo "BB"
##wait $ANTS_PID
##wait $SCMOCO_PID1
##wait $SCMOCO_PID2
##wait $SCMOCO_PID3
##wait $SCMOCO_PID4

#antsApplyTransforms -d 4 -e 3 -i ${mocodir}/${subjectID}_rfMRI_moco.nii.gz -r $template -n BSpline -t ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz -t ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat -t ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt -o ${procdir}/${subjectID}_rsfMRI_processed.nii.gz -v

#Warps the 4d timeseries to template space in order of: EPI-to-T1 affine transformation, affine warp to template, Nonlinear deformation to template
WarpTimeSeriesImageMultiTransform 4 ${mocodir}/${subjectID}_rfMRI_moco_rest.nii.gz ${procdir}/${subjectID}_rsfMRI_processed_rest.nii.gz  -R ${template}  ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz  ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt &
Warp_PID1=$!

echo "BBB"
#WarpTimeSeriesImageMultiTransform 4 ${mocodir}/${subjectID}_rfMRI_moco_r01.nii.gz ${procdir}/${subjectID}_rsfMRI_processed_r01.nii.gz  -R ${template}  ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz  ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt &
#Warp_PID2=$!

#WarpTimeSeriesImageMultiTransform 4 ${mocodir}/${subjectID}_rfMRI_moco_r02.nii.gz ${procdir}/${subjectID}_rsfMRI_processed_r02.nii.gz  -R ${template}  ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz  ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt &
#Warp_PID3=$!

#WarpTimeSeriesImageMultiTransform 4 ${mocodir}/${subjectID}_rfMRI_moco_r03.nii.gz ${procdir}/${subjectID}_rsfMRI_processed_r03.nii.gz  -R ${template}  ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz  ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt &
#Warp_PID4=$!

#WarpTimeSeriesImageMultiTransform 4 ${mocodir}/${subjectID}_rfMRI_moco_r04.nii.gz ${procdir}/${subjectID}_rsfMRI_processed_r04.nii.gz  -R ${template}  ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz  ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt &
#Warp_PID5=$!

wait $Warp_PID1
echo "CC"
cp ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz ${procdir}
cp ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${procdir}
cp ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt ${procdir}
cp ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${procdir}
cp ${template} ${procdir}
cp ${coregdir}/${subjectID}_rfMRI_v0_correg.mat  ${procdir}
cp ${mocodir}/${subjectID}_rfMRI_moco_rest.nii.gz ${procdir}
cp ${anatdir}/${subjectID}_run-01_T1w_bc_ss.nii.gz  ${procdir}

echo "DD"

#wait $Warp_PID1
##wait $Warp_PID2
##wait $Warp_PID3
##wait $Warp_PID4
##wait $Warp_PID5

end=`date +%s`
echo $((end-start)) >> ${procdir}/benchTime.txt
echo 'end of program'

