#!/bin/bash

python3 update_readme.py
docker build --pull \
  --build-arg CURRENT_DATE=$(date "+%F") \
  -t grzadr/biosak:testing .

docker system prune
