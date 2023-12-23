#!/bin/bash

DATA_DIRECTORY=/data/users2/jwardell1/oulu_data
PROJECT_DIRECTORY=/data/users2/jwardell1/nshor_docker/examples/oulu-project

sub_file=${PROJECT_DIRECTORY}/OULU/subjects.txt
num_subs=$(cat $sub_file | wc -l)
IFS=$'\n' sub_ids=($(cat $sub_file))

PATH_FILE=/data/users2/jwardell1/nshor_docker/examples/oulu-project/OULU/paths

touch ${PATH_FILE}

for tr in 2150 100
do
	for(( i=0; i<$num_subs; i++))
	do
		#20150210_data_TR2150.nii.gz
		#20150210_mreg_data_TR100.nii.gz
		subjectID=${sub_ids[$i]}
		if [ "$tr" -eq 100 ]; then
			echo "${DATA_DIRECTORY}/${subjectID}_mreg_data_TR${tr}.nii.gz" >> $PATH_FILE
		else
			echo "${DATA_DIRECTORY}/${subjectID}_data_TR${tr}.nii.gz" >> $PATH_FILE
		fi
		echo "${DATA_DIRECTORY}/${subjectID}_T1.nii.gz" >> $PATH_FILE
		OUTPUT_DIRECTORY=/data/users2/jwardell1/nshor_docker/examples/oulu-project/OULU
		mkdir "${OUTPUT_DIRECTORY}/${subjectID}"
		sub_outpath="${OUTPUT_DIRECTORY}/${subjectID}"
		echo "${sub_outpath}" >> $PATH_FILE
	done
done
