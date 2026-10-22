#!/bin/bash

#environment variables
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KERNEL_DIR=${KERNEL_DIR:-"$BASE_DIR/linux"} #path to kernel files

#security asserts
error () {
    echo "error: $1" >&2
    exit 1
}

#validate required tools
for tool in git perl jq parallel make; do
    command -v "$tool" > /dev/null || error "required tool \"$tool\" not found"
done

#check if kernel dir exists
[ -d "$KERNEL_DIR" ] \
    || error "could not find kernel directory \"$KERNEL_DIR\""

#check if the kernel dir has the MAINTAINERS file
[ -f "$KERNEL_DIR/MAINTAINERS" ] \
    || error "MAINTAINERS file not found in $KERNEL_DIR"

#check if it has the get_maintainer script
[ -f "$KERNEL_DIR/scripts/get_maintainer.pl" ] \
    || error "scripts/get_maintainer.pl not found in $KERNEL_DIR"

#assert kernel dir is an absolute path
KERNEL_DIR="$(cd -- "$KERNEL_DIR" && pwd)"

#set the other variables
KERNEL_VERSION=$(make -s -C "$KERNEL_DIR" kernelversion)
[ -n $KERNEL_VERSION ] || error "could not determine kernel version" #check if it is not empty

CSV_FILE="$BASE_DIR/results_${KERNEL_VERSION}.csv"
export ERR_LOG="$BASE_DIR/err.log"
export GET_MAINTAINER="$KERNEL_DIR/scripts/get_maintainer.pl"

cd "$KERNEL_DIR"

echo "directory,file,subsystem,mailing_list,lists_subsystem" > "$CSV_FILE"
: > "$ERR_LOG"

#run the get maintainer script in a received file
process_line () {
    line="$1"

    dir=$(dirname "$line")
    name=$(basename "$line")
    json=$(perl "$GET_MAINTAINER" \
                        --nogit \
                        --nogit-fallback \
                        --nom \
                        --nor \
                        --separator=";" \
                        --subsystem \
                        --json \
                        -f "$line" \
                        2>> "$ERR_LOG") #redirect errors and warnings to a file

    #get the subsystems field in json format
    subsystems=$(echo "$json" | \
                    jq -r -c '[.subsystem.[] ]')

    #filter json "maintainers" field to get mailing lists in json format
    mailing_list=$(echo "$json" | \
                    jq -r -c '[.maintainers.[] | select(.role | contains("open list")) | .email]')

    #filter json "maintainers" field to get subsystems and mailing lists relationships in json format
    lists_relations=$(echo "$json" | \
                        jq -r -c '[.maintainers.[] | select(.role | contains("open list")) | {email, role}]')

    #format the columns to the csv file
    final_line=$(jq -rn \
                    --arg dir "$dir" \
                    --arg name "$name" \
                    --arg subs "$subsystems" \
                    --arg ml "$mailing_list" \
                    --arg list_r "$lists_relations" \
                    '[$dir, $name, $subs, $ml, $list_r] | @csv'
    )

    echo "$final_line"
}
export -f process_line

#Process all the files in parallel and update the table
git ls-files -z . | parallel -0 process_line >> "$CSV_FILE"
