#!/bin/bash

project_dir=/data/users2/jwardell1/nshor_docker/examples/bsnip-project

subs_file=${project_dir}/BSNIP/Boston/subjects.txt
num_subs=$(cat $subs_file | wc -l)

IFS=$'\n' sub_ids=($(cat $subs_file))

speeds_file=${project_dir}/speeds.txt

if [ -f $speeds_file ]; then
	rm $speeds_file
else
	touch $speeds_file
fi

for(( i=0; i<$num_subs; i++))
do
	subjectID=${sub_ids[$i]}
	if [ ! -f ${project_dir}/BSNIP/Boston/${subjectID}/ses_01/processed/benchTime.txt ]; then
		continue
	fi
	time=`cat ${project_dir}/BSNIP/Boston/${subjectID}/ses_01/processed/benchTime.txt`
	echo $time >> $speeds_file
done
