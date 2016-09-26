#!/usr/bin/perl -w
use strict;

my $fastq1 = $ARGV[0];
my $fastq2 = $ARGV[1];

my $seqs   = 77965607;
my $sample =  7796561;

my @Random;
my %Random;
my $iter = 0;

while(scalar(@Random) < $sample) {
    my $rand_num = int(rand($seqs));
    unless (exists $Random{$rand_num}) {
	$Random{$rand_num} = 1;
	push(@Random, $rand_num);
    }
    $iter++;
}

my $l=0;
my $counter = 1;
my $print_flag = 0;
open(IN,"<$fastq1") || die "\n Cannot open the file: $fastq1\n";
while(<IN>) {
    chomp;
    if ($l == 0) {
	if (exists $Random{$counter}) {
	    print STDOUT $_ . "\n";
	    $print_flag = 1;
	}
	$counter++;
    }
    elsif ($l == 1) {
	if ($print_flag == 1) {
	    print STDOUT $_ . "\n+\n";
	}
    }
    elsif ($l == 3) {
	if ($print_flag == 1) {
	    $print_flag = 0;
	    print STDOUT $_ . "\n";
	}
	$l = -1;
    }
    $l++;
}
close(IN);

$l = 0;
$counter = 1;
open(IN,"<$fastq2") || die "\n CAnnot open the file: $fastq2\n";
while(<IN>) {
    chomp;
    if ($l == 0) {
	if (exists $Random{$counter}) {
	    print STDERR $_ . "\n";
	    $print_flag = 1;
	}
	$counter++;
    }
    elsif ($l == 1) {
	if ($print_flag == 1) {
	    print STDERR $_ . "\n+\n";
	}
    }
    elsif ($l == 3) {
	if ($print_flag == 1) {
	    $print_flag = 0;
	    print STDERR $_ . "\n";
	}
	$l = -1;
    }
    $l++;
}
close(IN);

exit 0;
