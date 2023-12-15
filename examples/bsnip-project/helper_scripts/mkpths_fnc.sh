#!/bin/bash

PROJECT_DIRECTORY=/data/users2/jwardell1/nshor_docker/examples/bsnip-project

sub_file=${PROJECT_DIRECTORY}/BSNIP/Boston/subjects.txt
num_subs=$(cat $sub_file | wc -l)
IFS=$'\n' sub_ids=($(cat $sub_file))

PATH_FILE=/data/users2/jwardell1/nshor_docker/examples/bsnip-project/helper_scripts/paths_fnc

touch ${PATH_FILE}
#        print("Usage: python script.py <subject_id> <timecourse_file> <output_dir>")

for(( i=0; i<$num_subs; i++))
do
	subjectID=${sub_ids[$i]}
	echo "${subjectID}" >> $PATH_FILE
	echo "${PROJECT_DIRECTORY}/BSNIP/Boston/${subjectID}/ses_01/processed/TCOutMax_${subjectID}.mat" >> $PATH_FILE
	echo "/data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/${subjectID}/ses_01/processed" >> $PATH_FILE
done
