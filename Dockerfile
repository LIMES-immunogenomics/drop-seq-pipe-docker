FROM pwlb/rna-seq-pipeline-base


RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.3.27-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
ENV PATH /opt/conda/bin:$PATH

# this step takes unberably long due to a bug in conda

RUN git clone https://github.com/Hoohm/dropSeqPipe.git && \
    cd dropSeqPipe && \
    cp drop-seq-tools-wrapper.sh $DROPSEQPATH && \
    conda env create -v --name dropSeqPipe --file environment.yaml

RUN wget --quiet \
    http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/gtfToGenePred \
    -O /usr/bin/gtfToGenePred && \
    chmod a+x /usr/bin/gtfToGenePred

ENV NUMCELLS 500
ENV NCORES 1
ENV TARGETS all
COPY config/config.yaml /config/
COPY scripts /scripts

# patch until https://github.com/Hoohm/dropSeqPipe/issues/17 is resolved
#
# it also resovles the issue with an empty refFlat being generated by
# ConvertToRefFlat.  This should be resolved by removing reliance on
# refFlat once https://github.com/broadinstitute/picard/pull/951 gets
# merged.

# COPY patches/generate_meta.smk /dropSeqPipe/rules/generate_meta.smk

ENTRYPOINT ["bash", "/scripts/run-all.sh"]
CMD [""]
