# pd\_dockerParallelized.sh

## Name

pd\_dockerParallelized.sh - a script that preprocesses a subject's fMRI file

## Synopsis

### Usage:
```
bash pd_dockerParallelized.sh -a [sMRI file] -f [fMRI file] -o [output directory]
```

### Compulsory arguments (You MUST set one or more of):<br />
&nbsp;&nbsp;&nbsp;&nbsp; -f &nbsp;&nbsp;&nbsp;&nbsp; name of functional MRI (fMRI) file<br />
&nbsp;&nbsp;&nbsp;&nbsp; -a &nbsp;&nbsp;&nbsp;&nbsp; name of anatomical MRI (sMRI) file<br />
&nbsp;&nbsp;&nbsp;&nbsp; -o &nbsp;&nbsp;&nbsp;&nbsp; path to cluster directory to which subject's processed file is written out to<br />

### Optional Arguments
&nbsp;&nbsp;&nbsp;&nbsp; -j &nbsp;&nbsp;&nbsp;&nbsp; name of json sidecar file containing metadata<br />
&nbsp;&nbsp;&nbsp;&nbsp; -c &nbsp;&nbsp;&nbsp;&nbsp; bias channel field map file<br />
&nbsp;&nbsp;&nbsp;&nbsp; -b &nbsp;&nbsp;&nbsp;&nbsp; bias body coil field map file<br />
&nbsp;&nbsp;&nbsp;&nbsp; -s &nbsp;&nbsp;&nbsp;&nbsp; single band reference (SBREF) image file <br />
&nbsp;&nbsp;&nbsp;&nbsp; -l &nbsp;&nbsp;&nbsp;&nbsp; left-right spin echo field map file <br />
&nbsp;&nbsp;&nbsp;&nbsp; -r &nbsp;&nbsp;&nbsp;&nbsp; right-left spin echo field map file <br />


## Description

The preprocessing script pd\_dockerParallelized.sh takes the functional and anatomical MRI files and produces a smoothed, registered NIfTI file in MNI 152 space. If the appropriate field maps and acquisition parameters are provided as input from the user, TOPUP and bias correction take place. Otherwise, they are skipped. 

# Using on the HPC Cluster
_Overview:_ The script processes one run at a time, meaning it processes one fMRI/sMRI pair at once.
An entire set of fMRI/sMRI pairs can be submitted to the SLURM scheduler on the high performance computing (HPC) cluster.
The set of fMRI/sMRI file pairs, along with the desired output directory, should be provided to the script such that the entire set is processed as individual, parallel instances of SLURM jobs. Each SLURM job is an instance of the script being executed inside a container instance. The resulting processed file is written to the output directory specified for that particular sMRI/fMRI pair.

