#!/bin/sh

DOCKER_TAG=${1:-docker-kotlin}
DOCKER_PLATFORM=${2:-linux/amd64}

docker build --platform "$DOCKER_PLATFORM" -t "$DOCKER_TAG" .