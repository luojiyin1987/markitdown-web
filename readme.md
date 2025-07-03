# MarkItDown Web Service

一个基于 [Microsoft MarkItDown](https://github.com/microsoft/markitdown) 的现代化 Web 文档转换服务，支持将多种文档格式转换为 Markdown。

## ✨ 特性

- 🚀 **快速转换**: 基于微软 MarkItDown 引擎，支持多种文档格式
- 🎨 **现代化 UI**: 响应式设计，支持拖拽上传
- 📱 **移动友好**: 完美适配各种设备尺寸
- 🔒 **安全可靠**: 文件处理后自动清理，保护隐私
- 🐳 **容器化**: 支持 Docker 和 Docker Compose 部署
- 📖 **预览功能**: 转换后可直接预览 Markdown 内容
- 🛠️ **开发友好**: 支持多种虚拟环境工具（venv、conda、uv）

## 📋 支持的格式

- **Office 文档**: PDF, DOCX, PPTX, XLSX, XLS
- **图像文件**: JPG, JPEG, PNG, GIF, BMP
- **音频文件**: WAV, MP3
- **网页文件**: HTML, HTM
- **数据文件**: CSV, JSON, XML
- **压缩文件**: ZIP
- **电子书**: EPUB
- **文本文件**: TXT

## 🚀 快速开始

### 方式一：直接运行

1. **克隆仓库**
```bash
git clone <repository-url>
cd markitdown-web
```

2. **创建并激活虚拟环境**

   **使用 Python 内置 venv（推荐）：**
   ```bash
   # 创建虚拟环境
   python3 -m venv venv
   
   # 激活虚拟环境
   # Linux/Mac:
   source venv/bin/activate
   
   # Windows:
   venv\Scripts\activate
   
   # Windows PowerShell:
   venv\Scripts\Activate.ps1
   ```

   **使用 conda：**
   ```bash
   # 创建虚拟环境
   conda create -n markitdown-web python=3.11
   
   # 激活虚拟环境
   conda activate markitdown-web
   ```

   **使用 uv（现代化工具）：**
   ```bash
   # 创建虚拟环境
   uv venv --python=3.11 venv
   
   # 激活虚拟环境
   source venv/bin/activate  # Linux/Mac
   venv\Scripts\activate     # Windows
   ```

3. **安装依赖**
```bash
# 确保虚拟环境已激活（命令行前应显示 (venv) 或 (markitdown-web)）
pip install -r requirements.txt

# 如果使用 uv：
# uv pip install -r requirements.txt
```

4. **启动服务**
```bash
python run.py
```

5. **访问服务**
打开浏览器访问: http://localhost:8000

6. **退出虚拟环境**
```bash
deactivate
```

### 方式二：Docker Compose 部署（推荐）

1. **快速启动**
```bash
# 设置环境并启动
make setup
make quick-start

# 或者手动步骤
cp env.example .env
docker-compose up -d
```

2. **访问服务**
打开浏览器访问: http://localhost:8000

3. **查看日志**
```bash
make logs
# 或
docker-compose logs -f
```

### 方式三：Docker 部署

1. **构建镜像**
```bash
docker build -t markitdown-web .
```

2. **运行容器**
```bash
docker run -d -p 8000:8000 --name markitdown-web markitdown-web
```

3. **访问服务**
打开浏览器访问: http://localhost:8000

## 🐳 Docker Compose 详细使用

### 可用的部署配置

1. **基础配置**：仅包含 Web 服务
```bash
docker-compose up -d
```

2. **带 Nginx 反向代理**：适合生产环境
```bash
make up-nginx
# 或
docker-compose --profile with-nginx up -d
```

3. **完整配置**：包含 Nginx + Redis
```bash
make up-full
# 或
docker-compose --profile with-nginx --profile with-redis up -d
```

4. **开发环境**：支持热重载
```bash
make dev-up
# 或
docker-compose -f docker-compose.dev.yml up -d
```

### Makefile 快捷命令

```bash
# 查看所有可用命令
make help

# 开发环境
make dev-up        # 启动开发环境
make dev-logs      # 查看开发日志
make dev-shell     # 进入开发容器

# 生产环境
make up            # 启动生产环境
make down          # 停止服务
make logs          # 查看日志
make restart       # 重启服务

# 维护命令
make clean         # 清理容器
make backup        # 备份数据
make health        # 健康检查
```

## 🔧 API 文档

启动服务后，可以访问以下地址查看自动生成的 API 文档：

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### 主要 API 端点

| 端点 | 方法 | 描述 |
|------|------|------|
| `/` | GET | 主页面 |
| `/convert` | POST | 上传并转换文件 |
| `/download/{filename}` | GET | 下载转换后的文件 |
| `/preview/{filename}` | GET | 预览转换后的内容 |
| `/health` | GET | 健康检查 |
| `/api/supported-formats` | GET | 获取支持的格式列表 |

## 📖 使用说明

### Web 界面使用

1. 打开 http://localhost:8000
2. 点击上传区域或拖拽文件到页面
3. 选择要转换的文档文件
4. 点击"开始转换"按钮
5. 等待转换完成
6. 下载 Markdown 文件或预览内容

### API 使用示例

```python
import requests

# 上传并转换文件
with open('document.pdf', 'rb') as f:
    response = requests.post(
        'http://localhost:8000/convert',
        files={'file': f}
    )
    
result = response.json()
print(f"转换成功: {result['download_url']}")

# 下载转换后的文件
download_response = requests.get(
    f"http://localhost:8000{result['download_url']}"
)
with open('converted.md', 'wb') as f:
    f.write(download_response.content)
```

## ⚙️ 配置选项

### 环境变量

| 变量名 | 默认值 | 描述 |
|--------|--------|------|
| `HOST` | 0.0.0.0 | 服务监听地址 |
| `PORT` | 8000 | 服务监听端口 |
| `MAX_FILE_SIZE` | 50MB | 最大文件大小限制 |

### 修改配置

编辑 `main.py` 文件中的配置常量：

```python
# 最大文件大小（字节）
MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB

# 支持的文件扩展名
SUPPORTED_EXTENSIONS = {
    ".pdf", ".pptx", ".docx", ".xlsx", ".xls",
    # ... 更多格式
}
```

## 🛠️ 开发环境设置

### 本地开发环境

1. **创建虚拟环境**

   **使用 Python venv：**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # Linux/Mac
   venv\Scripts\activate     # Windows
   ```

   **使用 conda：**
   ```bash
   conda create -n markitdown-web-dev python=3.11
   conda activate markitdown-web-dev
   ```

   **使用 uv：**
   ```bash
   uv venv --python=3.11 venv
   source venv/bin/activate  # Linux/Mac
   venv\Scripts\activate     # Windows
   ```

2. **安装开发依赖**
   ```bash
   # 基础依赖
   pip install -r requirements.txt
   
   # 开发工具（可选）
   pip install pytest pytest-asyncio httpx black isort flake8 mypy
   
   # 如果使用 uv：
   # uv pip install -r requirements.txt
   # uv pip install pytest pytest-asyncio httpx black isort flake8 mypy
   ```

3. **环境配置**
   ```bash
   # 复制环境变量配置
   cp env.example .env
   
   # 编辑配置文件（可选）
   # nano .env
   ```

4. **运行开发服务器**
   ```bash
   # 方式 1：使用启动脚本
   python run.py
   
   # 方式 2：直接使用 uvicorn
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   
   # 方式 3：使用环境变量
   DEBUG=true RELOAD=true python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

### Docker 开发环境

如果您更喜欢使用 Docker 进行开发：

```bash
# 启动开发环境
make dev-up

# 查看日志
make dev-logs

# 进入容器进行调试
make dev-shell

# 停止开发环境
make dev-down
```

### 开发工具使用

**代码格式化：**
```bash
# 使用 black 格式化代码
black .

# 使用 isort 整理导入
isort .
```

**代码检查：**
```bash
# 使用 flake8 检查代码风格
flake8 .

# 使用 mypy 进行类型检查
mypy .
```

**运行测试：**
```bash
# 运行所有测试
pytest

# 运行测试并生成覆盖率报告
pytest --cov=. --cov-report=html
```

## 📁 项目结构

```
markitdown-web/
├── main.py                 # FastAPI 主应用
├── run.py                  # 启动脚本
├── requirements.txt        # Python 依赖
├── Dockerfile              # Docker 配置
├── docker-compose.yml      # 生产环境 Docker Compose
├── docker-compose.dev.yml  # 开发环境 Docker Compose
├── nginx.conf              # Nginx 反向代理配置
├── Makefile               # 便捷操作命令
├── env.example            # 环境变量示例
├── .gitignore             # Git 忽略文件
├── readme.md              # 项目文档
├── templates/             # HTML 模板
│   └── index.html         # 主页模板
├── static/                # 静态文件
│   └── style.css          # 自定义样式
├── uploads/               # 上传文件目录（自动创建）
├── outputs/               # 转换结果目录（自动创建）
├── logs/                  # 日志目录（自动创建）
└── ssl/                   # SSL 证书目录（可选）
```

## 🔍 故障排除

### 常见问题

1. **虚拟环境相关问题**
   
   **问题：虚拟环境创建失败**
   ```bash
   # 确保 Python 版本正确
   python3 --version  # 应该是 3.10+
   
   # 如果提示 venv 模块不存在（Ubuntu/Debian）
   sudo apt install python3-venv
   
   # macOS 使用 Homebrew
   brew install python@3.11
   ```

   **问题：虚拟环境未激活**
   ```bash
   # 检查是否已激活（命令行前应有 (venv) 标识）
   which python  # 应该指向虚拟环境中的 python
   
   # 重新激活
   source venv/bin/activate  # Linux/Mac
   venv\Scripts\activate     # Windows
   ```

   **问题：包安装到全局环境**
   ```bash
   # 确认虚拟环境已激活
   pip list  # 检查已安装的包
   
   # 如果不小心安装到全局，清理虚拟环境重新开始
   deactivate
   rm -rf venv
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

2. **依赖安装失败**
   - 确保使用 Python 3.10+ 版本
   - 在某些系统上可能需要安装 `python-magic` 的系统依赖
   
   **Linux (Ubuntu/Debian):**
   ```bash
   sudo apt update
   sudo apt install python3-dev libmagic1 libmagic-dev
   ```
   
   **macOS:**
   ```bash
   brew install libmagic
   ```
   
   **Windows:**
   ```bash
   # 可能需要安装 Microsoft C++ Build Tools
   # 或使用预编译的轮子包
   pip install python-magic-bin
   ```

3. **文件转换失败**
   - 检查文件格式是否在支持列表中
   - 确认文件没有损坏
   - 查看服务器日志获取详细错误信息
   - 检查文件大小是否超过限制（默认 50MB）

4. **端口被占用**
   ```bash
   # 查找占用端口的进程
   lsof -i :8000          # Linux/Mac
   netstat -ano | findstr 8000  # Windows
   
   # 杀死占用端口的进程
   kill -9 <PID>          # Linux/Mac
   taskkill /PID <PID> /F # Windows
   
   # 或修改端口
   uvicorn main:app --port 8001
   ```

5. **Docker 相关问题**
   
   **问题：Docker 构建失败**
   ```bash
   # 清理 Docker 缓存
   docker system prune -a
   
   # 重新构建
   docker-compose build --no-cache
   ```
   
   **问题：容器启动失败**
   ```bash
   # 查看详细日志
   docker-compose logs -f
   
   # 检查容器状态
   docker-compose ps
   
   # 进入容器调试
   docker-compose exec markitdown-web bash
   ```

6. **权限问题**
   ```bash
   # Linux/Mac 下可能需要调整文件权限
   chmod +x run.py
   
   # Docker 卷挂载权限问题
   sudo chown -R $USER:$USER uploads outputs logs
   ```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目基于 MIT 许可证开源 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- [Microsoft MarkItDown](https://github.com/microsoft/markitdown) - 核心转换引擎
- [FastAPI](https://fastapi.tiangolo.com/) - 现代化 Web 框架
- [Bootstrap](https://getbootstrap.com/) - UI 组件库

## 📞 支持

如果您遇到问题或有任何建议，请：

1. 查看 [Issues](../../issues) 页面
2. 创建新的 Issue
3. 联系维护者

---

**基于 Microsoft MarkItDown 技术构建 | 使用 FastAPI 和 Bootstrap 开发**
