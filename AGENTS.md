# Agent 开发规范指南

## 一、 通用协作规范

### 1. Git 分支管理与工作流

- **主分支保护**：`main` 分支受保护，严禁直接执行 `git push origin main`。
- **特性分支策略**：所有修改必须在专用分支上进行开发，遵循标准命名规范（例如：`feature/<feature-name>`、`fix/<issue-name>`、`docs/<docs-name>`、`refactor/<name>`）。
- **Pull Request 协议**：所有修改必须通过 Pull Request 合并至 `main` 分支。
- **Commit 提交信息规范**：提交信息必须遵循 Conventional Commits 规范（如：`feat:`、`fix:`、`chore:`、`build:`、`ci:`、`test:`、`docs:`、`refactor:`），并附带清晰的描述。

### 2. 持续集成与质量门禁（CI & Quality Gate）

- **强制 CI 检查**：所有以 `main` 为目标的 Pull Request 必须通过 GitHub Actions CI 状态检查。
- **测试零容忍机制**：存在测试用例失败或测试用例数为 0 的 PR 严禁合并。

---

## 二、 后端开发与部署规范

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

---

## 三、 APP 客户端开发规范
