#!/bin/bash

python3 update_readme.py
docker build --pull \
  --build-arg current_date="$(date '+%F')" \
  -t grzadr/biosak:testing .

docker system prune
