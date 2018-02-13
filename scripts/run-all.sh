#!/bin/bash

source activate dropSeqPipe

input=/input
output=/output
meta=/meta
data=$output/data

echo "samples,expected_cells,read_length" \
     > $output/samples.csv

if [ ! -n "$SAMPLENAMES" ]; then
    echo "set SAMPLENAMES environmental variable in the docker-compose.yml"
fi

# TODO: parallelize
mkdir -p $data
for sample in $SAMPLENAMES; do
    for r in R1 R2; do

        echo "merging $sample, $r..."

        files=$(find /input -name "$sample_*$r*.fastq.gz")
        if [ ! -n "$files" ]; then
            (>&2 echo "Could not find any suitable files associated with the name $sample")
            exit 0
        fi

        find /input -name "$sample_*$r*.fastq.gz" \
            | sort \
            | xargs zcat \
            | gzip --fast \
                   > $data/"${sample}_$r.fastq.gz"
    done

    readlength=$(zcat $data/"${sample}_R2.fastq.gz" \
                     | head -n2 \
                     | tail -n1 \
                     | wc -c)
    # correct for the newline character
    let readlength-=1

    echo "$sample,$NUMCELLS,$readlength" \
         >> $output/samples.csv
done

cp /config/config.yaml $output/config.yaml

cd $output

snakemake \
    --cores $NTHREADS \
    --snakefile /dropSeqPipe/Snakefile \
    $TARGETS \
    > >(tee -a $output/stdout.log) \
    2> >(tee -a $output/stderr.log >&2)

# clear the data folder
rm -rf $data
