use strict;

my ($input, $output, %hash);

open($input, "<", $ARGV[0]);
while (defined($_ = <$input>)) {
	@_ = split(",", $_);
	$hash{"$_[1]_$_[2]_$_[3]"} = $_[28];
}

open($input, "<", $ARGV[1]);
open($output, ">", "RplotMarker.csv");
$_ = <$input>;
chomp $_;
print $output $_,",TREEMARKER\n";
while (defined($_ = <$input>)) {
	chomp $_;
	@_ = split(",", $_);
	if (exists($hash{"$_[7]_$_[8]_$_[9]"})) {
		print $output $_,",",$hash{"$_[7]_$_[8]_$_[9]"},"\n";
	} else {
		print $output $_,",NO\n";
	}
}


