FROM docker.io/alpine:3 AS builder

# Download ttrss via git
WORKDIR /var/www
RUN apk add --update tar curl git \
  && rm -rf /var/www/* \
  && git clone https://git.tt-rss.org/fox/tt-rss --depth=1 /var/www \
  && cp config.php-dist config.php

# Download plugins
WORKDIR /var/www/plugins.local

## Fever
RUN mkdir /var/www/plugins/fever && \
  curl -sL https://github.com/HenryQW/tinytinyrss-fever-plugin/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C /var/www/plugins/fever tinytinyrss-fever-plugin-master

## Mercury Fulltext
RUN mkdir mercury_fulltext && \
  curl -sL https://github.com/HenryQW/mercury_fulltext/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C mercury_fulltext mercury_fulltext-master

## Feediron
RUN mkdir feediron && \
  curl -sL https://github.com/feediron/ttrss_plugin-feediron/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C feediron ttrss_plugin-feediron-master

## OpenCC
RUN mkdir opencc && \
  curl -sL https://github.com/HenryQW/ttrss_opencc/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C opencc ttrss_opencc-master

## News+ API
RUN mkdir api_newsplus && \
  curl -sL https://github.com/voidstern/tt-rss-newsplus-plugin/archive/master.tar.gz | \
  tar xzvpf - --strip-components=2 -C api_newsplus  tt-rss-newsplus-plugin-master/api_newsplus

## FeedReader API
ADD https://raw.githubusercontent.com/jangernert/FeedReader/master/data/tt-rss-feedreader-plugin/api_feedreader/init.php api_feedreader/

## Options per feed
RUN mkdir options_per_feed && \
  curl -sL https://github.com/sergey-dryabzhinsky/options_per_feed/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C options_per_feed options_per_feed-master

## Remove iframe sandbox
RUN mkdir remove_iframe_sandbox && \
  curl -sL https://github.com/DIYgod/ttrss-plugin-remove-iframe-sandbox/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C remove_iframe_sandbox ttrss-plugin-remove-iframe-sandbox-master

## Wallabag
RUN mkdir wallabag_v2 && \
  curl -sL https://github.com/joshp23/ttrss-to-wallabag-v2/archive/master.tar.gz | \
  tar xzvpf - --strip-components=2 -C wallabag_v2 ttrss-to-wallabag-v2-master/wallabag_v2

# Download themes
WORKDIR /var/www/themes.local

## Feedly
RUN curl -sL https://github.com/levito/tt-rss-feedly-theme/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 --wildcards -C . tt-rss-feedly-theme-master/feedly*.css tt-rss-feedly-theme-master/feedly/fonts

## RSSHub
RUN curl -sL https://github.com/DIYgod/ttrss-theme-rsshub/archive/master.tar.gz | \
  tar xzvpf - --strip-components=2 -C . ttrss-theme-rsshub-master/dist/rsshub.css

FROM docker.io/php:8-fpm-alpine

LABEL maintainer="Henry<hi@henry.wang>"

WORKDIR /var/www

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY src/wait-for.sh /wait-for.sh
COPY src/ttrss.nginx.conf /etc/nginx/nginx.conf
COPY src/initialize.php /initialize.php
COPY src/s6/ /etc/s6/

# Open up ports to bypass ttrss strict port checks, USE WITH CAUTION
ENV ALLOW_PORTS="80,443"
ENV SELF_URL_PATH http://localhost:181
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss
ENV PHP_EXTENTIONS intl curl fileinfo mbstring dom pcntl posix \
  pgsql session pdo pdo_pgsql zip

# Install dependencies
RUN chmod -x /wait-for.sh && chmod -x /docker-entrypoint.sh \
  && apk add --update --no-cache nginx s6 git icu-libs libpq libzip \
  # https://github.com/docker-php/issues/1055#issuecomment-693370957
  && apk add --virtual=.build-dependencies --update --no-cache icu-dev curl-dev \
  oniguruma-dev libpng-dev postgresql-dev libzip-dev libxml2-dev \
  && NPROC=$(getconf _NPROCESSORS_ONLN) \
  && docker-php-ext-configure gd --enable-gd \
  && docker-php-ext-install -j${NPROC} ${PHP_EXTENTIONS} \
  && apk del .build-dependencies \
  && rm -rf /var/cache/apk/* \
  # Update libiconv as the default version is too low
  && apk add gnu-libiconv --update --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/community/ \
  && rm -rf /var/www

# Copy TTRSS and plugins
COPY --from=builder /var/www /var/www

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
  "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
  chown nobody:nginx -R /var/www

EXPOSE 80

# Database default settings
ENV DB_HOST=database.postgres
ENV DB_PORT=5432
ENV DB_USER=postgres
ENV DB_PASS=ttrss
ENV DB_NAME=ttrss

# Some default settings
ENV SELF_URL_PATH=http://localhost:181/
ENV ENABLE_PLUGINS=auth_internal,fever
ENV SESSION_COOKIE_LIFETIME=24
ENV SINGLE_USER_MODE=false
ENV LOG_DESTINATION=sql
ENV FEED_LOG_QUIET=false

ENTRYPOINT ["sh", "/docker-entrypoint.sh"]
