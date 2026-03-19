#!/bin/bash
#
# ==============================================================================
#
echo -e "\e[34m[TRACESPipe]\e[32m Extracting programs versions ... \e[0m";
#
#BEGIN AUTO-GENERATED SECTION - VersionCmds : DO NOT MODIFY
#==================================================
#This code snippet generated on Thu Mar 19 14:27:22 EET 2026,
# using src/TRACES_generator_scripts/gen_get_program_versions.sh
# based on information in system_files/dependencies.yml
#==================================================
printf "%-15s: %s\n" AdapterRemoval $(AdapterRemoval --version 2>&1 | awk '{ print $3 }')
printf "%-15s: %s\n" ART_illumina $(echo 2016.06.05)
printf "%-15s: %s\n" BBNorm $(bbnorm.sh --version 2>&1 | awk '/BBTools version/ { print $3 }')
printf "%-15s: %s\n" BFCtools $(bcftools --version | awk '(FNR == 1) { print $2 }')
printf "%-15s: %s\n" BEDOPS $(bedops --version | grep version | awk '{ print $2 }')
printf "%-15s: %s\n" BEDTools $(bedtools --version | awk '{ print $2 }')
printf "%-15s: %s\n" BLASTn $(blastn -version | awk '(FNR == 1) { print $2 }')
printf "%-15s: %s\n" Bowtie2 $(bowtie2 --version | awk '(FNR==1) { print $3 }')
printf "%-15s: %s\n" BWA $(bwa 2>&1 | awk '/Version/ { print $2 }')
printf "%-15s: %s\n" Cryfa $(cryfa 2>&1 | awk '/Cryfa v/ { print $2 }')
printf "%-15s: %s\n" dnadiff $(dnadiff --version 2>&1 | awk '/version/ { print $3 }')
printf "%-15s: %s\n" efetch $(efetch -version)
printf "%-15s: %s\n" FALCON $(FALCON -V 2>&1 | awk '/VERSION/ { print $2 }')
printf "%-15s: %s\n" fastp $(fastp --version 2>&1 | awk '{ print $2 }')
printf "%-15s: %s\n" grepq $(grepq --version | awk '{ print $2 }')
printf "%-15s: %s\n" GTO $(gto 2>&1 | awk '/GTO v/ { print substr($2,1,length($2)-1) }')
printf "%-15s: %s\n" IGV $(echo 2.19.3)
printf "%-15s: %s\n" iVar $(ivar version | awk '(FNR == 1) { print $3 }')
printf "%-15s: %s\n" MAGNET $(MAGNET --version 2>&1 | awk '/MAGNET/ { print $3 }')
printf "%-15s: %s\n" mapDamage2 $(mapDamage --version)
printf "%-15s: %s\n" SAMtools $(samtools --version | awk '(FNR == 1) { print $2 }')
printf "%-15s: %s\n" Sdust $(echo 0.1)
printf "%-15s: %s\n" SPAdes $(spades.py --version | awk '{ print substr($4,2) }')
printf "%-15s: %s\n" Tabix $(2>&1 tabix | awk '/Version:/ { print $2 }')
printf "%-15s: %s\n" Trimmomatic $(trimmomatic -version)
#==================================================
#END AUTO-GENERATED SECTION: DO NOT MODIFY
#
echo -e "\e[34m[TRACESPipe]\e[32m Done! \e[0m";
#
# ==============================================================================

