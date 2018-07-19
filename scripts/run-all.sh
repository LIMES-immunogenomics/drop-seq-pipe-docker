#!/bin/bash

set -e

python /scripts/samplescsv.py \
       --samplenames "$SAMPLENAMES" \
       --ncells $NUMCELLS \
       --fastqpath /input \
       --csvpath /samples.csv

source activate dropSeqPipe

cp /config/config.yaml /output/config.yaml
cp /samples.csv /output/samples.csv

snakemake \
    --jobs $JOBS \
    --snakefile /dropSeqPipe/Snakefile \
    --directory /output
    $TARGETS \
    > >(tee -a /output/stdout.log) \
    2> >(tee -a /output/stderr.log >&2)

chmod -R a+w $output
chown -R nobody $output
