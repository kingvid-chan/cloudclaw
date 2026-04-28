#!/usr/bin/env bash
# Cloud 接入版的 OpenClaw 启动包装
# 显式叠加 .cloudclaw/docker-compose.override.yml,使 agent 启动读到 Cloud 人格
# 用法: ./.cloudclaw/start.sh {up|down|tui|logs|status|config|restart|recreate|yolo-tui}
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_DIR="$(cd "$ROOT_DIR/.." && pwd)"
BASE="$ROOT_DIR/docker-compose.yml"
OVERRIDE="$SCRIPT_DIR/docker-compose.override.yml"

if [[ ! -f "$BASE" ]];     then echo "missing $BASE" >&2; exit 1; fi
if [[ ! -f "$OVERRIDE" ]]; then echo "missing $OVERRIDE" >&2; exit 1; fi

if [[ -f "$ROOT_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
  set +a
fi

if [[ -f "$SCRIPT_DIR/env.local" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$SCRIPT_DIR/env.local"
  set +a
fi

resolve_gemini_cli_dir() {
  if [[ -n "${CLOUDCLAW_GEMINI_CLI_DIR:-}" ]]; then
    printf '%s\n' "$CLOUDCLAW_GEMINI_CLI_DIR"
    return
  fi

  local npm_root=""
  npm_root="$(npm root -g 2>/dev/null || true)"
  if [[ -n "$npm_root" && -d "$npm_root/@google/gemini-cli" ]]; then
    printf '%s\n' "$npm_root/@google/gemini-cli"
    return
  fi

  local nvm_candidate
  for nvm_candidate in "$HOME"/.nvm/versions/node/*/lib/node_modules/@google/gemini-cli; do
    if [[ -d "$nvm_candidate" ]]; then
      printf '%s\n' "$nvm_candidate"
      return
    fi
  done

  echo "missing Gemini CLI package dir; set CLOUDCLAW_GEMINI_CLI_DIR" >&2
  exit 1
}

export CLOUDCLAW_PRIVATE_DIR="${CLOUDCLAW_PRIVATE_DIR:-$WORKSPACE_DIR/cloudclaw-private/.cloudclaw}"
export CLOUDCLAW_WRAPPER_PATH="${CLOUDCLAW_WRAPPER_PATH:-$SCRIPT_DIR/gemini-wrapper.sh}"
export CLOUDCLAW_LIFE_SYSTEM_DIR="${CLOUDCLAW_LIFE_SYSTEM_DIR:-$(cd "$WORKSPACE_DIR/.." && pwd)}"
export CLOUDCLAW_LIFE_SYSTEM_MOUNT="${CLOUDCLAW_LIFE_SYSTEM_MOUNT:-/home/node/.openclaw/workspace/人生系统}"
export CLOUDCLAW_GEMINI_HOME_DIR="${CLOUDCLAW_GEMINI_HOME_DIR:-$HOME/.gemini}"
export CLOUDCLAW_GEMINI_CLI_DIR="$(resolve_gemini_cli_dir)"
export OPENCLAW_WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"

for required_path in \
  "$CLOUDCLAW_PRIVATE_DIR" \
  "$CLOUDCLAW_WRAPPER_PATH" \
  "$CLOUDCLAW_LIFE_SYSTEM_DIR" \
  "$CLOUDCLAW_GEMINI_CLI_DIR"; do
  if [[ ! -e "$required_path" ]]; then
    echo "missing required CloudClaw path: $required_path" >&2
    exit 1
  fi
done

for required_private_file in \
  SOUL.md \
  USER.md \
  AGENTS.md \
  HEARTBEAT.md \
  MEMORY_PROTOCOL.md \
  SELF_REVIEW.md \
  PROMPT_REVIEW_TEMPLATE.md; do
  if [[ ! -f "$CLOUDCLAW_PRIVATE_DIR/$required_private_file" ]]; then
    echo "missing required CloudClaw private file: $CLOUDCLAW_PRIVATE_DIR/$required_private_file" >&2
    exit 1
  fi
done

prepare_workspace_mountpoints() {
  mkdir -p "$OPENCLAW_WORKSPACE_DIR"
  for mount_file in \
    SOUL.md \
    USER.md \
    AGENTS.md \
    HEARTBEAT.md \
    MEMORY_PROTOCOL.md \
    SELF_REVIEW.md \
    PROMPT_REVIEW_TEMPLATE.md; do
    [[ -e "$OPENCLAW_WORKSPACE_DIR/$mount_file" ]] || : > "$OPENCLAW_WORKSPACE_DIR/$mount_file"
  done

  mkdir -p \
    "$OPENCLAW_WORKSPACE_DIR/对话纪要" \
    "$OPENCLAW_WORKSPACE_DIR/周度报告" \
    "$OPENCLAW_WORKSPACE_DIR/提案"
}

prepare_workspace_mountpoints

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
  config)
    "${COMPOSE[@]}" config --quiet
    ;;
  *)
    echo "Usage: $0 {up|down|tui|logs|status|config|restart|recreate|yolo-tui}" >&2
    exit 1
    ;;
esac
