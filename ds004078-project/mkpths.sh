#!/bin/bash

DATA_DIRECTORY=/data/users2/nshor/Multiband_with_MEG
num_subs=`cat subjects.txt | wc -l`
IFS=$'\n' sub_ids=($(cat subjects.txt))
PATH_FILE=/data/users2/jwardell1/nshor_docker/ds004078-project/ds004078/paths
touch ${PATH_FILE}

for(( i=0; i<$num_subs; i++))
do
	subjectID=${sub_ids[$i]}
	subfunc=/data/users2/jwardell1/nshor_docker/ds004078-project/ds004078/subfunc.txt
	touch $subfunc
	cd ${DATA_DIRECTORY}/${subjectID}/func && ls *.nii.gz > $subfunc
	sub_func_files=($(cat $subfunc))
	num_func_files=`cat $subfunc | wc -l`
	anat_filename=${subjectID}_run-01_T1w.nii.gz
	OUTPUT_DIRECTORY=/data/users2/jwardell1/nshor_docker/ds004078-project/ds004078
	sub_outpath="${OUTPUT_DIRECTORY}/${subjectID}"
	mkdir "${OUTPUT_DIRECTORY}/${subjectID}"
	for((j=0; j<$num_func_files; j++))
	do
		func_filename=${sub_func_files[$j]}
		echo "${DATA_DIRECTORY}/${subjectID}/func/${func_filename}" >> $PATH_FILE
		echo "${DATA_DIRECTORY}/${subjectID}/anat/${anat_filename}" >> $PATH_FILE
		echo "${sub_outpath}" >> $PATH_FILE
	done
	rm $subfunc
done
