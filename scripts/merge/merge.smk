from snakemake.shell import shell
from pathlib import Path
import re


def samplefiles(sample,read):
    r1_files = list(map(
        str,
        (Path("/input")
         .glob(f"""**/{sample}*_R1_*.fastq.gz"""))
    ))
    r2_files = [re.sub(r'_R1_','_R2_',r1) for r1 in r1_files]

    if read == "1":
        return r1_files
    elif read == "2":
        return r2_files
    else:
        raise Exception("Wrong read id")

rule merge_fastq:
    input:
        lambda wildcards: samplefiles(wildcards.sample,wildcards.read)
    output:
        temp("data/{sample}_R{read}.fastq.gz")
    log:
        "logs/merging/{sample}_R{read}.log"
    run:
        shell("echo {input} > {log}")
        if len(input) == 1:
            shell("ln -s {input} {output}")
        else:
            shell("cat {input} > {output}")
