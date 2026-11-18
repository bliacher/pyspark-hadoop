
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "Checking HDFS NameNode storage..."

# Exit codes:
# 0 = already formatted
# 1 = empty, formatting required
# 2 = nonempty but invalid storage
set +e
docker compose run --rm --no-deps --entrypoint bash namenode -c '
  DIR=/hadoop/dfs/name

  if [[ -f "$DIR/current/VERSION" ]]; then
    exit 0
  fi

  if [[ -z "$(ls -A "$DIR")" ]]; then
    exit 1
  fi

  exit 2
'
STATUS=$?
set -e

case "$STATUS" in
  0)
    echo "NameNode already formatted."
    ;;
  1)
    echo "Formatting new HDFS NameNode..."
    docker compose run --rm --no-deps namenode \
      hdfs namenode -format -nonInteractive
    echo "NameNode formatted successfully."
    ;;
  2)
    echo "ERROR: NameNode storage is nonempty but not formatted."
    echo "Refusing to format automatically."
    exit 1
    ;;
  *)
    echo "ERROR: Could not inspect NameNode storage (exit code: $STATUS)."
    exit 1
    ;;
esac

