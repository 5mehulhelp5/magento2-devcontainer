#!/bin/bash

# Host-side devcontainer bootstrap, run from initializeCommand BEFORE the
# container is created. Seeds the per-project files the compose stack needs
# from the submodule's samples on first run.
#
# This lives in a script (rather than as parallel initializeCommand keys)
# because the samples live inside the submodule: the copies must run AFTER the
# submodule is checked out. initializeCommand inits the submodule first, then
# invokes this, keeping the ordering deterministic instead of racing.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUBMODULE_DIR="$(dirname "$SCRIPT_DIR")"        # .devcontainer/magento2-devcontainer
DEVCONTAINER_DIR="$(dirname "$SUBMODULE_DIR")"  # .devcontainer

# .env and docker-compose.local.yml are gitignored / per-project, and
# docker-compose.local.yml is referenced by dockerComposeFile — so the
# container won't build without them. Seed from samples if missing.
[ -f "$DEVCONTAINER_DIR/.env" ] \
    || cp "$SUBMODULE_DIR/.env.sample" "$DEVCONTAINER_DIR/.env"
[ -f "$DEVCONTAINER_DIR/docker-compose.local.yml" ] \
    || cp "$SUBMODULE_DIR/docker-compose.local.yml.sample" "$DEVCONTAINER_DIR/docker-compose.local.yml"
