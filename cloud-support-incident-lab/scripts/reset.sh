#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "Resetting the entire lab and deleting local volumes..."
docker compose down -v --remove-orphans
docker compose up -d --build
