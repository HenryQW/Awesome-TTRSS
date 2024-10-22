import { defineConfig } from 'vitepress';
import { shared } from './shared';
import { en } from './en';
import { zh } from './zh';

export default defineConfig({
  ...shared,

  locales: {
    root: { label: 'English', ...en },
    zh: { label: '中文', ...zh },
  }
})
