---
name: data-processing
tier: 4
category: domain
version: 1.0.0
description: Pandas, ETL pipelines, CSV/Excel, data validation, transformation.
triggers:
  - "data processing"
  - "pandas"
  - "CSV"
  - "Excel"
  - "ETL"
requires:
  - builder
related:
  - "[[google-workspace]]"
  - "[[database]]"
---

# 📊 Data Processing & ETL

Pandas, CSV/Excel handling, validation, and transformation patterns.

## Read Data Sources

```python
import pandas as pd

# CSV (with encoding handling for VN)
df = pd.read_csv("data.csv", encoding="utf-8-sig")

# Excel
df = pd.read_excel("data.xlsx", sheet_name="Sheet1", engine="openpyxl")

# Google Sheets → DataFrame
def sheets_to_df(records: list[dict]) -> pd.DataFrame:
    df = pd.DataFrame(records)
    # Auto-convert numeric columns
    for col in df.columns:
        df[col] = pd.to_numeric(df[col], errors='ignore')
    return df

# SQL → DataFrame
df = pd.read_sql("SELECT * FROM products WHERE stock < 10", engine)
```

## Common Transformations

```python
# Clean whitespace
df.columns = df.columns.str.strip()
df = df.applymap(lambda x: x.strip() if isinstance(x, str) else x)

# Remove duplicates
df = df.drop_duplicates(subset=['sku'], keep='last')

# Fill missing values
df['stock'] = df['stock'].fillna(0).astype(int)
df['category'] = df['category'].fillna('Uncategorized')

# Date parsing (VN format DD/MM/YYYY)
df['date'] = pd.to_datetime(df['date'], format='%d/%m/%Y', errors='coerce')

# Filter
active = df[df['status'] == 'active']
low_stock = df[df['stock'] < 10]

# Group & Aggregate
summary = df.groupby('category').agg(
    total_revenue=('revenue', 'sum'),
    avg_price=('price', 'mean'),
    count=('sku', 'count')
).reset_index()

# Pivot
pivot = df.pivot_table(values='revenue', index='month', columns='category', aggfunc='sum', fill_value=0)
```

## Data Validation

```python
def validate_dataframe(df: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Returns (valid_df, invalid_df)."""
    errors = []

    # Required fields
    required = ['sku', 'name', 'price']
    for col in required:
        mask = df[col].isna() | (df[col] == '')
        errors.extend(df[mask].index.tolist())

    # Numeric constraints
    price_invalid = df[df['price'] <= 0].index.tolist()
    errors.extend(price_invalid)

    error_indices = list(set(errors))
    valid = df.drop(index=error_indices)
    invalid = df.loc[error_indices]

    return valid, invalid
```

## Export Patterns

```python
# To CSV
df.to_csv("output.csv", index=False, encoding="utf-8-sig")

# To Excel with formatting
with pd.ExcelWriter("report.xlsx", engine="openpyxl") as writer:
    summary.to_excel(writer, sheet_name="Summary", index=False)
    details.to_excel(writer, sheet_name="Details", index=False)

# To Google Sheets
def df_to_sheets(df: pd.DataFrame, spreadsheet_id: str, sheet_name: str):
    values = [df.columns.tolist()] + df.fillna('').values.tolist()
    update_range(spreadsheet_id, f"{sheet_name}!A1", values)

# To JSON
df.to_json("output.json", orient="records", force_ascii=False)
```

## ETL Pipeline Pattern

```python
def etl_pipeline(source_config: dict, dest_config: dict):
    # EXTRACT
    raw = extract(source_config)
    logger.info(f"Extracted {len(raw)} records")

    # TRANSFORM
    cleaned = transform(raw)
    valid, invalid = validate_dataframe(cleaned)
    logger.info(f"Valid: {len(valid)}, Invalid: {len(invalid)}")

    # LOAD
    load(valid, dest_config)
    if len(invalid) > 0:
        quarantine(invalid)
        logger.warning(f"Quarantined {len(invalid)} invalid records")

    return {"loaded": len(valid), "quarantined": len(invalid)}
```

## Dependencies

```txt
pandas>=2.0.0
openpyxl>=3.0.0
xlsxwriter>=3.0.0
```
