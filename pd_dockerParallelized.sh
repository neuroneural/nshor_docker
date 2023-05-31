#!/bin/bash

#  Print commands and their arguments as they are executed.
set -x

#  Sets MNI project to true by default
mni_project=true


#    Getopts is used by shell procedures to parse positional parameters.
#    Check for the optional flags that were provided in the pd_dockerParallelized.sh script
while getopts f:a:j:c:b:s:l:r:p:o: flag
do
        case "${flag}" in
                f) # -f flag was used to provide the functional MRI image file 
			func_file=${OPTARG}
			func_filepath=/func/${func_file}
			;;
                a) # -a flag was used to provide the anatomical MRI image file
			anat_file=${OPTARG}
			anat_filepath=/anat/${anat_file}
			;;
                j) # -j flag was used to provide the json sidecar file
			json_file=${OPTARG}
			json_filepath=/func/${json_file}
			;;
                c) # -c flag was used to provide the bias channel fieldmap file
			biasch_file=${OPTARG}
			biasch_filepath=/func/${biasch_file}
			;;
                b) # -b flag was used to provide the body coil fieldmap file
			biasbc_file=${OPTARG}
			biasbc_filepath=/func/${biasbc_file}
			;;
                s) # -s flag was used to provide the single band reference image file
			sbref_file=${OPTARG}
			sbref_filepath=/func/${sbref_file}
			;;
                l) # -l flag was used to provide the left-right spin echo fieldmap file
			spinlr_file=${OPTARG}
			spinlr_filepath=/func/${spinlr_file}
			;;
                r) # -r flag was used to provide the right-left spin echo fieldmap file
			spinrl_file=${OPTARG}
			spinrl_filepath=/func/${spinrl_file}
			;;
                p) # -p flag was used to provide the aquisition parameters text file
			params_file=${OPTARG}
			params_filepath=/params/${params_file}
			;;
                o) # -o flag was used to provide the output directory for the processed images
			out_filepath=${OPTARG}
			;;
                n) # -n flag was used to indicate not putting subject into MNI space
			mni_project=false
			;;
        esac
done


# Print file names to the console how they were parsed into script
echo "func_file : ${func_file}"
echo "anat_file : ${anat_file}"
echo "json_file : ${json_file}"
echo "biasch_file : ${biasch_file}"
echo "biasbc_file : ${biasbc_file}"
echo "sbref_file : ${sbref_file}"
echo "spinlr_file : ${spinlr_file}"
echo "spinrl_file : ${spinrl_file}"
echo "params_file : ${params_file}"
echo "out_filepath : ${out_filepath}"
echo "mni_project :  ${mni_project}"



# Extract subject ID from out filepath.
# This assumes subject ID is either at the end of the output filepath...
# ...or that it is one directory above the ses-01 directory (assuming there can be multiple sessions)
run_dir=`basename $out_filepath`
if [[ $out_filepath == *"ses"* ]]
then
	# If the specified output directory contains "ses", then the subject ID is one directory above the "ses" directory
	path_ending_in_ID=`dirname $out_filepath`
else
	# If the specified output directory does not contain "ses", then the subject ID is at the very end of the specified output directory
	path_ending_in_ID=$out_filepath
fi

# The basename utility deletes any prefix ending with the last slash ‘/’ character present in string
# Extract the subject ID from the path ending in id and capture it in a variable to use later
subjectID=`basename $path_ending_in_ID`
echo "subjectID is ${subjectID}"


# Location of the temporary filesystem in the singularity container
tmpfs=/dev/shm

# Location on cluster mounted into sif container for final processed image
outputMount=/out

# Capture the start time of the script to measure benchmark time
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

#Deletes files on conatiner for this subject in case they exist already in cache
rm -rf ${tmpfs}/derivatives/$subjectID


#Create directory for subject intermediate derivative files
mkdir -p  ${tmpfs}/derivatives/$subjectID



