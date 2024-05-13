#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH --mem=32g
#SBATCH -p qTRD
#SBATCH --time=20:00:00
#SBATCH -J mask
#SBATCH -e /data/users2/jwardell1/nshor_docker/examples/oulu-project/jobs/error%A_%a.err
#SBATCH -o /data/users2/jwardell1/nshor_docker/examples/oulu-project/jobs/out%A_%a.out
#SBATCH -A psy53c17
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jwardell1@student.gsu.edu
#SBATCH --oversubscribe

module load afni

# Loop through each subject directory
while IFS= read -r sub_id; do
    # Define the paths to the input files
    input_file="/data/users2/jwardell1/nshor_docker/examples/oulu-project/OULU/${sub_id}/processed/func2mni_warped.nii.gz"
    mask_file="/data/users2/jwardell1/nshor_docker/examples/oulu-project/OULU/${sub_id}/processed/template_mask_3mm.nii.gz"
    
    # Define the output filename
    output_file="/data/users2/jwardell1/nshor_docker/examples/oulu-project/OULU/${sub_id}/processed/func2mni_masked.nii.gz"
    
    # Apply the mask using 3dcalc
    3dcalc -a "$input_file" -b "$mask_file" -expr 'a*b' -prefix "$output_file"
    
    echo "Mask applied for subject ${sub_id}"
done < subjects.txt
