# 博客 MVP 验证记录

## 已完成

- `scripts/sync-notes.mjs` 已使用模拟 `notes` 目录执行；Markdown 与 `figures/` 能同步到 `src/content/notes/`。
- 内容源不存在时，同步脚本正常退出并保留空 collection。
- 已核对 Astro Content Collections 的 `glob()`、`body`、`filePath` 和 `render()` API。
- 已核对静态动态路由 `getStaticPaths()` 与静态 XML 端点写法。
- 已确认分支只修改 `zglab-website`，未修改 `notes` 仓库。

## 合并前需要在项目环境执行

```bash
npm ci
npm run format:check
npm run check
npm run build
```

当前执行环境的 npm 镜像无法获取 `@astrojs/check`，因此完整 Astro 类型检查和构建需要在本地 WSL 或服务器项目目录完成。

## 内容验收

目前 `notes` 仓库中抽查的文章状态为 `draft`，因此生产构建可能只展示博客空状态。需要选定首批文章并将 Frontmatter 改为：

```yaml
status: published
```

文章日期晚于构建时间时仍不会公开。
