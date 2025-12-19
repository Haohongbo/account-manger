# 账号管理系统

基于 **Tauri + Spring Boot** 的账号管理系统

## 项目结构

```
account-manager/
├── backend/           # Spring Boot 后端
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/example/accountmanager/
│       │   ├── AccountManagerApplication.java
│       │   ├── entity/ZhanghaoInfo.java
│       │   ├── repository/ZhanghaoInfoRepository.java
│       │   ├── service/ZhanghaoInfoService.java
│       │   ├── controller/ZhanghaoInfoController.java
│       │   └── config/CorsConfig.java
│       └── resources/application.yml
│
└── frontend/          # Tauri 前端
    ├── package.json
    ├── vite.config.js
    ├── index.html
    ├── src/
    │   ├── styles.css
    │   └── main.js
    └── src-tauri/
        ├── tauri.conf.json
        ├── Cargo.toml
        └── src/main.rs
```

## 快速开始

### 1. 启动后端服务

```bash
cd /Users/hongbohao/.gemini/antigravity/scratch/account-manager/backend

# 确保 MySQL 服务正在运行，且数据库 lele_data 已存在

# 使用 Maven 启动
./mvnw spring-boot:run
```

后端将运行在 `http://localhost:8080`

### 2. 启动前端（开发模式）

```bash
cd /Users/hongbohao/.gemini/antigravity/scratch/account-manager/frontend

# 安装依赖
npm install

# 启动 Tauri 开发模式
npm run tauri dev
```

### 3. 构建发布版本

```bash
cd /Users/hongbohao/.gemini/antigravity/scratch/account-manager/frontend

# 构建 Tauri 应用
npm run tauri build
```

## API 接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/accounts | 获取所有未完成账号 |
| GET | /api/accounts/all | 获取所有账号（含已完成） |
| GET | /api/accounts/{id} | 获取单个账号 |
| POST | /api/accounts | 创建账号 |
| PUT | /api/accounts/{id} | 更新账号 |
| DELETE | /api/accounts/{id} | 删除账号 |
| GET | /api/accounts/search?userName=xxx | 按用户名搜索 |

## 数据库配置

- 数据库：MySQL
- 数据库名：`lele_data`
- 表名：`zhanghao_info`
- 用户名：`root`
- 密码：空

## 技术栈

- **后端**: Java 17, Spring Boot 3.2, Spring Data JPA, MySQL
- **前端**: HTML/CSS/JavaScript, Vite, Tauri v2
