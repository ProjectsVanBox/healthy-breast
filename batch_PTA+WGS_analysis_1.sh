# batch 1 analysis
# PART1

## filtering common callable loci
### creating dirs
mkdir .output/filtered_PTA/callable
cd .output/filtered_PTA/callable

### run CallableLoci for WGS samples
sbatch ./run_CallableLoci_30x.sh ./inputs/Breast/S8506Nr1_dedup.bam
sbatch ./run_CallableLoci_30x.sh ./inputs/Breast/S8506Nr2_dedup.bam

### run CallableLoci for PTA samples
sbatch ./run_CallableLoci_15x.sh ./inputs/Breast/S8506Nr3_dedup.bam
sbatch ./run_CallableLoci_15x.sh ./inputs/Breast/S8506Nr4_dedup.bam
sbatch ./run_CallableLoci_15x.sh ./inputs/Breast/S8506Nr5_dedup.bam
sbatch ./run_CallableLoci_15x.sh ./inputs/Breast/S8506Nr6_dedup.bam
