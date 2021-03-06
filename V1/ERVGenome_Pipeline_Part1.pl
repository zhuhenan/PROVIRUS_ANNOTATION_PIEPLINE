#!/usr/bin/perl -w
 
format HEADER =
/ ------------------------------------------------------------------------------------------------------------------
| Purpose : This is pipeine for analysis DIGS output. It will:
|           (1) extract RT sequences and their flanking region (10,000 5' ~ 3' 10,000)
|           (2) detect proviral genes using LTR_Harcest & LTR_Digest
|           (3) find more LTRs
|           (4) calculate the time of intergate based on LTR alignment
| 
|  Options:
|    -v    verbose mode
|    -h    Give help screen
|    -f    Control file
|  
|  Example:
|    ERVGenome_Pipeline.pl -f <DIGS_resultset>.csv
\ ------------------------------------------------------------------------------------------------------------------
.

use strict;
use warnings;

# ------------------------------------------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------------------------------------------
# Import local tool library
use Getopt::Long;
use Pod::Usage;
use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin, ".", 'src');
use Toolboxs;
use Analysis;

# ------------------------------------------------------------------------------------------------------------------
# Main functions
# ------------------------------------------------------------------------------------------------------------------

# Initialization - read files
my ($ctl, $tools, $analysis, $embl) = &Initialization();

# Step 1 : read the DIGS screening result set & extract RT and (RT + flanking region) sequences
$analysis->step1_read_DIGS_result($tools, $ctl);

# Step 2 : use LTR_Harvest & LTR_Digest to detect proviral gene
$analysis->step2_gt_ltrharvest_ltrdigest($tools, $ctl);

#
&quit(0);
 
# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Initialization - test system & catch the command line input & set output file parameters 
# ------------------------------------------------------------------------------------------------------------------
sub Initialization {
	
	# Initialization
    my ($opt_h, $tools, $ctl, $ctlFile, $verbose);
	
	# Get the input parameters from command line
    GetOptions ("h"    => \$opt_h,
                "v"    => \$verbose,
                "f=s"  => \$ctlFile
    );
	
    # Call help screen or do the analysis 
    if (defined $opt_h) {
	    &do_help;
    } else {
	    $tools    = Toolboxs->new();
		$analysis = Analysis->new();
    }
	
	# Read the control file
	$ctl = $tools->ctl_reader($ctlFile);
	# System test
	$tools->test_system($ctl);
	
	# Read & store the Repbase reference sequence library
    #$tools->embl_reader($ctl);
	#$tools->create_Repbase_LTR_fasta_lib($ctl);
	
	# Make blast database based on the Repbase library
	my $fasta = $ctl->get_one_tag("REPMASKER_LTR_LIBRARY_FILE");
	system "makeblastdb -dbtype nucl -in ".$fasta." -out ".$fasta." -input_type fasta -parse_seqids -hash_index";
	# Call help screen out and exit or continue
    &do_help if (defined $opt_h);
	
	# Return address
	return ($ctl, $tools, $analysis, $embl);
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Give help Screen and exit 
# ------------------------------------------------------------------------------------------------------------------
sub do_help {
    $~ = "HEADER";
    write;
    exit;
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Clean up our mess and exit 
# ------------------------------------------------------------------------------------------------------------------
sub quit {
    my ($retcode) = @_;
    exit($retcode);
}