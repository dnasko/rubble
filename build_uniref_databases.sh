#!/bin/sh

read -p " 
     This script is designed to make downloading and building a BLAST-able
 UniRef database that can be used to perform cluster-restricted protein BLAST.
 It contains 2 steps, each of which you will be prompted to confirm:

 1.) Download the necessary UniRef files.
 2.) Build the BLAST databases and lookup file.

     When this script complete all outputs will be in the ./blast_dbs directory.

 [Download UniRef Files]
 I am going to download three (very) large files that total ca. 20 GB.
 This will likely take a couple of hours or so to complete.
 Type 'y' or 'yes' to proceed, or anything else (perhaps 'no') to forgo this download
 and move on to the next step:

" -r
echo
if [[ $REPLY =~ ^[Yy] ]]
then
    echo -e "\n Downloading UniRef100 and UniRef50 FASTA's"
    echo -e " as well as the UniRef50 XML file."
    mkdir -p blast_dbs
    wget "ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref100/uniref100.fasta.gz"
    wget "ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref50/uniref50.fasta.gz"
else
    echo " Okay, we'll move on to the next thing then...

"
fi
