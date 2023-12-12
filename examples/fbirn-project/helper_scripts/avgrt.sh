#!/bin/bash

# Initialize variables
total=0
count=0

# Loop through each subject
for subject_dir in */ses_01/processed; do
    # Get the benchmark file path
    bench_file="$subject_dir/benchTime.txt"
    
    # Check if the file exists
    if [ -e "$bench_file" ]; then
        # Get the bottom number and add it to the total
        bottom_number=$(tail -n 1 "$bench_file")
        total=$(echo "$total + $bottom_number" | bc)
        
        # Increment the count
        ((count++))
    fi
done

# Calculate the average
average=$(echo "scale=2; $total / $count" | bc)

# Print the result
echo "Total: $total"
echo "Count: $count"
echo "Average: $average"

