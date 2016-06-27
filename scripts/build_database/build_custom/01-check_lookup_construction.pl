#!/usr/bin/perl -w
use strict;

my $lookup = $ARGV[0];
my $fasta  = $ARGV[1];
my %h;

open(IN,"<$lookup") || die "\n Cannot open the file: $lookup\n";
while(<IN>) {
    chomp;
    my @a = split(/\t/, $_);
    $h{$a[1]} = 0;
}        
close(IN);

open(IN,"<$fasta") || die "\n Cannot open the file: $fasta\n";
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	my $id = $_;
	$id =~ s/^>//;
	$id =~ s/ .*//;
	if (exists $h{$id}) {
	    $h{$id} = 1;
	}
	else {
	    print "is in UniRef100 FASTA, needs to be in the LOOKUP file\t" . $id . "\n";
	}
    }
}
close(IN);

foreach my $i (keys %h) {
    if ($h{$i} == 0) {
	print "is in LOOKUP, needs to be in 100 FASTA\t" . $i . "\n";
    }
}

exit 0;


