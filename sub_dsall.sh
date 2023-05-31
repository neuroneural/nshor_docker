#!/bin/bash

cd /data/users2/jwardell1/nshor_docker
######################################################################################################
# FBIRN
# 1. Copies script to make paths file and output directory into project dir
# 2. Copies textfile list of subjects into project dir
# 3. Deletes existing processed files in output directory
# 4. Makes new empty output directory 
# 5. Moves subjects list and script for making paths file and output directories into output directory 
# 6. Executes script to make paths file and output directories for each subject
# 7. Submits the dataset to slurm for processing
#####################################################################################################gg
cp /data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/fbirn-project/
cp /data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/subjects.txt /data/users2/jwardell1/nshor_docker/examples/fbirn-project/
rm -rf /data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN
mkdir /data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN
mv /data/users2/jwardell1/nshor_docker/examples/fbirn-project/subjects.txt /data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/subjects.txt
mv /data/users2/jwardell1/nshor_docker/examples/fbirn-project/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/mkpths.sh
cd examples/fbirn-project
bash /data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/mkpths.sh
bash /data/users2/jwardell1/nshor_docker/examples/fbirn-project/submit.sh
echo "fbirn submitted"


cd /data/users2/jwardell1/nshor_docker
######################################################################################################
# BSNIP
# 1. Copies script to make paths file and output directory into project dir
# 2. Copies textfile list of subjects into project dir
# 3. Deletes existing processed files in output directory
# 4. Makes new empty output directory 
# 5. Moves subjects list and script for making paths file and output directories into output directory 
# 6. Executes script to make paths file and output directories for each subject
# 7. Submits the dataset to slurm for processing
#####################################################################################################gg
cp /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/bsnip-project/
cp /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/subjects.txt /data/users2/jwardell1/nshor_docker/examples/bsnip-project/
rm -rf /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP
mkdir /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP
mkdir /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston
mv /data/users2/jwardell1/nshor_docker/examples/bsnip-project/subjects.txt /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/subjects.txt
mv /data/users2/jwardell1/nshor_docker/examples/bsnip-project/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/mkpths.sh
cd examples/bsnip-project
bash /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/mkpths.sh
bash /data/users2/jwardell1/nshor_docker/examples/bsnip-project/submit.sh
echo "bsnip submitted"






cd /data/users2/jwardell1/nshor_docker
######################################################################################################
# HCP
# 1. Copies script to make paths file and output directory into project dir
# 2. Copies textfile list of subjects into project dir
# 3. Deletes existing processed files in output directory
# 4. Makes new empty output directory 
# 5. Moves subjects list and script for making paths file and output directories into output directory 
# 6. Executes script to make paths file and output directories for each subject
# 7. Submits the dataset to slurm for processing
#####################################################################################################gg
cp /data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/hcp-project/
cp /data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/subjects.txt /data/users2/jwardell1/nshor_docker/examples/hcp-project/
rm -rf /data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP
mkdir /data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP
mv /data/users2/jwardell1/nshor_docker/examples/hcp-project/subjects.txt /data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/subjects.txt
mv /data/users2/jwardell1/nshor_docker/examples/hcp-project/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/mkpths.sh
cd examples/hcp-project
bash /data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/mkpths.sh
bash /data/users2/jwardell1/nshor_docker/examples/hcp-project/submit.sh
echo "hcp submitted"



cd /data/users2/jwardell1/nshor_docker
######################################################################################################
# ds004078
# 1. Copies script to make paths file and output directory into project dir
# 2. Copies textfile list of subjects into project dir
# 3. Deletes existing processed files in output directory
# 4. Makes new empty output directory 
# 5. Moves subjects list and script for making paths file and output directories into output directory 
# 6. Executes script to make paths file and output directories for each subject
# 7. Submits the dataset to slurm for processing
#####################################################################################################
cp /data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/ds004078-project/
cp /data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078/subjects.txt /data/users2/jwardell1/nshor_docker/examples/ds004078-project/
rm -rf /data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078
mkdir /data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078
mv /data/users2/jwardell1/nshor_docker/examples/ds004078-project/subjects.txt /data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078/subjects.txt
mv /data/users2/jwardell1/nshor_docker/examples/ds004078-project/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078/mkpths.sh
cd examples/ds004078-project
bash /data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078/mkpths.sh
bash /data/users2/jwardell1/nshor_docker/examples/ds004078-project/submit.sh
echo "ds004078 submitted"
