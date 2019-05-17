# 🐋 Awesome TTRSS

![Docker Pulls](https://img.shields.io/docker/pulls/wangqiru/ttrss.svg)
![Docker Stars](https://img.shields.io/docker/stars/wangqiru/ttrss.svg)
![Docker Automated build](https://img.shields.io/docker/automated/wangqiru/ttrss.svg)
![Docker Build Status](https://img.shields.io/docker/build/wangqiru/ttrss.svg)
![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FHenryQW%2FAwesome-TTRSS.svg?type=shield)

## 关于

[Tiny Tiny RSS](https://tt-rss.org/) 是一款基于 PHP 的免费开源 RSS 聚合阅读器。🐋 Awesome TTRSS 旨在提供一个「容器化」的 Tiny Tiny RSS 一站式解决方案，通过提供简易的部署方式以及一些额外插件，以提升用户体验。

## 部署

**为了更好的用户体验，此镜像仅支持 postgres 数据库。** 自 [tag 3.5_mysql_php5](https://github.com/HenryQW/Awesome-TTRSS/tree/3.5_mysql_php5) 起停止支持 mysql。

### 通过 Docker 部署

```dockerfile
docker run -it --name ttrss --restart=always \
-e SELF_URL_PATH = [ TTRSS 实例地址 ]  \
-e DB_HOST = [ 数据库地址 ]  \
-e DB_PORT= [ 数据库端口 ]  \
-e DB_NAME = [ 数据库名称 ]  \
-e DB_USER = [ 数据库用户名 ]  \
-e DB_PASS = [ 数据库密码 ]  \
-p [ 容器对外映射端口 ]:80  \
-d wangqiru/ttrss
```

### 通过 docker-compose 部署

[docker-compose.yml](https://github.com/HenryQW/Awesome-TTRSS/blob/master/docker-compose.yml) 包含了 4 个镜像:

1. [TTRSS](https://hub.docker.com/r/wangqiru/ttrss)
1. [PostgreSQL](https://hub.docker.com/r/sameersbn/postgresql)
1. [Mercury Parser API](https://hub.docker.com/r/wangqiru/mercury-parser-api)
1. [OpenCC API](https://hub.docker.com/r/wangqiru/opencc-api-server)

#### 步骤

1. 下载 [docker-compose.yml](https://github.com/HenryQW/Awesome-TTRSS/blob/master/docker-compose.yml) 至任意目录。
1. 更改 `docker-compose.yml` 中的设置，请务必更改 postgres 用户密码。
1. 通过终端在同目录下运行 `docker-compose up -d` 后等待部署完成。
1. 默认通过 181 端口访问 TTRSS，默认账户：`admin` 密码：`password`，请第一时间更改。
1. `wangqiru/mercury-parser-api` 及 `wangqiru/opencc-api-server` 为支持高级功能而加入的可选服务类容器，删除不会影响 TTRSS 基础功能。

### 支持的环境变量列表

* SELF_URL_PATH: TTRSS 实例地址
* DB_HOST: 数据库地址
* DB_PORT: 数据库端口
* DB_NAME: 数据库名字
* DB_USER: 数据库用户名
* DB_PASS: 数据库密码
* ENABLE_PLUGINS: 在系统层面启用的插件名称，其中 `auth_internal` 为必须启用的登录插件
* SESSION_COOKIE_LIFETIME: 使用网页版登陆时 cookie 过期时间，单位为小时，默认为 24 小时

## 插件

### [Mercury 全文获取](https://github.com/HenryQW/mercury_fulltext)

全文内容提取插件，配合单独的 Mercury Parser API 服务器使用。[样例 docker-compose](#通过-docker-compose-部署) 中已经包含了 [HenryQW/mercury-parser-api](https://github.com/HenryQW/mercury-parser-api) 服务器。

#### 设置步骤

1. 在设置中启用 `mercury-fulltext` 插件
    ![启用 Mercury](https://share.henry.wang/92AGp5/x9xYB93cnX+)
1. 在设置中填入 Mercury Parser API 地址
    ![填入 Mercury Parser API 地址](https://share.henry.wang/KFrzMD/O2xonuy9ta+)

### [Fever API](https://github.com/HenryQW/tinytinyrss-fever-plugin)

提供 Fever API 支持。

**该插件默认作为系统插件启用。**

#### 设置步骤

1. 在设置中启用 API。
    ![启用 API](https://share.henry.wang/X2AnXi/bVVDg9mGDm+)
1. 在插件设置中设置 Fever 密码。
    ![设置 Fever 密码](https://share.henry.wang/HspODo/xRSbZQheVN+)
1. 在支持 Fever 的阅读器用，使用 `https://[你的地址]/plugins/fever` 作为服务器地址。使用你的账号和步骤 2 中的密码登录。
1. 由于该插件使用未加盐的 MD5 加密密码进行通信，强烈建议开启 https，使用 [Let's Encrypt](https://letsencrypt.org/) 可以获取免费 SSL 证书。

### [OpenCC 繁简转换](https://github.com/HenryQW/ttrss_opencc)

使用 [OpenCC](https://github.com/BYVoid/OpenCC) 为 TTRSS 提供中文繁转简的插件，需要配合单独的 OpenCC API 服务器使用。[样例 docker-compose](#通过-docker-compose-部署) 中已经包含了 [HenryQW/OpenCC.henry.wang](https://github.com/HenryQW/OpenCC.henry.wang) 服务器。

#### 设置步骤

1. 在设置中启用 `opencc` 插件
    ![启用 opencc](https://share.henry.wang/EvN5Nl/2RHNnMV2iP+)
1. 在设置中填入 OpenCC API 地址
    ![填入 OpenCC API 地址](https://share.henry.wang/JdJeUB/vIsRBk3EXn+)

Demo 服务器，可用性不做任何保证：[https://opencc.henry.wang](https://opencc.henry.wang) or [http://opencc2.henry.wang](http://opencc2.henry.wang)。

### [FeedReader API](https://github.com/jangernert/FeedReader/tree/master/data/tt-rss-feedreader-plugin)

提供 FeedReader API 支持。

系统插件，将 `api_feedreader` 添加到 **ENABLE_PLUGINS** 环境变量中以启用。

使用指南见 [FeedReader API](https://github.com/jangernert/FeedReader/tree/master/data/tt-rss-feedreader-plugin)。

### [News+ API](https://github.com/voidstern/tt-rss-newsplus-plugin/)

为 Android App [News+](http://github.com/noinnion/newsplus/) 和 iOS App [Fiery Feeds](http://cocoacake.net/apps/fiery/) 提供更快的同步速度。

系统插件，将 `api_newsplus` 添加到 **ENABLE_PLUGINS** 环境变量中以启用。

使用指南见 [News+ API](https://github.com/voidstern/tt-rss-newsplus-plugin/)。

### [Feediron](https://github.com/feediron/ttrss_plugin-feediron)

提供文章 DOM 操控能力的插件。

使用指南见 [Feediron](https://github.com/feediron/ttrss_plugin-feediron)。

## 主题

### [Feedly](https://github.com/levito/tt-rss-feedly-theme)

![Feedly](https://share.henry.wang/f3WNje/Q7RoLBSUFp+)

### [RSSHub](https://github.com/DIYgod/ttrss-theme-rsshub)

![RssHub](https://share.henry.wang/E5Lifa/1ykvdTWuew+)

## 使用建议

* 推荐使用 [RSSHub](https://docs。rsshub。app/) 来发现更多有趣的订阅源。
* 对于 iOS 和 macOS 用户，内置的 [Fever API 模拟插件](#fever-api) 提供 [Reeder 4](http://reederapp.com/) 后端支持。
* 对于 Linux 用户，内置的 [FeedReader API](#feedreader-api) 提供 [FeedReader](https://jangernert.github.io/FeedReader/) 后端支持。

## 支持与帮助

通过 [GitHub issue](https://github.com/HenryQW/Awesome-TTRSS/issues) 提交问题，我会尽快答复。

## 许可

MIT

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FHenryQW%2FAwesome-TTRSS.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FHenryQW%2FAwesome-TTRSS?ref=badge_large)