# Sets locations of intermediate file directories
mocodir=${tmpfs}/derivatives/${subjectID}/motion
coregdir=${tmpfs}/derivatives/${subjectID}/coregistration
normdir=${tmpfs}/derivatives/${subjectID}/normalization
procdir=${tmpfs}/derivatives/${subjectID}/processed
anatdir=${tmpfs}/derivatives/${subjectID}/anat
funcdir=${tmpfs}/derivatives/${subjectID}/func
fmapdir=${tmpfs}/derivatives/$subjectID/fieldmap
biasdir=${tmpfs}/derivatives/$subjectID/bias_field
sbrefdir=${tmpfs}/derivatives/$subjectID/SBRef

# Non-destructively creates intermediate file directories (probably can just create them due to line 121)
mkdir -p ${coregdir}
mkdir -p ${mocodir}
mkdir -p ${normdir}
mkdir -p ${procdir}
mkdir -p ${anatdir}
mkdir -p ${funcdir}
mkdir -p ${fmapdir}
mkdir -p ${biasdir}
mkdir -p ${sbrefdir}

# (Bias Correction for voxel intensity distortions) Calls the AFNI linux utilities to prepare de-baised fMRI and SBREF subject data
function afni_set() {
	# Performs voxel-by-voxel division on the body coil and bias channel fieldmaps to obtain receive coil sensitivity fieldmap
	3dcalc -a ${biasch_filepath} -b ${biasbc_filepath} -prefix ${tmpfs}/derivatives/$subjectID/bias_field/${subjectID}_bias_field.nii.gz -expr 'b/a'

	# Deobliques previously created sensitivity fieldmap, puts it in cartesian coordinate system
	3dWarp -deoblique -prefix ${tmpfs}/derivatives/$subjectID/bias_field/${subjectID}_bias_field_deobl.nii.gz ${tmpfs}/derivatives/$subjectID/bias_field/${subjectID}_bias_field.nii.gz

	# Computes the brain mask from the singleband reference (SBREF) image
	3dAutomask -dilate 2 -prefix ${tmpfs}/derivatives/$subjectID/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz ${sbref_filepath}

	# Warps the deobliqued sensitivity fieldmaps into the subject's anatomical coordinate space
	3dWarp -oblique_parent ${func_filepath} -gridset ${func_filepath} -prefix ${tmpfs}/derivatives/$subjectID/bias_field/${subjectID}_biasfield_card2EPIoblN.nii.gz ${tmpfs}/derivatives/$subjectID/bias_field/${subjectID}_bias_field_deobl.nii.gz
   
	# Bias Correction on subject fMRI: Performs voxel-wise multiplication between the functional MRI image, SBREF mask, and subject warped sensitivity fieldmap.
	3dcalc -float -a ${func_filepath} -b ${tmpfs}/derivatives/$subjectID/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz -c ${tmpfs}/derivatives/$subjectID/bias_field/${subjectID}_biasfield_card2EPIoblN.nii.gz  -prefix ${funcdir}/${subjectID}_3T_rfMRI_REST1_RL_DEBIAS.nii.gz -expr 'a*b*c'

	# Bias Correction on subject SBREF Mask: Perform voxel-wise multiplication between SBREF image, SBREF mask, and subject warped sensitivity fieldmap.
	3dcalc  -float  -a ${sbref_filepath} -b ${tmpfs}/derivatives/$subjectID/SBRef/${subjectID}_3T_rfMRI_REST1_LR_SBRef_Mask.nii.gz -c ${tmpfs}/derivatives/$subjectID/bias_field/${subjectID}_biasfield_card2EPIoblN.nii.gz  -prefix ${funcdir}/${subjectID}_3T_rfMRI_REST1_RL_DEBIAS_SBRef.nii.gz -expr 'a*b*c'
}

