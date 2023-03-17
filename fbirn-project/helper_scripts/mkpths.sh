#!/bin/bash

DATA_DIRECTORY=/data/qneuromark/Data/FBIRN/Data_BIDS/Raw_Data
num_subs=`ls $DATA_DIRECTORY | wc -l`
IFS=$'\n' sub_ids=($(cat subjects.txt))
PATH_FILE=/data/users2/jwardell1/nshor_docker/fbirn-project/FBIRN/paths
touch ${PATH_FILE}

for(( i=0; i<$num_subs; i++))
do
	subjectID=${sub_ids[$i]}
	echo "${DATA_DIRECTORY}/${subjectID}/ses_01/func/rest.nii" >> $PATH_FILE
	echo "${DATA_DIRECTORY}/${subjectID}/ses_01/anat/T1.nii" >> $PATH_FILE
	OUTPUT_DIRECTORY=/data/users2/jwardell1/nshor_docker/fbirn-project/FBIRN
	mkdir "${OUTPUT_DIRECTORY}/${subjectID}"
	mkdir "${OUTPUT_DIRECTORY}/${subjectID}/ses_01"
	sub_outpath="${OUTPUT_DIRECTORY}/${subjectID}/ses_01"
	echo "${sub_outpath}" >> $PATH_FILE
done
