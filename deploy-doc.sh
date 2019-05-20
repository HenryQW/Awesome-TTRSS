#!/usr/bin/env sh

set -e

yarn docs:build

cd docs/.vuepress/dist

echo 'ttrss.henry.wang' >CNAME

git init
git add -A
git -c "user.name=Travis CI" -c "user.email=travis@travis-ci.org" commit -m "docs:deploy v$TRAVIS_BUILD_NUMBER"

git push -f https://${GITHUB_TOKEN}@github.com/HenryQW/Awesome-TTRSS.git master:gh-pages

cd -
