
#!/usr/bin/env bash

set -euo pipefail

HDFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$HDFS_SCRIPT_DIR/../.." && pwd)"

# Execute an HDFS command inside the NameNode container.
hdfs_exec() {
    (
        cd "$PROJECT_ROOT"
        docker compose exec -T namenode hdfs dfs "$@"
    )
}

# Check that the NameNode is running.
hdfs_check() {
    (
        cd "$PROJECT_ROOT"
        if ! docker compose ps --status running --services |
            grep -qx "namenode"; then
            echo "ERROR: HDFS NameNode is not running." >&2
            exit 1
        fi
    )
}

# Validate an absolute HDFS path.
hdfs_validate_path() {
    local path="$1"

    if [[ "$path" != /* ]]; then
        echo "ERROR: HDFS path must be absolute: $path" >&2
        return 1
    fi
}

