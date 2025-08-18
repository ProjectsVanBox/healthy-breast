#!/bin/bash
#SBATCH -t 2:0:0
#SBATCH -c 4
#SBATCH --mem=20G

### filter only the callable loci
module load bedtools
module load R

home_dir=$1
cd "$home_dir/3_Output/Breast_1/filtered_PTA/callable"

bedtools sort -i S8506Nr1_dedup_CallableLoci.bed > S8506Nr1_dedup_CallableLoci_sorted.bed
bedtools sort -i S8506Nr2_dedup_CallableLoci.bed > S8506Nr2_dedup_CallableLoci_sorted.bed
bedtools sort -i S8506Nr3_dedup_CallableLoci.bed > S8506Nr3_dedup_CallableLoci_sorted.bed
bedtools sort -i S8506Nr4_dedup_CallableLoci.bed > S8506Nr4_dedup_CallableLoci_sorted.bed
bedtools sort -i S8506Nr5_dedup_CallableLoci.bed > S8506Nr5_dedup_CallableLoci_sorted.bed
bedtools sort -i S8506Nr6_dedup_CallableLoci.bed > S8506Nr6_dedup_CallableLoci_sorted.bed

grep "CALLABLE" S8506Nr1_dedup_CallableLoci_sorted.bed > S8506Nr1_dedup_CallableLoci_sorted_filtered.bed
grep "CALLABLE" S8506Nr2_dedup_CallableLoci_sorted.bed > S8506Nr2_dedup_CallableLoci_sorted_filtered.bed
grep "CALLABLE" S8506Nr3_dedup_CallableLoci_sorted.bed > S8506Nr3_dedup_CallableLoci_sorted_filtered.bed
grep "CALLABLE" S8506Nr4_dedup_CallableLoci_sorted.bed > S8506Nr4_dedup_CallableLoci_sorted_filtered.bed
grep "CALLABLE" S8506Nr5_dedup_CallableLoci_sorted.bed > S8506Nr5_dedup_CallableLoci_sorted_filtered.bed
grep "CALLABLE" S8506Nr6_dedup_CallableLoci_sorted.bed > S8506Nr6_dedup_CallableLoci_sorted_filtered.bed

bedtools multiinter -i S8506Nr1_dedup_CallableLoci_sorted_filtered.bed S8506Nr2_dedup_CallableLoci_sorted_filtered.bed S8506Nr3_dedup_CallableLoci_sorted_filtered.bed S8506Nr4_dedup_CallableLoci_sorted_filtered.bed S8506Nr5_dedup_CallableLoci_sorted_filtered.bed S8506Nr6_dedup_CallableLoci_sorted_filtered.bed > common_callable.bed

grep "1,2,3,4,5,6" common_callable.bed > common_callable_filtered.bed

awk '{OFS="\t"; print $1,$2,$3}' common_callable_filtered.bed > callable.tsv
