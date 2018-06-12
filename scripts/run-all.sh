#!/bin/bash

set -ex

input=/input
output=/output
meta=/meta
data=$output/data

echo "samples,expected_cells,read_length,batch" \
     > $output/samples.csv

if [ ! -n "$SAMPLENAMES" ]; then
    echo "set SAMPLENAMES environmental variable in the docker-compose.yml"
fi

# TODO: parallelize
mkdir -p $data

for sample in $SAMPLENAMES; do
    # delete the underscores because dropSeqPipe may run into issues
    # with files named sample_1_2_R1.fastq.gz
    samplenorm=$(echo $sample| sed -e 's/_//g')

    for r in R1 R2; do

        echo "merging $sample [$samplenorm], $r..."

        files=$(find $input -type f -name "${sample}_*$r*.fastq.gz"|sort)
        if [ ! -n "$files" ]; then
            (>&2 echo "Could not find any suitable files associated with the name $sample")
            exit 0
        fi

        find $input  \
             -type f \
             -name "${sample}_*$r*.fastq.gz" \
            | sort \
            | xargs cat \
                    > $data/"${samplenorm}_$r.fastq.gz"
    done

    readlength=$(zcat $data/"${samplenorm}_R2.fastq.gz" \
                     | head -n2 \
                     | tail -n1 \
                     | wc -c)
    # correct for the newline character
    let readlength-=1

    echo "$samplenorm,$NUMCELLS,$readlength,Batch1" \
         >> $output/samples.csv
done

cp /config/config.yaml $output/config.yaml

cd $output

source activate dropSeqPipe

snakemake \
    --cores $NTHREADS \
    --snakefile /dropSeqPipe/Snakefile \
    $TARGETS \
    > >(tee -a $output/stdout.log) \
    2> >(tee -a $output/stderr.log >&2)

chmod -R a+w $output
chown -R nobody $output
