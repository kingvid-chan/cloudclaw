#!/bin/sh
# Gemini CLI wrapper — bridge between OpenClaw cli-backend's `exec gemini` and
# the host-mounted @google/gemini-cli npm package at /opt/gemini-cli.
# Mounted into container as /usr/local/bin/gemini via .cloudclaw/docker-compose.override.yml.
#
# CLOUDCLAW_GEMINI_APPROVAL_MODE defaults to auto_edit:
#   auto_edit: auto-approve edit/write tools (Cloud needs to write
#              对话纪要/周度报告/提案 产出区), while shell tools still require
#              confirmation (non-interactive => effectively rejected, aligning
#              with AGENTS.md §4 git 禁令).
#   yolo:      maintenance-only mode. It also allows shell tools, so use only
#              with the read-only/RW bind mounts in docker-compose.override.yml.
# OpenClaw cli-backend appends: --skip-trust --output-format json --prompt {prompt}
# If this wrapper is already mounted in a running container and behavior looks
# stale, run `.cloudclaw/start.sh recreate` once to refresh the bind mount.
APPROVAL_MODE="${CLOUDCLAW_GEMINI_APPROVAL_MODE:-auto_edit}"
exec node /opt/gemini-cli/bundle/gemini.js --approval-mode "$APPROVAL_MODE" "$@"
