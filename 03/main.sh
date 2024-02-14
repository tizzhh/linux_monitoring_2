#!/bin/bash

date_re_pattern="^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$"

validate_parameter() {
    length=$#
    if [[ $length -ne 1 ]]
    then
        echo "Usage: ./main.sh [1-3]. 1: clear by log file, 2: by creation of date and time, 3: by name mask"
        exit 1
    fi

    if [[ ! $1 =~ ^[1-3]$ ]]
    then
        echo "Invalid parameter $1. Param should be an int [1, 3]"
        exit 1
    fi
}

validate_date() {
    if [[ ! $1 =~ $date_re_pattern ]]
    then
        echo "Date should be in the format: 'YYYY-MM-DD HH:MM'"
        exit 0
    fi

    if ! date -d "$1" &> /dev/null
    then
        echo "Incorrect date: $1"
    fi
}

validate_parameter "$@"
arg=$1

delete_by_log_file() {
    read -p "Input path to log_file: " log_file_path
    if [[ ! -f $log_file_path ]]
    then
        echo "Path does not exist"
    fi

    while read -r line
    do
        file_path=$(echo "$line" | sed 's/ / /' | awk '{print $1}')
        file_path=$(dirname "$file_path")
        sudo rm -rf $file_path
    done < "$log_file_path"
}

delete_by_date() {
    read -p "Input start date in UTC: " start_date
    read -p "Input end date in UTC: " end_date
    validate_date "$start_date"
    validate_date "$end_date"
    sudo find / -type d -newermt "$start_date" -not -newermt "$end_date" -exec rm -rv {} +
}

delete_by_mask() {
    read -p "Input mask (chars, underscore and date): " delete_pattern_mask
    res=$(sudo find / -name "$delete_pattern_mask") &> /dev/null
    for path in ${res[*]}
    do
        rm -rf $path
    done
}

if [[ $arg -eq 1 ]]
then
    delete_by_log_file
elif [[ $arg -eq 2 ]]
then
    delete_by_date
elif [[ $arg -eq 3 ]]
then
    delete_by_mask
fi