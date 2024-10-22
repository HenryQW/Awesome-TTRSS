import { defineConfig, type DefaultTheme } from 'vitepress';

export const zh = defineConfig({
  lang: "zh-Hans",
  description: "🐋 一个「容器化」的 Tiny Tiny RSS 一站式解决方案。",

  themeConfig: {
    nav: [
      { text: '首页', link: '/zh/' },
      { text: '赞助', link: 'https://opencollective.com/Awesome-TTRSS' }
    ],
    editLink: {
      pattern: 'https://github.com/HenryQW/Awesome-TTRSS/edit/main/docs/:path',
      text: '在 GitHub 上编辑此页面'
    },
    outline: {
      level: [2, 3],
      label: '页面导航'
    },
    lastUpdated: {
      text: '最后更新于',
    },
  },
})

export const search: DefaultTheme.LocalSearchOptions['locales'] = {
  zh: {
    translations: {
      button: {
        buttonText: '搜索',
        buttonAriaLabel: '搜索'
      },
      modal: {
        displayDetails: '显示详情',
        resetButtonTitle: '重置搜索',
        backButtonTitle: '关闭搜索',
        noResultsText: '没有结果',
        footer: {
          selectText: '选择',
          selectKeyAriaLabel: '输入',
          navigateText: '导航',
          navigateUpKeyAriaLabel: '上箭头',
          navigateDownKeyAriaLabel: '下箭头',
          closeText: '关闭',
          closeKeyAriaLabel: 'esc'
        }
      }
    }
  }
}
