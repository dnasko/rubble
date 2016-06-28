![Alt text](https://github.com/dnasko/rubble/blob/master/images/logo.png "RUBBLE!")

Welcome to RUBBLE, a pipeline that enables you to perform BLAST searches 10-20X faster, without compromising your results -- precision = 98% (+/-2%) ; recall = 98% (+/- 2%).

RUBBLE is most useful when your subject BLAST database is large (e.g. UniRef100).

1. Downloading RUBBLE
----------------------

To download, simply clone the RUBBLE repository from GitHub:

`$ git clone git@github.com:dnasko/rubble`

And RUBBLE will be cloned to your working directory.

2. Installing RUBBLE and its Dependencies
------------------------------------------

Once you have cloned the repository you should see 3 files and 3 direcotries:

* **LICENSE** the GPL version 2.
* **README.md** this read me!
* **./getting_started** a directory containing some additional information to help you get started.
* **./images** a drectory with images, logos, etc. No need to worry about any of this.
* **rubble.pl** a symbolic link to the rubble.pl script. Let's you run RUBBLE after you have databases built.
* **./scripts** the scripts directory, which has all of the important bits.

**RUBBLE has one external dependency, and it's NCBI BLAST+**. Before you can run this pipeline you will need to be sure that all executables (especially blastp, makeblastdb, and blastdbcmd) are installed on your machine and included in your PATH. [Latest versions of BLAST binaries are located here](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download).

**Perl modules needed:** [threads](http://search.cpan.org/~jdhedden/threads-2.09/lib/threads.pm), which is likely not installed on most systesm by default. Can be installed very easily (with admin privileges) via cpan minus:

> sudo cpanm threads

3. Using RUBBLE
---------------



Acknowledgements
----------------

Support from the University of Delaware Center for Bioinformatics and Computational Biology Core Facility and use of the BIOMIX compute cluster was made possible through funding from Delaware INBRE (NIGMS GM103446) and the Delaware Biotechnology Institute.