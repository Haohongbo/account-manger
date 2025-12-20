# 账号管理系统

一个完整的账号管理解决方案，包含后端 API 服务、桌面客户端和移动客户端。

## 项目结构

```
account-manager/
├── backend/          # Spring Boot 后端 API
├── frontend/         # Tauri 桌面客户端 (Windows/macOS)
└── mobile/           # Flutter 移动客户端 (Android)
```

## 功能特性

### 核心功能
- ✅ 账号列表展示（自动过滤已完成状态）
- ✅ 添加/编辑/删除账号
- ✅ 一键复制（用户名、密码、账密组合）

### 高级搜索
- 🔍 用户名模糊搜索
- 🔍 金币范围搜索（单位：亿）
- 🔍 钻石范围搜索（单位：万）
- 🔍 VIP 等级范围搜索
- 🔍 手机尾号搜索（支持搜索空尾号）

### 系统设置
- ⚙️ 后端 API 地址配置
- ⚙️ 连接测试功能
- ⚙️ 配置本地持久化

---

## 后端 (Backend)

### 技术栈
- Java 17
- Spring Boot 3.2
- Spring Data JPA
- MySQL

### 运行方式

```bash
cd backend
./mvnw spring-boot:run
```

### 配置数据库

编辑 `backend/src/main/resources/application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/lele_data
    username: root
    password: your_password
```

### API 接口

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/accounts | 获取账号列表 |
| GET | /api/accounts/{id} | 获取单个账号 |
| POST | /api/accounts | 创建账号 |
| PUT | /api/accounts/{id} | 更新账号 |
| DELETE | /api/accounts/{id} | 删除账号 |

---

## 桌面客户端 (Frontend)

### 技术栈
- Tauri 2.0
- Vite
- 原生 HTML/CSS/JavaScript

### 开发运行

```bash
cd frontend
npm install
npm run tauri dev
```

### 构建发布

```bash
npm run tauri build
```

生成文件：
- Windows: `src-tauri/target/release/bundle/nsis/*.exe`
- macOS: `src-tauri/target/release/bundle/dmg/*.dmg`

---

## 移动客户端 (Mobile)

### 技术栈
- Flutter 3.x
- Provider (状态管理)
- Dio (HTTP 请求)
- SharedPreferences (本地存储)

### 开发运行

```bash
cd mobile
flutter pub get
flutter run
```

### 构建 APK

```bash
flutter build apk --release
```

生成文件：`build/app/outputs/flutter-apk/app-release.apk`

### 注意事项
- Android 模拟器访问本机后端：使用 `10.0.2.2:8080`
- 真机访问：使用服务器实际 IP 地址

---

## 部署说明

详见 [DEPLOY.md](./DEPLOY.md)

---

## 数据库结构

**表名**: `zhanghao_info`

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 主键 |
| userName | VARCHAR | 用户名 |
| passWord | VARCHAR | 密码 |
| jing_bi | VARCHAR | 金币 |
| zhuanshi | VARCHAR | 钻石 |
| data_time | VARCHAR | 时间 |
| status | VARCHAR | 状态 |

---

## 截图预览

### 桌面客户端
深色主题，现代化 UI 设计，支持高级搜索和一键复制功能。

### 移动客户端
Material Design 3 风格，支持下拉刷新、高级搜索和剪贴板复制。

---

## License

MIT
