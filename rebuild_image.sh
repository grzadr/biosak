#!/bin/bash

set -eux

DATE_TAG=$(date '+%y-%m-%d')
IMAGE_TAG=${1:-${DATE_TAG}}

IMAGE_NAME="grzadr/biosak"
python3 update_readme.py
docker build --pull \
  --build-arg image_label="${IMAGE_TAG}" \
  -t "${IMAGE_NAME}:${IMAGE_TAG}" \
  .

docker push "${IMAGE_NAME}:${IMAGE_TAG}"
