#!/bin/sh
set -eu
. "$(dirname "$0")/e2e.common.sh"

IMAGE="${IMAGE:-ttrss:e2e}"
trap 'docker logs ttrss 2>&1 | tail -n 50' EXIT

sudo systemctl start postgresql
echo "host all all 172.16.0.0/12 scram-sha-256" | sudo tee -a "$(sudo -u postgres psql -tAc 'SHOW hba_file')" >/dev/null
sudo -u postgres psql -c "ALTER SYSTEM SET listen_addresses = '*'" -c "CREATE USER ttrss PASSWORD 'ttrss' CREATEDB"
sudo systemctl restart postgresql

WORK=$(mktemp -d)
write_fixtures "$WORK" host.docker.internal
sudo cp "$WORK"/*.xml /var/www/html/
echo "server { listen 1234; root /var/www/html; }" | sudo tee /etc/nginx/conf.d/port1234.conf >/dev/null
sudo systemctl start nginx

docker run -d --name ttrss -p 181:80 \
  --add-host host.docker.internal:host-gateway -e DB_HOST=host.docker.internal \
  -e DB_USER=ttrss -e ALLOW_PORTS=1234 "$IMAGE" >/dev/null
psql() { PGPASSWORD=ttrss command psql -h 127.0.0.1 -U ttrss -d ttrss -tA -c "$1"; }

wait_for_ttrss
subscribe_and_update "$WORK/feeds.opml"
assert_feeds
