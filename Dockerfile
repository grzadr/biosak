FROM jupyter/datascience-notebook:latest

ARG IMAGE_TAG
LABEL version=19-03-16
LABEL maintainer="Adrian Grzemski <adrian.grzemski@gmail.com>"

USER root

# Add usefull aliases
RUN echo '#!/bin/bash\nls -lha "$@"' > /usr/bin/ll && chmod +x /usr/bin/ll
RUN echo '#!/bin/bash\nconda update --all --no-channel-priority "$@"' > /usr/bin/condaup \
 && chmod +x /usr/bin/condaup

### Update system
RUN apt update && apt full-upgrade -y \
 && apt install -y \
    build-essential \
    man \
    software-properties-common \
    tree \
    ncdu \
    nano \
    libssl1.0.0 libssl-dev \
    apt-utils \
    python3-roman \
    libsqlite3-dev \
 && cp /usr/lib/python3/dist-packages/roman.py /opt/conda/lib/python3.7 \
 && chown jovyan /opt/conda/lib/python3.7/roman.py \
 && add-apt-repository ppa:jonathonf/vim -y \
 && add-apt-repository ppa:ubuntu-toolchain-r/ppa \
 && apt install -y \
    vim \
    ctags \
    vim-doc \
    vim-scripts \
    gcc-8-multilib \
    g++-8-multilib \
    gfortran-8-multilib \
    g++-7-multilib \
    gfortran-7-multilib \
 && (update-alternatives --remove-all gcc || true) \
 && (update-alternatives --remove-all g++ || true) \
 && (update-alternatives --remove-all gfortran || true) \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 10 \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 20 \
 && update-alternatives --set gcc /usr/bin/gcc-8 \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 10 \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 20 \
 && update-alternatives --set g++ /usr/bin/g++-8 \
 && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 30 \
 && update-alternatives --set cc /usr/bin/gcc \
 && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 30 \
 && update-alternatives --set c++ /usr/bin/g++ \
 && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-8 10 \
 && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-7 20 \
 && update-alternatives --set gfortran /usr/bin/gfortran-8 \
 && apt autoremove -y && apt clean -y

USER jovyan

### Update conda & add repos
RUN conda update --yes -n base conda > conda_update.log \
 && conda config --add channels bioconda \
 && conda config --add channels defaults \
 && conda config --add channels r \
 && conda config --add channels conda-forge

ADD conda_packages.txt ./conda_packages.txt

# Install extra packages listed in conda_packages
RUN conda install \
  --yes \
  --no-channel-priority \
  --prune \
  --file conda_packages.txt \
  > conda_install.log \
### Clean cache
 && conda clean --all \
 && conda list > conda_installed.txt

USER root

WORKDIR /Git/Public

## Install pyHKL for jovyan
RUN ldconfig \
 && chown jovyan:users -R . \
 && git clone -j8 --recurse-submodules https://github.com/grzadr/hkl.git \
 && cd hkl && mkdir build && cd build \
 && cmake .. && make -j8 install \
 && chown jovyan:users /opt/conda/lib/python3.7/* && cd ../.. \
 && chown jovyan:users -R hkl \
 && git clone -j8 --recurse-submodules https://github.com/grzadr/biosh.git \
 && chown jovyan:users ./biosh \
 && git clone -j8 --recurse-submodules https://github.com/grzadr/VCFLite.git \
 && cd VCFLite && mkdir build && cd build \
 && cmake .. && make install -j8 && cd ../../ \
 && chown jovyan:users -R VCFLite

ENV PATH=${PATH}:/Git/Public/biosh

USER jovyan
WORKDIR /home/jovyan

# Configure vim
RUN mkdir .vim \
 && cd .vim \
 && git clone https://github.com/grzadr/grzadr_vim.git ./ \
 && cd .. \
 && chown jovyan:users -R .vim \
 && ln -s .vim/vimrc .vimrc \
 && vim -c "PlugInstall|qa"

#Configure Jupyter notebooks
 RUN jupyter contrib nbextension install --user \
 && jupyter nbextension enable scroll_down/main \
 && jupyter nbextension enable toc2/main \
 && jupyter nbextension enable execute_time/ExecuteTime \
 && jupyter nbextension enable hide_header/main \
 && jupyter nbextension enable printview/main \
 && jupyter nbextension enable table_beautifier/main \
 && jupyter nbextension enable contrib_nbextensions_help_item/main \
 && jupyter nbextension enable hinterland/hinterland \
 && jupyter nbextension enable python-markdown/main \
 && jupyter nbextension enable code_prettify/autopep8

ADD --chown=jovyan:users ./jupyter_notebook_config.py /home/jovyan/.jupyter/jupyter_notebook_config.py

WORKDIR /home/jovyan
