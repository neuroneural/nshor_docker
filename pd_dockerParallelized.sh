#!/bin/bash


#The script expects the user to prepare a text file with a list of paths one line per subject.  (DONE)
#The list will be indexed by job number and is meant to be run on the entire list in slurm from start to end. (DONE)
# TODO - If the jobs in slurm crash and restarted every subject needs to be re-processed.

set -x
set -e

#get data provided as input from user input file
while getopts f:a:j:c:b:s:l:r:o: flag
do
        case "${flag}" in
                f) 
			func_file=${OPTARG}
			func_filepath=/func/${func_file}
			;;
                a) 
			anat_file=${OPTARG}
			anat_filepath=/anat/${anat_file}
			;;
                j) 
			json_file=${OPTARG}
			json_filepath=/func/${json_file}
			;;
                c) 
			biasch_file=${OPTARG}
			biasch_filepath=/func/${biasch_file}
			;;
                b) 
			biasbc_file=${OPTARG}
			biasbc_filepath=/func/${biasbc_file}
			;;
                s) 
			sbref_file=${OPTARG}
			sbref_filepath=/func/${sbref_file}
			;;
                l) 
			spinlr_file=${OPTARG}
			spinlr_filepath=/func/${spinlr_file}
			;;
                r) 
			spinrl_file=${OPTARG}
			spinrl_filepath=/func/${spinrl_file}
			;;
                o) 
			out_filepath=${OPTARG}
			;;
        esac
done

#print the filenames to console for debugging purposes
echo "func_file : ${func_file}"
echo "anat_file : ${anat_file}"
echo "json_file : ${json_file}"
echo "biasch_file : ${biasch_file}"
echo "biasbc_file : ${biasbc_file}"
echo "sbref_file : ${sbref_file}"
echo "spinlr_file : ${spinlr_file}"
echo "out_filepath : ${out_filepath}"


#reassign filepaths using singularity bind points

#extract subject ID from out filepath, 
#this assumes subject ID is either at the end of the output filepath
#or that it is right before the ses-01 directory (assuming there can be multiple sessions)
run_dir=`basename $out_filepath`
if [[ $out_filepath == *"ses"* ]]
then
	path_ending_in_ID=`dirname $out_filepath`
else
	path_ending_in_ID=$out_filepath
fi

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

#make output directories for intermediate files
mocodir=${outputUniverse}/derivatives/${subjectID}/motion
coregdir=${outputUniverse}/derivatives/${subjectID}/coregistration
normdir=${outputUniverse}/derivatives/${subjectID}/normalization
procdir=${outputUniverse}/derivatives/${subjectID}/processed
anatdir=${outputUniverse}/derivatives/${subjectID}/anat
funcdir=${outputUniverse}/derivatives/${subjectID}/func

#Makes the directories
mkdir -p ${coregdir}
mkdir -p ${mocodir}
mkdir -p ${normdir}
mkdir -p ${procdir}
mkdir -p ${anatdir}
mkdir -p ${funcdir}

