# ZGLab 内容维护指南

本文说明 `src/data/`、`src/content/projects/` 和 `src/content/logs/` 中的全部字段。所有 YAML 文件使用两个空格缩进，不要使用 Tab。

## 1. `profile.yaml`

| 字段                        | 类型     | 必填 | 说明                            |
| --------------------------- | -------- | ---- | ------------------------------- |
| `name`                      | string   | 是   | 中文姓名                        |
| `nameEn`                    | string   | 否   | 英文或拼音姓名                  |
| `role`                      | string   | 是   | 当前身份                        |
| `school`                    | string   | 否   | 学校名称；存在时显示身份标签    |
| `status`                    | string   | 是   | 中文当前状态                    |
| `statusEn`                  | string   | 是   | 英文状态辅助文本                |
| `headline`                  | string   | 是   | Hero 方向概括                   |
| `intro`                     | string   | 是   | 一句话介绍                      |
| `bio`                       | string[] | 是   | 完整介绍，每项显示为一个段落    |
| `directions`                | string[] | 是   | 主要方向                        |
| `researchThreads`           | object[] | 是   | 研究主题列表                    |
| `researchThreads[].id`      | string   | 是   | 稳定唯一标识                    |
| `researchThreads[].title`   | string   | 是   | 研究主题名称                    |
| `researchThreads[].summary` | string   | 是   | 主题简介                        |
| `github`                    | URL      | 否   | GitHub 地址；删除后相关入口隐藏 |
| `email`                     | email    | 否   | 联系邮箱；删除后相关入口隐藏    |
| `website`                   | URL      | 否   | 个人网站地址                    |
| `avatar`                    | string   | 否   | `public/` 下头像的绝对站内路径  |
| `avatarAlt`                 | string   | 否   | 头像替代文本                    |

## 2. `skills.yaml`

文件顶层为数组。

| 字段          | 类型     | 必填 | 说明         |
| ------------- | -------- | ---- | ------------ |
| `id`          | string   | 是   | 分组唯一标识 |
| `title`       | string   | 是   | 技能分组名称 |
| `description` | string   | 是   | 能力说明     |
| `keywords`    | string[] | 是   | 技术关键词   |

## 3. `publications.yaml`

| 字段      | 类型   | 必填 | 说明                                        |
| --------- | ------ | ---- | ------------------------------------------- |
| `id`      | string | 是   | 论文唯一标识                                |
| `title`   | string | 是   | 论文标题                                    |
| `journal` | string | 是   | 期刊名称                                    |
| `level`   | string | 是   | 期刊或会议级别                              |
| `note`    | string | 否   | 封面文章等补充说明                          |
| `role`    | string | 是   | 作者角色或顺序                              |
| `status`  | enum   | 是   | 仅允许 `Published` 或 `Under Review / 在投` |
| `summary` | string | 是   | 研究简介                                    |

不要添加未经确认的 DOI、链接、发表年月、卷期号。`Under Review / 在投` 不能写成 `Published`。

## 4. `awards.yaml`

| 字段      | 类型   | 必填 | 说明             |
| --------- | ------ | ---- | ---------------- |
| `id`      | string | 是   | 竞赛记录唯一标识 |
| `name`    | string | 是   | 竞赛名称         |
| `task`    | string | 是   | 竞赛任务         |
| `result`  | string | 是   | 团队或个人成绩   |
| `level`   | string | 是   | 竞赛级别         |
| `summary` | string | 是   | 方法与实践简介   |

## 5. `ideas.yaml`

| 字段             | 类型     | 必填 | 说明                        |
| ---------------- | -------- | ---- | --------------------------- |
| `id`             | string   | 是   | 想法唯一标识                |
| `title`          | string   | 是   | 想法名称                    |
| `summary`        | string   | 是   | 一句话描述                  |
| `status`         | enum     | 是   | 生命周期状态                |
| `createdAt`      | date     | 是   | 创建日期，格式 `YYYY-MM-DD` |
| `tags`           | string[] | 否   | 分类标签                    |
| `relatedProject` | string   | 否   | 关联项目的 `slug`           |
| `visible`        | boolean  | 是   | 是否公开展示                |

状态值：

- `exploring`：探索中
- `planned`：已规划
- `building`：构建中
- `online`：已上线
- `paused`：暂停
- `archived`：归档

## 6. `now.yaml`

| 字段             | 类型     | 必填 | 说明               |
| ---------------- | -------- | ---- | ------------------ |
| `currentProject` | string   | 否   | 当前项目的 `slug`  |
| `eyebrow`        | string   | 是   | 英文辅助标题       |
| `title`          | string   | 是   | 当前重点标题       |
| `problem`        | string   | 是   | 当前正在解决的问题 |
| `recentUpdate`   | string   | 是   | 最近更新           |
| `principles`     | string[] | 是   | 当前工作原则       |

如果 `currentProject` 与某个公开项目的 `slug` 匹配，首页会自动显示项目详情入口和部分技术栈。

## 7. `timeline.yaml`

