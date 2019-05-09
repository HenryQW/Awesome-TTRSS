[![Docker Pulls](https://img.shields.io/docker/pulls/wangqiru/ttrss.svg)](https://hub.docker.com/r/wangqiru/ttrss)
[![Docker Stars](https://img.shields.io/docker/stars/wangqiru/ttrss.svg)](https://hub.docker.com/r/wangqiru/ttrss)

[![Docker Automated build](https://img.shields.io/docker/automated/wangqiru/ttrss.svg)](https://hub.docker.com/r/wangqiru/ttrss/builds)
[![Docker Build Status](https://img.shields.io/docker/build/wangqiru/ttrss.svg)](https://hub.docker.com/r/wangqiru/ttrss/builds)

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FHenryQW%2Fdocker-ttrss-plugins.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2FHenryQW%2Fdocker-ttrss-plugins?ref=badge_shield)

[简体中文说明在这里](#tiny-tiny-rss-容器镜像)

## Tiny Tiny RSS feed reader as a docker image

### Plugins

1. [Mercury_fulltext](https://github.com/HenryQW/mercury_fulltext): fetches fulltext of articles via self-hosted Mercury Parser API, see [HenryQW/mercury-parser-api](https://github.com/HenryQW/mercury-parser-api).
1. [Fever API](https://github.com/HenryQW/tinytinyrss-fever-plugin): simulates Fever API (please read the configuration [here](https://tt-rss.org/oldforum/viewtopic.php?f=22&t=1981)).
1. [Feediron](https://github.com/feediron/ttrss_plugin-feediron): enables modification of article's DOM.
1. [ttrss_opencc](https://github.com/HenryQW/ttrss_opencc): Conversion between Traditional and Simplified Chinese via OpenCC for ttrss. Set the [OpenCC API Server](https://github.com/HenryQW/OpenCC.henry.wang) address in plugin setting page. Demo instances (availability is not guaranteed): https://opencc.henry.wang (Google Cloud) or http://opencc2.henry.wang (Heroku)
1. [FeedReader API](https://github.com/jangernert/FeedReader/tree/master/data/tt-rss-feedreader-plugin): FeedReader API support. Enable by adding 'api_feedreader' to ENABLE_PLUGINS env.

### Theme

1. [Feedly](https://github.com/levito/tt-rss-feedly-theme)
1. [RSSHub](https://github.com/DIYgod/ttrss-theme-rsshub)

**Support postgres only for better user experience.** mysql support is dropped since [tag 3.5_mysql_php5](https://github.com/HenryQW/docker-ttrss-plugins/tree/3.5_mysql_php5).

### Deployment example

#### A more detailed guide is available [here](https://henry.wang/2018/04/25/ttrss-docker-plugins-guide.html) [![forthebadge](https://forthebadge.com/images/badges/check-it-out.svg)](https://henry.wang/2018/04/25/ttrss-docker-plugins-guide.html)

#### Deployment via docker

```
docker run -it --name ttrss --restart=always \
-e SELF_URL_PATH = [ your URL ]  \
-e DB_HOST = [ your DB address ]  \
-e DB_PORT= [ your DB port ]  \
-e DB_NAME = [ your DB name ]  \
-e DB_USER = [ your DB user ]  \
-e DB_PASS = [ your DB password ]  \
-p [ your port ]:80  \
-d wangqiru/ttrss
```

##### List of Docker ENV variables

* ENV SELF_URL_PATH
* ENV DB_HOST
* ENV DB_PORT
* ENV DB_NAME
* ENV DB_USER
* ENV DB_PASS
* ENV ENABLE_PLUGINS

#### Deployment via docker-compose

`docker-compose.yml` contains ttrss and postgres images.

1. Download `docker-compose.yml` to any directory.
1. Read `docker-compose.yml` and change the settings (please ensure you change user and password for postgres).
1. Run `docker-compose up -d` and wait for the deployment to finish.
1. Access ttrss via port 181，with default credentials `admin` and `password`, please change them asap.
1. `wangqiru/mercury-parser-api` and `wangqiru/opencc-api-server` are optional service containers to support additional features, removing them will not affect TTRSS's basic functionalities.

### Recommendation

* [RSSHub](https://docs.rsshub.app/en/) is an interesting place for discovering RSS feeds.
* For iOS and macOS user, the integrated [Fever plugin](https://github.com/HenryQW/tinytinyrss-fever-plugin) supplies [Reeder 4](http://reederapp.com/) backend support.
* For Linux user，the integrated [FeedReader API](https://github.com/jangernert/FeedReader/tree/master/data/tt-rss-feedreader-plugin) supplies [FeedReader](https://jangernert.github.io/FeedReader/) backend support.
* For Android user, strongly recommend an iPhone.

### [Author's GitHub](https://github.com/HenryQW/docker-ttrss-plugins)

## Tiny Tiny RSS 容器镜像

### 插件

1. [Mercury](https://github.com/HenryQW/mercury_fulltext)：全文内容提取插件，需要配合自建 Mercury Parser API，参见[HenryQW/mercury-parser-api](https://github.com/HenryQW/mercury-parser-api)。
1. [Fever API](https://github.com/HenryQW/tinytinyrss-fever-plugin)：Fever API 模拟插件（请参照[这里](https://tt-rss。org/oldforum/viewtopic。php?f=22&t=1981)进行设置）。
1. [Feediron](https://github.com/feediron/ttrss_plugin-feediron)：提供文章 DOM 操控能力的插件。
1. [ttrss_opencc](https://github.com/HenryQW/ttrss_opencc)：使用 OpenCC 为 ttrss 提供中文繁转简的插件。插件设置中填写 [OpenCC API 服务器](https://github.com/HenryQW/OpenCC.henry.wang)地址。 Demo 服务器(可用性不做任何保证)：https://opencc.henry.wang (Google Cloud) or http://opencc2.henry.wang (Heroku)
1. [FeedReader API](https://github.com/jangernert/FeedReader/tree/master/data/tt-rss-feedreader-plugin)：提供 FeedReader API 支持。 将 'api_feedreader' 添加到 **ENABLE_PLUGINS** 环境变量。

### 主题

1. [Feedly](https://github.com/levito/tt-rss-feedly-theme)
1. [RSSHub](https://github.com/DIYgod/ttrss-theme-rsshub)

**为了更好的用户体验，此镜像仅支持 postgres 数据库。** 自 [tag 3.5_mysql_php5](https://github.com/HenryQW/docker-ttrss-plugins/tree/3.5_mysql_php5) 起停止支持 mysql。

### 部署样例

#### 一份更详细的设置说明（只有英文，中文版有空再写= =）请参见[这里](https://henry.wang/2018/04/25/ttrss-docker-plugins-guide.html) [![forthebadge](https://forthebadge.com/images/badges/check-it-out.svg)](https://henry.wang/2018/04/25/ttrss-docker-plugins-guide.html)

#### 通过 docker 部署

```
docker run -it --name ttrss --restart=always \
-e SELF_URL_PATH = [ 你的URL地址 ]  \
-e DB_HOST = [ 你的数据库地址 ]  \
-e DB_PORT= [ 你的数据库端口 ]  \
-e DB_NAME = [ 你的数据库名称 ]  \
-e DB_USER = [ 你的数据库用户名 ]  \
-e DB_PASS = [ 你的数据库密码 ]  \
-p [ 容器对外映射端口 ]:80  \
-d wangqiru/ttrss
```

##### Docker ENV 环境变量列表

* ENV SELF_URL_PATH
* ENV DB_HOST
* ENV DB_PORT
* ENV DB_NAME
* ENV DB_USER
* ENV DB_PASS
* ENV ENABLE_PLUGINS

#### 通过 docker-compose 部署

`docker-compose.yml` 包含了 ttrss 与 postgres 镜像。

1. 下载 `docker-compose.yml` 至任意目录。
1. 更改 `docker-compose.yml` 中的设置（务必更改 postgres 用户密码）。
1. 运行 `docker-compose up -d` 后等待部署完成。
1. 默认通过 181 端口访问 ttrss，默认账户：`admin` 密码：`password`，请第一时间更改。
1. `wangqiru/mercury-parser-api` 及 `wangqiru/opencc-api-server` 为支持高级功能而加入的可选服务类容器，删除不会影响 TTRSS 基础功能。

### 使用建议

* 推荐使用 [RSSHub](https://docs。rsshub。app/) 来发现更多有趣的订阅源。
* 对于 iOS 和 macOS 用户，内置的[Fever 模拟插件](https://github.com/HenryQW/tinytinyrss-fever-plugin)提供[Reeder 4](http://reederapp.com/)后端支持。
* 对于 Linux 用户，内置的[FeedReader API](https://github.com/jangernert/FeedReader/tree/master/data/tt-rss-feedreader-plugin)提供[FeedReader](https://jangernert.github.io/FeedReader/) 后端支持。
* 对于安卓用户，强烈推荐一部 iPhone。

### [作者的 GitHub](https://github.com/HenryQW/docker-ttrss-plugins)

## License

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FHenryQW%2Fdocker-ttrss-plugins.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2FHenryQW%2Fdocker-ttrss-plugins?ref=badge_large)