#performs bias field correction using bias channel and body coil fieldmaps
###NOTE: for any of the data that has LR or RL, we need to infer what that is before running these, these methods are not generalized to the RL/LR (can probably use the filename)
function afni_set() {
	if [ -f ${outputUniverse}/derivatives/$subjectID/bias_field/${subjectID}_bias_field.nii.gz  ]
	then
		rm ${outputUniverse}/derivatives/$subjectID/bias_field/${subjectID}_bias_field.nii.gz
	fi


    3dcalc -a ${biasch_filepath} -b ${biasbc_filepath} -prefix ${outputUniverse}/derivatives/$subjectID/bias_field/${subjectID}_bias_field.nii.gz -expr 'b/a'
    echo "function afni_set debug 1"


	if [ -f ${outputUniverse}/derivatives/$subjectID/bias_field/${subjectID}_bias_field_deobl.nii.gz  ]
	then
		rm ${outputUniverse}/derivatives/$subjectID/bias_field/${subjectID}_bias_field_deobl.nii.gz
	fi
 

    3dWarp -deoblique -prefix ${outputUniverse}/derivatives/$subjectID/bias_field/${subjectID}_bias_field_deobl.nii.gz ${outputUniverse}/derivatives/$subjectID/bias_field/${subjectID}_bias_field.nii.gz

	if [ -f ${outputUniverse}/derivatives/$subjectID/bias_field/${subjectID}_bias_field_deobl.nii.gz ]; then
		echo "${subjectID}_bias_field_deobl.nii.gz file exists"
	else 
		echo "${subjectID}_bias_field_deobl.nii.gz file DOES NOT exist"
	fi
	if [ -f ${outputUniverse}/derivatives/$subjectID/bias_field/${subjectID}_bias_field.nii.gz ]; then
		echo "${subjectID}_bias_field.nii.gz file exists"
	else 
		echo "${subjectID}_bias_field.nii.gz file DOES NOT exist"
	fi
    echo "function afni_set debug 2"


	if [ -f ${outputUniverse}/derivatives/$subjectID/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz  ]
	then
		rm ${outputUniverse}/derivatives/$subjectID/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz
	fi

    3dAutomask -dilate 2 -prefix ${outputUniverse}/derivatives/$subjectID/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz ${sbref_filepath}

    if [ -f ${outputUniverse}/derivatives/$subjectID/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz ]; then
	    echo "Brain mask created successfully."
    else
	    echo "Error: Brain mask creation failed."
    fi
    echo "function afni_set debug 3"


    3dWarp -oblique_parent ${func_filepath} -gridset ${func_filepath} -prefix ${outputUniverse}/derivatives/$subjectID/bias_field/${subjectID}_biasfield_card2EPIoblN.nii.gz ${outputUniverse}/derivatives/$subjectID/bias_field/${subjectID}_bias_field_deobl.nii.gz
   
 
	if [ -f ${outputUniverse}/derivatives/$subjectID/bias_field/${subjectID}_biasfield_card2EPIoblN.nii.gz ]
	then
		echo "${outputUniverse}/derivatives/${subjectID}_biasfield_card2EPIoblN.nii.gz file created successfully"
	else
		echo "${outputUniverse}/derivatives/${subjectID}_biasfield_card2EPIoblN.nii.gz creation failed"
	fi

    echo "function afni_set debug 4"


#output file is not created
    3dcalc -float -a ${func_filepath} -b ${outputUniverse}/derivatives/$subjectID/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz -c ${outputUniverse}/derivatives/$subjectID/bias_field/${subjectID}_biasfield_card2EPIoblN.nii.gz  -prefix ${funcdir}/${subjectID}_3T_rfMRI_REST1_RL_DEBIAS.nii.gz -expr 'a*b*c'
    echo "function afni_set debug 5"

    3dcalc  -float  -a ${sbref_filepath} -b ${outputUniverse}/derivatives/$subjectID/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz -c ${outputUniverse}/derivatives/$subjectID/bias_field/${subjectID}_biasfield_card2EPIoblN.nii.gz  -prefix ${funcdir}/${subjectID}_3T_rfMRI_REST1_RL_DEBIAS_SBRef.nii.gz -expr 'a*b*c'
    echo "function afni_set debug 6"
}

