#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMPOSE_DIR="$REPO_ROOT/compose"
ENV_FILE="$REPO_ROOT/config/env/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE. Copy config/env/.env.example first."
  exit 2
fi

echo "Starting Harmonia - Recommended Default Stack"
echo "This starts core infrastructure plus the main tools layer."
echo "Main entry point: http://ai.localhost"

cd "$COMPOSE_DIR"
docker compose \
  --env-file "$ENV_FILE" \
  -f docker-compose.yml \
  -f docker-compose.tools.yml \
  --profile infra \
  --profile tools \
  up -d

echo
echo "Dashboard: http://ai.localhost"
echo "OpenWebUI: http://openwebui.localhost"
echo "MLflow: http://mlflow.localhost"
echo "Adminer: http://db.localhost"
