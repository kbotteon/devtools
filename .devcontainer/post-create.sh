#!/usr/bin/env bash
################################################################################
# Serializes post-create commands
################################################################################
set -e

sudo chown -R $(whoami): /persist

mkdir -p /persist/sandboxes
[ -L /persist/sandboxes/devtools ] || ln -sfn /workspaces/devtools /persist/sandboxes/devtools

/bin/bash /persist/sandboxes/devtools/.devcontainer/environment.sh
/bin/bash /persist/sandboxes/devtools/.devcontainer/project.sh
