FROM docker.io/alpine:3.23 AS builder

# Download ttrss via git
WORKDIR /var/www
# https://stackoverflow.com/questions/36996046/how-to-prevent-dockerfile-caching-git-clone
ADD https://api.github.com/repos/tt-rss/tt-rss/git/refs/heads/main /var/www/ttrss-version
RUN apk add --update tar curl git \
  && rm -rf /var/www/* \
  && git clone https://github.com/tt-rss/tt-rss --depth=1 /var/www \
  && rm -rf /var/www/tests \
  && find /var/www -mindepth 1 -maxdepth 1 -name ".*" ! -name ".git" -exec rm -rf {} +

# Download plugins
WORKDIR /var/www/plugins.local

RUN mkdir /var/www/plugins/fever mercury_fulltext feediron opencc api_newsplus options_per_feed remove_iframe_sandbox wallabag_v2 auth_oidc freshapi api_feedreader && \
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
  curl -sL https://github.com/entekadesign/options_per_feed/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C options_per_feed options_per_feed-master && \
  ## Remove iframe sandbox
  curl -sL https://github.com/DIYgod/ttrss-plugin-remove-iframe-sandbox/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C remove_iframe_sandbox ttrss-plugin-remove-iframe-sandbox-master && \
  ## Wallabag
  curl -sL https://github.com/joshp23/ttrss-to-wallabag-v2/archive/master.tar.gz | \
  tar xzvpf - --strip-components=2 -C wallabag_v2 ttrss-to-wallabag-v2-master/wallabag_v2 && \
  ## Auth OIDC
  curl -sL https://github.com/tt-rss/tt-rss-plugin-auth-oidc/archive/main.tar.gz | \
  tar xzvpf - --strip-components=1 -C auth_oidc tt-rss-plugin-auth-oidc-main && \
  ## FreshAPI
  curl -sL https://github.com/eric-pierce/freshapi/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 -C freshapi freshapi-master && \
  ## FeedReader API
  curl -sL https://raw.githubusercontent.com/jangernert/FeedReader/master/data/tt-rss-feedreader-plugin/api_feedreader/init.php -o api_feedreader/init.php

# Download themes
WORKDIR /var/www/themes.local

# Fix safari: TypeError: window.requestIdleCallback is not a function
# https://community.tt-rss.org/t/typeerror-window-requestidlecallback-is-not-a-function/1755/26
# https://github.com/pladaria/requestidlecallback-polyfill
# COPY src/local-overrides.js local-overrides.js
# this polyfill is added to tt-rss after 1 years 7 months
# https://github.com/HenryQW/Awesome-TTRSS/commit/1b077f26f8c40ce7dd7b2a0cf2263a3537118e07
# https://github.com/tt-rss/tt-rss/commit/31ef788e02339452fa6241277e17f85067c33ba0

## Feedly
RUN curl -sL https://github.com/levito/tt-rss-feedly-theme/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 --wildcards -C . tt-rss-feedly-theme-master/feedly*.css tt-rss-feedly-theme-master/feedly/fonts && \
  ## RSSHub
  curl -sL https://github.com/DIYgod/ttrss-theme-rsshub/archive/master.tar.gz | \
  tar xzvpf - --strip-components=2 -C . ttrss-theme-rsshub-master/dist/rsshub.css && \
  ## Feedlish
  curl -sL https://github.com/Gravemind/tt-rss-feedlish-theme/archive/master.tar.gz | \
  tar xzvpf - --strip-components=1 --wildcards -C . tt-rss-feedlish-theme-master/feedlish*.css

FROM docker.io/alpine:3.23

LABEL maintainer="Henry<hi@henry.wang>"

# Database default settings
ENV DB_HOST=database.postgres
ENV DB_PORT=5432
ENV DB_USER=postgres
ENV DB_NAME=ttrss
ENV DB_PASS=ttrss
ENV DB_SSLMODE=prefer

# Some default settings
ENV SELF_URL_PATH=http://localhost:181
ENV ENABLE_PLUGINS=auth_internal,fever
ENV SESSION_COOKIE_LIFETIME=24
ENV SINGLE_USER_MODE=false
ENV LOG_DESTINATION=sql
ENV FEED_LOG_QUIET=false

# Open up ports to bypass ttrss strict port checks, USE WITH CAUTION
ENV ALLOW_PORTS="80,443"

ENV PHP_SUFFIX=83

WORKDIR /var/www

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY src/wait-for.sh /wait-for.sh
COPY src/ttrss.nginx.conf /etc/nginx/nginx.conf
COPY src/initialize.php /initialize.php
COPY src/s6/ /etc/s6/

# Install dependencies
RUN set -ex \
  && chmod -x /wait-for.sh && chmod -x /docker-entrypoint.sh \
  && PHP_PACKAGES="fpm ctype curl dom exif fileinfo gd iconv intl json mbstring opcache \
  openssl pcntl pdo pdo_pgsql pecl-apcu phar posix session simplexml sockets sodium tokenizer xml xmlwriter zip \
  gmp pecl-imagick" \
  && EXT_LIST="" \
  && for p in $PHP_PACKAGES; do \
       EXT_LIST="$EXT_LIST php${PHP_SUFFIX}-$p"; \
     done \
  && apk add --update --no-cache git nginx s6 curl sudo tzdata \
  php${PHP_SUFFIX} $EXT_LIST \
  ca-certificates && rm -rf /var/cache/apk/* \
  # Update libiconv as the default version is too low
  # Do not bump this dependency https://gitlab.alpinelinux.org/alpine/aports/-/issues/12328
  && apk add gnu-libiconv=1.15-r3 --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community/ \
  && echo -e "opcache.enable_cli=1\nopcache.jit=1255\nopcache.jit_buffer_size=64M" >> /etc/php${PHP_SUFFIX}/php.ini \
  # leftover files
  && rm -rf /var/www

ENV LD_PRELOAD="/usr/lib/preloadable_libiconv.so php"

# Copy TTRSS and plugins
COPY --from=builder /var/www /var/www

RUN chown nobody:nginx -R /var/www \
  && git config --global --add safe.directory /var/www \
  # https://github.com/tt-rss/tt-rss/commit/f57bb8ec244c39615d4ab247a7016aded11080a2
  && chown -R nobody:nginx /root

EXPOSE 80

ENTRYPOINT ["sh", "/docker-entrypoint.sh"]
