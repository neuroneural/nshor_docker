#!/bin/bash
# Loop through each subject ID in subjects.txt
while IFS= read -r subject_id; do
  # Check if the subject directory exists
  if [ -d "$subject_id/ses_01/processed" ]; then
    # Delete files containing _hm.nii.gz within the processed directory
	rm $subject_id/ses_01/processed/fmri_ts_ds_mc_vr_motion.1D
    echo "Deleted files for $subject_id"
  else
    echo "Warning: $subject_id directory not found"
  fi
done < "subjects.txt"
