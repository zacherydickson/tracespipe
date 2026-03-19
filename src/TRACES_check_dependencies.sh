#!/bin/bash

PROGRAM_EXISTS () {
    tool=$1; shift
    call=$1; shift
    printf "Checking %s ... " "$tool";
    if ! [ -x "$(command -v "$call")" ]; then
      echo -e "\e[41mERROR\e[49m: $tool (called as $call) is not installed." >&2;
      echo -e "\e[42mTIP\e[49m: Try: ./TRACESPipe.sh --install" >&2;
    else
      echo -e "\e[42mSUCCESS!\e[49m";
    fi
}
#
#
install=$1; shift
[ -z "$install" ] && install=0;
[ "$install" -eq "1" ] && exit 0;
#BEGIN AUTO-GENERATED SECTION - CheckDepends : DO NOT MODIFY
#==================================================
#This code snippet generated on Thu Mar 19 15:29:55 EET 2026,
# using src/TRACES_generator_scripts/gen_check_dependencies.sh
# based on information in system_files/dependencies.yml
#==================================================
PROGRAM_EXISTS "AdapterRemoval" "AdapterRemoval"
PROGRAM_EXISTS "ART_illumina" "art_illumina"
PROGRAM_EXISTS "BBNorm" "bbnorm.sh"
PROGRAM_EXISTS "BFCtools" "bcftools"
PROGRAM_EXISTS "BEDOPS" "bedops"
PROGRAM_EXISTS "BEDTools" "bedtools"
PROGRAM_EXISTS "BLASTn" "blastn"
PROGRAM_EXISTS "Bowtie2" "bowtie2"
PROGRAM_EXISTS "BWA" "bwa"
PROGRAM_EXISTS "Cryfa" "cryfa"
PROGRAM_EXISTS "dnadiff" "dnadiff"
PROGRAM_EXISTS "efetch" "efetch"
PROGRAM_EXISTS "FALCON" "FALCON"
PROGRAM_EXISTS "fastp" "fastp"
PROGRAM_EXISTS "grepq" "grepq"
PROGRAM_EXISTS "GTO" "gto"
PROGRAM_EXISTS "IGV" "igv"
PROGRAM_EXISTS "iVar" "ivar"
PROGRAM_EXISTS "MAGNET" "MAGNET"
PROGRAM_EXISTS "mapDamage2" "mapDamage"
PROGRAM_EXISTS "SAMtools" "samtools"
PROGRAM_EXISTS "Sdust" "sdust"
PROGRAM_EXISTS "SPAdes" "spades.py"
PROGRAM_EXISTS "Tabix" "tabix"
PROGRAM_EXISTS "Trimmomatic" "trimmomatic"
#==================================================
#END AUTO-GENERATED SECTION - CheckDepends : DO NOT MODIFY
