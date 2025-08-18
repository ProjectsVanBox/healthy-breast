#!/bin/bash
#SBATCH -t 6:0:0
#SBATCH -c 4
#SBATCH --mem=30G

module load bcftools
### filter initial file by PASS, biallelic SNPs
IAP_NAME=$1
mkdir ./3_Output/Breast_1/filtered_PTA/downstream
cd ./3_Output/Breast_1/filtered_PTA/downstream
bcftools view -Oz -f PASS -m2 -M2 -v snps ./$IAP_NAME.vcf.filtered_variants_dbnsfp_CosmicCodingMuts_gonl.snps_indels.r5.liftover.hg38.sorted.vcf > biall_snps.vcf.gz
bcftools index biall_snps.vcf.gz

### overlap with common callable regions
bcftools view -Oz -R ./3_Output/Breast_1/filtered_PTA/callable/callable.tsv biall_snps.vcf.gz > callable.vcf.gz
bcftools index callable.vcf.gz

### extract sample names and split by sample
bcftools query -l callable.vcf.gz > sample_names.txt

for sample in $(cat sample_names.txt); do
    bcftools view -Oz -c1 -s $sample -o ${sample}.vcf.gz callable.vcf.gz
done

### filter files 1-2 (non-PTA) by VAF > 0.2
bcftools view -Oz -i 'INFO/AF>0.2' S8506Nr1.vcf.gz > S8506Nr1.vcf.gz_0.2.vcf.gz
bcftools view -Oz -i 'INFO/AF>0.2' S8506Nr2.vcf.gz > S8506Nr2.vcf.gz_0.2.vcf.gz

bcftools index S8506Nr1.vcf.gz_0.2.vcf.gz
bcftools index S8506Nr2.vcf.gz_0.2.vcf.gz
bcftools index S8506Nr3.vcf.gz
bcftools index S8506Nr4.vcf.gz
bcftools index S8506Nr5.vcf.gz
bcftools index S8506Nr6.vcf.gz

### find common variants in 2 or more samples
bcftools isec -Oz -n+2 S8506Nr1.vcf.gz_0.2.vcf.gz S8506Nr2.vcf.gz_0.2.vcf.gz S8506Nr3.vcf.gz S8506Nr4.vcf.gz S8506Nr5.vcf.gz S8506Nr6.vcf.gz > variants_02.txt

### subset variants file by list of exclusions and turn it to positions list
grep -v -f remove.txt variants_02.txt > variants_02_filt.txt
grep -v -E "decoy|EBV" variants_02_filt.txt > variants_02_filt_2.txt
awk '{OFS="\t"; print $1,$2}' variants_02_filt_2.txt > pos_02_filt.tsv

### subset initial VCF by positions list and remove PON variants
bcftools view -Oz -R pos_02_filt.tsv biall_snps.vcf.gz > final_filtered_0.2_biall.vcf.gz
mkdir ./3_Output/Breast_1/filtered_PTA/Breast_1/
Rscript ./PON_remove_PTA.R
mkdir ./3_Output/filtered_PTA/PTATO_PON
