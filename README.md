# Pillxa - 智能药盒APP

![Python](https://img.shields.io/badge/Python-3.10-blue.svg)
![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-green.svg)
![Docker](https://img.shields.io/badge/Docker-Supported-blue.svg)
![CI](https://img.shields.io/badge/CI-GitHub%20Actions-brightgreen.svg)

**Pillxa** 是一套面向日常健康管理与精准用药场景的智能药盒系统。系统整合了**硬件端（Firmware）**、**用户客户端（App）** 与 **云端服务（Backend）**，通过定时提醒、用药计划分发以及状态同步，帮助用户建立规律、科学的服药习惯。

---

## 🏗️ 目录结构 (Project Structure)

```text
Pillxa/
├── backend/            # 后端服务（FastAPI 业务逻辑、依赖清单与 Docker 配置）
├── app/                # 用户客户端（移动端 / 前端应用，规划中）
├── firmware/           # 硬件固件（智能药盒嵌入式控制程序，规划中）
├── tests/              # 自动化测试套件
├── docker-compose.yml  # Docker 容器编排配置
├── AGENTS.md           # 开发者与 Agent 协作规范
└── README.md           # 项目主说明文档
```

### 主要模块说明

- **`backend/`**：基于 FastAPI 的后端服务，负责用药计划数据分发、设备状态同步与服务健康监测；管理后端专属依赖（`backend/requirements.txt`）。
- **`app/`**：用户客户端，提供用药计划管理、服药提醒推送与药盒设备绑定交互。
- **`firmware/`**：智能药盒硬件固件，负责出药控制、传感器数据采集与声光提醒。
- **`tests/`**：后端接口自动化测试，保障服务稳定与数据模型一致。

---

## 🚀 快速上手 (Quick Start)

### 1. 环境准备

推荐使用 Conda 管理 Python 虚拟环境：

```bash
# 创建并激活 Conda 环境
conda create -n pillbox-backend python=3.10 -y
conda activate pillbox-backend

# 安装后端依赖
pip install -r backend/requirements.txt
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