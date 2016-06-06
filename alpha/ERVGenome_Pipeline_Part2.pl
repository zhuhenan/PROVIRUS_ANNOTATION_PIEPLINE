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
|    ERVGenome_Pipeline_part2.pl -f <control file>
\ ------------------------------------------------------------------------------------------------------------------
.
 
#
# History
# -------
# Henan Zhu     29/02/2016     create it - Version 1

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
use MySQLtools;

# ------------------------------------------------------------------------------------------------------------------
# Main functions
# ------------------------------------------------------------------------------------------------------------------

# Initialization - read files
my ($ctl, $tools, $analysis, $mysql) = &Initialization();

# Begin to process LTRs
#$analysis->step3_summarize_LTRs($ctl, $tools, $mysql);

# Build GLUEtool project and align all LTR sequences
$analysis->step4_build_gluetoo_projects($ctl, $tools);

#
&quit(0);
 
# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Initialization - test system & catch the command line input & set output file parameters 
# ------------------------------------------------------------------------------------------------------------------
sub Initialization {
	
	# Initialization
    my ($opt_h, $tools, $ctl, $ctlFile, $dbh, $mysql, $verbose);
	
	# Get the input parameters from command line
    GetOptions ("h"    => \$opt_h,
                "v"    => \$verbose,
                "f=s"  => \$ctlFile
    );
	
    # Call help screen or do the analysis 
    if (defined $opt_h) {
	    &do_help;
    } else {
	    $tools    = Toolboxs  ->new();
		$analysis = Analysis  ->new();
		$mysql    = MySQLtools->new();
    }
	
    # System test
	$tools->test_system();
	
	# Read the control file
	$ctl = $tools->ctl_reader($ctlFile);

	# Connect to the database
	$mysql->mysql_connection_UCSC($ctl, $tools);
	$mysql->mysql_connection_DIGS($ctl, $tools);
	
	# Call help screen out and exit or continue
    &do_help if (defined $opt_h);
	
	# Return address
	return ($ctl, $tools, $analysis, $mysql);
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