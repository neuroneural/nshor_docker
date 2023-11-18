#!/bin/bash

DATA_DIRECTORY=/data/qneuromark/Data/FBIRN/Data_BIDS/Raw_Data
PROJECT_DIRECTORY=/data/users2/jwardell1/nshor_docker/examples/fbirn-project

sub_file=${PROJECT_DIRECTORY}/FBIRN/subjects.txt
num_subs=$(cat $sub_file | wc -l)
IFS=$'\n' sub_ids=($(cat $sub_file))

PATH_FILE=/data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/paths
#mask_filepath=${PROJECT_DIRECTORY}/FBIRN/group_mean_masks/groupmeanmask.nii

touch ${PATH_FILE}

for(( i=0; i<$num_subs; i++))
do
	subjectID=${sub_ids[$i]}
	echo "${DATA_DIRECTORY}/${subjectID}/ses_01/func/rest.nii" >> $PATH_FILE
	echo "${DATA_DIRECTORY}/${subjectID}/ses_01/anat/T1.nii" >> $PATH_FILE
	#echo  ${mask_filepath} >> $PATH_FILE
	OUTPUT_DIRECTORY=/data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN
	#mkdir "${OUTPUT_DIRECTORY}/${subjectID}"
	#mkdir "${OUTPUT_DIRECTORY}/${subjectID}/ses_01"
	sub_outpath="${OUTPUT_DIRECTORY}/${subjectID}/ses_01"
	echo "${sub_outpath}" >> $PATH_FILE
done
