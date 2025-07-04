#!/bin/bash
# 
# ALIGNMENT OF READS
#
# IT REQUIRES THAT THE FOLLOWING FASTQ FILES EXIST In the currect diectory (FOR INPUT):
# o_fw_pr.fq o_rv_pr.fq o_fw_unpr.fq o_rv_unpr.fq
set -o pipefail

FullCall="$0 $*"
ScriptName="$(basename "$0")"

function Log {
    msg=$1; shift
    lvl=$2; shift
    [ -z "$lvl" ] && lvl="ERROR"
    >&2 echo -e "[$lvl] $msg\n\tCmd: $FullCall"
    return 0;
}

function Usage {
    >&2 echo -e "Usage: $ScriptName refType refFasta refLabel smplID nThread bRmDup bSensitive\n" \
                "\trefType {mt, cy, specific, viral}\tThe type of reference to which reads are to be mapped\n" \
                "\trefFasta PATH\tFasta file containing the reference genome; optionally gzipped\n" \
                "\trefLabel STR\tA label for the specific reference being used\n" \
                "\t\tViral abbreviation for viral, pattern for specific, mt for mt, and cy for cy\n" \
                "\tsmplID STR\tAn identifier for the reads\n" \
                "\tnThread [1,∞)\tThe number of threads to use\n" \
                "\tbRmDup {0,!0}\tBoolean indicator of whether mapping based deduplication should be performed\n" \
                "\tbSensitive {0,!0}\tBoolean indicator of whether highly sensitive mapping should be performed\n" \
        ;
    return 0;
}

### MAIN FUNCTION

function main {
    ValidateInput "$@" || { Usage; return 1; }
    refType=$1; shift
    refFasta=$1; shift
    refLabel=$1; shift
    smplID=$1; shift
    nThread=$1; shift
    bRmDup=$1; shift
    bSensitive=$1; shift
    ValidateFQ || return 1;

    #Count the number of molecules to be mapped
    libSize="$(bc <<< "$(cat o_fw_pr.fq o_*_unpr.fq | wc -l)/4")" ||
        Log "Failure to calculate library Size" "WARNING"
    #Build the Index
    indexPrefix="$(BuildIndex "$refFasta" "$refLabel" "$smplID")" || return 1;
    #Map the Reads
    samFile="$(Align "$indexPrefix" "$refLabel" "$smplID" "$nThread" "$bSensitive")" || return 1;
    #Count the number of molecules which actually mapped
    #Note: the samFile contains entries only for reads where at least one mate mapped (or unpaired and mapped)
    #      for paired reads that means both read1 and read2 have entries, one may be unmapped,
    #      only one needs to be counted
    nMapped="$(samtools view -c -F 0xF00 -e '!flag.read2' "$samFile")" ||
        Log "Failure to calculate nMapped" "WARNING"
    #Either just sort or deduplicate the reads as necessary, either path also creates the index file
    declare -A labelSuffixDict=(["cy"]="" ["mt"]="" ["specific"]="-$refLabel" ["viral"]="-$refLabel");
    labelSuffix="${labelSuffixDict["$refType"]}"
    bamFile="${refType}_aligned_sorted-${smplID}${labelSuffix}.bam"
    nDeduped="NA"
    if [ "$bRmDup" != "0" ]; then
        Deduplicate "$samFile" "$bamFile" "$nThread" || return 1;
        nDeduped="$(samtools view -c -F 0xF00 -e '!flag.read2' "$bamFile")" ||
            Log "Failure to calculate nDeduped" "WARNING"
    else
        samtools sort -@ "$nThread" -o "$bamFile" --write-index "$samFile" ||
            { Log "Failure to sort aligned output"; rm -f "$bamFile" "$bamFile.bai" "$bamFile.csi"; return 1; }
    fi
    #Clean up the intermediary sam file
    rm -f "$samFile"
    #Output Alignment flagstats and mapping stats
    OutputStats "$refType" "$refLabel" "$labelSuffix" "$smplID" "$bamFile" "$libSize" "$nMapped" "$nDeduped" ||
        return 1;
}

###FUNCTIONS

function Align {
    local index=$1; shift
    local refLabel=$1; shift
    local smplID=$1; shift
    local nThread=$1; shift
    local bSensitive=$1; shift

    local sensitivityArg=""
    if [[ "$bSensitive" != "0" ]]; then
        sensitivityArg="--very-sensitive"
    fi

    local samFile="aligned-$smplID-$refLabel.sam"
    #Map End-2-End with Bowtie and filter out molecules which did not map at all
    bowtie2 -a --threads "$nThread" "$sensitivityArg" -x "$index" \
        -1 o_fw_pr.fq -2 o_rv_pr.fq -U o_fw_unpr.fq,o_rv_unpr.fq |
        samtools view -h -e '(flag.paired && (!flag.unmap || !flag.munmap)) || (!flag.paired && !flag.unmap)' \
        >| "$samFile" ||
        { Log "Failure in Bowtie2 mapping or filtering out umapped molecules"; rm -f "$samFile" return 1; }

    echo "$samFile"
}

function BuildIndex {
    local refFasta=$1; shift
    local refLabel=$1; shift
    local smplID=$1; shift

    local idxName="index-$smplID-$refLabel-file"
    if ! bowtie2-build -q "$refFasta" "$idxName"; then
        Log "Failure to build bowtie2 index for ($refFasta)"
        rm -f "$idxName"*.bt2
        return 1;
    fi
    echo "$idxName"
}

