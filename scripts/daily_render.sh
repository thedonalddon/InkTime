#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# InkTime 每日渲染脚本
# =========================================================

# 修改为你的项目目录
PROJECT_DIR="/path/to/inktime"

VENV_DIR="$PROJECT_DIR/venv"
PYTHON_BIN="$VENV_DIR/bin/python"
LOG_DIR="$PROJECT_DIR/logs"

LOCK_DIR="$PROJECT_DIR/tmp/inktime_render.lockdir"

mkdir -p "$LOG_DIR" "$PROJECT_DIR/tmp"
cd "$PROJECT_DIR"

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  echo "[$(date '+%F %T')] another render is running, skip." >> "$LOG_DIR/render.log"
  exit 0
fi

cleanup() {
  rmdir "$LOCK_DIR" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo "[$(date '+%F %T')] render start" >> "$LOG_DIR/render.log"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "[$(date '+%F %T')] ERROR: python not found in venv: $PYTHON_BIN" >> "$LOG_DIR/render.log"
  exit 1
fi

if [[ ! -f "config.py" ]]; then
  echo "[$(date '+%F %T')] ERROR: config.py not found in project dir" >> "$LOG_DIR/render.log"
  exit 1
fi

"$PYTHON_BIN" render_daily_photo.py >> "$LOG_DIR/render.log" 2>&1

echo "[$(date '+%F %T')] render done" >> "$LOG_DIR/render.log"