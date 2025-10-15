#!/bin/bash
#
# $1 -> ORGAN NAME
# $2 -> NUMBER OF THREADS
#
# IT ASSUMES THAT THE FOLLOWING INPUT FILES EXIST:
# o_fw_pr.fq o_rv_pr.fq o_fw_unpr.fq o_rv_unpr.fq
#
# ASSEMBLE

if [ "$#" -lt 3 ]; then
    >&2 echo "YourCall: $0 $*"
    >&2 echo -e "Usage: $(basename "$0") Organ nThread bResume\n" \
                "\to_(fw|rv)_(un)?pr.fq must exists in the pwd\n";
    exit 1;
fi

Organ=$1; shift
nThread=$1; shift
BResume=$1; shift
fq1p="o_fw_pr.fq"
fq2p="o_rv_pr.fq"
fq1u="o_fw_unpr.fq"
fq2u="o_rv_unpr.fq"
UnPairArg=""
[ -s "$fq1u" ] && UnPairArg="-s $fq1u"
[ -s "$fq2u" ] && UnPairArg="$UnPairArg -s $fq2u"
OutDir="../output_data/TRACES_denovo_$Organ"

MemLimit=350

#If we are not trying to resume, or the attempt to resume fails, run the assembly from scratch
if [ "$BResume" -eq 0 ] || ! spades.py --restart-from last -o "$OutDir"; then
    #Note the lack of quotation marks on the UnPair Arg is required
    spades.py --meta --threads "$nThread" --only-assembler -m "$MemLimit" -o "$OutDir" -1 "$fq1p" -2 "$fq2p" $UnPairArg 
fi
