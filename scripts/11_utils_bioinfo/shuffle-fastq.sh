#!/usr/bin/env bash
set -euo pipefail

[ ! -n "$1" ] && exit 1
INFILE=$1

if [ ! -n "$2" ]; then
    OUTFILE=${INFILE%.*}_shuf.fastq.gz
else
    OUTFILE=$2
fi

zcat "$INFILE" | paste - - - - | shuf | tr '\t' '\n' | pigz -c > "$OUTFILE"
