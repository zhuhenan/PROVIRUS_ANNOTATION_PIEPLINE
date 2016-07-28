# Provirus Annotation Pipeline

This pipeline is a dowstream analysis tools for the Database-Integrated Genome Screening (DIGS) Tool. It was writtern in PERL and provides a computational framework. It can be used to recover complete ERV proviruses from a host genome assembly, given a table of ERV loci based on screening with a subgenomic region (e.g. RT or TM).

## Getting Started

### Installing
After downloading this repository, the following several external programmes are required. All of them need to be added to **PATH** enviroment variables.

This pipeline requires:
 - PERL 5.8.3 or later
 - [NCBI BLAST+](ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/)
 - [Exonerate](https://www.ebi.ac.uk/about/vertebrate-genomics/software/exonerate)
 - [GenomeTools](http://genometools.org/)
 - [HMMER](http://hmmer.org/)

