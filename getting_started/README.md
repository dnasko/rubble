# Getting started!

RUBBLE isn't a program, it isn't even a pipeline per se, it's more of a method really. As a result it's not so straight forward to wrap the whole RUBBLE method into one or two scripts and is necessary to break things up a bit.

I've placed in this directory two helpful scripts in getting started.

### Building a set of RUBBLE databases

In order to run RUBBLE you must have a subject BLAST database built (using NCBI's makeblasdb) and a clustered version of that same subject BLAST database (also built with NCBI's makeblastdb). This method can be applied to any set of subjects, however I provide a Perl script (sym-linked here) that will download and build these databases from UniRef.

`./build_a_uniref_rubble_database.pl --out rubble_blast_db`


### Running RUBBLE

Once you have a set of RUBBLE BLAST databases indexed and a lookup file able to connect your clusters to the sequences in the big database you're ready to go!

`./rubble.pl --help`