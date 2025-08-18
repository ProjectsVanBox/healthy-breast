rm(list=ls(all=TRUE))
options(stringsAsFactors = FALSE)

### Load libraries
library(UpSetR)
library(dplyr)
library(VariantAnnotation)
library(stringr)

vcf_file = './3_Output/Breast_1/filtered_PTA/downstream/final_filtered_0.2_biall.vcf.gz'
vcf_pon = 'HMF_PON_POSITION'

vcf <- readVcf(vcf_file)

vcf <- vcf[(!duplicated(rownames(vcf))), ]

pon <- readVcf(vcf_pon)

variants_to_exclude <- rownames(pon)

# Exclude variants from the VCF file based on the variant IDs from PON
vcf <- vcf[(!(rownames(vcf) %in% variants_to_exclude)), ]

writeVcf(vcf, file = "./3_Output/Breast_1/filtered_PTA/Breast_1/PTA_WGS_0.2_PON.vcf")
