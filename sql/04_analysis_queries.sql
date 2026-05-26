-- KPI Queries
-- Revenue Trend Queries
-- Customer Analysis Queries
-- Operations Analysis Queries

-- ============================================================
-- STEP 4: EDA - EXPLORATORY DATA ANALYSIS
-- Olist Brazilian E-Commerce Dataset
-- ============================================================

-- EDA Theme 1 — Order Trends Over Time

-- EDA 1.1: Total orders per year
SELECT 
  YEAR(order_purchase_timestamp) AS order_year,
  COUNT(*) AS total_orders
FROM olist_orders
GROUP BY order_year
ORDER BY order_year;

-- EDA 1.2: Monthly order volume trend
SELECT 
  DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
  COUNT(*) AS total_orders
FROM olist_orders
GROUP BY order_month
ORDER BY order_month;

-- EDA 1.2 Key Insights:
-- 1. Consistent growth from Jan 2017 (800) to Aug 2018 (6,512)
-- 2. Nov 2017 spike (7,544) = Black Friday / seasonal sales peak
-- 3. Sep-Oct 2018 data is incomplete (16 and 4 orders) — dataset cutoff
--    Exclude 2018-09 and 2018-10 from any trend/time-series analysis

-- EDA 1.3: Orders by day of week
SELECT 
  DAYNAME(order_purchase_timestamp) AS day_of_week,
  COUNT(*) AS total_orders
FROM olist_orders
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');

-- EDA 1.3 Key Insight:
-- Peak shopping days: Monday (16,196) > Tuesday > Wednesday
-- Lowest: Saturday (10,887)
-- Implication: Schedule promotions/email campaigns on Mon-Wed for max impact

-- EDA Theme 2 — Customer Behavior

-- EDA 2.1: Top 10 states by customer count
SELECT 
  customer_state,
  COUNT(*) AS total_customers
FROM olist_customer
GROUP BY customer_state
ORDER BY total_customers DESC
LIMIT 10;

-- EDA 2.1 Key Insight:
-- Top 3 states (SP, RJ, MG) = ~67% of all customers
-- SP alone = 42% of total customer base
-- Implication: Southeast Brazil is the core market — prioritize logistics and marketing here

-- EDA 2.2: Repeat vs one-time customers
SELECT 
  order_count,
  COUNT(*) AS num_customers
FROM (
  SELECT 
    customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count
  FROM olist_customer c
  JOIN olist_orders o ON c.customer_id = o.customer_id
  GROUP BY customer_unique_id
) AS customer_orders
GROUP BY order_count
ORDER BY order_count;

-- EDA 2.2 Key Insight:
-- ~97% of customers (93,099) placed only 1 order — extremely low retention
-- Only ~3% of customers are repeat buyers
-- CRITICAL business problem: Olist is heavily dependent on new customer acquisition
-- Recommended KPI to track: Repeat Purchase Rate, Customer Retention Rate
-- Potential business action: Loyalty programs, post-purchase email campaigns

-- EDA Theme 3 — Product & Category Performance

-- EDA 3.1: Top 10 product categories by order volume
SELECT 
  t.product_category_name_english AS category,
  COUNT(oi.order_id) AS total_orders
FROM olist_order_items oi
JOIN olist_products p ON oi.product_id = p.product_id
JOIN product_category_name_translation t 
  ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY total_orders DESC
LIMIT 10;

