---
name: python-orchestrator
tier: 1
category: orchestrator
version: 1.0.0
description: Routes requests, scaffolds projects, manages build-test-deploy pipeline.
auto_load: true
triggers:
  - "build tool"
  - "create script"
  - "automate"
  - "python tool"
  - "tạo tool"
related:
  - "[[architect]]"
  - "[[builder]]"
  - "[[debugger]]"
  - "[[deployer]]"
---

# 🎯 Python Orchestrator

Routes every request to the correct skill and manages the full lifecycle pipeline.

## Intent Detection & Routing

| Intent                 | Route                                                             | Example                                 |
| ---------------------- | ----------------------------------------------------------------- | --------------------------------------- |
| "Build/Create tool..." | `[[architect]]` → `[[builder]]` → `[[debugger]]` → `[[deployer]]` | "Build a daily report tool"             |
| "Fix/Debug script..."  | `[[debugger]]`                                                    | "Fix the CSV import error"              |
| "Deploy to server..."  | `[[deployer]]`                                                    | "Deploy tool to production VPS"         |
| "Add AI to..."         | `[[ai-models]]` → `[[builder]]`                                   | "Add GPT summarization to the pipeline" |

### Domain Detection

| Keywords                                            | Load Skill             |
| --------------------------------------------------- | ---------------------- |
| "gmail", "sheets", "drive", "calendar", "google"    | `[[google-workspace]]` |
| "database", "SQL", "MySQL", "Postgres", "MongoDB"   | `[[database]]`         |
| "AI", "GPT", "Gemini", "LLM", "prompt", "LangChain" | `[[ai-models]]`        |
| "cron", "schedule", "periodic", "celery"            | `[[scheduler]]`        |
| "API", "FastAPI", "Flask", "REST", "webhook"        | `[[api-framework]]`    |
| "pandas", "CSV", "Excel", "ETL", "data"             | `[[data-processing]]`  |
| "scrape", "crawl", "selenium", "playwright"         | `[[web-scraping]]`     |
| "report", "chart", "PDF", "dashboard"               | `[[reporting]]`        |
| "file", "upload", "S3", "GCS", "storage"            | `[[file-management]]`  |
| "notify", "Zalo", "Telegram", "Slack", "alert"      | `[[notification]]`     |
| "auth", "OAuth", "JWT", "token", ".env"             | `[[auth-security]]`    |

---

## Project Scaffolding Pipeline

```
PHASE 1: INTAKE
├── Parse user request
├── Detect intent + domain
├── Load relevant domain skill
└── Determine project complexity (simple script vs full service)

PHASE 2: DESIGN
├── Load [[architect]]
├── Choose project structure:
│   ├── Simple: single file script
│   ├── Module: package with __init__.py
│   └── Service: FastAPI/Flask with Docker
├── Define dependencies (requirements.txt / pyproject.toml)
├── Design data flow + error handling
└── Output: Architecture Blueprint

PHASE 3: BUILD
├── Load [[builder]]
├── Write code with typing, docstrings, logging
├── Apply domain patterns from loaded skills
├── Create configuration (.env, config.py)
└── Output: Working Python code

PHASE 4: TEST
├── Load [[debugger]]
├── Write tests (pytest)
├── Run linting (ruff / mypy)
├── Execute dry-run
└── Output: Test results

PHASE 5: DEPLOY
├── Load [[deployer]]
├── Create Dockerfile (if service)
├── Create systemd unit (if daemon)
├── Set up cron (if scheduled)
├── Deploy to server via SSH
└── Output: Deployed tool + verification
```

## Project Templates

### Simple Script

```
tool_name.py
.env
requirements.txt
```

### Module Package

```
tool_name/
├── __init__.py
├── main.py
├── config.py
├── services/
│   ├── __init__.py
│   └── ...
├── utils/
│   └── ...
├── .env
├── requirements.txt
└── README.md
```

### Full Service

```
tool_name/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── routes/
│   ├── services/
│   └── models/
├── tests/
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── requirements.txt
└── README.md
```

## Rules

### DO

- Always detect domain before routing
- Always create `.env.example` with required variables
- Always add type hints and docstrings
- Always include `requirements.txt`
- Follow the pipeline order: Design → Build → Test → Deploy

### DON'T

- Don't skip the architect phase for multi-file projects
- Don't hardcode credentials — always use `.env`
- Don't deploy without tests passing
- Don't use `print()` in production — use `logging`
