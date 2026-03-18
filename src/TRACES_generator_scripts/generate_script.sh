#!/bin/bash

#This script autogenerates the conda install commands for:
#   TRACES_install.sh
#   TRACES_update.sh
#   TRACES_get_program_versions.sh
# based on the dependencies in the dependencies.yml file
#It attempts to modify the target in place, with a backup which is either
#   deleted or restored depending on the success of the modification
#This script requires yq (a CLI YAML parser)


export ExecDir=$(dirname "$(readlink -f $0)")
export DepFile=$(readlink -f "$ExecDir/../../system_files/dependencies.yml")
declare -A ValidStems=;
ValidStems["install"]=1;
ValidStems["update"]=1;
ValidStems["get_program_versions"]=1;

#!/bin/bash

function main {
    #Get args from command line
    if [ "$#" -lt 1 ]; then
        >&2 echo "Usage: $(basename "$0") stem";
        exit 1;
    fi

    #validate args
    local stem=$1; shift
    if [[ -z "${ValidStems["$stem"]}" ]]; then
        >&2 echo "Unsupported script to generate ($stem)";
        return 1;
    fi

    #set the target
    local targetFile=$(readlink -f "$ExecDir/../TRACES_${stem}.sh")

    #Attempt to generate
    if AttemptGeneration $stem $targetFile; then
        rm -f "$targetFile.bak"
    else
        mv "$targetFile.bak" "$targetFile"
        >&2 echo "[ERROR] Failure to generate $targetFile"
        exit 1;
    fi
}

function GenerateCode {
    local stem=$1; shift
    case "$stem" in
        install)
            GenerateInstallCode
        ;;
        update)
            GenerateUpdateCode
        ;;
        get_program_versions)
            GenerateVersionCode
        ;;
        *)
            return 1;
        ;;
    esac
}; export -f GenerateCode;

#### THESE FUNCTIONS ARE WHERE THE MAGIC HAPPENS

#Pulls the conda channel and package (including version ranges), and the command
#   to call the tool to construct conda install commands,
#   as well as Program_installed check commands
function GenerateInstallCode {
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

}; export -f GenerateInstallCode;


#Pulls the conda channel and package (including version ranges) from YAML
#   to construct conda update commands,
function GenerateUpdateCode {
    yq -r '.[].conda | .channel + " " + .package' "$DepFile" |
        sort -u | #If multiple tools come from the same package this prevents redundancy
        while read -r channel package; do
            echo "    conda update -c $channel \"$package\" --yes;"
        done
}; export -f GenerateUpdateCode;

#Pulls the tool name, and Verson commands from YAML to construct commands
# for outputing the versions for each tool
function GenerateVersionCode {
    yq -r '.[] | .name + " " + .versionCmd' system_files/dependencies.yml |
        while read -r name cmd; do
            echo printf \"%-15s: %s\\n\" "$name" "\$($cmd)";
        done
}; export -f GenerateVersionCode;

#Constructs a comment to go with the inserted snippet indicating when and
# how the snippet was generated
function GenerateMetaData {
    local stem=$1; shift;
    local depDir=$(basename "$(dirname "$DepFile")")
    echo "#This code snippet generated on $(date),"
    echo "# using src/$(basename "$ExecDir")/$(basename "$0") $stem"
    echo "# based on information in $depDir/$(basename $DepFile)"
    echo "#=================================================="
}; export -f GenerateMetaData;

#Constructs the complete section of text to insert
function GenerateSnippet {
    local stem=$1; shift;
    echo "#=================================================="
    GenerateMetaData "$stem";
    GenerateCode "$stem";
    echo "#=================================================="
}; export -f GenerateSnippet;

#Function that tries to use awk's inplace editing to insert a code snippet
#Note that this requires a GenerateSnippet function to exist in the environment
#Inputs - the stem to generate
#       - and a Target File
#Output - None, modifies the target File in place
#           may create a .bak file
#           returns a failure

function AttemptGeneration {
    local stem=$1; shift
    local targetFile=$1; shift
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
    ' inplace::enable=0 <(GenerateSnippet "$stem") inplace::enable=1 "$targetFile"
}; export AttemptGeneration;


if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
