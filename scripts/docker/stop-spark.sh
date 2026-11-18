
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "Stopping Apache Spark..."

docker compose stop \
  spark-client \
  spark-worker \
  spark-master

echo "Spark services stopped."

