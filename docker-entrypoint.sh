#!/bin/sh
set -eu

RETIPEDIA_HOME="${RETIPEDIA_HOME:-/srv/pages/Retipedia}"
RETIPEDIA_DATA_DIR="${RETIPEDIA_DATA_DIR:-/var/lib/rns-page-node}"
RETICULUM_IDENTITY_DIR="${RETICULUM_IDENTITY_DIR:-$RETIPEDIA_DATA_DIR/identity}"
RETICULUM_CONFIG_PATH="${RETICULUM_CONFIG_PATH:-${RETICULUM_CONFIG_DIR:-$RETIPEDIA_DATA_DIR/reticulum}}"
export RETIPEDIA_ZIMS_DIR="${RETIPEDIA_ZIMS_DIR:-/zims}"

mkdir -p \
  "$RETICULUM_IDENTITY_DIR" \
  "$RETICULUM_CONFIG_PATH" \
  "$RETIPEDIA_DATA_DIR/retipedia/zims" \
  "$RETIPEDIA_DATA_DIR/retipedia/cache" \
  "$RETIPEDIA_DATA_DIR/Retipedia/images"

if [ "${RETIPEDIA_GENERATE_META:-true}" = "true" ]; then
  if [ "${RETIPEDIA_GENERATE_META_FORCE:-false}" = "true" ]; then
    python3 "$RETIPEDIA_HOME/generate_meta.py" --force
  else
    python3 "$RETIPEDIA_HOME/generate_meta.py"
  fi
fi

set -- rns-page-node \
  --node-name "${RETIPEDIA_NODE_NAME:-Retipedia}" \
  --pages-dir /srv/pages \
  --files-dir /srv/files \
  --media-dir "$RETIPEDIA_DATA_DIR" \
  --identity-dir "$RETICULUM_IDENTITY_DIR" \
  --announce-interval "${RETIPEDIA_ANNOUNCE_INTERVAL:-360}" \
  --page-refresh-interval "${RETIPEDIA_PAGE_REFRESH_INTERVAL:-0}" \
  --file-refresh-interval "${RETIPEDIA_FILE_REFRESH_INTERVAL:-0}" \
  --log-level "${RETIPEDIA_LOG_LEVEL:-INFO}" "$@"

set -- "$@" --config "$RETICULUM_CONFIG_PATH"

exec "$@"
