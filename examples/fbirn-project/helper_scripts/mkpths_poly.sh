#!/bin/bash

PROJECT_DIRECTORY=/data/users2/jwardell1/nshor_docker/examples/fbirn-project

PATH_FILE=/data/users2/jwardell1/nshor_docker/examples/fbirn-project/helper_scripts/data_poly
LABELS_FILE=/data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/diagnosis.txt

IFS=$'\n' entries=($(cat $LABELS_FILE))

touch $PATH_FILE

for entry in "${entries[@]}"; do
    IFS=',' read -r subjectID label <<< "$entry"
    echo "/data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/${subjectID}/ses_01/processed/FNC_${subjectID}.npy,${label}" >> $PATH_FILE
done
