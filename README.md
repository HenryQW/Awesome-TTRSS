## Tiny Tiny RSS feed reader as a docker image, forked from [rubenv/docker-ttrss-plugins](https://github.com/rubenv/docker-ttrss-plugins)

With [Mercury_fulltext](https://github.com/WangQiru/mercury_fulltext) and [updated Fever plugins](https://github.com/WangQiru/tinytinyrss-fever-plugin).

With [Feedly](https://github.com/levito/tt-rss-feedly-theme) theme.

### Example usage:

```
docker run -it --name ttrss --restart=always \
--link [your DB container]:db  \
-e SELF_URL_PATH=[your URL]  \
-e DB_USER=[your DB user]  \
-e DB_PASS=[your DB password]  \
-p [your port]:80  \
-d wangqiru/ttrss
```

### List of Docker ENV
- ENV SELF_URL_PATH
- ENV DB_NAME
- ENV DB_USER
- ENV DB_PASS
- ENV MYSQL_CHARSET


### [GitHub](https://github.com/WangQiru/docker-ttrss-plugins)
