---
name: google-workspace
tier: 3
category: utility
version: 1.0.0
description: Gmail, Sheets, Drive, Calendar, Docs API integration patterns.
triggers:
  - "gmail"
  - "google sheets"
  - "google drive"
  - "calendar"
  - "google api"
related:
  - "[[auth-security]]"
  - "[[data-processing]]"
---

# 📊 Google Workspace Integration

Python patterns for Gmail, Sheets, Drive, Calendar, and Docs APIs.

## Authentication Setup

### Service Account (Recommended for Automation)

```python
from google.oauth2.service_account import Credentials
from googleapiclient.discovery import build

SCOPES = [
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/gmail.send',
    'https://www.googleapis.com/auth/calendar',
]

def get_credentials(credentials_file: str = "service-account.json"):
    return Credentials.from_service_account_file(credentials_file, scopes=SCOPES)

def get_sheets_service():
    return build('sheets', 'v4', credentials=get_credentials())

def get_drive_service():
    return build('drive', 'v3', credentials=get_credentials())

def get_gmail_service():
    return build('gmail', 'v1', credentials=get_credentials())
```

### gspread (Simpler API)

```python
import gspread

gc = gspread.service_account(filename="service-account.json")
spreadsheet = gc.open_by_key("SPREADSHEET_ID")
worksheet = spreadsheet.worksheet("Sheet1")
```

## Google Sheets Patterns

### Read All Data

```python
def read_sheet(spreadsheet_id: str, range_name: str = "Sheet1") -> list[dict]:
    service = get_sheets_service()
    result = service.spreadsheets().values().get(
        spreadsheetId=spreadsheet_id,
        range=range_name
    ).execute()

    rows = result.get("values", [])
    if not rows:
        return []

    headers = rows[0]
    return [dict(zip(headers, row + [''] * (len(headers) - len(row)))) for row in rows[1:]]
```

### Write/Append Data

```python
def append_rows(spreadsheet_id: str, sheet_name: str, rows: list[list]):
    service = get_sheets_service()
    service.spreadsheets().values().append(
        spreadsheetId=spreadsheet_id,
        range=f"{sheet_name}!A1",
        valueInputOption="USER_ENTERED",
        insertDataOption="INSERT_ROWS",
        body={"values": rows}
    ).execute()

def update_range(spreadsheet_id: str, range_name: str, values: list[list]):
    service = get_sheets_service()
    service.spreadsheets().values().update(
        spreadsheetId=spreadsheet_id,
        range=range_name,
        valueInputOption="USER_ENTERED",
        body={"values": values}
    ).execute()
```

### Batch Update (Rate-Limit Safe)

```python
import time

def batch_update_rows(spreadsheet_id: str, updates: list[dict], batch_size: int = 50):
    """Updates: [{"range": "Sheet1!A2", "values": [[...]]}]"""
    service = get_sheets_service()

    for i in range(0, len(updates), batch_size):
        batch = updates[i:i + batch_size]
        service.spreadsheets().values().batchUpdate(
            spreadsheetId=spreadsheet_id,
            body={"valueInputOption": "USER_ENTERED", "data": batch}
        ).execute()

        if i + batch_size < len(updates):
            time.sleep(1)  # Rate limit: 60 req/min
```

## Gmail Patterns

### Send Email

```python
import base64
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_email(to: str, subject: str, body_html: str, sender: str = "me"):
    service = get_gmail_service()

    message = MIMEMultipart()
    message["to"] = to
    message["subject"] = subject
    message.attach(MIMEText(body_html, "html"))

    raw = base64.urlsafe_b64encode(message.as_bytes()).decode()
    service.users().messages().send(
        userId=sender,
        body={"raw": raw}
    ).execute()
```

### Send Email with Attachment

```python
from email.mime.base import MIMEBase
from email import encoders

def send_with_attachment(to: str, subject: str, body: str, file_path: str):
    message = MIMEMultipart()
    message["to"] = to
    message["subject"] = subject
    message.attach(MIMEText(body, "html"))

    with open(file_path, "rb") as f:
        part = MIMEBase("application", "octet-stream")
        part.set_payload(f.read())
    encoders.encode_base64(part)
    part.add_header("Content-Disposition", f"attachment; filename={Path(file_path).name}")
    message.attach(part)

    raw = base64.urlsafe_b64encode(message.as_bytes()).decode()
    get_gmail_service().users().messages().send(userId="me", body={"raw": raw}).execute()
```

## Google Drive Patterns

### Upload File

```python
from googleapiclient.http import MediaFileUpload

def upload_to_drive(file_path: str, folder_id: str = None, mime_type: str = None):
    service = get_drive_service()
    metadata = {"name": Path(file_path).name}
    if folder_id:
        metadata["parents"] = [folder_id]

    media = MediaFileUpload(file_path, mimetype=mime_type, resumable=True)
    file = service.files().create(
        body=metadata, media_body=media, fields="id,webViewLink"
    ).execute()
    return file
```

### List Files in Folder

```python
def list_files(folder_id: str) -> list[dict]:
    service = get_drive_service()
    results = service.files().list(
        q=f"'{folder_id}' in parents and trashed=false",
        fields="files(id, name, mimeType, modifiedTime, size)"
    ).execute()
    return results.get("files", [])
```

## Google Calendar

```python
def create_event(summary: str, start: str, end: str, calendar_id: str = "primary"):
    service = build('calendar', 'v3', credentials=get_credentials())
    event = {
        "summary": summary,
        "start": {"dateTime": start, "timeZone": "Asia/Ho_Chi_Minh"},
        "end": {"dateTime": end, "timeZone": "Asia/Ho_Chi_Minh"},
    }
    return service.events().insert(calendarId=calendar_id, body=event).execute()
```

## Dependencies

```txt
google-auth>=2.0.0
google-api-python-client>=2.0.0
gspread>=5.0.0
```
