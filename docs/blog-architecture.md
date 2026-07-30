# 博客 MVP 架构

```text
notes repository
  ├── knowledge/
  ├── problems/
  ├── projects/
  ├── conversations/
  ├── daily/
  └── figures/
        │
        ▼ scripts/sync-notes.mjs
src/content/notes/
        │
        ▼ Astro Content Collections
/notes/ + /notes/[...slug] + RSS + Sitemap
```

## 边界

- `notes` 是文章正文的唯一事实源。
- `zglab-website` 只保存同步、校验、路由和展示代码。
- `status: draft`、`status: archived` 和未来日期文章不生成公开详情页。
- 内容源缺失不会阻断个人主页构建。
- 生产环境继续输出纯静态文件，不新增数据库和常驻 Node 服务。
