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
	params=${displacement_parameters[$i]}
	numbers=$(echo $params | grep -Eon "[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?" | awk -F ':' '{print $2}')	
	nums_arr=($numbers)
	dx=${nums_arr[0]}
	dx=`printf "%.8f" $dx`
	echo "dx is ${dx}"

	dy=${nums_arr[1]}
	dy=`printf "%.8f" $dy`
	echo "dy is ${dy}"

	dz=${nums_arr[2]}
	dz=`printf "%.8f" $dz`
	echo "dz is ${dz}"

	rx=${nums_arr[3]}
	rx=`printf "%.8f" $rx`
	echo "rx is ${rx}"

	ry=${nums_arr[4]}
	ry=`printf "%.8f" $ry`
	echo "ry is ${ry}"

	rz=${nums_arr[5]}
	rz=`printf "%.8f" $rz`
	echo "rz is ${rz}"

	if (($i==0))
	then
		continue
	fi
	params=${displacement_parameters[$i-1]}
	numbers=$(echo $params | grep -Eon "[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?" | awk -F ':' '{print $2}')	
	nums_arr=($numbers)
	dx_b=${nums_arr[0]}
	dy_b=${nums_arr[1]}
	dz_b=${nums_arr[2]}
	rx_b=${nums_arr[3]}
	ry_b=${nums_arr[4]}
	rz_b=${nums_arr[5]}
	echo "scale=5; 4*a(1)" | bc -l > pi.txt
	pi=3.14159
	#pi=`tex --version | head -1 | cut -f2 -d' '`
	fd_at_timepoint=`echo "($dx_b-$dx)+($dy_b-$dy)+($dz_b-$dz)+180*$pi+($rx_b-$rx)+($ry_b-$ry)+($rz_b-$rz)" | bc`

	echo $fd_at_timepoint >> ${fw_outfile}
done
