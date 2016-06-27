#!/bin/sh
set -e

BLASTDB="./blast_db"

read -p " 
     This script is designed to make downloading and building a BLAST-able
 UniRef database that can be used to perform a RUBBLE cluster-restricted
 protein-protein BLAST. It contains 2 steps, each of which you will be prompted to confirm:

 1.) Download the necessary UniRef files.
 2.) Build the BLAST databases and lookup file.

     When this script completes all outputs will be in the ./blast_dbs directory and
 you can move that directory to where ever you would like to use it after. 

 [Download UniRef Files]

     I am going to download three (very) large files that total ca. 20 GB.
 This could take a couple of hours or maybe just 15-20 minutes depending on your 
 internet connection.

     Once the files are downloaded I'm going to parse through them and build
some BLAST databases. This step will require ca. 50 GB of hard drive space and
take up to an hour to complete.

 Type 'y' or 'yes' to proceed, or anything else (perhaps 'no') to quit now!

 TL;DR you better have 70 GB or so of disk space!

" -r
echo
if [[ $REPLY =~ ^[Yy] ]]
then
    echo -e "\n Downloading UniRef100 and UniRef50 FASTA's"
    echo -e " as well as the UniRef50 XML file."
    echo
    echo
    mkdir -p ${BLASTDB}
    wget "ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref100/uniref100.fasta.gz -O ${BLASTDB}/uniref100.fasta.gz"
    wget "ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref50/uniref50.fasta.gz -O ${BLASTDB}/uniref50.fasta.gz"
    wget "ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref50/uniref50.xml.gz -O ${BLASTDB}/uniref50.xml.gz"

    echo "

 [Building BLAST-able cluster-restriction databases]

     Again, this will require ca. 50 GB of hard drive space to do and take up to an hour
 to complete.

     If at any point you think you will run out of disk space just kill this script!


"
    echo
    if [[ $REPLY =~ ^[Yy] ]]
    then
	cd ${BLASTDB}
	../scripts/00-XML2uniref_lookup.pl uniref50.xml.gz > uniref50__2__uniref100.lookup
	gunzip uniref100.fasta.gz
	mv uniref100.fasta UNIREF100
	makeblastdb -in UNIREF100 -dbtype prot -parse_seqids
	rm UNIREF100
	gunzip uniref50.fasta.gz
	mv uniref50.fasta UNIREF50
	makeblastdb-in UNIREF50 -dbtype prot
	rm UNIREF50
    else
	echo -e "\n Exitting without constructing databases\n\n";
    fi

    echo -e "\n\n All done: ";
    date
    echo
    echo
else
    echo -e "\n\n Canceling the download and construction of a RUBBLE UniRef database...\n\n"
fi
