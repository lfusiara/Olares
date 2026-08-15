#!/usr/bin/env bash

set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEMP_ROOT"' EXIT

OLARES_TOOLBOX_BIN_DIR="$TEMP_ROOT/bin" \
OLARES_TOOLBOX_LIB_DIR="$TEMP_ROOT/lib" \
OLARES_TOOLBOX_PROFILE_FILE="$TEMP_ROOT/profile" \
  "$ROOT/install.sh" >/dev/null

for command_name in olares-codex-list olares-codex-usb olares-ha-port-forward; do
  [[ -x "$TEMP_ROOT/bin/$command_name" ]]
done
[[ -f "$TEMP_ROOT/lib/codex-targets.sh" ]]
bash -n "$TEMP_ROOT/bin/olares-codex-list" \
  "$TEMP_ROOT/bin/olares-codex-usb" \
  "$TEMP_ROOT/bin/olares-ha-port-forward"
printf 'OK\n'
