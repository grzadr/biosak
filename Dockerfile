FROM jupyter/datascience-notebook:c39518a3252f

LABEL version=19-05-06
LABEL maintainer="Adrian Grzemski <adrian.grzemski@gmail.com>"

USER root
ENV DEBIAN_FRONTEND noninteractive

# Add usefull aliases
RUN echo '#!/bin/bash\nls -lhaF "$@"' > /usr/bin/ll && chmod +x /usr/bin/ll
RUN echo '#!/bin/bash\nconda update --all --no-channel-priority "$@"' > /usr/bin/condaup \
 && chmod +x /usr/bin/condaup


### Update system
RUN apt update && apt full-upgrade -y \
 && apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    apt-utils \
 && add-apt-repository ppa:jonathonf/vim -y \
 && add-apt-repository ppa:ubuntu-toolchain-r/ppa -y \
 && apt update \
 && apt install -y \
    man \
    vim \
    nano \
    tree \
    ncdu \
    ctags \
    vim-doc \
    vim-scripts \
    less \
    build-essential \
    gcc-8-multilib \
    g++-8-multilib \
    gfortran-8-multilib \
    g++-7-multilib \
    gfortran-7-multilib \
    libsqlite3-dev \
    libssl1.0.0 libssl-dev \
 && apt autoremove -y && apt clean -y && rm -rf /var/lib/apt/lists/

RUN (update-alternatives --remove-all gcc || true) \
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
 && update-alternatives --set gfortran /usr/bin/gfortran-8

USER jovyan

### Update conda & add repos
RUN conda update --yes -n base conda > conda_update.log \
 && conda config --add channels bioconda \
 && conda config --add channels defaults \
 && conda config --add channels r \
 && conda config --add channels conda-forge

ADD conda_packages.txt ./conda_packages.txt

# Install extra packages listed in conda_packages
RUN rm /opt/conda/conda-meta/pinned \
 && conda install \
    --yes \
    --no-channel-priority \
    --prune \
    --file conda_packages.txt \
    > conda_install.log \
### Clean cache
 && conda clean --all \
 && conda list

ENV CONDA_PYTHON_VERSION=3.6
ENV CONDA_LIB_DIR=$CONDA_DIR/lib/python$CONDA_PYTHON_VERSION

ADD pip_packages.txt ./pip_packages.txt
RUN pip install -r pip_packages.txt > pip_install.log

USER root

ENV GIT_DIRECTORY=$HOME/Git

WORKDIR $GIT_DIRECTORY

RUN git clone -j8 --recurse-submodules https://github.com/grzadr/biosh.git

ENV PATH=${PATH}:$GIT_DIRECTORY/biosh

RUN ldconfig

RUN git clone -j8 --recurse-submodules https://github.com/grzadr/hkl.git \
 && mkdir hkl/build && cd hkl/build \
 && cmake .. && make -j8 install && \
 cd ../ && rm -rf build

WORKDIR $GIT_DIRECTORY

RUN git clone -j8 --recurse-submodules https://github.com/grzadr/VCFLite.git \
 && mkdir VCFLite/build && cd VCFLite/build \
 && cmake .. && make -j8 install \
 && cd ../ && rm -rf build

RUN chown jovyan:users -R $GIT_DIRECTORY

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
 && jupyter nbextension enable code_prettify/autopep8 \
 && jupyter nbextension enable snippets/main \
 && jupyter nbextension enable varInspector/main \
 && jupyter nbextension enable code_font_size/code_font_size \
 && jupyter nbextension enable hide_input_all/main \
 && jupyter nbextension enable collapsible_headings/main

ADD --chown=jovyan:users ./jupyter_notebook_config.py /home/jovyan/.jupyter/jupyter_notebook_config.py

WORKDIR /home/jovyan