#performs topup correction using acquisition parameters, LR/RL spin echo and sbref fieldmaps 
function topup_set {
        #sets the acquisition parameters to use for topup, this file should exist in the subject's func directory
        touch ${outputUniverse}/derivatives/$subjectID/bias_field/acqparams.txt
        acqparams=${outputUniverse}/derivatives/$subjectID/bias_field/acqparams.txt
        echo -e "1 0 0 1\n-1 0 0 1" > $acqparams


        #Field Distortion Correction
        mkdir -p ${outputUniverse}/derivatives/$subjectID/fieldmap/

        fslmerge -t ${outputUniverse}/derivatives/$subjectID/fieldmap/${subjectID}_3T_Phase_Map.nii.gz ${spinlr_filepath} ${spinrl_filepath}

        topup --imain=${outputUniverse}/derivatives/$subjectID/fieldmap/${subjectID}_3T_Phase_Map.nii.gz --datain=$acqparams --out=${outputUniverse}/derivatives/$subjectID/fieldmap/$subjectID\_TOPUP --fout=${outputUniverse}/derivatives/$subjectID/fieldmap/$subjectID\_TOPUP_FIELDMAP.nii.gz --iout=${outputUniverse}/derivatives/$subjectID/fieldmap/${subjectID}_TOPUP_CORRECTION.nii.gz

        if [ -f ${outputUniverse}/derivatives/$subjectID/fieldmap/${subjectID}_TOPUP_FIELDMAP.nii.gz ]; then
                echo   "TOPUP SUCCESS"
        fi

        applytopup --imain=${outputUniverse}/derivatives/${subjectID}/func/${subjectID}_3T_rfMRI_REST1_LR_DEBIAS.nii.gz --inindex=1 --method=jac --datain=$acqparams --topup=${outputUniverse}/derivatives/${subjectID}/fieldmap/${subjectID}_TOPUP --out=${outputUniverse}/derivatives/${subjectID}/func/${subjectID}_3T_rfMRI_REST1_LR_DEBIAS_UNWARPED.nii.gz &

        topup1_PID=$!

        applytopup --imain=${outputUniverse}/derivatives/$subjectID/func/${subjectID}_3T_rfMRI_REST1_LR_DEBIAS_SBRef.nii.gz --inindex=1 --method=jac --datain=$acqparams --topup=${outputUniverse}/derivatives/$subjectID/fieldmap/${subjectID}_TOPUP --out=${outputUniverse}/derivatives/$subjectID/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_DEBIAS_UNWARPED.nii.gz &
        topup2_PID=$!
        echo 'finished topup'
        wait $topup1_PID
        wait $topup2_PID
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

	#slice timing correction
        if [ -z "$json_file" ]
        then
                echo "no json file was included in input text file"
		# Get the TR value from the nii header
		TR=$(fslval $func_filepath pixdim4)
		TR=$(echo "scale=0; $TR/1000" | bc)

		#Get the number of slices from the nii header
		num_slices=$(fslval $func_filepath dim3)

		#Try to extract the slice order from nii header
		slice_order=$(fslval $func_filepath slice_order)
		if [ -z "$slice_order" ]
		then
			slice_order="ascending"
		fi
		
		# Calcuate the time at which each slice was acquired
		increment=$(echo "scale=6; $TR / $num_slices" | bc)
		case $slice_order in
			"ascending")
				slice_times=($(seq -f "%.4f" 0 $increment $(echo "$TR - $increment" | bc)))
				;;
			"descending")
				slice_times=($(seq 0 $((num_slices-1)) | xargs -I{} echo "scale=6; $increment * {}" | bc))
				;;
			*)
				echo "Error: Unsupported slice order '$slice_order'" >&2
		esac
		
		echo "${slice_times[@]}" | tr ' ' '\n' > slice_timing_file.txt
		slice_timing_file=slice_timing_file.txt
		slice_duration=$(fslval $func_filepath slice_duration)

		if [ -f Despike_${suffix}.nii.gz ]
		then
			rm Despike_${suffix}.nii.gz
		fi

		3dDespike -NEW -prefix Despike_${suffix}.nii.gz ${epi_in}

		if (( $(echo "$slice_duration < $TR" | bc -l) )); then
    			echo "multiband data detected"
			echo $slice_timing_file
			slicetimer -i Despike_${suffix}.nii.gz -o ${mocodir}/tshift_Despiked_${suffix}.nii.gz --tcustom=$slice_timing_file
		else
    			echo "singleband data detected"
			slicetimer -i Despike_${suffix}.nii.gz -o ${mocodir}/tshift_Despiked_${suffix}.nii.gz -r $TR
			
		fi
	
		

        else
                #Metadata extraction from BIDS compliant json sidecar file
                abids_json_info.py -field SliceTiming -json ${json_filepath} | sed 's/[][]//g' | tr , '\n' | sed 's/ //g' > tshiftparams.1D
                #Finds the number where the slice value is 0 in the slice timing
                SliceRef=`cat tshiftparams.1D | grep -m1 -n -- "0$" | cut -d ":" -f1`

                #Pulls the TR from the json file. This tells 3dTshift what the scaling factor is
                TR=`abids_json_info.py -field RepetitionTime -json ${json_filepath}`

		3dDespike -NEW -prefix Despike_${suffix}.nii.gz ${epi_in}

		#Timeshifts the data. It's SliceRef-1 because AFNI indexes at 0 so 1=0, 2=1, 3=2, ect
		3dTshift -tzero $(($SliceRef-1)) -tpattern @tshiftparams.1D -TR ${TR} -quintic -prefix tshift_Despiked_${suffix}.nii.gz Despike_${suffix}.nii.gz
       		3dTshift -tzero 0 -tpattern '${Tshiftparams} ' -quintic -prefix tshift_${suffix} ${epi_in}
      		3dvolreg -verbose -zpad 1 -base ${ref_vol} -heptic -prefix moco_${suffix} -1Dfile ${subjectID}_motion.1D -1Dmatrix_save mat.${subjectID}.1D tshift_${suffix}+orig  
        fi

    
	3dvolreg -verbose -zpad 1 -base ${ref_vol} -heptic -prefix moco_${suffix} -1Dfile ${subjectID}_motion.1D -1Dmatrix_save mat.${subjectID}.1D ${mocodir}/Despike_${suffix}.nii.gz

	if [ -f ${mocodir}/${subjectID}_rfMRI_moco_${suffix}.nii.gz  ]
	then
		rm ${mocodir}/${subjectID}_rfMRI_moco_${suffix}.nii.gz
	fi

    	3dresample -orient RPI -inset moco_${suffix}+tlrc.HEAD -prefix ${mocodir}/${subjectID}_rfMRI_moco_${suffix}.nii.gz

}



