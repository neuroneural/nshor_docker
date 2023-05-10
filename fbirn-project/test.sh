#!/bin/bash
#get data provided as input from user input file
while getopts f:a:j:c:b:l:r:o: flag
do
        case "${flag}" in
                f) func_file=${OPTARG};;
                a) anat_file=${OPTARG};;
                j) json_file=${OPTARG};;
                c) biasch_file=${OPTARG};;
                b) biasbc_file=${OPTARG};;
                s) sbref_file=${OPTARG};;
                l) spinlr_file=${OPTARG};;
                r) spinrl_file=${OPTARG};;
                o) out_filepath=${OPTARG};;
        esac
done

echo "debug pd 4"
#print the filenames to console for debugging purposes
echo "func_file : ${func_file}"
echo "anat_file : ${anat_file}"
echo "json_file : ${json_file}"
echo "biasch_file : ${biasch_file}"
echo "biasbc_file : ${biasbc_file}"
echo "sbref_file : ${sbref_file}"
echo "spinlr_file : ${spinlr_file}"

