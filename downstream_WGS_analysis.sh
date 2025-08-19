#!/bin/bash
#SBATCH -t 1:0:0
#SBATCH -c 2
#SBATCH --mem=50G

home_dir= $1
ASAP_ID=$2

### Breast_2 analysis (WGS only)
module load bcftools
module load R

