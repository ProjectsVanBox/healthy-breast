#!/bin/bash

#SBATCH --time=24:0:0
#SBATCH --mem=30G 

echo "Start CallableLoci        " `date` "      " `uname -n`

module load Java/1.8.0_60

BAM=$1
NAME=$(basename $BAM)
BED=${NAME/.bam/_CallableLoci.bed}
TXT=${NAME/.bam/_CallableLoci.txt}
TMP=${NAME/.bam/_tmp}

java -Djava.io.tmpdir=${TMP} \
-Xmx30G -jar /hpc/local/CentOS7/pmc_vanboxtel/bin/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T CallableLoci \
-R /hpc/pmc_vanboxtel/resources/homo_sapiens.GRCh38.GATK.illumina/Homo_sapiens_assembly38.fasta \
-I ${BAM} \
-o ${BED} \
-summary ${TXT} \
--minBaseQuality 10 --minMappingQuality 10 --minDepth 8 --minDepthForLowMAPQ 10 

echo "Finished CallableLoci     " `date` "      " `uname -n`
