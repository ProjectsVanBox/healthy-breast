### Load libraries
BiocManager::install("VariantAnnotation")
library(VariantAnnotation)

### pass home_dif
args <- commandArgs(trailingOnly = TRUE)

vcf_file = paste0(args[1],"/3_Output/Breast_1/filtered_PTA/downstream/final_filtered_0.2_biall.vcf.gz")
vcf_pon = c("HMF_PON_LOCATION")

vcf <- readVcf(vcf_file)

vcf <- vcf[(!duplicated(rownames(vcf))), ]

pon <- readVcf(vcf_pon)

variants_to_exclude <- rownames(pon)

# Exclude variants from the VCF file based on the variant IDs from PON
vcf <- vcf[(!(rownames(vcf) %in% variants_to_exclude)), ]

writeVcf(vcf, file = paste0(args[1],"/3_Output/Breast_1/filtered_PTA/Breast_1/PTA_WGS_0.2_PON.vcf")
