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
An entire set of fMRI/sMRI pairs can be submitted to the SLURM scheduler on the high performance compute (HPC) cluster
The set of fMRI/sMRI file pairs, along with the desired output directory, should be provided to the script such that the entire set is processed as individual, parallel instances of SLURM jobs. Each SLURM job is an instance of the script being executed inside a container instance. The resulting processed file is written to the output directory specified for that particular sMRI/fMRI pair.

Steps (Explained in Detail Below): 
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
full file path on the cluster to functional MRI file for a subject
full file path on the cluster to anatomical MRI file for a subject
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the left right spin echo field map file for a subject
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the right left spin echo field map file for a subject
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the bias channel field map file for a subject
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the bias body coil field map file for a subject
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the single band reference (SBREF) image 
(OPTIONAL/DEPENDS ON FLAGS) full file path on the cluster to the acquisition parameters file
full file path on the cluster to the subject's output directory to which processed files are to be written
```


## Prepare the Output Directories
## Submit to SLURM




