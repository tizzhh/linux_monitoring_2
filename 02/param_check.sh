#!/bin/bash

validate_parameter () {
    local len=$#
    if [ $len -ne 3 ]
    then
        echo "Usage: [7 english chars for folder names] [<= 7 english chars for file name <= for ext] [file size in mb <= 100mb]"
        exit 2
    fi

    local param1=$1
    if [[ "$param1" =~ [^a-zA-Z]$ ]]
    then
        echo "Param1 should be english chars only"
        exit 2
    fi

    local len=${#param1}
    if [ $len -gt 7 ]
    then
        echo "$param1"
        echo "Param1 should not be longer than 7 characters"
        exit 2
    fi

    local param2=$2
    if [[ ! "$param2" =~ ^[a-zA-Z]{1,7}\.[a-zA-Z]{1,3}$ ]]
    then
        echo "Param2 should be english chars only: <= 7 for file name and <= 3 for ext and include a dot"
        exit 2
    fi

    local param3=$3
    if [[ ! "$param3" =~ ^[1-9][0-9]+mb$  ]]
    then
        echo "Param3 should be <= 100 and >= 1 and mb"
        exit 2 
    fi

}
