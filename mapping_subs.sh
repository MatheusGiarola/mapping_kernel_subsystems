#!/bin/bash

#environment variables
BASE_DIR="$HOME/Documentos/ic/mapping_kernel_subsystems"
KERNEL_DIR="$BASE_DIR/linux/" #path to kernel files
CSV_FILE="$BASE_DIR/resultados.csv"
export GET_MAINTAINER="$KERNEL_DIR/scripts/get_maintainer.pl"

cd "$KERNEL_DIR"
echo "Diretorio,Arquivo,Subsistemas,Listas de Email" > "$CSV_FILE"

#run the get maintainer script in a received file
process_line () {
    line="$1"

    dir=$(dirname "$line")
    nome=$(basename "$line")
    json=$(perl "$GET_MAINTAINER" \
                        --nogit \
                        --nogit-fallback \
                        --nom \
                        --nor \
                        --separator=";" \
                        --subsystem \
                        --json \
                        -f "$line")

    #get the subsystems field
    subsistemas=$(echo $json | \
                    jq -r '[.subsystem.[] ] | join(";")')

    #filter json "maintainers" field to get mailing lists
    mailing_list=$(echo $json | \
                    jq -r '[.maintainers.[] | select(.role | contains("open list")) | .email] | join(";")')

    echo "\"$dir\",\"$nome\",\"$subsistemas\",\"$mailing_list\""
}
export -f process_line

#Process all the files in parallel and update the table
git ls-files -z drivers | parallel -0 process_line >> "$CSV_FILE"
