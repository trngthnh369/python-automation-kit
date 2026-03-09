---
name: database
tier: 3
category: utility
version: 1.0.0
description: SQL/NoSQL, SQLAlchemy ORM, migrations, connection pooling.
triggers:
  - "database"
  - "SQL"
  - "MySQL"
  - "PostgreSQL"
  - "MongoDB"
  - "SQLAlchemy"
---

# 🗄️ Database Integration

SQL, NoSQL, and ORM patterns for Python automation tools.

## SQLAlchemy ORM (Recommended)

### Setup

```python
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Float
from sqlalchemy.orm import sessionmaker, declarative_base
from datetime import datetime

Base = declarative_base()

class Product(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True)
    sku = Column(String(50), unique=True, index=True)
    name = Column(String(200))
    price = Column(Float)
    stock = Column(Integer, default=0)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

# Engine + Session
engine = create_engine(Config.DATABASE_URL, pool_size=5, pool_recycle=3600)
Session = sessionmaker(bind=engine)

# Create tables
Base.metadata.create_all(engine)
```

### CRUD Operations

```python
def get_or_create(session, model, defaults=None, **kwargs):
    instance = session.query(model).filter_by(**kwargs).first()
    if instance:
        return instance, False
    params = {**kwargs, **(defaults or {})}
    instance = model(**params)
    session.add(instance)
    session.commit()
    return instance, True

# Context manager pattern
def with_session(func):
    def wrapper(*args, **kwargs):
        session = Session()
        try:
            result = func(session, *args, **kwargs)
            session.commit()
            return result
        except Exception:
            session.rollback()
            raise
        finally:
            session.close()
    return wrapper
```

## Direct MySQL/PostgreSQL

### mysql-connector

```python
import mysql.connector

def query_db(sql: str, params: tuple = ()) -> list[dict]:
    conn = mysql.connector.connect(
        host=Config.DB_HOST, user=Config.DB_USER,
        password=Config.DB_PASS, database=Config.DB_NAME
    )
    cursor = conn.cursor(dictionary=True)
    cursor.execute(sql, params)
    results = cursor.fetchall()
    conn.close()
    return results
```

### psycopg2 (PostgreSQL)

```python
import psycopg2
from psycopg2.extras import RealDictCursor

def pg_query(sql: str, params: tuple = ()) -> list[dict]:
    with psycopg2.connect(Config.DATABASE_URL) as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(sql, params)
            return cur.fetchall()
```

## MongoDB

```python
from pymongo import MongoClient

client = MongoClient(Config.MONGO_URI)
db = client[Config.MONGO_DB]

# Insert
db.products.insert_one({"sku": "A001", "name": "Product A", "stock": 100})

# Find
products = list(db.products.find({"stock": {"$lt": 10}}))

# Upsert
db.products.update_one(
    {"sku": "A001"},
    {"$set": {"stock": 50, "updated_at": datetime.utcnow()}},
    upsert=True
)
```

## Connection Pool Pattern

```python
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    Config.DATABASE_URL,
    poolclass=QueuePool,
    pool_size=5,          # Persistent connections
    max_overflow=10,      # Extra connections when busy
    pool_recycle=3600,    # Recycle after 1 hour
    pool_pre_ping=True,   # Check connection health
)
```

## Dependencies

```txt
sqlalchemy>=2.0.0
mysql-connector-python>=8.0.0  # MySQL
psycopg2-binary>=2.9.0         # PostgreSQL
pymongo>=4.0.0                 # MongoDB
```
