#!/bin/bash

# Forward container service ports onto the workspace container so the
# editor's port forwarding (VS Code / Codespaces) can reach them.
#
# This runs from postStartCommand. Codespaces reaps the process tree of the
# lifecycle hook once it returns, so `nohup ... &` isn't enough — the
# forwarders get killed with the hook. `setsid` moves each socat into its own
# session, detaching it from the hook's process group so it survives.

set -e

# listen_port:target_host:target_port
FORWARDS=(
    "8000:nginx:8000"
    "8025:mailpit:8025"
)

for entry in "${FORWARDS[@]}"; do
    listen="${entry%%:*}"
    target="${entry#*:}"

    # postStartCommand can fire more than once (rebuilds, reconnects); don't
    # stack duplicate listeners on the same port.
    if pgrep -f "socat TCP-LISTEN:${listen}," >/dev/null 2>&1; then
        echo "Port ${listen} already forwarded, skipping."
        continue
    fi

    echo "Forwarding ${listen} -> ${target}"
    setsid socat "TCP-LISTEN:${listen},fork,reuseaddr" "TCP:${target}" \
        >"/tmp/socat-${listen}.log" 2>&1 </dev/null &
done
