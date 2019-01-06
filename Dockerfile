FROM jupyter/datascience-notebook:latest

LABEL version="190106"
LABEL maintainer="Adrian Grzemski <adrian.grzemski@gmail.com>"

USER root
### Update system
RUN apt update && apt full-upgrade -y

### Install necessery packages for library building
RUN apt install -y \
    build-essential \
    software-properties-common \
    tree \
    ncdu \
    nano \
    libssl1.0.0 libssl-dev \
 && apt install python3-roman && \
    cp /usr/lib/python3/dist-packages/roman.py /opt/conda/lib/python3.6 && \
    chown jovyan /opt/conda/lib/python3.6/roman.py && \
    apt autoremove -y && apt clean -y

USER jovyan

### Update conda & add repos
RUN conda update --yes -n base conda \
 && conda config --add channels bioconda \
 && conda config --add channels defaults \
 && conda config --add channels r \
 && conda config --add channels conda-forge

ADD conda_packages.txt ./conda_packages.txt

RUN conda install --yes --force --file conda_packages.txt \
### Clean cache
 && conda clean -tipsy

USER root
## Install pyHKL for jovyan
RUN apt-get install -y libssl1.0.0 libssl-dev
RUN ldconfig && git clone -j8 --recurse-submodules https://github.com/grzadr/hkl.git && \
    cd hkl && mkdir build && cd build && cmake .. && make -j8 install && \
    chown jovyan:users /opt/conda/lib/python3.6/* && cd ../.. && rm -rf hkl
RUN groupadd -g 119 qnap && usermod -aG qnap jovyan

USER jovyan
WORKDIR /home/jovyan
