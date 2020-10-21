#!/bin/sh

set -e

if [ "$ALLOW_PORTS" != "80,443" ]; then
    # open ports in the env
    ALLOW_PORTS="80, 443, $ALLOW_PORTS, ''"
    sed -i -r "s/(80, 443).*?('')/$ALLOW_PORTS/" /var/www/classes/urlhelper.php

    # modify BL to include ports
    CODE="if (isset(\$parts['port'])) {\$tmp .= ':' . \$parts['port'];} \n \$tmp = \$tmp . \$parts['path'];"
    sed -i "/\$parts\['path'\];/a $CODE" /var/www/classes/urlhelper.php
    sed -i -r "s/\]\ \.\ \\\$parts\['path'\]/\]/" /var/www/classes/urlhelper.php
fi

echo $DB_HOST
echo $DB_PORT

sh /wait-for.sh $DB_HOST:$DB_PORT -- php /configure-db.php && exec s6-svscan /etc/s6/

exec "$@"
