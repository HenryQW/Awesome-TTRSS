![Docker Pulls](https://img.shields.io/docker/pulls/wangqiru/ttrss.svg)
![Docker Stars](https://img.shields.io/docker/stars/wangqiru/ttrss.svg)

![Docker Automated build](https://img.shields.io/docker/automated/wangqiru/ttrss.svg)
![Docker Build Status](https://img.shields.io/docker/build/wangqiru/ttrss.svg)

[简体中文说明在这里](#简体中文说明)

#### Tiny Tiny RSS feed reader as a docker image.

#### Plugins

1.  [Mercury_fulltext](https://github.com/HenryQW/mercury_fulltext): fetches fulltext of articles via Mercury API.
2.  [Fever plugin](https://github.com/HenryQW/tinytinyrss-fever-plugin): simulates Fever API.
3.  [Feediron](https://github.com/feediron/ttrss_plugin-feediron): enables modification of article's DOM.

#### Theme

[Feedly](https://github.com/levito/tt-rss-feedly-theme)

**Support postgres only for better user experience.** mysql support is dropped since [tag 3.5_mysql_php5](https://github.com/HenryQW/docker-ttrss-plugins/tree/3.5_mysql_php5).

### Example usage:

```
docker run -it --name ttrss --restart=always \
--link [ your DB container ]:db  \
-e SELF_URL_PATH = [ your URL ]  \
-e DB_USER = [ your DB user ]  \
-e DB_PASS = [ your DB password ]  \
-p [ your port ]:80  \
-d wangqiru/ttrss
```

A full setup using docker-compose is on the way, when the summer vacation ends. 
https://github.com/HenryQW/docker-ttrss-plugins/issues/2

### List of Docker ENV

* ENV SELF_URL_PATH
* ENV DB_NAME
* ENV DB_USER
* ENV DB_PASS

### Recommendation

* For web interface, recommend to use **[Stylish plugin](https://userstyles.org/)** to customise your own CSS style, especially for non-western languages.

  ```css
  .postContent {
      font-size: 16px;
  }

  .hlContent {
      font-size: 15px;
  }

  html, button, input, select, textarea {
      font: 13px/1.5 Helvetica sans-serif, Arial, "Microsoft Yahei";
  }

  #floatingTitle > *, .cdm.expandable:not(.active) .cdmHeader > *, .hl > * {
      padding: 5px 5px;
      order: 3;
  }

  #floatingTitle .title, .postHeader .postTitle a {
      font-weight: bold;
      font-size: 16px;
  ```

* For iOS user, [Fever plugin](https://github.com/HenryQW/tinytinyrss-fever-plugin) supplies **[Reeder iOS](http://reederapp.com/ios/)** (THE RSS READER) backend support.

* For Android user, strongly recommend an iPhone.

### [Author's GitHub](https://github.com/HenryQW/docker-ttrss-plugins)

# 简体中文说明

#### Tiny Tiny RSS 容器镜像

#### 插件

1. [Mercury](https://github.com/HenryQW/mercury_fulltext): 全文内容提取插件（Mercury API）.
2. [Fever](https://github.com/HenryQW/tinytinyrss-fever-plugin): Fever API 模拟插件.
3. [Feediron](https://github.com/feediron/ttrss_plugin-feediron): 提供文章 DOM 操控能力的插件.

#### 主题

[Feedly](https://github.com/levito/tt-rss-feedly-theme)

**为了更好的用户体验，此镜像仅支持 postgres 数据库.** 自 [tag 3.5_mysql_php5](https://github.com/HenryQW/docker-ttrss-plugins/tree/3.5_mysql_php5) 起停止支持 mysql.

### 使用样例:

```
docker run -it --name ttrss --restart=always \
--link [ 你的数据库容器名 ] : db  \
-e SELF_URL_PATH = [ 你的URL地址 ]  \
-e DB_USER = [ 你的数据库用户名 ]  \
-e DB_PASS = [ 你的数据库密码 ]  \
-p [ 容器对外映射端口 ]:80  \
-d wangqiru/ttrss
```

度假回来后着手实施 docker-compose 一键部署。
https://github.com/HenryQW/docker-ttrss-plugins/issues/2

### Docker ENV 变量列表

* ENV SELF_URL_PATH
* ENV DB_NAME
* ENV DB_USER
* ENV DB_PASS

### 使用建议

* Web 端推荐使用 **[Stylish 插件](https://userstyles.org/)** 来定制自己的 CSS 风格, 尤其是中文字体.

  ```css
  .postContent {
      font-size: 16px;
  }

  .hlContent {
      font-size: 15px;
  }

  html, button, input, select, textarea {
      font: 13px/1.5 Helvetica sans-serif, Arial, "Microsoft Yahei";
  }

  #floatingTitle > *, .cdm.expandable:not(.active) .cdmHeader > *, .hl > * {
      padding: 5px 5px;
      order: 3;
  }

  #floatingTitle .title, .postHeader .postTitle a {
      font-weight: bold;
      font-size: 16px;
  ```

* 对于 iOS 用户, [Fever 模拟插件](https://github.com/HenryQW/tinytinyrss-fever-plugin)提供 **[Reeder iOS](http://reederapp.com/ios/)** (最强 RSS 阅读器, 没有之一) 后端支持.

* 对于安卓用户, 强烈推荐一部 iPhone.

### [作者的 GitHub](https://github.com/HenryQW/docker-ttrss-plugins)
