# 宝塔服务器部署指南

## 1. 准备工作

### 生成的 JAR 文件位置
```
/Users/hongbohao/.gemini/antigravity/scratch/account-manager/backend/target/account-manager-1.0.0.jar
```

### 服务器要求
- Java 17 或更高版本
- MySQL 数据库
- 开放 8080 端口（或您配置的端口）

---

## 2. 上传 JAR 文件

将 `account-manager-1.0.0.jar` 上传到宝塔服务器，建议路径：
```
/www/wwwroot/account-manager/
```

---

## 3. 宝塔面板配置

### 方法一：使用宝塔 Java 项目管理器

1. 在宝塔面板中，进入 **软件商店**
2. 搜索并安装 **Java项目管理器**
3. 打开 Java 项目管理器
4. 点击 **添加Java项目**
5. 填写配置：
   - 项目名称：`account-manager`
   - 项目路径：`/www/wwwroot/account-manager`
   - JAR路径：`/www/wwwroot/account-manager/account-manager-1.0.0.jar`
   - 项目端口：`8080`
   - JDK版本：`17`

### 方法二：手动运行（使用 Supervisor）

1. 安装 Supervisor
   ```bash
   yum install supervisor -y  # CentOS
   apt install supervisor -y  # Ubuntu
   ```

2. 创建配置文件 `/etc/supervisord.d/account-manager.ini`
   ```ini
   [program:account-manager]
   command=/usr/bin/java -jar /www/wwwroot/account-manager/account-manager-1.0.0.jar
   directory=/www/wwwroot/account-manager
   autostart=true
   autorestart=true
   stderr_logfile=/www/wwwroot/account-manager/logs/err.log
   stdout_logfile=/www/wwwroot/account-manager/logs/out.log
   user=root
   ```

3. 创建日志目录并启动
   ```bash
   mkdir -p /www/wwwroot/account-manager/logs
   supervisorctl reread
   supervisorctl update
   supervisorctl start account-manager
   ```

---

## 4. 修改数据库配置

### 方法一：修改 JAR 包内配置
解压 JAR，修改 `BOOT-INF/classes/application.yml`，然后重新打包

### 方法二：使用外部配置文件（推荐）
在 JAR 同目录创建 `application.yml`：

```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://你的数据库地址:3306/lele_data?useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
    username: 你的数据库用户名
    password: 你的数据库密码
    driver-class-name: com.mysql.cj.jdbc.Driver
  
  jpa:
    hibernate:
      ddl-auto: none
      naming:
        physical-strategy: org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
    show-sql: false
```

---

## 5. 开放防火墙端口

在宝塔面板 **安全** 中，放行 8080 端口

---

## 6. 验证部署

访问：`http://你的服务器IP:8080/api/accounts`

如果返回 JSON 数据，说明部署成功！

---

## 7. 配置 Nginx 反向代理（可选）

如果要使用域名访问，在宝塔面板添加网站后，配置反向代理：

```nginx
location /api {
    proxy_pass http://127.0.0.1:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

---

## 常用命令

```bash
# 查看运行状态
supervisorctl status account-manager

# 重启服务
supervisorctl restart account-manager

# 查看日志
tail -f /www/wwwroot/account-manager/logs/out.log
```
