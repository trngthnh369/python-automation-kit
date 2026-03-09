---
name: debugger
tier: 2
category: hub
version: 1.0.0
description: Testing, debugging, logging, profiling, error analysis.
triggers:
  - "test"
  - "debug"
  - "fix error"
  - "pytest"
requires:
  - builder
related:
  - "[[deployer]]"
---

# 🐛 Debugger

Testing, debugging, and quality assurance for Python automation tools.

## Testing with pytest

### Basic Test Structure

```python
# tests/test_main.py
import pytest
from unittest.mock import patch, MagicMock

def test_process_data_happy_path():
    result = process_data([{"name": "A", "value": 10}])
    assert result["total"] == 10
    assert result["count"] == 1

def test_process_data_empty():
    result = process_data([])
    assert result["total"] == 0

def test_process_data_invalid():
    with pytest.raises(DataError):
        process_data([{"invalid": True}])
```

### Mocking External Services

```python
@patch("services.sheets.get_sheet_data")
def test_report_generation(mock_sheets):
    mock_sheets.return_value = [
        {"date": "2025-01-01", "revenue": 1000},
        {"date": "2025-01-02", "revenue": 2000},
    ]
    result = generate_report("sheet_id_123")
    assert result["total_revenue"] == 3000
    mock_sheets.assert_called_once_with("sheet_id_123")
```

### Fixtures

```python
@pytest.fixture
def sample_config():
    return Config(
        SPREADSHEET_ID="test_id",
        OPENAI_API_KEY="test_key",
        DEBUG=True
    )

@pytest.fixture
def sample_data():
    return [
        {"sku": "A001", "name": "Product A", "stock": 10},
        {"sku": "A002", "name": "Product B", "stock": 0},
    ]

def test_with_fixtures(sample_config, sample_data):
    result = process(sample_data, config=sample_config)
    assert len(result) == 2
```

## Run Tests

```bash
# All tests
python -m pytest tests/ -v

# Single file
python -m pytest tests/test_main.py -v

# With coverage
python -m pytest tests/ --cov=app --cov-report=term-missing

# Only failed
python -m pytest --lf
```

## Linting & Type Checking

```bash
# Ruff (fast linter)
pip install ruff
ruff check .
ruff format .

# Mypy (type checker)
pip install mypy
mypy app/ --ignore-missing-imports
```

## Logging Best Practices

```python
import logging

# Configure once in main.py
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler("tool.log", encoding="utf-8")
    ]
)

logger = logging.getLogger(__name__)

# Usage patterns
logger.info("Processing %d records", len(records))
logger.warning("Rate limit approaching: %d/100", count)
logger.error("Failed to fetch data: %s", error)
logger.exception("Unexpected error")  # includes traceback
```

## Common Debugging Patterns

### 1. Dry-Run Mode

```python
def execute(action, dry_run=False):
    if dry_run:
        logger.info(f"[DRY-RUN] Would execute: {action}")
        return {"status": "dry-run", "action": action}
    return actually_execute(action)
```

### 2. Debug Breakpoint

```python
# Insert anywhere for interactive debugging
breakpoint()  # Python 3.7+
# Or: import pdb; pdb.set_trace()
```

### 3. Timing Decorator

```python
import time
import functools

def timer(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        logger.info(f"{func.__name__} took {elapsed:.2f}s")
        return result
    return wrapper
```

## Error Diagnosis Checklist

1. ❓ Is `.env` loaded correctly? → `print(Config.SPREADSHEET_ID)`
2. ❓ Are credentials valid? → Test with minimal API call
3. ❓ Network issues? → `curl` or `httpx` test
4. ❓ Data format changed? → Log `type(data)`, `len(data)`, `data[:2]`
5. ❓ Rate limited? → Check headers for `X-RateLimit-*`
