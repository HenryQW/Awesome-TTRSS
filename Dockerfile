FROM clue/ttrss
MAINTAINER Ruben Vermeersch <ruben@rocketeer.be>

ADD https://github.com/dasmurphy/tinytinyrss-fever-plugin/archive/master.tar.gz /var/www/plugins/
RUN tar xzvpf /var/www/plugins/master.tar.gz --strip-components=1 -C /var/www/plugins/ tinytinyrss-fever-plugin-master/fever && rm /var/www/plugins/master.tar.gz

ADD https://github.com/levito/tt-rss-feedly-theme/archive/master.tar.gz /var/www/themes/
RUN tar xzvpf /var/www/themes/master.tar.gz --strip-components=1 -C /var/www/plugins/ tt-rss-feedly-theme-master/feedly tt-rss-feedly-theme-master/feedly.css && rm /var/www/themes/master.tar.gz
