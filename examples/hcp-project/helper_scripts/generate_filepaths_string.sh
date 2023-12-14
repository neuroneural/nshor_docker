#!/bin/bash

if [ -f time_courses_files.txt ]; then
	rm time_courses_files.txt
fi

subs_file=/data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/subjects.txt
num_subs=$(wc -l < "$subs_file")
num_iter=$(($num_subs - 1))
IFS=$'\n' sub_ids=($(cat ${subs_file}))

for(( i=0; i<$num_subs; i++))
do
        subjectID=${sub_ids[$i]}
		if [[ "$i" -eq "$num_iter" ]]; then
			echo -n "/data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/${subjectID}/processed/TCOutMax_${subjectID}.mat" >> time_courses_files.txt
		else
			echo -n "/data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/${subjectID}/processed/TCOutMax_${subjectID}.mat," >> time_courses_files.txt
		fi
done