-- EDA 3.1 Key Insight:
-- Top category: bed_bath_table (11,115 orders)
-- Home & lifestyle categories dominate the top 10
-- Health & beauty (#2) has high repeat purchase potential
-- Tech categories present but not dominant — Olist is a lifestyle marketplace

-- EDA 3.2: Top 10 categories by revenue
SELECT 
  t.product_category_name_english AS category,
  ROUND(SUM(oi.price), 2) AS total_revenue
FROM olist_order_items oi
JOIN olist_products p ON oi.product_id = p.product_id
JOIN product_category_name_translation t 
  ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;

-- EDA 3.2 Key Insight:
-- health_beauty = #1 revenue AND #2 volume = STAR category
-- watches_gifts = #7 volume but #2 revenue = HIGH avg price category
-- bed_bath_table = #1 volume but #3 revenue = high volume, low price
-- cool_stuff = not top 10 in orders but top 10 in revenue = hidden high-value niche
-- Implication: Prioritize health_beauty and watches_gifts for revenue-focused KPIs

-- EDA Theme 4 — Delivery Performance

-- EDA 4.1: Average delivery time — estimated vs actual
SELECT
  ROUND(AVG(DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp)), 1) 
    AS avg_estimated_days,
  ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 1) 
    AS avg_actual_days,
  ROUND(AVG(DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date)), 1) 
    AS avg_days_early_or_late
FROM olist_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

-- EDA 4.1 Key Insight:
-- Avg estimated delivery: 24.4 days from purchase
-- Avg actual delivery: 12.5 days from purchase
-- Avg days delivered EARLY: +11.9 days
-- Olist consistently delivers ~12 days ahead of estimate = strong delivery performance
-- Possible strategy: Deliberate over-estimation to ensure positive customer experience
-- Follow-up: Check if early delivery correlates with higher review scores (EDA 5)

-- EDA 4.2: On-time vs late delivery rate
SELECT
  COUNT(*) AS total_delivered,
  SUM(CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date 
      THEN 1 ELSE 0 END) AS on_time,
  SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date 
      THEN 1 ELSE 0 END) AS late,
  ROUND(100.0 * SUM(CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date 
      THEN 1 ELSE 0 END) / COUNT(*), 1) AS on_time_pct,
  ROUND(100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date 
      THEN 1 ELSE 0 END) / COUNT(*), 1) AS late_pct
FROM olist_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

-- EDA 4.2 Key Insight:
-- On-time delivery rate: 91.9% (88,652 of 96,478 delivered orders)
-- Late deliveries: 8.1% (7,826 orders)
-- Strong performance for a large geographically diverse country like Brazil
-- KPI: On-Time Delivery Rate — target >90%, currently at 91.9% (PASSING)
-- Follow-up: Check if late deliveries directly cause low review scores (EDA 5)

-- EDA Theme 5 — Review & Satisfaction Analysis

-- EDA 5.1: Review score by delivery status (on-time vs late)
SELECT
  CASE 
    WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date 
    THEN 'On Time'
    ELSE 'Late'
  END AS delivery_status,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  COUNT(*) AS total_orders
FROM olist_orders o
JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;

-- EDA 5.1 Key Insight — MOST IMPORTANT FINDING:
-- On-time delivery → avg review score: 4.30/5
-- Late delivery → avg review score: 2.57/5
-- Score drop of 1.73 points purely due to late delivery
-- CONCLUSION: Late delivery is the #1 driver of negative reviews on Olist
-- Business action: Every 1% improvement in on-time delivery = direct improvement in CSAT
-- This is a KPI-level and dashboard-level finding

-- EDA 5.2: Review score distribution
SELECT
  review_score,
  COUNT(*) AS total_reviews,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 1) AS pct
FROM olist_order_reviews
GROUP BY review_score
ORDER BY review_score DESC;

-- EDA 5.2 Key Insight:
-- 77.1% reviews are 4-5 stars = healthy overall satisfaction
-- 1-star reviews = 11.5% — higher than 2-star (3.2%) = classic J-curve pattern
-- 1-star spike strongly correlates with 8.1% late delivery rate (EDA 4.2 + 5.1)
-- Overall CSAT is positive but 1-star rate needs attention via delivery improvement

