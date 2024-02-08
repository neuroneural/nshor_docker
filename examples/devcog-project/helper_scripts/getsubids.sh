#!/bin/bash

set -x


PROJECT_DIRECTORY="/data/users2/jwardell1/nshor_docker/examples/devcog-project"
DATA_DIRECTORY="/data/brainforge/managed/mrn/jstephen/devcog_20908/triotim"
subsfile=${PROJECT_DIRECTORY}/DEVCOG/subjects.txt

subids_file=${PROJECT_DIRECTORY}/DEVCOG/subs_with_open_closed.txt
filepaths_file=${PROJECT_DIRECTORY}/DEVCOG/subs_with_open_closed_filepaths.txt

touch $subids_file
> $subids_file

touch $filepaths_file
> $filepaths_file

while IFS= read -r subjectID; do
	cd ${PROJECT_DIRECTORY}/DEVCOG/$subjectID
	echo `pwd`
	IFS=$'\n' sessions=(`ls`)
	for session in "${sessions[@]}"
	do
		openfound=false
		closedfound=false
		for condition in rest_open_evenURSIfirst_  rest_closed_oddURSIfirst_
		do
			echo $condition
			
			#determine prefix for fMRI file
			REST_STR=$(find "${DATA_DIRECTORY}/${subjectID}/$session" -type d -name "*\\${condition}*" | grep -v 'SBRef' | head -n 1)
			REST_STR=$(basename "$REST_STR")
			if [ -z $REST_STR ]; then
				echo "REST_STR $REST_STR not found for subject $subjectID session $session breaking now"
				break;
			fi
			
			#write location of fMRI file to subids_file file
			session_path=${DATA_DIRECTORY}/${subjectID}/${session}/${REST_STR}
			func_filepath=$(find "${session_path}" -type f -name '*.nii.gz' -print 2> /dev/null)
			
			json_filepath=$(find "${session_path}" -type f -name '*.json' -print 2> /dev/null)
			
			
			#determine location of anat file and write to subids_file file
			ses_path=`dirname $session_path`
			t1_directory=$(find "${ses_path}" -maxdepth 1 -type d -name 't1w_*' | sort -V | head -n 1)
			
			if [ -z $t1_directory ]; then
				echo "t1 file not found for subject $subjectID session $session"
				break
			fi
			
			if [ -f $func_filepath ] && [[ "$condition" == *"open"* ]];then
				openfound=true
			elif [ -f $func_filepath ] && [[ "$condition" == *"closed"* ]];then
				closedfound=true
			fi
			
			
			echo "closedfound: $closedfound openfound: $openfound"
	
			if [ "$openfound" == true ] && [ "$closedfound" == true ]; then
				echo ${subjectID} >> $subids_file
				echo ${DATA_DIRECTORY}/${subjectID}/$session >> $filepaths_file
			else 
				echo "open and closed not found for subject $subjectID session $session"
			fi
		done
			
	done
done < ${PROJECT_DIRECTORY}/DEVCOG/subjects.txt

