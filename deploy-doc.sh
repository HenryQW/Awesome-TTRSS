#!/bin/bash

cd docs/.vuepress/dist

echo 'ttrss.henry.wang' >CNAME

git init
git add -A
git -c "user.name=GitHub Actions" -c "user.email=actions@github.com" commit -m "docs:deploy $(date '+%Y-%m-%d %H:%M:%S')"

git push -f https://${CI_TOKEN}@github.com/HenryQW/Awesome-TTRSS.git master:gh-pages
