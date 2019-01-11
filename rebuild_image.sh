#!/bin/bash

python3 update_readme.py
docker build --pull -t grzadr/biosak .
docker system prune
