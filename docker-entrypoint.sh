#!/bin/sh
set -eu

: "${SISH_DOMAIN:?SISH_DOMAIN must be set}"

mkdir -p /data/keys /data/pubkeys

if [ -n "${SISH_AUTHORIZED_KEYS:-}" ]; then
  printf '%s\n' "$SISH_AUTHORIZED_KEYS" > /data/pubkeys/fly_authorized_keys
  chmod 600 /data/pubkeys/fly_authorized_keys
fi

if [ -z "${SISH_AUTHENTICATION_KEY_REQUEST_URL:-}" ] && ! find /data/pubkeys -maxdepth 1 -type f | grep -q .; then
  echo "No authorized SSH keys found in /data/pubkeys." >&2
  echo "Set SISH_AUTHENTICATION_KEY_REQUEST_URL, set the SISH_AUTHORIZED_KEYS secret, or place one or more public key files in /data/pubkeys." >&2
  exit 1
fi

exec /app/app \
  --ssh-address="${SISH_SSH_ADDRESS:-0.0.0.0:2222}" \
  --http-address="${SISH_HTTP_ADDRESS:-0.0.0.0:8080}" \
  --authentication=true \
  --authentication-password="" \
  --authentication-key-request-url="${SISH_AUTHENTICATION_KEY_REQUEST_URL:-}" \
  --authentication-keys-directory=/data/pubkeys \
  --private-keys-directory=/data/keys \
  --bind-random-ports=false \
  --port-bind-range="${SISH_PORT_BIND_RANGE:-80,443}" \
  --proxy-ssl-termination="${SISH_PROXY_SSL_TERMINATION:-true}" \
  --redirect-root=false \
  --domain="${SISH_DOMAIN}" \
  "$@"
