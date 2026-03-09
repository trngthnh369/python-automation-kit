---
name: auth-security
tier: 4
category: domain
version: 1.0.0
description: OAuth2, JWT, .env management, secrets, API key rotation.
triggers:
  - "auth"
  - "OAuth"
  - "JWT"
  - "security"
  - "token"
  - ".env"
requires:
  - builder
---

# 🔐 Auth & Security

Authentication, secrets management, and security patterns.

## .env Management

### Standard .env

```env
# .env (NEVER commit this file)
DEBUG=false
TZ=Asia/Ho_Chi_Minh

# Google Workspace
GOOGLE_CREDENTIALS_FILE=service-account.json
SPREADSHEET_ID=1BxiMVs0XRA5nFMd...

# AI
OPENAI_API_KEY=sk-proj-...
GEMINI_API_KEY=AIzaSy...

# Database
DATABASE_URL=postgresql://user:pass@host:5432/dbname

# Notifications
TELEGRAM_TOKEN=123456:ABC...
TELEGRAM_CHAT_ID=-100123456789
SLACK_WEBHOOK=https://hooks.slack.com/services/...
```

### .env.example (Commit this)

```env
# Copy to .env and fill in values
DEBUG=false
TZ=Asia/Ho_Chi_Minh
GOOGLE_CREDENTIALS_FILE=service-account.json
SPREADSHEET_ID=
OPENAI_API_KEY=
DATABASE_URL=
TELEGRAM_TOKEN=
TELEGRAM_CHAT_ID=
```

### Loading

```python
from dotenv import load_dotenv
import os

load_dotenv()  # Loads .env if exists

# With validation
required_vars = ["SPREADSHEET_ID", "OPENAI_API_KEY"]
missing = [v for v in required_vars if not os.getenv(v)]
if missing:
    raise EnvironmentError(f"Missing required env vars: {missing}")
```

## OAuth2 Flow (Google)

### Service Account (Server-to-Server)

```python
from google.oauth2.service_account import Credentials

creds = Credentials.from_service_account_file(
    "service-account.json",
    scopes=["https://www.googleapis.com/auth/spreadsheets"]
)
```

### OAuth2 User Consent (Interactive)

```python
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
import pickle

SCOPES = ["https://www.googleapis.com/auth/gmail.send"]
TOKEN_FILE = "token.pickle"

def get_user_credentials():
    creds = None
    if Path(TOKEN_FILE).exists():
        with open(TOKEN_FILE, "rb") as f:
            creds = pickle.load(f)

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file("oauth_credentials.json", SCOPES)
            creds = flow.run_local_server(port=0)

        with open(TOKEN_FILE, "wb") as f:
            pickle.dump(creds, f)

    return creds
```

## JWT Tokens (For APIs)

```python
import jwt
from datetime import datetime, timedelta

SECRET_KEY = Config.JWT_SECRET

def create_token(user_id: str, expires_hours: int = 24) -> str:
    payload = {
        "sub": user_id,
        "iat": datetime.utcnow(),
        "exp": datetime.utcnow() + timedelta(hours=expires_hours)
    }
    return jwt.encode(payload, SECRET_KEY, algorithm="HS256")

def verify_token(token: str) -> dict:
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        raise AuthError("Token expired")
    except jwt.InvalidTokenError:
        raise AuthError("Invalid token")
```

## API Key Pattern

```python
import secrets
import hashlib

def generate_api_key() -> str:
    return f"sk-{secrets.token_hex(32)}"

def hash_api_key(key: str) -> str:
    return hashlib.sha256(key.encode()).hexdigest()
```

## Security Checklist

- [ ] `.env` in `.gitignore`
- [ ] `.env.example` committed (no real values)
- [ ] `service-account.json` in `.gitignore`
- [ ] No hardcoded secrets anywhere
- [ ] API keys have minimal required permissions
- [ ] Tokens expire and are refreshable
- [ ] HTTPS for all external requests
- [ ] Input validation on all user inputs

## Dependencies

```txt
python-dotenv>=1.0.0
PyJWT>=2.8.0
google-auth>=2.0.0
google-auth-oauthlib>=1.0.0
cryptography>=41.0.0
```
