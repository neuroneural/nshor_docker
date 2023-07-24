#!/bin/bash

DATA_DIRECTORY=/data/qneuromark/Data/BSNIP/Data_BIDS/Raw_Data/Boston
PROJECT_DIRECTORY=/data/users2/jwardell1/nshor_docker/examples/bsnip-project

sub_file=${PROJECT_DIRECTORY}/BSNIP/Boston/subjects.txt
num_subs=$(cat $sub_file | wc -l)
IFS=$'\n' sub_ids=($(cat $sub_file))

PATH_FILE=/data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/paths
mask_filepath=${PROJECT_DIRECTORY}/BSNIP/Boston/group_mean_masks/groupmeanmask.nii

touch ${PATH_FILE}

for(( i=0; i<$num_subs; i++))
do
	subjectID=${sub_ids[$i]}
	echo "${DATA_DIRECTORY}/${subjectID}/ses_01/func/rest.nii" >> $PATH_FILE
	echo "${DATA_DIRECTORY}/${subjectID}/ses_01/anat/T1.nii" >> $PATH_FILE
	echo ${mask_filepath} >> $PATH_FILE
	OUTPUT_DIRECTORY=/data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston
	mkdir "${OUTPUT_DIRECTORY}/${subjectID}"
	mkdir "${OUTPUT_DIRECTORY}/${subjectID}/ses_01"
	sub_outpath="${OUTPUT_DIRECTORY}/${subjectID}/ses_01"
	echo "${sub_outpath}" >> $PATH_FILE
done
