#!/bin/bash

set -x

DATADIR=/data/neuromark2/Data/BSNIP2/Data_BIDS/Raw_Data
PROJDIR=/data/users2/jwardell1/nshor_docker/examples/bsnip2-project

> /data/users2/jwardell1/nshor_docker/examples/bsnip2-project/BSNIP2/paths
PATHSFILE=/data/users2/jwardell1/nshor_docker/examples/bsnip2-project/BSNIP2/paths

IFS=$'\n' sites=(`ls -1 $DATADIR`)

for site in "${sites[@]}"
do
	mkdir -p $PROJDIR/BSNIP2/${site}/
	IFS=$'\n' subjects=(`ls -1 ${DATADIR}/${site}`)
	> $PROJDIR/BSNIP2/${site}/subjects.txt
	for subject in "${subjects[@]}"
	do
		mkdir -p $PROJDIR/BSNIP2/${site}/$subject
		mkdir -p $PROJDIR/BSNIP2/${site}/$subject/ses_01
		echo $subject > $PROJDIR/BSNIP2/${site}/subjects.txt
		IFS=$'\n' files=(`ls -1 $DATADIR/${site}/$subject/ses_01`)
		anatfound=false
		funcfound=false
		for file in "${files[@]}"
		do
			if [[ "$file" == *"anat"* ]] && [ "$anatfound" == false ]; then
				anat_filepath=$DATADIR/${site}/$subject/ses_01/$file/T1.nii
				anatfound=true
			elif [[ "$file" == *"func"* ]] && [ "$funcfound" == false ]; then
				func_filepath=$DATADIR/${site}/$subject/ses_01/$file/rest.nii
				funcfound=true
			fi
		done
		if [[ $anatfound == true  ]]; then
			if [[ $funcfound == true ]]; then
				echo $func_filepath >> $PATHSFILE
				echo $anat_filepath >> $PATHSFILE
				suboutdir=$PROJDIR/BSNIP2/${site}/$subject/ses_01
				echo $suboutdir >> $PATHSFILE
			fi
		fi
		if [ "$funcfound" == false ] || [ "$anatfound" == false ]; then
			rmdir -v $PROJDIR/BSNIP2/${site}/$subject/ses_01
			rmdir -v $PROJDIR/BSNIP2/${site}/$subject
		fi
	done
done

