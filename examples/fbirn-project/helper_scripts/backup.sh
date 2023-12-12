#!/bin/bash

while IFS= read -r subject_id; do
  # Check if the subject directory exists
  if [ -d "$subject_id/ses_01/processed" ]; then
    # Move existing _rest.nii.gz file to _rest.nii.gz.bak
    rest_file="$subject_id/ses_01/processed/${subject_id}_rest.nii.gz"
    bak_file="$subject_id/ses_01/processed/${subject_id}_rest.nii.gz.bak"

    if [ -f "$rest_file" ]; then
      mv "$rest_file" "$bak_file"
      echo "Moved $rest_file to $bak_file for $subject_id"
    else
      echo "Warning: $rest_file not found for $subject_id"
    fi
  else
    echo "Warning: $subject_id directory not found"
  fi
done < "subjects.txt"
