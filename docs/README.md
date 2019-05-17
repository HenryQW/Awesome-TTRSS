# 🐋 Awesome TTRSS

[![Docker Pulls](https://img.shields.io/docker/pulls/wangqiru/ttrss.svg)](https://hub.docker.com/r/wangqiru/ttrss)
[![Docker Stars](https://img.shields.io/docker/stars/wangqiru/ttrss.svg)](https://hub.docker.com/r/wangqiru/ttrss)

[![Docker Automated build](https://img.shields.io/docker/automated/wangqiru/ttrss.svg)](https://hub.docker.com/r/wangqiru/ttrss/builds)
[![Docker Build Status](https://img.shields.io/docker/build/wangqiru/ttrss.svg)](https://hub.docker.com/r/wangqiru/ttrss/builds)

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FHenryQW%2Fdocker-ttrss-plugins.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2FHenryQW%2Fdocker-ttrss-plugins?ref=badge_shield)

## About

[Tiny Tiny RSS](https://tt-rss.org/) is an open source RSS feed reader and aggregator written in PHP. 🐋 Awesome TTRSS aims to provide a powerful [Dockerised] all-in-one solution, with enhanced user experience via simplified deployment and a list of curated plugins.

## Deployment

**Support postgres only for a better user experience.** mysql support is dropped since [tag 3.5_mysql_php5](https://github.com/HenryQW/docker-ttrss-plugins/tree/3.5_mysql_php5).

### Deployment via docker

```dockerfile
docker run -it --name ttrss --restart=always \
-e SELF_URL_PATH = [ your public URL ]  \
-e DB_HOST = [ your DB address ]  \
-e DB_PORT= [ your DB port ]  \
-e DB_NAME = [ your DB name ]  \
-e DB_USER = [ your DB user ]  \
-e DB_PASS = [ your DB password ]  \
-p [ public port ]:80  \
-d wangqiru/ttrss
```

### Deployment via docker-compose

[docker-compose.yml](https://github.com/HenryQW/docker-ttrss-plugins/blob/master/docker-compose.yml) include 4 docker images:

1. [TTRSS](https://hub.docker.com/r/wangqiru/ttrss)
1. [PostgreSQL](https://hub.docker.com/r/sameersbn/postgresql)
1. [Mercury Parser API](https://hub.docker.com/r/wangqiru/mercury-parser-api)
1. [OpenCC API](https://hub.docker.com/r/wangqiru/opencc-api-server)

#### Steps

1. Download [docker-compose.yml](https://github.com/HenryQW/docker-ttrss-plugins/blob/master/docker-compose.yml) to any directory.
1. Read `docker-compose.yml` and change the settings (please ensure you have changed the password for postgres).
1. Run `docker-compose up -d` and wait for the deployment to finish.
1. Access ttrss via port 181, with default credentials `admin` and `password`, please change them asap.
1. `wangqiru/mercury-parser-api` and `wangqiru/opencc-api-server` are optional service containers to support additional features, removing them will not affect TTRSS's basic functionalities.

#### Supported Environment Variables

* SELF_URL_PATH: the url to your TTRSS instance
* DB_HOST: the address of your database
* DB_PORT: the port of your database
* DB_NAME: the name of your database
* DB_USER: the user of your database
* DB_PASS: the password of your database
* ENABLE_PLUGINS: the plugins you'd like to enable at system level
* SESSION_COOKIE_LIFETIME: the expiry time for your login session cookie in hours, default to 24 hours

## Plugins

### [Mercury Fulltext Extraction](https://github.com/HenryQW/mercury_fulltext)

Fetch fulltext of articles via a self-hosted Mercury Parser API. A separate Mercury Parser API is required, the example [docker-compose](#deployment-via-docker-compose) has already included [such a server](https://github.com/HenryQW/mercury-parser-api).

#### Steps

1. Enable `mercury-fulltext` plugin in preference
    ![enable Mercury](https://share.henry.wang/92AGp5/x9xYB93cnX+)
1. Enter Mercury Parser API endpoint
    ![enter Mercury Parser API endpoint](https://share.henry.wang/KFrzMD/O2xonuy9ta+)

### [Fever API](https://github.com/HenryQW/tinytinyrss-fever-plugin)

Provide Fever API simulate.

**Plugin is enabled as a system plugin by default.**

#### Steps

1. Enable API in preference
    ![enable API](https://share.henry.wang/X2AnXi/bVVDg9mGDm+)
1. Enter a password for Fever in preference
    ![enter a Fever password](https://share.henry.wang/HspODo/xRSbZQheVN+)
1. In supported RSS readers, use `https://[your url]/plugins/fever` as the target server address, with your account and the password set in Step 2.
1. The plugin communicates with TTRSS using an unsalted MD5 hash, using https is strongly recommended. [Let's Encrypt](https://letsencrypt.org/) provides SSL certificates for free.

### [OpenCC Simp-Trad Chinese Conversion](https://github.com/HenryQW/ttrss_opencc)

Conversion between Traditional and Simplified Chinese via [OpenCC](https://github.com/BYVoid/OpenCC) , a separate [OpenCC API Server](https://github.com/HenryQW/OpenCC.henry.wang) is required. the example [docker-compose](#deployment-via-docker-compose) has already included [such a server](https://github.com/HenryQW/OpenCC.henry.wang).

#### Steps

1. Enable `opencc` plugin in preference
    ![enable opencc](https://share.henry.wang/EvN5Nl/2RHNnMV2iP+)
1. Enter OpenCC API endpoint
    ![enter OpenCC API endpoint](https://share.henry.wang/JdJeUB/vIsRBk3EXn+)

Demo instances, availability is not guaranteed: [https://opencc.henry.wang](https://opencc.henry.wang) or [http://opencc2.henry.wang](http://opencc2.henry.wang).

### [FeedReader API](https://github.com/jangernert/FeedReader/tree/master/data/tt-rss-feedreader-plugin)

Provide FeedReader API support.

System plugin, enabled by adding `api_feedreader` to the environment variable **ENABLE_PLUGINS**.

Refer to [FeedReader API](https://github.com/jangernert/FeedReader/tree/master/data/tt-rss-feedreader-plugin) for more details.

### [News+ API](https://github.com/voidstern/tt-rss-newsplus-plugin/)

Provide a faster two-way synchronization for Android App [News+](http://github.com/noinnion/newsplus/) and iOS App [Fiery Feeds](http://cocoacake.net/apps/fiery/) with TTRSS.

System plugin, enabled by adding `api_newsplus` to the environment variable **ENABLE_PLUGINS**.

Refer to [News+ API](https://github.com/voidstern/tt-rss-newsplus-plugin/) for more details.

### [Feediron](https://github.com/feediron/ttrss_plugin-feediron)

Provide the ability to manipulate article DOMs.

Refer to [Feediron](https://github.com/feediron/ttrss_plugin-feediron) for more details.

## Themes

### [Feedly](https://github.com/levito/tt-rss-feedly-theme)

![Feedly](https://share.henry.wang/f3WNje/Q7RoLBSUFp+)

### [RSSHub](https://github.com/DIYgod/ttrss-theme-rsshub)

![RssHub](https://share.henry.wang/E5Lifa/1ykvdTWuew+)

## Recommendation

* [RSSHub](https://docs.rsshub.app/en/) is an interesting place for discovering RSS feeds.
* For iOS and macOS user, the integrated [Fever plugin](https://github.com/HenryQW/tinytinyrss-fever-plugin) supplies [Reeder 4](http://reederapp.com/) backend support.
* For Android user, the integrated [Fever plugin](https://github.com/HenryQW/tinytinyrss-fever-plugin) supplies [News+](http://github.com/noinnion/newsplus/) backend support.
* For Linux user, the integrated [FeedReader API](https://github.com/jangernert/FeedReader/tree/master/data/tt-rss-feedreader-plugin) supplies [FeedReader](https://jangernert.github.io/FeedReader/) backend support.

## Support and Help

Open an issue via [GitHub issue](https://github.com/HenryQW/docker-ttrss-plugins/issues), I will try to respond ASAP.

## License

MIT

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FHenryQW%2Fdocker-ttrss-plugins.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2FHenryQW%2Fdocker-ttrss-plugins?ref=badge_large)
