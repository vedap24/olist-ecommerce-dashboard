# Olist E-Commerce Dashboard Project

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql) ![Tableau](https://img.shields.io/badge/Tableau-Public-orange?logo=tableau) ![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

End-to-end SQL + Tableau e-commerce analytics project built using the Olist Brazilian E-Commerce dataset.

## Project Overview
This project analyzes the Olist Brazilian E-Commerce dataset using MySQL and Tableau.  
The workflow covers data loading, validation, business analysis, and dashboard development to generate actionable insights across revenue, customers, delivery performance, and product categories.

## Tools & Technologies
- MySQL
- SQL
- Tableau
- GitHub
- Kaggle Olist Dataset

## Project Workflow
1. Downloaded the Olist dataset from Kaggle
2. Loaded 9 CSV files into MySQL
3. Performed data validation and quality checks
4. Wrote SQL queries for KPIs and business analysis
5. Built Tableau dashboards for executive, customer/revenue, and operations insights
6. Exported dashboards and documented the project in GitHub

## Repository Structure
- `dashboards/` – Tableau workbook, story presentation, and exported dashboard images
- `sql/01_table_creation.sql` – SQL statements used to create all required tables
- `sql/02_data_loading.sql` – CSV loading scripts using `LOAD DATA LOCAL INFILE`
- `sql/03_data_validation.sql` – Data quality checks including null checks, duplicate checks, and referential integrity validation
- `sql/04_analysis_queries.sql` – Business analysis queries for KPIs, customer distribution, revenue trends, delivery performance, and category insights
- `README.md` – Project documentation

## Dashboards

### 1. Executive Overview
Shows the key business KPIs including total revenue, total orders, average order value, on-time delivery percentage, and average review score.

![Executive Overview](dashboards/dashboard-1-executive-overview.png)

### 2. Customer & Revenue Analysis
Highlights customer distribution by state and monthly revenue trends, including the Black Friday peak in November 2017.

![Customer & Revenue Analysis](dashboards/dashboard-2-customer-revenue-analysis.png)

### 3. Operations Dashboard
Focuses on late delivery rate by state and top product categories by revenue to identify operational and category-level performance patterns.

![Operations Dashboard](dashboards/dashboard-3-operations-dashboard.png)

## Files Included
- Tableau workbook: (dashboards/Olist_Ecommerce.twbx)
- Story presentation: (dashboards/Olist_Ecommerce_Story.pptx)
- Exported dashboard PNGs
- SQL scripts for schema creation, data loading, validation, and analysis

## Key Insights
- Total revenue exceeded 13.2M across the dataset period.
- Sao Paulo contributed the highest share of customers.
- Revenue peaked in November 2017 during Black Friday.
- On-time delivery performance was strong overall, but some states showed higher late delivery rates.
- Health & Beauty and Watches & Gifts were among the top revenue-generating product categories.

## Dataset
Source: [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The dataset includes customers, orders, products, sellers, payments, reviews, and geolocation data.

## Notes
All SQL scripts used for table creation, data loading, validation, and business analysis are included in the `sql/` folder.
