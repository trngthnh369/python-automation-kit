# Python Automation Kit 🐍

**4-tier skill kit for AI agents to build Python automation tools.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.10+-blue.svg)](https://python.org)

Build, deploy, and maintain Python automation scripts **autonomously** with AI agents. Covers Google Workspace, AI models, data processing, web scraping, and server deployment.

## ✨ Features

- **4-Tier Skill Graph**: Orchestrator → Hubs → Utilities → Domains
- **16 Skills**: Covering the full automation lifecycle
- **Google Workspace**: Gmail, Sheets, Drive, Calendar, Docs
- **AI Integration**: OpenAI, Gemini, LangChain, RAG patterns
- **Production Deploy**: Docker, systemd, CI/CD, cron scheduling
- **Agent-Agnostic**: Antigravity, Claude Code, Gemini CLI, Cursor

## 📦 Quick Install

```bash
# npm
npm install python-automation-kit

# git
git clone https://github.com/trngthnh369/python-automation-kit.git

# manual
# Copy to .agents/skills/python-automation-kit/
```

## 🏗️ Architecture

```
_moc.md (Entry Point)
│
├── Tier 1: Orchestrator (auto-loaded)
│   └── Routes requests, scaffolds projects
│
├── Tier 2: Core Hubs
│   ├── Architect — project design
│   ├── Builder — Python code patterns
│   ├── Debugger — testing & logging
│   └── Deployer — server & Docker
│
├── Tier 3: Utilities
│   ├── Google Workspace — Gmail/Sheets/Drive/Calendar
│   ├── Database — SQL/NoSQL/ORM
│   ├── AI Models — OpenAI/Gemini/LangChain
│   ├── Scheduler — Cron/Celery/APScheduler
│   └── API Framework — FastAPI/Flask
│
└── Tier 4: Domains
    ├── Data Processing — Pandas/ETL
    ├── Web Scraping — BS4/Playwright
    ├── Reporting — Charts/PDF
    ├── File Management — S3/GCS
    ├── Notification — Zalo/Telegram/Slack
    └── Auth & Security — OAuth/JWT/.env
```

## 🎯 Usage

Tell your AI agent what you need:

- _"Build a Python script that reads Google Sheets and sends daily email reports"_
- _"Create a FastAPI service with Gemini AI that processes uploaded CSV files"_
- _"Deploy a Telegram bot that monitors inventory and sends alerts"_

## 📝 License

MIT License
