use strict;

my %hash;
open(my $input, "<", $ARGV[0]);
while (defined($_ = <$input>)) {
	if ($_ =~ /taxlabels/) {
		do {
			$_ = <$input>;
			s/\n|'| |\t//g;
			$hash{"$_.fna"} ++;
		} while ($_ !~ /;/);
	}
}

open($input, "<", $ARGV[1]);
open(my $output, ">", "TreeMarker.csv");
while (defined($_ = <$input>)) {
	#
	chomp $_;
	@_ = split(",", $_);
	#
	for (my $i = 0; $i <= 27; $i ++) {
		print $output $_[$i],",";
	}
	#
	if (exists($hash{$_[10]})) {
		print $output "YES,";
	} else {
		print $output "NO,";
	}
	#
	for (my $i = 28; $i < @_; $i ++) {
		print $output $_[$i],",";
	}
	print $output "\n";
}


