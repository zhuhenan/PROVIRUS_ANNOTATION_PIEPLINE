package LTRGroup;

#
# History
# -------
# Henan Zhu     29/02/2016     create it - Version 1
 
use strict;
use warnings;

# ------------------------------------------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------------------------------------------
use List::MoreUtils qw(uniq);

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Initialization - builder 
# ------------------------------------------------------------------------------------------------------------------
sub new {
	
	# Initialization
    my $class = shift;
    my $self = {
		rowArray     => [@_],
		repNameList  => [@_],
		repClassList => [@_],
		start        => -10000,
		end          => -10000,
	};
	
	# Return reference
    return bless $self, $class;
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Add a new row into this group
# ------------------------------------------------------------------------------------------------------------------
sub add_new_row {
	
	# Initialization
    my ($self, $ref) = @_;

	#
	if (scalar @{$self->{rowArray}} == 0) {
        $self->initialization($ref);
    } else {
	    #
	    push(@{$self->{rowArray}}, $ref);
	    #
	    push(@{$self->{repNameList}},  $ref->{'repName'});
	    push(@{$self->{repClassList}}, $ref->{'repClass'});
	    #
	    if ($self->{start} > $ref->{'genoStart'}) { $self->{start} = $ref->{'genoStart'} }
	    if ($self->{end}   < $ref->{'genoEnd'})   { $self->{end}   = $ref->{'genoEnd'} }
	}
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Add a new row into this group
# ------------------------------------------------------------------------------------------------------------------
sub initialization {
	
	# Initialization
    my ($self, $ref) = @_;
	
	#
	@{$self->{rowArray}}     = ();
	@{$self->{repNameList}}  = ();
	@{$self->{repClassList}} = ();
	
	#
	push(@{$self->{rowArray}},     $ref);
    push(@{$self->{repNameList}},  $ref->{'repName'});
    push(@{$self->{repClassList}}, $ref->{'repClass'});
	#
	$self->{start}  = $ref->{'genoStart'};
	$self->{end}    = $ref->{'genoEnd'};
	$self->{single} = "single";
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Format current group & return keep or delete signal
# ------------------------------------------------------------------------------------------------------------------
sub format_LTR_group {
	
	# Initialization
	my $self = shift;
	
	# Clean duplicate elements from array
	@{$self->{repNameList}}  = uniq(@{$self->{repNameList}});
	@{$self->{repClassList}} = uniq(@{$self->{repClassList}});
	
	# if there is no LTRs in the current group, return 0
	if (!scalar grep {$_ =~ /LTR/i} @{$self->{repClassList}}) { return 0; }
	
	# if the size of LTR group is less than 150 bp, ignore
	if ($self->{end} - $self->{start} < 150) { return 0; }

	# Set LTR group stage
	if (scalar @{$self->{repNameList}} == 1) { $self->{single} = "single"; }
	else { $self->{single} = "multiple"; }
    
	#
	return 1;
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Format current group & return keep or delete signal
# ------------------------------------------------------------------------------------------------------------------
sub group_multiple_to_single {
	
	# Initialization
	my $self = shift;
	
	#
	my @sortRef = ();
	if (scalar @{$self->{repNameList}} <= 3) {
        $self->find_best_hit();
		return 1;
    } else {
		return 0;
	}
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Find the hit with highest swScore in the given LTR group
# Reset the LTR group using this 
# ------------------------------------------------------------------------------------------------------------------
sub find_best_hit {
	
	# Initialization
	my $self = shift;
	
	#
	my $bestRef = shift $self->{rowArray};
	foreach my $candidate (@{$self->{rowArray}}) {
		#
		my $candidata_l = $candidate->{'genoEnd'} - $candidate->{'genoStart'};
		my $bestRef_l   = $bestRef->{'genoEnd'}   - $bestRef->{'genoStart'};
		#
		if ($candidata_l > $bestRef_l) {
			$bestRef = $candidate;
		} elsif ($candidata_l == $bestRef_l && $bestRef->{'milliDiv'} < $candidate->{'milliDiv'}) {
			$bestRef = $candidate;
		}
	}
	
	#
	$self->initialization($bestRef);
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Return values
# ------------------------------------------------------------------------------------------------------------------
#
sub get_all_rep_classes {
	
	# Initialization
	my $self = shift;
	
	# Return value
	return $self->{repClassList};
}

#
sub get_all_rep_names {
	
	# Initialization
	my $self = shift;
	
	# Return value
	return $self->{repNameList};
}

#
sub get_LTR_group_stage {
	
	# Initialization
	my $self = shift;
	
	# Return value
	return $self->{single};
}

#
sub get_LTR_group_hit_num {
	
	# Initialization
	my $self = shift;
	
	# Return value
	return scalar @{$self->{repNameList}};
}

#
sub extract_LTR_info {
	
	# Initialization
	my $self = shift;
	
	#
	my $start  = $self->{start};
	my $end    = $self->{end};
	my $label  = $self->{repNameList}->[0];
	my $class  = $self->{repClassList}->[0];
	my $strand = "";
	
	#
	if (scalar @{$self->{rowArray}} == 1) {
		#
        $strand = $self->{rowArray}->[0]->{'strand'};
    } else {
		#
		my @allStrand = ();
		foreach (@{$self->{rowArray}}) { push(@allStrand, $_->{'strand'}); }
		@allStrand = uniq(@allStrand);
		#
		if (scalar @allStrand == 1) { $strand = $allStrand[0]; }
		else { return 0; }
	}
	
	#
	return ($label, $start, $end, $strand, $class);
}

1;