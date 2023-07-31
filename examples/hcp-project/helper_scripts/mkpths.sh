#!/bin/bash

project_dir=/data/users2/jwardell1/nshor_docker/examples/hcp-project
DATA_DIRECTORY=/data/hcp-plis/drive01
PARAMS_DIRECTORY=$project_dir

subs_file=${project_dir}/HCP/subjects.txt
num_subs=`cat $subs_file | wc -l`
IFS=$'\n' sub_ids=($(cat $subs_file))

PATH_FILE=${project_dir}/HCP/paths
mask_filepath=${project_dir}/HCP/group_mean_masks/groupmeanmask.nii

touch ${PATH_FILE}

for(( i=0; i<$num_subs; i++))
do
	subjectID=${sub_ids[$i]}
	echo "${DATA_DIRECTORY}/${subjectID}/unprocessed/3T/rfMRI_REST1_RL/${subjectID}_3T_rfMRI_REST1_RL.nii.gz" >> $PATH_FILE
	echo "${DATA_DIRECTORY}/${subjectID}/unprocessed/3T/T1w_MPR1/${subjectID}_3T_T1w_MPR1.nii.gz" >> $PATH_FILE
	echo "${DATA_DIRECTORY}/${subjectID}/unprocessed/3T/rfMRI_REST1_RL/${subjectID}_3T_SpinEchoFieldMap_LR.nii.gz" >> $PATH_FILE
	echo "${DATA_DIRECTORY}/${subjectID}/unprocessed/3T/rfMRI_REST1_RL/${subjectID}_3T_SpinEchoFieldMap_RL.nii.gz" >> $PATH_FILE
	echo "${DATA_DIRECTORY}/${subjectID}/unprocessed/3T/rfMRI_REST1_RL/${subjectID}_3T_BIAS_32CH.nii.gz" >> $PATH_FILE
	echo "${DATA_DIRECTORY}/${subjectID}/unprocessed/3T/rfMRI_REST1_RL/${subjectID}_3T_BIAS_BC.nii.gz" >> $PATH_FILE
	echo "${DATA_DIRECTORY}/${subjectID}/unprocessed/3T/rfMRI_REST1_RL/${subjectID}_3T_rfMRI_REST1_RL_SBRef.nii.gz" >> $PATH_FILE
	echo "${PARAMS_DIRECTORY}/datain.txt" >> $PATH_FILE
	echo "${mask_filepath}"  >> $PATH_FILE
	
	OUTPUT_DIRECTORY=/data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP
	mkdir "${OUTPUT_DIRECTORY}/${subjectID}"
	sub_outpath="${OUTPUT_DIRECTORY}/${subjectID}"
	echo "${sub_outpath}" >> $PATH_FILE
done
total_lines=$(($num_subs * 10))

echo "for $num_subs subjects and 10 lines for each subject, there should be a total of $total_lines lines in the paths file."
