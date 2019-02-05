FROM jupyter/datascience-notebook:latest

LABEL version="190205"
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
 && add-apt-repository ppa:jonathonf/vim -y \
 && add-apt-repository ppa:ubuntu-toolchain-r/ppa \
 && apt install -y \
    vim \
    ctags \
    vim-doc \
    vim-scripts \
    gcc-8-multilib \
    g++-8-multilib \
 && (update-alternatives --remove-all gcc || true) \
 && (update-alternatives --remove-all g++ || true) \
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
 && conda clean --all

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
 && jupyter nbextension enable printview/main \
 && jupyter nbextension enable table_beautifier/main \
 && jupyter nbextension enable contrib_nbextensions_help_item/main \
 && jupyter nbextension enable hinterland/hinterland \
 && jupyter nbextension enable python-markdown/main \
 && jupyter nbextension enable code_prettify/autopep8

WORKDIR /home/jovyan
