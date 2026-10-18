#!/bin/bash

#environment variables
BASE_DIR="$HOME/Documentos/ic/mapping_kernel_subsystems"
KERNEL_DIR="$BASE_DIR/linux/" #path to kernel files
KERNEL_VERSION=$(make -s -C "$KERNEL_DIR" kernelversion)
CSV_FILE="$BASE_DIR/resultados_${KERNEL_VERSION}.csv"
export GET_MAINTAINER="$KERNEL_DIR/scripts/get_maintainer.pl"

cd "$KERNEL_DIR"
echo "Diretorio,Arquivo,Subsistemas,Listas de Email,Relação de Listas e Subsistemas" > "$CSV_FILE"

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
                        -f "$line")

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
