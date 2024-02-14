#!/bin/bash

validate_parameter () {
    local len=$#
    if [ $len -ne 6 ]
    then
        echo "Usage: [absolute_path] [number of subfolders] [7 english chars for folder names] [number of each file in folder] [<= 7 english chars for file name <= for ext] [file size in kb <= 100kb]"
        exit 2
    fi

    local param1=$1
    if [[ ! "$1" = /* || ! "$1" = */ ]]
    then
        echo "Param1 should be an absolute path"
        exit 2
    fi
    
    local param2=$2
    if [[ $param2 =~ [^1-9]+$ ]]
    then
        echo "Param2 should be an int"
        exit 2
    fi

    local param3=$3
    if [[ "$param3" =~ [^a-zA-Z]$ ]]
    then
        echo "Param3 should be english chars only"
        exit 2
    fi

    local len=${#param3}
    if [ $len -gt 7 ]
    then
        echo "$param3"
        echo "Param3 should not be longer than 7 characters"
        exit 2
    fi

    local param4=$4
    if [[ "$param4" =~ [^1-9]$ ]]
    then
        echo "Param4 should an int"
        exit 2
    fi

    local param5=$5
    if [[ ! "$param5" =~ ^[a-zA-Z]{1,7}\.[a-zA-Z]{1,3}$ ]]
    then
        echo "Param5 should be english chars only: <= 7 for file name and <= 3 for ext and include a dot"
        exit 2
    fi

    local param6=$6
    if [[ ! "$param6" =~ ^[1-9][0-9]+kb$  ]]
    then
        echo "Param6 should be <= 100 and >= 1"
        exit 2 
    fi

}