/*
✅ Theme 1: Order Trends     → 20% YoY growth, Nov 2017 Black Friday spike, Mon-Wed peak days
✅ Theme 2: Customer Behavior → 97% one-time buyers, SP/RJ/MG = 67% of customers
✅ Theme 3: Product & Category → health_beauty = star category, watches_gifts = high value
✅ Theme 4: Delivery Performance → 91.9% on-time, 12 days avg ahead of estimate
✅ Theme 5: Reviews & Satisfaction → Late delivery = 2.57 vs on-time = 4.30 avg score
*/

-- ============================================================
-- STEP 5: DATA MODELING
-- Star Schema Design for Olist E-Commerce Analytics
-- ============================================================

-- Step 5.1: Create dim_date table
CREATE TABLE dim_date AS
SELECT DISTINCT
  DATE(order_purchase_timestamp) AS date_id,
  YEAR(order_purchase_timestamp) AS year,
  MONTH(order_purchase_timestamp) AS month,
  MONTHNAME(order_purchase_timestamp) AS month_name,
  QUARTER(order_purchase_timestamp) AS quarter,
  DAYNAME(order_purchase_timestamp) AS day_of_week,
  DAY(order_purchase_timestamp) AS day
FROM olist_orders;

SELECT COUNT(*) FROM dim_date;
SELECT * FROM dim_date LIMIT 5;

-- Step 5.2: Create dim_customers
CREATE TABLE dim_customers AS
SELECT DISTINCT
  c.customer_id,
  c.customer_unique_id,
  c.customer_city,
  c.customer_state
FROM olist_customer c;

SELECT COUNT(*) FROM dim_customers;
SELECT * FROM dim_customers LIMIT 3;

-- Step 5.3: Create dim_sellers
CREATE TABLE dim_sellers AS
SELECT DISTINCT
  seller_id,
  seller_city,
  seller_state
FROM olist_sellers;

SELECT COUNT(*) FROM dim_sellers;
SELECT * FROM dim_sellers LIMIT 3;

-- Step 5.4: Create dim_products
CREATE TABLE dim_products AS
SELECT DISTINCT
  p.product_id,
  COALESCE(t.product_category_name_english, 'uncategorized') AS category_english,
  p.product_weight_g,
  p.product_photos_qty
FROM olist_products p
LEFT JOIN product_category_name_translation t
  ON p.product_category_name = t.product_category_name;

SELECT COUNT(*) FROM dim_products;
SELECT * FROM dim_products LIMIT 3;

-- Step 5.5: Create fact_orders (central fact table)
CREATE TABLE fact_orders AS
SELECT
  oi.order_id,
  oi.order_item_id,
  o.customer_id,
  oi.product_id,
  oi.seller_id,
  DATE(o.order_purchase_timestamp) AS order_date_id,
  o.order_status,
  oi.price,
  oi.freight_value,
  (oi.price + oi.freight_value) AS total_order_value,
  COALESCE(p.payment_value, 0) AS payment_value,
  COALESCE(r.review_score, 0) AS review_score,
  DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) 
    AS actual_delivery_days,
  DATEDIFF(o.order_estimated_delivery_date, o.order_purchase_timestamp) 
    AS estimated_delivery_days,
  CASE 
    WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date 
    THEN 0 ELSE 1 
  END AS is_late
FROM olist_order_items oi
JOIN olist_orders o ON oi.order_id = o.order_id
LEFT JOIN olist_order_payments p ON oi.order_id = p.order_id
  AND p.payment_sequential = 1
LEFT JOIN olist_order_reviews r ON oi.order_id = r.order_id;


SELECT COUNT(*) FROM fact_orders;
SELECT * FROM fact_orders LIMIT 3;

-- ============================================================
-- STEP 6: BUSINESS PROBLEM SOLVING
-- Real business questions answered using fact_orders + dims
-- ============================================================

