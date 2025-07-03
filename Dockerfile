# 多阶段构建 - 基础镜像
FROM python:3.11-slim as base

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    libmagic1 \
    libmagic-dev \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt

# 开发环境阶段
FROM base as development

# 安装开发依赖
RUN pip install --no-cache-dir pytest pytest-asyncio httpx

# 复制应用代码（开发时会通过卷挂载覆盖）
COPY . .

# 创建必要的目录
RUN mkdir -p uploads outputs static templates logs

# 设置权限
RUN chmod +x run.py

# 暴露端口
EXPOSE 8000

# 开发环境启动命令
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# 生产环境阶段
FROM base as production

# 复制应用代码
COPY . .

# 创建必要的目录
RUN mkdir -p uploads outputs static templates logs

# 设置权限
RUN chmod +x run.py

# 创建非root用户
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 appuser

# 设置目录权限
RUN chown -R appuser:appgroup /app

# 切换到非root用户
USER appuser

# 暴露端口
EXPOSE 8000

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# 启动应用
CMD ["python", "main.py"] 