# nshor_docker
## Dockerfile
The docker file may be built using the following example command from inside the directory containing the dockerfile and the robex tar
          docker build -t yourname/yourproject .

## Singularity sif file
Once you have built the dockerfile into a docker image, you may build the docker image into a sif file using singularity commands 
          singularity build output.sif docker-daemon://yourname/yourproject-latest

## Running the container 
Once you have built the container, you may run the singularity container, but first you probably need a node to run it on 

           srun -p qTRDGPUH -A PSYC0002 -v -n1 -c 12 --mem=20G  --nodelist=trendsdgx003.rs.gsu.edu --pty /bin/bash

Note you may need more resources, but this will process a single patient in about 10-20 minutes. This is more cpu heavy than ram heavy.

Once you have a node with sufficient resources, you may run the following singularity command 

           singularity exec --bind /data/users2/nshor/share/Multiband_with_MEG:/data/,/data/users2/nshor/share:/share/ /data/users2/nshor/Dockerbuild/nshor.sif /data/pd_dockerParralelized.sh

the bind command maps local paths onto internal container paths. 
exec runs the command at the end of the string. 
We ran with the shell scripts inside the Multiband_with_MEG data from thomas. 
It may not need the share bind, but we did that as a convenience 
## TODO 
We need to implement multiple subject processing and test the single subject implementation.
## More information
we attempted to keep a log of our activities in #docker-projects slack channel
Thomas deramus also knows more as does nicholas shor
Also sergey oversaw this project


## Code api calls documentation
AFNI 
  3dcalc docs
  https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dcalc.html

  3dwarp
  https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dWarp.html

  3dAutomask
  https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dAutomask.html
  
  abids_json_info.py
  
  3dDespike
  
  3dTshift
  
  3dvolreg
  
  3dresample
  
  1deval
  
  
  
FSL
  fslmerge
  https://rdrr.io/cran/fslr/man/fslmerge.html
    
  topup
    https://rdrr.io/github/neuroconductor-devel-releases/fslr/man/topup.html

  applytopup
    https://rdrr.io/github/neuroconductor/fslr/man/applytopup.html

  fast
  
  fslmaths
  
  flirt
  
  applywarp
  
  mcflirt

Ants
  N4BiasFieldCorrection
  https://github.com/ANTsX/ANTs/wiki/N4BiasFieldCorrection
  
  antsRegistrationSyN.sh
  
  WarpTimeSeriesImageMultiTransform

ROBEX

C3D
   c3d_affine_tool
   
