![Alt text](https://github.com/dnasko/rubble/blob/master/images/logo.png "RUBBLE!")

Welcome to Rubble, a pipeline that enables you to perform BLAST searches 10-20X faster, without compromising your results -- precision = 98% (+/-2%) ; recall = 98% (+/- 2%).

Rubble is most useful when your subject BLAST database is large (e.g. UniRef100).

## Downloading Rubble

To download, simply clone the Rubble repository from GitHub:

> git clone git@github.com:dnasko/rubble

And Rubble will be cloned to your working directory.

## Installing Rubble and its Dependencies

Once you have cloned the repository you should see 3 files and 3 direcotries:

* **LICENSE** the GPL version 2.
* **README.md** this read me!
* **./getting_started** a directory containing some additional information to help you get started.
* **./images** a drectory with images, logos, etc. No need to worry about any of this.
* **rubble.pl** a symbolic link to the rubble.pl script. Let's you run Rubble after you have databases built.
* **./scripts** the scripts directory, which has all of the important bits.

**Rubble has one external dependency, and it's NCBI BLAST+**. Before you can run this pipeline you will need to be sure that all executables (especially blastp, makeblastdb, and blastdbcmd) are installed on your machine and included in your PATH. [Latest versions of BLAST binaries are located here](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download).

**Perl modules needed:** [threads](http://search.cpan.org/~jdhedden/threads-2.09/lib/threads.pm), which is likely not installed on most systesm by default. Can be installed very easily (with admin privileges) via cpan minus:

> sudo cpanm threads

## Using Rubble

Before you can BLAST a set of query sequences against a set of subject sequences you must create an indexed database. The same is true for Rubble, but with an additional requirement. Not only do we need a BLAST database of your subject sequences, we need a BLAST database of your clustered subject sequences. Below I will breifly detail how Rubble databases are created and then how Rubble can be run.

#### Creating Rubble databases


## Citing Rubble

A peer-reviewed manuscript is still being prepared. In the meantime you can find the preprint available on bioRxiv here: https://www.biorxiv.org/content/early/2018/09/26/426098.

## Acknowledgements

Support from the University of Delaware Center for Bioinformatics and Computational Biology Core Facility and use of the BIOMIX compute cluster was made possible through funding from Delaware INBRE (NIGMS GM103446) and the Delaware Biotechnology Institute.
