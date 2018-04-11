[简体中文说明在这里](#简体中文说明)

#### Tiny Tiny RSS feed reader as a docker image.
#### Modified(heavily) from [rubenv/docker-ttrss-plugins](https://github.com/rubenv/docker-ttrss-plugins)

With [Mercury_fulltext](https://github.com/WangQiru/mercury_fulltext) and [updated Fever plugins](https://github.com/WangQiru/tinytinyrss-fever-plugin) that solves compatibility issue (since repo owner is MIA).

With [Feedly](https://github.com/levito/tt-rss-feedly-theme) theme.

**Support postgres only.** mysql support is dropped since [tag 3.5_mysql_php5](https://github.com/WangQiru/docker-ttrss-plugins/tree/3.5_mysql_php5).

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

### List of Docker ENV
- ENV SELF_URL_PATH
- ENV DB_NAME
- ENV DB_USER
- ENV DB_PASS

### Recommendation
- For web interface, recommend to use **[Stylish plugin](https://userstyles.org/)** to customise your own CSS style, especially for non-western languages.

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

- For iOS user, Fever plugin supplies **[Reeder iOS](http://reederapp.com/ios/)** (THE RSS READER) backend support.

- For Android user, strongly recommend an iPhone.



### [Author's GitHub](https://github.com/WangQiru/docker-ttrss-plugins)





# 简体中文说明
#### Tiny Tiny RSS 容器镜像
#### 魔改自 [rubenv/docker-ttrss-plugins](https://github.com/rubenv/docker-ttrss-plugins)

内置 [Mercury_fulltext](https://github.com/WangQiru/mercury_fulltext) 全文提取插件以及修复了（由于原基主已跑路）兼容性问题的 [Fever 模拟插件](https://github.com/WangQiru/tinytinyrss-fever-plugin).

内置 [Feedly](https://github.com/levito/tt-rss-feedly-theme) 主题.

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

### Docker ENV 变量列表
- ENV SELF_URL_PATH
- ENV DB_NAME
- ENV DB_USER
- ENV DB_PASS


### 使用建议
- Web 端推荐使用 **[Stylish 插件](https://userstyles.org/)** 来定制自己的 CSS 风格, 尤其是中文字体.

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

- 对于 iOS 用户, Fever 模拟插件提供 **[Reeder iOS](http://reederapp.com/ios/)** (最强 RSS 阅读器, 没有之一) 后端支持.

- 对于安卓用户, 强烈推荐一部 iPhone.

### [作者的 GitHub](https://github.com/WangQiru/docker-ttrss-plugins)
