---
name: Python Automation Kit
version: 1.0.0
type: map-of-content
description: Entry point for the Python Automation Kit. Read this file FIRST to navigate available skills.
---

# 🐍 Python Automation Kit — Map of Content

> **How to use**: Read this MOC first. Follow `[[wikilinks]]` to load only the skills you need. Each skill has YAML frontmatter with `triggers`, `requires`, and `related` fields.

---

## 🎯 Tier 1: Orchestrator _(Auto-loaded)_

| Skill            | Purpose                                                  | Path                                         |
| ---------------- | -------------------------------------------------------- | -------------------------------------------- |
| [[orchestrator]] | Route requests, scaffold projects, manage build pipeline | `tier-1-orchestrators/orchestrator/SKILL.md` |

---

## 📋 Tier 2: Core Hubs _(Load on demand)_

| Skill         | Purpose                                             | Path                             |
| ------------- | --------------------------------------------------- | -------------------------------- |
| [[architect]] | Design project structure, modules, dependencies     | `tier-2-hubs/architect/SKILL.md` |
| [[builder]]   | Python code patterns, best practices, typing, async | `tier-2-hubs/builder/SKILL.md`   |
| [[deployer]]  | Server deployment, Docker, systemd, CI/CD           | `tier-2-hubs/deployer/SKILL.md`  |
| [[debugger]]  | Testing, debugging, logging, profiling              | `tier-2-hubs/debugger/SKILL.md`  |

**Pipeline**: `orchestrator` → `architect` → `builder` → `debugger` → `deployer`

---

## 🛠️ Tier 3: Utilities _(Load on demand)_

| Skill                | Purpose                                        | Path                                         |
| -------------------- | ---------------------------------------------- | -------------------------------------------- |
| [[google-workspace]] | Gmail, Sheets, Drive, Calendar, Docs via API   | `tier-3-utilities/google-workspace/SKILL.md` |
| [[database]]         | SQL/NoSQL, ORM, migrations, connection pooling | `tier-3-utilities/database/SKILL.md`         |
| [[ai-models]]        | OpenAI, Gemini, LangChain, prompt engineering  | `tier-3-utilities/ai-models/SKILL.md`        |
| [[scheduler]]        | Cron, APScheduler, Celery, task queues         | `tier-3-utilities/scheduler/SKILL.md`        |
| [[api-framework]]    | FastAPI, Flask, middleware, CORS, docs         | `tier-3-utilities/api-framework/SKILL.md`    |

---

## 🏢 Tier 4: Domain Skills _(Load by project type)_

| Skill               | Domain               | Key Patterns                              | Path                                      |
| ------------------- | -------------------- | ----------------------------------------- | ----------------------------------------- |
| [[data-processing]] | Data & ETL           | Pandas, CSV/Excel, pipelines, validation  | `tier-4-domains/data-processing/SKILL.md` |
| [[web-scraping]]    | Web Scraping         | BeautifulSoup, Playwright, anti-detection | `tier-4-domains/web-scraping/SKILL.md`    |
| [[reporting]]       | Reports & Dashboards | Charts, PDF generation, email reports     | `tier-4-domains/reporting/SKILL.md`       |
| [[file-management]] | File Operations      | S3, GCS, local, zip/unzip, streaming      | `tier-4-domains/file-management/SKILL.md` |
| [[notification]]    | Notifications        | Zalo, Telegram, Slack, Email, SMS         | `tier-4-domains/notification/SKILL.md`    |
| [[auth-security]]   | Auth & Security      | OAuth2, JWT, .env, secrets management     | `tier-4-domains/auth-security/SKILL.md`   |

---

## 🔗 Pipeline Flow

```
User Request
    ↓
[orchestrator] → detects intent + domain
    ↓
[architect] → designs project structure
    ├─→ [ai-models] (if AI-powered tool)
    ├─→ [google-workspace] (if GWS integration)
    └─→ [domain-skill] (domain-specific patterns)
    ↓
[builder] → writes Python code
    ├─→ [database] (if data storage needed)
    ├─→ [api-framework] (if API/webhook needed)
    └─→ [auth-security] (if credentials needed)
    ↓
[debugger] → tests & validates
    ↓
[deployer] → deploys to server
    ├─→ [scheduler] (if cron/recurring needed)
    └─→ Docker + systemd + CI/CD
```
