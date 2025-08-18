#!/bin/bash
#SBATCH -t 2:0:0
#SBATCH -c 2
#SBATCH --mem=10G
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=e.kulaeva@prinsesmaximacentrum.nl

home_dir=$1

## Breast_1
### merge all PTATO-filtered vcfs

module load bcftools
module load R

cd "$home_dir/3_Output/Breast_1/filtered_PTA/PTATO_PON/snvs/Breast_1/"
bcftools merge -Oz PTA_WGS_0.2_PON_S8506Nr3/PTA_WGS_0.2_PON_S8506Nr3.snvs.ptato.filtered.vcf.gz PTA_WGS_0.2_PON_S8506Nr4/PTA_WGS_0.2_PON_S8506Nr4.snvs.ptato.filtered.vcf.gz PTA_WGS_0.2_PON_S8506Nr5/PTA_WGS_0.2_PON_S8506Nr5.snvs.ptato.filtered.vcf.gz PTA_WGS_0.2_PON_S8506Nr6/PTA_WGS_0.2_PON_S8506Nr6.snvs.ptato.filtered.vcf.gz > $home_dir/3_Output/Breast_1/filtered_PTA/downstream/PTATO_filtered.vcf.gz
bcftools merge -Oz PTA_WGS_0.2_PON_S8506Nr3.snvs.ptato.vcf.gz PTA_WGS_0.2_PON_S8506Nr4.snvs.ptato.vcf.gz PTA_WGS_0.2_PON_S8506Nr5.snvs.ptato.vcf.gz PTA_WGS_0.2_PON_S8506Nr6.snvs.ptato.vcf.gz >  $home_dir/3_Output/Breast_1/filtered_PTA/downstream/PTATO_flagged.vcf.gz

### filter out dbSNPs from the filtered file and subset initial multiVCF file by PTATO filtered variants

cd "$home_dir/3_Output/Breast_1/filtered_PTA/downstream/"

tabix -p vcf PTATO_filtered.vcf.gz
tabix -p vcf PTATO_flagged.vcf.gz
tabix -p vcf biall_snps.vcf.gz
bcftools isec -p matrix_intersect PTATO_filtered.vcf.gz biall_snps.vcf.gz
bcftools view -R matrix_intersect/0002.vcf biall_snps.vcf.gz -Oz -o matrix.vcf.gz
bcftools index matrix.vcf.gz
Rscript $home_dir/2_Code/mutmatWGS_PTA.R
