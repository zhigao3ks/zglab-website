# ZGLab 博客维护指南

博客代码位于 `zglab-website`，文章正文仍以相邻的 `notes` 仓库为唯一内容源。构建前，`scripts/sync-notes.mjs` 会把允许使用的内容目录复制到 Astro Content Collection。

## 本地目录约定

```text
/home/zhigao/projects/
├── notes/
└── zglab-website/
```

目录不相邻时，可以在 `.env` 或命令行中设置：

```dotenv
NOTES_SOURCE_DIR=/absolute/path/to/notes
```

## 发布文章

文章 Frontmatter 至少包含：

```yaml
---
title: '文章标题'
date: 2026-07-30
updated: 2026-07-30
status: published
category: knowledge
tags:
  - Astro
summary: '用于列表和 SEO 的文章摘要。'
---
```

支持的核心状态：

- `draft`：仅保留在内容仓库，不生成公开页面；
- `published`：日期不晚于构建时间时公开；
- `archived`：保留内容，但不生成公开页面。

推荐分类为 `knowledge`、`problems`、`projects`、`conversations`、`daily`。图片统一放在 `notes/figures/`，文章中使用相对路径引用。

## 构建流程

`npm run dev`、`npm run check` 和 `npm run build` 都会自动先同步文章，也可以单独执行：

```bash
npm run sync:notes
```

内容源缺失时，同步脚本会生成空 collection 并正常退出，避免主站构建失败。此时 `/notes` 展示空状态。

生产发布：

```bash
npm ci
npm run check
npm run build
./scripts/deploy.sh
```

## Mermaid

Markdown 中使用 `mermaid` 代码块即可。文章页面会按需从 jsDelivr 加载 Mermaid ESM；没有 Mermaid 图表的文章不会请求该脚本。加载失败时，其余文章内容仍正常显示。
