# batch 1 analysis
# PART1

## filtering common callable loci
### creating dirs
mkdir 3_Output/filtered_PTA/callable
cd 3_Output/filtered_PTA/callable

### run CallableLoci for WGS samples
sbatch ./run_CallableLoci_30x.sh 1_Input/Breast_1/S8506Nr1_dedup.bam
sbatch ./run_CallableLoci_30x.sh 1_Input/Breast_1/S8506Nr2_dedup.bam

### run CallableLoci for PTA samples
sbatch ./run_CallableLoci_15x.sh 1_Input/Breast_1/S8506Nr3_dedup.bam
sbatch ./run_CallableLoci_15x.sh 1_Input/Breast_1/S8506Nr4_dedup.bam
sbatch ./run_CallableLoci_15x.sh 1_Input/Breast_1/S8506Nr5_dedup.bam
sbatch ./run_CallableLoci_15x.sh 1_Input/Breast_1/S8506Nr6_dedup.bam
