const glob = require("glob");

// function for loading all MD files in a directory
const getChildren = function (parent_path, dir) {
  return glob
    .sync(parent_path + "/" + dir + "/*.md")
    .map(path => {
      // remove "parent_path" and ".md"
      // path = path.substring(path.length - 3, 0);
      path = path.slice(parent_path.length + 1, -3);
      // remove README
      if (path.endsWith("README")) {
        path = path.slice(0, -6);
      }
      return path;
    })
    .sort();
};

module.exports = {
  base: "/",
  dest: "./docs/.vuepress/dist",
  plugins: {
    "@vuepress/google-analytics": {
      ga: "G-S0X56ZZMQB"
    },
    "@vuepress/back-to-top": true
  },
  locales: {
    "/zh/": {
      lang: "zh-CN",
      title: "🐋 Awesome TTRSS",
      description: "🐋 A Dockerized powerful all-in-one Tiny Tiny RSS solution."
    },
    "/": {
      lang: "en-GB",
      title: "🐋 Awesome TTRSS",
      description: "🐋 一个「容器化」的 Tiny Tiny RSS 一站式解决方案。"
    }
  },
  themeConfig: {
    sidebar: "auto",
    sidebarDepth: 1,
    docsDir: "site",
    repo: "HenryQW/Awesome-TTRSS",
    locales: {
      "/zh/": {
        lang: "zh-CN",
        selectText: "English",
        label: "中文",
        lastUpdated: "上次更新",
        nav: [
          {
            text: "首页",
            link: "/zh/"
          },
          {
            text: "赞助",
            link: "https://opencollective.com/Awesome-TTRSS/"
          }
        ]
      },
      "/": {
        lang: "en-GB",
        selectText: "中文",
        label: "English",
        lastUpdated: "Last Updated",
        nav: [
          {
            text: "Home",
            link: "/"
          },
          {
            text: "Sponsor",
            link: "https://opencollective.com/Awesome-TTRSS/"
          }
        ]
      }
    }
  }
};
