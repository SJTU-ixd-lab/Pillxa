# Agent 开发与协作规范指南

## 一、 通用协作规范（Git 与 CI）

### 1. Git 分支管理与工作流

- **主分支保护**：`main` 分支受保护，严禁直接执行 `git push origin main`。
- **特性分支策略**：所有修改必须在专用分支上进行开发，遵循标准命名规范（例如：`feature/<feature-name>`、`fix/<issue-name>`、`docs/<docs-name>`、`refactor/<name>`）。
- **Pull Request 协议**：所有修改必须通过 Pull Request 合并至 `main` 分支。
- **Commit 提交信息规范**：提交信息必须遵循 Conventional Commits 规范（如：`feat:`、`fix:`、`chore:`、`build:`、`ci:`、`test:`、`docs:`、`refactor:`），并附带清晰的描述。
- **职责解耦与原子化提交**：保持 PR 的原子性与独立性，基础设施/CI 配置与业务功能开发不得随意混在一个 PR 中提交。

### 2. 持续集成与质量门禁（CI & Quality Gate）

- **强制 CI 检查**：所有以 `main` 为目标的 Pull Request 必须通过 GitHub Actions CI 状态检查。
- **测试零容忍机制**：存在测试用例失败或测试用例数为 0 的 PR 严禁合并。

---

## 二、 后端开发与部署规范（Backend）

### 1. Python 虚拟环境要求

- **Conda 环境名称**：`pillbox-backend`
- **强制守则**：所有后端开发、依赖管理、测试执行以及脚本运行，**必须**使用 `pillbox-backend` Conda 环境。

#### 使用方法

```bash
conda activate pillbox-backend
# 或直接通过 conda run 运行命令：
conda run -n pillbox-backend <command>
```

### 2. 本地测试与预推送验证

- 在推送代码前，务必在本地运行并通过后端全量测试套件：
  ```bash
  conda run -n pillbox-backend pytest backend/tests -v
  ```

### 3. 容器与 Docker 部署规范

- **Docker 一致性**：确保 `backend/Dockerfile` 与 `backend/docker-compose.yml` 始终与 `backend/requirements.txt` 及 Python 3.10 运行时环境保持同步一致。
- **端口映射规范**：
  - 容器内部端口：`8000`
  - 宿主机映射端口：`8011`（避免与服务器上其他已有服务端口冲突）
- **标准服务器运维指令**：
  - 构建并后台启动：`docker compose -f backend/docker-compose.yml up -d --build`（或进入 `backend` 目录执行 `docker compose up -d --build`）
  - 查看容器状态：`docker compose -f backend/docker-compose.yml ps`
  - 查看后端日志：`docker compose -f backend/docker-compose.yml logs -f backend`
  - 停止服务容器：`docker compose -f backend/docker-compose.yml down`

### 4. 服务器公网访问与反向代理架构

- **公网访问 Base URL**：`https://ixd.sjtu.edu.cn/pillxa-demo`
- **系统网络拓扑**：
  `客户端 (HTTPS)` -> `Nginx (Port 443 / 80)` -> `宿主机 (127.0.0.1:8011)` -> `Docker 容器 (Port 8000)`
- **Nginx 反向代理配置规则**：
  ```nginx
  location /pillxa-demo/ {
      proxy_pass http://127.0.0.1:8011/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
  }
  ```
- **公网服务验证端点**：
  - 健康检查接口：`curl -i https://ixd.sjtu.edu.cn/pillxa-demo/health`
  - 今日用药计划接口：`curl -i https://ixd.sjtu.edu.cn/pillxa-demo/medications/today`

---

## 三、 APP 客户端开发规范（App - 待补充）

*(后续开发 APP 客户端时在此补充技术栈选型、依赖管理、调试构建与代码规范)*

---

## 四、 硬件固件开发规范（Firmware - 待补充）

*(后续开发硬件固件时在此补充 ESP32 芯片环境、烧录流程与通信协议规范)*
