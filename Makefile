# MarkItDown Web Service Makefile

.PHONY: help build up down restart logs clean dev-up dev-down test lint format

# 默认目标
help:
	@echo "MarkItDown Web Service - 可用命令:"
	@echo ""
	@echo "开发环境:"
	@echo "  dev-up      - 启动开发环境"
	@echo "  dev-down    - 停止开发环境"
	@echo "  dev-logs    - 查看开发环境日志"
	@echo "  dev-shell   - 进入开发容器shell"
	@echo ""
	@echo "生产环境:"
	@echo "  build       - 构建Docker镜像"
	@echo "  up          - 启动生产环境"
	@echo "  down        - 停止生产环境"
	@echo "  restart     - 重启生产环境"
	@echo "  logs        - 查看生产环境日志"
	@echo ""
	@echo "带Nginx反向代理:"
	@echo "  up-nginx    - 启动带Nginx的生产环境"
	@echo "  down-nginx  - 停止带Nginx的生产环境"
	@echo ""
	@echo "维护:"
	@echo "  clean       - 清理容器和镜像"
	@echo "  clean-all   - 清理所有相关资源"
	@echo "  test        - 运行测试"
	@echo "  lint        - 代码检查"
	@echo "  format      - 代码格式化"

# 开发环境命令
dev-up:
	@echo "🚀 启动开发环境..."
	docker-compose -f docker-compose.dev.yml up -d
	@echo "✅ 开发环境已启动: http://localhost:8000"

dev-down:
	@echo "🛑 停止开发环境..."
	docker-compose -f docker-compose.dev.yml down

dev-logs:
	@echo "📋 查看开发环境日志..."
	docker-compose -f docker-compose.dev.yml logs -f

dev-shell:
	@echo "🐚 进入开发容器shell..."
	docker-compose -f docker-compose.dev.yml exec markitdown-web-dev bash

dev-restart:
	@echo "🔄 重启开发环境..."
	docker-compose -f docker-compose.dev.yml restart

# 生产环境命令
build:
	@echo "🔨 构建Docker镜像..."
	docker-compose build --no-cache

up:
	@echo "🚀 启动生产环境..."
	docker-compose up -d
	@echo "✅ 生产环境已启动: http://localhost:8000"

down:
	@echo "🛑 停止生产环境..."
	docker-compose down

restart:
	@echo "🔄 重启生产环境..."
	docker-compose restart

logs:
	@echo "📋 查看生产环境日志..."
	docker-compose logs -f

# Nginx环境命令
up-nginx:
	@echo "🚀 启动带Nginx的生产环境..."
	docker-compose --profile with-nginx up -d
	@echo "✅ 环境已启动:"
	@echo "   应用: http://localhost:8000"
	@echo "   Nginx: http://localhost:80"

down-nginx:
	@echo "🛑 停止带Nginx的生产环境..."
	docker-compose --profile with-nginx down

# 完整环境（包含Redis）
up-full:
	@echo "🚀 启动完整生产环境..."
	docker-compose --profile with-nginx --profile with-redis up -d
	@echo "✅ 完整环境已启动"

down-full:
	@echo "🛑 停止完整生产环境..."
	docker-compose --profile with-nginx --profile with-redis down

# 测试命令
test:
	@echo "🧪 运行测试..."
	docker-compose -f docker-compose.dev.yml exec markitdown-web-dev pytest

test-coverage:
	@echo "🧪 运行测试并生成覆盖率报告..."
	docker-compose -f docker-compose.dev.yml exec markitdown-web-dev pytest --cov=. --cov-report=html

# 代码质量
lint:
	@echo "🔍 运行代码检查..."
	docker-compose -f docker-compose.dev.yml exec markitdown-web-dev flake8 .
	docker-compose -f docker-compose.dev.yml exec markitdown-web-dev mypy .

format:
	@echo "✨ 格式化代码..."
	docker-compose -f docker-compose.dev.yml exec markitdown-web-dev black .
	docker-compose -f docker-compose.dev.yml exec markitdown-web-dev isort .

# 清理命令
clean:
	@echo "🧹 清理停止的容器..."
	docker container prune -f
	docker image prune -f

clean-all:
	@echo "🧹 清理所有相关资源..."
	docker-compose down -v --rmi all
	docker-compose -f docker-compose.dev.yml down -v --rmi all
	docker system prune -af --volumes

# 备份和恢复
backup:
	@echo "💾 备份数据..."
	mkdir -p backup
	docker-compose exec markitdown-web tar -czf /tmp/backup.tar.gz /app/uploads /app/outputs
	docker cp $$(docker-compose ps -q markitdown-web):/tmp/backup.tar.gz backup/markitdown-backup-$$(date +%Y%m%d-%H%M%S).tar.gz
	@echo "✅ 备份完成"

# 监控
stats:
	@echo "📊 容器状态统计..."
	docker-compose ps
	docker stats --no-stream

health:
	@echo "❤️ 健康检查..."
	curl -f http://localhost:8000/health || echo "❌ 服务不健康"

# 环境设置
setup:
	@echo "⚙️ 设置环境..."
	cp env.example .env
	mkdir -p uploads outputs logs ssl
	@echo "✅ 环境设置完成，请编辑 .env 文件"

# 快速启动命令
quick-start: setup build up
	@echo "🎉 快速启动完成！访问 http://localhost:8000"

# SSL证书生成（自签名，仅用于开发）
ssl-cert:
	@echo "🔐 生成自签名SSL证书..."
	mkdir -p ssl
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout ssl/key.pem \
		-out ssl/cert.pem \
		-subj "/C=CN/ST=Beijing/L=Beijing/O=MarkItDown/CN=localhost"
	@echo "✅ SSL证书已生成" 