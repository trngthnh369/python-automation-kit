---
name: file-management
tier: 4
category: domain
version: 1.0.0
description: S3, GCS, local file ops, zip/unzip, streaming uploads.
triggers:
  - "file"
  - "upload"
  - "download"
  - "S3"
  - "GCS"
  - "storage"
requires:
  - builder
---

# 📁 File Management

Local, cloud (S3/GCS), and file operation patterns.

## Local File Operations

```python
from pathlib import Path
import shutil

# Safe file operations
def ensure_dir(path: str) -> Path:
    p = Path(path)
    p.mkdir(parents=True, exist_ok=True)
    return p

def safe_write(path: str, content: str):
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(content, encoding="utf-8")

def list_files(directory: str, pattern: str = "*") -> list[Path]:
    return sorted(Path(directory).glob(pattern))

# Zip/Unzip
def create_zip(source_dir: str, output_path: str):
    shutil.make_archive(output_path.replace('.zip', ''), 'zip', source_dir)

def extract_zip(zip_path: str, dest_dir: str):
    shutil.unpack_archive(zip_path, dest_dir)
```

## AWS S3

```python
import boto3

s3 = boto3.client('s3',
    aws_access_key_id=Config.AWS_ACCESS_KEY,
    aws_secret_access_key=Config.AWS_SECRET_KEY,
    region_name=Config.AWS_REGION
)

def upload_to_s3(file_path: str, bucket: str, key: str):
    s3.upload_file(file_path, bucket, key)
    return f"s3://{bucket}/{key}"

def download_from_s3(bucket: str, key: str, dest: str):
    s3.download_file(bucket, key, dest)

def list_s3_files(bucket: str, prefix: str = "") -> list[str]:
    resp = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)
    return [obj['Key'] for obj in resp.get('Contents', [])]
```

## Google Cloud Storage

```python
from google.cloud import storage

def upload_to_gcs(file_path: str, bucket_name: str, blob_name: str):
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    blob.upload_from_filename(file_path)
    return f"gs://{bucket_name}/{blob_name}"
```

## Temp File Pattern

```python
import tempfile

def process_with_temp():
    with tempfile.NamedTemporaryFile(suffix='.csv', delete=False) as tmp:
        tmp.write(data_bytes)
        tmp_path = tmp.name

    try:
        result = process_file(tmp_path)
    finally:
        Path(tmp_path).unlink(missing_ok=True)
    return result
```

## Dependencies

```txt
boto3>=1.28.0           # AWS S3
google-cloud-storage>=2.0.0  # GCS
```