-- Business Problem 1: Top 10 sellers with worst late delivery rate
-- (min 50 orders to be statistically meaningful)
SELECT
  f.seller_id,
  s.seller_city,
  s.seller_state,
  COUNT(*) AS total_orders,
  SUM(f.is_late) AS late_orders,
  ROUND(100.0 * SUM(f.is_late) / COUNT(*), 1) AS late_rate_pct,
  ROUND(AVG(f.review_score), 2) AS avg_review_score
FROM fact_orders f
JOIN dim_sellers s ON f.seller_id = s.seller_id
WHERE f.order_status = 'delivered'
GROUP BY f.seller_id, s.seller_city, s.seller_state
HAVING COUNT(*) >= 50
ORDER BY late_rate_pct DESC
LIMIT 10;

-- Business Problem 1 Insight:
-- Worst seller late rate: 32.1% (foz do iguacu, PR) — avg review 2.88
-- São Luís seller: 403 orders, 23.6% late = highest absolute impact
-- Business action: Sellers with late_rate > 20% should be flagged for SLA review
-- Strong correlation confirmed: high late rate = low avg review score

-- Business Problem 2: Revenue per order by category
SELECT
  dp.category_english,
  COUNT(DISTINCT f.order_id) AS total_orders,
  ROUND(SUM(f.price), 2) AS total_revenue,
  ROUND(AVG(f.price), 2) AS avg_revenue_per_item,
  ROUND(AVG(f.review_score), 2) AS avg_review_score
FROM fact_orders f
JOIN dim_products dp ON f.product_id = dp.product_id
WHERE f.order_status = 'delivered'
GROUP BY dp.category_english
ORDER BY avg_revenue_per_item DESC
LIMIT 10;

-- Business Problem 2 Insight:
-- Highest avg price: computers (R$1,099) — low volume but premium
-- Best balance of volume + price: watches_gifts (5,495 orders, R$199 avg)
-- watches_gifts = R$1.16M total revenue = Olist's best scalable category
-- fixed_telephony has low review score (3.71) despite decent price — investigate
-- Business action: Prioritize watches_gifts expansion + grow computers seller base

-- Business Problem 3: Monthly revenue trend
SELECT
  d.year,
  d.month,
  d.month_name,
  COUNT(DISTINCT f.order_id) AS total_orders,
  ROUND(SUM(f.price), 2) AS total_revenue,
  ROUND(AVG(f.price), 2) AS avg_order_value
FROM fact_orders f
JOIN dim_date d ON f.order_date_id = d.date_id
WHERE f.order_status = 'delivered'
  AND NOT (d.year = 2018 AND d.month >= 9)
  AND NOT (d.year = 2016)
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- Business Problem 3 Insight:
-- 2017 revenue growth: R$112K (Jan) → R$990K (Nov) — 9x in one year
-- 2018 avg monthly revenue: ~R$903K (+81% YoY vs 2017)
-- Nov 2017 Black Friday = biggest revenue month
-- AOV stable at R$109-R$133 throughout — growth is volume-driven, not price-driven
-- Business action: To grow revenue, focus on AOV increase (upsell/bundles) OR volume growth

-- Business Problem 4: Late delivery rate by customer state
SELECT
  dc.customer_state,
  COUNT(*) AS total_orders,
  SUM(f.is_late) AS late_orders,
  ROUND(100.0 * SUM(f.is_late) / COUNT(*), 1) AS late_rate_pct,
  ROUND(AVG(f.actual_delivery_days), 1) AS avg_actual_days
FROM fact_orders f
JOIN dim_customers dc ON f.customer_id = dc.customer_id
WHERE f.order_status = 'delivered'
GROUP BY dc.customer_state
ORDER BY late_rate_pct DESC
LIMIT 10;

-- Business Problem 4 Insight:
-- Worst late delivery states: AL (24.2%), MA (20.3%), SE (16.3%) — ALL Northeast Brazil
-- Clear regional logistics problem: Northeast is far from SP seller hub
-- RJ = highest absolute late orders (1,841) despite only 13% rate
-- PA = slowest avg delivery (23.7 days) — Amazon region isolation
-- Business action: Invest in regional logistics/fulfillment centers in Northeast Brazil

