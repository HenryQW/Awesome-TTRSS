TITLE='简体中文 GB18030 测试 😀'

write_fixtures() {
  cat <<XML | iconv -f UTF-8 -t GB18030 > "$1/gb18030.xml"
<?xml version="1.0" encoding="gb18030"?>
<rss version="2.0"><channel>
<title>GB18030 feed</title><link>http://$2/</link><description>e2e</description>
<item><title>$TITLE</title><link>http://$2/1</link><guid>http://$2/1</guid><description>内容</description></item>
</channel></rss>
XML

  cat > "$1/port1234.xml" <<XML
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0"><channel>
<title>port 1234 feed</title><link>http://$2:1234/</link><description>e2e</description>
<item><title>custom port</title><link>http://$2:1234/1</link><guid>http://$2:1234/1</guid><description>e2e</description></item>
</channel></rss>
XML

  cat > "$1/feeds.opml" <<OPML
<?xml version="1.0" encoding="utf-8"?>
<opml version="1.0"><head><title>e2e</title></head><body>
<outline type="rss" text="github" xmlUrl="https://github.blog/changelog/feed/"/>
<outline type="rss" text="gb18030" xmlUrl="http://$2/gb18030.xml"/>
<outline type="rss" text="port1234" xmlUrl="http://$2:1234/port1234.xml"/>
</body></opml>
OPML
}

wait_for_ttrss() {
  echo "waiting for ttrss..."
  for i in $(seq 1 60); do
    curl -sf http://localhost:181/ >/dev/null && break
    sleep 5
  done
  curl -sf http://localhost:181/ >/dev/null
}

subscribe_and_update() {
  docker cp "$1" ttrss:/tmp/feeds.opml
  docker exec ttrss chmod 644 /tmp/feeds.opml
  docker exec ttrss s6-setuidgid nobody php /var/www/update.php --opml-import=admin:/tmp/feeds.opml
  psql "UPDATE ttrss_users SET last_login = NOW()" >/dev/null
  docker exec ttrss s6-setuidgid nobody php /var/www/update.php --force-update --feeds --force-refetch
}

assert_feeds() {
  echo "--- feeds"
  psql "SELECT f.feed_url, count(ue.int_id) AS entries, coalesce(f.last_error,'') AS last_error
        FROM ttrss_feeds f LEFT JOIN ttrss_user_entries ue ON ue.feed_id = f.id
        GROUP BY f.id ORDER BY f.id"

  FAIL=0
  BAD=$(psql "SELECT count(*) FROM ttrss_feeds f WHERE coalesce(f.last_error,'') <> ''
              OR NOT EXISTS (SELECT 1 FROM ttrss_user_entries ue WHERE ue.feed_id = f.id)")
  [ "$BAD" = "0" ] || { echo "FAIL: $BAD feed(s) with errors or no entries"; FAIL=1; }

  HIT=$(psql "SELECT count(*) FROM ttrss_entries WHERE title = '$TITLE'")
  [ "$HIT" = "1" ] || { echo "FAIL: GB18030 title not decoded (matches: $HIT)"; FAIL=1; }

  VERSION=$(docker exec -w /var/www ttrss php -r 'require "vendor/autoload.php"; echo Config::get_version();')
  echo "--- version: $VERSION"
  case "$VERSION" in
    ""|*Unsupported*) echo "FAIL: version string"; FAIL=1 ;;
  esac

  [ "$FAIL" = "0" ] && echo "PASS"
  return "$FAIL"
}
