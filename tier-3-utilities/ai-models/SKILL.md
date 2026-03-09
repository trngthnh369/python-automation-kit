---
name: ai-models
tier: 3
category: utility
version: 1.0.0
description: OpenAI, Gemini, LangChain, prompt engineering, RAG patterns.
triggers:
  - "AI"
  - "GPT"
  - "OpenAI"
  - "Gemini"
  - "LangChain"
  - "LLM"
  - "prompt"
related:
  - "[[data-processing]]"
---

# 🧠 AI Models Integration

Patterns for using LLMs as the "brain" in Python automation tools.

## OpenAI (GPT-4o)

### Basic Completion

```python
from openai import OpenAI

client = OpenAI(api_key=Config.OPENAI_API_KEY)

def ask_gpt(prompt: str, system: str = "You are a helpful assistant.", model: str = "gpt-4o") -> str:
    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system},
            {"role": "user", "content": prompt}
        ],
        temperature=0.7,
        max_tokens=2000
    )
    return response.choices[0].message.content
```

### Structured Output (JSON Mode)

```python
import json

def extract_structured(text: str, schema_description: str) -> dict:
    response = client.chat.completions.create(
        model="gpt-4o",
        response_format={"type": "json_object"},
        messages=[
            {"role": "system", "content": f"Extract data as JSON. Schema: {schema_description}"},
            {"role": "user", "content": text}
        ]
    )
    return json.loads(response.choices[0].message.content)
```

### Function Calling (Tools)

```python
tools = [{
    "type": "function",
    "function": {
        "name": "search_products",
        "description": "Search products by SKU or name",
        "parameters": {
            "type": "object",
            "properties": {
                "query": {"type": "string"},
                "category": {"type": "string", "enum": ["electronics", "clothing", "food"]}
            },
            "required": ["query"]
        }
    }
}]

response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages,
    tools=tools,
    tool_choice="auto"
)
```

## Google Gemini

```python
import google.generativeai as genai

genai.configure(api_key=Config.GEMINI_API_KEY)
model = genai.GenerativeModel("gemini-2.0-flash")

def ask_gemini(prompt: str) -> str:
    response = model.generate_content(prompt)
    return response.text

# With image
def analyze_image(image_path: str, prompt: str) -> str:
    import PIL.Image
    img = PIL.Image.open(image_path)
    response = model.generate_content([prompt, img])
    return response.text
```

## LangChain Patterns

### Simple Chain

```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate

llm = ChatOpenAI(model="gpt-4o", temperature=0)
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a data analyst."),
    ("user", "Analyze this data: {data}")
])
chain = prompt | llm
result = chain.invoke({"data": str(data)})
```

### RAG (Retrieval-Augmented Generation)

```python
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import FAISS
from langchain.text_splitter import RecursiveCharacterTextSplitter

# Index documents
splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
docs = splitter.split_documents(documents)
vectorstore = FAISS.from_documents(docs, OpenAIEmbeddings())

# Query
retriever = vectorstore.as_retriever(search_kwargs={"k": 5})
relevant_docs = retriever.invoke("What is the return policy?")
```

## Prompt Engineering Patterns

### Template with Context

```python
ANALYSIS_PROMPT = """
Analyze the following data and provide insights.

## Data
{data}

## Requirements
- Language: Vietnamese
- Format: bullet points
- Focus on: {focus_areas}
- Max length: {max_words} words

## Output Format
Return as JSON:
{{
  "summary": "...",
  "insights": ["..."],
  "recommendations": ["..."]
}}
"""
```

### Cost Tracking

```python
import tiktoken

def count_tokens(text: str, model: str = "gpt-4o") -> int:
    enc = tiktoken.encoding_for_model(model)
    return len(enc.encode(text))

def estimate_cost(input_tokens: int, output_tokens: int, model: str = "gpt-4o") -> float:
    prices = {
        "gpt-4o": {"input": 2.50 / 1_000_000, "output": 10.00 / 1_000_000},
        "gpt-4o-mini": {"input": 0.15 / 1_000_000, "output": 0.60 / 1_000_000},
    }
    p = prices[model]
    return input_tokens * p["input"] + output_tokens * p["output"]
```

## Dependencies

```txt
openai>=1.0.0
google-generativeai>=0.3.0
langchain>=0.1.0
langchain-openai>=0.0.5
tiktoken>=0.5.0
faiss-cpu>=1.7.0  # For RAG
```
