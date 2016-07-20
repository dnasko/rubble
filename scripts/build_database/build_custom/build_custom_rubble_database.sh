#!/bin/sh
set -e

usage="
$(basename "$0") [-h] [-i input.fasta] [-o ./output_directory/] -- program to build a RUBBLE database

where:
    -h  show this help text
    -i  input database fasta file (required)
    -o  directory where all of the output files will exist

"

while getopts ':h:i:o:' option; do
    case "$option" in
	h) echo "$usage"
	   exit
	   ;;
	i) infile=${OPTARG}
	   ;;
	o) outdir=${OPTARG}
	   ;;
    esac
done
shift $((OPTIND - 1))

if [ -z "${infile}" ]; then
    printf "\nmissing argument for -i\n" >&2
    echo "$usage" >&2
    exit 1
fi

if [ -z "${outdir}" ]; then
    printf "\nmissing argument for -o\n" >&2
    echo "$usage" >&2
    exit 1
fi

basein=${infile##*/}
basein=${basein%.*}
mkdir -o ${outdir}
# cd-hit -i ${infile} -o ${outdir}/${basein}.60 -c 0.6 -M 0 -T 0 -d 10000000 -n4

echo "

 in = $infile
 out = $outdir
 base = $basein

"

# INFILE=$1
# OUTDIR=$2

# mkdir -p ${OUTIDR}

# cd-hit -i ${INFILE} -o ${INFILE}.60 -c 0.6 -M 0 -T 0 -d 10000000 -n 4
# makeblastdb -in ${INFILE} -dbtype prot -parse_seqids
# makeblastdb -in ${INFILE}.60 -dbtype prot

