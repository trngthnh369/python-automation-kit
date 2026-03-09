---
name: web-scraping
tier: 4
category: domain
version: 1.0.0
description: BeautifulSoup, Playwright, Selenium, anti-detection, proxy rotation.
triggers:
  - "scrape"
  - "crawl"
  - "web scraping"
  - "BeautifulSoup"
  - "Playwright"
requires:
  - builder
---

# 🕷️ Web Scraping

Patterns for ethical web scraping with anti-detection and resilience.

## BeautifulSoup (Static Pages)

```python
import httpx
from bs4 import BeautifulSoup

def scrape_page(url: str) -> BeautifulSoup:
    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}
    response = httpx.get(url, headers=headers, timeout=30, follow_redirects=True)
    response.raise_for_status()
    return BeautifulSoup(response.text, "html.parser")

# Extract data
soup = scrape_page("https://example.com/products")
products = []
for item in soup.select(".product-card"):
    products.append({
        "name": item.select_one(".title").text.strip(),
        "price": item.select_one(".price").text.strip(),
        "url": item.select_one("a")["href"],
    })
```

## Playwright (Dynamic / JS-rendered)

```python
from playwright.async_api import async_playwright

async def scrape_dynamic(url: str) -> str:
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()

        # Anti-detection
        await page.set_extra_http_headers({"Accept-Language": "vi-VN,vi;q=0.9"})

        await page.goto(url, wait_until="networkidle")

        # Wait for specific element
        await page.wait_for_selector(".product-list", timeout=10000)

        content = await page.content()
        await browser.close()
        return content
```

## Pagination Handling

```python
async def scrape_all_pages(base_url: str, max_pages: int = 50) -> list[dict]:
    all_items = []

    for page in range(1, max_pages + 1):
        url = f"{base_url}?page={page}"
        soup = scrape_page(url)
        items = parse_items(soup)

        if not items:
            break

        all_items.extend(items)
        logger.info(f"Page {page}: {len(items)} items (total: {len(all_items)})")

        time.sleep(random.uniform(1, 3))  # Polite delay

    return all_items
```

## Rate Limiting & Retry

```python
import time
import random

class RateLimitedScraper:
    def __init__(self, requests_per_minute: int = 30):
        self.delay = 60 / requests_per_minute
        self.last_request = 0

    def get(self, url: str, max_retries: int = 3) -> httpx.Response:
        for attempt in range(max_retries):
            elapsed = time.time() - self.last_request
            if elapsed < self.delay:
                time.sleep(self.delay - elapsed)

            try:
                response = httpx.get(url, headers=self.headers, timeout=30)
                self.last_request = time.time()

                if response.status_code == 429:
                    wait = int(response.headers.get("Retry-After", 60))
                    logger.warning(f"Rate limited, waiting {wait}s")
                    time.sleep(wait)
                    continue

                response.raise_for_status()
                return response
            except httpx.TimeoutException:
                logger.warning(f"Timeout on attempt {attempt + 1}")
                time.sleep(2 ** attempt)

        raise Exception(f"Failed after {max_retries} attempts: {url}")
```

## Proxy Rotation

```python
import itertools

class ProxyRotator:
    def __init__(self, proxies: list[str]):
        self.cycle = itertools.cycle(proxies)

    def get_next(self) -> dict:
        proxy = next(self.cycle)
        return {"http://": proxy, "https://": proxy}

proxies = ProxyRotator(["http://proxy1:8080", "http://proxy2:8080"])
response = httpx.get(url, proxies=proxies.get_next())
```

## Dependencies

```txt
httpx>=0.24.0
beautifulsoup4>=4.12.0
lxml>=4.9.0
playwright>=1.40.0
```
