#!/bin/sh
set -e

INFILE=$1

cd-hit -i ${INFILE} -o ${INFILE}.60 -c 0.6 -M 0 -T 0 -d 10000000 -n 4
makeblastdb -in ${INFILE} -dbtype prot -parse_seqids
makeblastdb -in ${INFILE}.60 -dbtype prot

