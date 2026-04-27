#!/usr/bin/env bash
# Cloud 接入版的 OpenClaw 启动包装
# 显式叠加 .cloudclaw/docker-compose.override.yml,使 agent 启动读到 Cloud 人格
# 用法: ./.cloudclaw/start.sh {up|down|tui|logs|status|restart|recreate|yolo-tui}
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BASE="$ROOT_DIR/docker-compose.yml"
OVERRIDE="$SCRIPT_DIR/docker-compose.override.yml"

if [[ ! -f "$BASE" ]];     then echo "missing $BASE" >&2; exit 1; fi
if [[ ! -f "$OVERRIDE" ]]; then echo "missing $OVERRIDE" >&2; exit 1; fi

export CLOUDCLAW_PRIVATE_DIR="${CLOUDCLAW_PRIVATE_DIR:-$ROOT_DIR/../cloudclaw-private/.cloudclaw}"
if [[ ! -d "$CLOUDCLAW_PRIVATE_DIR" ]]; then
  echo "missing private Cloud state dir: $CLOUDCLAW_PRIVATE_DIR" >&2
  exit 1
fi

cd "$ROOT_DIR"
COMPOSE=(docker compose --env-file "$ROOT_DIR/.env" -f "$BASE" -f "$OVERRIDE")

case "${1:-status}" in
  up)
    "${COMPOSE[@]}" up -d openclaw-gateway
    echo ""
    echo "Cloud 接入版 gateway 已启动. 进 TUI: $0 tui"
    ;;
  restart)
    "${COMPOSE[@]}" restart openclaw-gateway
    ;;
  recreate)
    "${COMPOSE[@]}" up -d --force-recreate openclaw-gateway
    ;;
  down)
    "${COMPOSE[@]}" down
    ;;
  tui)
    "${COMPOSE[@]}" run --rm openclaw-cli tui
    ;;
  yolo-tui)
    CLOUDCLAW_GEMINI_APPROVAL_MODE=yolo "${COMPOSE[@]}" run --rm openclaw-cli tui
    ;;
  logs)
    "${COMPOSE[@]}" logs -f openclaw-gateway
    ;;
  status)
    "${COMPOSE[@]}" ps
    ;;
  *)
    echo "Usage: $0 {up|down|tui|logs|status|restart|recreate|yolo-tui}" >&2
    exit 1
    ;;
esac