| 字段      | 类型    | 必填 | 说明                                   |
| --------- | ------- | ---- | -------------------------------------- |
| `id`      | string  | 是   | 节点唯一标识                           |
| `marker`  | string  | 是   | 时间或阶段标记，例如 `2026.07`、`当前` |
| `title`   | string  | 是   | 节点标题                               |
| `summary` | string  | 是   | 节点说明                               |
| `type`    | enum    | 是   | `lab`、`project` 或 `research`         |
| `visible` | boolean | 是   | 是否公开                               |

项目起止时间必须有可靠来源，不能为了视觉完整而补写。

## 8. 项目 Markdown

目录：`src/content/projects/*.md`

文件由 YAML Frontmatter 和 Markdown 正文组成：

```md
---
title: 示例项目
slug: example-project
summary: 项目简介
visible: true
order: 10
---

## 问题定义

项目正文。
```

### Frontmatter 字段

| 字段                     | 类型     | 必填 | 默认值 / 说明                          |
| ------------------------ | -------- | ---- | -------------------------------------- |
| `title`                  | string   | 是   | 项目名称                               |
| `slug`                   | string   | 是   | URL 标识，只允许小写字母、数字和连字符 |
| `summary`                | string   | 是   | 项目摘要                               |
| `status`                 | enum     | 否   | 项目状态；缺省时不显示状态             |
| `progress`               | number   | 否   | 0–100；没有可靠数据时不要填写          |
| `featured`               | boolean  | 否   | 默认 `false`，是否优先作为代表项目     |
| `visible`                | boolean  | 否   | 默认 `true`                            |
| `order`                  | integer  | 否   | 默认 `0`，越小越靠前                   |
| `startedAt`              | date     | 否   | 项目开始时间                           |
| `updatedAt`              | date     | 否   | 项目更新时间                           |
| `categories`             | string[] | 否   | 项目分类，用于筛选                     |
| `tags`                   | string[] | 否   | 主题标签                               |
| `stack`                  | string[] | 否   | 技术栈                                 |
| `cover`                  | string   | 否   | `public/` 下封面路径                   |
| `gallery`                | string[] | 否   | `public/` 下画廊路径，首版保留字段     |
| `highlights`             | string[] | 否   | 项目重点                               |
| `links.demo`             | URL      | 否   | 在线演示                               |
| `links.repository`       | URL      | 否   | 代码仓库                               |
| `links.documentation`    | URL      | 否   | 项目文档                               |
| `runtime.enabled`        | boolean  | 否   | 是否允许查询运行状态，默认 `false`     |
| `runtime.statusEndpoint` | string   | 否   | 相对于状态 API 的项目端点              |

`status` 可选值：

- `exploring`
- `planned`
- `building`
- `completed`
- `online`
- `paused`

未提供的 URL 字段应直接省略，不要写空字符串或 `#`。页面会自动隐藏缺失的封面、日期、进度和外部链接。

### 新增项目检查清单

1. 文件名清晰且不与已有文件冲突。
2. `slug` 唯一，并与期望 URL 一致。
3. `title`、`summary`、`visible`、`order` 正确。
4. 指标、时间、链接和状态已有可靠依据。
5. Markdown 正文使用 `##` 开始组织章节。
6. 运行 `npm run check` 和 `npm run build`。

## 9. Lab Log Markdown

目录：`src/content/logs/*.md`

| 字段      | 类型     | 必填 | 说明        |
| --------- | -------- | ---- | ----------- |
| `title`   | string   | 是   | 日志标题    |
| `date`    | date     | 是   | 记录日期    |
| `summary` | string   | 是   | 日志摘要    |
| `visible` | boolean  | 否   | 默认 `true` |
| `tags`    | string[] | 否   | 日志标签    |

Markdown 正文用于记录详细内容。首版已建立 Collection 与 Schema，后续可添加日志归档页，无需改变内容格式。

## 10. 导航与功能

- `src/config/site.ts`：站点名称、所有者、URL、默认 SEO 文案。
- `src/config/navigation.ts`：导航顺序、文字和地址。
- `src/config/features.ts`：功能开关。

带 `feature` 的导航项只会在对应开关为 `true` 时出现。启用新功能前，先确认对应页面已经实现并通过构建。

## 11. 运行时接口

项目运行状态字段只描述“是否允许查询”和“查询哪个公开端点”。真实请求由 `src/services/runtime.ts` 负责：

- 环境变量未配置：立即返回 `null`，不发送请求。
- 网络错误或非 2xx：返回 `null`，不影响静态内容。
- 响应成功：返回 `src/types/runtime.ts` 定义的公开数据。

环境变量：

| 变量                         | 说明                       |
| ---------------------------- | -------------------------- |
| `PUBLIC_STATUS_API_BASE_URL` | 公开的状态服务基础地址     |
| `PUBLIC_GITHUB_PROXY_URL`    | 公开的 GitHub 数据代理地址 |

两者都会进入前端构建结果，不得包含 Token、密码、签名密钥或私有 API Key。
