![Docker Pulls](https://img.shields.io/docker/pulls/wangqiru/ttrss.svg)
![Docker Stars](https://img.shields.io/docker/stars/wangqiru/ttrss.svg)

![Docker Automated build](https://img.shields.io/docker/automated/wangqiru/ttrss.svg)
![Docker Build Status](https://img.shields.io/docker/build/wangqiru/ttrss.svg)

[简体中文说明在这里](#简体中文说明)

#### Tiny Tiny RSS feed reader as a docker image.

#### Plugins:

1.  [Mercury_fulltext](https://github.com/HenryQW/mercury_fulltext): fetches fulltext of articles via Mercury API.
2.  [Fever plugin](https://github.com/HenryQW/tinytinyrss-fever-plugin): simulates Fever API (please read the configuration [here](https://tt-rss.org/oldforum/viewtopic.php?f=22&t=1981)).
3.  [Feediron](https://github.com/feediron/ttrss_plugin-feediron): enables modification of article's DOM.
4.  [ttrss_opencc](https://github.com/HenryQW/ttrss_opencc): Conversion between Traditional and Simplified Chinese via OpenCC for ttrss (WIP).

#### Theme: [nextcloud](https://github.com/dugite-code/tt-rss-nextcloud-theme)

**Support postgres only for better user experience.** mysql support is dropped since [tag 3.5_mysql_php5](https://github.com/HenryQW/docker-ttrss-plugins/tree/3.5_mysql_php5).

### Deployment example:

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

#### Deployment via docker-compose

`docker-compose.yml` contains ttrss and postgres images.

1.  Download `docker-compose.yml` to any directory.
2.  Read `docker-compose.yml` and change the settings (please ensure you change user and password for postgres).
3.  Run `docker-compose up -d` and wait for the deployment to finish.
4.  Access ttrss via port 181，with default credentials `admin` and `password`, please change them asap.

### Recommendation

* For web interface, recommend to use **[freestyler plugin](http://freestyler.ws)** to customise your own CSS style, especially for non-western languages. Some [sample code](https://github.com/HenryQW/Stylish/blob/master/ttrss.css), please [replace it with your own ttrss domain](https://github.com/HenryQW/Stylish/blob/08923469377a974d66f8d2c767e6b6a69616a688/ttrss.css#L1).

* For iOS user, [Fever plugin](https://github.com/HenryQW/tinytinyrss-fever-plugin) supplies **[Reeder iOS](http://reederapp.com/ios/)** (THE RSS READER) backend support.

* For Android user, strongly recommend an iPhone.

### [Author's GitHub](https://github.com/HenryQW/docker-ttrss-plugins)

# 简体中文说明

#### Tiny Tiny RSS 容器镜像

#### 插件:

1.  [Mercury](https://github.com/HenryQW/mercury_fulltext): 全文内容提取插件 (Mercury API) .
2.  [Fever](https://github.com/HenryQW/tinytinyrss-fever-plugin): Fever API 模拟插件（请参照[这里](https://tt-rss.org/oldforum/viewtopic.php?f=22&t=1981)进行设置）.
3.  [Feediron](https://github.com/feediron/ttrss_plugin-feediron): 提供文章 DOM 操控能力的插件.
4.  [ttrss_opencc](https://github.com/HenryQW/ttrss_opencc): 使用 OpenCC 为 ttrss 提供繁转简（开发中）.


#### 主题: [nextcloud](https://github.com/dugite-code/tt-rss-nextcloud-theme)

**为了更好的用户体验，此镜像仅支持 postgres 数据库.** 自 [tag 3.5_mysql_php5](https://github.com/HenryQW/docker-ttrss-plugins/tree/3.5_mysql_php5) 起停止支持 mysql.

### 部署样例:

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

#### 通过 docker-compose 部署

`docker-compose.yml` 包含了 ttrss 与 postgres 镜像.

1.  下载 `docker-compose.yml` 至任意目录.
2.  更改 `docker-compose.yml` 中的设置（务必更改 postgres 用户密码）.
3.  运行 `docker-compose up -d` 后等待部署完成.
4.  默认通过 181 端口访问 ttrss，默认账户: `admin` 密码: `password`，请第一时间更改.

### 使用建议

* Web 端推荐使用 **[freestyler 插件](http://freestyler.ws)** 来定制自己的 CSS 风格, 尤其是中文字体. 一些样式[代码](https://github.com/HenryQW/Stylish/blob/master/ttrss.css), 请[替换自己的ttrss域名](https://github.com/HenryQW/Stylish/blob/08923469377a974d66f8d2c767e6b6a69616a688/ttrss.css#L1).


* 对于 iOS 用户, [Fever 模拟插件](https://github.com/HenryQW/tinytinyrss-fever-plugin)提供 **[Reeder iOS](http://reederapp.com/ios/)** (最强 RSS 阅读器, 没有之一) 后端支持.

* 对于安卓用户, 强烈推荐一部 iPhone.

### [作者的 GitHub](https://github.com/HenryQW/docker-ttrss-plugins)
