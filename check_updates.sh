#!/bin/bash

set -eux

docker run -it "grzadr/biosak:${1:-latest}" condaup --dry-run
