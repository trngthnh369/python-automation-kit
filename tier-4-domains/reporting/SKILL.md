---
name: reporting
tier: 4
category: domain
version: 1.0.0
description: Charts, PDF generation, email reports, dashboards.
triggers:
  - "report"
  - "chart"
  - "PDF"
  - "dashboard"
requires:
  - builder
related:
  - "[[google-workspace]]"
  - "[[data-processing]]"
---

# 📈 Reporting & Dashboards

Chart generation, PDF reports, and automated email report delivery.

## Matplotlib Charts

```python
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend

def create_bar_chart(data: dict, title: str, output_path: str):
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.bar(data.keys(), data.values(), color='#4CAF50')
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.set_ylabel("Value")
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig(output_path, dpi=150)
    plt.close()

def create_line_chart(df, x_col: str, y_cols: list, title: str, output: str):
    fig, ax = plt.subplots(figsize=(12, 6))
    for col in y_cols:
        ax.plot(df[x_col], df[col], marker='o', label=col)
    ax.legend()
    ax.set_title(title)
    plt.tight_layout()
    plt.savefig(output, dpi=150)
    plt.close()
```

## Plotly (Interactive)

```python
import plotly.express as px
import plotly.io as pio

def create_interactive_chart(df, x, y, title):
    fig = px.bar(df, x=x, y=y, title=title, color=y, barmode='group')
    pio.write_html(fig, "report.html")
    pio.write_image(fig, "report.png", scale=2)
```

## PDF Report Generation

```python
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Image, Spacer
from reportlab.lib.styles import getSampleStyleSheet

def generate_pdf_report(data: list[dict], charts: list[str], output: str):
    doc = SimpleDocTemplate(output, pagesize=A4)
    styles = getSampleStyleSheet()
    elements = []

    # Title
    elements.append(Paragraph("Daily Report", styles['Title']))
    elements.append(Spacer(1, 20))

    # Table
    table_data = [list(data[0].keys())]  # Headers
    table_data.extend([list(row.values()) for row in data])

    table = Table(table_data)
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#4CAF50')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('GRID', (0, 0), (-1, -1), 1, colors.grey),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
    ]))
    elements.append(table)

    # Charts
    for chart_path in charts:
        elements.append(Spacer(1, 20))
        elements.append(Image(chart_path, width=450, height=250))

    doc.build(elements)
```

## HTML Email Report

```python
def build_html_report(title: str, summary: dict, table_html: str) -> str:
    return f"""
    <html>
    <body style="font-family: Arial, sans-serif; padding: 20px;">
        <h2 style="color: #333;">{title}</h2>
        <div style="background: #f5f5f5; padding: 15px; border-radius: 8px;">
            <p><strong>Tổng doanh thu:</strong> {summary['revenue']:,.0f} VND</p>
            <p><strong>Số đơn hàng:</strong> {summary['orders']}</p>
            <p><strong>Ngày:</strong> {summary['date']}</p>
        </div>
        <h3>Chi tiết</h3>
        {table_html}
        <p style="color: #999; font-size: 12px;">Auto-generated report</p>
    </body>
    </html>
    """

# DataFrame to HTML table
table_html = df.to_html(index=False, classes='report-table', border=0)
```

## Automated Report Pipeline

```python
def daily_report_pipeline():
    # 1. Get data
    data = fetch_daily_data()
    df = pd.DataFrame(data)

    # 2. Generate charts
    chart_path = "/tmp/daily_chart.png"
    create_bar_chart(df.groupby('category')['revenue'].sum().to_dict(),
                     "Revenue by Category", chart_path)

    # 3. Generate PDF
    pdf_path = f"/tmp/report_{today_vn()}.pdf"
    generate_pdf_report(data, [chart_path], pdf_path)

    # 4. Send email
    html = build_html_report("Daily Report", summary, df.to_html(index=False))
    send_with_attachment(Config.REPORT_EMAIL, f"Report {today_vn()}", html, pdf_path)

    # 5. Upload to Drive
    upload_to_drive(pdf_path, folder_id=Config.REPORTS_FOLDER_ID)
```

## Dependencies

```txt
matplotlib>=3.7.0
plotly>=5.15.0
reportlab>=4.0.0
kaleido>=0.2.0     # For plotly image export
```
