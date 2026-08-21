# Pillxa Flutter App (智能药盒客户端)

Pillxa 智能药盒系统的移动端 / 客户端 Flutter 应用程序。

---

## 🎯 当前功能特性

1. **服务健康检测 (`GET /health`)**：
   - 实时探测后端云服务存活性；
   - 展示连接状态（🟢 正常 / 🔴 异常）及响应延迟（毫秒）；
   - 支持一键刷新探测。
2. **今日用药计划展示 (`GET /medications/today`)**：
   - 动态拉取今日用药计划列表（早餐、午餐、晚餐、睡前）；
   - 卡片化展示各时段服药状态（已服用 / 待服药）。
3. **多环境灵活切换**：
   - 默认连接公网部署环境：`https://ixd.sjtu.edu.cn/pillxa-demo`；
   - 点击右上角设置图标可切换至本地调试环境（如 `http://localhost:8000` 或 Android 模拟器 `http://10.0.2.2:8000`）。

---

## 📁 目录结构

```text
app/
├── lib/
│   ├── main.dart                  # 应用入口与全局主题配置
│   ├── models/                    # 数据解析模型 (HealthStatus, MedicationPlanItem)
│   ├── services/                  # 网络服务层 (ApiService http 客户端封装)
│   └── screens/                   # 界面组件 (HomeScreen 状态与用药卡片)
├── test/                          # 单元测试与 Widget 测试 (model_test.dart)
├── pubspec.yaml                   # Flutter 项目与依赖定义
└── README.md                      # 客户端使用与调试说明
```

---

## 🚀 运行与调试指南

### 1. 安装依赖

进入 `app` 目录并拉取 Flutter 依赖包：

```bash
cd app
flutter pub get
```

### 2. 启动应用

- **运行在已连接的手机 / 模拟器 (Android / iOS)**：
  ```bash
  flutter run
  ```
- **运行在 Chrome 浏览器 (Web 预览)**：
  ```bash
  flutter run -d chrome
  ```

### 3. 运行自动化测试

```bash
flutter test
```
