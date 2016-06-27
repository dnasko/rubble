#!/usr/bin/perl -w

# MANUAL FOR rubble.pl

=pod

=head1 NAME

rubble.pl -- runs the RUBBLE protein BLAST pipeline

=head1 SYNOPSIS

 rubble.pl --query /Path/to/input.fasta --db /Path/to/database --dbClust /Path/to/clustered_database --lookup /Path/to/db.lookup --out /Path/to/out.btab --evalue 1e-3 --threads 1
                    [--grid] [--help] [--manual]

=head1 DESCRIPTION

 RUBBLE is a BLAST-based pipeline that runs protein BLAST's 10-20X faster without
 an appreciable lose of accuracy (i.e. usually 98-99% identical results to using
 NCBI's protein-protein BLAST).

 This is because RUBBLE with search first against a clustered version of your database
 and then search against only the members of whatever clusters were hit when BLAST'ing
 against your unclustered database.
 
=head1 OPTIONS

=over 3

=item B<-q, --query>=FILENAME

Input file in FASTA format. (Required) 

=item B<-d, --db>=DATABASE

Path to the unclustered BLAST database. (Required)

=item B<-dc, -dbClust>=DATABASE

Path to the clustered BLAST database. (Required)

=item B<-l, -lookup>=LOOKUP

Path to the lookup file that connects the clusters in the cluster database to the members in the database. (Required)

=item B<-o, --out>=FILENAME

Output file in BLAST tabular format. (Required) 

=item B<-e, --evalue>=FLOAT

The e-value cutoff. (Defualt = 1e-3)

=item B<-t, --threads>=INT

The number of threads to use for the BLAST. (Default = 1)

=item B<-g, --grid>

Use this flag to run your BLAST's on Grid Engine (Not working yet, will soon I hope)

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-m, --manual>

Displays full manual.  (Optional) 

=back

=head1 DEPENDENCIES

Requires the following Perl libraries.



=head1 AUTHOR

Written by Daniel Nasko, 
Center for Bioinformatics and Computational Biology, University of Delaware.

=head1 REPORTING BUGS

Report bugs to dnasko@udel.edu

=head1 COPYRIGHT

Copyright 2016 Daniel Nasko.  
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.  
This is free software: you are free to change and redistribute it.  
There is NO WARRANTY, to the extent permitted by law.  

Please acknowledge author and affiliation in published work arising from this script's 
usage <http://bioinformatics.udel.edu/Core/Acknowledge>.

=cut


use strict;
use Getopt::Long;
use File::Basename;
use Pod::Usage;

## ARGUMENTS WITH NO DEFAULT
my($query,$db,$dbClust,$lookup,$out,$grid,$help,$manual);
## ARG's with defaults
my $evalue = 0.001;
my $threads = 1;

GetOptions (	
                                "q|query=s"	=>	\$query,
                                "d|db=s"        =>      \$db,
                                "dc|dbClust=s"  =>      \$dbClust,
                                "l|lookup=s"    =>      \$lookup,
                                "o|out=s"	=>	\$out,
                                "e|evalue=s"    =>      \$evalue,
                                "t|threads=i"   =>      \$threads,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument --query not found.\n\n", -exitval => 2, -verbose => 1)   if (! $query);
pod2usage( -msg  => "\n\n ERROR!  Required argument --db not found.\n\n", -exitval => 2, -verbose => 1)      if (! $db);
pod2usage( -msg  => "\n\n ERROR!  Required argument --dbClust not found.\n\n", -exitval => 2, -verbose => 1) if (! $dbClust);
pod2usage( -msg  => "\n\n ERROR!  Required argument --lookup not found.\n\n", -exitval => 2, -verbose => 1)  if (! $lookup);
pod2usage( -msg  => "\n\n ERROR!  Required argument --out not found.\n\n", -exitval => 2, -verbose => 1)     if (! $out);

if ($grid ) { print "\n Warning: The --grid option is not working yet.\n"; }









exit 0;
