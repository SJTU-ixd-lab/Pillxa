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

### 4. 服务器公网访问与反向代理架构

- **公网访问 Base URL**：`https://ixd.sjtu.edu.cn/pillxa-demo`
- **系统网络拓扑**：
  `客户端 (HTTPS)` ➔ `Nginx (Port 443 / 80)` ➔ `宿主机 (127.0.0.1:8011)` ➔ `Docker 容器 (Port 8000)`
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

---

## 四、 自动化持续交付与部署规范 (CI/CD Pipeline)

本项目已建立完整的全自动化 CI/CD 流水线，分为**后端服务器自动化部署**与**APP 客户端持续交付**两部分。

### 1. 后端服务器持续部署 (Backend Server CD)

- **工作流文件**：`.github/workflows/deploy.yml`
- **部署架构**：基于 **GitHub Actions Self-Hosted Runner**（运行于学校内网服务器的后台守护进程），无需开放外网 22 SSH 端口，通过出站长连接实现安全拉取与部署。
- **触发机制**：
  - **自动触发**：代码合并至 `main` 分支且修改涉及 `backend/**` 或部署配置时。
  - **手动触发**：支持在 GitHub Actions 页面通过 `workflow_dispatch` 手动一键部署。
- **流水线执行链路**：
  1. **代码同步**：自托管 Runner 自动增量拉取最新代码至工作区。
  2. **环境门禁**：自动在 `pillbox-backend` Conda 环境中执行全量单元测试（Pytest 失败则立即中断部署）。
  3. **容器热更**：自动执行 `docker compose -f backend/docker-compose.yml up -d --build --remove-orphans` 完成容器重新构建与无缝重启。
  4. **状态核验**：自动输出 `docker compose ps` 容器健康状态，后端服务继续通过宿主机 `8011` 端口对外提供服务（由 Nginx 反代至 `https://ixd.sjtu.edu.cn/pillxa-demo`）。

### 2. APP 客户端持续交付与发布 (App Client CD & Release)

#### (1) 预览版自动构建与归档 (Android Preview Build)
- **工作流文件**：`.github/workflows/build.yml`
- **触发机制**：代码合并至 `main` 分支时自动触发。
- **构建产物**：自动编译 Android Debug APK，并在 GitHub Actions 中作为 Artifact 归档保留 14 天，供内部快速测试验证。

#### (2) 正式发布流水线 (Android Formal Release)
- **工作流文件**：`.github/workflows/release.yml`
- **触发机制**：
  - 推送符合语义化版本规范的 Git Tag（如 `v1.0.0`、`v1.0.1`）。
  - 支持在 GitHub Actions 页面手动指定 Tag 版本号触发。
- **自动化构建产物**：
  - **多架构分包 APK**：自动生成适配主流 CPU 架构的轻量 APK（`arm64-v8a`、`armeabi-v7a`、`x86_64`）。
  - **应用包 Bundle**：自动生成适用于商店分发的 `aab` 文件。
  - **安全校验**：自动计算所有发布产物的 `sha256sum` 校验和。
  - **自动 Release 发布**：自动创建 GitHub Release 页面，附带更新日志并将安装包直接挂载至 Release Assets 供用户下载。
