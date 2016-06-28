#!/usr/bin/perl -w

# MANUAL FOR build_uniref_rubble_databases.pl

=pod

=head1 NAME

build_uniref_rubble_databases.pl -- Will download and build a UniRef RUBBLE database to perform fast and accurate BLASTp searches.

=head1 SYNOPSIS

 build_uniref_rubble_databases.pl --out /path/to/database
                     [--help] [--manual]

=head1 DESCRIPTION

 This script is designed to download and build a UniRef50 and UniRef100 BLASTp database for use in the RUBBLE BLAST pipeline.

 Broadly, it will perform the following three actions:

 1.) Download the necessary UniRef files.
 2.) Build the lookup file that connects UR50 clusters to UR100 sequences.
 3.) Build the UR50 and UR100 BLAST databases.

 YOU WILL NEED AROUND 70 GB of FREE DISK SPACE TO RUN THIS SCRIPT. ONLY RUN ON A MACHINE WITH ENOUGH SPACE!

 If you would like to build your own custom RUBBLE BLAST database there are scripts available in the next directory over to assist you in that.
 
=head1 OPTIONS

=over 3

=item B<-o, --out>=DIRECTORY

Output directory where the UniRef RUBBLE databases and lookup file will be build. WARNING: If this directory already exists files may be written over. Use --help argument for more information. (Required) 

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-m, --manual>

Displays full manual.  (Optional) 

=back

=head1 DEPENDENCIES

Requires the following Perl libraries.

None.

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

#ARGUMENTS WITH NO DEFAULT
my($out,$help,$manual);
my $version = "1.0";

GetOptions (	
				"o|out=s"	=>	\$out,
				"h|help"	=>	\$help,
				"m|manual"	=>	\$manual);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument --out not found.\n\n", -exitval => 2, -verbose => 1)  if (! $out);

## Make sure external dependencies are installed
my $PROG = `which wget`; unless ($PROG =~ m/wget/) { die "\n ERROR: External program \"wget\" not installed. Please install it or use a machine with it installed.\n\n"; }
$PROG = `which makeblastdb`; unless ($PROG =~ m/makeblastdb/) { die "\n ERROR: External program \"makeblastdb\" not installed. Please install it or use a machine with it installed.\n\n" }

print "\n\n Downloading UniRef100 and UniRef50 FASTA's as well as the UniRef50 XML file...\n\n\n";

print `mkdir -p $out`;
print_log_info($out);
print `wget "ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref100/uniref100.fasta.gz" -O $out/uniref100.fasta.gz`;
print `wget "ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref50/uniref50.fasta.gz" -O $out/uniref50.fasta.gz`;
print `wget "ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref50/uniref50.xml.gz" -O $out/uniref50.xml.gz`;

print "\n\n Building the lookup file that connects UR50 clusters to UR100 sequences...\n\n\n";
build_lookup($out);
print `rm $out/uniref50.xml.gz`;

print "\n\n Building the BLAST databases...\n\n\n";
print `gunzip $out/uniref100.fasta.gz`;
print `makeblastdb -in $out/uniref100.fasta -dbtype prot -out $out/UNIREF100 -parse_seqids`;
print `rm $out/uniref100.fasta`;
print `gunzip $out/uniref50.fasta.gz`;
print `makeblastdb -in $out/uniref50.fasta -dbtype prot -out $out/UNIREF50`;
print `rm $out/uniref50.fasta`;

print "\n All done!\n";

sub print_log_info
{
    my $log_file = $_[0] . "/" . "UniRef_RUBBLE_Database_Build.log";
    my $date = `date`;
    open(OUT,">$log_file") || die "\n Cannot write to $log_file\n";
    print OUT "This UniRef RUBBLE BLAST database was build on: $date";
    print OUT "Using RUBBLE BLAST version $version\n";
    close(OUT);
}
sub build_lookup
{
    my $infile = $_[0] . "/" . "uniref50.xml.gz";
    my $id50;
    open(IN, "gunzip -c $infile |") || die "\n Cannot open the file: $infile\n";
    open(OUT,">$out/uniref50__2__uniref100.lookup" ) || die "\n Cannot write to: $out/uniref50__2__uniref100.lookup\n";
    print OUT "UR50\tUR100\n";
    while(<IN>) {
	chomp;
	if ($_ =~ m/^<entry id=/) {
	    $id50 = $_;
	    $id50 =~ s/.*?"//;
	    $id50 =~ s/".*//;
	}
	elsif ( $_ =~ m/^<property type="UniRef100 ID"/ ) {
	    my $id100 = $_;
	    $id100 =~ s/.*value="//;
	    $id100 =~ s/".*//;
	    print OUT $id50 . "\t" . $id100 . "\n";
	}
    }
    close(IN);
    close(OUT);
}

exit 0;
