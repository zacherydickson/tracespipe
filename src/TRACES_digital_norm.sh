#!/bin/bash

function ConstructOutPath {
    path=$1; shift
    echo "$(dirname "$pathath")/DN-$(basename "$path")"
}

function CreateLink {
    path=$1; shift
    ln -s "$(readlink "$path")" "$(ConstructOutPath "$path")";
}

#Taken from stackoverflow question 1527049
# Answer from user Nicholas Sushkin
function JoinBy {
	local d=${1-} f=${2-}
	if shift 2; then
		printf %s "$f" "${@/#/$d}"
	fi
}

if [ "$#" -lt 5 ]; then
    >&2 echo "Usage: $(basename "$0") maxMem memFactor PathTo/rawFwd.gz fwd.fq rev.fq unpaired1.fq ...";
    >&2 echo -e "\tFor the fwd and rev paths creates a file in the same directory with the prefix 'DN-'\n" \
                "\t\tThat file will be a link if no normalization occurs\n" \
                "\tunpaired reads are used for kmer hashing, but are not included in the output\n" \
                "\t\tNo new files or links will be generated for them\n";
    exit 1;
fi

maxMem=$1;shift
memFactor=$1;shift
rawFwdGZPath=$1;shift
fwdPath=$1;shift
revPath=$1;shift

bFilter=0;
#Check if digital normalization is required
if [[ "$maxMem" -gt 0 && "$memFactor" -gt 0 ]]; then
    bFilter=$(stat -Lc "%s*$memFactor > $maxMem*1024^3" "$rawFwdGZPath" | bc);
fi

if [ "$bFilter" -eq 1 ]; then
    #Attempt digital normalization
    if ! bbnorm.sh in="$fwdPath" in2="$revPath" extra="$(JoinBy "," "$@")" \
        out="$(ConstructOutPath "$fwdPath")" out2="$(ConstructOutPath "$revPath")"
    then
        bFilter=0;
        >&2 echo -e "\e[33mWARNING\e[0m: Digital Normalization Failed";
    fi;
fi

if [ "$bFilter" -eq 0 ]; then
    CreateLink "$fwdPath"
    CreateLink "$revPath"
fi
