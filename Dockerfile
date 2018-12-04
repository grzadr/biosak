FROM jupyter/scipy-notebook:latest

LABEL version="1.0" maintainer="Adrian Grzemski <adrian.grzemski@gmail.com>"

USER root
### Update system
RUN apt update && apt full-upgrade -y

### Install necessery packages for library building
RUN apt install -y build-essential software-properties-common && \
    apt install python3-roman && \
    cp /usr/lib/python3/dist-packages/roman.py /opt/conda/lib/python3.6 && \
    chown jovyan /opt/conda/lib/python3.6/roman.py && \
    apt autoremove -y && apt clean -y

USER jovyan
### Update conda & add repos
RUN conda update --yes -n base conda && \
    conda config --add channels bioconda && \
    conda config --add channels defaults && \
    conda config --add channels r && \
    conda config --add channels conda-forge

### Install & update packages
RUN \
### From bioconda
    conda install --yes -f -c bioconda \
    snakemake=5.3.0 \
    bwa=0.7.17 \
    minimap2=2.14 \
    picard=2.18.17 \
    fastqc=0.11.8 \
    multiqc=1.6 \
    samtools=1.9 \
    bcftools=1.9 \
    htslib=1.9 \
    bamtools=2.5.1 \
    gatk4=4.0.11.0 \
    && \
### from R
    conda install --yes -f -c r \
    r-base=3.5.1 \
    r-htmlwidgets=1.2 \
    r-rsqlite=2.1.1 \
    r-forecast=8.4 \
    r-nycflights13=1.0 \
    r-sparklyr=0.8.4 \
    r-shiny=1.1 \
    rpy2=2.9.4 \
    r-rmarkdown=1.10 \
    r-tidyverse=1.2.1 \
    && \
### From conda-forge
conda install --yes -f -c conda-forge \
    natsort=5.5.0 \
    matplotlib=3.0.2 \
    numpy=1.15.4 \
    scipy=1.1 \
    statsmodels=0.9 \
    scikit-learn=0.20.1 \
    openblas=0.3.3 \
    seaborn=0.9 \
    sqlite=3.26 \
    h5py=2.8.0 \
    pandas=0.23.4 \
    openpyxl=2.5.9 \
    ftputil=3.4 \
    cmake=3.12 \
    && \
### Clean cache
    conda clean -tipsy

USER root
## Install pyHKL for jovyan
RUN ldconfig && git clone -j8 --recurse-submodules https://github.com/grzadr/hkl.git && \
    cd hkl && mkdir build && cd build && cmake .. && make -j8 install && \
    chown jovyan:users /opt/conda/lib/python3.6/* && cd ../.. && rm -rf hkl

USER jovyan
WORKDIR /home/jovyan
