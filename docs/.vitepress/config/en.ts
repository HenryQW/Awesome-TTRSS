import { defineConfig } from 'vitepress';

export const en = defineConfig({
  lang: 'en-GB',
  description: "🐋 A Dockerized powerful all-in-one Tiny Tiny RSS solution.",

  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Sponsor', link: 'https://opencollective.com/Awesome-TTRSS' }
    ],
  },
})
