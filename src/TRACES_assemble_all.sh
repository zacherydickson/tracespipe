#!/bin/bash
#
# $1 -> ORGAN NAME
# $2 -> NUMBER OF THREADS
#
# IT ASSUMES THAT THE FOLLOWING INPUT FILES EXIST:
# o_fw_pr.fq o_rv_pr.fq o_fw_unpr.fq o_rv_unpr.fq
#
# ASSEMBLE
Organ=$1; shift
nThread=$1; shift
fq1p="o_fw_pr.fq"
fq2p="o_rv_pr.fq"
fq1u="o_fw_unpr.fq"
fq2u="o_rv_unpr.fq"
UnPairArg=""
[ -s "$fq1u" ] && UnPairArg="-s $fq1u"
[ -s "$fq2u" ] && UnPairArg="$UnPairArg -s $fq2u"
spades.py --meta --threads "$nThread" --only-assembler -o "../output_data/TRACES_denovo_$Organ" -1 "$fq1p" -2 "$fq2p" "$UnPairArg" 
