#!/bin/bash

set -eux

IMAGE_NAME="grzadr/biosak"
DATE_TAG=$(date '+%y-%m-%d')

docker push "${IMAGE_NAME}":latest
docker push "${IMAGE_NAME}":"${DATE_TAG}"