-- Business Problem 5: Revenue from repeat vs one-time customers
SELECT
  CASE 
    WHEN order_count = 1 THEN 'One-time Customer'
    ELSE 'Repeat Customer'
  END AS customer_type,
  COUNT(*) AS num_customers,
  ROUND(SUM(total_revenue), 2) AS total_revenue,
  ROUND(100.0 * SUM(total_revenue) / SUM(SUM(total_revenue)) OVER(), 1) AS revenue_pct
FROM (
  SELECT
    c.customer_unique_id,
    COUNT(DISTINCT f.order_id) AS order_count,
    SUM(f.price) AS total_revenue
  FROM fact_orders f
  JOIN dim_customers c ON f.customer_id = c.customer_id
  WHERE f.order_status = 'delivered'
  GROUP BY c.customer_unique_id
) AS customer_summary
GROUP BY customer_type
ORDER BY revenue_pct DESC;

-- Business Problem 5 Insight — CRITICAL FINDING:
-- 94.4% of revenue from one-time customers — extreme dependency on new acquisition
-- Only 5.6% revenue from repeat customers (2,801 customers)
-- Business risk: Revenue collapses if new customer acquisition slows
-- Opportunity: Converting 10% of one-time buyers to repeat = ~R$1.25M extra revenue
-- Business action: Launch loyalty program, post-purchase campaigns, personalized recommendations

-- ============================================================
-- STEP 7: ADVANCED SQL ANALYSIS
-- Window functions, CTEs, cohort analysis, rankings
-- ============================================================

-- Advanced 1: Month-over-Month revenue growth rate using LAG
WITH monthly_revenue AS (
  SELECT
    d.year,
    d.month,
    d.month_name,
    ROUND(SUM(f.price), 2) AS revenue
  FROM fact_orders f
  JOIN dim_date d ON f.order_date_id = d.date_id
  WHERE f.order_status = 'delivered'
    AND NOT (d.year = 2018 AND d.month >= 9)
    AND NOT (d.year = 2016)
  GROUP BY d.year, d.month, d.month_name
)
SELECT
  year,
  month,
  month_name,
  revenue,
  LAG(revenue) OVER (ORDER BY year, month) AS prev_month_revenue,
  ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY year, month))
    / LAG(revenue) OVER (ORDER BY year, month), 1) AS mom_growth_pct
FROM monthly_revenue
ORDER BY year, month;

-- Advanced 1 Insight:
-- LAG() used to calculate Month-over-Month revenue growth
-- 2017: High volatility (109.8% to -26.6%) = hypergrowth phase
-- Nov 2017 Black Friday: +52.4% MoM spike
-- 2018: Growth stabilizing (-13% to +15% range) = maturity phase
-- Aug 2018: -3.5% — business growth stalling, needs new growth lever

-- Advanced 2: Cumulative revenue over time using SUM OVER
WITH monthly_revenue AS (
  SELECT
    d.year,
    d.month,
    d.month_name,
    ROUND(SUM(f.price), 2) AS revenue
  FROM fact_orders f
  JOIN dim_date d ON f.order_date_id = d.date_id
  WHERE f.order_status = 'delivered'
    AND NOT (d.year = 2018 AND d.month >= 9)
    AND NOT (d.year = 2016)
  GROUP BY d.year, d.month, d.month_name
)
SELECT
  year,
  month,
  month_name,
  revenue,
  ROUND(SUM(revenue) OVER (ORDER BY year, month), 2) AS cumulative_revenue
FROM monthly_revenue
ORDER BY year, month;

-- Advanced 2 Insight:
-- SUM() OVER() used for cumulative/running total revenue
-- R$1M milestone: Apr 2017 | R$5M: Nov 2017 | R$10M: Apr 2018
-- Total revenue Jan 2017 - Aug 2018: R$13.2M
-- First R$5M = 11 months | Next R$5M = 6 months — pace accelerating
-- Use this as a line chart in Tableau dashboard