function Deduplicate {
    local samFile=$1; shift
    local bamFile=$1; shift
    local nThread=$1; shift
    
    echo "Removing Duplications ..."
    #Sort by name so that fixmate can and MS and MC tags, then sort by coordinates again,
    # then have markdup remove the duplicate reads
    # the -S option makes in also remove supplement-/second-ary alignments of duplicates
    # as well as unmapped mates of duplicates
    samtools sort --threads "$nThread" -n "$samFile" |
        samtools fixmate --threads "$nThread" -m - - |
        samtools sort --threads "$nThread" - |
        samtools markdup --threads "$nThread" -r -S --write-index - "$bamFile" ||
        { Log "Failure to deduplicate aligned reads"; rm -f "$bamFile" "$bamFile.bai" "$bamFile.csi"; return 1; }
}

function OutputStats {
	local refType=$1; shift
	local refLabel=$1; shift
    local labelSuffix=$1; shift
	local smplID=$1; shift
	local bamFile=$1; shift
	local libSize=$1; shift
	local nMapped=$1; shift
	local nDeduped=$1; shift

    declare -A statsDirInfix=(["cy"]="cy" ["mt"]="mtdna" ["specific"]="specific" ["viral"]="viral")
    local statsDir="../output_data/TRACES_${statsDirInfix["$refType"]}_statistics"
    mkdir -p "$statsDir" ||
        { Log "Failure to create statistics directory" "WARNING"; return 0; }
    #Output the flagstats
    local label=$refType-${smplID}${labelSuffix};
    local flagStatFile="$statsDir/Alignment-$label.txt"
    samtools flagstat "$bamFile" >| "$flagStatFile" ||
        { Log "Failure to calculate flagstats" "WARNING"; rm -f "$flagStatFile"; }

    #Calculate and Output the mapping statistics
    local mapStatFile="$statsDir/Mapping-$label.txt"
    local acc="NA";
    acc=$(samtools view -H "$bamFile" | awk -F '\\t|:' '/^@SQ/ {print $3; exit 0}') ||
        Log "Failure to determine reference accession for mapping stats"
    local mapPerc="NA";
    mapPerc="$(bc <<< "scale=4;100*$nMapped/$libSize")" ||
        Log "Failure to calculate mapping percentage for mapping stats"
    local dupRate="NA"
    if [ "$nDeduped" != "NA" ]; then 
        dupRate="$(printf "%0.3f%%" "$(bc <<< "scale=3;100*(1-$nDeduped/$nMapped)")")" ||
            Log "Failure to calculate duplication rate for mapping stats";
    fi
    printf "%s\t%s\t%d\t%d\t%0.3f\t%s\t%s" \
        "$acc" "$smplID" "$libSize" "$nMapped" "$mapPerc" "$nDeduped" "$dupRate" >| \
        "$mapStatFile" ||
        { Log "Failure to output mapping stats"; rm -f "$mapStatFile"; }
}

function ValidateFQ {
     if [ -s o_fw_pr.fq ] && [ -s o_rv_pr.fq ] && [ -s o_fw_unpr.fq ] && [ -s o_rv_unpr.fq ]; then
         return 0;
     fi
     Log "Could not find o_fw_pr.fq, o_rv_pr.fq, o_fw_unpr.fq, and o_rv_unpr.fq in current directory"
    return 1;
}

function ValidateInput {
    [ "$#" -lt 7 ] && 
        { Log "Insufficient Command Line Arguments";  return 1; }
    local refType=$1; shift
    local refFasta=$1; shift
    local refLabel=$1; shift
    local smplID=$1; shift
    local nThread=$1; shift
    local bRmDup=$1; shift
    local bSensitive=$1; shift
    #Ensure all variables are non-empty
    declare -A varDict=(["refType"]="$refType" ["refFasta"]="$refFasta" \
                        ["refLabel"]="$refLabel" ["smplID"]="$smplID" \
                        ["nThread"]="$nThread" ["bRmDup"]="$bRmDup" \
                        ["bSensitive"]="$bSensitive");
    for var in "${!varDict[@]}"; do
        if [ -z "${varDict[$var]}" ]; then
            Log "Empty $var provided"
            return 1;
        fi
    done
    #Ensure the ref Type is valid
    declare -A validTypeSet=(["cy"]=1 ["mt"]=1 ["specific"]=1 ["viral"]=1);
    if ! [[ -v validTypeSet["$refType"] ]]; then
        Log "Unrecognized refType ($refType)"
        return 1;
    fi
    #Ensure the ref fasta, exists, is non-empty
    if ! [ -s "$refFasta" ]; then
        Log "Empty or non-existent fasta reference ($refFasta)"
        return 1;
    fi
    #Ensure that the refLabel is correct if a particular label is required
    declare -A reqLabelSet=(["cy"]="cy" ["mt"]="mt")
    if [[ -v reqLabelSet["$refType"] ]] && [ "$refLabel" != "${reqLabelSet["$refType"]}" ]; then
        Log "refLabel ($refLabel) does not match required label for $refType (${reqLabelSet["$refType"]})"
        return 1;
    fi
}

### RUN THE PROGRAM

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@";
fi
