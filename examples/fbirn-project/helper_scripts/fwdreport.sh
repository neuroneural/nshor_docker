#!/bin/bash

report_file="mean_fwd_report.txt"

# Ensure the report file is empty or create a new one
> $report_file

while IFS= read -r subject_id; do
    subject_dir="${subject_id}/ses_01/processed"
    motion_file="${subject_dir}/${subject_id}_motion.1D"

    if [ -f "$motion_file" ]; then
        echo "Calculating mean fwd for subject: $subject_id"
        mean_fwd=$(bash fwd.sh "$motion_file")

        # Append the result to the report file
        echo "Subject: $subject_id, Mean FWD: $mean_fwd" >> $report_file
    else
        echo "Warning: Motion file not found for $subject_id." >&2
    fi
done < subjects.txt

# Calculate the average FWD across the study
average_fwd=$(awk '/^Average FWD:/{ sum += $3; count++ } END { if (count > 0) print sum / count }' mean_fwd_report.txt)

# Append the average_fwd to the report file
echo "Average FWD Across Study: $average_fwd" >> $report_file

echo "Report created: $report_file"

