#!/bin/bash

GB_IN_KB=1048576
file_size_mb=10
num_subfolders=5

EXCEPT_PATHS=("/bin/" "/sbin/")

check_free_space() {
    free_space=$(df / | awk '{print $4}' | tail -n 1)
    if [ "$free_space" -lt "$GB_IN_KB" ]
    then
        echo "Less than 1 GB free on root"
        exit 0
    fi
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

    dir_paths=(${root_paths[@]})
    for (( i=0; i < 1; ++i ))
    do
        temp_outer=("${dir_paths[@]}")
        dir_paths=()
        for path_inner in ${temp_outer[@]}
        do
            temp=()
            for (( j=0; j < $num_subfolders; ++j ))
            do
                subfolder=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
                new_dir_path="$path_inner$subfolder/"
                if ! sudo mkdir -p "$new_dir_path" &> /dev/null
                then
                    break
                fi
                temp+=("$new_dir_path")
                num_files=$(echo $((3 + $RANDOM % 10)))
                for (( k=0; k < $num_files; ++k ))
                do
                    filenamepart="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
                    file_name="$filenamepart"
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