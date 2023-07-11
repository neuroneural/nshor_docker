#!/bin/bash


num_subs=`ls FBIRN/derivatives/ | wc -l`
IFS=$'\n' sub_ids=($(cat subjects.txt))
sum=0
for(( i=0; i<$num_subs; i++))
do
	subjectID=${sub_ids[$i]}
	if [ ! -f FBIRN/derivatives/${subjectID}/processed/benchTime.txt ]; then
		echo "$time" >  FBIRN/derivatives/${subjectID}/processed/benchTime.txt
	fi
	time=`cat FBIRN/derivatives/${subjectID}/processed/benchTime.txt`
	sum=$(($sum + $time))
done
avg=$(($sum/$num_subs))
echo "$avg" > avg.txt