vrefbrain=T1_bc_ss.nii.gz
vrefhead=T1_bc.nii.gz

vepi=$func_filepath
vout=${subjectID}_rfMRI_v0_correg

epi_orig=$func_filepath


skullstrip ${anatdir}

if [[ (-z "${biasch_file}") || (-z "${biasbc_file}") || (-z "${sbref_file}") ]]; then 
	echo "bias channel and sbref field maps were not included for bias correction."
fi

if [[ (-n "${biasch_file}") || (-n "${biasbc_file}") || (-n "${sbref_file}") ]]; then 
	afni_set &
	AFNI_PID=$!
fi



if [[ (-z "${spinlr_file}") || (-z "${spinrl_file}") ]]
then
        echo "LR or RL spin echo field maps were not included for topup correction."
fi

if [[ (-n "${spinlr_file}") || (-n "${spinrl_file}")  ]]
then
        topup_set &
        TOPUP_PID=$!
fi





antsRegistrationSyN.sh -d 3 -n 16 -f ${template} -m ${anatdir}/T1_bc_ss.nii.gz -x ${templatemask} -o ${normdir}/${subjectID}_ANTsReg &
ANTS_PID=$! 

if [[ (-z "${biasch_file}") || (-z "${sbref_file}") ]]
then
        echo
fi

if [[ (-n "${biasch_file}") || (-n "${sbref_file}")  ]]
then
        wait ${AFNI_PID}
fi

if [[ (-z "${spinlr_file}") || (-z "${spinrl_file}") ]]
then
	echo
fi

if [[ (-n "${spinlr_file}") || (-n "${spinrl_file}") ]]
then
	wait ${TOPUP_PID}
fi

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
