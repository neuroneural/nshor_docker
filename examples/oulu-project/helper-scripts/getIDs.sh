#!/bin/bash

# Define the directory containing the files
data_dir="/data/users2/jwardell1/Oulu_data"

# Create an empty text file to store the IDs
output_file="subjects.txt"
> "$output_file"

# Extract subject IDs
cd "$data_dir" || exit 1  # Change directory
for file in *.nii.gz; do
    # Extract the filename without extension
    filename=$(basename "$file")
    id=$(echo "$filename" | cut -d'_' -f1)  # Extract ID before the first underscore
    echo "$id" >> "$output_file"  # Write the ID to the output file
done
