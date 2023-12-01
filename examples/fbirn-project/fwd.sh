function framewise_displacement() {
	#FDi = ∣Δdix∣ + ∣Δdiy∣ + ∣Δdiz∣ + ∣Δαi∣ + ∣Δβi∣ + ∣Δγi∣
	#Δdix = d(i−1)x − dix, Δdiy = d(i−1)y − diy, Δdiz = d(i−1)z − diz, ect.
	fw_out_filename=fw_displacement.txt
	fw_outfile=`pwd`/${fw_out_filename}
	touch ${fw_outfile}
	par_file=$1
	echo "parfile - ${parfile}"
	echo "parfile contents - "
	cat $parfile
	
	IFS=$'\n' displacement_parameters=($(cat $par_file))
	num_timepoints=`wc -l <  $par_file`
	fd_at_timepoint=0
	for(( i=0; i<$num_timepoints; i++))
	do
        	params=${displacement_parameters[$i]}
        	echo -e $params | tr '\n' ' ' | sed -e 's/[^0-9]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ' | sed 's/ /\n/g' > nums.txt
        	IFS=$'\n' nums_arr=($(cat nums.txt))
        	dx=${nums_arr[0]}
        	dy=${nums_arr[1]}
        	dz=${nums_arr[2]}
        	rx=${nums_arr[3]}
        	ry=${nums_arr[4]}
        	rz=${nums_arr[5]}
        	if (($i==0)); then
                	break
        	fi
        	params=${displacement_parameters[$i-1]}
        	echo -e $params | tr '\n' ' ' | sed -e 's/[^0-9]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ' | sed 's/ /\n/g' > nums.txt
        	IFS=$'\n' nums_arr=($(cat nums.txt))
        	dx_b=${nums_arr[0]}
        	dy_b=${nums_arr[1]}
        	dz_b=${nums_arr[2]}
        	rx_b=${nums_arr[3]}
        	ry_b=${nums_arr[4]}
        	rz_b=${nums_arr[5]}
        	#pi=`tex --version | head -1 | cut -f2 -d' '`
		pi=$(3.14159)
        	fd_at_timepoint=$(((dx_b-dx) + (dy_b-dy) + (dz_b-dz) + 180*$pi + (rx_b-rx) + (ry_b-ry) + (rz_b-rz)))

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
    		echo "Average FWD: $average"
	else
    		echo "Error: count is empty."
    		exit 1
	fi
	return $average
}
