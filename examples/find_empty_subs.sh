#!/bin/bash

dataset=$1
region=$2

if [ -z "$dataset" ]; then
	echo "provide the dataset name as an argument to this script in lowercase"
	echo "provide the region name as the second argument to this script if your dataset has a region"
	exit 1
fi

if [ "$dataset" = "ds004078" ]; then 
	dataset_cp=ds004078
elif [ "$dataset" = "hcpnm" ]; then 
	dataset_cp=HCP
else
	dataset_cp=`capitalize $dataset`
fi

if [ -z "$region"  ]; then
	myroot=/data/users2/jwardell1/nshor_docker/examples/${dataset}-project/${dataset_cp}
else
	myroot=/data/users2/jwardell1/nshor_docker/examples/${dataset}-project/${dataset_cp}/${region}
fi	

num_subs=$(cat ${myroot}/subjects.txt | wc -l)
subject=($(cat ${myroot}/subjects.txt))
uprocfile=${myroot}/unprocessed_subs_${dataset}.txt

if [ -f ${uprocfile} ]; then 
	rm ${uprocfile}
fi

touch $uprocfile

for (( i=0; i<$num_subs; i++ )); do
	if [ -d ${myroot}/${subject[i]}/ses_01/ ]; then
		cd ${myroot}/${subject[i]}/ses_01/
	else
		cd ${myroot}/${subject[i]}/
	fi
	if [ -d ./processed ]; then
		continue
	else
		echo ${subject[i]} >> ${uprocfile}
	fi
done

num_empty=`cat ${uprocfile} | wc -l`
echo "$dataset: there are ${num_empty} unprocessed subjects among the total ${num_subs}"
