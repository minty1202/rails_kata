#!/usr/bin/env bash
set -e

# 既存の Puma PID を掃除
rm -f /app/tmp/pids/server.pid 2>/dev/null || true

exec "$@"
