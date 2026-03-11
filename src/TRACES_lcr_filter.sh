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
    sdust "$fastaIn" | bedtools maskfasta -fi "$fastaIn" -bed /dev/stdin \
        -fo /dev/stdout -fullHeader
}

#Actually run the script
main "$@";
