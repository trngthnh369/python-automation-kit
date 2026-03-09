---
name: api-framework
tier: 3
category: utility
version: 1.0.0
description: FastAPI, Flask patterns, middleware, CORS, OpenAPI docs.
triggers:
  - "API"
  - "FastAPI"
  - "Flask"
  - "REST"
  - "webhook"
related:
  - "[[auth-security]]"
  - "[[deployer]]"
---

# 🌐 API Framework

FastAPI and Flask patterns for building APIs and webhook endpoints.

## FastAPI (Recommended)

### Basic App

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Tool API", version="1.0.0")

class TaskRequest(BaseModel):
    action: str
    params: dict = {}

class TaskResponse(BaseModel):
    status: str
    result: dict

@app.post("/run", response_model=TaskResponse)
async def run_task(request: TaskRequest):
    try:
        result = await execute_task(request.action, request.params)
        return TaskResponse(status="success", result=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health():
    return {"status": "ok"}
```

### Webhook Endpoint

```python
from fastapi import Request, BackgroundTasks

@app.post("/webhook/{source}")
async def webhook(source: str, request: Request, bg: BackgroundTasks):
    payload = await request.json()
    bg.add_task(process_webhook, source, payload)
    return {"received": True}

async def process_webhook(source: str, payload: dict):
    logger.info(f"Processing webhook from {source}")
    # Heavy processing happens in background
```

### CORS + Middleware

```python
from fastapi.middleware.cors import CORSMiddleware
import time

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.middleware("http")
async def log_requests(request: Request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    elapsed = time.perf_counter() - start
    logger.info(f"{request.method} {request.url.path} → {response.status_code} ({elapsed:.2f}s)")
    return response
```

### Run Server

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload  # dev
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4  # production
```

## Flask (Simpler Alternative)

```python
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/webhook", methods=["POST"])
def webhook():
    data = request.json
    process(data)
    return jsonify({"status": "ok"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

## API Key Authentication

```python
from fastapi import Security, HTTPException
from fastapi.security import APIKeyHeader

api_key_header = APIKeyHeader(name="X-API-Key")

async def verify_api_key(api_key: str = Security(api_key_header)):
    if api_key != Config.API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API key")
    return api_key

@app.post("/secure-endpoint")
async def secure(api_key: str = Security(verify_api_key)):
    return {"authenticated": True}
```

## Dependencies

```txt
fastapi>=0.100.0
uvicorn>=0.20.0
flask>=3.0.0       # Alternative
```
