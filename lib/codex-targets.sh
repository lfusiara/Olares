#!/usr/bin/env bash

discover_codex_targets() {
  CODEX_TARGETS=()
  mapfile -t codex_namespaces < <(
    kubectl get pods -A -l bytetrade.io/terminal=codex \
      -o jsonpath='{range .items[*]}{.metadata.namespace}{"\n"}{end}' | sort -u
  )
  for candidate_namespace in "${codex_namespaces[@]}"; do
    [[ -n "$candidate_namespace" ]] || continue
    mapfile -t codex_deployments < <(
      kubectl -n "$candidate_namespace" get deploy -l io.kompose.service=codex \
        -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
    )
    for candidate_deployment in "${codex_deployments[@]}"; do
      [[ -n "$candidate_deployment" ]] || continue
      CODEX_TARGETS+=("$candidate_namespace|$candidate_deployment")
    done
  done
}

print_codex_targets() {
  discover_codex_targets
  if ((${#CODEX_TARGETS[@]} == 0)); then
    printf 'Nie znaleziono instancji Codex CLI.\n' >&2
    return 1
  fi
  printf 'Dostepne instancje Codex CLI:\n'
  for index in "${!CODEX_TARGETS[@]}"; do
    IFS='|' read -r namespace deployment <<<"${CODEX_TARGETS[$index]}"
    printf '  %s) namespace=%s deployment=%s\n' "$((index + 1))" "$namespace" "$deployment"
  done
}

select_codex_target() {
  requested_namespace="${1:-}"
  requested_deployment="${2:-}"
  discover_codex_targets
  matches=()
  for target in "${CODEX_TARGETS[@]}"; do
    IFS='|' read -r namespace deployment <<<"$target"
    [[ -z "$requested_namespace" || "$namespace" == "$requested_namespace" ]] || continue
    [[ -z "$requested_deployment" || "$deployment" == "$requested_deployment" ]] || continue
    matches+=("$target")
  done

  if ((${#matches[@]} == 0)); then
    printf 'ERROR: Nie znaleziono pasujacej instancji Codex CLI.\n' >&2
    print_codex_targets >&2 || true
    return 1
  fi

  if ((${#matches[@]} == 1)); then
    selected_target="${matches[0]}"
  elif [[ -t 0 ]]; then
    printf 'Wybierz instancje Codex CLI:\n' >&2
    for index in "${!matches[@]}"; do
      IFS='|' read -r namespace deployment <<<"${matches[$index]}"
      printf '  %s) namespace=%s deployment=%s\n' \
        "$((index + 1))" "$namespace" "$deployment" >&2
    done
    read -r -p 'Numer: ' selection
    [[ "$selection" =~ ^[1-9][0-9]*$ ]] && ((selection <= ${#matches[@]})) || {
      printf 'ERROR: Nieprawidlowy wybor.\n' >&2
      return 1
    }
    selected_target="${matches[$((selection - 1))]}"
  else
    printf 'ERROR: Znaleziono kilka instancji. Podaj --namespace i --deployment.\n' >&2
    print_codex_targets >&2
    return 1
  fi

  IFS='|' read -r CODEX_NAMESPACE CODEX_DEPLOYMENT <<<"$selected_target"
  export CODEX_NAMESPACE CODEX_DEPLOYMENT
}
