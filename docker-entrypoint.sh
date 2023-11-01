#!/bin/sh

set -e

# reset previously modified UrlHelper.php, in case ALLOW_PORTS is updated
git checkout -- /var/www/classes/UrlHelper.php

if [ "$ALLOW_PORTS" != "80,443" ]; then
    # open ports in the env
    ALLOW_PORTS="80, 443, $ALLOW_PORTS, ''"
    sed -i -r "s/(80, 443).*?('')/$ALLOW_PORTS/" /var/www/classes/UrlHelper.php

    # modify BL to include ports
    CODE="if (isset(\$parts['port'])) \$tmp .= ':' . \$parts['port']; \n"
    sed -i "/if (isset(\$parts\['path'\]))/i $CODE" /var/www/classes/UrlHelper.php
fi

if [ "$FEED_LOG_QUIET" != "true" ]; then
    sed -i -r "s/--quiet/ /" /etc/s6/update-daemon/run
else
    sed -i -r "s/\.php/.php --quiet/" /etc/s6/update-daemon/run
fi

if [ -n "$DB_USER_FILE" ]; then DB_USER="$(cat $DB_USER_FILE)"; fi

if [ -n "$DB_PASS_FILE" ]; then DB_PASS="$(cat $DB_PASS_FILE)"; fi

sh /wait-for.sh $DB_HOST:$DB_PORT -- php /initialize.php && sudo -E -u nobody php /var/www/update.php --update-schema=force-yes && exec s6-svscan /etc/s6/

exec "$@"
