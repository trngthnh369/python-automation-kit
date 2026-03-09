---
name: builder
tier: 2
category: hub
version: 1.0.0
description: Python code patterns, best practices, typing, async, error handling.
triggers:
  - "write code"
  - "python code"
  - "implement"
requires:
  - architect
related:
  - "[[debugger]]"
---

# 🔨 Builder

Production-grade Python code patterns for automation tools.

## Code Standards

### Type Hints (Always)

```python
from typing import Optional
from datetime import datetime

def process_data(
    records: list[dict],
    sheet_id: str,
    date_filter: Optional[datetime] = None,
    batch_size: int = 100
) -> dict[str, int]:
    """Process records and return summary counts."""
    ...
```

### Pydantic Models (For Structured Data)

```python
from pydantic import BaseModel, Field
from datetime import datetime

class ReportRow(BaseModel):
    date: datetime
    metric: str
    value: float = Field(ge=0)
    source: str = "manual"

    class Config:
        json_encoders = {datetime: lambda v: v.isoformat()}
```

### Error Handling Pattern

```python
import logging

logger = logging.getLogger(__name__)

class ToolError(Exception):
    """Base error for this tool."""

class APIError(ToolError):
    """External API failure."""

class DataError(ToolError):
    """Data validation failure."""

def safe_execute(func):
    """Decorator for safe execution with logging."""
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except ToolError as e:
            logger.error(f"Tool error in {func.__name__}: {e}")
            raise
        except Exception as e:
            logger.exception(f"Unexpected error in {func.__name__}: {e}")
            raise ToolError(f"Unexpected: {e}") from e
    return wrapper
```

## Async Patterns

### httpx for HTTP Requests

```python
import httpx

async def fetch_data(url: str, headers: dict) -> dict:
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.get(url, headers=headers)
        resp.raise_for_status()
        return resp.json()
```

### Batch Async (Semaphore-Limited)

```python
import asyncio

async def batch_process(items: list, max_concurrent: int = 5):
    semaphore = asyncio.Semaphore(max_concurrent)

    async def process_one(item):
        async with semaphore:
            return await do_work(item)

    results = await asyncio.gather(
        *[process_one(item) for item in items],
        return_exceptions=True
    )

    successes = [r for r in results if not isinstance(r, Exception)]
    failures = [r for r in results if isinstance(r, Exception)]
    return successes, failures
```

## Retry Pattern

```python
import time
import logging

logger = logging.getLogger(__name__)

def retry(max_attempts: int = 3, delay: float = 1.0, backoff: float = 2.0):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts:
                        logger.error(f"{func.__name__} failed after {max_attempts} attempts: {e}")
                        raise
                    wait = delay * (backoff ** (attempt - 1))
                    logger.warning(f"{func.__name__} attempt {attempt} failed, retrying in {wait}s: {e}")
                    time.sleep(wait)
        return wrapper
    return decorator
```

## Date/Time (Always Use Timezone-Aware)

```python
from datetime import datetime, timezone, timedelta

VN_TZ = timezone(timedelta(hours=7))

def now_vn() -> datetime:
    return datetime.now(VN_TZ)

def today_vn() -> str:
    return now_vn().strftime("%Y-%m-%d")
```

## CLI Entry Point Pattern

```python
import argparse
import sys

def main():
    parser = argparse.ArgumentParser(description="Tool description")
    parser.add_argument("--dry-run", action="store_true", help="Run without side effects")
    parser.add_argument("--date", type=str, help="Target date (YYYY-MM-DD)")
    parser.add_argument("--verbose", "-v", action="store_true")

    args = parser.parse_args()

    # Validate config
    from config import Config
    errors = Config.validate()
    if errors:
        print(f"Config errors: {errors}", file=sys.stderr)
        sys.exit(1)

    # Run
    try:
        result = run(dry_run=args.dry_run, target_date=args.date)
        print(f"✅ Done: {result}")
    except Exception as e:
        print(f"❌ Failed: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
```
