FROM docker.io/alpine:3.21 AS builder

# Download ttrss via git
WORKDIR /var/www
# https://stackoverflow.com/questions/36996046/how-to-prevent-dockerfile-caching-git-clone
ADD https://gitlab.tt-rss.org/api/v4/projects/20/repository/branches/master /var/www/ttrss-version
RUN apk add --update tar curl git \
  && rm -rf /var/www/* \
  && git clone https://git.tt-rss.org/fox/tt-rss --depth=1 /var/www

# Download plugins
WORKDIR /var/www/plugins.local

RUN mkdir /var/www/plugins/fever mercury_fulltext feediron opencc api_newsplus options_per_feed remove_iframe_sandbox wallabag_v2 auth_oidc freshapi && \
  ## Fever
  curl -sL https://github.com/DigitalDJ/tinytinyrss-fever-plugin/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C /var/www/plugins/fever tinytinyrss-fever-plugin-master && \
  ## Mercury Fulltext
  curl -sL https://github.com/HenryQW/mercury_fulltext/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C mercury_fulltext mercury_fulltext-master && \
  ## Feediron
  curl -sL https://github.com/feediron/ttrss_plugin-feediron/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C feediron ttrss_plugin-feediron-master && \
  ## OpenCC
  curl -sL https://github.com/HenryQW/ttrss_opencc/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C opencc ttrss_opencc-master && \
  ## News+ API
  curl -sL https://github.com/voidstern/tt-rss-newsplus-plugin/archive/master.tar.gz | \
  tar xzvpf - --strip-components=2 -C api_newsplus tt-rss-newsplus-plugin-master/api_newsplus && \
  ## Options per feed
  curl -sL https://github.com/sergey-dryabzhinsky/options_per_feed/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C options_per_feed options_per_feed-master && \
  ## Remove iframe sandbox
  curl -sL https://github.com/DIYgod/ttrss-plugin-remove-iframe-sandbox/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C remove_iframe_sandbox ttrss-plugin-remove-iframe-sandbox-master && \
  ## Wallabag
  curl -sL https://github.com/joshp23/ttrss-to-wallabag-v2/archive/master.tar.gz | \
  tar xzvpf - --strip-components=2 -C wallabag_v2 ttrss-to-wallabag-v2-master/wallabag_v2 && \
  ## Auth OIDC
  curl -sL https://gitlab.tt-rss.org/tt-rss/plugins/ttrss-auth-oidc/-/archive/master/ttrss-auth-oidc-master.tar.gz | \
  tar xzvpf - --strip-components=1 -C auth_oidc ttrss-auth-oidc-master && \
  ## FreshAPI
  curl -sL https://github.com/eric-pierce/freshapi/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C freshapi freshapi-master

## FeedReader API
ADD https://raw.githubusercontent.com/jangernert/FeedReader/master/data/tt-rss-feedreader-plugin/api_feedreader/init.php api_feedreader/

# Download themes
WORKDIR /var/www/themes.local

# Fix safari: TypeError: window.requestIdleCallback is not a function
# https://community.tt-rss.org/t/typeerror-window-requestidlecallback-is-not-a-function/1755/26
# https://github.com/pladaria/requestidlecallback-polyfill
# COPY src/local-overrides.js local-overrides.js
# this polyfill is added to tt-rss after 1 years 7 months
# https://github.com/HenryQW/Awesome-TTRSS/commit/1b077f26f8c40ce7dd7b2a0cf2263a3537118e07
# https://gitlab.tt-rss.org/tt-rss/tt-rss/-/commit/31ef788e02339452fa6241277e17f85067c33ba0

## Feedly
RUN curl -sL https://github.com/levito/tt-rss-feedly-theme/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 --wildcards -C . tt-rss-feedly-theme-master/feedly*.css tt-rss-feedly-theme-master/feedly/fonts && \
  ## RSSHub
  curl -sL https://github.com/DIYgod/ttrss-theme-rsshub/archive/master.tar.gz | \
  tar xzvpf - --strip-components=2 -C . ttrss-theme-rsshub-master/dist/rsshub.css && \
  ## Feedlish
  curl -sL https://github.com/Gravemind/tt-rss-feedlish-theme/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 --wildcards -C . tt-rss-feedlish-theme-master/feedlish*.css

FROM docker.io/alpine:3.21

LABEL maintainer="Henry<hi@henry.wang>"

WORKDIR /var/www

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY src/wait-for.sh /wait-for.sh
COPY src/ttrss.nginx.conf /etc/nginx/nginx.conf
COPY src/initialize.php /initialize.php
COPY src/s6/ /etc/s6/

# Open up ports to bypass ttrss strict port checks, USE WITH CAUTION
ENV ALLOW_PORTS="80,443"
ENV SELF_URL_PATH=http://localhost:181
ENV DB_NAME=ttrss
ENV DB_USER=ttrss
ENV DB_PASS=ttrss

# Install dependencies
RUN chmod -x /wait-for.sh && chmod -x /docker-entrypoint.sh && apk add --update --no-cache git nginx s6 curl sudo tzdata \
  php82 php82-fpm php82-ctype php82-curl php82-dom php82-exif php82-fileinfo php82-gd php82-iconv php82-intl php82-json php82-mbstring php82-opcache \
  php82-openssl php82-pcntl php82-pdo php82-pdo_pgsql php82-phar php82-pecl-apcu php82-posix php82-session php82-simplexml php82-sockets php82-tokenizer php82-xml php82-xmlwriter php82-zip \
  php82-gmp php82-pecl-imagick \
  ca-certificates && rm -rf /var/cache/apk/* \
  # Update libiconv as the default version is too low
  # Do not bump this dependency https://gitlab.alpinelinux.org/alpine/aports/-/issues/12328
  && apk add gnu-libiconv=1.15-r3 --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community/ \
  && rm -rf /var/www \
  && ln -s /usr/bin/php82 /usr/bin/php

ENV LD_PRELOAD="/usr/lib/preloadable_libiconv.so php"

# Copy TTRSS and plugins
COPY --from=builder /var/www /var/www

RUN chown nobody:nginx -R /var/www \
  && git config --global --add safe.directory /var/www

EXPOSE 80

# Database default settings
ENV DB_HOST=database.postgres
ENV DB_PORT=5432
ENV DB_USER=postgres
ENV DB_PASS=ttrss
ENV DB_NAME=ttrss

# Some default settings
ENV SELF_URL_PATH=http://localhost:181
ENV ENABLE_PLUGINS=auth_internal,fever
ENV SESSION_COOKIE_LIFETIME=24
ENV SINGLE_USER_MODE=false
ENV LOG_DESTINATION=sql
ENV FEED_LOG_QUIET=false

ENTRYPOINT ["sh", "/docker-entrypoint.sh"]
