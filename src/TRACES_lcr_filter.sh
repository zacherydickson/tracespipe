#!/bin/bash

if [ "$#" -lt 1 ]; then
    >&2 echo "Usage: $(basename "$0") seqs.fna > maskedSeqs.fna";
    exit 1;
fi

#Use sdust to identify low complexity regions in the provided DNA sequences
#This creates a bed file which bedtools can use to hardmask (replace with N's)
#the lcr regions. Note: falcon ignores non-canonical bases
function main {
    local fastaIn=$1; shift;
    #There is a bug in sdust which can cause it to report intervals outside of sequences
    # if there are N's in the sequences
    #As a workaround we will take the intersect with actual genomic intervals 
    samtools faidx "$fastaIn"
    sdust "$fastaIn" |
        bedtools intersect -a /dev/stdin -b <(awk '{print $1"\t0\t"$2}' "$fastaIn.fai") |
        bedtools maskfasta -fi "$fastaIn" -bed /dev/stdin \
        -fo /dev/stdout -fullHeader
    rm -f samtools "$fastaIn.fai"
}

#Actually run the script
main "$@";
