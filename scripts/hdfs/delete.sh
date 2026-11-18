
#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

TARGET="${1:?Usage: delete.sh <hdfs-path> [--recursive]}"

hdfs_check
hdfs_validate_path "$TARGET"

if [[ "$TARGET" == "/" ]]; then
    echo "ERROR: Refusing to delete HDFS root." >&2
    exit 1
fi

if ! hdfs_exec -test -e "$TARGET"; then
    echo "ERROR: HDFS path does not exist: $TARGET" >&2
    exit 1
fi

if [[ "${2:-}" == "--recursive" ]]; then
    hdfs_exec -rm -r "$TARGET"
else
    hdfs_exec -rm "$TARGET"
fi

echo "Deleted: $TARGET"

