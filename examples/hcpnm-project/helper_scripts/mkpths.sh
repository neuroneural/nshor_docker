#!/bin/bash

FUNC_DATA=/data/qneuromark/Data/HCP/Data_BIDS/Preprocess_Data
FUNC_SUFFIX=rfMRI_REST1_LR
FUNC_FILENAME=rest_prep.nii.gz

ANAT_DATA=/data/qneuromark/Data/HCP/Data_BIDS/Raw_Data
ANAT_SUFFIX=T1w_MPR1
ANAT_FILENAME=T1.nii.gz

OUTPUT_DIRECTORY=/data/users2/jwardell1/nshor_docker/examples/hcpnm-project/HCP

num_subs=`ls $FUNC_DATA | wc -l`
IFS=$'\n' sub_ids=($(cat /data/users2/jwardell1/nshor_docker/examples/hcpnm-project/HCP/subjects.txt))
PATH_FILE=/data/users2/jwardell1/nshor_docker/examples/hcpnm-project/HCP/paths
touch ${PATH_FILE}

for(( i=0; i<$num_subs; i++))
do
	subjectID=${sub_ids[$i]}
	echo "${FUNC_DATA}/${subjectID}/${FUNC_SUFFIX}/func/${FUNC_FILENAME}" >> $PATH_FILE
	echo "${ANAT_DATA}/${subjectID}/${ANAT_SUFFIX}/anat/${ANAT_FILENAME}" >> $PATH_FILE
	
	mkdir "${OUTPUT_DIRECTORY}/${subjectID}"
	sub_outpath="${OUTPUT_DIRECTORY}/${subjectID}"
	echo "${sub_outpath}" >> $PATH_FILE
done
