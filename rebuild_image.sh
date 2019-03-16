#!/bin/bash

set -eux

IMAGE_NAME="grzadr/biosak"
DATE_TAG=$(date '+%y-%m-%d')
python3 update_readme.py
docker build --pull \
  --build-arg image_label="${DATE_TAG}" \
  -t "${IMAGE_NAME}":latest \
  -t "${IMAGE_NAME}":"${DATE_TAG}" \
  .
docker push "${IMAGE_NAME}":latest
docker push "${IMAGE_NAME}":"${DATE_TAG}"

docker system prune
