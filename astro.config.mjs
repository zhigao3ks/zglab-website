// @ts-check
import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://zglab.fun',
  output: 'static',
  build: {
    format: 'directory',
  },
});
