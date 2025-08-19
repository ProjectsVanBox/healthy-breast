library(VariantAnnotation)
args <- commandArgs(trailingOnly = TRUE)

vcf<-readVcf(paste0(args[1],"/3_Output/Breast_2/filtered/downstream/matrix.vcf.gz"))
vcf <- vcf[(!duplicated(rownames(vcf))), ]
info <- info(vcf)
csq<-info$CSQ

impact_modifier_indices <- sapply(csq, function(csq_entry) {
  any(grepl("HIGH|MODIFIER|MODERATE", csq_entry))
})
vcf_impact_modifier <- vcf[impact_modifier_indices==TRUE, ]
vcf<-vcf_impact_modifier
sample_names <- colnames(vcf)
print(sample_names)
sample_to_keep <- setdiff(sample_names, "wgs_S11340Nr1")
vcf<-vcf[,sample_to_keep]

writeVcf(vcf,(paste0(args[1],"/3_Output/Breast_2/filtered/downstream/impact_vars.vcf.gz")))

seqnames <- seqnames(vcf)
start_positions <- start(vcf)-1
end_positions <- end(vcf)
ref_alleles <- ref(vcf)
alt_alleles <- unlist(alt(vcf))  # ALT might have multiple alleles

# Create a string in the format chr:start-end_REF/ALT 
annotations <- paste0(seqnames, ":", start_positions, "-", end_positions, "_", ref_alleles, "/", alt_alleles)

# Update row names of the VCF object
rows_old<-rownames(vcf)
rownames(vcf) <- annotations

ad <- geno(vcf)$AD

s<-ad[,1]
ads<-c()
for (j in c(1:804)){
  x<-paste0(s[[j]][2],"/",s[[j]][1]+s[[j]][2])
  ads<-c(ads,x)
}
ad_df<-data.frame(ads)
colnames(ad_df)<-colnames(vcf)[1]

for (i in c(2:6)){
  s<-ad[,i]
  ads<-c()
  for (j in c(1:804)){
    x<-paste0(s[[j]][2],"/",s[[j]][1]+s[[j]][2])
    ads<-c(ads,x)
  }
  y<-as.data.frame(ads)
  colnames(y)<-colnames(vcf)[i]
  ad_df<-cbind(ad_df,y)
}

rownames(ad_df)<-rownames(vcf)

csq <- info(vcf)$CSQ

impact_field <- sapply(csq, function(x) {
  csq_parts <- strsplit(x, ",")[[1]]
  impact_info <- sapply(csq_parts, function(csq_item) {
    fields <- strsplit(csq_item, "\\|")[[1]]
    impact <- fields[3]
    return(impact)
  })
  return(impact_info[1])  
})

gene_field <- sapply(csq, function(x) {
  # Split by ',' (for multiple transcripts) and then extract Impact field
  csq_parts <- strsplit(x, ",")[[1]]
  gene_info <- sapply(csq_parts, function(csq_item) {
    fields <- strsplit(csq_item, "\\|")[[1]]
    gene <- fields[4]  # The Impact field is usually the 4th in CSQ
    return(gene)
  })
  # Return the first Impact field for each variant (or handle multiple if needed)
  return(gene_info[1])  
})

genotype<-geno(vcf)$GT

data<-as.data.frame(cbind(as.character(gene_field),as.character(impact_field),ad_df))
colnames(data)[1:2]<-c("Gene name","Status")
rownames(data)<-rownames(vcf)
rows<-rownames(data)
data$vars <- gsub("_.*", "", rownames(data))
