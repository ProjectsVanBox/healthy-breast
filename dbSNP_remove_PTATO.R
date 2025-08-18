args <- commandArgs(trailingOnly = TRUE)

### Load libraries
library(VariantAnnotation)

vcf_file = pasteo(args[1],"/3_Output/Breast_1/filtered_PTA/downstream/PTATO_filtered.vcf.gz")

## Read file

vcf <- readVcf(vcf_file)

# Remove duplicates

vcf <- vcf[(!duplicated(rownames(vcf))), ]

# remove dbSNPs
dbsnp<-str_subset(rownames(vcf), "rs", negate = FALSE)
vcf <- vcf[(!(rownames(vcf) %in% dbsnp)), ]

writeVcf(vcf, file = paste0(agrs[1],"/3_Output/Breast_1/filtered_PTA/downstream/PTATO_filtered_dbSNP.vcf")
