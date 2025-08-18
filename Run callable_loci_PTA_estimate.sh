#!/bin/bash

#SBATCH --time=24:0:0
#SBATCH --mem=60G 

# batch 1 analysis
# PART1
home_dir = $1
## filtering common callable loci
### creating dirs
mkdir -r $home_dir/3_Output/Breast_1/filtered_PTA/callable
cd $home_dir/3_Output/Breast_1/filtered_PTA/callable

### run CallableLoci for WGS samples
sbatch $home_dir/2_Code/run_CallableLoci_30x.sh $home_dir/1_Input/Breast_1/S8506Nr1_dedup.bam
sbatch $home_dir/2_Code/run_CallableLoci_30x.sh $home_dir/1_Input/Breast_1/S8506Nr2_dedup.bam

### run CallableLoci for PTA samples
sbatch $home_dir/2_Code/run_CallableLoci_15x.sh $home_dir/1_Input/Breast_1/S8506Nr3_dedup.bam
sbatch $home_dir/2_Code/run_CallableLoci_15x.sh $home_dir/1_Input/Breast_1/S8506Nr4_dedup.bam
sbatch $home_dir/2_Code/run_CallableLoci_15x.sh $home_dir/1_Input/Breast_1/S8506Nr5_dedup.bam
sbatch $home_dir/2_Code/run_CallableLoci_15x.sh $home_dir/1_Input/Breast_1/S8506Nr6_dedup.bam
