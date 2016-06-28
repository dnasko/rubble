# Creating your own RUBBLE BLAST database

I've written a little BASH wrapper script that will created a RUBBLE BLAST database using CD-HIT.
If you do not have CD-HIT installed it won't work. [Find CD-HIT here](http://weizhongli-lab.org/cd-hit/ "CD-HIT").

To run, simply issue:

> ./build_custom_rubble_database.sh input.fasta

Feel free to open up the script and modify any steps / naming conventions as you please. Again, RUBBLE isn't a program, nor a pipeline, it's essentially a method for BLAST'ing against a clustered database. I'm providing only the code that I use to achieve this method.