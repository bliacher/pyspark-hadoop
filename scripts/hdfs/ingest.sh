
#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

SOURCE="${1:?Usage: ingest.sh <local-path> <hdfs-destination>}"
DEST="${2:?Usage: ingest.sh <local-path> <hdfs-destination>}"

hdfs_check
hdfs_validate_path "$DEST"

SOURCE_ABS="$(cd "$(dirname "$SOURCE")" && pwd)/$(basename "$SOURCE")"

if [[ ! -e "$SOURCE_ABS" ]]; then
    echo "ERROR: Local source does not exist: $SOURCE" >&2
    exit 1
fi

# Copy source into the NameNode container.
TEMP_PATH="/tmp/hdfs-ingest-$(date +%s)-$$"

cd "$PROJECT_ROOT"

docker compose cp "$SOURCE_ABS" "namenode:$TEMP_PATH"

# Ensure destination parent exists.
hdfs_exec -mkdir -p "$(dirname "$DEST")"

# Reject existing destinations.
if hdfs_exec -test -e "$DEST"; then
    echo "ERROR: Destination already exists: $DEST" >&2
    docker compose exec -T namenode rm -rf "$TEMP_PATH"
    exit 1
fi

hdfs_exec -put "$TEMP_PATH" "$DEST"

docker compose exec -T namenode rm -rf "$TEMP_PATH"

echo "Ingested: $SOURCE -> $DEST"

