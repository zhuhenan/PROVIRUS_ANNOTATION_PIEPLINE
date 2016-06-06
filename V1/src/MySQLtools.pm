package MySQLtools;

#
# History
# -------
# Henan Zhu     29/02/2016     create it - Version 1
 
use strict;
use warnings;

# ------------------------------------------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------------------------------------------
use Ctl;

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
# Build the connection to the database that user specific
# ------------------------------------------------------------------------------------------------------------------
sub mysql_connection_UCSC {
	
	# Initialization
	my ($self, $ctl, $tools) = @_;
	
	# Connect to the database
	$self->{dbh_ucsc} = DBI->connect(
		"DBI:mysql:database=".$ctl->get_mysql_UCSC_database_name().";host=".$ctl->get_mysql_database_host(),
		$ctl->get_mysql_username(),
	    $ctl->get_mysql_password(),
		{RaiseError => 1}
	) or die $tools->signal_step_message(13);
	
	# Send signal message
	$tools->signal_step_message(6);
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Build the connection to the database that user specific
# ------------------------------------------------------------------------------------------------------------------
sub mysql_connection_DIGS {
	
	# Initialization
	my ($self, $ctl, $tools) = @_;
	
	# Connect to the database
	$self->{dbh_digs} = DBI->connect(
		"DBI:mysql:database=".$ctl->get_mysql_DIGS_database_name().";host=".$ctl->get_mysql_database_host(),
		$ctl->get_mysql_username(),
	    $ctl->get_mysql_password(),
		{RaiseError => 1}
	) or die $tools->signal_step_message(13);
	
	# Send signal message
	$tools->signal_step_message(6);
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Disconnect the database
# ------------------------------------------------------------------------------------------------------------------

sub mysql_disconnect {
	
	# Initialization
	my $self = shift;
	
	# Disconnect the database
	$self->{dbh_ucsc}->disconnect();
	$self->{dbh_digs}->disconnect();
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# MySQL tool box
# ------------------------------------------------------------------------------------------------------------------
# Return all table names
sub mysql_get_all_UCSC_table_names {
	
	# Initialization
	my $self       = shift;
	my @tableNames = ();
	
	# Show all talbe names in the database
	# Prepare the MySQL commands
	my $sth = $self->{dbh}->prepare("SHOW TABLES");
	# Retrieve data from the table
	$sth->execute();
	while (my $ref = $sth->fetchrow_hashref()) {
        push(@tableNames, $ref->{'Tables_in_ucsc_repeatmasker'});
    }
	$sth->finish();
	
	# Return table names array;
	return (\@tableNames, $sth->rows);
}

# Return all rows in the given table
sub mysql_get_all_rows_from_UCSC_table {
	
	# Initialization
	my ($self, $tableName) = @_;
	my @rows = ();
	
	# Show all talbe names in the database
	# Prepare the MySQL commands
	my $sth = $self->{dbh_ucsc}->prepare("SELECT * FROM $tableName");
	# Retrieve data from the table
	$sth->execute();
	while (my $ref = $sth->fetchrow_hashref()) {
        push(@rows, $ref);
    }
	$sth->finish();
	
	# Return table names array;
	return (\@rows, $sth->rows);
}

# Return all rows in the given table
sub mysql_get_all_rows_from_DIGS_table {
	
	# Initialization
	my ($self, $chr) = @_;
	my @rows = ();
	
	# Show all talbe names in the database
	# Prepare the MySQL commands
	my $sql = "SELECT Mismatches as 'milliDiv', Extract_start as 'genoStart', ".
	          "Extract_end as 'genoEnd', Scaffold as 'genoName', Orientation as 'strand', ".
			  "Assigned_name as 'repName', Assigned_gene as 'repClass', ".
			  "Subject_start as 'repStart', Subject_end as 'repEnd'".
	          " FROM Extracted where Scaffold = \"$chr\"";
	my $sth = $self->{dbh_digs}->prepare($sql);
	# Retrieve data from the table
	$sth->execute();
	while (my $ref = $sth->fetchrow_hashref()) {
        push(@rows, $ref);
    }
	$sth->finish();
	
	# Return table names array;
	return (\@rows, $sth->rows);
}

1;