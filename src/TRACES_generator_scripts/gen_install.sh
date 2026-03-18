#!/bin/bash

#This script autogenerates the conda install commands for TRACES_install.sh
# based on the dependencies in the dependencies.yml file
#It attempts to modify the target in place, with a backup which is either
#   deleted or restored depending on the success of the modification
#This script requires yq (a CLI YAML parser)

export ExecDir=$(dirname "$(readlink -f $0)")
export Stem="install"
export DepFile=$(readlink -f "$ExecDir/../../system_files/dependencies.yml")
export TargetFile=$(readlink -f "$ExecDir/../TRACES_${Stem}.sh")

function GenerateCode {
    yq -r '.[].conda | .channel + " " + .package' "$DepFile" |
        while read -r channel package; do
            echo "    conda install -c $channel \"$package\" --yes;"
        done
    echo "";
    yq -r '.[] | .call' "$DepFile" |
        while read -r call; do
            echo "    Program_installed \"$call\";"
        done;
}

function GenerateMetaData {
    local depDir=$(basename "$(dirname "$DepFile")")
    echo "#This code snippet generated on $(date),"
    echo "# using src/$(basename "$ExecDir")/$(basename "$0")"
    echo "# based on information in $depDir/$(basename $DepFile)"
    echo "#=================================================="
}

function GenerateSnippet {
    echo "#=================================================="
    GenerateMetaData
    GenerateCode
    echo "#=================================================="
}

export -f GenerateCode;
export -f GenerateMetaData;
export -f GenerateSnippet;


function AttemptGeneration {
    awk -i inplace -v inplace::suffix=.bak '
        BEGIN{
            maxInsert = 1;
            inSnippet = 0;
        }
        (ARGIND == 2){
            snippet[++nLine] = $0;
            next;
        }
        /^#BEGIN AUTO-GENERATED SECTION/ {print; inSnippet=1; next}
        /^#END AUTO-GENERATED SECTION/ {
            if(maxInsert--){
                for(i=1;i<=nLine;i++){
                    print snippet[i]
                }
            }
            inSnippet=0;
            print;
            next;
        }
        (inSnippet){next}
        1
    ' inplace::enable=0 <(GenerateSnippet) inplace::enable=1 "$TargetFile"
}

if AttemptGeneration; then
    rm -f "$TargetFile.bak"
else
    mv "$TargetFile.bak" "$TargetFile"
    >&2 echo "[ERROR] Failure to generate $TargetFile"
    exit 1;
fi

