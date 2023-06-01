#!/bin/bash
#FDi = ∣Δdix∣ + ∣Δdiy∣ + ∣Δdiz∣ + ∣Δαi∣ + ∣Δβi∣ + ∣Δγi∣
#Δdix = d(i−1)x − dix, Δdiy = d(i−1)y − diy, Δdiz = d(i−1)z − diz, ect.
fw_out_filename=fw_displacement.txt
fw_outfile=${fw_out_filename}
touch ${fw_outfile}
par_file=000300655084_rfMRI_moco.nii.gz.par
IFS=$'\n' displacement_parameters=($(cat $par_file))
num_timepoints=`wc -l <  $par_file`
echo "num_timepoints is ${num_timepoints}"
fd_at_timepoint=0
for(( i=0; i<${num_timepoints}; i++))
do
	echo "inside for loop i is $i"
	echo "debug 1"
	params=${displacement_parameters[$i]}
	echo "debug 2"
	numbers=$(echo $params | grep -Eon "[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?" | awk -F ':' '{print $2}')	
	echo "debug 3"
	nums_arr=($numbers)
	echo "debug 4"
	dx=${nums_arr[0]}
	echo "debug 5"
	dx=`printf "%.8f" $dx`
	echo "debug 6"
	echo "dx is ${dx}"
	echo "debug 7"

	dy=${nums_arr[1]}
	echo "debug 8"
	dy=`printf "%.8f" $dy`
	echo "debug 9"
	echo "dy is ${dy}"
	echo "debug 10"

	dz=${nums_arr[2]}
	echo "debug 11"
	dz=`printf "%.8f" $dz`
	echo "debug 12"
	echo "dz is ${dz}"
	echo "debug 13"

	rx=${nums_arr[3]}
	echo "debug 14"
	rx=`printf "%.8f" $rx`
	echo "debug 15"
	echo "rx is ${rx}"
	echo "debug 16"

	ry=${nums_arr[4]}
	echo "debug 17"
	ry=`printf "%.8f" $ry`
	echo "debug 18"
	echo "ry is ${ry}"
	echo "debug 19"

	rz=${nums_arr[5]}
	echo "debug 20"
	rz=`printf "%.8f" $rz`
	echo "debug 21"
	echo "rz is ${rz}"
	echo "debug 22"

	if (($i==0))
	then
		echo "debug 23"
		continue
	fi
	params=${displacement_parameters[$i-1]}
	echo "debug 24"
	numbers=$(echo $params | grep -Eon "[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?" | awk -F ':' '{print $2}')	
	echo "debug 25"
	nums_arr=($numbers)
	echo "debug 26"
	dx_b=${nums_arr[0]}
	dx_b=`printf "%.8f" $dx_b`
	echo "debug 27"
	dy_b=${nums_arr[1]}
	dy_b=`printf "%.8f" $dy_b`
	echo "debug 28"
	dz_b=${nums_arr[2]}
	dz_b=`printf "%.8f" $dz_b`
	echo "debug 29"
	rx_b=${nums_arr[3]}
	rx_b=`printf "%.8f" $rx_b`
	echo "debug 30"
	ry_b=${nums_arr[4]}
	ry_b=`printf "%.8f" $ry_b`
	echo "debug 31"
	rz_b=${nums_arr[5]}
	rz_b=`printf "%.8f" $rz_b`
	echo "debug 32"
	pi=3.14159
	echo "debug 34"
	fd_at_timepoint=`echo "($dx_b-($dx))+($dy_b-($dy))+($dz_b-($dz))+(180*$pi)+($rx_b-($rx))+($ry_b-($ry))+($rz_b-($rz))" | bc`
	echo "debug 35"

	echo $fd_at_timepoint >> ${fw_outfile}
	echo "debug 36"
done
