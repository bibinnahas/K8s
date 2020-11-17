#!/usr/bin/env bash

set -euox pipefail # exit on first failure

export SOURCE_COMMIT=$(git rev-parse --short HEAD)
export PYSPARK_TAG="image.name:${SOURCE_COMMIT}"
docker build . -f Dockerfile -t ${PYSPARK_TAG}
docker push ${PYSPARK_TAG}