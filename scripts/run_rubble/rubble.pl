#!/usr/bin/perl -w

# MANUAL FOR rubble.pl

=pod

=head1 NAME

rubble.pl -- runs the RUBBLE protein BLAST pipeline

=head1 SYNOPSIS

 rubble.pl --query=/Path/to/input.fasta --db=/Path/to/database --dbClust=/Path/to/clustered_database --lookup=/Path/to/db.lookup --out=/Path/to/out.btab --evalue=1e-3 --max_target_seqs=500  --threads=1
                    [--grid] [--version] [--help] [--manual] [--debug]

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

=item B<-mx, --max_target_seqs>=INT

Maximum number of aligned sequences to keep. (Defualt = 500)

=item B<-t, --threads>=INT

The number of threads to use for the BLAST. (Default = 1)

=item B<-g, --grid>

Use this flag to run your BLAST's on Grid Engine (Not working yet, will soon I hope)

=item B<-v, --version>

Print the RUBBLE version. (Optional)

=item B<-h, --help>

Displays the usage message.  (Optional) 

=item B<-m, --manual>

Displays full manual.  (Optional) 

=item B<-b, --debug>

Debug mode. Will supress the removal of the working directory. (Optional)

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
use threads;

## ARGUMENTS WITH NO DEFAULT
my($query,$db,$dbClust,$lookup,$out,$grid,$help,$manual,$debug,$ver);
## ARG's with defaults
my $evalue = 0.001;
my $threads = 1;
my $max_target_seqs=500;
my $version = "1.0";
GetOptions (	
                                "q|query=s"	=>	\$query,
                                "d|db=s"        =>      \$db,
                                "dc|dbClust=s"  =>      \$dbClust,
                                "l|lookup=s"    =>      \$lookup,
                                "o|out=s"	=>	\$out,
                                "e|evalue=s"    =>      \$evalue,
                                "t|threads=i"   =>      \$threads,
                                "mx|max_target_seqs=i" => \$max_target_seqs,
                                "v|version"     =>      \$ver,
                                "h|help"	=>	\$help,
				"m|manual"	=>	\$manual,
                                "b|debug"       =>      \$debug);

## VALIDATE ARGS
pod2usage(-verbose => 2)  if ($manual);
pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} )  if ($help);
if ($ver) {die "\n RUBBLE version: $version\n\n";}
pod2usage( -msg  => "\n\n ERROR!  Required argument --query not found.\n\n", -exitval => 2, -verbose => 1)   if (! $query);
pod2usage( -msg  => "\n\n ERROR!  Required argument --db not found.\n\n", -exitval => 2, -verbose => 1)      if (! $db);
pod2usage( -msg  => "\n\n ERROR!  Required argument --dbClust not found.\n\n", -exitval => 2, -verbose => 1) if (! $dbClust);
pod2usage( -msg  => "\n\n ERROR!  Required argument --lookup not found.\n\n", -exitval => 2, -verbose => 1)  if (! $lookup);
pod2usage( -msg  => "\n\n ERROR!  Required argument --out not found.\n\n", -exitval => 2, -verbose => 1)     if (! $out);
my $splitby = 4;
$threads = int($threads);
$max_target_seqs = int($max_target_seqs);
if ($threads < 1) { die "\n Error! --threads needs to be >0 and a whole number.\n";}
if ($max_target_seqs < 1) { die "\n Error! --max_target_seqs needs to be >0 and a whole number.\n";}

if ($grid ) { print "\n Warning: The --grid option is not working yet.\n"; }

## Checking that blastp is installed
my $BLASTP = `which blastp`;
unless ($BLASTP =~ m/blastp/) { die "\n ERROR: NCBI's blastp is not installed, or not located in your PATH. Please install it and put it in your PATH (ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/)\n"; }
my $BLASTDBCMD = `which blastdbcmd`;
unless ($BLASTDBCMD =~ m/blastdbcmd/) { die "\n ERROR: blastdbcmd is not installed or in your PATH. It's a part of NCBI's blast package.\n"; }

## Create a temporary working directory that will be removed after we're done
my $outdir = dirname($out);
my @chars = ("A".."Z", "a".."z");
my $rand_string;
$rand_string .= $chars[rand @chars] for 1..8;
my $working_dir = $outdir . "/rubble_working_" . $rand_string;
print `mkdir -p $working_dir`;
print `mkdir -p $working_dir/0-blast_clust`;
print `mkdir -p $working_dir/1-cull`;
print `mkdir -p $working_dir/2-restrict`;
print `mkdir -p $working_dir/3-blast_final`;

#################################################
## 1. Initial BLAST against clustered BLAST DB ##
#################################################
if ($threads == 1) {
    my $blast_exe = "blastp -query " . $query .	" -db " . $dbClust . " -out " . $working_dir . "/0-blast_clust/out.btab" . " -evalue " . $evalue . " -outfmt 6" . " -max_target_seqs " . $max_target_seqs . " -task blastp-fast";
    print `$blast_exe`;
}
else { para_blastp($query, $dbClust, "$working_dir/0-blast_clust/", $evalue, $threads, $max_target_seqs, "-task blastp-fast", "6 std ppos"); }

