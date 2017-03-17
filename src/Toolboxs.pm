package Toolboxs;

use strict;
use warnings;

# ------------------------------------------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------------------------------------------
use Ctl;
use Cwd;
use DBI;
use Test::More;
#use EMBL;

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Initialization - builder 
# ------------------------------------------------------------------------------------------------------------------
sub new {
	
	# Initialization
    my $class = shift;
    my $self = {};
	
	# Return reference
    return bless $self, $class;
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# System testing - test system & make sure the system has all tools
# Currently, pipeline requires: 1. samtools; 2. genometools; 3. ncbi-blast+; 4. exonerate
# ------------------------------------------------------------------------------------------------------------------
# The main test subfunction
sub test_system {

    # Initialization
	my ($self, $ctl) = @_;

    # require Some::Module
    require_ok('Text::CSV_XS'    );
	require_ok('Time::Progress'  );
	require_ok('List::Util'      );
	require_ok('List::MoreUtils' );
	
	# require some external program
    unlike(test_samtools(),         qr/not found/, "samtools"    );
	unlike(test_genometools(),      qr/not found/, "genometools" );
	unlike(test_exonerate(),        qr/not found/, "exonerate"   );
	unlike(test_ncbi_makeblastdb(), qr/not found/, "makeblastdb" );
	unlike(test_ncbi_tblastn(),     qr/not found/, "blastn"      );
	
	# require some reference database
	isnt($ctl->get_one_tag("REFERENCE_GENOME_DIR"),       0, "Reference genome folder");
	isnt($ctl->get_one_tag("DIGS_RESULT_SET_CSV"),        0, "DIGS screening result"  );
	isnt($ctl->get_one_tag("REPMASKER_LTR_LIBRARY_FILE"), 0, "RepMasker library"      );
	isnt($ctl->get_one_tag("TRNA_LIB"),                   0, "tRNA library"           );
	isnt($ctl->get_one_tag("HMMS_PROFILE"),               0, "Pfam hmm profile"       );
	
	# Done
	done_testing();
}

# test subfunction: samtools, genometools, exonerate, ncbi-blast+
sub test_samtools         { return `which samtools`    ; }
sub test_genometools      { return `which gt`          ; }
sub test_exonerate        { return `which exonerate`   ; }
sub test_ncbi_makeblastdb { return `which makeblastdb` ; }
sub test_ncbi_tblastn     { return `which tblastn`     ; }
#
# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Signal System - system test signal & working stage single & error message
# ------------------------------------------------------------------------------------------------------------------
# System test signal
sub signal_tools_test_message {
	
	# Initialization
	my ($signal, @tools) = @_;
	my $message = "";
	
	# Format the return message
	for (my $i = 0; $i < @tools; $i += 2) {
		$message .= sprintf("%-20s%-10s\n", $tools[$i], $tools[$i+1]);
	}
	
	# signal check & return message
	return $message;
}

# working stage single & error message
# working stage 1 - 9
# error message 10 - 19
sub signal_step_message {
	
	# Initialization
	my ($signal, $stage) = @_;
	my $message = "";
	
	# Return signal message
	if    ($stage == 1)  { print "\nProgress : making raw sequence output folder\n"; }
	elsif ($stage == 2)  { print "\nProgress : processing DIGS result set & extracted sequences\n"; }
	elsif ($stage == 3)  { print "\nProgress : processing read step1 summary & confrim provirus genes\n"; }
	elsif ($stage == 4)  { print "\nProgress : Read control file\n"; }
	elsif ($stage == 5)  { print "\nProgress : Build Repbase EMBL reference sequence database for BLAST\n"; }
	elsif ($stage == 6)  { print "\nProgress : MySQL database connected\n"; }
	elsif ($stage == 7)  { print "\nProgress : Build LTR target list\n"; }
	elsif ($stage == 8)  { print "\nProgress : Build gluetool project for UCSC"; }
	elsif ($stage == 9)  { print "\nProgress : Build gluetool project for DIGS"; }
	elsif ($stage == 10) { print "\nERROR : DIGS results set file doesn't exist\n"; }
	elsif ($stage == 11) { print "\nERROR : Pipeline cannot find control file\n"; }
	elsif ($stage == 12) { print "\nERROR : Pipeline cannot find Repbase reference sequence library\n"; }
	elsif ($stage == 13) { $DBI::errstr }
	elsif ($stage == 14) { print "\nERROR : Provirus table doesn't exists\n";}
	else                 { print "\nERROR : Unknown single"; }
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# File reader - tools for reading control file and Repbase ref EMBL file
# ------------------------------------------------------------------------------------------------------------------
# Control file reader - read and store the control file & return address
sub ctl_reader {
	
	# Initialization
	my ($self, $ctlFile) = @_;
	
	# create a new address for control file
	my $ctl = Ctl->new();
	
	# Open control file & set all parameters
	open(my $input, "<", $ctlFile) or die $self->signal_step_message(11);
	while (defined($_ = <$input>)) {
		chomp $_;
		# skip blank & commented lines when reading a file 
		next if /^(\s*(#.*)?)?$/;
		# Read one parameter setting & set it as input value
		s/ +//g;
		@_ = split("=", $_);
		$ctl->add_parameters($_[0], $_[1]);
	}
	
	# Set default valure for empty parametrs
	# If this setting is empty, pipeline will use "RAW_SEQ_OUT_DIR" as default folder name
	if (!defined($ctl->get_one_tag("RAW_SEQ_OUT_DIR"))) {
		$ctl->add_parameters("RAW_SEQ_OUT_DIR", "RAW_SEQ_OUT_DIR_ALL");
	}
	
	# Return address
	$self->signal_step_message(4);
	return $ctl;
}

1;