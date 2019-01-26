FROM jupyter/datascience-notebook:latest

LABEL version="190126"
LABEL maintainer="Adrian Grzemski <adrian.grzemski@gmail.com>"

USER root
# Add specific group
RUN groupadd -g 119 qnap && usermod -aG qnap jovyan
### Update system
RUN apt update && apt full-upgrade -y

### Install necessery packages for library building
RUN sudo apt install -y \
    build-essential \
    software-properties-common \
    tree \
    ncdu \
    nano \
    libssl1.0.0 libssl-dev \
    apt-utils \
    python3-roman \
 && cp /usr/lib/python3/dist-packages/roman.py /opt/conda/lib/python3.6 \
 && chown jovyan /opt/conda/lib/python3.6/roman.py \
 && apt autoremove -y && apt clean -y \
 && add-apt-repository ppa:jonathonf/vim -y \
 && apt install -y \
    vim \
    ctags \
    vim-doc \
    vim-scripts

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

#Configure Jupyter notebooks

 RUN jupyter contrib nbextension install --user \
 && jupyter nbextension enable scroll_down/main \
 && jupyter nbextension enable toc2/main \
 && jupyter nbextension enable execute_time/ExecuteTime \
 && jupyter nbextension enable hide_header/main \
 && jupyter nbextension enable nbextensions_configurator/tree_tab/main \
 && jupyter nbextension enable printview/main \
 && jupyter nbextension enable table_beautifier/main \
 && jupyter nbextension enable contrib_nbextensions_help_item/main \
 && jupyter nbextension enable hinterland/hinterland \
 && jupyter nbextension enable nbextensions_configurator/config_menu/main \
 && jupyter nbextension enable python-markdown/main \
 && jupyter nbextension enable code_prettify/autopep8

WORKDIR /home/jovyan
