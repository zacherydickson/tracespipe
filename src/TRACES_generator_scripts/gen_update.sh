#!/bin/bash


#This script autogenerates the conda update commands for TRACES_update.sh
# based on the dependencies in the dependencies.yml file
#It attempts to modify the target in place, with a backup which is either
#   deleted or restored depending on the success of the modification
#This script requires yq (a CLI YAML parser)

export ExecDir=$(dirname "$(readlink -f $0)")
export Stem="update"
export DepFile=$(readlink -f "$ExecDir/../../system_files/dependencies.yml")
export TargetFile=$(readlink -f "$ExecDir/../TRACES_${Stem}.sh")
export SectionLabel="UpdateCmds"

function GenerateCode {
    yq -r '.[].conda | .channel + " " + .package' "$DepFile" |
        sort -u | #If multiple tools come from the same package this prevents redundancy
        while read -r channel package; do
            echo "    conda update -c $channel \"$package\" --yes;"
        done

}; export -f GenerateCode;

function GenerateMetaData {
    local depDir=$(basename "$(dirname "$DepFile")")
    echo "#This code snippet generated on $(date),"
    echo "# using src/$(basename "$ExecDir")/$(basename "$0")"
    echo "# based on information in $depDir/$(basename $DepFile)"
    echo "#=================================================="
}; export -f GenerateMetaData;

function GenerateSnippet {
    echo "#=================================================="
    GenerateMetaData
    GenerateCode
    echo "#=================================================="
}; export -f GenerateSnippet;


#Loads the functions for actually instering a code snippet:
#   GenerateTarget (and its dependencies)
source "$ExecDir/generate_common.sh"

GenerateTarget "$TargetFile" "$SectionLabel" GenerateSnippet
