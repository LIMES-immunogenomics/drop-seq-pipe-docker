# dropSeqPipe

A simple wrapper around the dropSeqPipe, which itself is a wrapper
around dropSeqTools from the dropseq project.  The additional
functionality includes merging `fastq.gz` files before performing the
analysis.

# Usage

## Environmental variables

Under normal circumstances no

The environmental variables used in this container include

- `SAMPLENAMES`: the names of the samples, that will be used to select
  and merge `fastq.gz` files.  For example
  ```
  SAMPLENAMES=STAT1_Ctrl_1_1 STAT1_Ctrl_1_2
  ```
  if we have fastq files named like

  ```
  Ctrl_1_1/STAT1_Ctrl_1_1_S11_L001_R1_001.fastq.gz
  Ctrl_1_1/STAT1_Ctrl_1_1_S11_L002_R1_001.fastq.gz
  Ctrl_1_1/STAT1_Ctrl_1_1_S11_L003_R1_001.fastq.gz
  Ctrl_1_1/STAT1_Ctrl_1_1_S11_L004_R1_001.fastq.gz
  Ctrl_1_2/STAT1_Ctrl_1_2_S12_L001_R1_001.fastq.gz
  Ctrl_1_2/STAT1_Ctrl_1_2_S12_L002_R1_001.fastq.gz
  Ctrl_1_2/STAT1_Ctrl_1_2_S12_L003_R1_001.fastq.gz
  Ctrl_1_2/STAT1_Ctrl_1_2_S12_L004_R1_001.fastq.gz
  ```

  Would merge the first 4 samples and the last 4 together.  If you set
  `SAMPLENAMES=STAT1` all samples will be merged under the name
  `STAT1`.  By default `SAMPLENAMES=""` (i.e. if not specified) and
  sample names will be determined automatically.

- `NUMCELLS`: a number of cells/beads to extract from each sample (if
  you don't want to discard any barcodes set this to a large number.
  Otherwise it should correspond to the n. of cells you expect to find
  (any but the top $NUMCELLS$ barcodes, sorted by UMIs, will be
  discarded).

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
- `/samples.csv` (optional), if you want to provide a specific
  `samples.csv` file according to the dropSeqPipe standard.  If not
  present it will be automatically generated based on `SAMPLENAMES` or
  on file names if `SAMPLENAMES` is not provided.
