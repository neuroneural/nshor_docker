#!/bin/bash

set -x

subsfile=DEVCOG-ss/subjects.txt

PROJECT_DIRECTORY="/data/users2/jwardell1/nshor_docker/examples/devcog-project"
DATA_DIRECTORY="/data/brainforge/managed/mrn/jstephen/devcog_20908/triotim"

cd ${PROJECT_DIRECTORY}/DEVCOG-ss

paths=${PROJECT_DIRECTORY}/DEVCOG-ss/pathsremaining
touch $paths
> $paths

while IFS= read -r subjectID; do
	cd ${PROJECT_DIRECTORY}/DEVCOG-ss/$subjectID
	echo `pwd`
	IFS=$'\n' sessions=(`ls`)
	for session in "${sessions[@]}"
	do
		cd ${PROJECT_DIRECTORY}/DEVCOG-ss/$subjectID/$session
		session_processed=false
		IFS=$'\n' files=(`ls`)
		for file in "${files[@]}"
		do
			if [[ "$file" == *"processed"* ]]; then
				echo "processed file found for sub $subjectID session $session"
				cd $file
				IFS=$'\n' subfiles=(`ls`)
				for subfile in "${subfiles[@]}"
				do
					if [[ "$subfile" == *".nii.gz" ]]; then
						echo "nifti file $subfile found"
						session_processed=true
						break
					else
						echo "file $subfile is not ending in .nii.gz"
					fi
				done
				cd ${PROJECT_DIRECTORY}/DEVCOG-ss/$subjectID/$session
			elif [[ "$file" == *"pathsremaining"* ]]; then
				rm $file
				continue
			fi
		done
		if ! $session_processed; then
			echo "found missing session: $session"
			
			#determine prefix for fMRI file
			REST_STR=$(find "${DATA_DIRECTORY}/${subjectID}/$session" -type d -name 'rest_open_evenURSIfirst_*' | grep -v 'SBRef' | head -n 1)
			REST_STR=$(basename "$REST_STR")
			if [ -z $REST_STR ]; then
				break;
			fi
			
			#write location of fMRI file to paths file
			session_path=${DATA_DIRECTORY}/${subjectID}/${session}/${REST_STR}
			func_filepath=$(find "${session_path}" -type f -name '*.nii.gz' -print 2> /dev/null)
			
			json_filepath=$(find "${session_path}" -type f -name '*.json' -print 2> /dev/null)
			
			
			#determine location of anat file and write to paths file
			ses_path=`dirname $session_path`
			t1_directory=$(find "${ses_path}" -maxdepth 1 -type d -name 't1w_*' | sort -V | head -n 1)
			
			if [ -z $t1_directory ]; then
				echo "t1 file not found for subject $subjectID session $session"
				break
			fi
			
			anat_filepath=$(find "${t1_directory}" -type f -name 't1w_*.nii.gz' | sort -V | head -n 1)
			output_dir=${PROJECT_DIRECTORY}/DEVCOG-ss/$subjectID/$session
			
			echo $func_filepath >> $paths
			echo $anat_filepath >> $paths
			echo $json_filepath >> $paths
			echo $output_dir >> $paths
			
		fi
	done
done < subjects.txt

