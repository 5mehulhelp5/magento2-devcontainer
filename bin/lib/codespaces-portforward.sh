#!/usr/bin/env bash
# Codespaces-only: bridge sibling compose service ports into the devcontainer's
# localhost so Codespaces auto-forwards them. No-op locally — the Dev Containers
# extension handles "service:port" entries in forwardPorts natively there.

[ "$CODESPACES" = "true" ] || exit 0

set -u

forward() {
  local listen_port="$1" target_host="$2" target_port="$3"

  if ss -lnt "( sport = :$listen_port )" 2>/dev/null | grep -q LISTEN; then
    echo "port-proxy: :$listen_port already listening, skipping"
    return 0
  fi

  echo "port-proxy: :$listen_port -> $target_host:$target_port"
  nohup socat "TCP-LISTEN:$listen_port,fork,reuseaddr" "TCP:$target_host:$target_port" \
    >/dev/null 2>&1 &
  disown
}

forward 8000 nginx   8000
forward 8025 mailpit 8025
