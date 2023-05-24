#!/bin/bash

DATA_DIRECTORY=/data/hcp-plis/drive01
#PARAMS_DIRECTORY=/data/neuromark2/Data/HCP_Development/Data_BIDS/Raw_Data/HCD0001305_V1_MR/ses_01/func1_PA
PARAMS_DIRECTORY=/data/users2/jwardell1/nshor_docker/hcp-project
num_subs=`ls $DATA_DIRECTORY | wc -l`
IFS=$'\n' sub_ids=($(cat /data/users2/jwardell1/nshor_docker/hcp-project/HCP/subjects.txt))
PATH_FILE=/data/users2/jwardell1/nshor_docker/hcp-project/HCP/paths
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
	
	OUTPUT_DIRECTORY=/data/users2/jwardell1/nshor_docker/hcp-project/HCP
	mkdir "${OUTPUT_DIRECTORY}/${subjectID}"
	sub_outpath="${OUTPUT_DIRECTORY}/${subjectID}"
	echo "${sub_outpath}" >> $PATH_FILE
done
