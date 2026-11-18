
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

JOB="${1:?Usage: run-local.sh <job-name> [--config path] [job-args...]}"
shift

uv run python scripts/spark/runner.py \
  "$JOB" \
  --config config/spark/local.yaml \
  "$@"

