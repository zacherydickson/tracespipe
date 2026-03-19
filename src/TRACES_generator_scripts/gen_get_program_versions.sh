#!/bin/bash

#This script autogenerates the display version commands for TRACES_get_program_versions.sh
# based on the dependencies in the dependencies.yml file
#It attempts to modify the target in place, with a backup which is either
#   deleted or restored depending on the success of the modification
#This script requires yq (a CLI YAML parser)

export ExecDir=$(dirname "$(readlink -f $0)")
export Stem="get_program_versions"
export DepFile=$(readlink -f "$ExecDir/../../system_files/dependencies.yml")
export TargetFile=$(readlink -f "$ExecDir/../TRACES_${Stem}.sh")
export SectionLabel="VersionCmds"

function GenerateCode {
    yq -r '.[] | .name + " " + .versionCmd' system_files/dependencies.yml |
        while read -r name cmd; do
            echo printf \"%-15s: %s\\n\" "$name" "\$($cmd)";
        done
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

source "$ExecDir/generate_common.sh"

GenerateTarget "$TargetFile" "$SectionLabel"
