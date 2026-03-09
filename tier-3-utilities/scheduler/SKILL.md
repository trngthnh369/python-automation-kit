---
name: scheduler
tier: 3
category: utility
version: 1.0.0
description: Cron, APScheduler, Celery, task queues, recurring tasks.
triggers:
  - "schedule"
  - "cron"
  - "recurring"
  - "periodic"
  - "celery"
related:
  - "[[deployer]]"
---

# ⏰ Scheduler

Patterns for scheduled and recurring Python tasks.

## APScheduler (Recommended for Simple)

```python
from apscheduler.schedulers.blocking import BlockingScheduler
from apscheduler.triggers.cron import CronTrigger
import logging

logging.basicConfig(level=logging.INFO)

scheduler = BlockingScheduler(timezone="Asia/Ho_Chi_Minh")

@scheduler.scheduled_job(CronTrigger(hour=8, minute=0))
def daily_report():
    """Runs daily at 8:00 AM VN."""
    logger.info("Starting daily report...")
    generate_report()

@scheduler.scheduled_job('interval', minutes=30)
def check_inventory():
    """Runs every 30 minutes."""
    scan_inventory()

if __name__ == "__main__":
    scheduler.start()
```

## Celery (For Distributed / Complex)

### Setup

```python
# celery_app.py
from celery import Celery
from celery.schedules import crontab

app = Celery('tasks', broker='redis://localhost:6379/0')

app.conf.beat_schedule = {
    'daily-report': {
        'task': 'tasks.generate_report',
        'schedule': crontab(hour=8, minute=0),
    },
    'inventory-check': {
        'task': 'tasks.check_inventory',
        'schedule': crontab(minute='*/30'),
    },
}
app.conf.timezone = 'Asia/Ho_Chi_Minh'

@app.task(bind=True, max_retries=3)
def generate_report(self):
    try:
        return do_report()
    except Exception as exc:
        self.retry(countdown=60, exc=exc)
```

```bash
# Run worker + beat
celery -A celery_app worker --loglevel=info
celery -A celery_app beat --loglevel=info
```

## Python Schedule Library (Simplest)

```python
import schedule
import time

def job():
    print("Running scheduled task...")

schedule.every().day.at("08:00").do(job)
schedule.every(30).minutes.do(job)

while True:
    schedule.run_pending()
    time.sleep(1)
```

## Cron Expression Reference

| Expression     | Meaning            |
| -------------- | ------------------ |
| `0 8 * * *`    | Daily at 8:00 AM   |
| `*/30 * * * *` | Every 30 minutes   |
| `0 */2 * * *`  | Every 2 hours      |
| `0 8 * * 1`    | Weekly Monday 8AM  |
| `0 8 1 * *`    | Monthly 1st at 8AM |

## Dependencies

```txt
apscheduler>=3.10.0    # Simple scheduler
celery>=5.3.0          # Distributed
redis>=4.0.0           # Celery broker
schedule>=1.2.0        # Simplest
```
