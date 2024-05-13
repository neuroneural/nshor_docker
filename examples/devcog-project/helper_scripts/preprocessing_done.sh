#!/bin/bash


preprocessing_done() {
	prep_dir=$1
	proj_dir=`dirname $prep_dir`
	pathsfile=${prep_dir}/paths
	numlines=`cat $pathsfile | wc -l`
	numruns=$((numlines/4))
	for ((i=0; i<$numruns; i++)); do
		source ${proj_dir}/setvarstest.sh $i 1> /dev/null
		processed_dir="${out_bind}/processed"
		if ! ls "${processed_dir}"/*.nii.gz 1> /dev/null 2>&1; then
			echo "false"
			exit
		fi
	done
	echo "true"
}
