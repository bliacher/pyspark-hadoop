
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

HOST="${1:-namenode}"

echo "Checking hostname resolution from spark-client: $HOST"

docker compose exec -T spark-client \
  getent hosts "$HOST"

echo "Hostname resolution successful."

