import { defineConfig } from 'vitepress';
import { search as zhSearch } from './zh';

// https://vitepress.dev/reference/site-config
export const shared = defineConfig({
  title: "🐋 Awesome TTRSS",

  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    outline: [2, 3],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/HenryQW/Awesome-TTRSS' }
    ],
    editLink: {
      pattern: 'https://github.com/HenryQW/Awesome-TTRSS/edit/main/docs/:path'
    },
    search: {
      provider: 'local',
      options: {
        detailedView: true,
        locales: {
          ...zhSearch,
        }
      }
    }
  },

  lastUpdated: true,

  head: [
    ['link', { rel: 'dns-prefetch', href: 'https://share.henry.wang' }],
    ['script', { async: '', src: 'https://www.googletagmanager.com/gtag/js?id=G-S0X56ZZMQB' }],
    [
      'script',
      {},
      `window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('config', 'G-S0X56ZZMQB');`
    ]
  ],

  markdown: {
    image: {
      lazyLoading: true
    }
  }
})
