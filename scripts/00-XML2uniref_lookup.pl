#!/usr/bin/perl -w
use strict;

## Input is the Uniref50 XML file. GZIP'd
## wget "ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref50/uniref50.xml.gz"

my $infile = $ARGV[0];
my $id50;

open(IN, "gunzip -c $infile |") || die "\n Cannot open the file: $infile\n";
while(<IN>) {
    chomp;
    if ($_ =~ m/^<entry id=/) {
	$id50 = $_;
	$id50 =~ s/.*?"//;
	$id50 =~ s/".*//;
	# print $id50 . "\n";
    }
    elsif ( $_ =~ m/^<property type="UniRef100 ID"/ ) {
	my $id100 = $_;
	$id100 =~ s/.*value="//;
	$id100 =~ s/".*//;
	print $id50 . "\t" . $id100 . "\n";
    }
}        
close(IN);

exit 0;


