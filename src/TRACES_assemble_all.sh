#!/bin/bash
#
# ASSEMBLE

if [ "$#" -lt 8 ]; then
    >&2 echo "YourCall: $0 $*"
    >&2 echo -e "Usage: $(basename "$0") Organ nThread bResume memLimit o_fw_pr.fq o_rv_pr.fq o_fw_unpr.fq o_rv_unpr.fq\n";
    exit 1;
fi

Organ=$1; shift
nThread=$1; shift
BResume=$1; shift
memLimit=$1; shift
fq1p=$1; shift
fq2p=$1; shift
fq1u=$1; shift
fq2u=$1; shift
UnPairArg=""
[ -s "$fq1u" ] && UnPairArg="-s $fq1u"
[ -s "$fq2u" ] && UnPairArg="$UnPairArg -s $fq2u"
OutDir="../output_data/TRACES_denovo_$Organ"

#If we are not trying to resume, or the attempt to resume fails, run the assembly from scratch
if [ "$BResume" -eq 0 ] || ! spades.py --restart-from last -o "$OutDir"; then
    #Note the lack of quotation marks on the UnPair Arg is required
    spades.py --meta --threads "$nThread" --only-assembler -m "$memLimit" -o "$OutDir" -1 "$fq1p" -2 "$fq2p" $UnPairArg 
fi
