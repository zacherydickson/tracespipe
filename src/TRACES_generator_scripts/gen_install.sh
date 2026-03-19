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
        sort -u | #If multiple tools come from the same package this prevents redundancy
        while read -r channel package; do
            echo "    conda install -c $channel \"$package\" --yes;"
        done
    echo "";
    yq -r '.[] | .call' "$DepFile" |
        while read -r call; do
            echo "    Program_installed \"$call\";"
        done;
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

source "$ExecDir/generate_common.sh"

GenerateTarget "$TargetFile"
