# healthy-breast
Scripts for collaborative project with Jacco van Rheenen's team, NKI

Requirenments: R >= 4.3.0, GATK 3.8 (for callable loci analysis) + Java 1.8.0_60, tabix, bcftools, bedtools

!NB Unpack the dbGAP BAM files archive into the created directory ./1_Input (it should display Breast_1 and Breast_2 directories); unpack the githib code to ./2_Code

For the WGS + PTA data (Breast_1):

1. Run callable_loci_PTA_estimate.sh (here and below always specify the home_dir argument by passing the absolute path to the whole folder of this repository to sbatch after the script name (no specific name, encoded as $1); check the script(s) for more information)
2. Run callable_loci_PTA_overlap.sh
3. Run NF-IAP from the corresponding repository: https://github.com/ToolsVanBox/NF-IAP starting with BAM files from dbGAP and store the results in /home_dir/3_Output/Breast1/NF-IAP
4. Run downstream_PTA_analysis.sh (pass the NF-IAP VCF name to the script in addition to home_dir (treat is as $2)). 

!NB - replace the dummy panel of normals (PON) HMF location file to the actual full path of this file (to obtain PON HMF file, see ***)

5. Run PTATO from the corresponding repository: https://github.com/ToolsVanBox/PTATO and VCF file from /home_dir/3_Output/filtered_PTA/PTATO_PON
   When running PTATO, specify the output directory as /home_dir/3_Output/filtered_PTA/PTATO_PON and bulk_names parameter as:
   bulk_names = [
    ['Breast_1', 'S8506Nr1'],
    ['Breast_2', 'S8506Nr2'],
   
6. Run subset_by_PTATO_output_analysis.sh
7. Run mutmat_PTA.R
