# Olist E-Commerce Dashboard Project

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql) ![Tableau](https://img.shields.io/badge/Tableau-Public-orange?logo=tableau) ![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

End-to-end data analytics project using the **Olist Brazilian E-Commerce** public dataset.  
Raw CSV files were loaded into MySQL, cleaned, modeled into a star schema, analyzed with advanced SQL, and visualized in Tableau — built as a portfolio-ready showcase of the full analytics workflow.

---

## Tools & Technologies

| Layer | Tool |
|---|---|
| Data Storage | MySQL 8.0 |
| Data Analysis | SQL (Window Functions, CTEs, Aggregations) |
| Visualization | Tableau Desktop / Tableau Public |
| Dataset | Kaggle — Olist Brazilian E-Commerce (9 CSV files) |
| Version Control | GitHub |

---

## Project Workflow

1. **Data Loading** — Imported 9 raw CSV files into MySQL using `LOAD DATA LOCAL INFILE`
2. **Data Cleaning & Validation** — Checked for nulls, duplicates, and referential integrity across all tables
3. **Exploratory Data Analysis (EDA)** — Analyzed revenue trends, geography, product performance, delivery, and customer satisfaction
4. **Data Modeling** — Built a Star Schema (fact + dimension tables) optimized for reporting
5. **Business Problem Solving** — Wrote 5 targeted SQL queries addressing real business questions
6. **KPI Building** — Calculated 6 core KPIs: Revenue, AOV, On-Time Delivery Rate, Review Score, Repeat Rate, Late Delivery %
7. **Tableau Dashboards** — Built 3 interactive dashboards with a Story narrative
8. **Portfolio Documentation** — Structured and published on GitHub

```
All SQL scripts used for data loading, cleaning, validation, KPI creation, and analysis are included in the `sql/` folder.
```
---

## Repository Structure

```
olist-ecommerce-dashboard/
├── sql/
│   ├── 01_data_loading.sql          # Load 9 CSV files into MySQL
│   ├── 02_data_cleaning.sql         # Null checks, duplicate detection, integrity validation
│   ├── 03_analysis_queries.sql      # EDA + Business problem queries + KPI calculations
│   └── 04_star_schema.sql           # Fact & dimension table creation
├── dashboards/
│   ├── olist_dashboard.twbx         # Tableau packaged workbook
│   ├── dashboard_export.pdf         # Static PDF export
│   └── screenshots/                 # Dashboard preview images
└── README.md
```

> **Note:** Raw CSV data files are excluded from this repository. Download the dataset from [Kaggle — Olist E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

---

## Key Insights

- **Total Revenue:** R$ 13.2M+ across ~99K orders (2016–2018)
- **Top State:** São Paulo accounts for the majority of customers and revenue
- **Revenue Peak:** November 2017 Black Friday drove the single largest monthly spike
- **Top Categories:** Health & Beauty and Watches & Gifts lead in revenue
- **On-Time Delivery:** ~92% of orders delivered on time overall
- **Late Delivery Hotspots:** States like Amapá and Roraima show significantly higher delay rates
- **Review Score:** Average of ~4.09 / 5.0 across all delivered orders

---

## Dashboards

### 1. Executive Overview
High-level KPI scorecards: Total Revenue, Total Orders, AOV, On-Time Delivery Rate, and Avg Review Score.

### 2. Customer & Revenue Analysis
Geographic breakdown by state, monthly revenue trend line, and Black Friday peak identification.

### 3. Operations Dashboard
Late delivery rate by state (map), top revenue categories (bar), and order status distribution.

---

## Data Model — Star Schema

```
                    dim_customers
                         |
fact_orders ── dim_products ── dim_sellers
                         |
                    dim_dates
```

`fact_orders` is the central fact table joining all dimensions on `order_id`, `customer_id`, `product_id`, and `seller_id`.

---

## Dataset

- **Source:** [Kaggle — Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Size:** 9 CSV files, ~100K orders, 2016–2018
- **Tables:** customers, orders, order_items, order_payments, order_reviews, products, sellers, geolocation, product_category_name_translation

---

## Author

**Veda Praneeth** — Data Analyst  
[GitHub: vedap24](https://github.com/vedap24)
