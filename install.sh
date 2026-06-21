#!/usr/bin/env bash
#
# install.sh - download the official cloudflared static binary to /usr/local/bin.
#
# Idempotent: safe to re-run; it overwrites the binary in place and re-prints
# the version. Run as root (or with sudo) so it can write to /usr/local/bin.

set -euo pipefail

INSTALL_DIR="/usr/local/bin"
BINARY="cloudflared"
BASE_URL="https://github.com/cloudflare/cloudflared/releases/latest/download"

# --- preflight ------------------------------------------------------------

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root (try: sudo $0)" >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required but not installed." >&2
  exit 1
fi

# --- detect architecture --------------------------------------------------

arch="$(uname -m)"
case "$arch" in
  x86_64 | amd64)
    asset="cloudflared-linux-amd64"
    ;;
  aarch64 | arm64)
    asset="cloudflared-linux-arm64"
    ;;
  *)
    echo "Unsupported architecture: $arch" >&2
    echo "Supported: x86_64 (amd64), aarch64 (arm64)." >&2
    exit 1
    ;;
esac

url="${BASE_URL}/${asset}"
dest="${INSTALL_DIR}/${BINARY}"

echo "Detected architecture: ${arch}"
echo "Downloading: ${url}"

# --- download (atomic) ----------------------------------------------------

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl --fail --location --silent --show-error --output "$tmp" "$url"

chmod +x "$tmp"
mv -f "$tmp" "$dest"
trap - EXIT

echo "Installed ${BINARY} to ${dest}"
"$dest" --version
