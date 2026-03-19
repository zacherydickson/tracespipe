#!/bin/bash

PROGRAM_EXISTS () {
    prog=$1; shift
    printf "Checking %s ... " "$prog";
    if ! [ -x "$(command -v "$prog")" ]; then
      echo -e "\e[41mERROR\e[49m: $prog is not installed." >&2;
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
PROGRAM_EXISTS "trimmomatic";
PROGRAM_EXISTS "cryfa";
PROGRAM_EXISTS "MAGNET";
PROGRAM_EXISTS "FALCON";
PROGRAM_EXISTS "gto";
PROGRAM_EXISTS "spades.py";
PROGRAM_EXISTS "igv";
PROGRAM_EXISTS "bowtie2";
PROGRAM_EXISTS "samtools";
PROGRAM_EXISTS "bcftools";
PROGRAM_EXISTS "bedops";
PROGRAM_EXISTS "bedtools";
PROGRAM_EXISTS "efetch";
PROGRAM_EXISTS "mapDamage";
PROGRAM_EXISTS "tabix";
PROGRAM_EXISTS "AdapterRemoval";
PROGRAM_EXISTS "bwa";
PROGRAM_EXISTS "art_illumina";
PROGRAM_EXISTS "blastn";
PROGRAM_EXISTS "dnadiff";
PROGRAM_EXISTS "fastp"
PROGRAM_EXISTS "grepq"
PROGRAM_EXISTS "bbnorm.sh"
PROGRAM_EXISTS "sdust"

