#!/usr/bin/env bash
################################################################################
# Build a devcontainer variant locally.
#
# When working locally, run this before "Rebuild Container" in VS Code.
################################################################################

REGISTRY="ghcr.io/kbotteon/devtools"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

build_base() {
    docker build \
        --cache-from "${REGISTRY}/base:latest" \
        -t "${REGISTRY}/base:latest" \
        "${DIR}/base"
}

build_fpga() {
    docker build \
        --cache-from "${REGISTRY}/base:latest" \
        --cache-from "${REGISTRY}/fpga:latest" \
        -t "${REGISTRY}/fpga:latest" \
        "${DIR}/fpga"
}

case "${1}" in
    base) build_base ;;
    fpga) build_fpga ;;
    all)  build_base && build_fpga ;;
    *)
        echo "Usage: $(basename "$0") [base|fpga|all]"
        exit 1
        ;;
esac
