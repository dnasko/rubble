#!/usr/bin/perl -w

# MANUAL FOR rubble.pl

=pod

=head1 NAME

rubble.pl -- runs the RUBBLE protein BLAST pipeline

=head1 SYNOPSIS

 rubble.pl --query /Path/to/input.fasta --db /Path/to/database --dbClust /Path/to/clustered_database --lookup /Path/to/db.lookup --out /Path/to/out.btab --evalue 1e-3 --threads 1
                    [--grid] [--help] [--manual] [--debug]

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

Threads

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
use Threads;

## ARGUMENTS WITH NO DEFAULT
my($query,$db,$dbClust,$lookup,$out,$grid,$help,$manual,$debug);
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
				"m|manual"	=>	\$manual,
                                "b|debug"       =>      \$debug);

# VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
pod2usage( -msg  => "\n\n ERROR!  Required argument --query not found.\n\n", -exitval => 2, -verbose => 1)   if (! $query);
pod2usage( -msg  => "\n\n ERROR!  Required argument --db not found.\n\n", -exitval => 2, -verbose => 1)      if (! $db);
pod2usage( -msg  => "\n\n ERROR!  Required argument --dbClust not found.\n\n", -exitval => 2, -verbose => 1) if (! $dbClust);
pod2usage( -msg  => "\n\n ERROR!  Required argument --lookup not found.\n\n", -exitval => 2, -verbose => 1)  if (! $lookup);
pod2usage( -msg  => "\n\n ERROR!  Required argument --out not found.\n\n", -exitval => 2, -verbose => 1)     if (! $out);
$threads = int($threads);
if ($threads < 1) { die "\n Error! --threads needs to be >0 and a whole number.\n";}

if ($grid ) { print "\n Warning: The --grid option is not working yet.\n"; }

## Checking that blastp is installed.
my $BLASTP = `which blastp`;
unless ($BLASTP =~ m/blastp/) { die "\n ERROR: NCBI's blastp is not installed, or not located in your PATH. Please install it and put it in your PATH (ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/)\n"; }
my $BLASTDBCMD = `which blastdbcmd`;
unless ($BLASTDBCMD =~ m/blastdbcmd/) { die "\n ERROR: blastdbcmd is not installed or in your PATH. It's a part of NCBI's blast package.\n"; }

## Create a temporary working directory that will be removed after we're done.
my @chars = ("A".."Z", "a".."z");
my $rand_string;
$rand_string .= $chars[rand @chars] for 1..8;
my $working_dir = "rubble_working_" . $rand_string;
print `mkdir -p $working_dir`;
print `mkdir -p $working_dir/0-blast_clust`;
print `mkdir -p $working_dir/1-cull`;
print `mkdir -p $working_dir/2-restrict`;
print `mkdir -p $working_dir/3-blast_final`;

## Initial BLAST against clustered BLAST DB.
if ($threads == 1) {
    my $blast_exe = "blastp -query " . $query .	" -db " . $dbClust . " -out " . $working_dir . "/0-blast_clust/out.btab" . " -evalue " . $evalue . " -outfmt 6";
    print `$blast_exe`;
}
else { para_blastp($query, $dbClust, $working_dir . "/0-blast_clust/out.btab", $evalue, $threads); }

## Cull the query sequences that have a hit.


## Create the restriction list for the final BLAST. Also, figure out how large the final BLAST db is...
# blastdbcmd -db MGOL_DEC2014 -info

## Final BLAST using the restriction list.


## Cleaning up.
unless ($debug && -d $working_dir) {
    print `rm -rf $working_dir`;
}

sub para_blastp
{
    my $q = $_[0];
    my $d = $_[1];
    my $o = $_[2];
    my $e = $_[3];
    my $t = $_[4];
    my @THREADS;
    print `mkdir -p $working_dir/0-blast_clust/para_blastp`;
    my $seqs=count_seqs($q);
    my $seqs_per_thread = seqs_per_thread($seqs, $threads);
    split_multifasta($q, "$working_dir/0-blast_clust/para_blastp", "split", $seqs_per_thread);
    for (my $i=1; $i<=$t; $i++) {
	my $blast_exe = "blastp -query $working_dir/0-blast_clust/para_blastp/split-$i.fsa -db $dbClust -out $working_dir/0-blast_clust/para_blastp/$i.btab -outfmt 6 -evalue $evalue";
	push (@THREADS, threads->create('task',"$blast_exe"));
    }
    foreach my $thread (@THREADS) {
	$thread->join();
    }
    
}
sub split_multifasta
{
    my $q       = $_[0];
    my $working = $_[1];
    my $prefix  = $_[2];
    my $spt     = $_[3];
    my $j=0;
    my $fileNumber=1;
    open(IN,"<$q") || die "\n Cannot open the file: $q\n";
    open (OUT, "> $working/$prefix-$fileNumber.fsa") or die "Error! Cannot create output file: $working/$prefix-$fileNumber.fsa\n";
    while(<IN>) {
	chomp;
	if ($_ =~ /^>/) { $j++; }
	if ($j > $spt) { #if time for new output file
	    close(OUT);
	    $fileNumber++;
	    open (OUT, "> $working/$prefix-$fileNumber.fsa") or die "Error! Cannot create output file: $working/$prefix-$fileNumber.fsa\n";
	    $j=1;
	}
	print OUT $_ . "\n";
    }
    close(IN);
    close(OUT);
}
sub seqs_per_thread
{
    my $s = $_[0];
    my $t = $_[1];
    my $seqs_per_file = $s / $t;
    if ($seqs_per_file =~ m/\./) {
	$seqs_per_file =~ s/\..*//;
	$seqs_per_file++;
    }
    return $seqs_per_file;
}
sub count_seqs
{
    my $f = $_[0];
    my $s = 0;
    open(IN,"<$f") || die "\n Cannot open the file: $f\n";
    while(<IN>) {
	chomp;
	if ($_ =~ m/^>/) { $s++; }
    }
    close(IN);
    return $s;
}
sub task
{
    system( @_ );
}
exit 0;
