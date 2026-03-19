#!/bin/bash

#Function that tries to use awk's inplace editing to insert a code snippet
#Note that this requires a GenerateSnippet function to exist in the environment
#Inputs - a Target File
#       - a Section Label
#       - an option number of max insertions, defaulting to 1
#           if there are multiple AUTO-sections to have the same code inserted this could be used
#Output - None, modifies the target File in place
#       - silently returns an exit code if:
#           the target file is empty
#           the GenerateSnippet Function doesn't exist
#           something else goes wrong
function AttemptGeneration {
    local targetFile=$1; shift
    local sectionLabel=$1; shift
    local generationFunction=$1; shift
    local maxInsert=$1; shift
    if ! [ -s "$targetFile" ]; then
        >&2 echo "Empty/Non-existent TargetFile ($targetFile) for AttemptGeneration"
        return 1;
    fi
    if [ -z "$sectionLabel" ]; then
        >&2 echo "Missing sectionLabel for AttemptGeneration"
        return 1;
    fi
    if ! [[ $(type -t "$generationFunction") == "function" ]]; then
        >&2 echo "Provided snippet generating function ($generationFunction) is not a function"
        return 1;
    fi
    [ -z "$maxInsert" ] && maxInsert=1;
    awk -i inplace -v inplace::suffix=.bak -v tgtLabel="$sectionLabel" -v maxInsert="$maxInsert" '
        BEGIN{
            inSnippet = 0;
            insertCount=0;
        }
        (ARGIND == 2){
            snippet[++nLine] = $0;
            next;
        }
        /^#BEGIN AUTO-GENERATED SECTION/ {
            print;
            label = $5
            if(label == tgtLabel){
                inSnippet=1;
                insertCount++;
            }
        next}
        /^#END AUTO-GENERATED SECTION/ {
            if(inSnippet){
                if(maxInsert--){
                    for(i=1;i<=nLine;i++){
                        print snippet[i]
                    }
                }
                inSnippet=0;
            }
            print;
            next;
        }
        (inSnippet){next}
        1
        END {
            if(!insertCount){
                print "WARNING - Did not find a section to replace! Check Section header in target" > "/dev/stderr"
            }
        }
    ' inplace::enable=0 <("$generationFunction") inplace::enable=1 "$targetFile"
}

function GenerateTarget {
    local targetFile=$1; shift
    local sectionLabel=$1; shift
    local generationFunction=$1; shift
    local maxInsert=$1; shift
    if AttemptGeneration "$targetFile" "$sectionLabel" "$generationFunction" "$maxInsert"; then
        rm -f "$targetFile.bak"
    else
        mv "$targetFile.bak" "$targetFile"
        >&2 echo "[ERROR] Failure to generate $targetFile"
        return 1;
    fi
}

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    >&2 echo "This script is not intended to be run directly, it is\n" \
                " to be sourced as a library by the other generator scripts\n"
fi

