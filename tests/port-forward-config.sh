#!/usr/bin/env bash

set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEMP_ROOT"' EXIT

mkdir -p "$TEMP_ROOT/bin" "$TEMP_ROOT/config" "$TEMP_ROOT/state"
cat >"$TEMP_ROOT/bin/kubectl" <<'EOF'
#!/usr/bin/env bash
if [[ "$*" == *"get pods -A"* ]]; then
  printf 'codex-one\ncodex-two\n'
elif [[ "$*" == *"-n codex-one get deploy"* ]]; then
  printf 'codex-one-deployment\n'
elif [[ "$*" == *"-n codex-two get deploy"* ]]; then
  printf 'codex-two-deployment\n'
else
  printf 'Unexpected kubectl invocation: %s\n' "$*" >&2
  exit 1
fi
EOF
chmod +x "$TEMP_ROOT/bin/kubectl"

run_forward() {
  PATH="$TEMP_ROOT/bin:$PATH" \
  OLARES_TOOLBOX_LIB_DIR="$ROOT/lib" \
  OLARES_TOOLBOX_CONFIG_DIR="$TEMP_ROOT/config" \
  OLARES_HA_FORWARD_STATE_DIR="$TEMP_ROOT/state" \
    "$ROOT/bin/olares-ha-port-forward" "$@"
}

run_forward config set \
  --namespace codex-one --deployment codex-one-deployment \
  8123:8123 1883:1883 >/dev/null
run_forward config set \
  --namespace codex-two --deployment codex-two-deployment \
  18123:8123 11883:1883 >/dev/null

config_output="$(run_forward config list)"
grep -Fq 'namespace=codex-one deployment=codex-one-deployment ports=8123:8123 1883:1883' \
  <<<"$config_output"
grep -Fq 'namespace=codex-two deployment=codex-two-deployment ports=18123:8123 11883:1883' \
  <<<"$config_output"
[[ "$(stat -c '%a' "$TEMP_ROOT/config/port-forward.conf")" == 600 ]]

run_forward config remove \
  --namespace codex-one --deployment codex-one-deployment >/dev/null
config_output="$(run_forward config list)"
[[ "$config_output" != *'namespace=codex-one '* ]]
[[ "$config_output" == *'namespace=codex-two '* ]]

printf 'OK\n'
