#!/bin/bash

ID=${SLURM_ARRAY_TASK_ID}

#subjects=( `aws s3  ls s3://data/users2/nshor/Multiband_with_MEG/ | grep s | awk '{print $2}'` )
#commented above out --will
#S3_PATH=s3:/data/users2/nshor/Multiband_with_MEG/
SUBJ_DIR=${subjects[${ID}]}

#mkdir /data I will make data a bind point--will
#data will be MULTI...
cd /data
#cp /pd_dockerParralelized.sh .

#echo ${S3_PATH}${SUBJ_DIR}
#aws s3 sync ${S3_PATH}${SUBJ_DIR} ./${SUBJ_DIR}

CURRDIR=`pwd`
#mkdir derivatives
#derivatives is already there? -- will 
echo "1 0  0 1" > ${CURRDIR}/derivatives/acqparams.txt
echo "1 0  0 1" >> ${CURRDIR}/derivatives/acqparams.txt
echo "1 0  0 1" >> ${CURRDIR}/derivatives/acqparams.txt
echo "-1 0  0 1" >> ${CURRDIR}/derivatives/acqparams.txt
echo "-1 0  0 1" >> ${CURRDIR}/derivatives/acqparams.txt
echo "-1 0  0 1" >> ${CURRDIR}/derivatives/acqparams.txt


#bash pd_dockerParralelized.sh ${CURRDIR}/${SUBJ_DIR}
SUBJ_DIR=$(pwd)/sub-01
echo $SUBJ_DIR
bash pd_dockerParralelized.sh ${SUBJ_DIR}

#aws s3 sync ${CURRDIR}/derivatives/${SUBJ_DIR}/processed s3://pd.tango/derivatives/${SUBJ_DIR}


