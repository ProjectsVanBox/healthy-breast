# healthy-breast
Scripts for collaborative project with Jacco van Rheenen's team, NKI

Requirenments: R >= 4.3.0, GATK 3.8 (for callable_loci_analysis.sh) PTATO , ASAP->SMuRF-derived vcfs.

For the WGS + PTA data (data batch 1):

1. Run callable_loci_analysis.sh
2. Run NF-IAP using BAM files from the corresponding repository: https://github.com/ToolsVanBox/NF-IAP
3. Run downstream_PTA_analysis.sh
4. Run PTATO from the folder PTATO_scripts
5. Run batch_PTA+WGS_analysis.sh
6. Run mutmatWGS_PTA.R in RStudio (pay attention to the bash commands included in the script);


For the WGS data only (data batch 2):

1. Run batch_WGS_analysis.sh;
2. Run DriversAnalysis.sh;
3. Run mutmatWGS.R in RStudio (pay attention to the bash commands included in the script);
