#!/bin/bash


# This function checks if preprocessing is complete for a dataset
# Arguments:
# $1: Dataset name
# Prints "true" if preprocessing is done for all subjects in the dataset, "false" otherwise

function is_preprocessing_done() {
    local dataset_name="$1"
    local ds_cap=`capitalize $dataset_name`
    local PROJECT_DIR="/data/users2/jwardell1/nshor_docker/examples/${dataset_name}-project"
    local all_preprocessed=true
    local SUBJECT_FILE="${PROJECT_DIR}/${ds_cap}/subjects.txt"
    
    # Loop through subject IDs listed in subjects.txt
    while IFS= read -r subject_id; do
        local preprocessed_file="${PROJECT_DIR}/${ds_cap}/${subject_id}/ses_01/processed/${subject_id}_rest.nii.gz"
        if [ ! -f "$preprocessed_file" ]; then
            all_preprocessed=false
            break
        fi
    done < $SUBJECT_FILE
    
    if [ "$all_preprocessed" = true ]; then
        echo "true"
    else
        echo "false"
    fi
}


function capitalize() {
	word=$1
	capitalized_word=""

	# Loop 	through each character in the word
	for ((i=0; i<${#word}; i++)); do
      	 	 # Get the current character
	        char="${word:i:1}"

	        # Capitalize the character using parameter expansion
	        char="${char^^}"

	        # Append the capitalized character to the result
	        capitalized_word+="$char"
	done

	echo $capitalized_word
}
