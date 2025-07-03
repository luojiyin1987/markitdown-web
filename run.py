#!/usr/bin/env python3
"""
MarkItDown Web Service 启动脚本
"""

import uvicorn
import sys
import os

def main():
    """启动服务器"""
    print("🚀 正在启动 MarkItDown Web Service...")
    print("📝 基于 Microsoft MarkItDown 的文档转换服务")
    print("-" * 50)
    
    # 检查是否安装了必要的依赖
    try:
        from fastapi import FastAPI
        from markitdown import MarkItDown
    except ImportError as e:
        print(f"❌ 缺少必要依赖: {e}")
        print("💡 请运行: pip install -r requirements.txt")
        sys.exit(1)
    
    # 启动服务器
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )

if __name__ == "__main__":
    main() 