#!/bin/bash
# Normalize variance across the subjects. Requires the group mean mask

#---------------------------------------------------------------------
set -o nounset # exit if uninitialized variables
set -o errexit # exit on any error
# =================================================================
# configure freesurfer or copy two lines below to your ~/.bashrc
# export FREESURFER_HOME=/usr/local/freesurfer/freesurfer_5.1
# source $FREESURFER_HOME/SetUpFreeSurfer.sh
#---------------------------------------------------------------------

BASEDIR=
OUTDIR=
CURDIR=`pwd`
FMRIDIR=fmri_subjects

cd $BASEDIR
subject=(h20031219_094210_03030370 h20040402_153422_04030582 h20050328_120427_05031526 h20050331_152209_05031534 h20051111_105949_05032077 h20051116_162858_05032100 h20051217_085643_05032201 h20060104_150847_06032236 h20060210_152449_06032370 h20060228_103219_06032434 h20060315_140534_06032499 h20060321_171236_06032528 h20060418_154156_06032609 h20060605_145624_06032750 h20060624_093052_06032805 h20060629_163400_06032829 h20060706_113353_06032837 h20060725_152616_06032917 h20060905_101432_06033067 h20060909_124225_06033084 h5032190 h5032222 h6032239 h6032247 h6032253 h6032807 h6032819 h6032835)

# variance normalization
typeset -i idx
for (( idx = 0 ; idx < ${#subject[@]} ; idx++)); do
	echo ${subject[idx]}
	cd ${subject[idx]}/1 &>/dev/null
	3dTstat -mean -stdev -mask $OUTDIR/$FMRIDIR/groupmeanmask.nii \
		-prefix MeanStd.nii swraod.nii &>/dev/null
	3dcalc  -a swraod.nii -b MeanStd.nii'[0]' -c MeanStd.nii'[1]' \
		-d $OUTDIR/$FMRIDIR/groupmeanmask.nii \
		-expr "((a-b)/c + 100) * d" -prefix  vswraod.nii &>/dev/null
	ln -sf `pwd`/vswraod.nii $OUTDIR/$FMRIDIR/${subject[idx]}_vswraod.nii
	cd - &>/dev/null
done
cd $CURDIR
