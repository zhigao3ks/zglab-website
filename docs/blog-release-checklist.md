# 博客发布检查清单

1. 确认 `notes` 与 `zglab-website` 位于相邻目录，或设置 `NOTES_SOURCE_DIR`。
2. 在 `notes` 中选择首批文章，将 `status` 改为 `published`。
3. 执行 `npm ci`。
4. 执行 `npm run format:check`。
5. 执行 `npm run check`。
6. 执行 `npm run build`。
7. 检查 `/notes/`、一篇文章详情、`/notes/rss.xml` 和 `/sitemap.xml`。
8. 执行 `./scripts/deploy.sh`。
