FROM jupyter/datascience-notebook:latest

LABEL version="190125"
LABEL maintainer="Adrian Grzemski <adrian.grzemski@gmail.com>"

USER root
# Add specific group
RUN groupadd -g 119 qnap && usermod -aG qnap jovyan
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
    apt-utils \
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

# Install extra packages listed in conda_packages
RUN conda install \
  --yes \
  --force \
  --no-channel-priority \
  --file conda_packages.txt \
  > conda_install.log \
### Clean cache
 && conda clean -tipsy

USER root

# Install newest vim from external repo
RUN add-apt-repository ppa:jonathonf/vim -y \
 && sudo apt install -y \
    vim \
    ctags \
    vim-doc \
    vim-scripts

## Install pyHKL for jovyan
RUN ldconfig \
 && git clone -j8 --recurse-submodules https://github.com/grzadr/hkl.git \
 && cd hkl && mkdir build && cd build && cmake .. && make -j8 install \
 && chown jovyan:users /opt/conda/lib/python3.6/* && cd ../.. && rm -rf hkl
 
# && git clone -j8 --recurse-submodules https://github.com/grzadr/VCFLite \
# && cd VCFLite && mkdir build && cd build && cmake .. && make -j8 install \
# && cd .. && rm -rf VCFLite

USER jovyan

# Configure vim
RUN mkdir .vim \
 && cd .vim \
 && git clone https://github.com/grzadr/grzadr_vim.git ./ \
 && cd .. \
 && chown jovyan:users -R .vim \
 && ln -s .vim/vimrc .vimrc \
 && vim -c "PlugInstall|qa"

WORKDIR /home/jovyan
