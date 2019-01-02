FROM jupyter/datascience-notebook:latest

LABEL version="181227" maintainer="Adrian Grzemski <adrian.grzemski@gmail.com>"

USER root
### Update system
RUN apt update && apt full-upgrade -y

### Install necessery packages for library building
RUN apt install -y \
    build-essential \
    software-properties-common \
    tree \
    ncdu \
 && apt install python3-roman && \
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
    conda install --yes -f \
    # Bioinformatics
    snakemake=5.4.0 \
    bwa=0.7.17 \
    minimap2=2.14 \
    picard=2.18.21 \
    fastqc=0.11.8 \
    multiqc=1.6 \
    samtools=1.9 \
    bcftools=1.9 \
    htslib=1.9 \
    bamtools=2.5.1 \
    gatk4=4.0.12.0 \
    # R Project
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
    # Python Related
    natsort=5.5.0 \
    matplotlib=3.0.2 \
    numpy=1.15.4 \
    scipy=1.2.0 \
    statsmodels=0.9 \
    scikit-learn=0.20.2 \
    openblas=0.3.3 \
    seaborn=0.9 \
    sqlite=3.26.0 \
    h5py=2.9.0 \
    hdf5=1.10.4 \
    pandas=0.23.4 \
    openpyxl=2.5.12 \
    ftputil=3.4 \
    cmake=3.13.2 \
    markdown=3.0.1 \
    rsa=3.4.2 \
    sympy=1.3 \
    qt=5.9.6 \
    pyqt=5.9.6 \
    numba=0.41 \
    cython=0.29.2 \
    alembic=1.0.5 \
    dropbox=9.3.0 \
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
