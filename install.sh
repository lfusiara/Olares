#!/usr/bin/env bash

set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
BIN_DIR="${OLARES_TOOLBOX_BIN_DIR:-$HOME/.local/bin}"
LIB_DIR="${OLARES_TOOLBOX_LIB_DIR:-$HOME/.local/lib/olares-toolbox}"
PROFILE_FILE="${OLARES_TOOLBOX_PROFILE_FILE:-$HOME/.profile}"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

mkdir -p "$BIN_DIR" "$LIB_DIR"
install -m 0644 "$ROOT/lib/codex-targets.sh" "$LIB_DIR/codex-targets.sh"
for command_path in "$ROOT"/bin/*; do
  install -m 0755 "$command_path" "$BIN_DIR/${command_path##*/}"
done

if [[ "$BIN_DIR" == "$HOME/.local/bin" ]]; then
  touch "$PROFILE_FILE"
  grep -Fqx "$PATH_LINE" "$PROFILE_FILE" || printf '\n%s\n' "$PATH_LINE" >>"$PROFILE_FILE"
fi

printf 'Zainstalowano Olares toolbox w %s.\n' "$BIN_DIR"
printf 'W biezacym terminalu wykonaj:\n  export PATH="%s:$PATH"\n' "$BIN_DIR"