# (TOPUP Correction for Geometric Distortions)
function topup_set {
	# acqparams is a 4xN matrix : first three cols are xyz phase encoding directions, last col is readout time, stored in a text file provided by user
	# N is number of volumes in ${fmapdir}/${subjectID}_3T_Phase_Map.nii.gz	 (created as output from FSL merge function below)
	# See here for more information: https://web.mit.edu/fsl_v5.0.10/fsl/doc/wiki/topup(2f)TopupUsersGuide.html#A--datain
	acqparams=$params_filepath

	# Concatenates left-right and right-left spin echo fieldmaps into one fieldmap
        fslmerge -t ${fmapdir}/${subjectID}_3T_Phase_Map.nii.gz ${spinlr_filepath} ${spinrl_filepath}


	# Estimates the geometric susceptibility fieldmap using the LR/RL fieldmap and acquisition parameters matrix
        topup --imain=${fmapdir}/${subjectID}_3T_Phase_Map.nii.gz --datain=$acqparams --out=${fmapdir}/${subjectID}_TOPUP --fout=${fmapdir}/${subjectID}_TOPUP_FIELDMAP.nii.gz --iout=${fmapdir}/${subjectID}_TOPUP_CORRECTION.nii.gz  -v

	# Applies the estimated geometric susceptibility fieldmap to the de-biased fMRI data created from function afni_set (as a background process)
        applytopup --imain=${funcdir}/${subjectID}_3T_rfMRI_REST1_RL_DEBIAS.nii.gz --inindex=1 --method=jac --datain=$acqparams --topup=${tmpfs}/derivatives/${subjectID}/fieldmap/${subjectID}_TOPUP --out=${funcdir}/${subjectID}_3T_rfMRI_REST1_RL_DEBIAS_UNWARPED.nii.gz -v &
	
	# Catch the process id (PID) of the applytopup command for fMRI TOPUP correction
        topup1_PID=$!

	# Applies the the estimated geometric susceptibility fieldmap to the de-biased SBREF mask created from function afni_set (as a background process)
        applytopup --imain=${tmpfs}/derivatives/$subjectID/func/${subjectID}_3T_rfMRI_REST1_RL_DEBIAS_SBRef.nii.gz --inindex=1 --method=jac --datain=$acqparams --topup=${tmpfs}/derivatives/$subjectID/fieldmap/${subjectID}_TOPUP --out=${tmpfs}/derivatives/$subjectID/SBRef/${subjectID}_3T_rfMRI_REST1_RL_SBRef_DEBIAS_UNWARPED.nii.gz -v &

	# Catch the PID of the applytopup command for SBREF TOPUP correction
        topup2_PID=$!

	# Wait for fMRI and SBREF TOPUP correction to complete
        wait $topup1_PID
        wait $topup2_PID

        echo 'finished topup'
}

# Align subject fMRI with sMRI (corregistration)
# EPI is a technique used to capture BOLD signal
function epireg_set() {
        coregdir=$1 # directory where intermediate files associated with corregistration are written
        vrefbrain=$2 # skull stripped bias corrected T1 anatomical image
        vepi=$3 # subject fMRI file
        vout=$4 # name of file to be output by this function (final corregistered result)
        vrefhead=$5 # bias corrected T1 anat image with head still present (before skull strip)

	# Move to corregistration intermediate directory and copy the anatomical skull and brain data here 
        cd ${coregdir}
        cp ../anat/${vrefbrain} .
        cp ../anat/${vrefhead} .
      
	# Creates brain matter segmentation probability maps
        $FSLDIR/bin/fast -N -o ${vout}_fast ${vrefbrain}

	# Thresholds segmentation probability maps to produce a binary white matter segmentation image
        $FSLDIR/bin/fslmaths ${vout}_fast_pve_2 -thr 0.5 -bin ${vout}_fast_wmseg

	# Computes a matrix to align the subject fMRI image to sMRI image (?)
        $FSLDIR/bin/flirt -ref ${vrefbrain} -in ${vepi} -dof 6 -omat ${vout}_init.mat

        $FSLDIR/bin/flirt -ref ${vrefhead} -in ${vepi} -dof 6 -cost bbr -wmseg ${vout}_fast_wmseg -init ${vout}_init.mat -omat ${vout}.mat -out ${vout} -schedule ${FSLDIR}/etc/flirtsch/bbr.sch -v

        $FSLDIR/bin/applywarp -i ${vepi} -r ${vrefhead} -o ${vout} --premat=${vout}.mat --interp=spline -v

	echo "EPI APPLYWARP DONE"
}

