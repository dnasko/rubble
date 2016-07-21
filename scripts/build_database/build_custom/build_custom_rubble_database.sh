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

if ! [ -a $infile ]; then
    printf $"\n\n ERROR: Cannot find the input file: ${infile}\n\n"
    exit 1
fi

## Now for the actual work...

mkdir -p ${outdir}
printf "\n Building RUBBLE Databases: "; date;
printf "\n [ 1/4 ] Running CD-HIT ...\n"
cd-hit -i ${infile} -o ${outdir}/${basein}.60 -c 0.6 -M 0 -d 10000000 -n 4 -T 0 &> ${outdir}/cd-hit.log
printf " [ 2/4 ] Building the cluster lookup file ...\n"
perl clstr2rubble_lookup.pl ${outdir}/${basein}.60.clstr > ${outdir}/${basein}.rubble.lookup
printf " [ 3/4 ] Building the BLASTp clustered database ...\n"
makeblastdb -in ${outdir}/${basein}.60 -out ${outdir}/${basein}_60 -dbtype prot &> ${outdir}/makeblastdb_60.log
printf " [ 4/4 ] Building the BLASTp non-clustered database ...\n"
makeblastdb -in ${infile} -out ${outdir}/${basein}_100 -dbtype prot -parse_seqids &> ${outdir}/makeblastdb_100.log
printf "\n\n RUBBLE database build complete! "; date;
printf "\n\n"
printf " Here is an exmaple command you would use to run a RUBBLE search against the database you just built:\n\n"
printf "    rubble.pl -q input_queries.fasta --db=${outdir}/${basein}_100 --dbClust=${outdir}/${basein}_60 --lookup=${outdir}/${basein}.rubble.lookup"
printf "\n\n\n"
