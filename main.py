import os
import tempfile
import uuid
from datetime import datetime
from pathlib import Path
from typing import Optional

import magic
from fastapi import FastAPI, File, HTTPException, Request, UploadFile
from fastapi.responses import FileResponse, HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from markitdown import MarkItDown

# 创建FastAPI应用
app = FastAPI(
    title="MarkItDown Web Service",
    description="一个基于Microsoft MarkItDown的文档转Markdown web服务",
    version="1.0.0"
)

# 配置静态文件和模板
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

# 创建必要的目录
os.makedirs("uploads", exist_ok=True)
os.makedirs("outputs", exist_ok=True)
os.makedirs("static", exist_ok=True)
os.makedirs("templates", exist_ok=True)

# 初始化MarkItDown
md_converter = MarkItDown()

# 支持的文件类型
SUPPORTED_EXTENSIONS = {
    ".pdf", ".pptx", ".docx", ".xlsx", ".xls", 
    ".jpg", ".jpeg", ".png", ".gif", ".bmp",
    ".wav", ".mp3", ".html", ".htm", ".csv", 
    ".json", ".xml", ".zip", ".epub", ".txt"
}

def get_file_extension(filename: str) -> str:
    """获取文件扩展名"""
    return Path(filename).suffix.lower()

def is_supported_file(filename: str) -> bool:
    """检查文件是否支持"""
    return get_file_extension(filename) in SUPPORTED_EXTENSIONS

def generate_unique_filename(original_filename: str, extension: str = ".md") -> str:
    """生成唯一的文件名"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    unique_id = str(uuid.uuid4())[:8]
    base_name = Path(original_filename).stem
    return f"{base_name}_{timestamp}_{unique_id}{extension}"

@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
    """主页"""
    return templates.TemplateResponse("index.html", {"request": request})

@app.get("/health")
async def health_check():
    """健康检查"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@app.post("/convert")
async def convert_file(file: UploadFile = File(...)):
    """
    上传文件并转换为Markdown
    """
    try:
        # 检查文件是否为空
        if not file.filename:
            raise HTTPException(status_code=400, detail="没有选择文件")
        
        # 检查文件类型是否支持
        if not is_supported_file(file.filename):
            supported_types = ", ".join(sorted(SUPPORTED_EXTENSIONS))
            raise HTTPException(
                status_code=400, 
                detail=f"不支持的文件类型。支持的类型：{supported_types}"
            )
        
        # 读取文件内容
        file_content = await file.read()
        if len(file_content) == 0:
            raise HTTPException(status_code=400, detail="文件为空")
        
        # 检查文件大小（限制为50MB）
        max_size = 50 * 1024 * 1024  # 50MB
        if len(file_content) > max_size:
            raise HTTPException(status_code=400, detail="文件大小超过50MB限制")
        
        # 创建临时文件进行转换
        with tempfile.NamedTemporaryFile(
            delete=False, 
            suffix=get_file_extension(file.filename)
        ) as temp_file:
            temp_file.write(file_content)
            temp_file_path = temp_file.name
        
        try:
            # 使用MarkItDown转换文件
            result = md_converter.convert(temp_file_path)
            
            if not result.text_content:
                raise HTTPException(status_code=500, detail="文件转换失败，无法提取内容")
            
            # 生成输出文件名
            output_filename = generate_unique_filename(file.filename)
            output_path = os.path.join("outputs", output_filename)
            
            # 保存转换结果
            with open(output_path, "w", encoding="utf-8") as f:
                f.write(result.text_content)
            
            return {
                "status": "success",
                "message": "文件转换成功",
                "original_filename": file.filename,
                "output_filename": output_filename,
                "download_url": f"/download/{output_filename}",
                "file_size": len(file_content),
                "converted_size": len(result.text_content.encode('utf-8'))
            }
            
        finally:
            # 清理临时文件
            if os.path.exists(temp_file_path):
                os.unlink(temp_file_path)
                
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"服务器内部错误: {str(e)}")

@app.get("/download/{filename}")
async def download_file(filename: str):
    """
    下载转换后的Markdown文件
    """
    import urllib.parse
    
    file_path = os.path.join("outputs", filename)
    
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="文件不存在")
    
    # 对文件名进行URL编码以处理中文字符
    encoded_filename = urllib.parse.quote(filename, safe='')
    
    # 使用RFC5987标准格式，同时提供ASCII fallback
    content_disposition = f"attachment; filename*=UTF-8''{encoded_filename}; filename=\"{filename.encode('ascii', 'ignore').decode('ascii')}\""
    
    return FileResponse(
        path=file_path,
        filename=filename,
        media_type="text/markdown",
        headers={"Content-Disposition": content_disposition}
    )

@app.get("/preview/{filename}")
async def preview_file(filename: str):
    """
    预览转换后的Markdown内容
    """
    file_path = os.path.join("outputs", filename)
    
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="文件不存在")
    
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        return {
            "filename": filename,
            "content": content,
            "size": len(content.encode('utf-8'))
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"读取文件失败: {str(e)}")

@app.get("/api/supported-formats")
async def get_supported_formats():
    """
    获取支持的文件格式列表
    """
    return {
        "supported_extensions": sorted(list(SUPPORTED_EXTENSIONS)),
        "description": "支持的文件格式包括：PDF、Office文档、图片、音频、HTML等"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True) 