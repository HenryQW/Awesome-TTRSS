# 🐋 Awesome TTRSS

![Docker Pulls](https://img.shields.io/docker/pulls/wangqiru/ttrss.svg)
![Docker Stars](https://img.shields.io/docker/stars/wangqiru/ttrss.svg)
![Docker Automated build](https://img.shields.io/docker/automated/wangqiru/ttrss.svg)
![Docker Build Status](https://img.shields.io/docker/build/wangqiru/ttrss.svg)
![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FHenryQW%2FAwesome-TTRSS.svg?type=shield)

## 关于

[Tiny Tiny RSS](https://tt-rss.org/) 是一款基于 PHP 的免费开源 RSS 聚合阅读器。🐋 Awesome TTRSS 旨在提供一个 **「一站式容器化」** 的 Tiny Tiny RSS 解决方案，通过提供简易的部署方式以及一些额外插件，以提升用户体验。

## 鸣谢

[![赞助者](https://opencollective.com/awesome-ttrss/backers.svg)](https://opencollective.com/awesome-ttrss#support)

## 部署

推荐使用一台 VPS 来部署您的 Awesome TTRSS 实例，[DigitalOcean](https://m.do.co/c/d6ef3c80105c) 提供高性价比的 VPS 仅需 \$5/月。除此之外，通过 Awesome TTRSS 的 [💰OpenCollective 页面](https://opencollective.com/Awesome-TTRSS/) 进行赞助，即可获得定制支持，全托管服务，全托管 VPS 等私人服务。

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

- SELF_URL_PATH: TTRSS 实例地址
- DB_HOST: 数据库地址
- DB_PORT: 数据库端口
- DB_NAME: 数据库名字
- DB_USER: 数据库用户名
- DB_PASS: 数据库密码
- ENABLE_PLUGINS: 在系统层面启用的插件名称，其中 `auth_internal` 为必须启用的登录插件
- SESSION_COOKIE_LIFETIME: 使用网页版登陆时 cookie 过期时间，单位为小时，默认为 `24` 小时
- HTTP_PROXY: `ip:port`, TTRSS 实例的全局代理, 为源地址添加单独代理请使用 [Options per Feed](#options-per-feed)

### 配置 HTTPS

TTRSS 容器自身不负责使用 HTTPS 加密通信。参见下方的样例自行配置 Nginx 反向代理。使用 [Let's Encrypt](https://letsencrypt.org/) 可以获取免费 SSL 证书。

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

## 更新

Awesome-TTRSS 会自动监控 TTRSS 官方更新并与之同步，这意味着更新会比较频繁。

默认使用 `wangqiru/ttrss:latest` 版本，该版本包含了 [TTRSS 官方](https://git.tt-rss.org/fox/tt-rss/releases)的稳定发行版。 `wangqiru/ttrss:nightly` 包含了含有最新功能的尝鲜版，但可能包含 bug。旧版本请参照 [此页面](https://hub.docker.com/r/wangqiru/ttrss/tags)。

### 手动更新

通过以下命令进行手动更新:

```shell
    docker pull wangqiru/ttrss:latest
    # docker pull wangqiru/mercury-parser-api:latest
    # docker pull wangqiru/opencc-api-server:latest
    docker-compose up -d # 如果您没有使用 docker-compose，我确信您知道该怎么做。
```

### 自动更新

[样例 docker-compose](#通过-docker-compose-部署) 中包含了 [Watchtower](https://github.com/containrrr/watchtower)，它会自动拉取并更新您所有的服务容器 (包括当前系统上运行的非 Awesome-TTRSS 服务的容器）。该服务默认关闭，**启用前请确认它将不会影响您其他的服务容器。**

您也可以设置 watchtower 忽略您的其他容器：

```yml
  service.mercury:
    image: wangqiru/mercury-parser-api:latest
    container_name: mercury
    expose:
      - 3000
    restart: always
    # ⬇️ 这将使 Watchtower 跳过对 mercury-parser-api 的更新检测
    labels:
        - com.centurylinklabs.watchtower.enable=false
```

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
1. 在支持 Fever 的阅读器用，使用 `https://[您的地址]/plugins/fever` 作为服务器地址。使用您的账号和步骤 2 中的密码登录。
1. 由于该插件使用未加盐的 MD5 加密密码进行通信，强烈建议[开启 HTTPS](#配置-https)。

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

### [Options per Feed](https://github.com/sergey-dryabzhinsky/options_per_feed)

提供单独为源地址配置代理、user-agent 以及 SSL 证书验证的能力。

使用指南见 [Options per Feed](https://github.com/sergey-dryabzhinsky/options_per_feed)。

## 主题

### [Feedly](https://github.com/levito/tt-rss-feedly-theme)

![Feedly](https://share.henry.wang/f3WNje/Q7RoLBSUFp+)

### [RSSHub](https://github.com/DIYgod/ttrss-theme-rsshub)

![RssHub](https://share.henry.wang/E5Lifa/1ykvdTWuew+)

## 使用建议

- 推荐使用 [RSSHub](https://docs。rsshub。app/) 来发现更多有趣的订阅源。
- 对于 iOS 和 macOS 用户，内置的 [Fever API 模拟插件](#fever-api) 提供 [Reeder 4](http://reederapp.com/) 后端支持。
- 对于 Linux 用户，内置的 [FeedReader API](#feedreader-api) 提供 [FeedReader](https://jangernert.github.io/FeedReader/) 后端支持。

## 支持与帮助

- 通过 Awesome TTRSS 的 [💰OpenCollective 页面](https://opencollective.com/Awesome-TTRSS/) 进行赞助，即可获得私人定制支持。
- 阅读此[指南](https://henry.wang/2018/04/25/ttrss-docker-plugins-guide.html)可能会有帮助。
- 通过 [GitHub issue](https://github.com/HenryQW/Awesome-TTRSS/issues) 提交问题。

## 捐赠

| PayPal                                                                                                                                                                       | 微信赞赏                                                            | OpenCollective                                                     |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------ |
| [![paypal](https://www.paypalobjects.com/en_US/GB/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MTM5L6T4PHRQS&source=url) | <img src="https://share.henry.wang/IKaxAW/duFgAuOnmk+" width="200"> | [💰OpenCollective page](https://opencollective.com/Awesome-TTRSS/) |

## 许可

MIT

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FHenryQW%2FAwesome-TTRSS.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FHenryQW%2FAwesome-TTRSS?ref=badge_large)
