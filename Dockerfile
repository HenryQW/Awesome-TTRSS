FROM clue/ttrss
MAINTAINER Ruben Vermeersch <ruben@rocketeer.be>

ADD https://github.com/dasmurphy/tinytinyrss-fever-plugin/archive/master.tar.gz /var/www/plugins/
RUN tar xzvpf /var/www/plugins/master.tar.gz --strip-components=1 -C /var/www/plugins/ tinytinyrss-fever-plugin-master/fever && rm /var/www/plugins/master.tar.gz
