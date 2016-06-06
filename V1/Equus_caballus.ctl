# ------------------------------------------------------------------------------------------------------------------
# Pipeline Control File Tamplate
# ------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------
# Part 1. Basic setting
# ------------------------------------------------------------------------------------------------------------------
# Host species reference genome sequences
# The folder of host reference genome in which reference sequences can be found
# Reference sequence should be the same as what you used for DIGS screening
REFERENCE_GENOME_DIR = goldenpath_equCab2_Dec13

# The format of any pipeline output summary file require a "project name" to begin with
# Format: <project_name>.<output_name>.<file_type>
PROJECT_NAME = EquCab_2016FEB_ALL

# ------------------------------------------------------------------------------------------------------------------
# Part 2. DIGS Screening result set table
# ------------------------------------------------------------------------------------------------------------------
# The DIGS screening resutlt set table
# The name of the file which the data are to be read from. Each row of the table appears as one line of the file.
# If it does not contain an absolute path, the file name is relative to the current working directory
# Default: first line should be header, separated by comma, no quote required, end with "\n" only
DIGS_RESULT_SET_CSV = HZ_RT_2016_Twilight_all.csv


# The pathway of folder which raw sequneces are to be write into.
# This folder will also work as the output folder for LTR_harvest & LTR_Digest
# If the folder doesn't exist, pipeline will create a new one
# If the folder exists, pipeline will overwrite the old one
# If this setting is empty, pipeline will use "RAW_SEQ_OUT_DIR" as default folder name
RAW_SEQ_OUT_DIR = RAW_SEQ_OUT_DIR_ALL

# ------------------------------------------------------------------------------------------------------------------
# Part 3. LTR_Harvest & LTR_Digest settings and input, and blast to find new LTRs
# ------------------------------------------------------------------------------------------------------------------
# LTR_Harvest parameter settings
# minlenltr: minimum length for each LTR - 200
MINLENLTR  = 200
# maxlenltr: maximum length for each LTR - 1500
MAXLENLTR  = 1500
# mindistltr: minimum distance of LTR start positions - 1000
MINDISTLTR = 1000
# maxdistltr: maximum distance of LTR start positions - 15000
MAXDISTLTR = 15000
# similar: minimum similarity value between the two LTRs - 80%
SIMILAR    = 80
# mintsd: minimum length for each TSD - 5
MINTSD     = 5
# maxtsd: maximum length for each TSD - 20
MAXTSD     = 20

# LTR_Digest parameter settings
# PPTLEN_MIN & PPTLEN_MAX: specify a range of acceptable PPT lengths
PPTLEN_MIN    = 10
PPTLEN_MAX    = 30
# Specify a file in multiple FASTA format to be used as a tRNA library that is aligned to the
# area around the end of the 5Õ LTR to find a putative PBS. This file can be downloaded from GtRNAdb
TRNA_LIB      = equCab2-tRNAs.fa
# Specify the minimum and maximum allowed distance between the start of the PBS and the 3Õ end
# of the 5Õ LTR.
PBSOFFSET_MIN = 0
PBSOFFSET_MAX = 100
# Specify a list of pHMM files in HMMER2 format. The pHMMs must be defined for the amino
# acid alphabet and follow the Plan7 specification. This file can be downloaded from pfam
HMMS_PROFILE  = Pfam-Equine.hmm
# Specify the area around the 5Õ LTR end to be searched for a PBS
PBSRADIUS     = 100

# Specify a file in EMBL format to be used as the Repbase reference sequences that is used to
# build the blast database, only long terminal repeat (LTR) sequences will be accepted, no
# matter they are present or absent in the file
REPBASE_EMBL_LIBRARY_FILE = RepBase.ref.embl

# ------------------------------------------------------------------------------------------------------------------
# Part 4. Mysql database connection parameter
# ------------------------------------------------------------------------------------------------------------------
# Username
USERNAME = zhuhenan
# Password
PASSWORD = 19890514
# Specify the UCSC prepeat elements database that has all LTR information
DATABASE_UCSC = UCSC_RepeatMasker
# Specify the UCSC prepeat elements database that has all LTR information
DATABASE_DIGS = HZ_LTR_2016_Twilight
# Specify the host of database
HOST     = LOCALHOST
# Specify the port of database
PORT     = 3306

# ------------------------------------------------------------------------------------------------------------------
# Part 5. Detect & filter LTRs according to DIGS results and UCSC RepeatMasker annotation
# ------------------------------------------------------------------------------------------------------------------
# The provirus result table
# This table is the same as the piepline part 1 final report, but has "TREEMARKER" column
# "TREEMARKER" column shows every reocrd in the RT tree, only rows with "TREEMARKER" will be analysis
# The table should be "csv" format
PROVIRUS_CSV = EquCab_2016FEB_ALL.step2_provirus_TreeMarker.csv

# The pathway of folder which LTR sequneces are to be write into.
# This folder will also work as the output folder for gluetools
# If the folder doesn't exist, pipeline will create a new one
# If the folder exists, pipeline will overwrite the old one
GLUETOOLS_PROJECT = GLUETOOLS_PROJECTS