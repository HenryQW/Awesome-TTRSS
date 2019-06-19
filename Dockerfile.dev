FROM alpine:3.10

LABEL maintainer="Henry<hi@henry.wang>"

ADD src/wait-for.sh /wait-for.sh

# Install dependencies
RUN chmod -x /wait-for.sh && apk add --update --no-cache nginx s6 \
  php7 php7-intl php7-fpm php7-cli php7-curl php7-fileinfo \
  php7-mbstring php7-gd php7-json php7-dom php7-pcntl php7-posix \
  php7-pgsql php7-mcrypt php7-session php7-pdo php7-pdo_pgsql \
  ca-certificates && rm -rf /var/cache/apk/*

# Add ttrss nginx config
ADD src/ttrss.nginx.conf /etc/nginx/nginx.conf

# Download plugins
ADD https://github.com/HenryQW/tinytinyrss-fever-plugin/archive/dev.tar.gz /var/www/plugins/fever/
ADD https://github.com/HenryQW/mercury_fulltext/archive/master.tar.gz /var/www/plugins/mercury_fulltext/
ADD https://github.com/feediron/ttrss_plugin-feediron/archive/master.tar.gz /var/www/plugins/feediron/ 
ADD https://github.com/HenryQW/ttrss_opencc/archive/master.tar.gz /var/www/plugins/opencc/ 
ADD https://github.com/voidstern/tt-rss-newsplus-plugin/archive/master.tar.gz /var/www/plugins/api_newsplus/ 

# FeedReader API
ADD https://raw.githubusercontent.com/jangernert/FeedReader/master/data/tt-rss-feedreader-plugin/api_feedreader/init.php /var/www/plugins/api_feedreader/

# Download themes
ADD https://github.com/levito/tt-rss-feedly-theme/archive/master.tar.gz /var/www/themes/feedly/
ADD https://github.com/DIYgod/ttrss-theme-rsshub/archive/master.tar.gz /var/www/themes/rsshub/

# Install ttrss and patch configuration
WORKDIR /var/www
RUN apk add --update --virtual build-dependencies curl tar \
  && curl -SL https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz | tar xzC /var/www --strip-components 1 \
  && tar xzvpf /var/www/plugins/fever/dev.tar.gz --strip-components=1 -C /var/www/plugins/fever tinytinyrss-fever-plugin-dev && rm /var/www/plugins/fever/dev.tar.gz \
  \
  && tar xzvpf /var/www/plugins/mercury_fulltext/master.tar.gz --strip-components=1 -C /var/www/plugins/mercury_fulltext/ mercury_fulltext-master && rm /var/www/plugins/mercury_fulltext/master.tar.gz \
  \
  && tar xzvpf /var/www/plugins/feediron/master.tar.gz --strip-components=1 -C /var/www/plugins/feediron/ ttrss_plugin-feediron-master && rm /var/www/plugins/feediron/master.tar.gz \
  \
  && tar xzvpf /var/www/plugins/opencc/master.tar.gz --strip-components=1 -C /var/www/plugins/opencc/ ttrss_opencc-master && rm /var/www/plugins/opencc/master.tar.gz \
  \
  && tar xzvpf /var/www/plugins/api_newsplus/master.tar.gz --strip-components=2 -C /var/www/plugins/api_newsplus tt-rss-newsplus-plugin-master/api_newsplus && rm /var/www/plugins/api_newsplus/master.tar.gz \
  \
  && tar xzvpf /var/www/themes/feedly/master.tar.gz --strip-components=1 -C /var/www/themes/ tt-rss-feedly-theme-master/feedly tt-rss-feedly-theme-master/feedly.css && rm -rf /var/www/themes/feedly \
  \
  && tar xzvpf /var/www/themes/rsshub/master.tar.gz --strip-components=2 -C /var/www/themes/ ttrss-theme-rsshub-master/dist/rsshub.css && rm -rf /var/www/themes/rsshub \
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
