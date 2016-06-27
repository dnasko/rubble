#!/usr/bin/perl -w
use strict;

my $infile = $ARGV[0];
my $link_file = $ARGV[1];
my %h;

open(IN,"<$infile") || die "\n Cannot open the file: $infile\n";
while(<IN>) {
    chomp;
    $h{$_} = 0;
}        
close(IN);

open(IN,"<$link_file") || die "\n Cannot open the file: $link_file\n";
while(<IN>) {
    chomp;
    my @a = split(/\t/, $_);
    if (scalar @a == 2) {
	if (exists $h{$a[0]}) {
	    print STDOUT $a[1] . "\n";
	    $h{$a[0]} = 1;
	}
    }
}
close(IN);

foreach my $i (keys %h) {
    if ( $h{$i} == 0 ) {
	print STDERR "missing\t$i\n";
    }
}

exit 0;


