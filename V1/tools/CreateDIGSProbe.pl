use strict;

my ($input, $fh, $output);
#
open($input, "<", $ARGV[0]);
open($output, ">", "DIGS_probe.fa");
#
my $seq_dir = $ARGV[1];
my @records = <$input>;
#
for (my $i = 1; $i < @records; $i ++) {
	@_ = split(",", $records[$i]);
	if ($_[28] =~ /YES/i && $_[18] =~ /NONE/ && $_[21] =~ /NONE/) {
		my $header = "Mammalia_Equus.$_[1].$_[2].$_[3]";
		#
		open($fh, "<", "$seq_dir/$_[11].ltrdigest_3ltr.fas");
		while (defined($_ = <$fh>)) {
			if ($_ =~ />/) {
				print $output ">$header.3ltr_LTR\n";
			} else {
				print $output $_;
			}
		}
		#
		open($fh, "<", "$seq_dir/$_[11].ltrdigest_5ltr.fas");
		while (defined($_ = <$fh>)) {
			if ($_ =~ />/) {
				print $output ">$header.5ltr_LTR\n";
			} else {
				print $output $_;
			}
		}
	}
}