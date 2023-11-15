#!/bin/bash

dataset=$1
region=$2

if [ -z "$dataset" ]; then
	echo "provide the dataset name as an argument to this script in lowercase"
	echo "provide the region name as the second argument to this script if your dataset has a region"
	exit
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
for (( i=0; i<$num_subs; i++ )); do #check each subject's derivatives
	if [ -d ${myroot}/${subject[i]}/ses_01/ ]; then #if sessions exist, go into sessions dir
		cd ${myroot}/${subject[i]}/ses_01/
	else
		cd ${myroot}/${subject[i]}/ #if no sessions, just go into subject dir
	fi
	if [ ! -d ./processed ]; then #if the processed dir isn't there, then the sub wasn't processed 
		echo ${subject[i]} >> ${uprocfile}
		break #this subject was noted as non-processed, so exit loop for this sub

	else #if the processed dir exists, see if there is a nii file in the dir
		cd processed
		for file in *; do #for all files in sub's processed dir
			#check if there is a nii or nii.gz file there 
			if [[ -f "$file" && ( "$file" == *.nii || "$file" == *.nii.gz ) ]]; then  
				break #if a nii file exists, then exit the filecheck loop
			else
				echo ${subject[i]} >> ${uprocfile} #if a nifti file isn't there, the sub isn't proc. correctly
    		fi

		done
	fi
done

num_empty=`cat ${uprocfile} | wc -l`
echo "$dataset: there are ${num_empty} unprocessed subjects among the total ${num_subs}"
