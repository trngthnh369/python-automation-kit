---
name: notification
tier: 4
category: domain
version: 1.0.0
description: Zalo, Telegram, Slack, Email, SMS notification patterns.
triggers:
  - "notify"
  - "Zalo"
  - "Telegram"
  - "Slack"
  - "alert"
requires:
  - builder
---

# 🔔 Notification

Multi-channel notification patterns for automation tools.

## Telegram Bot

```python
import httpx

class TelegramNotifier:
    def __init__(self, token: str, chat_id: str):
        self.base_url = f"https://api.telegram.org/bot{token}"
        self.chat_id = chat_id

    def send(self, message: str, parse_mode: str = "HTML"):
        httpx.post(f"{self.base_url}/sendMessage", json={
            "chat_id": self.chat_id,
            "text": message,
            "parse_mode": parse_mode
        })

    def send_document(self, file_path: str, caption: str = ""):
        with open(file_path, "rb") as f:
            httpx.post(f"{self.base_url}/sendDocument",
                data={"chat_id": self.chat_id, "caption": caption},
                files={"document": f}
            )

# Usage
notifier = TelegramNotifier(Config.TELEGRAM_TOKEN, Config.TELEGRAM_CHAT_ID)
notifier.send("✅ <b>Report completed</b>\nRecords: 150\nTime: 2.5s")
```

## Slack Webhook

```python
def send_slack(webhook_url: str, message: str, blocks: list = None):
    payload = {"text": message}
    if blocks:
        payload["blocks"] = blocks
    httpx.post(webhook_url, json=payload)

# Rich message
def slack_alert(title: str, details: str, color: str = "#FF0000"):
    return send_slack(Config.SLACK_WEBHOOK, title, blocks=[
        {"type": "header", "text": {"type": "plain_text", "text": title}},
        {"type": "section", "text": {"type": "mrkdwn", "text": details}},
    ])
```

## Zalo OA

```python
def send_zalo(user_id: str, message: str):
    httpx.post("https://openapi.zalo.me/v3.0/oa/message/cs",
        headers={"access_token": Config.ZALO_TOKEN},
        json={
            "recipient": {"user_id": user_id},
            "message": {"text": message}
        }
    )
```

## Email (SMTP)

```python
import smtplib
from email.mime.text import MIMEText

def send_email_smtp(to: str, subject: str, body: str):
    msg = MIMEText(body, "html")
    msg["Subject"] = subject
    msg["From"] = Config.EMAIL_FROM
    msg["To"] = to

    with smtplib.SMTP(Config.SMTP_HOST, Config.SMTP_PORT) as server:
        server.starttls()
        server.login(Config.SMTP_USER, Config.SMTP_PASS)
        server.send_message(msg)
```

## Unified Notifier

```python
class Notifier:
    def __init__(self, config):
        self.telegram = TelegramNotifier(config.TELEGRAM_TOKEN, config.TELEGRAM_CHAT_ID) if config.TELEGRAM_TOKEN else None
        self.slack_url = config.SLACK_WEBHOOK

    def success(self, message: str):
        text = f"✅ {message}"
        if self.telegram: self.telegram.send(text)
        if self.slack_url: send_slack(self.slack_url, text)

    def error(self, message: str, error: Exception = None):
        text = f"❌ {message}"
        if error: text += f"\n<code>{str(error)[:500]}</code>"
        if self.telegram: self.telegram.send(text)
        if self.slack_url: send_slack(self.slack_url, text)

# Usage: notifier = Notifier(Config)
```

## Dependencies

```txt
httpx>=0.24.0
```
