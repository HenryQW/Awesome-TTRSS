#!/bin/sh

set -e

# reset previously modified urlhelper.php, in case ALLOW_PORTS is updated
git checkout -- /var/www/classes/urlhelper.php

if [ "$ALLOW_PORTS" != "80,443" ]; then
    # open ports in the env
    ALLOW_PORTS="80, 443, $ALLOW_PORTS, ''"
    sed -i -r "s/(80, 443).*?('')/$ALLOW_PORTS/" /var/www/classes/urlhelper.php

    # modify BL to include ports
    CODE="if (isset(\$parts['port'])) {\$tmp .= ':' . \$parts['port'];} \n \$tmp = \$tmp . \$parts['path'];"
    sed -i "/\$parts\['path'\];/a $CODE" /var/www/classes/urlhelper.php
    sed -i -r "s/\]\ \.\ \\\$parts\['path'\]/\]/" /var/www/classes/urlhelper.php
fi

sh /wait-for.sh $DB_HOST:$DB_PORT -- php /configure-db.php && exec s6-svscan /etc/s6/

exec "$@"
