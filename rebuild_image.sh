#!/bin/bash

python3 update_readme.py
docker build --pull -t grzadr/biosak:testing . && \
docker system prune
