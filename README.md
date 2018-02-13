# dropSeqPipe

A simple wrapper around the dropSeqPipe, which itself is a wrapper
around dropSeqTools from the dropseq project.  The additional
functionality includes merging `fastq.gz` files before performing the
analysis.

# Usage

## Environmental variables

The environmental variables used in this container include

- `SAMPLENAMES`: the names of the samples, that will be used to select
  and merge `fastq.gz` files.  For example
  ```
  SAMPLENAMES=STAT1_Ctrl_1_1 STAT1_Ctrl_1_2
  ```
  if we have fastq files named like

  ```
  Ctrl_1_1/STAT1_Ctrl_1_1_S11_L001_R1_001.fastq.gz
  Ctrl_1_1/STAT1_Ctrl_1_1_S11_L001_R2_001.fastq.gz
  Ctrl_1_1/STAT1_Ctrl_1_1_S11_L002_R1_001.fastq.gz
  Ctrl_1_1/STAT1_Ctrl_1_1_S11_L002_R2_001.fastq.gz
  Ctrl_1_1/STAT1_Ctrl_1_1_S11_L003_R1_001.fastq.gz
  Ctrl_1_1/STAT1_Ctrl_1_1_S11_L003_R2_001.fastq.gz
  Ctrl_1_1/STAT1_Ctrl_1_1_S11_L004_R1_001.fastq.gz
  Ctrl_1_1/STAT1_Ctrl_1_1_S11_L004_R2_001.fastq.gz
  Ctrl_1_2/STAT1_Ctrl_1_2_S12_L001_R1_001.fastq.gz
  Ctrl_1_2/STAT1_Ctrl_1_2_S12_L001_R2_001.fastq.gz
  Ctrl_1_2/STAT1_Ctrl_1_2_S12_L002_R1_001.fastq.gz
  Ctrl_1_2/STAT1_Ctrl_1_2_S12_L002_R2_001.fastq.gz
  Ctrl_1_2/STAT1_Ctrl_1_2_S12_L003_R1_001.fastq.gz
  Ctrl_1_2/STAT1_Ctrl_1_2_S12_L003_R2_001.fastq.gz
  Ctrl_1_2/STAT1_Ctrl_1_2_S12_L004_R1_001.fastq.gz
  Ctrl_1_2/STAT1_Ctrl_1_2_S12_L004_R2_001.fastq.gz
  ```
  The actual line used to match the filenames is `find /input -name
  "$sample_*$r*.fastq.gz"`, where $r is either `R1` or `R2`, which
  means the sub-directories are completely ignored now.

- `NUMCELLS`: a number of cells/beads to extract from each sample (if
  you don't want to discard any barcodes set this to a large number.
  Otherwise it should correspond to the n. of cells you expect to
  find.

- `NCORES`: number of available cores.  The dropSeqPipe takes
  advantage of some jobs being independent of each other (e.g. if
  there are two samples they will be processed independently) and
  spreads the jobs among available cores.

- `JOBS`: the type of analysis to perform, the default is `all`.  If
  you want to perform just a preliminary qc select one of the
  available targets from
  https://github.com/Hoohm/dropSeqPipe/wiki/Running-dropSeqPipe#modes.

## Volumes

The pipeline expects the following directories to be mounted

- `/input:ro`, the location of the `fastq.gz` files
- `/output:rw`, where the results will be stored
- `/meta:rw`, the location of the annotation and genome files.  The
  script will look for `transctripts.fasta` and `annotation.gtf`
  files.  Then it will generated STAR index and other files necessary
  for the pipeline, if such files already exist the pipeline will
  reuse them without regenerating them.
