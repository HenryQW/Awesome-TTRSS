# 🐋 Awesome TTRSS

![Docker Pulls](https://img.shields.io/docker/pulls/wangqiru/ttrss.svg)
![Docker Stars](https://img.shields.io/docker/stars/wangqiru/ttrss.svg)
![Docker Automated build](https://img.shields.io/docker/automated/wangqiru/ttrss.svg)
![Docker Build Status](https://img.shields.io/docker/build/wangqiru/ttrss.svg)
![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FHenryQW%2FAwesome-TTRSS.svg?type=shield)

## About

🐋 Awesome TTRSS aims to provide a powerful **Dockerized all-in-one** solution for [Tiny Tiny RSS](https://tt-rss.org/), an open source RSS feed reader and aggregator written in PHP, with enhanced user experience via simplified deployment and a list of curated plugins.

## Special Thanks

[![Backers](https://opencollective.com/awesome-ttrss/backers.svg)](https://opencollective.com/awesome-ttrss#support)

## Deployment

A VPS is highly recommended to host your Awesome TTRSS instance, a VPS can be obtained from as little as \$5/month at [DigitalOcean](https://m.do.co/c/d6ef3c80105c). Alternatively, you may request for personalized support, fully-managed service or fully-managed VPS via sponsoring Awesome TTRSS on its [💰OpenCollective page](https://opencollective.com/Awesome-TTRSS/).

Awesome TTRSS supports multiple architectures <Badge text="x86 ✓" vertical="top" type="tip"/><Badge text="arm32v7 ✓" vertical="top" type="tip"/><Badge text="arm64v8 ✓" vertical="top" type="tip"/>, except the OpenCC API.

### Deployment via docker

```bash
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

[docker-compose.yml](https://github.com/HenryQW/Awesome-TTRSS/blob/master/docker-compose.yml) include 4 docker images:

1. [TTRSS](https://hub.docker.com/r/wangqiru/ttrss)
1. [PostgreSQL](https://hub.docker.com/_/postgres)
1. [Mercury Parser API](https://hub.docker.com/r/wangqiru/mercury-parser-api)
1. [OpenCC API](https://hub.docker.com/r/wangqiru/opencc-api-server) <Badge text="arm32v7 ✗" vertical="top" type="error"/><Badge text="arm64v8 ✗" vertical="top" type="error"/>

#### Steps

1. Download [docker-compose.yml](https://github.com/HenryQW/Awesome-TTRSS/blob/master/docker-compose.yml) to any directory.
1. Read `docker-compose.yml` and change the settings (please ensure you have changed the password for postgres).
1. Run `docker-compose up -d` and wait for the deployment to finish.
1. Access ttrss via port 181, with default credentials `admin` and `password`, please change them asap.
1. `wangqiru/mercury-parser-api` and `wangqiru/opencc-api-server` are optional service containers to support additional features, removing them will not affect TTRSS's basic functionalities.

### Supported Environment Variables

- SELF_URL_PATH: the url to your TTRSS instance
- DB_HOST: the address of your database
- DB_PORT: the port of your database
- DB_NAME: the name of your database
- DB_USER: the user of your database
- DB_PASS: the password of your database
- ENABLE_PLUGINS: the plugins you'd like to enable at system level, note that `auth_internal` is required
- SESSION_COOKIE_LIFETIME: the expiry time for your login session cookie in hours, default to `24` hours
- HTTP_PROXY: `ip:port`, the global proxy for your TTRSS instance, to set proxy on a per feed basis, use [Options per Feed](#options-per-feed)
- SINGLE_USER_MODE: `true` will enable single user mode and disable user authentication, which means login will not be required. **Please only enable this under a secure environment**

### Configure HTTPS

TTRSS container itself doesn't handle HTTPS traffic. An example of configuring an Nginx reverse proxy with free SSL certificate from [Let's Encrypt](https://letsencrypt.org/) is shown below:

```nginx
upstream ttrssdev {
    server 127.0.0.1:181;
}

server {
    listen 80;
    server_name  ttrssdev.henry.wang;
    return 301 https://ttrssdev.henry.wang$request_uri;
}

server {
    listen 443 ssl;
    gzip on;
    server_name  ttrssdev.henry.wang;

    ssl_certificate /etc/letsencrypt/live/ttrssdev.henry.wang/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ttrssdev.henry.wang/privkey.pem;

    access_log /var/log/nginx/ttrssdev_access.log combined;
    error_log  /var/log/nginx/ttrssdev_error.log;

    location / {
        proxy_redirect off;
        proxy_pass http://ttrssdev;

        proxy_set_header  Host                $http_host;
        proxy_set_header  X-Real-IP           $remote_addr;
        proxy_set_header  X-Forwarded-Ssl     on;
        proxy_set_header  X-Forwarded-For     $proxy_add_x_forwarded_for;
        proxy_set_header  X-Forwarded-Proto   $scheme;
        proxy_set_header  X-Frame-Options     SAMEORIGIN;

        client_max_body_size        100m;
        client_body_buffer_size     128k;

        proxy_buffer_size           4k;
        proxy_buffers               4 32k;
        proxy_busy_buffers_size     64k;
        proxy_temp_file_write_size  64k;
    }
}
```

## Update

Awesome TTRSS automatically keeps up with TTRSS by mirroring the official releases, this means update can be issued frequently.

[TTRSS stopped releasing tags](https://community.tt-rss.org/t/versioning-changes-for-trunk/2974). `wangqiru/ttrss:latest` will sync with [TTRSS' master branch](https://git.tt-rss.org/fox/tt-rss) periodically.

### Manual Update

You can fetch the latest image manually:

```bash
docker pull wangqiru/ttrss:latest
# docker pull wangqiru/mercury-parser-api:latest
# docker pull wangqiru/opencc-api-server:latest
docker-compose up -d # If you didn't use docker-compose, I'm sure you know what to do.
```

### Auto Update

The example [docker-compose](#deployment-via-docker-compose) includes [Watchtower](https://github.com/containrrr/watchtower), which automatically pulls all containers included in Awesome TTRSS (and other containers running on your system) and refreshes your running services. By default, it's disabled, **make sure it will not affect your other service containers before enabling this.**

To exclude images, check the following for disabling auto update for containers:

```yml
service.mercury:
  image: wangqiru/mercury-parser-api:latest
  container_name: mercury
  expose:
    - 3000
  restart: always
  # ⬇️ this prevents Watchtower from auto updating mercury-parser-api
  labels:
    - com.centurylinklabs.watchtower.enable=false
```

## Migration

To further optimize Awesome TTRSS, sometimes breaking changes will be introduced.

### Postgres Migration

Migrate from sameersbn/postgresql to postgres:alpine.

| Image            | sameersbn/postgresql | postgres:alpine                         |
| ---------------- | -------------------- | --------------------------------------- |
| Postgres version | 10.2                 | latest (12.1 as of the time of writing) |
| Size             | 176MB                | 72.8MB                                  |

Since sameersbn/postgresql is no longer needed for enabling the pg_trgm extension, switching to postgres:alpine will benefit Awesome TTRSS from latest updates of Postgres and also be able to reduce the deployment size by over 100MB.

To begin the migration:

1. Stop all the service containers:
   ```bash
   docker-compose stop
   ```
1. Move the Postgres data volume `~/postgres/data/`, or the location specified in your docker-compose file, to somewhere else as a backup, THIS IS IMPORTANT.
1. Use the following command to dump all your data:
   ```bash
   docker exec postgres pg_dumpall -c -U postgres > export.sql
   ```
1. Update your docker-compose file with `database.postgres` section in the the latest [docker-compose.yml](https://github.com/HenryQW/Awesome-TTRSS/blob/master/docker-compose.yml), and bring it up:
   ```bash
   docker-compose up -d
   ```
1. Use the following command to restore all your data:
   ```bash
   cat export.sql | docker exec -i postgres psql -U postgres
   ```
1. Test if everything works fine, and now you may remove the backup in step 2.

The legacy docker-compose file is [archived as docker-compose.legacy.yml](https://github.com/HenryQW/Awesome-TTRSS/blob/master/docker-compose.legacy.yml).

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

#### Steps

1. Enable API in preference
   ![enable API](https://share.henry.wang/X2AnXi/bVVDg9mGDm+)
1. Enter a password for Fever in preference
   ![enter a Fever password](https://share.henry.wang/HspODo/xRSbZQheVN+)
1. In supported RSS readers, use `https://[your url]/plugins/fever` as the target server address, with your account and the password set in Step 2.
1. The plugin communicates with TTRSS using an unsalted MD5 hash, [using HTTPS](#configure-https) is strongly recommended.

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

### [Options per Feed](https://github.com/sergey-dryabzhinsky/options_per_feed)

Provide the ability to configure proxy, user-agent and SSL certificate verification on a per feed basis.

Refer to [Options per Feed](https://github.com/sergey-dryabzhinsky/options_per_feed) for more details.

### [Remove iframe sandbox](https://github.com/DIYgod/ttrss-plugin-remove-iframe-sandbox)

Remove the sandbox attribute on iframes, thus enabling playback of embedded video in feeds.

Refer to [Remove iframe sandbox](https://github.com/DIYgod/ttrss-plugin-remove-iframe-sandbox)。

## Themes

### [Feedly](https://github.com/levito/tt-rss-feedly-theme)

![Feedly](https://share.henry.wang/f3WNje/Q7RoLBSUFp+)

### [RSSHub](https://github.com/DIYgod/ttrss-theme-rsshub)

![RssHub](https://share.henry.wang/E5Lifa/1ykvdTWuew+)

## Recommendation

- [RSSHub](https://docs.rsshub.app/en/) is an interesting place for discovering RSS feeds.
- For iOS and macOS user, the integrated [Fever plugin](https://github.com/HenryQW/tinytinyrss-fever-plugin) supplies [Reeder 4](http://reederapp.com/) backend support.
- For Android user, the integrated [Fever plugin](https://github.com/HenryQW/tinytinyrss-fever-plugin) supplies [News+](http://github.com/noinnion/newsplus/) backend support.
- For Linux user, the integrated [FeedReader API](https://github.com/jangernert/FeedReader/tree/master/data/tt-rss-feedreader-plugin) supplies [FeedReader](https://jangernert.github.io/FeedReader/) backend support.

## Support and Help

- You may request for personalized support via sponsoring Awesome TTRSS on its [💰OpenCollective page](https://opencollective.com/Awesome-TTRSS/).
- Read [this guide](https://henry.wang/2018/04/25/ttrss-docker-plugins-guide.html) might help.
- Open an issue via [GitHub issue](https://github.com/HenryQW/Awesome-TTRSS/issues).
- [Direct donation to TTRSS](https://tt-rss.org/).

## Donation

| PayPal                                                                                                                                                                       | WeChat Pay                                                          | OpenCollective                                                     |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------ |
| [![paypal](https://www.paypalobjects.com/en_US/GB/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MTM5L6T4PHRQS&source=url) | <img src="https://share.henry.wang/IKaxAW/duFgAuOnmk+" width="200"> | [💰OpenCollective page](https://opencollective.com/Awesome-TTRSS/) |

## License

MIT

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FHenryQW%2FAwesome TTRSS.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FHenryQW%2FAwesome TTRSS?ref=badge_large)