-- Advanced 3: Top 3 sellers by revenue per year using RANK()
WITH seller_revenue AS (
  SELECT
    d.year,
    f.seller_id,
    s.seller_state,
    ROUND(SUM(f.price), 2) AS revenue,
    RANK() OVER (PARTITION BY d.year ORDER BY SUM(f.price) DESC) AS revenue_rank
  FROM fact_orders f
  JOIN dim_date d ON f.order_date_id = d.date_id
  JOIN dim_sellers s ON f.seller_id = s.seller_id
  WHERE f.order_status = 'delivered'
    AND NOT (d.year = 2016)
  GROUP BY d.year, f.seller_id, s.seller_state
)
SELECT *
FROM seller_revenue
WHERE revenue_rank <= 3
ORDER BY year, revenue_rank;

-- Advanced 3 Insight:
-- RANK() OVER (PARTITION BY year) used to rank sellers within each year
-- 2017 top seller: BA state (R$177K) — surprising Northeast dominance
-- 2018 top 3: All SP sellers (R$112K–R$136K)
-- No seller in top 3 both years = healthy seller competition, no monopoly
-- Revenue spreading across more sellers in 2018 = growing marketplace diversity

SET SESSION wait_timeout = 600;
SET SESSION interactive_timeout = 600;
SET SESSION net_read_timeout = 600;
SET SESSION net_write_timeout = 600;

-- Advanced 4: Customer cohort analysis — first purchase month
WITH first_orders AS (
  SELECT
    c.customer_unique_id,
    MIN(DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')) AS cohort_month
  FROM olist_orders o
  JOIN olist_customer c ON o.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
),
customer_orders AS (
  SELECT
    c.customer_unique_id,
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month
  FROM olist_orders o
  JOIN olist_customer c ON o.customer_id = c.customer_id
)
SELECT
  f.cohort_month,
  COUNT(DISTINCT f.customer_unique_id) AS cohort_size,
  COUNT(DISTINCT CASE WHEN co.order_month > f.cohort_month 
    THEN co.customer_unique_id END) AS returned_customers,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN co.order_month > f.cohort_month 
    THEN co.customer_unique_id END) 
    / COUNT(DISTINCT f.customer_unique_id), 1) AS retention_pct
FROM first_orders f
LEFT JOIN customer_orders co ON f.customer_unique_id = co.customer_unique_id
GROUP BY f.cohort_month
ORDER BY f.cohort_month
LIMIT 15;

