#!/bin/sh
set -eu
. "$(dirname "$0")/e2e.common.sh"

IMAGE="${IMAGE:-ttrss:e2e}"
WORK=$(mktemp -d) && chmod 755 "$WORK"

cleanup() {
  docker logs ttrss 2>&1 | tail -n 50 || true
  docker rm -f ttrss feed database.postgres >/dev/null 2>&1 || true
  docker network rm e2e >/dev/null 2>&1 || true
  rm -rf "$WORK"
}
trap cleanup EXIT

write_fixtures "$WORK" feed
echo "server { listen 1234; root /usr/share/nginx/html; }" > "$WORK/port1234.conf"

docker network create e2e >/dev/null
docker run -d --name database.postgres --network e2e \
  -e POSTGRES_USER=ttrss -e POSTGRES_PASSWORD=ttrss \
  postgres:alpine >/dev/null
docker run -d --name feed --network e2e \
  -v "$WORK:/usr/share/nginx/html:ro" \
  -v "$WORK/port1234.conf:/etc/nginx/conf.d/port1234.conf:ro" \
  nginx:alpine >/dev/null
docker run -d --name ttrss --network e2e -p 181:80 \
  -e DB_USER=ttrss -e ALLOW_PORTS=1234 \
  "$IMAGE" >/dev/null
psql() { docker exec database.postgres psql -U ttrss -d ttrss -tA -c "$1"; }

wait_for_ttrss
subscribe_and_update "$WORK/feeds.opml"
assert_feeds
