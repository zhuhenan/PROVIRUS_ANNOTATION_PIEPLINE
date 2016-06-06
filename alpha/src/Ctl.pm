package Ctl;

#
# History
# -------
# Henan Zhu     11/02/2016     create it - Version 1
# Henan Zhu     17/02/2016     add more tags
 
use strict;
use warnings;

# ------------------------------------------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Initialization - catch the pipeline control file 
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
# Tools - get values
# ------------------------------------------------------------------------------------------------------------------
# Store the step summary file pathway
sub add_step_summary {
	
	# Initialization
	my ($self, $step, $value) = @_;
	
	# Return value
	$self->{"step$step\_summary"} = $value;
}

# Update the parameter according to the input tag and values
sub add_parameters {
	
	# Initialization
	my ($self, $tag, $value) = @_;
	
	# add value
	$self->{$tag} = $value;
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Tools - return values
# ------------------------------------------------------------------------------------------------------------------
# Debug function
# Return all tag labels
sub get_all_tags {
	
	# Initialization
	my $self = shift;
	# Return value
	return keys %{$self};
}

# Return the parameter stored in tag
sub get_one_tag {
	
	# Initialization
	my $self = shift;
	my $tag  = shift;
	# Return value
	if   (exists($self->{$tag})) { return $self->{$tag}; }
	else { return 0; }
}

# Return raw sequence output folder
# tag "RAW_SEQ_OUT_DIR"
sub get_raw_seq_out_dir {
	
	# Initialization
	my $self = shift;
	
	# Return value
	return $self->{RAW_SEQ_OUT_DIR};
}

# Return LTR_Harvest parameter settings
# tag "MINLENLTR"  "MAXLENLTR"  "MINDISTLTR" "MAXDISTLTR"    "SIMILAR" "MINTSD" "MAXTSD"
# tag "PPTLEN_MIN" "PPTLEN_MAX" "TRNA_LIB"   "PBSOFFSET_MIN" "PBSOFFSET_MAX"    "HMMS_PROFILE" "PBSRADIUS"
sub get_ltrharvest_settings {
	
	# Initialization
	my $self = shift;
	
	# Return values
	return ($self->{MINLENLTR},    $self->{MAXLENLTR},  $self->{MINDISTLTR},    $self->{MAXDISTLTR},
			$self->{SIMILAR},      $self->{MINTSD},     $self->{MAXTSD},        $self->{PPTLEN_MIN},
			$self->{PPTLEN_MAX},   $self->{TRNA_LIB},   $self->{PBSOFFSET_MIN}, $self->{PBSOFFSET_MAX},
			$self->{HMMS_PROFILE}, $self->{PBSRADIUS});
}

# Return project name
# tag "USERNAME"
sub get_mysql_username {
	
	# Initialization
	my $self = shift;
	
	# Return value
	return $self->{USERNAME};
}

# Return project name
# tag "PASSWORD"
sub get_mysql_password {
	
	# Initialization
	my $self = shift;
	
	# Return value
	return $self->{PASSWORD};
}

# Return project name
# tag "DATABASE_UCSC"
sub get_mysql_UCSC_database_name {
	
	# Initialization
	my $self = shift;
	
	# Return value
	return $self->{DATABASE_UCSC};
}

# Return project name
# tag "DATABASE_DIGS"
sub get_mysql_DIGS_database_name {
	
	# Initialization
	my $self = shift;
	
	# Return value
	return $self->{DATABASE_DIGS};
}

# Return project name
# tag "HOST"
sub get_mysql_database_host {
	
	# Initialization
	my $self = shift;
	
	# Return value
	return $self->{HOST};
}

# Return project name
# tag "PORT"
sub get_mysql_database_port {
	
	# Initialization
	my $self = shift;
	
	# Return value
	return $self->{PORT};
}

# Return treemarkder table
# tag "PROVIRUS_CSV"
sub get_treemarker_csv_table {
	
	# Initialization
	my $self = shift;
	
	# Return value
	return $self->{PROVIRUS_CSV};
}

# Return gluetools working space
# tag "GLUETOOLS_PROJECT"
sub get_gluetools_dir {
	
	# Initialization
	my $self = shift;
	
	# Return value
	return $self->{GLUETOOLS_PROJECT};
}

1;