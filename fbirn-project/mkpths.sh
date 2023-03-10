#!/bin/bash

DATA_DIRECTORY=/data/qneuromark/Data/FBIRN/Data_BIDS/Raw_Data
num_subs=`ls $DATA_DIRECTORY | wc -l`
IFS=$'\n' sub_ids=($(cat subjects.txt))

for(( i=0; i<$num_subs; i++))
do
	subjectID=${sub_ids[$i]}
	touch 'paths_${subjectID}'
	PATH_FILE=./paths_${subjectID}
	echo "${DATA_DIRECTORY}/${subjectID}/func/rest.nii" >> $PATH_FILE
	echo "${DATA_DIRECTORY}/${subjectID}/anat/T1.nii" >> $PATH_FILE
done
