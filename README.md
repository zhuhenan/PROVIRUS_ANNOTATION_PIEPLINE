# Provirus Annotation Pipeline

This pipeline is a dowstream analysis tools for the Database-Integrated Genome Screening (DIGS) Tool. It was writtern in PERL and provides a computational framework. It can be used to recover complete ERV proviruses from a host genome assembly, given a table of ERV loci based on screening with a subgenomic region (e.g. RT or TM).

## Getting Started

### Requirements
This pipeline requires several external programs, All of them need to be added to **PATH** enviroment variables:
 - PERL 5.8.3 or later
 - [NCBI BLAST](ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/)
 - [Exonerate](https://www.ebi.ac.uk/about/vertebrate-genomics/software/exonerate)
 - [GenomeTools](http://genometools.org/)
 - [HMMER](http://hmmer.org/)
 - [EMBOSS Transeq](http://emboss.open-bio.org)
 
Also, you need to make sure the following PERL package is in your **@INC** and up-to-date.
 - List::Util
 - Text::CSV_XS
 - Bio::DB::Fasta
 
To run this pipeline, some reference libraries are needed. As some of them are quite big, it will be great to prepare them before running this pipeline. Also, to reduce the running time, it's recommonded to limit the library size. DIGS "Extracted" talbe can be explored from the database that DIGS build, also you can custom the same csv table using your own data.
 - RepeatMasker library in **FASTA** format: http://www.girinst.org/server/RepBase/index.php
 - Pfam **hmm** profile : http://pfam.xfam.org
 - tRNA library : you can use your own library, or you can download one from [GtRNAdb](http://gtrnadb.ucsc.edu)
 - Host assembly or reference genome in **FASTA** format
<<<<<<< HEAD
 - DIGS "Extracted" talbe in tab-delimited **CSV** format, you can also use this [templete](https://github.com/zhuhenan/PROVIRUS_ANNOTATION_PIEPLINE/blob/master/DIGS_table_templete.csv) to generate your own table																								
  1. Record_ID	 BLAST_ID can be any number																									
  2. <Organism>/<Data_type>/<Version>/<Target_name> is the path to the host genome assembly																									
  3. Assigned_name and Assigned_gene can be the same																									
  4. Orientation can be either +ve for positive or -ve for negative																										
=======
 - DIGS "Extracted" talbe in tab-delimited **CSV** format, you can also use this [templete](https://github.com/zhuhenan/PROVIRUS_ANNOTATION_PIEPLINE/blob/master/DIGS_table_templete.csv) to generate your own table
 - if you want to custom your own table, please follow these rules
  1. Record_ID, BLAST_ID can be any number
  2. \<Organism\>/\<Data_type\>/\<Version\>/\<Target_name\> is the path to the host genome assembly
  3. Assigned_name and Assigned_gene can be the same
  4. Orientation can be either +ve for positive or -ve for negative

>>>>>>> readme
 
### Setting up control file
After you meet all requirements, the only thing you need to do is to fillful the control file. This [control file templete](https://github.com/zhuhenan/PROVIRUS_ANNOTATION_PIEPLINE/blob/master/Equus_caballus.ctl)  provides setting details.

### Run
It's very simply to run this pipeline, just follow the syntx:
> perl ERVGenome_Pipeline_Part1.pl -f \<you control file\>

To see options:
> perl ERVGenome_Pipeline_Part1.pl -h

## Authors
Zhu, Henan (h.zhu.1@research.gla.ac.uk)