# 📊 Olist End-to-End Analytics Platform

An end-to-end modern data platform that transforms raw e-commerce data into actionable business insights using a **cloud-native analytics stack**:  
**Meltano → BigQuery → dbt → Great Expectations → Looker Studio**

---

## 🚀 Project Overview

This project demonstrates a **production-style analytics engineering workflow**, covering the full data lifecycle:

1. **Raw data ingestion** from CSV source systems  
2. **Cloud data warehousing** in BigQuery  
3. **Data transformation & modeling** using dbt  
4. **Data quality validation** using Great Expectations  
5. **Orchestration-ready pipelines** via Dagster  
6. **Business intelligence dashboard** in Looker Studio  

The final output is a **3-layer BI dashboard** delivering:

- Executive KPIs  
- Business growth trends  
- Operational & customer experience insights  

---

## 🏗️ Architecture

### 🔹 Logical Architecture (Cloud-Agnostic)

```text
Source Systems
↓
Ingestion Layer (Meltano)
↓
Raw Data Layer (BigQuery)
↓
Transformation Layer (dbt)
↓
Data Quality Layer (Great Expectations)
↓
Orchestration Layer (Dagster)
↓
Analytics & BI (Looker Studio / Python)
```

### 🔹 Physical Architecture (GCP)

```text
CSV Files
↓
Meltano (tap-csv → target-bigquery)
↓
BigQuery (olist_raw)
↓
dbt (staging → marts)
↓
BigQuery (olist_analytics)
↓
Great Expectations validation
↓
Looker Studio Dashboard
```

---

## 🧱 Tech Stack


- **Ingestion**: Meltano  
- **Data Warehouse**: BigQuery  
- **Transformation**: dbt  
- **Data Quality**: Great Expectations  
- **Orchestration**: Dagster (optional)  
- **BI Tool**: Looker Studio  
- **Language**: SQL, Python  
- **Environment**: VS Code, Conda  

---

## 📂 Project Structure

```text
olist-analytics-platform/
│
├── ingestion/ # Meltano EL layer
├── warehouse/ # Schema documentation
├── transformation/ # dbt models (staging → marts)
├── data_quality/ # Great Expectations
├── orchestration/ # Dagster pipelines
├── analytics/ # Python analysis
├── docs/ # Architecture diagrams
├── data/ # Local datasets
├── config/ # Environment configs
├── tests/ # Cross-layer tests
│
├── README.md
├── requirements.txt
├── .gitignore
└── docker-compose.yml
```


---

## 🧠 Data Modeling (Star Schema)

### ⭐ Fact Tables

- `fct_order_items` → (grain: 1 row per order item)  
- `fct_orders` → (grain: 1 row per order)  
- `fct_payments` → (grain: 1 row per payment) 
- `fct_reviews` → (grain: 1 row per review) 

### ⭐ Dimension Tables

- `dim_customers`  
- `dim_products`  
- `dim_sellers`  
- `dim_dates`  

### 🧩 Key Design Concepts

- Grain-first modeling (Kimball method)
- Degenerate dimensions → `order_id`, `review_id`
- Separation of grains across fact tables
- Reusable dimensions across facts (fact constellation)

---

## 🔄 Data Pipeline

### 1️⃣ Ingestion (Meltano → BigQuery)

```bash
cd ingestion
meltano run tap-csv target-bigquery
```

### 2️⃣ Transformation (dbt)

```bash
cd transformation/olist_dbt
dbt run
dbt test
```

### 3️⃣ Data Quality (Great Expectations)

```bash
cd ~/olist-analytics-platform
python data_quality/run_ge_validation.py
```

### 4️⃣ (Optional) Orchestration (Dagster)

```bash
dagster dev -f orchestration/olist_dagster_job.py
```

## 📊 BI Dashboard (Looker Studio)

🔗 **Dashboard Link**  
https://lookerstudio.google.com/reporting/5db17733-75bf-47d6-be43-3b62942b40be

---

### 🟦 Section 1 — Executive KPI Overview

- Total Revenue  
- Total Orders  
- Average Order Value (AOV)  
- Average Delivery Delay  
- Customer Satisfaction Score

---

### 🟩 Section 2 — Business Growth

