
#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

SOURCE="${1:?Usage: update.sh <local-file> <hdfs-destination>}"
DEST="${2:?Usage: update.sh <local-file> <hdfs-destination>}"

hdfs_check
hdfs_validate_path "$DEST"

SOURCE_ABS="$(cd "$(dirname "$SOURCE")" && pwd)/$(basename "$SOURCE")"

if [[ ! -f "$SOURCE_ABS" ]]; then
    echo "ERROR: Local source must be a file: $SOURCE" >&2
    exit 1
fi

if ! hdfs_exec -test -f "$DEST"; then
    echo "ERROR: Destination file does not exist: $DEST" >&2
    exit 1
fi

TEMP_PATH="/tmp/hdfs-update-$(date +%s)-$$"

cd "$PROJECT_ROOT"

docker compose cp "$SOURCE_ABS" "namenode:$TEMP_PATH"

hdfs_exec -put -f "$TEMP_PATH" "$DEST"

docker compose exec -T namenode rm -f "$TEMP_PATH"

echo "Updated: $DEST"

