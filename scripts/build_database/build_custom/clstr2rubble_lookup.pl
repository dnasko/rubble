#!/usr/bin/perl -w
use strict;

my $infile = $ARGV[0];
my %Reps;
my %Mems;
my $c;
my $max=0;

open(IN,"<$infile") || die "\n Cannot open the file: $infile\n";
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	$c = $_;
	$c =~ s/.* //;
	if ($max < $c) { $max = $c; }
    }
    else {
	my $line = $_;
	$line =~ s/.*, >//;
	my $seq = $line;
	$seq =~ s/\.\.\..*//;
	if ($line =~ m/\*$/) {
	    $Reps{$c} = $seq;
	}
	else {
	    $Mems{$c}{$seq} = 1;
	}
    }
}
close(IN);

for (my $i=0; $i<=$max; $i++) {
    if (exists $Reps{$i}) {
	print $Reps{$i} . "\t" . $Reps{$i} . "\n";
	foreach my $j (keys %{$Mems{$i}}) {
	    print $Reps{$i} . "\t" . $j . "\n";
	}
    }
}

exit 0;
