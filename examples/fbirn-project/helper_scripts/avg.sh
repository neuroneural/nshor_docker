#!/bin/bash

subs_file=${myroot}/FBIRN/subjects.txt
myroot=/data/users2/jwardell1/nshor_docker/examples/fbirn-project
num_subs=$(wc -l < "$subs_file")
IFS=$'\n' sub_ids=($(cat subjects.txt))
sum=0
for(( i=0; i<$num_subs; i++))
do
	subjectID=${sub_ids[$i]}
	if [ ! -f ${myroot}/FBIRN/derivatives/${subjectID}/processed/benchTime.txt ]; then
		echo "$time" >  ${myroot}/FBIRN/derivatives/${subjectID}/processed/benchTime.txt
	fi
	time=`cat ${myroot}/FBIRN/derivatives/${subjectID}/processed/benchTime.txt`
	sum=$(($sum + $time))
done
avg=$(($sum/$num_subs))
echo "$avg" > avg.txt
