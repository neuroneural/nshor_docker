#!/bin/bash

SUBJECTS_FILE=$1
SLURM_TASK_ID=$2

echo "1 is $1"

IFS=$'\n' a=($(cat ${SUBJECTS_FILE}))
for i in $(seq ${#a[*]}); do
    [[ ${a[$i-1]} = $name ]] && echo "${a[$i]}"
done

#RANDOM=$$$(date +%s)
#subjectID=${a[ $RANDOM % ${#a[@]} ]}
subjectID=${a[${SLURM_TASK_ID}]}

echo "selected patient id is ${subjectID}"

#touch output.txt
#echo "${a[*]}">output.txt
