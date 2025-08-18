#!/bin/bash
#SBATCH -t 2:0:0
#SBATCH -c 2
#SBATCH --mem=10G
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=e.kulaeva@prinsesmaximacentrum.nl

## Breast_1

### merge all PTATO-filtered vcfs

module load bcftools
module load R

cd ./3_Output/Breast_1/filtered_PTA/PTATO_PON/snvs/Breast/
bcftools merge -Oz PTA_WGS_0.2_PON_S8506Nr3/PTA_WGS_0.2_PON_S8506Nr3.snvs.ptato.filtered.vcf.gz PTA_WGS_0.2_PON_S8506Nr4/PTA_WGS_0.2_PON_S8506Nr4.snvs.ptato.filtered.vcf.gz PTA_WGS_0.2_PON_S8506Nr5/PTA_WGS_0.2_PON_S8506Nr5.snvs.ptato.filtered.vcf.gz PTA_WGS_0.2_PON_S8506Nr6/PTA_WGS_0.2_PON_S8506Nr6.snvs.ptato.filtered.vcf.gz > ./3_Output/Breast_1/filtered_PTA/downstream/PTATO_filtered.vcf.gz
bcftools merge -Oz PTA_WGS_0.2_PON_S8506Nr3.snvs.ptato.vcf.gz PTA_WGS_0.2_PON_S8506Nr4.snvs.ptato.vcf.gz PTA_WGS_0.2_PON_S8506Nr5.snvs.ptato.vcf.gz PTA_WGS_0.2_PON_S8506Nr6.snvs.ptato.vcf.gz >  ./3_Output/Breast_1/filtered_PTA/downstream/PTATO_flagged.vcf.gz

### filter out dbSNPs from the filtered file and subset initial multiVCF file by PTATO filtered variants

cd ./3_Output/Breast_1/filtered_PTA/downstream/

Rscript ../2_Code/dbSNP_remove_PTATO.R

tabix -p vcf PTATO_filtered.vcf.gz
tabix -p vcf PTATO_flagged.vcf.gz
bcftools isec -p CellPhy_intersect PTATO_filtered.vcf.gz PTATO_flagged.vcf.gz
bcftools view -R CellPhy_intersect/0002.vcf PTATO_flagged.vcf.gz -Oz -o cellphy.vcf.gz

tabix -p vcf biall_snps.vcf.gz
bcftools isec -p matrix_intersect PTATO_filtered.vcf.gz biall_snps.vcf.gz
bcftools view -R matrix_intersect/0002.vcf biall_snps.vcf.gz -Oz -o matrix.vcf.gz

###rename samples
bcftools reheader -s /hpc/pmc_vanboxtel/projects/_external_projects/vRheenen_LowInput/1_Input/rename_samples_PTA.txt -o cellphy_renamed.vcf.gz cellphy.vcf.gz
