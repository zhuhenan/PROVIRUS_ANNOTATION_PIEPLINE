package Analysis;

#
# History
# -------
# Henan Zhu     11/02/2016     create it - Version 1
# Henan Zhu     17/02/2016     1. add new functions: now it can blast LTRs again the Repbase reference
#                              2. delete multiple LTR ceck function & merge it into the main function
#                              - Version 2
 
use strict;
use warnings;
use Exporter qw(import);

# ------------------------------------------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------------------------------------------
use Cwd;
use List::Util 'first';
use Ctl;
use LTRGroup;
use Text::CSV_XS;
use Time::Progress;
use File::Basename;
use Bio::DB::Fasta;

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
# Processing data step 1 - read the DIGS screening result set
# 1. make a output folder for raw sequences
# 2. read the DIGS result set
# 3. for each result, extract RT and (RT + flanking region), and then store it in one individual file
# 4. for each result, store any asscoiated information into step1_summary.csv
# 5. return step1_summary.csv
# ------------------------------------------------------------------------------------------------------------------
sub step1_read_DIGS_result {
	
	# Check current working space & make output folder
	my $cwd = &cwd();
	
	# Initialization
	my ($self, $tools, $ctl) = @_;
	my $DIGS       = $ctl->get_one_tag("DIGS_RESULT_SET_CSV");
	my $project    = $ctl->get_one_tag("PROJECT_NAME");
	my $output_dir = $ctl->get_one_tag("RAW_SEQ_OUT_DIR");
	
	# If the folder exists, pipeline will overwrite the old one 
	# create a new one
	&build_folder("$cwd/$output_dir");
	$tools->signal_step_message(1);
	
	# Skip header line of DIGS csv & print header line of RT summary
	$tools->signal_step_message(2);
	
	## Process DIGS result set
	my $csv = Text::CSV_XS->new ({ binary => 1, auto_diag => 1 });
	# Open the DIGS result set & process record
	open(my $input, "<", $DIGS) or die $tools->signal_step_message(10);
	open(my $output, ">", "$cwd/$project.step1_RT_summary.csv");
	
	# Make new csv output file header
	my @header = ("HOST","CHR","RT_START","RT_END","5-FLANKING","3-FLANKING","STRAND","ASSIGNED_GENE","BIT_SCORE","IDENTITY","RT_FILE","FLANKING_FILE");
	push(my @rows, \@header);
	
	# Retrieve the first line as the column names
	$csv->header($input);
	# Retrieve all other line and process in turn
	while (my $row = $csv->getline($input)) {
        push(@rows, step1_process_extract_seq($ctl, $row));
    }
    
	# Store step 1 summary file into ctl class
	# Print step 1 summary
	$ctl->add_parameters("step1_summary", "$cwd/$project.step1_RT_summary.csv");
	$csv->say($output, $_) for @rows;
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Processing data step 1 - extract RT and (RT + flanking region) sequences
# DIGS result set csv format:
#     [2]  Organism    [5]  Target_name     [7]  Scaffold      [8]  Extract_start    [9]  Extract_end
#     [11] Sequence    [12] Assigned_name   [14] Orientation   [15] Bit_score        [16] Identity 
# Output fasta file name format :
#     {chr}_{start}_{end}_{host}_{RT|genome}.fna
# Output fasta file header format :
#    >{chr}_{start}_{end}_{RT|genome}
# Return csv line format  :
#     {HOST},{CHR},{RT_START},{RT_END},{5-FLANKING},{3-FLANKING},{STRAND},
#     {ASSIGNED_GENE},{BIT_SCORE},{IDENTITY},{RT_FILE},{FLANKING_FILE}
# ------------------------------------------------------------------------------------------------------------------
sub step1_process_extract_seq {
	
	# Initialization
	my ($ctl, $row) = @_;
	my ($fh, $output_RT, $output_flanking, $header);
	my $output_dir = $ctl->get_one_tag("RAW_SEQ_OUT_DIR");
	
	my @return_row = ();
	# Split line into samll elements & calculate flanking region
	# Store RT info into return line
	push(@return_row, ($row->[2],$row->[7],$row->[8],$row->[9]));
	# Calculate flanking region & store info into return line
	# 10,000 5' ~ 3' 10,000
	if ($row->[8] - 10000 < 0) {
		push(@return_row, (0,($row->[9]+10000)));
	} else {
		push(@return_row, (($row->[8]-10000),($row->[9]+10000)));
	}
	# Excahnge +/-ve to readable word
	if ($row->[14] =~ /-ve/) { push(@return_row, "negative"); }
    else { push(@return_row, "positive"); }
	# Add assigned gene information into return line
	push(@return_row, ($row->[12],$row->[15],$row->[16]));
	# Extract RT sequence - format the file and header
	$output_RT    = "$row->[2]_$row->[7]_$row->[8]_$row->[9]_RT.fna";
	$header       = ">$row->[2]_$row->[7]_$row->[8]_$row->[9]_RT";
	push(@return_row, $output_RT);
	# Extract RT sequence - print sequence
	open($fh, ">", "$output_dir/$output_RT");
	print $fh "$header\n$row->[11]\n";
	# Extract flanking region sequence - format the file and header
	$output_flanking = "$row->[2]_$row->[7]_$row->[8]_$row->[9]_genome.fna";
	$header          = ">$row->[2]_$row->[7]_$row->[8]_$row->[9]_genome";
	push(@return_row, $output_flanking);
	# Extract flanking region sequence - print sequence
	open($fh, ">", "$output_dir/$output_flanking");
	print $fh "$header\n";
	my $start = 0;
	if ($row->[8] - 10000 > 0) { $start = $row->[8] - 10000; }
	my $end   = $row->[9] + 10000;
	my $scaf  = $ctl->get_one_tag("REFERENCE_GENOME_DIR")."/$row->[2]/$row->[3]/$row->[4]/$row->[5]";
	
	print "samtools faidx $scaf $row->[7]:$start-$end\n";
	@_ = split("\n", `samtools faidx $scaf $row->[7]:$start-$end\n`);
	foreach (@_) { print $fh $_ if $_ !~ />/}

	# Return all summary line
	return \@return_row;
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Processing data step 2 - LTR_Harvest & LTR_Digest
# Read the step1_summary.csv
# ------------------------------------------------------------------------------------------------------------------
sub step2_gt_ltrharvest_ltrdigest {
	
	# Check current working space & make output folder
	my $cwd = &cwd();
	
	# Initialization
	my ($self, $tools, $ctl) = @_;
	my ($fh_summary, $seq, $output, @settings, $dir, $header, $proj, $gff3);
	my (@files, %RT);
	my $step1_summary = $ctl->get_one_tag("step1_summary");
	$tools->signal_step_message(3);
	
	# Debug : check every setting
	my $debug = 0;
	
	# Normal progress
	if ($debug == 0) {
		
		# Get raw sequence output dir & get LTR_Harvest settings & get project name
	    # LTR_Harvest setting return order:
	    #     "MINLENLTR"  -> "MAXLENLTR"  -> "MINDISTLTR" -> "MAXDISTLTR" -> "SIMILAR"       -> "MINTSD"
	    #  -> "MAXTSD"     -> "PPTLEN_MIN" -> "PPTLEN_MAX" -> "TRNA_LIB"   -> "PBSOFFser_MIN" -> "PBSOFFSET_MAX"
	    #  -> "HMMS_PROFILE"
	    $dir      = $ctl->get_one_tag("RAW_SEQ_OUT_DIR");
	    @settings = $ctl->get_ltrharvest_settings();
		$proj     = $ctl->get_one_tag("PROJECT_NAME");
	    # Collect all (RT + flanking region) sequence file
		# Open output csv to contain step2 annotation
	    open($fh_summary, "<", $step1_summary);
		open($output, ">", "$cwd/$proj.step2_provirus.csv");
		# Skip the header line & print new header part to step2 output summary
		$header = <$fh_summary>;
		chomp $header;
		print $output $header, ",REPEAT_S,REPEAT_E,LLTR_S,LLTR_E,RLTR_S,RLTR_E,LLTR_REP_ID,",
		                       "LLTR_REP_SIM,LLTR_REP_SOCRE,RLTR_REP_ID,RLTR_REP_SIM,RLTR_REP_SOCRE,",
							   "PBS_S,PBS_E,PBS_TYPE,RT_S,RT_E,RT_INSIDE,PROT_HITS_NUM,GENES\n";
		
	    # LTR_Harvest & LTR_Digest running & Exonerate check
		while (defined(my $line = <$fh_summary>)) {
		
		    chomp $line;
		
		    # Get the (RT + flanking region) sequence file path
		    my $seq = "$dir/".(split(",", $line))[-1];
			my $rt  = "$dir/".(split(",", $line))[-2];
		
		    # LTR_Harvest & LTR_Digest preparation step 1 : create .gz db file
		    system "gzip -k -1 $seq\n";
		
		    # LTR_Harvest & LTR_Digest preparation step 2 : create index files
		    system "gt suffixerator -tis -suf -lcp -des -ssp -sds -dna -db $seq.gz -indexname $seq";
		
		    # LTR_Harvest : screen given region & make gff3 annotation file
		    system "gt ltrharvest -index $seq -similar $settings[4] -minlenltr $settings[0] -maxlenltr $settings[1]".
		           " -mindistltr $settings[2] -maxdistltr $settings[3] -mintsd $settings[5] -maxtsd $settings[6]".
			       " -gff3 $seq.ltrharvest.gff3 > $seq.ltrharvest.log\n";
			
			# Empty gff3 will not be checked
			if (!-z "$seq.ltrharvest.gff3") {
				
				# LTR_Harvest & LTR_Digest preparation step 2 : sort LTR_Harvest annotation file for LTR_Digest
				system "gt gff3 -sort $seq.ltrharvest.gff3 > $seq.ltrharvest.sort.gff3";
				
				# LTR_Digest : screen given region based on LTR_Harvest annotation file
				system "gt -j 2 ltrdigest -pptlen $settings[7] $settings[8] -trnas $cwd/$settings[9]".
				       " -pbsoffset $settings[10] $settings[11] -pbsradius $settings[13] -hmms $cwd/$settings[12]".
					   " -outfileprefix $seq.ltrdigest $seq.ltrharvest.sort.gff3 $seq > $seq.ltrdigest.gff3";
				
				# exonerate : quick check the location of extracted RT in the flaking region
				system "exonerate $rt $seq > $seq.exonerate";
				
				# blastn : check whether 3'LTR can be found in Repbase
				system "blastn -query $seq.ltrdigest_3ltr.fas -db ".$ctl->get_one_tag("REPMASKER_LTR_LIBRARY_FILE").
				       " -outfmt 7 -max_target_seqs 1".
				       " -out $seq.ltrdigest_3ltr.fas.blast\n";
				# blastn : check whether 5'LTR can be found in Repbase
				system "blastn -query $seq.ltrdigest_5ltr.fas -db ".$ctl->get_one_tag("REPMASKER_LTR_LIBRARY_FILE").
				       " -outfmt 7 -max_target_seqs 1".
				       " -out $seq.ltrdigest_5ltr.fas.blast";
				#
				$gff3 = "$seq.ltrdigest.gff3";
			} else {
				print "$seq => hmmer\n";
				# exonerate : quick check the location of extracted RT in the flaking region
				system "exonerate $rt $seq > $seq.exonerate";
				# Translate the genome sequence using all 6 frame
				system "transeq -frame 6 -sequence $seq -outseq $seq.6frame";
				# Use hmmsearch to search all ERV domains
				system "hmmsearch -o $seq.hmmout --domtblout $seq.domain $cwd/$settings[12] $seq.6frame";
				#
				if (!-z "$seq.domain") {
					#
					&genGFF3($seq, "$seq.domain", "$seq.domain.gff3", $rt);
					#
				    $gff3 = "$seq.domain.gff3";
				}
			}
			
			# Summarise all output files and fulfill the step2 summary file
			my @addons = &step2_summarize_annotation($seq, $gff3, $ctl);
			foreach (@addons) { print $output "$line,$_\n"; }
	    }
	}
	
	# Store step 2 summary file into ctl file
	my $project = $ctl->get_one_tag("PROJECT_NAME");
	$ctl->add_parameters("step2_summary", "$cwd/$project.step2_provirus.csv");
}

#
sub genGFF3 {
	
	# Initialization
	my ($seq, $domain, $gff3, $rt) = @_;
	my ($input, $output, @tabs);
	my ($chr, $start, $end, $type, $frame, $strand, $length);
	#
	open($input, "<", $rt);
	my @rt_seq = <$input>;
	shift @rt_seq;
	my $RT_seq = "";
	foreach (@rt_seq) { chomp $_; $RT_seq .= $_; }
	$length = length($RT_seq) + 20000;
	#
	open($input, "<", $domain);
	open($output, ">", $gff3);
	#
	print $output "##gff-version 3\n";
	print $output "##sequence-region   seq0 1 $length\n";
	print $output "seq0\tHMMer\ttarget_region\t1\t$length\t.\t+\t.\tID=target_region1\n";
	print $output "seq0\tHMMer\tscan_region\t1\t$length\t.\t+\t.\tID=scan_region1;Parent=target_region1;seq_number=0\n";
	#
	while (defined($_ = <$input>)) {
		chomp $_;
		# skip blank & commented lines when reading a file 
		next if /^(\s*(#.*)?)?$/;
		#
		@tabs = split(" +", $_);
		($chr, $start, $end, $type, $frame) = split("_", $tabs[0]);
		#
		if ($frame =~ /1|2|3/) { $strand = "+"; $frame -= 1; }
		else { $strand = "-"; $frame -= 4; }
		#
		print $output "seq0\tHMMer\tprotein_match\t",$tabs[17]*3-2,"\t",$tabs[18]*3-2,"\t$tabs[11]\t$strand\t.\t";
		print $output "Parent=scan_region1;reading_frame=$frame;name=$tabs[3]\n";
	}
	#
	print $output "###\n";
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Processing data step 2 - LTR_Harvest & LTR_Digest
# Summarise all output files and fulfill the step2 summary file
# REPEAT_S		REPEAT_E		LLTR_S		LLTR_E			RLTR_S			RLTR_E	LLTR_REP_ID
# LLTR_REP_SIM	LLTR_REP_SOCRE	RLTR_REP_ID	RLTR_REP_SIM	RLTR_REP_SOCRE	RT_S	RT_E
# RT_INSIDE		PROVIRUS		GENES
# ------------------------------------------------------------------------------------------------------------------
sub step2_summarize_annotation {
	
	# Initialization
	my ($seq, $gff3, $ctl) = @_;
	my (@lines, %addon, %blast, @summary, @reps, @LTR_loci);
	my (@ltrs, @pros, $region, $pbs, @rt_loci);
	my $header = $1 if ($seq =~ /\/(.+_\d+_\d+)_genome\.fna/);
	# print genome strcture pic
	system "gt sketch $seq.sketch.png $gff3";

	# Read the exonerate output, match on the reverse strand will be marked as "revcomp"
	if (-f "$seq.exonerate") {
		@_ = split("\n", `cat $seq.exonerate`);
		# Coordinats are stored in "Target range" line
		@rt_loci = ($1, $2) if ($_[10] =~ /  Target range: (\d+) -> (\d+)/);
		# Change the order if the match on the reverse strand
		if ($_[6] =~ /revcomp/) { $_ = $rt_loci[1]; $rt_loci[1] = $rt_loci[0]; $rt_loci[0] = $_; }
	}

	# Read the LTR_Digest gff3 output
	open(my $input, "<", $gff3);
	@lines = <$input>;
	for (my $i = 2; $i < @lines; $i ++) { $gff3 .= $lines[$i]; }
	
	# Repeat region block: the beginning line of one repeat region, ending with "###"
	@reps    = split("###\n", $gff3);
    @summary = ();
	# Skip the first two blokc as they are header line
	for (my $i = 0; $i < @reps; $i ++) {
		#
		undef @ltrs;
		undef @pros;
		undef @LTR_loci;
		@lines = split("\n", $reps[$i]);
		#
		foreach (@lines) {
			# Repeat region shows the range of repeat locates
			if    ($_ =~ /\t(repeat|target)_region\t(\d+)\t(\d+)\t/) { $region = $_; }
			elsif ($_ =~ /\tlong_terminal_repeat\t/)                 { push(@ltrs, $_); }
			elsif ($_ =~ /\tprotein_match\t/)                        { push(@pros, $_); }
			elsif ($_ =~ /\tprimer_binding_site\t/)                  { $pbs = $_; }
			elsif ($_ =~ /\tLTR_retrotransposon\t(\d+)\t(\d+)/)      {
				$header = substr($header, 0, 20)."_$1\_$2";
			}
		}

		# Summairse all information
		# Repeat region
		@_ = split("\t", $region);
		$reps[$i] = "$_[3],$_[4]";
		# LTR location
		if (-f "$seq.ltrdigest_3ltr.fas" && -f "$seq.ltrdigest_5ltr.fas") {
			foreach (@ltrs) {
			    @_ = split("\t", $_);
			    $reps[$i] .= ",$_[3],$_[4]";
			    push(@LTR_loci, ($_[3],$_[4]));
		    }
		} else {
			$reps[$i] .= ",0,0,0,0";
			@LTR_loci = ((0,0), (0,0));
		}
		# Blast results
		# Read the LTR blast results for both 5' & 3' LTR
	    if (-f "$seq.ltrdigest_3ltr.fas.blast" && -f "$seq.ltrdigest_5ltr.fas.blast") {
		    #
			@{$blast{$header}} = (0, 0);
			&blast_result(\%blast, $seq, 5, $ctl);
	        &blast_result(\%blast, $seq, 3, $ctl);
			#
			foreach (@{$blast{$header}}) {
				if ($_) { $reps[$i] .= $_; }
				else    { $reps[$i] .= ",NONE,0,0"; }
			}
	    } else {
			$reps[$i] .= ",NONE,0,0,NONE,0,0";
		}
		# Primer binding site
		if (defined($pbs)) {
			@_ = split("\t", $pbs);
		    $reps[$i] .= ",$_[3],$_[4],";
		    @_ = split(";", $pbs);
		    $reps[$i] .= "$_[1]";
		} else {
			$reps[$i] .= ",NONE,NONE,NONE";
		}
	    # Check whether RT locate within two LTRs
		my $RT_INSIDE = "NO";
		if ($LTR_loci[1] < $rt_loci[0] && $rt_loci[1] < $LTR_loci[2]) {
			$RT_INSIDE = "YES";
		}
		#
		$reps[$i] .= ",$rt_loci[0],$rt_loci[1],$RT_INSIDE";
		#
		$reps[$i] .= ",".(scalar @pros);
		foreach (@pros) {
			@_ = split("name=", $_);
			$reps[$i] .= ",$_[-1]";
		}
	}
	#
	return @reps;
}

sub blast_result {
	
	# Initialization
	my ($blast, $seq, $LTR, $ctl) = @_;
	my $index = 0;
	if ($LTR == 3) { $index = 1 };

	# Read the blast result
	my $line = "cat $seq.ltrdigest_$LTR"."ltr.fas.blast";
	# Skip commented lines & catch the blast result
	my @blast_res = grep { $_ !~ /#/ } split("\n", `$line`);
	if (@blast_res != 0) {
		foreach (@blast_res) {
			@_ = split("\t", $_);
			if (exists($blast->{$_[0]})) {
				#
				print $_[0],"\n";
				print $index,"\n";
				print $blast->{$_[0]}->[$index],"\n";
				$blast->{$_[0]}->[$index] = ",$_[1],$_[2],$_[3]";
			}
		}
	}
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Processing data step 3 - UCSC RepeatMasker database & solo LTRs
# Extract tables from the database
# ------------------------------------------------------------------------------------------------------------------
sub step3_summarize_LTRs {
	
	# Check current working space & make output folder
	my $cwd = &cwd();
	
	# Initialization
	my ($self, $ctl, $tools, $mysql) = @_;
	my $output_dir = $ctl->get_gluetools_dir();
	my @chromosomes = (1..31, "X", "Un");
	my ($resultSet, $tableNames, $totalNum, $totalRow);
	my (%count, $progress);
	
	# If the folder exists, pipeline will overwrite the old one 
	# If the folder dosen't exist, create a new one
	&build_folder("$cwd/$output_dir");
	
	# Check each table for each chromosome
	foreach my $chrNum (@chromosomes) {
		
		#
		my $chrID = "chr$chrNum";
		print "\n\n$chrID : reading and sort";
		
		#
		my ($resultSet_UCSC, $rowNum_UCSC) = $mysql->mysql_get_all_rows_from_UCSC_table("$chrID\_rmsk");
		my ($resultSet_DIGS, $rowNum_DIGS) = $mysql->mysql_get_all_rows_from_DIGS_table($chrID);
        #
		$resultSet = &combine_ICSC_DIGS($resultSet_UCSC, $resultSet_DIGS);
		
		# Make a new progree meter
	    $progress = Time::Progress->new();
		
		# if the adjcent pair are overlapping, group them together
		# otherwise, put the next one as a new group
		#
		my ($LTRGroups, $index);
		$index = 0;
		@{$LTRGroups}[$index] = LTRGroup->new();
		@{$LTRGroups}[$index]->add_new_row($resultSet_UCSC->[0]);
		#
		print "\n$chrID : build groups\n";
		$progress->attr(min => 0, max => $rowNum_UCSC+$rowNum_DIGS);
		#
		for (my $c_count = 0; $c_count < $rowNum_UCSC+$rowNum_DIGS-1; $c_count ++) {
			
			# end   : the end position of the first row
			my $end   = $resultSet->[$c_count]  ->{'genoEnd'};
			# start : the start position of the second row
			my $start = $resultSet->[$c_count+1]->{'genoStart'};
			# Overplapping
			if ($end >= $start) {
				$LTRGroups->[$index]->add_new_row($resultSet->[$c_count+1]);
			} else {
				$index ++;
				$LTRGroups->[$index] = LTRGroup->new();
				$LTRGroups->[$index]->add_new_row($resultSet->[$c_count+1]);
			}
			#
			print $progress->report("%45b %p\r", $c_count);
		}
				
		#
		print "\n$chrID : format and print LTR sequences\n";
		$progress->attr(min => 0, max => scalar @{$LTRGroups});
		#
		for ($index = 0; $index < @{$LTRGroups}; $index ++) {
			
			#
			if ($LTRGroups->[$index]->format_LTR_group()) {
				#
				if ($LTRGroups->[$index]->get_LTR_group_stage() =~ /single/) {
					$count{'hits : 1'} ++;
				} else {
					$count{'hits : '.$LTRGroups->[$index]->get_LTR_group_hit_num()} ++;
					if (!$LTRGroups->[$index]->group_multiple_to_single()) {
						$LTRGroups->[$index] = 0;
					}
				}
			} else {
				$LTRGroups->[$index] = 0;
				$count{'hits : 0'} ++;
			}
			
			#
			if ($LTRGroups->[$index] != 0) {
				
                #
				my ($label, $start, $end, $strand, $class) = $LTRGroups->[$index]->extract_LTR_info();
				#
				if ($label ne "0" && $class =~ /LTR/i) {
					#
					my $refGenome = $ctl->get_ref_genome();
				    @_ = split("\n", `samtools faidx $refGenome/$chrID.fa $chrID:$start-$end`);
				    my $seq = "";
				    for (my $i = 1; $i < @_; $i ++) { chomp $_[$i]; $seq .= $_[$i]; }
					#
					if ($strand =~ /-/) { $seq = &reverse_complement_IUPAC($seq); }
				    #
				    open(my $output, ">>", "$cwd/$output_dir/$label.fa");
				    print $output ">$label.$chrID.$start.$end\n";
				    print $output $seq,"\n";
				}
			}
		    
			#
		    print $progress->report("%45b %p\r", $index);
		}
	}
	
	#
	foreach my $key (sort bynum keys %count) { print "$key\t$count{$key}\n"; }
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Processing data step 3 - UCSC RepeatMasker database & solo LTRs
# Combine and sort two result sets into one
# ------------------------------------------------------------------------------------------------------------------
sub combine_ICSC_DIGS {
	
	#Initialization
	my ($first, $second) = @_;
	
	#
	my @total = sort { $a->{'genoStart'} <=> $b->{'genoStart'} } (@$first, @$second);
	
	#
	return \@total;
	
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Processing data step 3 - UCSC RepeatMasker database & solo LTRs
# Modified sort function : sort count result accoring to hit number
# ------------------------------------------------------------------------------------------------------------------
sub bynum {
	
	#
	my $first  = $1 if ($a =~ /hits : (\d+)/);
	my $second = $1 if ($b =~ /hits : (\d+)/);
	#
	$first <=> $second;
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Processing data step 4 - Build GLUEtool project and align all LTR sequences
# Extract tables from the database
# ------------------------------------------------------------------------------------------------------------------
sub step4_build_gluetoo_projects {
	
	# Check current working space & make output folder
	my $cwd = &cwd();
	
	# Initialization
	my ($self, $ctl, $tools) = @_;
	my $output_dir = $cwd."/".$ctl->get_gluetools_dir();
	my (%targetList, @provirus);
	
	# Part 1 : build gluetool project for UCSC target
	$tools->signal_step_message(7);
	my $provirs_csv = $ctl->get_treemarker_csv_table();
	open(my $input, "<", $provirs_csv) or die $tools->signal_step_message(14);
	while (defined($_ = <$input>)) {
		@_ = split(",", $_);
		if ($_[18] !~ /NONE/ && $_[21] !~ /NONE/ && $_[28] =~ /YES/) {
			$targetList{$_[18]} ++;
			$targetList{$_[21]} ++;
		}
	}
	close $input;
	
	#
	my @list = glob("$output_dir/*.fa");
	foreach (@list) {
		my ($name,$path,$suffix) = fileparse($_, ".fa");
		if (exists($targetList{$name})) {
			print $name,"\n";
		}
	}
}


# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# Overwrite or make a folder at the given location, if folder does or doesn't exists
# ------------------------------------------------------------------------------------------------------------------
sub build_folder {
	
	#Initialization
	my $path = shift;
	
	# If the folder exists, pipeline will overwrite the old one
	if (-d $path) { system "rm -rf $path"};
	# create a new one
	system "mkdir $path";
}

# ------------------------------------------------------------------------------------------------------------------
# Sub functions
# The basic function, shown below, for reverse complementing a DNA sequence
# uses the built-in reverse() function in Perl to reverse the string.
# Article created: Aug 25, 2011
# Article by: Jeremiah Faith
# ------------------------------------------------------------------------------------------------------------------
sub reverse_complement_IUPAC {
	
	#Initialization
    my $dna = shift;

	# reverse the DNA sequence
    my $revcomp = reverse($dna);

	# complement the reversed DNA sequence
    $revcomp =~ tr/ABCDGHMNRSTUVWXYabcdghmnrstuvwxy/TVGHCDKNYSAABWXRtvghcdknysaabwxr/;
    return $revcomp;
}

1;