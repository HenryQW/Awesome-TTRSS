#!/usr/bin/env sh

set -e

npm run docs:build

cd docs/.vuepress/dist

echo 'ttrss.henry.wang' >CNAME

git init
git add -A
git commit -m 'docs:deploy'

git push -f git@github.com:HenryQW/docker-ttrss-plugins.git master:gh-pages

cd -
