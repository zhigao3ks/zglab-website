# ZGLab 统一发布

`deploy-all.sh` 是 `zglab.fun` 与 `tools.zglab.fun` 的统一生产发布入口。它会先完整构建两个站点，再使用同一条 SSH 控制连接上传和发布，避免在一次发布中重复进行服务器认证。

## 目录约定

默认本地目录：

```text
/home/zhigao/projects/
├── notes/
├── zglab-website/
└── zglab-tools/
```

主站构建时会自动从相邻的 `notes` 仓库同步已发布文章。

## 第一次使用

拉取最新代码：

```bash
git -C /home/zhigao/projects/zglab-website pull --ff-only origin main
git -C /home/zhigao/projects/zglab-tools pull --ff-only origin main
```

按需创建本地配置：

```bash
cd /home/zhigao/projects/zglab-website
cp ops/deploy.env.example ops/deploy.env
```

当前服务器、域名和目录都已经写入默认值，不修改也可以使用。`ops/deploy.env` 已被 Git 忽略。

只执行一次服务器目录初始化：

```bash
bash ops/bootstrap-server.sh
```

这一步会：

- 检查并安装远程 `rsync`、`curl`；
- 将两个站点目录统一交给部署用户管理；
- 创建统一暂存目录与备份目录；
- 保证 Nginx 可以读取静态文件；
- 验证 Nginx 配置，但不会修改域名或证书配置。

它会进行一次 SSH 认证和一次 `sudo` 认证。完成后，日常静态发布不再需要 `sudo`。

## 日常发布

在主站仓库运行：

```bash
npm run deploy:all
```

也可以直接运行：

```bash
bash ops/deploy-all.sh
```

脚本执行顺序：

1. 要求两个仓库均在干净的 `main` 分支；
2. 对两个仓库执行 `git pull --ff-only`；
3. 主站执行依赖安装、格式检查、Astro Check 和构建；
4. 工具站执行依赖安装、格式检查、ESLint、Astro Check、测试和构建；
5. 建立一条可复用的 SSH 控制连接；
6. 上传两个站点的 `dist`；
7. 同时备份两个线上版本；
8. 同时发布两个站点；
9. 严格检查两个 HTTPS `health.txt`；
10. 任意检查失败时同时回滚两个站点。

不拉取远端、直接发布当前本地 `main`：

```bash
npm run deploy:all -- --no-pull
```

## 认证次数

脚本通过 OpenSSH `ControlMaster` 在一次运行中复用同一条连接。因此即使仍使用服务器密码认证，一次发布通常也只输入一次服务器密码。

更推荐使用 SSH 密钥，并由 `ssh-agent` 缓存密钥密码：

```bash
ssh-keygen -t ed25519 -f ~/.ssh/zglab_deploy
ssh-copy-id -i ~/.ssh/zglab_deploy.pub ubuntu@124.223.48.17
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/zglab_deploy
```

可以在 `~/.ssh/config` 中增加：

```sshconfig
Host zglab-server
    HostName 124.223.48.17
    User ubuntu
    IdentityFile ~/.ssh/zglab_deploy
    IdentitiesOnly yes
```

然后将配置改为：

```dotenv
DEPLOY_SERVER=zglab-server
```

## 备份与回滚

统一备份默认保存在：

```text
/var/backups/zglab-release/<UTC时间>-<主站提交>-<工具站提交>/
├── website/
└── tools/
```

默认保留最近 10 次。发布后的健康检查失败时，脚本会自动恢复本次发布前的两个站点版本。

手动查看备份：

```bash
ssh ubuntu@124.223.48.17 \
  'find /var/backups/zglab-release -mindepth 1 -maxdepth 1 -type d | sort -r | head'
```

## 安全边界

- 不允许从非 `main` 分支发布；
- 不允许带未提交修改发布；
- 不使用 `git reset --hard`；
- 不修改 Nginx、Certbot 或防火墙配置；
- 远程路径必须位于 `/var/www/`、`/tmp/` 和 `/var/backups/` 的指定范围；
- 配置文件不得保存服务器密码、私钥或任何 Token。
