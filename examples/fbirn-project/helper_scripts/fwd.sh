#!/bin/bash

function framewise_displacement {
	#FDi = ∣Δdix∣ + ∣Δdiy∣ + ∣Δdiz∣ + ∣Δαi∣ + ∣Δβi∣ + ∣Δγi∣
	#Δdix = d(i−1)x − dix, Δdiy = d(i−1)y − diy, Δdiz = d(i−1)z − diz, etc.
	fw_out_filename=fw_displacement.txt
	fw_outfile=`pwd`/${fw_out_filename}
	if [ -f ${fw_outfile} ]; then
		rm ${fw_outfile}
	fi
	touch ${fw_outfile}
	par_file="$1"
	
	IFS=$'\n'
 	displacement_parameters=($(cat $par_file))
	num_timepoints=`wc -l <  $par_file`
	fd_at_timepoint=0
	for(( i=0; i<$num_timepoints; i++ ))
	do
		if [ -f nums.txt ]; then 
			rm nums.txt
		fi
		touch nums.txt
		IFS=$' '
        	params=(${displacement_parameters[$i]})
		for(( j=0; j<6; j++ ))
		do
			currnum=${params[$j]}
			if [[ "$currnum" == *"e"* ]]; then
				scinum=$currnum
				convnum=`echo "$scinum" | awk -F"e" 'BEGIN{OFMT="%10.10f"} {print $1 * (10 ^ $2)}'`
				echo "$convnum" >> nums.txt	
			elif [[ "$currnum" == *"E"* ]]; then
				scinum=$currnum
				convnum=`echo "$scinum" | awk -F"E" 'BEGIN{OFMT="%10.10f"} {print $1 * (10 ^ $2)}'`
				echo "$convnum" >> nums.txt	
			else
				echo "${params[$j]}" >> nums.txt
			fi
		done
        	IFS=$'\n' nums_arr=($(cat nums.txt))
        	rx=${nums_arr[0]}
        	ry=${nums_arr[1]}
        	rz=${nums_arr[2]}
        	dx=${nums_arr[3]}
        	dy=${nums_arr[4]}
        	dz=${nums_arr[5]}
        	if (($i==0)); then
                	continue
        	fi
		rm nums.txt
		IFS=$' '
        	params=(${displacement_parameters[$i-1]})
		for(( j=0; j<6; j++ ))
		do
			currnum=${params[$j]}
			if [[ "$currnum" == *"e"* ]]; then
				scinum=$currnum
				convnum=`echo "$scinum" | awk -F"e" 'BEGIN{OFMT="%10.10f"} {print $1 * (10 ^ $2)}'`
				echo "$convnum" >> nums.txt	
			elif [[ "$currnum" == *"E"* ]]; then
				scinum=$currnum
				convnum=`echo "$scinum" | awk -F"E" 'BEGIN{OFMT="%10.10f"} {print $1 * (10 ^ $2)}'`
				echo "$convnum" >> nums.txt	
			else
				echo "${params[$j]}" >> nums.txt
			fi
		done
        	IFS=$'\n' nums_arr=($(cat nums.txt))
        	rx_b=${nums_arr[0]}
        	ry_b=${nums_arr[1]}
        	rz_b=${nums_arr[2]}
        	dx_b=${nums_arr[3]}
        	dy_b=${nums_arr[4]}
        	dz_b=${nums_arr[5]}
		pi=3.14159
		fd_at_timepoint=$(echo "((($dx_b - $dx) + ($dy_b - $dy) + ($dz_b - $dz) + 50 * ($pi / 180) * (($rx_b - $rx) + ($ry_b - $ry) + ($rz_b - $rz))))" | bc -l)
		#fd_at_timepoint=$(echo "((($dx_b - $dx) + ($dy_b - $dy) + ($dz_b - $dz) + ($rx_b - $rx) + ($ry_b - $ry) + ($rz_b - $rz)))" | bc -l)
		fd_at_timepoint=`echo "sqrt($fd_at_timepoint^2)" | bc`
        	echo $fd_at_timepoint >> ${fw_outfile}
	done

	# Check if file exists
	if [ ! -f "$fw_outfile" ]; then
    		echo "Error: fw_outfile not found."
    		exit 1
	fi

	# Read the file and compute the average
	sum=0
	count=0

	while read line; do
    		sum=$(echo "$sum + $line" | bc -l)
    		((count++))
	done < "$fw_outfile"

	if [ "$count" -gt 0 ]; then
    		average=$(echo "$sum / $count" | bc -l)
    		#echo "Average FWD: $average"
	else
    		echo "Error: count is empty."
    		exit 1
	fi
	echo $average
}

infile=$1
framewise_displacement "$infile"
