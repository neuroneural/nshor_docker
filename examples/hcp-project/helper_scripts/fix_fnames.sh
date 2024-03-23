#!/bin/bash

set -x

SUBSFILE=/data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/subjects.txt
SUBSDIR=/data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP
IFS=$'\n' subjects=(`cat $SUBSFILE`)

for sub in "${subjects[@]}"
do
	if [ -f ${SUBSDIR}/$sub/processed/ICOutMax_${sub}_SANITYCHECK.mat ];then
		mv -v ${SUBSDIR}/$sub/processed/ICOutMax_${sub}_SANITYCHECK.mat ${SUBSDIR}/$sub/processed/ICOutMax_${sub}.mat
		mv -v ${SUBSDIR}/$sub/processed/ICOutMax_${sub}_SANITYCHECK.nii ${SUBSDIR}/$sub/processed/ICOutMax_${sub}.nii
		mv -v ${SUBSDIR}/$sub/processed/TCOutMax_${sub}_SANITYCHECK.mat ${SUBSDIR}/$sub/processed/TCOutMax_${sub}.mat
	fi
done
