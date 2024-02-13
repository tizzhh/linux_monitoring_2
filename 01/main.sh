#!/bin/bash

source param_check.sh

validate_parameter "$@"

path=$1
num_subfolders=$2
folder_chars=$3
num_files=$4
file_chars=$5
file_size_kb=$6

file_name_chars=$(echo "$file_chars" | cut -d'.' -f1)
file_ext_chars=$(echo "$file_chars" | cut -d'.' -f2)

# get_random_str() {

# }

normalize_file_name_chars () {
    length=${#file_name_chars}
    while [ $length -lt 4 ]
    do
        last_char=${file_name_chars: -1}
        file_name_chars="$file_name_chars$last_char"
        length=${#file_name_chars}
    done
}

generate_name() {
    local filenamepart=""
    local temp_allowed_chars=$1
    local temp_length=$2
    local upper_random=$3

    for (( i=0; i < $temp_length; ++i ))
    do
        local char="${temp_allowed_chars:$i:1}"
        local num_of_occur=$(echo $((1 + $RANDOM % $upper_random)))
        for (( j=0; j < $num_of_occur; ++j ))
        do
            filenamepart="$filenamepart$char"
        done
    done

    echo "$filenamepart"
}


main() {
    normalize_file_name_chars
    filenamepart="$(generate_name "$file_name_chars" "${#file_name_chars}" 3)_$(date +"%d%m%y")"
    fileextpart="$(generate_name "$file_ext_chars" "${#file_ext_chars}" 3)"
    file_name="$filenamepart.$fileextpart"
    echo "$file_name"
    exit 0
}

main