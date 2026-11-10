#!/bin/sh
set -eu
. "$(dirname -- "$0")/common.sh"

require_docker
docker compose down
echo "MAJAX ML-KEM engine stopped."
