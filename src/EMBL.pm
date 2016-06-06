package EMBL;

#
# History
# -------
# Henan Zhu     17/02/2016     create it - Version 1
 
use strict;
use warnings;

# ------------------------------------------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------------------------------------------
use List::Util 'first';

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Initialization - builder 
# ------------------------------------------------------------------------------------------------------------------
sub new {
	
	# Initialization
    my ($class, $args) = @_;
    my $self = {
        EMBL => $args->{EMBL},
    };
	
	# Return reference
    return bless $self, $class;
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Extract the Repbase reference from EMBL format record 
# ------------------------------------------------------------------------------------------------------------------
sub process_ref {
	
	# Initialization
	my $self = shift;
	
	# Get the original EMBL record
	my @lines = grep /\S/, split("\n", $self->get_EMBL_reocrd());
	
	# Get the ID line
	@_ = split(" +", first { /ID +/ } @lines);
	$self->{ID}     = $_[1];
	$self->{SOURCE} = $_[2];
	
	# Get the ORGANISM line
	$_ = first { /OS +/ } @lines;
	s/\n|OS   //g;
	$self->{OS} = $_;
	
	# Get the DESCRIPTION line and decide the type as "LTR" or "Internal region" or others
	$_ = join("\n", grep { /DE +/ } @lines);
	if ($_ =~ /internal/) {
		$self->{TYPE} = "internal";
	} elsif ($_ =~ /long|long terminal repeat|LTR/) {
		$self->{TYPE} = "LTR";
	} else {
		$self->{TYPE} = "unknown";
	}

	# Get the consensus sequences
	my ($sequence, $SQ);
	my $i = 0;
	while ($i < @lines) {
		if ($lines[$i] =~ /SQ +/) {
			$SQ = $lines[$i];
			do {
				$i ++;
				$_ = $lines[$i];
				s/(\d+)| +//g;
				$sequence .= $_;
			} until ($i == @lines - 1);
		} else {
			$i ++;
		}
	}
	# Store sequence
	$self->{SQ} = $sequence;
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Tools - return values
# ------------------------------------------------------------------------------------------------------------------
# Return the original EMBL record
# tag "EMBL"
sub get_EMBL_reocrd {
	
	# Initialization
	my $self = shift;
	
	# return value
    return $self->{EMBL};
}

# Return the type of seuqence
# tag "type"
sub get_ref_type {
	
	# Initialization
	my $self = shift;
	
	# return value
    return $self->{TYPE};
}

# Return the consensus sequence
# tag "SQ"
sub get_ref_seq {
	
	# Initialization
	my $self = shift;
	
	# return value
    return $self->{SQ};
}

# Return the record ID
# tag "ID"
sub get_ref_ID {
	
	# Initialization
	my $self = shift;
	
	# return value
    return $self->{ID};
}

1;