#### Steps (Explained in Detail Below): 
1. [Clone this Repository](#clone-this-repository)
2. [Prepare the Docker Container](#prepare-the-docker-container)
3. [Prepare the Singularity Container](#prepare-the-singularity-container)
4. [Prepare the Paths Input File](#prepare-the-paths-input-file)
5. [Prepare the Output Directories](#prepare-the-output-directories)
6. [Submit to SLURM](#submit-to-slurm)

## Clone this Repository
Connect to the cluster and clone this repository into your data directory by issuing the following command.

```
git clone https://github.com/neuroneural/nshor_docker/
```

### Repository Structure and Contents (Informational)
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

#### The `submitforce.sh` Script
* copies the `mkpths.sh` and `subjects.txt` files up a directory
* deletes the output directories for all subjects
* recreates the output directories for all subjects using `mkpths.sh`
* calculates the number of runs 
* submits the sbatch job to SLURM setting array to number of runs

#### The `setvarstest.sh` Script
* sets the environment variables necessary to run this script in the container
* source this `setvarstest.sh` script for testing in an interactive SLURM session
* you can then execute the following singularity exec call to test the script (in SLURM interactive mode)

```
singularity exec --writable-tmpfs --bind $RUN_BIND_POINT:/run,$func_bind:/func,$anat_bind:/anat,$out_bind:/out $SIF_FILE /run/${SCRIPT_NAME} -f $func_file -a $anat_file -o $out_bind &
```

There is a master submission script to be executed on the login node in the root directory of this repository. It is called `sub_dsall.sh` and it cleans up the output files and recreates them for each of the example datasets. After that, it executes the `submit.sh` script to send each dataset to process on slurm. 
#### The `sub_dsall.sh` Script
* Processes each example dataset in the following way: 
* Copies script to make paths file and output directory into project dir
* Copies textfile list of subjects into project dir
* Deletes existing processed files in output directory
* Makes new empty output directory 
* Moves subjects list and script for making paths file and output directories into output directory 
* Executes script to make paths file and output directories for each subject
* Submits the dataset to slurm for processing


## Prepare the Docker Container
The Dockerfile is already specified for this script in the root directory of this project, named `Dockerfile`. Clone this repository and move into the repository root directory where the Dockerfile is located. Build the docker image from the Dockerfile on a cluster machine that supports Docker operations. 

```
docker build . -t fmriproc
```
Where `fmriproc` is the name of the docker image. The name you choose for the docker image is arbitrary. 


To verify that your docker image was created, use the docker image ls command to display the images on the server. The docker image that you just created should be listed in the output of the following command. 

```
docker image ls
```

## Prepare the Singularity Container
Singularity is a container software used in HPC settings to work with Docker. You can create Singularity images and containers without needing administrative rights on the server. This script should be executed inside a Singularity container build off of a Docker image. With the Docker image built, load the Singularity module and build the .sif image. 

```
module load singularity
singularity build --writable-tmpfs output.sif docker-daemon://fmriproc
```

The `--writable-tmpfs` flag creates a temporary file system in the sif container that you can write intermediate files to. This script writes all intermediate files to the sif container's temporary file system. The temp file system is deleted after the script has been executed in the container. 


## Prepare the "Paths" Input File
The script expects an input text file of the follwing format, where order matters and lines with (OPTIONAL) at the end should only be included when their associated flags are utilized with the `pd_dockerParallelized.sh` script.

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

## Prepare the Output Directories
The script expects an output directory for each run to exist on the cluster which is provided by the user in the paths input file. It is the user's responsibility to prepare the output directory on the cluster. There are some example scripts on how to do this in each example project directory as part of this repository. For more information, see the [Repository Structure and Contents](#repository-structure-and-contents-informational) informational section.


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

## Submit to SLURM
The script can be ran on the cluster using an interactive SLURM job, or using sbatch (recommended). It is recommended to submit the job via sbatch when processing more than one subject. This is because each subject can take anywhere from 13 to 20 minutes each. 

#### Prerequisites: 
* prepared the docker and singularity containers
* found location(s) on the cluster of the raw data to be processed
* prepared the paths file and output directories


### Running using an SBATCH Session (Recommended)


#### Prepare the SLURM batch job file: 
The example of such a batch job script is `procruns.job` in this repository. See the [Repository Structure and Contents](#repository-structure-and-contents-informational) section for more information.
* create a bash script with the SLURM script tags after the shebang
* parse the input data provided in the paths file
* determine where to mount the sif container for functional and anatomical filepaths on the cluster (note, you should also mount a directory for the params file)
* call singularity exec on the sif container and `pd_dockerParallelized.sh` script
  * use the `--bind` flag to mount the func, anat, and params (optional) directories 
  * use the `--writeable-tmpfs` flag to use the sif container's temporary file system
  * pass the `pd_dockerParallelized.sh` script with appropriate flags

The following is an example of what the singularity exec call should look like:

 ```
singularity exec --writable-tmpfs --bind $RUN_BIND_POINT:/run,$func_bind:/func,$anat_bind:/anat,$out_bind:/out $SIF_FILE /run/${SCRIPT_NAME} -f $func_file -a $anat_file -j $json_file -o $out_bind &
 ```
For more information about running SLURM batch jobs, see the [SBATCH scripting guide](https://trendscenter.github.io/wiki/docs/Job_submission.html#sbatch-scripting-guide) in the cluster documentation.


### Running using an Interactive Session
For more information, see the [`setvarstest.sh` script](#the-setvarstestsh-script) section and associated outer section, [Repository Structure and Contents](#repository-structure-and-contents-informational). For running this script in an interactive session on the cluster, it is not required to use GPU partitions. You can use an interactive session for processing one or more subjects in the following way: 

* allocate an interactive session on the cluster using `srun`
* move into the project directory and source the `setvarstest.sh` file
  * or your own bash file which sets the required environment variables for the singularity exec call
* run the `pd_dockerParallelized.sh` script inside the sif container using singularity exec
  * see the above section for the singularity exec call
* note, you need to adjust the `SLURM_ARRAY_TASK_ID` to control which run to process from your paths input file
  * setting `SLURM_ARRAY_TASK_ID=1` processes the first run from your paths input file
  * this only applies to interactive runs that use the `setvarstest.sh` scripts to set environment variables


For more information about running SLURM interactive jobs, see the [resource allocation guide](https://trendscenter.github.io/wiki/docs/Log_in_to_the_cluster.html#headlogin-node-vs-computeworker-nodes) in the cluster documentation.


