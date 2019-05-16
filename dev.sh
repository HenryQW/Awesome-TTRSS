#!/bin/sh

# For dev use

docker build . -t wangqiru/ttrss

docker-compose up -d

# docker ec -it ttrss sh
