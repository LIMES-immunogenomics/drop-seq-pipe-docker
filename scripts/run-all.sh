#!/bin/bash

set -ex

input=/input
output=/output
meta=/meta
data=$output/data
tmp=$output/tmp

echo "samples,expected_cells,read_length,batch" \
     > $output/samples.csv

if [ ! -n "$SAMPLENAMES" ]; then
    echo "set SAMPLENAMES environmental variable in the docker-compose.yml"
fi

mkdir -p $data

rm -rf $tmp
mkdir -p $tmp

# TODO: parallelize
for sample in $SAMPLENAMES; do
    # delete the underscores because dropSeqPipe may run into issues
    # with files named sample_1_2_R1.fastq.gz
    samplenorm=$(echo $sample| sed -e 's/_//g')

    for r in R1 R2; do

        echo "merging $sample [$samplenorm], $r..."

        files=$(find $input -type f -name "${sample}_*$r*.fastq.gz"|sort)
        if [ ! -n "$files" ]; then
            (>&2 echo "Could not find any suitable files associated with the name $sample")
            exit 1
        fi

        fout=$data/"${samplenorm}_$r.fastq.gz"
        rm -f $fout

        for f in $files; do
            echo "$sample, $samplenorm, $r, $f, $fout" >> $output/merging$r.log
            echo $sample >> $tmp/${sample}_${r}
            cat $f >> $fout
        done
    done

    if ! cmp $tmp/${sample}_R1 $tmp/${sample}_R2; then
        echo "For sample $sample files with R1 and R2 are not matching"
        cat $tmp/${sample}_R2
        exit 1
    fi

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
