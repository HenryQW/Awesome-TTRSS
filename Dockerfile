FROM alpine:3

LABEL maintainer="Henry<hi@henry.wang>"

ADD src/wait-for.sh /wait-for.sh

# Install dependencies
RUN chmod -x /wait-for.sh && apk add --update --no-cache git nginx s6 curl \
  php7 php7-intl php7-fpm php7-cli php7-curl php7-fileinfo \
  php7-mbstring php7-gd php7-json php7-dom php7-pcntl php7-posix \
  php7-pgsql php7-mcrypt php7-session php7-pdo php7-pdo_pgsql \
  ca-certificates && rm -rf /var/cache/apk/* \
  # Update libiconv as the default version is too low
  && apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted && \
  # Download ttrss via git
  rm -rf /var/www && \
  git clone https://git.tt-rss.org/fox/tt-rss --depth=1 /var/www

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# Install GNU libc (aka glibc) and set C.UTF-8 locale as default.
# https://github.com/Docker-Hub-frolvlad/docker-alpine-glibc/blob/master/Dockerfile

ENV LANG=C.UTF-8

RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
  ALPINE_GLIBC_PACKAGE_VERSION="2.31-r0" && \
  ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
  ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
  ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
  apk add --no-cache --virtual=.build-dependencies wget && \
  wget https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -O /etc/apk/keys/sgerrand.rsa.pub && \
  wget \
  "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
  "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
  "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
  apk add --no-cache \
  "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
  "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
  "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
  \
  rm "/etc/apk/keys/sgerrand.rsa.pub" && \
  /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
  echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
  \
  apk del glibc-i18n && \
  \
  rm "/root/.wget-hsts" && \
  apk del .build-dependencies && \
  rm -rf /var/cache/apk/* && \
  rm \
  "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
  "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
  "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

# Add ttrss nginx config
ADD src/ttrss.nginx.conf /etc/nginx/nginx.conf

# Download plugins

## Fever
ADD https://github.com/HenryQW/tinytinyrss-fever-plugin/archive/master.tar.gz /var/www/plugins/fever/

## Mercury Fulltext
ADD https://github.com/HenryQW/mercury_fulltext/archive/master.tar.gz /var/www/plugins/mercury_fulltext/

## Feediron
ADD https://github.com/feediron/ttrss_plugin-feediron/archive/master.tar.gz /var/www/plugins/feediron/

## OpenCC
ADD https://github.com/HenryQW/ttrss_opencc/archive/master.tar.gz /var/www/plugins/opencc/

## News+ API
ADD https://github.com/voidstern/tt-rss-newsplus-plugin/archive/master.tar.gz /var/www/plugins/api_newsplus/

## FeedReader API
ADD https://raw.githubusercontent.com/jangernert/FeedReader/master/data/tt-rss-feedreader-plugin/api_feedreader/init.php /var/www/plugins/api_feedreader/

## Options per feed
ADD https://github.com/sergey-dryabzhinsky/options_per_feed/archive/master.tar.gz /var/www/plugins/options_per_feed/

## Remove iframe sandbox
ADD https://github.com/DIYgod/ttrss-plugin-remove-iframe-sandbox/archive/master.tar.gz /var/www/plugins/remove_iframe_sandbox/

# Download themes

## Feedly
ADD https://github.com/levito/tt-rss-feedly-theme/archive/master.tar.gz /var/www/themes.local/feedly.tar.gz

## RSSHub
ADD https://github.com/DIYgod/ttrss-theme-rsshub/archive/master.tar.gz /var/www/themes.local/rsshub.tar.gz

# Untar ttrss plugins
WORKDIR /var/www
RUN apk add --update --virtual build-dependencies tar \
  && tar xzvpf /var/www/plugins/fever/master.tar.gz --strip-components=1 -C /var/www/plugins/fever tinytinyrss-fever-plugin-master && rm /var/www/plugins/fever/master.tar.gz \
  \
  && tar xzvpf /var/www/plugins/mercury_fulltext/master.tar.gz --strip-components=1 -C /var/www/plugins/mercury_fulltext/ mercury_fulltext-master && rm /var/www/plugins/mercury_fulltext/master.tar.gz \
  \
  && tar xzvpf /var/www/plugins/feediron/master.tar.gz --strip-components=1 -C /var/www/plugins/feediron/ ttrss_plugin-feediron-master && rm /var/www/plugins/feediron/master.tar.gz \
  \
  && tar xzvpf /var/www/plugins/opencc/master.tar.gz --strip-components=1 -C /var/www/plugins/opencc/ ttrss_opencc-master && rm /var/www/plugins/opencc/master.tar.gz \
  \
  && tar xzvpf /var/www/plugins/api_newsplus/master.tar.gz --strip-components=2 -C /var/www/plugins/api_newsplus tt-rss-newsplus-plugin-master/api_newsplus && rm /var/www/plugins/api_newsplus/master.tar.gz \
  \
  && tar xzvpf /var/www/plugins/options_per_feed/master.tar.gz --strip-components=1 -C /var/www/plugins/options_per_feed options_per_feed-master && rm /var/www/plugins/options_per_feed/master.tar.gz \
  \
  && tar xzvpf /var/www/plugins/remove_iframe_sandbox/master.tar.gz --strip-components=1 -C /var/www/plugins/remove_iframe_sandbox ttrss-plugin-remove-iframe-sandbox-master && rm /var/www/plugins/remove_iframe_sandbox/master.tar.gz \
  \
  && tar xzvpf /var/www/themes.local/feedly.tar.gz --strip-components=1 --wildcards -C /var/www/themes.local/ tt-rss-feedly-theme-master/feedly tt-rss-feedly-theme-master/feedly*.css && rm -rf /var/www/themes.local/feedly.tar.gz \
  \
  && tar xzvpf /var/www/themes.local/rsshub.tar.gz --strip-components=2 -C /var/www/themes.local/ ttrss-theme-rsshub-master/dist/rsshub.css && rm -rf /var/www/themes.local/rsshub.tar.gz \
  \
  && apk del build-dependencies \
  && rm -rf /var/cache/apk/* \
  && cp config.php-dist config.php \
  && chown nobody:nginx -R /var/www

EXPOSE 80

# complete path to ttrss
ENV SELF_URL_PATH http://localhost:181

# Expose default database credentials via ENV in order to ease overwriting
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss

# Always re-configure database with current ENV when running container, then monitor all services
ADD src/configure-db.php /configure-db.php
ADD src/s6/ /etc/s6/

CMD php /configure-db.php && exec s6-svscan /etc/s6/
