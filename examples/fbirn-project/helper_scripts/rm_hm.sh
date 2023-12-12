#!/bin/bash
# Loop through each subject ID in subjects.txt
while IFS= read -r subject_id; do
  # Check if the subject directory exists
  if [ -d "$subject_id/ses_01/processed" ]; then
    # Delete files containing _hm.nii.gz within the processed directory
    find "$subject_id/ses_01/processed" -type f -name "*_hm.nii.gz" -delete
    echo "Deleted files for $subject_id"
  else
    echo "Warning: $subject_id directory not found"
  fi
done < "subjects.txt"
