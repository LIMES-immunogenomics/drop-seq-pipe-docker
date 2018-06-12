FROM pwlb/rna-seq-pipeline-base:v0.1.0


RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.3.27-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
ENV PATH /opt/conda/bin:$PATH

RUN conda install -c bioconda -c conda-forge snakemake

RUN git clone https://github.com/Hoohm/dropSeqPipe.git && \
    cd dropSeqPipe && \
    git checkout -b temp 8a3b643a30efab065c80a8fb5f732d4abc43d49f && \
    cp drop-seq-tools-wrapper.sh $DROPSEQPATH

COPY environment.yaml .
RUN conda env create -v --name dropSeqPipe --file environment.yaml

COPY ./binaries/gtfToGenePred /usr/bin/gtfToGenePred

ENV NUMCELLS 500
ENV NCORES 1
ENV TARGETS all
COPY config/config.yaml /config/
COPY scripts /scripts

ENTRYPOINT ["bash", "/scripts/run-all.sh"]
CMD [""]
