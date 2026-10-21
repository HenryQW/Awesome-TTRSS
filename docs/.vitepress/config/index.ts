import { defineConfig } from 'vitepress';
import { shared } from './shared.ts';
import { en } from './en.ts';
import { zh } from './zh.ts';

export default defineConfig({
  ...shared,

  locales: {
    root: { label: 'English', ...en },
    zh: { label: '中文', ...zh },
  }
})
