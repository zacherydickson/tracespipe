#!/bin/bash
#
# IT ASSUMES THAT THE FOLLOWING OUTPUT FILES EXIST:
# MT-o_fw_pr.fq MT-o_rv_pr.fq MT-o_fw_unpr.fq MT-o_rv_unpr.fq
#
# ASSEMBLE

Label=$1; shift
NThread=$1; shift
BResume=$1; shift

workDir="out_spades_$Label"

MemLimit=350;

#If not attempting to resume, or the attempt to resume fails run the asembly from scratch
if [ "$BResume" -eq 0 ] || ! spades.py --restart-from last -t "$NThread" -o "$workDir"; then 
    spades.py -t "$NThread" --careful -m "$MemLimit" -o "$workDir" -1 MT-o_fw_pr.fq -2 MT-o_rv_pr.fq -s MT-o_fw_unpr.fq -s MT-o_rv_unpr.fq
fi

#
