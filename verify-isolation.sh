#!/usr/bin/env bash
# Prove the network jail: API reachable, everything else dead.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
export PROJECT_DIR="${PROJECT_DIR:-$PWD}"

echo "== 1. Mistral domains via proxy (any HTTP code = reachable) =="
for url in https://api.mistral.ai/v1/models https://chat.mistral.ai https://console.mistral.ai; do
  code=$(docker compose run --rm cli \
    curl -sS --max-time 10 -o /dev/null -w '%{http_code}' "$url" 2>/dev/null) \
    && echo "  $url -> $code (good)" \
    || echo "  $url -> UNREACHABLE (check that proxy is up)"
done

echo "== 2. Everything else through the proxy (expect curl errors, not HTTP codes) =="
for url in https://example.com https://pypi.org https://github.com; do
  if docker compose run --rm cli \
       curl -sS --max-time 10 -o /dev/null -w '%{http_code}' "$url" >/dev/null 2>&1; then
    echo "  $url -> REACHABLE (BAD - allowlist is leaking!)"
  else
    echo "  $url -> blocked (good)"
  fi
done

echo "== 3. Direct egress bypassing the proxy (expect no route / timeout) =="
if docker compose run --rm cli \
     curl --noproxy '*' -sS --max-time 8 -o /dev/null http://1.1.1.1 >/dev/null 2>&1; then
  echo "  direct internet -> REACHABLE (BAD - internal network is leaking!)"
else
  echo "  direct internet -> blocked (good)"
fi

echo
echo "== 4. Open profile sanity check (expect 200 - full internet on demand) =="
docker compose -f docker-compose.open.yml run --rm cli \
  curl -sS --max-time 10 -o /dev/null -w '%{http_code}\n' https://example.com

echo
echo "Audit trail of everything the CLI ever tried to reach:"
echo "  docker compose exec proxy tail -f /var/log/squid/access.log"

# Leave nothing running behind (same no-auto-start policy as the wrapper).
docker compose stop proxy >/dev/null 2>&1 || true
