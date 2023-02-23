#!/bin/bash
FSLDIR=/usr/share/fsl/5.0
PATH=$PATH:/usr/lib/afni/bin:/usr/lib/ROBEX:/usr/lib/ants
export ANTSPATH=/usr/lib/ants
export AFNIbinPATH=/usr/local/AFNIbin/
PATH=$PATH:$AFNIbinPATH
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh

