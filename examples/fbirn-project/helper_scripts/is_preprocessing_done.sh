#!/bin/bash

# Function to check if preprocessing is done for all subjects in a dataset
# Arguments:
# $1: Dataset name
# Returns "true" if preprocessing is done for all subjects in the dataset, "false" otherwise
function is_preprocessing_done() {
    local dataset_name="$1"
    local subjects_dir="/path/to/subjects/directory"
    local all_preprocessed=true
    
    # Loop through subject IDs listed in subjects.txt
    while IFS= read -r subject_id; do
        local preprocessed_file="${subjects_dir}/${subject_id}/ses_01/processed/${subject_id}_rest.nii.gz"
        if [ ! -f "$preprocessed_file" ]; then
            echo "Preprocessing is not done for subject ${subject_id} in dataset ${dataset_name}"
            all_preprocessed=false
            break
        fi
    done < subjects.txt
    
    if [ "$all_preprocessed" = true ]; then
        echo "Preprocessing is done for all subjects in dataset ${dataset_name}"
        echo "true"
    else
        echo "Preprocessing is not done for all subjects in dataset ${dataset_name}"
        echo "false"
    fi
}

