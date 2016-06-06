use strict;

open(my $input, "<", $ARGV[0]);
open(my $output, ">", "ALL_LTR.fa");
while (defined($_ = <$input>)) {
    @_ = split(",", $_);
    if ($_[18] =~ /NONE/ && $_[21] =~ /NONE/ && $_[27] =~ /YES/) {
        open(my $fh, "<", "../RAW_SEQ_OUT_DIR_ALL/$_[11].ltrdigest_3ltr.fas");
        while (defined($_ = <$fh>)) {
            if ($_ =~ />/) {
                chomp $_;
	        print $output "$_\_3ltr\n";
	    } else {
                print $output $_;
            }
         }

        open(my $fh, "<", "../RAW_SEQ_OUT_DIR_ALL/$_[11].ltrdigest_5ltr.fas");
        while (defined($_ = <$fh>)) {
            if ($_ =~ />/) {
	         chomp $_;
                 print $output "$_\_5ltr\n";
            } else {						
                print $output $_;
            }
        }
    }
}

