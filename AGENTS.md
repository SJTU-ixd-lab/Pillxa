# 开发总规范
开发Agent必须严格遵守本项目的开发规范
## 一、 通用协作规范

### 1. Git 分支管理与工作流

- **⚠️ 主分支红线（严禁直推）**：`main` 分支维护稳定的生产/演示代码版本。由于所属组织私有仓库可能无法通过平台设置硬性主分支保护规则，**严禁 Agent 直接向 `main` 分支执行 `git push` 提交**。
- **特性分支策略**：所有修改必须在专用分支上进行开发，遵循标准命名规范（例如：`feature/<feature-name>`、`fix/<issue-name>`、`docs/<docs-name>`、`refactor/<name>`）。
- **Pull Request 强制协议**：所有代码变更必须先 push 到对应的特性分支，然后通过 Pull Request 审查后合并至 `main` 分支。
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

### 1. 技术栈与框架规范

- **开发框架**：Flutter (Dart 3.x)
- **工程目录**：`app/`
- **依赖管理**：所有客户端依赖统一在 `app/pubspec.yaml` 中声明，禁止在根目录混杂前端包管理文件。

#### 常用命令

```bash
cd app
# 获取依赖
flutter pub get
# 本地调试运行
flutter run
# 运行客户端测试
flutter test
```

### 2. 网络与 API 交互规范

- **服务分层**：所有与云端后端的 HTTP 接口交互必须统一封装在 `app/lib/services/` 目录下（如 `ApiService`）。
- **默认 Base URL**：生产/演示环境默认连接公网反代地址 `https://ixd.sjtu.edu.cn/pillxa-demo`。
- **数据模型**：所有 JSON 解析与实体映射统一放在 `app/lib/models/` 目录，必须包含健壮的 `fromJson` 解析与空值兜底。

### 3. 测试与质量验证

- 客户端单元测试与 Widget 测试统一放在 `app/test/` 目录。
- 提交前应在 `app/` 目录下执行并通过 `flutter test`。