function skullstrip() {
    anatdir=$1

    #Performs the N3/4 Bias correction on the T1 and Extracts the Brain
    N4BiasFieldCorrection -d 3 -i $anat_filepath -o ${anatdir}/T1_bc.nii.gz

    cd /ROBEX

    ./ROBEX ${anatdir}/T1_bc.nii.gz ${anatdir}/T1_bc_ss.nii.gz
}

# Performs slice timing correction and then uses 3dvolreg to align despiked data to one reference volume (first volume)
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

		#Timeshifts the data. It's SliceRef-1 because AFNI indexes at 0 so 1=0, 2=1, 3=2, etc

		3dTshift -tzero $(($SliceRef-1)) -tpattern @tshiftparams.1D -TR ${TR} -quintic -prefix tshift_Despiked_${suffix}.nii.gz Despike_${suffix}.nii.gz
        fi

   	#   Rotate all volumes to align with the first volume as a reference 
	3dvolreg -verbose -zpad 1 -base ${ref_vol} -heptic -prefix moco_${suffix}+orig -1Dfile ${subjectID}_motion.1D -1Dmatrix_save mat.${subjectID}.1D Despike_${suffix}.nii.gz

	
	echo `ls .`

	#   Resample the points into the correct coordinate system ? Not sure
	if [ -f moco_${suffix}+tlrc.HEAD  ]; then
		3dresample -orient RPI -inset moco_${suffix}+tlrc.HEAD -prefix ${mocodir}/${subjectID}_rfMRI_moco_${suffix}.nii.gz
	fi

	if [ -f moco_${suffix}+orig.HEAD  ]; then
		3dresample -orient RPI -inset moco_${suffix}+orig.HEAD -prefix ${mocodir}/${subjectID}_rfMRI_moco_${suffix}.nii.gz
	fi

	echo "moco done"

}


#  Skull Stripped Bias Corrected Anatomical T1 Image
vrefbrain=T1_bc_ss.nii.gz

#  Bias Corrected Anatomical T1 Image (Head Included)
vrefhead=T1_bc.nii.gz

#  EPI Image of BOLD Signal
vepi=$func_filepath

#  Suffix for Corregistered Image
vout=${subjectID}_rfMRI_v0_correg


#  ? Might should be deleted but this is the original EPI Image of BOLD Signal
epi_orig=$func_filepath


#   Function call to Perform T1 Bias Correction and Skull Strip
skullstrip ${anatdir} 


#  Checks if necessary fieldmasps were provided before calling the function for fMRI bias correction (optional)
if [[ (-z "${biasch_file}") || (-z "${biasbc_file}") || (-z "${sbref_file}") ]]; then 
	echo "bias channel and sbref field maps were not included for bias correction."
else
	afni_set &
	AFNI_PID=$!
fi


#  Checks if necessary fieldmasps were provided before calling the function for fMRI topup (optional)
if [[ (-z "${spinlr_file}") || (-z "${spinrl_file}") ]]
then
        echo "LR or RL spin echo field maps were not included for topup correction."
else
        topup_set &
        TOPUP_PID=$!
fi



if [ "$mni_project" = true  ]; then
	#warps T1 image to MNI152 template
	antsRegistrationSyN.sh -d 3 -n 16 -f ${template} -m ${anatdir}/T1_bc_ss.nii.gz -x ${templatemask} -o ${normdir}/${subjectID}_ANTsReg &
	ANTS_PID=$! 
