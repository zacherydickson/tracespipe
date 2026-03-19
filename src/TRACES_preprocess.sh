#!/bin/bash

function main {
    if [ "$#" -lt 6 ]; then
        >&2 echo "Usage: $(basename $0) threads outDir adapterFile prefix 1.fq 2.fq [bDedup = 0]";
        exit 1;
    fi
    nThread=$1; shift
    outDir=$1; shift
    adapterFile=$1; shift
    prefix=$1; shift
    in1=$1; shift
    in2=$1; shift
    bDedup=$1; shift
    [ -z "$bDedup" ] && bDedup=0;
    dedupArg="--dont_eval_duplication"
    [ "$bDedup" != "0" ] && dedupArg="--dedup"

    mkdir -p "$outDir" || return 1;

    fastp --in1 "$in1" --in2 "$in2" --out1 "$outDir/${prefix}_1P.fq.gz" --out2 "$outDir/${prefix}_2P.fq.gz" \
        --unpaired1 "$outDir/${prefix}_1U.fq.gz" --unpaired2 "$outDir/${prefix}_2U.fq.gz" \
        --adapter_fasta "$adapterFile" "$dedupArg" --trim_poly_g \
        --cut_front --cut_front_window_size 1 --cut_front_mean_quality 3 \
        --cut_tail --cut_tail_window_size 1 --cut_tail_mean_quality 3 \
        --cut_right --cut_right_window_size 4 --cut_right_mean_quality 15 \
        --disable_quality_filtering --length_required 25 --correction \
        --json "$outDir/${prefix}.json" --html "$outDir/${prefix}.html" --report_title "$prefix" \
        --thread "$nThread" 2> "$outDir/${prefix}.log" || return 1;

}

if [ ${BASH_SOURCE[0]} == ${0} ]; then
    main "$@"
fi
