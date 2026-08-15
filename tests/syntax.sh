#!/usr/bin/env bash

set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
bash -n "$ROOT/install.sh" "$ROOT/lib/codex-targets.sh" "$ROOT"/bin/*
bash -n "$ROOT"/tests/*.sh
grep -Fq -- '--namespace' "$ROOT/bin/olares-ha-port-forward"
grep -Fq 'port-forward.conf' "$ROOT/bin/olares-ha-port-forward"
grep -Fq 'config set' "$ROOT/README.md"
grep -Fq -- '--namespace' "$ROOT/bin/olares-codex-usb"
grep -Fq 'CharDevice' "$ROOT/bin/olares-codex-usb"
grep -Fq 'readOnly: true' "$ROOT/bin/olares-codex-usb"
"$ROOT/tests/targets.sh"
"$ROOT/tests/install.sh"
printf 'OK\n'
