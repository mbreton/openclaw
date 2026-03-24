#!/usr/bin/env bash
# Generates a CA key + certificate for open-claw-secure-proxy.
# Run once and commit proxy-ca.crt. Keep proxy-ca.key secret.
#
# Usage: ./scripts/generate-ca.sh [output-dir]
#   output-dir defaults to the project root (one level above this script).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${1:-"$SCRIPT_DIR/.."}"

KEY="$OUT/proxy-ca.key"
CRT="$OUT/proxy-ca.crt"

echo "Generating proxy CA..."
openssl genrsa -out "$KEY" 2048
openssl req -new -x509 -days 3650 \
  -key "$KEY" \
  -out "$CRT" \
  -subj "/CN=OpenClaw Proxy CA/O=openclaw-proxify/C=US"

echo ""
echo "Generated:"
echo "  $CRT  <- certificate (safe to commit)"
echo "  $KEY  <- private key  (keep secret, already in .gitignore)"
echo ""
echo "Add these to your .env file:"
echo ""

# base64 flag differs between Linux (-w0) and macOS (no -w flag)
B64() { base64 -w0 "$1" 2>/dev/null || base64 -i "$1"; }

echo "CA_CERT=$(B64 "$CRT")"
echo "CA_KEY=$(B64 "$KEY")"
echo ""
echo "Add CA_CERT value as the PROXY_CA_CERT_B64 GitHub Actions secret too:"
echo "  gh secret set PROXY_CA_CERT_B64 --body \"$(B64 "$CRT")\""
echo "  gh secret set PROXY_CA_KEY_B64  --body \"$(B64 "$KEY")\""