fi


#   If fieldmaps were provided for bias correction, wait for the bias correction process to finish, otherwise don't do anything
if [[ (-z "${biasch_file}") || (-z "${sbref_file}") ]]
then
        echo
else
        wait ${AFNI_PID}
fi


#   If fieldmaps were provided for topup correction, wait for the topup correction process to finish, otherwise don't do anything
if [[ (-z "${spinlr_file}") || (-z "${spinrl_file}") ]]
then
	echo
else
	wait ${TOPUP_PID}
fi


#   From the original script. Not exactly sure why this is here. It multiplies the epi_orig voxels by 1 and puts it in ${coregdir}/${func_file}
3dcalc -a0 ${epi_orig} -prefix ${coregdir}/${func_file} -expr 'a*1'


#  Function call to epireg_set, the function that performs alignment to T1 Image
epireg_set ${coregdir} ${vrefbrain} ${vepi} ${vout} ${vrefhead}  &
EPI_PID=$!


#   Function call to moco_sc, the function that performs slice timing correction and motion correction
moco_sc ${epi_orig} ${coregdir}/${func_file} ${subjectID} rest &
SCMOCO_PID=$!


#   ??? Does motion correction? But I thought that already happened.. Aligns the fMRI file to the corregistered file ?
mcflirt -in ${epi_orig} -reffile ${coregdir}/${func_file} -out ${mocodir}/${subjectID}_rfMRI_moco.nii.gz -mats -plots -rmsrel -rmsabs -report &

#   Wait for moco_sc and epireg_set to finish
wait $SCMOCO_PID
wait $EPI_PID


#   Translates the FSL corregistration matrix to one that ANTs can use
c3d_affine_tool -ref ${coregdir}/T1_bc_ss.nii.gz -src ${coregdir}/${func_file} ${coregdir}/${subjectID}_rfMRI_v0_correg.mat -fsl2ras -oitk ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt


if [ "$mni_project" = true  ]; then
	wait $ANTS_PID

	#computes the ANTs matrix for warping functional image to MNI152 T1 image
	antsApplyTransforms -d 4 -e 3 -i ${mocodir}/${subjectID}_rfMRI_moco.nii.gz -r $template -n BSpline -t ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz -t ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat -t ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt -o ${procdir}/${subjectID}_rsfMRI_processed.nii.gz

	#warps functional image to MNI152 T1 image using ANTs
	WarpTimeSeriesImageMultiTransform 4 ${mocodir}/${subjectID}_rfMRI_moco_rest.nii.gz ${procdir}/${subjectID}_rsfMRI_processed_rest.nii.gz  -R ${template}  ${normdir}/${subjectID}_ANTsReg1Warp.nii.gz  ${normdir}/${subjectID}_ANTsReg0GenericAffine.mat ${coregdir}/${subjectID}_rfMRI_FSL_to_ANTs_coreg.txt
fi

mkdir -p ${outputMount}/processed
mtdPrcDir=${outputMount}/processed

filenii="${func_file%.*}"
filename="${filenii%.*}"

#  Write final processed file to server
if [ "$mni_project" = true  ]; then
	cp ${procdir}/${subjectID}_rsfMRI_processed_rest.nii.gz ${mtdPrcDir}/${filename}_processed.nii.gz
else
	cp ${mocodir}/${subjectID}_rfMRI_moco_rest.nii.gz ${mtdPrcDir}/${filename}_processed.nii.gz
fi

#  Write displacement parameters to server
cp ${mocodir}/${subjectID}_rfMRI_moco.nii.gz.par ${mtdPrcDir}/${subjectID}_rfMRI_moco.nii.gz.par

#  Clean up shared memory directory
rm -rf ${tmpfs}/derivatives/$subjectID

#  Write benchmark time to server
end=`date +%s`
echo $((end-start)) >> ${mtdPrcDir}/benchTime.txt
