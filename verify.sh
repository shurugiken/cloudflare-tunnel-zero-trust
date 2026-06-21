#!/usr/bin/env bash
# Smoke-test the tunnel stack: local service reachable, systemd unit active,
# cloudflared running. Usage: ./verify.sh [local_port]   (default 8080)
set -euo pipefail

PORT="${1:-8080}"
fail() { echo "    FAIL: $1"; exit 1; }

echo "[1/3] Local service on 127.0.0.1:${PORT}"
curl -fsS "http://127.0.0.1:${PORT}/" >/dev/null && echo "    ok" || fail "local service not responding"

echo "[2/3] systemd unit service-tunnel.service"
systemctl is-active --quiet service-tunnel.service && echo "    active" || fail "unit not active"

echo "[3/3] cloudflared process"
pgrep -x cloudflared >/dev/null && echo "    running" || fail "cloudflared not running"

echo "All checks passed."
