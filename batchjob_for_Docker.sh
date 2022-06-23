#!/bin/bash

ID=${AWS_BATCH_JOB_ARRAY_INDEX}

subjects=( `aws s3  ls s3://pd.tango/pre_only/ | grep s | awk '{print $2}'` )

S3_PATH=s3://pd.tango/pre_only/
SUBJ_DIR=${subjects[${ID}]}

mkdir /data
cd /data
cp /Track_1_Preproc_awsN.sh .

echo ${S3_PATH}${SUBJ_DIR}
aws s3 sync ${S3_PATH}${SUBJ_DIR} ./${SUBJ_DIR}

CURRDIR=`pwd`
mkdir derivatives
echo "1 0  0 1" > ${CURRDIR}/derivatives/acqparams.txt
echo "1 0  0 1" >> ${CURRDIR}/derivatives/acqparams.txt
echo "1 0  0 1" >> ${CURRDIR}/derivatives/acqparams.txt
echo "-1 0  0 1" >> ${CURRDIR}/derivatives/acqparams.txt
echo "-1 0  0 1" >> ${CURRDIR}/derivatives/acqparams.txt
echo "-1 0  0 1" >> ${CURRDIR}/derivatives/acqparams.txt


bash Track_1_Preproc_awsN.sh ${CURRDIR}/${SUBJ_DIR}

aws s3 sync ${CURRDIR}/derivatives/${SUBJ_DIR}/processed s3://pd.tango/derivatives/${SUBJ_DIR}

