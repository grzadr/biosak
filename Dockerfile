#FROM jupyter/datascience-notebook:abdb27a6dfbb
FROM grzadr/workhaven:19-05-27

LABEL version=19-05-27
LABEL maintainer="Adrian Grzemski <adrian.grzemski@gmail.com>"

ENV CONDA_PYTHON_VERSION=3.6
ENV CONDA_LIB_DIR=$CONDA_DIR/lib/python$CONDA_PYTHON_VERSION
ENV CPATH="/opt/conda/include/:${CPATH}"
ENV LD_LIBRARY_PATH="/opt/conda/lib:${LD_LIBRARY_PATH}"

WORKDIR /home/jovyan

ADD --chown=jovyan:users packages ./packages

USER root
RUN apt update \
 && apt install -y $(cat packages/packages_apt.list | tr '\n' ' ') \
    >> logs/apt_install.log \
 && chown -R jovyan:users logs \
 && apt_vacuum \
 && ldconfig

WORKDIR $GIT_DIRECTORY

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

RUN Rscript -e 'if (!requireNamespace("BiocManager", quietly = TRUE))\
    install.packages("BiocManager");\
  BiocManager::install("cn.mops");'

USER jovyan
WORKDIR "${HOME}"

# Install extra packages listed in conda_packages
RUN conda install \
    --yes \
    --no-channel-priority \
    --prune \
    --file packages/packages_conda.list \
    >> logs/conda_install.log \
### Clean cache
 && conda clean --all \
 && conda list > conda_installed.list

WORKDIR /home/jovyan

ARG ROOT_PACKAGE="root_v6.16.00.Linux-ubuntu18-x86_64-gcc7.3.tar.gz"

RUN wget "https://root.cern/download/${ROOT_PACKAGE}" -O root.tar.gz \
 && tar -xvzf root.tar.gz \
 && rm root.tar.gz

ENV ROOTSYS="${HOME}/root"
ENV PATH="${PATH}:${ROOTSYS}/bin"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${ROOTSYS}/lib"

WORKDIR "${GIT_DIRECTORY}"

RUN wget https://github.com/abyzovlab/CNVnator/releases/download/v0.4/CNVnator_v0.4.zip -O CNVnator.zip \
 && wget https://github.com/abyzovlab/CNVnator/releases/download/v0.3.3/CNVnator_v0.3.3.zip -O CNVnator0.3.3.zip \
 && unzip CNVnator.zip \
 && mv CNVnator_v0.4 CNVnator \
 && unzip CNVnator0.3.3.zip \
 && cp -r CNVnator_v0.3.3/src/samtools CNVnator/src/samtools \
 && rm -rf CNVnator0.3.3 \
 && rm CNVnator.zip CNVnator0.3.3.zip

WORKDIR CNVnator/src/samtools

RUN make -j32 \
 && cd ../ \
 && make -j32 \
 && cp cnvnator ../

ENV PATH="${PATH}:${GIT_DIRECTORY}/CNVnator"

WORKDIR /home/jovyan
