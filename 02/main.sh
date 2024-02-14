#!/bin/bash

source param_check.sh

validate_parameter "$@"

GB_IN_KB=1048576

folder_chars=$1
file_chars=$2
file_size_mb=${3::-2}

num_subfolders=100

EXCEPT_PATHS=("/bin/" "/sbin/")


file_name_chars=$(echo "$file_chars" | cut -d'.' -f1)
file_ext_chars=$(echo "$file_chars" | cut -d'.' -f2)


check_free_space() {
    free_space=$(df / | awk '{print $4}' | tail -n 1)
    if [ "$free_space" -lt "$GB_IN_KB" ]
    then
        echo "Less than 1 GB free on root"
        exit 0
    fi
}

normalize_file_name_chars_folder_chars () {
    local -n var
    for var in file_name_chars folder_chars
    do
        length=${#var}
        while [ $length -lt 4 ]
        do
            last_char=${var: -1}
            var="$var$last_char"
            length=${#var}
        done
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

get_root_paths() {
    declare -g root_paths=( $(ls /) )
    temp_arr=()
    for var in ${root_paths[@]}
    do 
        if [[ -d "/$var/" && ! ${EXCEPT_PATHS[*]} =~ "/$var/" ]]
        then
            var="/$var/"
            temp_arr+=("$var")
        fi
    done
    root_paths=("${temp_arr[@]}")
}

# захуячить сюда вообще все диры через du и брать рандом
# find / -type d
get_root_paths

main() {
    normalize_file_name_chars_folder_chars

    dir_paths=(${root_paths[@]})
    # while true
    for (( i=0; i < 1; ++i ))
    do
        temp_outer=("${dir_paths[@]}")
        dir_paths=()
        for path_inner in ${temp_outer[@]}
        do
            temp=()
            for (( j=0; j < $num_subfolders; ++j ))
            do
                subfolder="$(generate_name "$folder_chars" "${#folder_chars}" 3)_$(date +"%d%m%y")"
                new_dir_path="$path_inner$subfolder/"
                if ! sudo mkdir -p "$new_dir_path" &> /dev/null
                then
                    break
                fi
                temp+=("$new_dir_path")
                num_files=$(echo $((1 + $RANDOM % 10)))
                for (( k=0; k < $num_files; ++k ))
                do
                    filenamepart="$(generate_name "$file_name_chars" "${#file_name_chars}" 3)_$(date +"%d%m%y")"
                    fileextpart="$(generate_name "$file_ext_chars" "${#file_ext_chars}" 3)"
                    file_name="$filenamepart.$fileextpart"
                    file_path="$path_inner$subfolder/$file_name"
                    if ! sudo fallocate -l $file_size_mb"M" "$file_path" &> /dev/null
                    then
                        break
                    fi
                    echo "$file_path $(date) $file_size_mb MB" >> script_log.txt
                done
                check_free_space
            done
            temp_outer=("${temp[@]}")
            dir_paths+=("${temp_outer[@]}")
        done
    done
    
    exit 0
}

main