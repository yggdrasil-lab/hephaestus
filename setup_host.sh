#!/bin/bash
# Setup script for Hephaestus
# Creates persistent storage directory on the host

HOST_PATH="/mnt/storage/registry"

echo "Setting up host directory: $HOST_PATH"
mkdir -p "$HOST_PATH"
chown -R 1000:1000 "$HOST_PATH"

echo "Setup complete."
