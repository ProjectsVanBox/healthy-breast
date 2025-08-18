library(VariantAnnotation)
library(dplyr)
library(biomaRt)
library(stringr)
library(ggplot2)
library(data.table)

vcf<-readVcf("~/hpc/pmc_vanboxtel/projects/_external_projects/vRheenen_LowInput/3_Output/filtered_PTA/downstream/matrix.vcf.gz")
info <- info(vcf)
csq<-info$ANN
impact_modifier_indices <- sapply(csq, function(csq_entry) {
  any(grepl("HIGH|MODIFIER|MODERATE", csq_entry))
})
vcf_impact_modifier <- vcf[impact_modifier_indices==TRUE, ]
vcf<-vcf_impact_modifier

writeVcf(vcf,"~/hpc/pmc_vanboxtel/projects/_external_projects/vRheenen_LowInput/3_Output/filtered_PTA/downstream/impact_vars.vcf.gz")

seqnames <- seqnames(vcf)
start_positions <- start(vcf)-1
end_positions <- end(vcf)
ref_alleles <- ref(vcf)
alt_alleles <- unlist(alt(vcf))

# Create a string in the format chr:start-end_REF/ALT 
annotations <- paste0(seqnames, ":", start_positions, "-", end_positions, "_", ref_alleles, "/", alt_alleles)

# Update row names of the VCF object
rows_old<-rownames(vcf)
rownames(vcf) <- annotations
ad <- geno(vcf)$AD

s<-ad[,1]
ads<-c()
for (j in c(1:341)){
  x<-paste0(s[[j]][2],"/",s[[j]][1]+s[[j]][2])
  ads<-c(ads,x)
}
ad_df<-data.frame(ads)
colnames(ad_df)<-colnames(vcf)[1]

for (i in c(2:6)){
  s<-ad[,i]
  ads<-c()
  for (j in c(1:341)){
    x<-paste0(s[[j]][2],"/",s[[j]][1]+s[[j]][2])
    ads<-c(ads,x)
  }
  y<-as.data.frame(ads)
  colnames(y)<-colnames(vcf)[i]
  ad_df<-cbind(ad_df,y)
}

rownames(ad_df)<-rownames(vcf)

csq <- info(vcf)$ANN

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
colnames(genotype)<-paste0("gt_",colnames(genotype))
data<-as.data.frame(cbind(as.character(gene_field),as.character(impact_field),ad_df,genotype))
colnames(data)[1:2]<-c("Gene name","Status")
rownames(data)<-rownames(vcf)
rows<-rownames(data)
data$vars <- gsub("_.*", "", rownames(data))

### add COSMIC IDs

cosmic <-fread("~/hpc/pmc_vanboxtel/projects/_external_projects/vRheenen_LowInput/1_Input/COSMIC_data.csv", skip = 1)
colnames(cosmic)<-c("chrom","chromStart","chromEnd","name","score","strand","refAllele","altAllele","cosmicLegIden")
cosmic$chrom <- gsub("^chr", "", cosmic$chrom)
cosmic$annot <- paste0(cosmic$chrom, ":", cosmic$chromStart, "-", cosmic$chromEnd, "_", cosmic$refAllele, "/", cosmic$altAllele)
data$COSMIC<-ifelse(rownames(data) %in% cosmic$annot, cosmic$name, NA)
IDs<-as.data.frame(na.omit(data$COSMIC))
write.table(IDs,"~/hpc/pmc_vanboxtel/projects/_external_projects/vRheenen_LowInput/3_Output/filtered_PTA/downstream/COSMIC_IDs.txt",
            row.names = F,col.names = F,quote = F)

### bash

# head -n 1 /hpc/pmc_vanboxtel/projects/silent-mutations/CancerMutationCensus_AllData_v100_GRCh37.tsv > subsetted_db_COSMIC.txt #it contains hg38 as well
# grep -Ff COSMIC_IDs.txt /hpc/pmc_vanboxtel/projects/silent-mutations/CancerMutationCensus_AllData_v100_GRCh37.tsv >> subsetted_db_COSMIC.txt

mut_COSM<-read.delim("~/hpc/pmc_vanboxtel/projects/_external_projects/vRheenen_LowInput/3_Output/filtered_PTA/downstream/subsetted_db_COSMIC.txt",header = T)
mut_COSM<-as.data.frame(cbind(mut_COSM$GENOMIC_MUTATION_ID,mut_COSM$Mutation.AA,mut_COSM$Mutation.Description.AA))

colnames(mut_COSM)<-c("COSMIC","AA change","AA change description") # No IDs found
data<-data[,(1:14)]

write.table(data,"~/hpc/pmc_vanboxtel/projects/_external_projects/vRheenen_LowInput/3_Output/filtered_PTA/downstream/matrix_mutations_PTA.txt")

plot_data<-as.data.frame(cbind(ifelse(data$COSMIC %in% mut_COSM$COSMIC,"COSMIC ID present","No COSMIC ID"),
                               data$Status,data$`AA change description`))

colnames(plot_data)<-c("ID","Impact","Type")

data_summary <- plot_data %>%
  group_by(ID, Impact, Type) %>%
  summarise(Count = n()) %>%
  group_by(ID) %>%
  mutate(Proportion = Count / sum(Count))

data_summary$Type[4:6]<-"None"

library(ggplot2)

# Plot stacked bar plot with proportions

ggplot(data_summary, aes(x = ID, y = Proportion, fill = interaction(Impact, Type))) +
  geom_bar(stat = "identity", position = "fill") +  # "fill" stacks bars to 100%
  labs(title = "Annotated mutations distribution, proportions",
       x = "ID",
       y = "Proportion") +
  theme_minimal() +
  scale_y_continuous(labels = scales::percent) +  # Convert y-axis to percentages
  guides(fill = guide_legend(title = "Impact & Type"))

ggplot(data_summary, aes(x = ID, y = Count, fill = interaction(Impact, Type))) +
  geom_bar(stat = "identity", position = "stack") +  # "fill" stacks bars to 100%
  labs(title = "Annotated mutations distribution, absolute number",
       x = "ID",
       y = "Count") +
  theme_minimal() +
  guides(fill = guide_legend(title = "Impact & Type"))

data_cosmic_present<-data_summary[data_summary$ID=="COSMIC ID present", ]

ggplot(data_cosmic_present, aes(x = Impact, y = Count, fill = Type))+
  geom_bar(stat = "identity", position = "stack")+
  labs(title = "COSMIC-annotated mutations distribution, absolute")+
  theme_linedraw()
