#!/bin/bash

#This script autogenerates the conda install commands for TRACES_install.sh
# based on the dependencies in the dependencies.yml file
#It attempts to modify the target in place, with a backup which is either
#   deleted or restored depending on the success of the modification
#This script requires yq (a CLI YAML parser)

export ExecDir=$(dirname "$(readlink -f $0)")
export Stem="readme"
export DepFile=$(readlink -f "$ExecDir/../../system_files/dependencies.yml")
export TargetFile=$(readlink -f "$ExecDir/../../README.md")
export VersionFile=$(readlink -f "$ExecDir/../../Version.txt")


function GenerateTable {
    articleIcon="![Article](https://img.shields.io/static/v1.svg?label=View&message=Article&color=green)"
    doiBaseURL="https://doi.org"
    #Table Header
    echo "| Tool | TestedVersion | URL | Article |"
    echo "| --- | --- | --- | --- |";
    #Parse dependency yaml
    yq -r '.[] | .name + " " + .url + " " + .doi + " " + .versionCmd' "$DepFile" |
        while read -r tool url doi versionCmd; do
            #Get the installed version
            version="$(eval "$versionCmd" 2> "/dev/null")"
            [ -z "$version" ] && version="NA";
            [ "$doi" != "NA" ] && doi="[$articleIcon($doiBaseURL/$doi)]";
            #Handle underscores which are interpreted by markdown
            tool=${tool/_/\\_}
            tool="&#x1F49A;&nbsp; $tool"
            url="[$url]($url)"
            echo "| $tool | $version | $url | $doi |"
        done

}; export -f GenerateTable;

function GenerateHelp {
    echo -e " \`\`\`"
    cd "$ExecDir/.."
    #Call the help for TRACESPipe and strip out colour escape sequences
    ./TRACESPipe.sh --help | sed -e 's/\[[0-9;]*m//g'
    echo -e " \`\`\`"
}; export -f GenerateHelp;

function GenerateMetaData {
    local depDir=$(basename "$(dirname "$DepFile")")
    echo "<!-- This snippet generated on $(date), -->"
    echo "<!-- using src/$(basename "$ExecDir")/$(basename "$0") -->"
    echo "<!-- based on information in $depDir/$(basename $DepFile) -->"
    echo "<!-- ================================================== -->"
}; export -f GenerateMetaData;

function GenerateTableSnippet {
    echo "<!-- ================================================== -->"
    GenerateMetaData
    GenerateTable
    echo "<!-- ================================================== -->"
}; export -f GenerateTableSnippet;

function GenerateHelpSnippet {
    echo "<!-- ================================================== -->"
    GenerateMetaData
    GenerateHelp
    echo "<!-- ================================================== -->"
}; export -f GenerateHelpSnippet;

function GenerateVersionSnippet {
    echo "<!-- ================================================== -->"
    GenerateMetaData
    version=$(head -1 "$VersionFile");
    echo "[![Version](https://img.shields.io/static/v1.svg?label=Release&message=v${version}&color=orange)](#)"
    echo "<!-- ================================================== -->"
}

source "$ExecDir/generate_common.sh"

GenerateTarget "$TargetFile" "VersionShield" GenerateVersionSnippet
GenerateTarget "$TargetFile" "TracesHelp" GenerateHelpSnippet
GenerateTarget "$TargetFile" "DepInfoTable" GenerateTableSnippet
