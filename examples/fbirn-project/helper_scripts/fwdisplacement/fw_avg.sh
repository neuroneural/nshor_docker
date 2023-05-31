#!/bin/bash

# Check if file exists
if [ ! -f "$1" ]; then
    echo "Error: file not found."
    exit 1
fi

# Read the file and compute the average
sum=0
count=0

while read line; do
    sum=$(echo "$sum + $line" | bc -l)
    ((count++))
done < "$1"

if [ "$count" -gt 0 ]; then
    average=$(echo "$sum / $count" | bc -l)
    echo "Average: $average"
else
    echo "Error: file is empty."
    exit 1
fi
