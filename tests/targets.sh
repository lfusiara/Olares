#!/usr/bin/env bash

set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

kubectl() {
  case "$*" in
    *"get pods -A"*)
      printf 'codex-alice\ncodex-bob\n'
      ;;
    *"-n codex-alice get deploy"*)
      printf 'codex-alice-deployment\n'
      ;;
    *"-n codex-bob get deploy"*)
      printf 'codex-bob-deployment\n'
      ;;
    *)
      printf 'Nieoczekiwane wywolanie kubectl: %s\n' "$*" >&2
      return 1
      ;;
  esac
}

source "$ROOT/lib/codex-targets.sh"
discover_codex_targets
[[ ${#CODEX_TARGETS[@]} -eq 2 ]]
select_codex_target codex-bob codex-bob-deployment
[[ "$CODEX_NAMESPACE" == codex-bob ]]
[[ "$CODEX_DEPLOYMENT" == codex-bob-deployment ]]
printf 'OK\n'
