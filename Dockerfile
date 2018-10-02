FROM alpine:latest

ADD wait-for /wait-for

RUN chmod -x /wait-for && apk add --update --no-cache nginx s6 php7 php7-fpm php7-cli php7-curl php7-fileinfo php7-mbstring php7-gd php7-json php7-dom php7-pcntl php7-posix \
  php7-pgsql php7-mcrypt php7-session php7-pdo php7-pdo_pgsql ca-certificates && \
  rm -rf /var/cache/apk/*

# add ttrss as the only nginx site
ADD ttrss.nginx.conf /etc/nginx/nginx.conf


# Download plugins
ADD https://github.com/HenryQW/tinytinyrss-fever-plugin/archive/master.tar.gz /var/www/plugins/
ADD https://github.com/HenryQW/mercury_fulltext/archive/master.tar.gz /var/www/plugins/mercury_fulltext/
ADD https://github.com/feediron/ttrss_plugin-feediron/archive/master.tar.gz /var/www/plugins/feediron/ 
ADD https://github.com/HenryQW/ttrss_opencc/archive/master.tar.gz /var/www/plugins/opencc/ 
ADD https://github.com/dugite-code/tt-rss-nextcloud-theme/archive/master.tar.gz /var/www/themes/

# install ttrss and patch configuration
WORKDIR /var/www
RUN apk add --update --virtual build-dependencies curl tar \
  && curl -SL https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz | tar xzC /var/www --strip-components 1 \
  && tar xzvpf /var/www/plugins/master.tar.gz --strip-components=1 -C /var/www/plugins/ tinytinyrss-fever-plugin-master/fever && rm /var/www/plugins/master.tar.gz \
  \
  \
  && tar xzvpf /var/www/plugins/mercury_fulltext/master.tar.gz --strip-components=1 -C /var/www/plugins/mercury_fulltext/ mercury_fulltext-master && rm /var/www/plugins/mercury_fulltext/master.tar.gz \
  \
  \
  && tar xzvpf /var/www/plugins/feediron/master.tar.gz --strip-components=1 -C /var/www/plugins/feediron/ ttrss_plugin-feediron-master && rm /var/www/plugins/feediron/master.tar.gz \
  \
  \
  && tar xzvpf /var/www/plugins/opencc/master.tar.gz --strip-components=1 -C /var/www/plugins/opencc/ ttrss_opencc-master && rm /var/www/plugins/opencc/master.tar.gz \
  \
  \
  && tar xzvpf /var/www/themes/master.tar.gz --strip-components=1 -C /var/www/themes/ tt-rss-nextcloud-theme-master/nextcloud tt-rss-nextcloud-theme-master/nextcloud.css && rm /var/www/themes/master.tar.gz \
  \
  \
  && apk del build-dependencies \
  && rm -rf /var/cache/apk/* \
  && cp config.php-dist config.php \
  && chown nobody:nginx -R /var/www

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
