# 🐋 Awesome TTRSS

![Docker Pulls](https://img.shields.io/docker/pulls/wangqiru/ttrss.svg) ![Docker Stars](https://img.shields.io/docker/stars/wangqiru/ttrss.svg) ![Docker Automated build](https://img.shields.io/docker/automated/wangqiru/ttrss.svg) ![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FHenryQW%2FAwesome-TTRSS.svg?type=shield)

## 关于

[Tiny Tiny RSS](https://tt-rss.org/) 是一款基于 PHP 的免费开源 RSS 聚合阅读器。🐋 Awesome TTRSS 旨在提供一个 **「一站式容器化」** 的 Tiny Tiny RSS 解决方案，通过提供简易的部署方式以及一些额外插件，以提升用户体验。

## 鸣谢

[![赞助者](https://opencollective.com/awesome-ttrss/backers.svg)](https://opencollective.com/awesome-ttrss#support)

## 部署

推荐使用一台 VPS 来部署您的 Awesome TTRSS 实例，[DigitalOcean](https://m.do.co/c/d6ef3c80105c) 提供高性价比的 VPS 仅需 \$5/月。

Awesome TTRSS 支持多架构 <Badge text="x86 ✓" vertical="top" type="tip"/><Badge text="arm32v7 ✓" vertical="top" type="tip"/><Badge text="arm64v8 ✓" vertical="top" type="tip"/>（暂不包括 OpenCC API）。

### 通过 Docker 部署

```bash
docker run -it --name ttrss --restart=always \
-e SELF_URL_PATH=[ TTRSS 实例地址 ]  \
-e DB_HOST=[ 数据库地址 ]  \
-e DB_PORT=[ 数据库端口 ]  \
-e DB_NAME=[ 数据库名称 ]  \
-e DB_USER=[ 数据库用户名 ]  \
-e DB_PASS=[ 数据库密码 ]  \
-p [ 容器对外映射端口 ]:80  \
-d wangqiru/ttrss
```

### 通过 Docker Compose 部署

[docker-compose.yml](https://github.com/HenryQW/Awesome-TTRSS/blob/main/docker-compose.yml) 包含了 4 个镜像：

1. [TTRSS](https://hub.docker.com/r/wangqiru/ttrss)
2. [PostgreSQL](https://hub.docker.com/_/postgres)
3. [Mercury Parser API](https://hub.docker.com/r/wangqiru/mercury-parser-api)
4. [OpenCC API](https://hub.docker.com/r/wangqiru/opencc-api-server) <Badge text="arm32v7 ✗" vertical="top" type="danger"/><Badge text="arm64v8 ✗" vertical="top" type="danger"/>
5. [RSSHub](https://docs.rsshub.app/)

#### 步骤

1. 下载 [docker-compose.yml](https://github.com/HenryQW/Awesome-TTRSS/blob/main/docker-compose.yml) 至任意目录。
2. 更改 `docker-compose.yml` 中的设置，请务必更改 postgres 用户密码。
3. 通过终端在同目录下运行 `docker compose up -d` 后等待部署完成。
4. 默认通过 181 端口访问 TTRSS，默认账户：`admin` 密码：`password`，请第一时间更改。
5. `wangqiru/mercury-parser-api` 及 `wangqiru/opencc-api-server` 为支持高级功能而加入的可选服务类容器，删除不会影响 TTRSS 基础功能。

### 支持的环境变量列表

- `SELF_URL_PATH`: TTRSS 实例地址。**🔴 请注意，该变量值必须与你在浏览器中用于访问 TTRSS 的 URL 保持完全一致，否则 TTRSS 将无法启动。**
- `DB_HOST`: 数据库地址
- `DB_PORT`: 数据库端口
- `DB_NAME`: 数据库名字
- `DB_USER`: 数据库用户名
- `DB_PASS`: 数据库密码
- `DB_USER_FILE`: Docker Secrets 支持（替代 DB_USE），包含数据库用户名的文件
- `DB_PASS_FILE`: Docker Secrets 支持（替代 DB_PASS），包含数据库密码的文件
- `ENABLE_PLUGINS`: 全局启用的插件名称，其中 `auth_internal` 为必须启用的登录插件
- `ALLOW_PORTS`: 逗号分隔端口号，如`1200,3000`。允许订阅非 80,443 端口的源。**🔴 谨慎使用。**
- `SESSION_COOKIE_LIFETIME`: 使用网页版登陆时 cookie 过期时间，单位为小时，默认为 `24` 小时
- `HTTP_PROXY`: `ip:port`, TTRSS 实例的全局代理，为源地址添加单独代理请使用 [Options per Feed](#options-per-feed)
- `DISABLE_USER_IN_DAYS`: 当用户 X 天后没有登录后，停止为其自动更新订阅源，直至用户再次登陆
- `FEED_LOG_QUIET`: `true` 禁用订阅源更新所产生的日志打印

更多环境变量，参见 [官方 tt-rss](https://gitlab.tt-rss.org/tt-rss/tt-rss/-/blob/master/classes/Config.php)。

### 配置 HTTPS

TTRSS 容器自身不负责使用 HTTPS 加密通信。参见下方的样例自行配置 Caddy 或 Nginx 反向代理。使用 [Let's Encrypt](https://letsencrypt.org/) 可以获取免费 SSL 证书。

```shell
# Caddyfile
ttrssdev.henry.wang {
    reverse_proxy 127.0.0.1:181
    encode zstd gzip
}
```

```shell
# nginx.conf
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

**🔴 请注意， [你需要更新 `SELF_URL_PATH` 环境变量。](#supported-environment-variables)**

## 更新

Awesome TTRSS 会自动监控 TTRSS 官方更新并与之同步，这意味着更新会比较频繁。

[TTRSS 官方不再释出 tag](https://community.tt-rss.org/t/versioning-changes-for-trunk/2974)。 `wangqiru/ttrss:latest` 会与 [官方 main branch](https://gitlab.tt-rss.org/tt-rss/tt-rss) 同步。

### 手动更新

通过以下命令进行手动更新：

```bash
    docker pull wangqiru/ttrss:latest
    # docker pull wangqiru/mercury-parser-api:latest
    # docker pull wangqiru/opencc-api-server:latest
    docker compose up -d # 如果您没有使用 docker compose，我确信您知道该怎么做。
```

### 自动更新

[样例 Docker Compose](#通过-docker-compose-部署） 中包含了 [Watchtower](https://github.com/containrrr/watchtower)，它会自动拉取并更新您所有的服务容器 （包括当前系统上运行的非 Awesome TTRSS 服务的容器）。该服务默认关闭，**启用前请确认它将不会影响您其他的服务容器。**

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

## 数据库更新或迁移

Postgres 大版本更新 (15->16) 需要额外的步骤来确保服务正常运行。
为了更好地优化 Awesome TTRSS，有时候可能会推出一些破坏性更新。

### 步骤

::: warning

在升级时，请勿跳过多个大版本，例如直接从 13.x 升级到 16.x 是不支援的，并可能导致数据丢失。

:::

这些步骤演示了如何进行 Postgres 大版本更新（从 15.x 至 16.x），或者从其他镜像迁移至 postgres:alpine。

1. 停止所有服务容器：

   ```bash
   docker compose stop
   ```

2. 复制 Postgres 数据卷 `~/postgres/data/`（或者你在 Docker Compose 中指定的目录）至其他任何地方作为备份，这非常重要！
3. 执行如下命令来导出所有数据：

   ```bash
   docker exec postgres pg_dumpall -c -U 数据库用户名 > export.sql
   ```

4. 删除 Postgres 数据卷 `~/postgres/data/`。
5. 根据最新 [docker-compose.yml](https://github.com/HenryQW/Awesome-TTRSS/blob/main/docker-compose.yml) 中的`database.postgres` 部份来更新你的 Docker Compose 文件（**注意 `DB_NAME` 不可更改**），并启动：

   ```bash
   docker compose up -d
   ```

6. 执行如下命令来导入所有数据：

   ```bash
   cat export.sql | docker exec -i postgres psql -U 数据库用户名
   ```

7. 测试所有服务是否正常工作，现在你可以移除步骤二中的备份了。

## 插件

### [Mercury 全文获取](https://github.com/HenryQW/mercury_fulltext)

全文内容提取插件，配合单独的 Mercury Parser API 服务器使用。[样例 Docker Compose](#通过-docker-compose-部署） 中已经包含了 [HenryQW/mercury-parser-api](https://github.com/HenryQW/mercury-parser-api) 服务器。

#### 设置步骤

1. 在设置中启用 `mercury-fulltext` 插件
   ![启用 Mercury](https://share.henry.wang/92AGp5/x9xYB93cnX+)
2. 在设置中填入 Mercury Parser API 地址
   ![填入 Mercury Parser API 地址](https://share.henry.wang/9HJemY/BlTnDhuUGC+)

使用 Awesome-TTRSS 部署的 mercury 可填写`service.mercury:3000`。

#### 全文提取按钮

<img src="https://share.henry.wang/ubHtDz/uxyKk68jqY+" width="400" loading="lazy">

### [FreshRSS / Google Reader API](https://github.com/eric-pierce/freshapi)

FreshRSS / Google Reader API 插件，用于 Tiny-Tiny RSS

#### Steps

1. 导航到 Tiny Tiny RSS 中的“首选项”菜单，然后选中 “General” “Enable API”下的框
   ![enable API](https://private-user-images.githubusercontent.com/551464/366939059-f79e6fe3-bfb0-4989-a0fb-0bda4ac8b84d.jpg?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjcxMDYzNjMsIm5iZiI6MTcyNzEwNjA2MywicGF0aCI6Ii81NTE0NjQvMzY2OTM5MDU5LWY3OWU2ZmUzLWJmYjAtNDk4OS1hMGZiLTBiZGE0YWM4Yjg0ZC5qcGc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjQwOTIzJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI0MDkyM1QxNTQxMDNaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT0yYzJiNDE4ZjkwMDEwOTAzOWY3NWZkNTVlZDMzMmFmNTY0OTM5N2VkODlkNGIwYWZkM2Y0ODNhZTFkOGJhZDdiJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.f78G7IsKszUMGS99y1ZPIpEwVjiwr3CaorTYKE-EXBI)
2. 偏好，打开插件菜单并启用 “freshapi”
   ![enable FreshAPI](https://private-user-images.githubusercontent.com/551464/366939183-68260e5f-bcb8-4e14-a416-3d31104d9006.jpg?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjcxMDYzNjMsIm5iZiI6MTcyNzEwNjA2MywicGF0aCI6Ii81NTE0NjQvMzY2OTM5MTgzLTY4MjYwZTVmLWJjYjgtNGUxNC1hNDE2LTNkMzExMDRkOTAwNi5qcGc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjQwOTIzJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI0MDkyM1QxNTQxMDNaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT00YzkzNGRhNzcyMTQ1MWQ2Yjc1ZmVlY2VkYzY1YmE0MDY3OTE2Mzc2MDU2N2IyZDFjMjE3MDVhODNmYzE5YTE3JlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.L8Y8AVEEXSCsT48xqWBEujvhZrOPwEwI0jfQz_OKdgI)
3. 配置移动应用程序时，请选择 “FreshRSS”或 “Google Reader API”。根据您的设置，您需要将客户指向 TT-RSS 安装。如果您使用子域来主持 TT-RSS，请使用 `https://yoursubdomain.yourdomain.com/plugins.local/freshapi/api/greader.php` . 如果您在根域上运行，请使用 `https://yourdomain.com/plugins.local/freshapi/api/greader.php`
4. 使用您的标准 TT-RSS 用户名和密码。如果您启用了 2 个因子身份验证（2FA）生成并使用应用程序密码。与所有处理身份验证的插件一样，强烈建议使用 [开启 HTTPS](#配置-https)。

### [Fever API](https://github.com/DigitalDJ/tinytinyrss-fever-plugin)

提供 Fever API 支持。

#### 设置步骤

1. 在设置中启用 API。
   ![启用 API](https://share.henry.wang/X2AnXi/bVVDg9mGDm+)
2. 在插件设置中设置 Fever 密码。
   ![设置 Fever 密码](https://share.henry.wang/HspODo/xRSbZQheVN+)
3. 在支持 Fever 的阅读器用，使用 `https://[您的地址]/plugins/fever` 作为服务器地址。使用您的账号和步骤 2 中的密码登录。
4. 由于该插件使用未加盐的 MD5 加密密码进行通信，强烈建议 [开启 HTTPS](#配置-https)。

### [OpenCC 繁简转换](https://github.com/HenryQW/ttrss_opencc) <Badge text="arm32v7 ✗" vertical="top" type="danger"/><Badge text="arm64v8 ✗" vertical="top" type="danger"/>

使用 [OpenCC](https://github.com/BYVoid/OpenCC) 为 TTRSS 提供中文繁转简的插件，需要配合单独的 OpenCC API 服务器使用。[样例 Docker Compose](#通过-docker-compose-部署） 中已经包含了 [HenryQW/OpenCC.henry.wang](https://github.com/HenryQW/OpenCC.henry.wang) 服务器。

#### 设置步骤

1. 在设置中启用 `opencc` 插件
   ![启用 opencc](https://share.henry.wang/EvN5Nl/2RHNnMV2iP+)
2. 在设置中填入 OpenCC API 地址 <br>
   ![填入 OpenCC API 地址](https://share.henry.wang/pePHAz/oWXX3I18hW+)

使用 Awesome-TTRSS 部署的 OpenCC 可填写`service.opencc:3000`。

#### 转换按钮

<img src="https://share.henry.wang/30kbTr/lSaHKXk5NT+" width="400" loading="lazy">

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

### [Remove iframe sandbox](https://github.com/DIYgod/ttrss-plugin-remove-iframe-sandbox)

::: warning 注意

该插件与 `Fever API` 不能同时作为全局插件启用。如果您同时需要两者：

1. 在环境变量 `ENABLE_PLUGINS` 中移除 `fever` 并添加 `remove_iframe_sandbox` 作为全局插件启用。
2. 在登陆 TTRSS 后，通过设置将 `Fever API` 作为本地插件启用。

:::

移除 iframe 上的 sandbox 属性，以支持 feed 中直接播放嵌入视频。

使用指南见 [Remove iframe sandbox](https://github.com/DIYgod/ttrss-plugin-remove-iframe-sandbox)。

### [Wallabag v2](https://github.com/joshp23/ttrss-to-wallabag-v2)

保存文章至 Wallabag。

使用指南见 [Wallabag v2](https://github.com/joshp23/ttrss-to-wallabag-v2)。

### [Auth OIDC](https://dev.tt-rss.org/tt-rss/ttrss-auth-oidc)

这是一个系统插件，允许用户通过 OpenID Connect 提供程序（如 Keycloak）连接到 TTRSS。

通过将 `auth_oidc` 添加到环境变量 **ENABLE_PLUGINS** 来启用。

然后添加以下环境变量及相应的值：

```yaml
AUTH_OIDC_NAME: "显示的 IDP 提供程序名称"
AUTH_OIDC_URL: "https://oidc.hostname.com"
AUTH_OIDC_CLIENT_ID: "test-rss"
AUTH_OIDC_CLIENT_SECRET: "your-secret-token"
```

有关更多详细信息，请参阅 [Auth OIDC](https://dev.tt-rss.org/tt-rss/ttrss-auth-oidc)。

## RSSHub

在示例的 [Docker Compose](https://github.com/HenryQW/Awesome-TTRSS/blob/main/docker-compose.yml) 中集成了一个最小化的 [RSSHub](https://docs.rsshub.app) URL（Docker 服务发现）添加来自 RSSHub 的 RSS 源，例如：`http://service.rsshub:3000/bbc`。

有关配置 RSSHub 的更多信息，请参考 [RSSHub 文档](https://docs.rsshub.app/)。

## 主题

### [Feedly](https://github.com/levito/tt-rss-feedly-theme)

![Feedly](https://share.henry.wang/f3WNje/Q7RoLBSUFp+)

### [RSSHub](https://github.com/DIYgod/ttrss-theme-rsshub)

![RSSHub](https://share.henry.wang/E5Lifa/1ykvdTWuew+)

## 使用建议

- 推荐使用 [RSSHub](https://docs.rsshub.app/) 来发现更多有趣的订阅源。
- 对于 iOS 和 macOS 用户，内置的 [Fever API 模拟插件](#fever-api) 提供 [Reeder 5](http://reederapp.com/) 后端支持。
- 对于 Linux 用户，内置的 [FeedReader API](#feedreader-api) 提供 [FeedReader](https://jangernert.github.io/FeedReader/) 后端支持。

## 支持与帮助

- 阅读此 [指南](https://henry.wang/2018/04/25/ttrss-docker-plugins-guide.html) 可能会有帮助。
- 通过 [GitHub issue](https://github.com/HenryQW/Awesome-TTRSS/issues) 提交问题。
- [直接捐助支持](https://tt-rss.org/)。

## 捐赠

**请考虑直接捐助支持 [TTRSS](https://tt-rss.org/).**

## 许可

MIT

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FHenryQW%2FAwesome-TTRSS.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FHenryQW%2FAwesome-TTRSS?ref=badge_large)
