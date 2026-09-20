#!/bin/bash

#environment variables
BASE_DIR="$HOME/Documentos/ic/mapping_kernel_subsystems"
KERNEL_DIR="$BASE_DIR/linux/" #path to kernel files
GET_MAINTAINER="$KERNEL_DIR/scripts/get_maintainer.pl"
FLAGS=(--nogit --nogit-fallback --nom --nor --separator=";" )
CSV_FILE="resultados.csv"

cd "$KERNEL_DIR"
echo "Diretorio,Arquivo,Subsistemas,Listas de Email" > "$CSV_FILE"

#get each file information and update the table
git ls-files -z drivers/iio | while IFS= read -r -d "" line
do

    dir=$(dirname "$line")
    nome=$(basename "$line")
    subsistemas=$(perl "$GET_MAINTAINER" "${FLAGS[@]}" --noemail --subsystem --nol -f "$line")
    mailing_list=$(perl "$GET_MAINTAINER" "${FLAGS[@]}" -f "$line")
    echo "\"$dir\",\"$nome\",\"$subsistemas\",\"$mailing_list\"" >> "$CSV_FILE"

done


mv "$CSV_FILE" "$BASE_DIR"