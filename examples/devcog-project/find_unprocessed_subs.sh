#!/bin/bash

> paths_remaining.txt

for ((i=0; i<222; i++)); do
    source setvarstest.sh $i

    # Form the path to the processed directory
    processed_dir="${out_bind}/processed"

    # Check if a .nii.gz file exists in the processed directory
    if ! ls "${processed_dir}"/*.nii.gz 1> /dev/null 2>&1; then
        # Print the 4 arguments to paths_remaining.txt
        echo "${func_filepath}" >> paths_remaining.txt
        echo "${anat_filepath}" >> paths_remaining.txt
        echo "${json_filepath}" >> paths_remaining.txt
        echo "${out_bind}" >> paths_remaining.txt
    fi
done
