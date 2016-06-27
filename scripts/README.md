# RUBBLE Scripts

To run RUBBLE you just need to use the RUBBLE Perl script. However, this requires that you already have a set of RUBBLE databases built. To build a RUBBLE database head to the [build_database](https://github.com/dnasko/rubble/tree/master/scripts/build_database) directory now. There you will be able to create [your own custom RUBBLE database](https://github.com/dnasko/rubble/tree/master/scripts/build_database/build_custom) or create a [RUBBLE database with the latest version of UniRef](https://github.com/dnasko/rubble/tree/master/scripts/build_database/build_uniref).

Once you're ready to run RUBBLE use the Perl script to issue some nice and descriptive help:

`./rubble.pl --help`

RUBBLE can utilizie multiple-CPU's by splitting the input query file into multiple chunks and using Perl's Threads module to run concurrent BLAST jobs.