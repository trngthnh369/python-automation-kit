---
name: architect
tier: 2
category: hub
version: 1.0.0
description: Designs project structure, modules, dependencies, and data flow.
triggers:
  - "design project"
  - "architecture"
  - "module plan"
  - "project structure"
requires:
  - orchestrator
related:
  - "[[builder]]"
  - "[[database]]"
---

# 📋 Architect

Designs project structure, dependency graph, and data flow for Python automation tools.

## Decision Matrix

| Criteria     | Simple Script | Module Package | Full Service     |
| ------------ | ------------- | -------------- | ---------------- |
| Files        | 1–2           | 3–10           | 10+              |
| Dependencies | ≤5            | 5–15           | 15+              |
| Scheduling   | cron external | APScheduler    | Celery / builtin |
| API needed   | No            | Optional       | Yes (FastAPI)    |
| Docker       | No            | Optional       | Yes              |
| Team size    | Solo          | 1–2            | 2+               |

## Dependency Management

### requirements.txt Template

```txt
# Core
python-dotenv>=1.0.0

# Google Workspace (if needed)
google-auth>=2.0.0
google-api-python-client>=2.0.0
gspread>=5.0.0

# AI (if needed)
openai>=1.0.0
langchain>=0.1.0

# Data (if needed)
pandas>=2.0.0
openpyxl>=3.0.0

# API (if needed)
fastapi>=0.100.0
uvicorn>=0.20.0

# Scheduling (if needed)
apscheduler>=3.10.0
```

### pyproject.toml (Modern)

```toml
[project]
name = "tool-name"
version = "1.0.0"
requires-python = ">=3.10"
dependencies = ["python-dotenv>=1.0.0"]

[project.optional-dependencies]
dev = ["pytest>=7.0", "ruff>=0.1.0", "mypy>=1.0"]
```

## Config Pattern (Standard)

```python
# config.py
import os
from dotenv import load_dotenv
from pathlib import Path

load_dotenv()

class Config:
    # General
    DEBUG = os.getenv("DEBUG", "false").lower() == "true"
    TIMEZONE = os.getenv("TZ", "Asia/Ho_Chi_Minh")

    # Google
    GOOGLE_CREDENTIALS_FILE = os.getenv("GOOGLE_CREDENTIALS_FILE", "credentials.json")
    SPREADSHEET_ID = os.getenv("SPREADSHEET_ID", "")

    # AI
    OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
    OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o")

    # Database
    DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///data.db")

    @classmethod
    def validate(cls) -> list[str]:
        errors = []
        if not cls.SPREADSHEET_ID:
            errors.append("SPREADSHEET_ID is required")
        return errors
```

## Logging Standard

```python
# utils/logger.py
import logging
import sys

def setup_logger(name: str, level: str = "INFO") -> logging.Logger:
    logger = logging.getLogger(name)
    logger.setLevel(getattr(logging, level))

    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(logging.Formatter(
        "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    ))
    logger.addHandler(handler)
    return logger
```

## Module Naming Conventions

| Module      | Purpose                 | Example                 |
| ----------- | ----------------------- | ----------------------- |
| `main.py`   | Entry point             | `python main.py`        |
| `config.py` | Environment + settings  | `Config.SPREADSHEET_ID` |
| `services/` | Business logic          | `services/sheets.py`    |
| `models/`   | Data models (Pydantic)  | `models/report.py`      |
| `utils/`    | Shared utilities        | `utils/logger.py`       |
| `routes/`   | API endpoints (FastAPI) | `routes/webhook.py`     |
