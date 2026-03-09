---
name: deployer
tier: 2
category: hub
version: 1.0.0
description: Server deployment — Docker, systemd, CI/CD, SSH deploy.
triggers:
  - "deploy"
  - "server"
  - "docker"
  - "production"
requires:
  - debugger
related:
  - "[[scheduler]]"
---

# 🚀 Deployer

Production deployment patterns for Python automation tools.

## Deployment Options

| Method             | Use Case                         | Complexity |
| ------------------ | -------------------------------- | ---------- |
| **SSH + venv**     | Simple scripts on VPS            | Low        |
| **Docker**         | Services, APIs, isolated env     | Medium     |
| **Docker Compose** | Multi-service (app + db + cache) | Medium     |
| **systemd**        | Long-running daemon              | Low        |
| **cron + SSH**     | Scheduled scripts                | Low        |

## SSH Deploy Script

```bash
#!/bin/bash
set -e

SERVER="user@your-server.com"
REMOTE_DIR="/opt/tools/tool-name"

echo "📦 Deploying to $SERVER..."
rsync -avz --exclude='.venv' --exclude='__pycache__' \
  ./ $SERVER:$REMOTE_DIR/

ssh $SERVER << 'EOF'
  cd /opt/tools/tool-name
  python3 -m venv .venv 2>/dev/null || true
  source .venv/bin/activate
  pip install -r requirements.txt --quiet
  echo "✅ Deploy complete"
EOF
```

## Dockerfile (Standard)

```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Dependencies first (cache layer)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Application code
COPY . .

# Non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

ENV TZ=Asia/Ho_Chi_Minh
ENV PYTHONUNBUFFERED=1

CMD ["python", "main.py"]
```

## Docker Compose (App + DB)

```yaml
version: "3.8"
services:
  app:
    build: .
    env_file: .env
    restart: unless-stopped
    depends_on:
      - db
    volumes:
      - ./data:/app/data

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

## systemd Service Unit

```ini
# /etc/systemd/system/tool-name.service
[Unit]
Description=Tool Name Automation
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/tools/tool-name
ExecStart=/opt/tools/tool-name/.venv/bin/python main.py
Restart=on-failure
RestartSec=10
EnvironmentFile=/opt/tools/tool-name/.env

StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable tool-name
sudo systemctl start tool-name
sudo journalctl -u tool-name -f  # View logs
```

## Cron Deployment

```bash
# Edit crontab
crontab -e

# Daily at 8AM Vietnam time (UTC+7 → 1AM UTC)
0 1 * * * cd /opt/tools/tool-name && .venv/bin/python main.py >> /var/log/tool-name.log 2>&1

# Every 30 minutes
*/30 * * * * cd /opt/tools/tool-name && .venv/bin/python main.py --mode=check
```

## GitHub Actions CI/CD

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -r requirements.txt
      - run: python -m pytest tests/
      - name: Deploy to server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /opt/tools/tool-name
            git pull
            source .venv/bin/activate
            pip install -r requirements.txt
            sudo systemctl restart tool-name
```

## Production Checklist

- [ ] `.env` file on server (never in git)
- [ ] `requirements.txt` pinned versions
- [ ] Logging configured (file + stdout)
- [ ] Error notifications set up (Telegram/Slack)
- [ ] Monitoring: systemd watchdog or health endpoint
- [ ] Backup: data/DB backup strategy
- [ ] Firewall: only required ports open