- Monthly Revenue Trend
- Order Volume Trend

---

### 🟥 Section 3 — Operations & Customer Experience

- Delivery Delay vs Review Score (Scatter Analysis)
- Revenue by Product Category (Top Categories Contribution)
- Number of Product Categories (Product Diversity Indicator)

---

## 🔍 Key Business Insights

- 📈 Revenue demonstrates a consistent upward growth trend over time
- ⚡ A significant spike in late 2017 suggests seasonal or promotional impact
- 🚚 Delivery delays are negatively correlated with customer satisfaction
- 🛍️ Revenue is highly concentrated in a small number of top-performing categories
- 📦 The business spans ~70 product categories, indicating strong catalog diversity

---

## ⚠️ Challenges & Debugging

### ⏱️ Extractor Timeout Issue (Meltano)

During data ingestion, the pipeline encountered timeout issues when extracting large CSV datasets using Meltano.

#### ❌ Impact

- Extraction jobs occasionally failed or stalled  
- Increased pipeline runtime and instability  
- Required manual reruns to complete ingestion  

#### 🔍 Root Cause

- Default extractor timeout settings were insufficient for large file sizes  
- Network and I/O latency contributed to delays during extraction  

#### ✅ Solution

- Increased timeout and retry settings in the Meltano configuration  
- Executed extraction in smaller batches where necessary  
- Ensured stable local environment during ingestion runs  

#### 💡 Outcome

- Improved pipeline reliability and stability  
- Reduced need for manual intervention  
- Enabled consistent ingestion of large datasets  

---

### 🔥 Hidden Encoding Issue (Critical Data Bug)

A **Byte Order Mark (BOM)** introduced a hidden character in the raw JSON key:

```text
"﻿product_category_name"
```

### ❌ Impact

- Failed joins in `dim_products`  
- Missing category data in BI layer  
- Inaccurate aggregation for category-level metrics  

---

### ✅ Solution

Handled explicitly during JSON parsing in dbt:

```sql
json_value(data, '$.﻿product_category_name') as product_category_name
```

✔ Restored correct joins between product and category tables  
✔ Recovered missing category-level analytics in BI dashboard  
✔ Prevented silent data inconsistencies in downstream models  

---

## 🎯 Learning Outcomes

This project demonstrates:

- End-to-end data platform architecture (ingestion → warehouse → transformation → BI)  
- Cloud data warehousing using BigQuery  
- Analytics engineering with dbt (staging → marts modeling)  
- Data quality validation using Great Expectations  
- Debugging real-world data issues:
  - Hidden encoding issues (BOM) affecting joins  
  - Extractor timeout issues during large-scale ingestion  
- Dimensional modeling (4 fact + 4 dimension tables) using Kimball principles  
- BI storytelling and dashboard design for business decision-making  
- Pipeline reliability improvement through configuration tuning and error handling  

---

## 🔐 Security

Sensitive files such as `.env` and service account keys are excluded from version control.
Please use `.env.example` as a template.

---

## 🚀 Future Improvements

- Streamlit custom BI dashboard layer (interactive analytics application)  
- dbt Semantic Layer for centralized metric definitions  
- Incremental dbt models for idempotent and scalable pipelines  
- Cloud deployment (Render / GCP services)  
- Revenue forecasting using machine learning models  
- API layer (FastAPI) for analytics serving  
- Orchestration enhancement with Dagster (production scheduling & monitoring)  

---

## 💡 Portfolio / Interview Summary

Built a **production-style end-to-end data platform** using Meltano, BigQuery, dbt, and Looker Studio to transform raw e-commerce data into actionable business insights.

Designed a **dimensional data warehouse (4 fact + 4 dimension tables)** following Kimball modeling principles, enabling scalable and efficient analytics.

Diagnosed and resolved multiple real-world pipeline issues, including:
- A **hidden encoding issue (BOM)** that broke dimension joins and caused missing BI data  
- An **extractor timeout issue** during large-scale ingestion, requiring configuration tuning and pipeline stabilization  

These demonstrate strong debugging capability and the ability to trace and resolve issues across the full data pipeline from ingestion to BI layer.

---

## 📌 Author

**Cheung KH**  
Aspiring AI Engineer / Data Engineer  