#################################################
## 2. Cull the query sequences that have a hit ##
#################################################
my %QueryCull;
my %SubjectCull;
my $print_flag = 0;
open(IN,"<$working_dir/0-blast_clust/out.btab") || die "\n Cannot open the file: $working_dir/0-blast_clust/out.btab\n";
while(<IN>) {
    chomp;
    my @a = split(/\t/, $_);
    $QueryCull{$a[0]} = 1;
    $SubjectCull{$a[1]} = 1;
}
close(IN);
open(OUT,">$working_dir/1-cull/query_cull.fasta") || die "\n Error: Cannot write to $working_dir/1-cull/query_cull.fasta\n";
open(IN,"<$query") || die "\n Cannot open the file: $query\n";
while(<IN>) {
    chomp;
    if ($_ =~ m/^>/) {
	$print_flag = 0;
	my $h = $_;
	$h =~ s/^>//;
	$h =~ s/ .*//;
	if (exists $QueryCull{$h}) {
	    $print_flag = 1;
	    print OUT $_ . "\n";
	}
    }
    elsif ($print_flag == 1) {
	print OUT $_ . "\n";
    }
}
close(IN);
close(OUT);

#############################################################
## 3.  Create the restriction list for the final BLAST.    ##
##     Also, figure out how large the final BLAST db is... ##
#############################################################
my $residues = `blastdbcmd -db $db -info | grep "total residues"`;
$residues =~ s/ total residues.*//;
$residues =~ s/.* //;
$residues =~ s/,//g;
chomp($residues);
open(IN,"<$lookup") || die "\n Cannot open the file: $lookup\n";
open(OUT,">$working_dir/2-restrict/restrict.txt") || die "\n Cannot write to: $working_dir/2-restrict/restrict.txt\n";
while(<IN>) {
    chomp;
    my @a = split(/\t/, $_);
    if (exists $SubjectCull{$a[0]}) {
	print OUT $a[1] . "\n";
    }
}
close(IN);
close(OUT);

###############################################
## 4. Final BLAST using the restriction list ##
###############################################
my $blast_exe = "blastp -query " . "$working_dir/1-cull/query_cull.fasta" . " -db " . $db . " -out " . $out . " -evalue " . $evalue . " -outfmt \"6 std ppos\"" . " -seqidlist " . "$working_dir/2-restrict/restrict.txt" . " -dbsize " . $residues . " -max_target_seqs " . $max_target_seqs . " -num_threads " . $threads;
print `$blast_exe`;


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
    my $max = $_[5];
    my $pass = $_[6];
    my $outfmt = $_[7];
    my @THREADS;
    print `mkdir -p $o/para_blastp`;
    my %CoreDist = distribute_cores($threads, $splitby);
    my $nfiles = keys %CoreDist;
    my $seqs=count_seqs($q);
    my $seqs_per_thread = seqs_per_thread($seqs, $nfiles);
    $nfiles = split_multifasta($q, "$o/para_blastp", "split", $seqs_per_thread, $t);
    for (my $i=1; $i<=$nfiles; $i++) {
	my $blast_exe = "blastp -query $o/para_blastp/split-$i.fsa -db $d -out $o/para_blastp/$i.btab -outfmt \"$outfmt\" -evalue $evalue -max_target_seqs $max -num_threads $CoreDist{$i} " . $pass;
	push (@THREADS, threads->create('task',"$blast_exe"));
    }
    foreach my $thread (@THREADS) {
	$thread->join();
    }
    print `cat $o/para_blastp/*.btab > $o/out.btab`;
}
sub split_multifasta
{
    my $q       = $_[0];
    my $working = $_[1];
    my $prefix  = $_[2];
    my $spt     = $_[3];
    my $nfiles  = $_[4];
    my $j=0;
    my $fileNumber=1;
    print `mkdir -p $working`;
    open(IN,"<$q") || die "\n Cannot open the file: $q\n";
    open (OUT, "> $working/$prefix-$fileNumber.fsa") or die "Error! Cannot create output file: $working/$prefix-$fileNumber.fsa\n";
    while(<IN>) {
	chomp;
	if ($_ =~ /^>/) { $j++; }
	if ($j > $spt && $fileNumber < $nfiles) { #if time for new output file
	    close(OUT);
	    $fileNumber++;
	    open (OUT, "> $working/$prefix-$fileNumber.fsa") or die "Error! Cannot create output file: $working/$prefix-$fileNumber.fsa\n";
	    $j=1;
	}
	print OUT $_ . "\n";
    }
    close(IN);
    close(OUT);
    return $fileNumber;
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
sub distribute_cores
{
    my $t = $_[0];
    my $by = $_[1];
    my %Hash;
    my $nsplits = calc_splits($t, $by);
    my $file=1;
    for (my $i=1; $i<=$t; $i++){
	$Hash{$file}++;
	if ($file==$nsplits) { $file = 0;}
	$file++;
    }
    return %Hash;
}
sub calc_splits
{
    my $t = $_[0];
    my $by = $_[1];
    my $n = roundup($t/$by);
    return $n;
}
sub roundup {
    my $n = shift;
    return(($n == int($n)) ? $n : int($n + 1))
}
sub task
{
    system( @_ );
}
# VIROME likes: qseqid qlen sseqid salltitles qstart qend sstart send pident ppos score bitscore slen evalue

exit 0;
