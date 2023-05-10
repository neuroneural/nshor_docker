#!/bin/bash
while getopts f:a:j:c:b:s:l:r:o: flag
do
        case "${flag}" in
                f) 
			func_file=${OPTARG}
			func_filepath=/func/${func_file}
			;;
                a) 
			anat_file=${OPTARG}
			anat_filepath=/anat/${anat_file}
			;;
                j) 
			json_file=${OPTARG}
			json_filepath=/func/${json_file}
			;;
                c) 
			biasch_file=${OPTARG}
			biasch_filepath=/func/${biasch_file}
			;;
                b) 
			biasbc_file=${OPTARG}
			biasbc_filepath=/func/${biasbc_file}
			;;
                s) 
			sbref_file=${OPTARG}
			sbref_filepath=/func/${sbref_file}
			;;
                l) 
			spinlr_file=${OPTARG}
			spinlr_filepath=/func/${spinlr_file}
			;;
                r) 
			spinrl_file=${OPTARG}
			spinrl_filepath=/func/${spinrl_file}
			;;
                o) 
			out_filepath=${OPTARG}
			;;
		?)
      			echo "script usage: $(basename \$0) [-l] [-h] [-a somevalue]" >&2
			exit 1
      			;;
        esac
done

#print the filenames to console for debugging purposes
echo "func_file : ${func_file}"
echo "anat_file : ${anat_file}"
echo "json_file : ${json_file}"
echo "biasch_file : ${biasch_file}"
echo "biasbc_file : ${biasbc_file}"
echo "sbref_file : ${sbref_file}"
echo "spinlr_file : ${spinlr_file}"
echo "out_filepath : ${out_filepath}"
