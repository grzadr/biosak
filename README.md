# BioSAK
### _BIOlogical Swiss Army Knife created with Docker!_
---

### _Version_: 181218
---

### _Description_:

This repository contains Docker environment for execution of biological
pipelines, data exploration and mining and many more. It is based on Jupyter
repository [Dockerhub:jupyter/datascience-notebook](https://hub.docker.com/r/jupyter/datascience-notebook/)
with additional packages like bwa, samtools and more. Packages are installed with conda.
Additionally HKL library is installed

---

### _Packages_:
| Repository      |      Name        | Version          |
|:----------------|:-----------------|:-----------------|
| **bioconda**    | snakemake        | 5.3.0            |
|                 | bwa              | 0.7.17           |
|                 | minimap2         | 2.14             |
|                 | picard           | 2.18.21          |
|                 | fastqc           | 0.11.8           |
|                 | multiqc          | 1.6              |
|                 | samtools         | 1.9              |
|                 | bcftools         | 1.9              |
|                 | htslib           | 1.9              |
|                 | bamtools         | 2.5.1            |
|                 | gatk4            | 4.0.12.0         |
|  **r**          | r-base           | 3.5.1            |
|                 | r-htmlwidgets    | 1.2              |
|                 | r-rsqlite        | 2.1.1            |
|                 | r-forecast       | 8.4              |
|                 | r-nycflights13   | 1.0              |
|                 | r-sparklyr       | 0.8.4            |
|                 | r-shiny          | 1.1              |
|                 | rpy2             | 2.9.4            |
|                 | r-rmarkdown      | 1.10             |
|                 | r-tidyverse      | 1.2.1            |
| **conda-forge** | natsort          | 5.5.0            |
|                 | matplotlib       | 3.0.2            |
|                 | numpy            | 1.15.4           |
|                 | statsmodels      | 0.9              |
|                 | scipy            | 1.1.0            |
|                 | scikit-learn     | 0.20.1           |
|                 | openblas         | 0.3.4            |
|                 | seaborn          | 0.9              |
|                 | sqlite           | 3.26             |
|                 | h5py             | 2.8.0            |
|                 | pandas           | 0.23.4           |
|                 | openpyxl         | 2.5.9            |
|                 | ftputil          | 3.4              |
|                 | cmake            | 3.13.1           |
| **github**      | grzadr/agizmo    | master           |
|                 | grzadr/hkl       | master           |
