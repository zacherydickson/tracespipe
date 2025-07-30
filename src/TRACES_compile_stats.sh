#!/bin/bash

ValidTypes=("viral" "specific" "mtdna" "cy");
ViralNamesFile="viral_names.txt"
MetaFile="../meta_data/meta_info.txt"
ResultsDir="../output_data/TRACES_results"
SpecAlnDir="../output_data/TRACES_specific_alignments"

#Assumes existence of Mapping files, Breadth and Depth statistics files, and Top files
#Creates Files in the TRACES_results directory

function main {
    if [ "$#" -lt 1 ]; then
        >&2 echo -e "Usage: $(basename "$0") StatType1 ... \n" \
            "Each stat type must be one of: all ${ValidTypes[*]}\n" \
            "Only unique stat types will be used\n" \
            ;
        exit 1;
    fi
    #Determine the unique set of types for which to compile stats 
    declare -A typeSet;
    for statType in "$@"; do
        for validType in "${ValidTypes[@]}"; do
            if [ "$statType" == "all" ]; then
                typeSet["$statType"]=1;
            elif [ "$statType" == "$validType" ]; then
                typeSet["$statType"]=1;
                continue;
            fi
        done
        #Check if the statType exists in the typeSet, if not that means no matching Valid Type was found
        if [ "$statType" != "all" ] && ! [[ -v typeSet["$statType"] ]]; then
            >&2 echo -e "[WARNING] ($(basename "$0")) Unrecognized StatType ($statType) - skipping"
        fi
    done
    #If no recognized stats types were provided we're done
    if [ "${#typeSet[@]}" -eq 0 ]; then
        >&2 echo "[ERROR] ($(basename "$0")) No recognized stat types to compile"
        exit 1;
    fi
    #Prepare the results dir
    mkdir -p "$ResultsDir"
    #Compile the stats for each stat type
    for statType in "${!typeSet[@]}"; do
        case "$statType" in 
            viral)
                readarray -t virusList < "$ViralNamesFile" 
                CompileStats "$statType" "viral" "${virusList[@]}"
            ;;
            specific)
                #Find the specific references used then strip and pass only the labes to Complle
                readarray -t specificList < <(find "$SpecAlnDir" -name "SPECIFIC-*.fa" -exec basename {} ".fa" \;)
                CompileStats "$statType" "specific" "${specificList[@]#SPECIFIC-}"
            ;;
            mtdna)
                CompileStats "$statType" "mt" "mt"
            ;;
            cy)
                CompileStats "$statType" "cy" "cy"
            ;;
        esac
    done
}

function CompileStats {
    local statType="$1"; shift
    local refType="$1"; shift
    local outFile="$ResultsDir/Compiled_${statType}_stats_all_samples.tsv"
    echo -e "ReferenceType\tSample\tReferenceID\tDepth\tBreadth\tSimilarity\tMappedReads\tProportionMapped\tDedupedReads\tDuplicationRate" >| "$outFile"
    #Iterate over provided reference labels
    for refLabel in "$@"; do
        if [ -z "$refLabel" ]; then
            continue;
        fi
        while IFS=":" read -r sID fq1 fq2; do
            #Acquire the mapping stats
            local v="-"; local s="-";
            local gid="-"; local lS="-"; local nM="-"; local pM="-"; local nD="-"; local pD="-";
            local targetFile="../output_data/TRACES_${statType}_statistics/Mapping-$refType-$sID-$refLabel.txt"
            if [ -f "$targetFile" ]; then
                read -r v gid s lS nM pM nD pD < "$targetFile";
            fi
            #Acquire the depth stats
            local depth="-";
            targetFile="../output_data/TRACES_${statType}_statistics/$refLabel-total-depth-coverage-$sID.txt"
            if [ -f "$targetFile" ]; then
                depth=$(head -1 "$targetFile" | cut -f3)
            fi
            #Acquire the breadth stats
            local breadth="-";
            targetFile="../output_data/TRACES_${statType}_statistics/$refLabel-total-horizontal-coverage-$sID.txt"
            if [ -f "$targetFile" ]; then
                breadth=$(head -1 "$targetFile" | cut -f3)
            fi
            #Acquire the similarity stats
            local sim="-";
            targetFile="../output_data/TRACES_results/top-$sID.csv"
            if [ "$gid" != "-" ] && [ -f "$targetFile" ]; then
                sim=$(grep "$gid" "$targetFile" | head -1 | cut -f3)
            fi
            #Print the results line
            c1="$refLabel"
            if [ "$statType" == "specific" ]; then
                c1="specific";
                [ "$gid" == "-" ] && gid="$refLabel";
            fi
            echo -e "$c1\t$sID\t$gid\t$depth\t$breadth\t$sim\t$nM\t$pM\t$nD\t$pD";
        done < "$MetaFile"
    done >> "$outFile";
}

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
