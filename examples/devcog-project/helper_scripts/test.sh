#!/bin/bash

source preprocessing_done.sh
# Example usage
projdir=/data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN
isdone=`preprocessing_done $projdir`
echo "$isdone"

if [ "$isdone" == "true" ]; then
    echo "Preprocessing is done. Calculate group mask."
    # Your logic for calculating group mask goes here
else
    echo "Preprocessing is not done. Finish before calculating group mask."
fi

