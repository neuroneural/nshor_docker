# nshor\_docker

## About
The preprocessing script pd\_dockerParallelized.sh takes the functional and anatomical MRI files and produces a smoothed, registered NIfTI file in MNI 152 space. If the appropriate field maps and acquisition parameters are provided as input from the user, TOPUP and bias correction take place. Otherwise, they are skipped. 


## Using on the HPC Cluster
_Overview:_ The script processes one run at a time, meaning it processes one fMRI/sMRI pair at once.
An entire set of fMRI/sMRI pairs can be submitted to the SLURM scheduler on the high performance computing (HPC) cluster.
The set of fMRI/sMRI file pairs, along with the desired output directory, should be provided to the script such that the entire set is processed as individual, parallel instances of SLURM jobs. Each SLURM job is an instance of the script being executed inside a container instance. The resulting processed file is written to the output directory specified for that particular sMRI/fMRI pair.

### First Time Setup: 
1. [Clone this Repository](#1-clone-this-repository)
2. [Prepare the Docker Container](#2-prepare-the-docker-container)
3. [Prepare the Singularity Container](#3-prepare-the-singularity-container)

### Usage:
- [Process a Single File](#process-a-single-file)
- [Set Up for Slurm Job Submissions](#set-up-for-slurm-job-submissions)

### Additional Information:
- [Running using an Interactive Session](#running-using-an-interactive-session)
- [About the Examples](#about-the-examples)
- [Preparing Output Directories](#preparing-output-directories)

# First Time Setup

## 1. Clone this Repository
Connect to the cluster and clone this repository into your data directory by issuing the following command.

```
git clone https://github.com/neuroneural/nshor_docker/
```

## 2. Prepare the Docker Container
The Dockerfile is already specified for this script in the root directory of this project, named `Dockerfile`. This copies `pd_dockerParallelized.sh` into a file inside the container that can later be called through the Singularity commands.

1. Enter a cluster node that has docker. Currently this includes `arctrdcn017` and `arctrdgndev101`
2. If you get permissions errors using the following commands, submit a ticket at [hydra.gsu.edu](https://hydra.gsu.edu/) (with assignee `arctic_developers`) asking to be added to the docker group.
3. Enter your cloned `nshor_docker` directory.
4. Build the Docker container using the premade `Dockerfile`:
```
docker build . -t fmriproc:latest
```
> Note that `fmriproc` **is an arbitrary name** and may be overwritten if someone else creates a Docker image with the same name on the same cluster node. It's recommended to use a unique name, such as `fmriproc_YOUR-USERNAME`. Be sure to future instances of `fmriproc` with your chosen name.
> 
> The tag name ("latest" here) is also arbitrary, but does not need to be unique. If you set no tag, it will be set to "latest", so that's what's used in the following demo commands. (Some future commands may throw errors if no tag is specified when referencing your image, which is why it matters.)
1. You may use `docker image ls` to confirm your Docker image exists.
2. (OPTIONAL/SITUATIONAL) There may be a scenario in which archiving the docker image to a tar file would be beneficial. In a case where singularity and docker are not available on the same server, then exporting to a tar file would make it possible to build the singularity file without the docker daemon running. To archive an existing docker image, use: `docker save -o fmriproc.tar fmriproc:latest`


## 3. Prepare the Singularity Container
Singularity is a container software used in HPC settings to work with Docker. You can create Singularity images and containers without needing administrative rights on the server. This script should be executed inside a Singularity container build off of a Docker image. With the Docker image built, load the Singularity module and build the .sif image.

1. Load the singularity module:
```bash
module load singularity
```
2. Build the singularity container:
```bash
singularity build --writable-tmpfs output.sif docker-daemon://fmriproc:latest
```
> If your docker image has been archived as a .tar file, then you can use Singularity's docker-archive option without needing the docker daemon to be awake: `singularity build --writable-tmpfs output.sif docker-archive://fmriproc.tar`

> The `--writable-tmpfs` flag creates a temporary file system in the sif container that you can write intermediate files to. This script writes all intermediate files to the sif container's temporary file system's `shm` directory, or shared memory.


# Usage

## Process A Single File
```bash
singularity exec --writable-tmpfs --bind $func_bind:/func,$anat_bind:/anat,$out_bind:/out $SIF_FILE /main.sh -f $func_file -a $anat_file -o $out_bind
```

#### Mandatory:
- `$SIF_FILE` is a path to your Singularity container file, as specified by the `--writable-tmpfs` argument when running `singularity build` earlier. Our example named it `output.sif`.
- `$func_file` is an fMRI file inside the `$func_bind` absolute directory
- `$anat_file` is an sMRI file inside the `$anat_bind` absolute directory
- `$out_bind` is an existing output directory to which subject's processed file is written out

#### Optional extra arguments:
- `-j` : name of json sidecar file containing metadata
- `-c` : bias channel field map file
- `-b` : bias body coil field map file
- `-s` : single band reference (SBREF) image file
- `-l` : left-right spin echo field map file
- `-r` : right-left spin echo field map file

> You must use `module load singularity` before running singularity commands in a given session. Otherwise, you will get a "command 'singularity' not found" error.


## Set Up for Slurm Job Submissions
You can view more examples in the [examples](https://github.com/neuroneural/nshor_docker/tree/master/examples) section of this repository, but here's a simple example setup for submitting a large number of files to the cluster for processing. Look at [Repository Structure and Contents] for more info on the purpose of each file, and additional helper files that show up in the examples section.

### "Paths" input file
The script expects an input text file of the follwing format, where order matters and lines with (OPTIONAL) at the end should only be included when their associated flags are utilized with the `pd_dockerParallelized.sh` script. **Given output directories should be unique & should already exist on the cluster.** See the [Preparing Output Directories](#preparing-output-directories) section for more info.

```
full file path on the cluster to functional MRI file for 1st run
full file path on the cluster to anatomical MRI file for 1st run
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the left right spin echo field map file for 1st run
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the right left spin echo field map file for 1st run
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the bias channel field map file for 1st run
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the bias body coil field map file for 1st run
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the single band reference (SBREF) image for 1st run
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the acquisition parameters file for 1st run
full file path on the cluster to the subject's output directory to which processed files are to be written for 1st run
.
.
.
full file path on the cluster to functional MRI file for nth run
full file path on the cluster to anatomical MRI file for nth run
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the left right spin echo field map file for nth run
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the right left spin echo field map file for nth run
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the bias channel field map file for nth run
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the bias body coil field map file for nth run
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the single band reference (SBREF) image for nth run
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the acquisition parameters file for nth run
full file path on the cluster to the subject's output directory to which processed files are to be written for nth run
```

Where n is the number of runs that you wish to process. The user is responsible for generating such a file, which can be done using bash. There are some example scripts in each example project directory as part of this repository. For more information, see the [Repository Structure and Contents](#repository-structure-and-contents-informational) informational section above.

The simplest version of this file (with no optional flags provided) looks like:
```
PATH_TO_FMRI_FILE_1
PATH_TO_ANAT_FILE_1
PATH_TO_OUT_DIRECTORY_1
PATH_TO_FMRI_FILE_2
PATH_TO_ANAT_FILE_2
PATH_TO_OUT_DIRECTORY_2
...
```

### `procruns.job`
The file that sets up each slurm submission.
```bash
#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH --mem=64g
#SBATCH -p qTRD
#SBATCH --time=20:00:00
#SBATCH -J NAME_OF_JOB
#SBATCH -e FULL/PATH/TO/LOGS/OUTPUT/DIRECTORY/%A_%a.err
#SBATCH -o FULL/PATH/TO/LOGS/OUTPUT/DIRECTORY/%A_%a.out
#SBATCH -A psy53c17
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL
#SBATCH --oversubscribe

sleep 5s

module load singularity/3.10.2

SUB_PATHS_FILE=FULL/PATH/TO/PATHS/FILE.txt

SIF_FILE=FULL/PATH/TO/SINGULARITY/CONTAINER.sif

IFS=$'\n'
paths_array=($(cat ${SUB_PATHS_FILE}))

anat_ix=$(( 3*SLURM_ARRAY_TASK_ID ))
func_ix=$(( 3*SLURM_ARRAY_TASK_ID + 1 ))
out_ix=$(( 3*SLURM_ARRAY_TASK_ID + 2 ))

anat_filepath=${paths_array[${anat_ix}]}
func_filepath=${paths_array[${func_ix}]}

out_bind=${paths_array[${out_ix}]}
anat_bind=`dirname $anat_filepath`
func_bind=`dirname $func_filepath`

anat_file=`basename $anat_filepath`
func_file=`basename $func_filepath`

singularity exec --writable-tmpfs --bind $func_bind:/func,$anat_bind:/anat,$out_bind:/out $SIF_FILE /main.sh -f $func_file -a $anat_file -o $out_bind &

wait

sleep 10s
```

### `submit.sh`
The file to run on the login node to submit the above in an array:

```bash
#!/bin/bash

project_dir=FULL/PATH/TO/nshor_docker
paths_file=${project_dir}/paths.txt

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( num_lines / 3 ))

runix=$(( num_total_runs ))

cd $project_dir

sbatch --array=0-${runix} ${project_dir}/procruns.job
```

After creating these files and filling out the paths, you would then run `bash submit.sh` on the login node.

> **Misc. Troubleshooting**
> - If having trouble submitting ry manually [processing a single file](#process-a-single-file) from your PATHS file (on a dev node), to make sure your paths are correct.
> - Errors like "`Can't open dataset`" showing up in your logs usually means there's a problem with your file paths. Double check that all paths are correct and listed in the right places across your submission and paths files.


# Additional Information

## Running using an Interactive Session
For more information, see the [`setvarstest.sh` script](#the-setvarstestsh-script) section and associated outer section, [Repository Structure and Contents](#repository-structure-and-contents-informational). For running this script in an interactive session on the cluster, it is not required to use GPU partitions. You can use an interactive session for processing one or more subjects in the following way: 

* allocate an interactive session on the cluster using `srun`
* move into the project directory and source the `setvarstest.sh` file
  * or your own bash file which sets the required environment variables for the singularity exec call
* run the `pd_dockerParallelized.sh` script inside the sif container using singularity exec
  * see the above section for the singularity exec call
* note, you need to adjust the `SLURM_ARRAY_TASK_ID` to control which run to process from your paths input file
  * setting `SLURM_ARRAY_TASK_ID=0` processes the first run from your paths input file
  * this only applies to interactive runs that use the `setvarstest.sh` scripts to set environment variables

For more information about running SLURM interactive jobs, see the [resource allocation guide](https://trendscenter.github.io/wiki/docs/Log_in_to_the_cluster.html#headlogin-node-vs-computeworker-nodes) in the cluster documentation.


## About the Examples
The repository contains example project directories in the `examples` directory. Each example is named `<DATASET>-project` where `<DATASET>` is replaced by the dataset name. Inside each of these project directories are some helper scripts for each dataset to perform various tasks related to this script.

#### The `mkpths.sh` Script
* looks at the raw data on the cluster
* counts the number of subjects from the input `subjects.txt` file
* iterates over all subjects' runs
* writes the desired files (func/anat/fieldmaps/params) to the paths file
* creates output directories in the user's data directory for the processed results

#### The `procruns.job` Script
* sets the SBATCH settings for SLURM
* loads the `singularity` module
* tells the script where the paths file is located (see "Preparing the Paths File")
* parses the data filepaths and bindpoints from the paths file
* mounts the location on the cluster of the input data for the sif container to access
* executes the script in the sif container providing filepaths as input

#### The `submit.sh` Script
* sets the project directory and paths file
* counts the number of lines in the paths file 
* divides num lines by the number of files per subject to determine number of total runs included in file
* sets the SLURM array to the number calculated in the previous step
* submits the `procruns.job` script to SLURM as an sbatch submission

#### The `setvarstest.sh` Script
* sets the environment variables necessary to run this script in the container
* source this `setvarstest.sh` script for testing in an interactive SLURM session
* you can then execute a [singularity exec call](#process-a-single-file) to test the script (in SLURM interactive mode)


## Preparing Output Directories
The script expects an output directory for each run to exist on the cluster which is provided by the user in the paths input file. It is the user's responsibility to prepare the output directory on the cluster. There are some example scripts on how to do this in each example project directory as part of this repository. For more information, see the [About the Examples](#about-the-examples) section above.

For example, if you are trying to process a number of runs from the BSNIP dataset, you might create an output directory `BSNIP` which will hold the processed information for each subject. You can create a subdirectory for each subject and within that, a directory for each session or run that you wish to process. See the file structure below for an illustration of this example. 

```
/data/users2/<GSU_ID>/nshor_docker/
├── bsnip-project
│   ├── BSNIP
│   │   └── Boston
│   │       ├── mkpths.sh
│   │       ├── paths
│   │       ├── S0153WRT1
│   │       │   └── ses_01
│   │       │       └── processed
│   │       │           └── S0153WRT1_rsfMRI_processed_rest.nii.gz
│   │       ├── S0914NVL1
│   │       │   └── ses_01
│   │       │       └── processed
│   │       │           └── S0914NVL1_rsfMRI_processed_rest.nii.gz
│   │       ├── S1424WOT1
│   │       │   └── ses_01
│   │       │       └── processed
│   │       │           └── S1424WOT1_rsfMRI_processed_rest.nii.gz
.
.
.
│   │       ├── S9670AKK1
│   │       │   └── ses_01
│   │       │       └── processed
│   │       │           └── S9670AKK1_rsfMRI_processed_rest.nii.gz
│   │       ├── S9875KAK1
│   │       │   └── ses_01
│   │       │       └── processed
│   │       │           └── S9875KAK1_rsfMRI_processed_rest.nii.gz
│   │       └── subjects.txt
```

The `<SUBJECT_ID>_rsfMRI_processed_rest.nii.gz` files are the result of running the preprocessing script, where SUBJECT_ID is the subject ID for the subject and GSU_ID is your GSU ID. 
