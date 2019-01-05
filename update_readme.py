#! /usr/bin/python3

from time import gmtime, strftime


def main():
    readme = open("README.md", "w")

    print("# BioSAK", file=readme)
    print("## _Biological Swiss Army Knife created with Docker!_", file=readme)
    # print("---", file=readme)
    print(file=readme)
    print("## _Version_: {}".format(strftime("%y%m%d", gmtime())), file=readme)
    # print("---", file=readme)
    print(file=readme)
    print("## _Description_:", file=readme)
    print(file=readme)
    print("""This repository contains Docker environment for execution of biological
    pipelines, data exploration and mining and many more. It is based on Jupyter
    repository [Dockerhub:jupyter/datascience-notebook](https://hub.docker.com/r/jupyter/datascience-notebook/)
    with additional packages like bwa, samtools and more. Packages are installed with conda.
    Additionally HKL library is installed""", file=readme)

    print(file=readme)
    print("## _Packages_:", file=readme)
    print(file=readme)
    print("#### _Conda_:", file=readme)
    for line in open("conda_packages.txt"):
        line = line.rstrip()

        if line.startswith("#"):
            print("##### _{}_:".format(line.lstrip("# ")), file=readme)
            print("|      Name      |     Version     |", file=readme)
            print("|:---------------|:----------------|", file=readme)
        elif not len(line):
            print(file=readme)
        else:
            print("|{}|{}".format(*line.rstrip().split("=")), file=readme)

if __name__ == "__main__":
    main()
