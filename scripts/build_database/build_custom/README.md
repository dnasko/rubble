# Creating your own RUBBLE BLAST database

I've written a little BASH wrapper script that will created a RUBBLE BLAST database using CD-HIT. 
If you do not have CD-HIT installed and in your PATH, it won't work. [Find CD-HIT here](http://weizhongli-lab.org/cd-hit/ "CD-HIT"). 
If you do not have the makeblastdb command from [NCBI](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download) installed and in your PATH, it won't work. 
If you're an adequate coder and have a better way to perform these tasks, by all means hack away. This BASH script is meant to act as an implementation of the process of building a clustere restricted BLASTp database and is by no means the only way to do this.

To issue the help message type:

> ./build_custom_rubble_database.sh -h

To run, here's an example:

> ./build_custom_rubble_database.sh -i input.fasta -o output_directory

Again, feel free to open up the script and modify any steps / naming conventions as you please. RUBBLE isn't a program, nor a pipeline, it's essentially a method for BLAST'ing against a clustered database. I'm providing only the code that I use to achieve this method.