-- Step 1: Save first order month per customer
CREATE TABLE cohort_base AS
SELECT
  c.customer_unique_id,
  MIN(DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')) AS cohort_month
FROM olist_orders o
JOIN olist_customer c ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id;

SELECT COUNT(*) FROM cohort_base;

-- Step 2: Cohort retention analysis using cohort_base table
SELECT
  cb.cohort_month,
  COUNT(DISTINCT cb.customer_unique_id) AS cohort_size,
  COUNT(DISTINCT CASE 
    WHEN DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') > cb.cohort_month 
    THEN cb.customer_unique_id 
  END) AS returned_customers,
  ROUND(100.0 * COUNT(DISTINCT CASE 
    WHEN DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') > cb.cohort_month 
    THEN cb.customer_unique_id 
  END) / COUNT(DISTINCT cb.customer_unique_id), 1) AS retention_pct
FROM cohort_base cb
LEFT JOIN olist_customer c ON cb.customer_unique_id = c.customer_unique_id
LEFT JOIN olist_orders o ON c.customer_id = o.customer_id
GROUP BY cb.cohort_month
ORDER BY cb.cohort_month
LIMIT 15;

-- Advanced 4 Insight: Cohort Retention Analysis
-- All cohorts show 1.7% to 4.3% retention — consistently extremely low
-- Nov 2017 (Black Friday cohort, 7,304 customers): only 1.9% returned
--   Deal-hunters from promotions have worst loyalty
-- Early 2017 cohorts slightly better retention (organic early adopters)
-- Confirms Business Problem 5: customer retention is the #1 business challenge
-- Tableau: Use this data for a cohort heatmap visualization

-- ============================================================
-- STEP 8: KPI BUILDING
-- Single-number metrics that go directly onto the dashboard
-- ============================================================

-- KPI Building: All 6 core KPIs for Olist dashboard
SELECT

  -- KPI 1: Total Revenue
  ROUND(SUM(f.price), 2) AS total_revenue,

  -- KPI 2: Total Orders
  COUNT(DISTINCT f.order_id) AS total_orders,

  -- KPI 3: Average Order Value (AOV)
  ROUND(SUM(f.price) / COUNT(DISTINCT f.order_id), 2) AS avg_order_value,

  -- KPI 4: On-Time Delivery Rate
  ROUND(100.0 * SUM(CASE WHEN f.is_late = 0 THEN 1 ELSE 0 END)
    / COUNT(DISTINCT f.order_id), 1) AS on_time_delivery_pct,

  -- KPI 5: Average Review Score (CSAT)
  ROUND(AVG(CASE WHEN f.review_score > 0 THEN f.review_score END), 2)
    AS avg_review_score,

  -- KPI 6: Customer Retention Rate
  ROUND(100.0 * SUM(CASE WHEN f.review_score > 0 THEN 1 ELSE 0 END)
    / COUNT(DISTINCT f.order_id), 1) AS review_coverage_pct

FROM fact_orders f
WHERE f.order_status = 'delivered';


-- KPI Building (Fixed): Aggregate at order level first
WITH order_level AS (
  SELECT
    order_id,
    MAX(is_late) AS is_late,
    MAX(CASE WHEN review_score > 0 THEN review_score END) AS review_score,
    SUM(price) AS order_revenue
  FROM fact_orders
  WHERE order_status = 'delivered'
  GROUP BY order_id
)
SELECT
  ROUND(SUM(order_revenue), 2) AS total_revenue,
  COUNT(order_id) AS total_orders,
  ROUND(AVG(order_revenue), 2) AS avg_order_value,
  ROUND(100.0 * SUM(CASE WHEN is_late = 0 THEN 1 ELSE 0 END)
    / COUNT(order_id), 1) AS on_time_delivery_pct,
  ROUND(AVG(CASE WHEN review_score > 0 THEN review_score END), 2)
    AS avg_review_score,
  ROUND(100.0 * SUM(CASE WHEN review_score IS NOT NULL THEN 1 ELSE 0 END)
    / COUNT(order_id), 1) AS review_coverage_pct
FROM order_level;

-- KPI Summary — Olist Dashboard Headline Metrics
-- Total Revenue:         R$13,248,393
-- Total Orders:          96,478 (delivered)
-- Avg Order Value (AOV): R$137.32
-- On-Time Delivery Rate: 91.9%  ← Target: >90% ✅
-- Avg Review Score:      4.16/5 ← Target: >4.0 ✅
-- Review Coverage:       98.9%  ← Near-complete ✅
-- Note: Customer Retention Rate (~3%) = key improvement area


-- ===========================================================
-- Step 9
-- ===========================================================
-- For this chart, monthly revenue should usually come from joining olist_orders with olist_order_payments, then grouping by the order purchase month and summing payment_value.

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(p.payment_value), 2) AS monthly_revenue
FROM olist_orders o
JOIN olist_order_payments p
    ON o.order_id = p.order_id
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;

-- SQL for dashboard-ready chart

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(p.payment_value), 2) AS monthly_revenue
FROM olist_orders o
JOIN olist_order_payments p
    ON o.order_id = p.order_id
WHERE o.order_purchase_timestamp < '2018-09-01'
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;

