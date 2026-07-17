# ZGLab

黄志高的个人数字研究档案与工程实验室门户。项目使用 Astro + TypeScript 构建，内容由 YAML 和 Astro Content Collections 驱动，默认输出纯静态文件，不需要常驻 Node 服务。

## 1. 环境要求

- Ubuntu 24.04 或其他常见 Linux / macOS 环境
- Node.js `>= 22.12.0`
- npm `>= 10`
- 生产部署需要 Nginx 与 rsync

检查版本：

```bash
node --version
npm --version
```

## 2. 本地启动

```bash
cd /home/zhigao/projects/zglab-website
npm install
npm run dev
```

默认开发地址为 `http://localhost:4321`。项目内开发约定要求自动化场景使用后台模式：

```bash
npm run astro -- dev --background
npm run astro -- dev status
npm run astro -- dev logs
npm run astro -- dev stop
```

## 3. 检查与构建

```bash
npm run format:check
npm run check
npm run build
```

构建结果写入 `dist/`。可以使用以下命令本地预览：

```bash
npm run preview
```

预览命令仅用于本地验收；生产环境直接由 Nginx 托管 `dist/`。

## 4. 项目目录

```text
zglab-website/
├── public/
│   └── images/                 # 头像和未来的静态图片
├── docs/
│   └── content-guide.md        # 所有内容字段说明
├── scripts/
│   └── deploy.sh               # 备份并同步到 Nginx 目录
├── src/
│   ├── components/             # Astro 展示组件
│   ├── config/                 # 站点、导航和功能开关
│   ├── content/
│   │   ├── projects/           # 每个项目一份 Markdown
│   │   └── logs/               # Lab Log Markdown
│   ├── data/                   # 个人资料、论文、竞赛、想法等 YAML
│   ├── layouts/                # 全站布局
│   ├── lib/                    # 数据加载、状态映射和内容查询
│   ├── pages/                  # Astro 路由
│   ├── services/               # 未来动态接口层
│   ├── styles/                 # 原生 CSS 视觉系统
│   ├── types/                  # TypeScript 类型
│   └── content.config.ts       # Content Collections + Zod Schema
├── .env.example
├── astro.config.mjs
└── package.json
```

## 5. 修改个人信息

编辑 `src/data/profile.yaml`：

- 姓名、身份、状态和一句话介绍
- 完整个人介绍
- 主要方向和研究主题
- GitHub、邮箱、网站
- 头像路径与 alt 文本

保存后开发服务器会自动刷新；生产环境需要重新执行 `npm run build` 和部署。

## 6. 添加新项目

最短流程：

1. 复制 `src/content/projects/meeting-agent.md`。
2. 修改文件名、`title`、`slug`、`summary`、`order` 和正文。
3. 按需填写状态、分类、技术栈、亮点与公开链接。
4. 执行 `npm run check && npm run build`。

项目列表和 `/projects/[slug]` 详情页会自动生成，不需要修改页面或组件代码。字段完整说明见 `docs/content-guide.md`。

不要填写未经确认的时间、仓库地址、演示地址、指标或运行状态。空链接应直接删除该字段，不要写 `#`。

## 7. 添加论文

编辑 `src/data/publications.yaml` 并追加一项。当前 Schema 只接受：

- `Published`
- `Under Review / 在投`

在投论文不得改成已发表。没有可靠信息时，不要添加 DOI、论文链接、年月、卷号或期号；当前站点也不会展示这些字段。

## 8. 添加竞赛

编辑 `src/data/awards.yaml`，追加 `id`、名称、任务、成绩、级别和简介。名次和会议等级应使用已经确认的原始信息。

## 9. 添加想法

编辑 `src/data/ideas.yaml`。允许的状态：

- `exploring`
- `planned`
- `building`
- `online`
- `paused`
- `archived`

将 `visible` 设为 `false` 可从网站隐藏该想法。

## 10. 替换头像

1. 将新文件放入 `public/images/`，例如 `avatar-new.webp`。
2. 编辑 `src/data/profile.yaml`：

```yaml
avatar: /images/avatar-new.webp
avatarAlt: 新头像的准确文字描述
```

3. 执行 `npm run build`。

如暂时不显示头像，删除 `avatar` 字段；页面不会生成空图片。

## 11. 功能开关与未来接口

功能开关位于 `src/config/features.ts`：

```ts
export const features = {
  notes: false,
  tools: false,
  runtimeStatus: false,
  githubActivity: false,
  downloadResume: false,
};
```

关闭的导航入口不会渲染。运行时接口的类型和容错封装位于：

- `src/types/runtime.ts`
- `src/services/runtime.ts`

如需接入公开接口：

```bash
cp .env.example .env
```

然后填写公开地址：

```dotenv
PUBLIC_STATUS_API_BASE_URL=https://status.example.com/
PUBLIC_GITHUB_PROXY_URL=https://proxy.example.com/repository
```

`PUBLIC_` 前缀变量会进入浏览器构建结果，绝对不能填写 GitHub Token、密码或任何私密密钥。接口地址为空时，服务层不会发送请求、不会报错，网站继续使用静态内容构建。

首版只预留接口与类型，不展示未经验证的动态数据。接入展示前还需要开启对应 feature，并在组件中消费服务返回值。

## 12. 构建并部署到 Nginx

先构建：

```bash
npm ci
npm run check
npm run build
```

执行部署脚本：

```bash
./scripts/deploy.sh
```

默认部署目录是 `/var/www/zglab.fun`，默认备份目录是 `/var/backups/zglab.fun`。可通过环境变量覆盖：

```bash
DEPLOY_DIR=/srv/www/zglab.fun BACKUP_ROOT=/srv/backups/zglab.fun ./scripts/deploy.sh
```

非 root 用户默认使用 `sudo`，脚本本身不保存密码。已经由外部流程取得权限时，可设置：

```bash
DEPLOY_USE_SUDO=0 ./scripts/deploy.sh
```

Nginx 站点配置示例：

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name zglab.fun www.zglab.fun;

    root /var/www/zglab.fun;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~* \.(css|js|svg|webp|png|jpg|jpeg|ico)$ {
        expires 7d;
        add_header Cache-Control "public";
        try_files $uri =404;
    }
}
```

检查并重载：

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 13. 回滚

部署脚本每次部署前都会为现有站点创建带时间戳的完整备份，并且不会删除最近一次或其他历史备份。

列出备份：

```bash
sudo ls -lah /var/backups/zglab.fun
```

回滚到指定备份：

```bash
sudo rsync -a --delete /var/backups/zglab.fun/20260717-120000/ /var/www/zglab.fun/
sudo nginx -t
sudo systemctl reload nginx
```

将示例时间戳替换为实际备份目录。回滚前建议再备份当前部署目录。

## 内容与安全原则

- 所有个人事实与成果数据由配置或内容文件读取。
- 空链接、空图片和关闭的页面入口不会渲染。
- 不填写虚构的 stars、访问量、在线状态、DOI、日期或地址。
- 项目状态、论文状态、作者顺序和竞赛名次以源数据为准。
- 生产构建为纯静态文件，不需要 Node 常驻进程。
