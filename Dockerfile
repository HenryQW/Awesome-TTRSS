FROM alpine:edge

RUN apk add --update nginx s6 php5 php5-fpm php5-cli php5-curl php5-gd php5-json php5-dom php5-pcntl php5-posix \
  php5-pgsql php5-mcrypt php5-pdo php5-pdo_pgsql ca-certificates && \
  rm -rf /var/cache/apk/*

# add ttrss as the only nginx site
ADD ttrss.nginx.conf /etc/nginx/nginx.conf

# Download plugins
ADD https://github.com/WangQiru/tinytinyrss-fever-plugin/archive/dev.tar.gz /var/www/plugins/
ADD https://github.com/WangQiru/mercury_fulltext/archive/dev.tar.gz /var/www/plugins/mercury_fulltext/
ADD https://github.com/levito/tt-rss-feedly-theme/archive/master.tar.gz /var/www/themes/

# install ttrss and patch configuration
WORKDIR /var/www
RUN apk add --update --virtual build-dependencies curl tar \
  && curl -SL https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz | tar xzC /var/www --strip-components 1 \
  && tar xzvpf /var/www/plugins/dev.tar.gz --strip-components=1 -C /var/www/plugins/ tinytinyrss-fever-plugin-dev/fever && rm /var/www/plugins/dev.tar.gz \
  && tar xzvpf /var/www/plugins/mercury_fulltext/dev.tar.gz --strip-components=1 -C /var/www/plugins/mercury_fulltext/ mercury_fulltext-dev && rm /var/www/plugins/mercury_fulltext/dev.tar.gz \
  && tar xzvpf /var/www/themes/master.tar.gz --strip-components=1 -C /var/www/themes/ tt-rss-feedly-theme-master/feedly tt-rss-feedly-theme-master/feedly.css && rm /var/www/themes/master.tar.gz \
  && apk del build-dependencies \
  && rm -rf /var/cache/apk/* \
  && cp config.php-dist config.php \
  && chown nobody:nginx -R /var/www \
  && ln -s /usr/bin/php5 /usr/bin/php

# expose only nginx HTTP port
EXPOSE 80

# complete path to ttrss
ENV SELF_URL_PATH http://localhost

# expose default database credentials via ENV in order to ease overwriting
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss

# always re-configure database with current ENV when RUNning container, then monitor all services
ADD configure-db.php /configure-db.php
ADD s6/ /etc/s6/

CMD php /configure-db.php && exec s6-svscan /etc/s6/
