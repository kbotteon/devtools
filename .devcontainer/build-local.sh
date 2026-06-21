#!/usr/bin/env bash
################################################################################
# Build a devcontainer variant locally.
#
# When working locally, run this before "Rebuild Container" in VS Code to
# test that it'll actually build.
################################################################################

export DOCKER_BUILDKIT=1

REGISTRY="ghcr.io/kbotteon/devtools"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker build \
    --cache-from "${REGISTRY}/base:latest" \
    -t "${REGISTRY}/base:latest" \
    "${DIR}"
