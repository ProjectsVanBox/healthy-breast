#!/bin/bash
#SBATCH -t 1:0:0
#SBATCH -c 2
#SBATCH --mem=50G

home_dir=$1
ASAP_NAME=$2

### Breast_2 analysis (WGS only)
module load bcftools
module load R

mkdir "$home_dir/3_Output/Breast_2/filtered/downstream"
cd "$home_dir/3_Output/Breast_2/filtered/downstream"

bcftools view -Oz -f PASS -m2 -M2 -v snps $home_dir/3_Output/Breast_2/ASAP/vcf/germline/somatic_filtering/SMuRF/$ASAP_NAME.vep.SMuRF.filtered.joined.vcf.gz > biall_snps.vcf.gz
bcftools sort -Oz biall_snps.vcf.gz > biall_snps_sorted.vcf.gz
bcftools index biall_snps_sorted.vcf.gz

Rscript "$home_dir/2_Code/mutmat_WGS.R" $home_dir
