# Pillxa - 智能药盒系统 (Smart Pillbox System)

![Python](https://img.shields.io/badge/Python-3.10-blue.svg)
![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-green.svg)
![Docker](https://img.shields.io/badge/Docker-Supported-blue.svg)
![CI](https://img.shields.io/badge/CI-GitHub%20Actions-brightgreen.svg)

**Pillxa** 是一套面向日常健康管理与精准用药场景的智能药盒系统。系统整合了**硬件端（Firmware）**、**用户客户端（App）** 与 **云端服务（Backend）**，通过定时提醒、用药计划分发以及状态同步，帮助用户建立规律、科学的服药习惯。

---

## 🏗️ 目录结构与模块说明 (Project Structure)

本项目采用多端协同的工程结构，整体目录组织如下：

```text
Pillxa/
├── backend/                  # 后端服务核心源码 (FastAPI)
│   ├── Dockerfile            # 后端容器构建定义文件 (Python 3.10-slim)
│   ├── __init__.py
│   └── main.py               # 服务入口、数据模型与 API 路由实现
├── tests/                    # 自动化测试套件
│   ├── __init__.py
│   └── test_medications.py   # 健康检查与用药计划接口自动化测试
├── app/                      # 移动端 / 客户端应用程序模块 (规划中)
│   └── README.md             # 客户端模块说明
├── firmware/                 # 智能药盒硬件嵌入式固件模块 (规划中)
│   └── README.md             # 硬件固件模块说明
├── .github/                  # GitHub 工作流与配置
│   └── workflows/
│       └── ci.yml            # CI 持续集成配置 (Pytest 自动化检查)
├── .dockerignore             # Docker 构建忽略文件
├── .gitignore                # Git 版本控制忽略文件
├── docker-compose.yml        # Docker Compose 容器编排配置
├── requirements.txt          # Python 运行时及开发依赖清单
├── pytest.ini                # Pytest 测试路径与运行配置
├── AGENTS.md                 # 开发者与 AI Agent 协作规范与工程守则
└── README.md                 # 项目全局说明文档 (本文档)
```

### 核心模块职责解析

1. **`backend/` (后端服务)**
   - 基于 **FastAPI** 构建的高性能异步 RESTful API 服务。
   - 核心功能：负责用药计划数据管理、定时计划分发、状态反馈以及服务健康监测。
   - 包含专用的轻量级 `Dockerfile`，支持一键容器化交付。

2. **`tests/` (自动化测试)**
   - 基于 **pytest** 与 `httpx.TestClient` 实现的端到端 API 测试。
   - 覆盖服务存活探针、返回数据模型结构及字段语义校验。

3. **`app/` (用户客户端 - 规划中)**
   - 用户移动端/小程序/Web 端应用源码目录。
   - 规划功能：个人用药计划设定、服药提醒推送、药盒设备绑定与健康数据可视化。

4. **`firmware/` (硬件固件 - 规划中)**
   - 智能药盒硬件嵌入式微控制器程序目录。
   - 规划功能：分仓出药控制、传感器状态检测、Wi-Fi/蓝牙配网通信及声光提醒交互。

5. **工程配置与持续集成**
   - `.github/workflows/ci.yml`：自动化质量门禁，每次 PR 与 Push 均自动触发全量测试。
   - `docker-compose.yml`：标准容器化部署配置，将容器内 `8000` 端口映射至宿主机 `8011` 端口。

---

## 🚀 快速上手 (Quick Start)

### 1. 环境准备

推荐使用 Conda 管理 Python 虚拟环境：

```bash
# 创建并激活 Conda 环境
conda create -n pillbox-backend python=3.10 -y
conda activate pillbox-backend

# 安装依赖
pip install -r requirements.txt
```

### 2. 本地启动服务

在项目根目录下执行：

```bash
# 激活环境后直接启动
uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000

# 或通过 conda run 启动
conda run -n pillbox-backend uvicorn backend.main:app --reload --port 8000
```

启动后访问本地交互式文档：`http://localhost:8000/docs`

### 3. 运行自动化测试

```bash
conda run -n pillbox-backend pytest -v
```

---

## 🐳 Docker 容器化部署 (Docker Deployment)

系统提供开箱即用的 Docker 容器编排支持：

```bash
# 构建并后台启动容器
docker compose up -d --build

# 查看容器运行状态
docker compose ps

# 查看后端实时日志
docker compose logs -f backend

# 停止容器服务
docker compose down
```

---

## 🌐 API 接口与公网部署 (API & Endpoints)

### 网络拓扑与公网访问
- **公网 Base URL**：`https://ixd.sjtu.edu.cn/pillxa-demo`
- **网络拓扑**：
  $$\text{Client (HTTPS)} \longrightarrow \text{Nginx (Port 443)} \longrightarrow \text{Host (127.0.0.1:8011)} \longrightarrow \text{Docker (Port 8000)}$$

### 核心接口列表

| 请求方式 | 路径 | 功能描述 | 返回示例 |
| :--- | :--- | :--- | :--- |
| `GET` | `/health` | 服务健康检查 | `{"status": "ok"}` |
| `GET` | `/medications/today` | 获取当日用药计划列表 | `[{"id": 1, "time": "08:00", "meal": "早餐", "status": "pending"}, ...]` |

#### 验证示例
```bash
# 健康检查验证
curl -i https://ixd.sjtu.edu.cn/pillxa-demo/health

# 获取今日用药计划
curl -i https://ixd.sjtu.edu.cn/pillxa-demo/medications/today
```

---

## 📋 开发者规范与协作指南 (Development Guidelines)

关于分支管理模型（Git Flow）、提交信息格式（Conventional Commits）、CI 质量门禁以及反向代理规则，请详细参阅 [**`AGENTS.md`**](AGENTS.md)。