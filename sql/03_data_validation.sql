

-- -------------------------------------------------------------------------------------------
-- Step-3: Data validation
-- This script contains data quality checks performed after loading the Olist dataset into MySQL.
-- It includes null checks, duplicate checks, referential integrity checks, and sanity checks.
-- -------------------------------------------------------------------------------------------

-- Starting with Table 1 — olist_orders

-- Check 1: Null check on critical columns
SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_status,
  SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_purchase_date
FROM olist_orders;

-- Check 2 — Duplicate primary keys in olist_orders
SELECT order_id, COUNT(*) AS count
FROM olist_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check 3 — Date range & order status validity in olist_orders
-- Date range check
SELECT 
  MIN(order_purchase_timestamp) AS earliest_order,
  MAX(order_purchase_timestamp) AS latest_order
FROM olist_orders;

-- Order status distinct values
SELECT order_status, COUNT(*) AS count
FROM olist_orders
GROUP BY order_status
ORDER BY count DESC;

-- Moving to Table 2 — olist_customer

-- Check 1: Null check
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS null_unique_id,
  SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS null_city,
  SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM olist_customer;

-- Check 2: Duplicate primary keys
SELECT customer_id, COUNT(*) AS count
FROM olist_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Check 3: Distinct states (should be valid Brazilian state codes)
SELECT customer_state, COUNT(*) AS count
FROM olist_customer
GROUP BY customer_state
ORDER BY count DESC;

-- Moving to Table 3 — olist_order_items

-- Check 1: Null check
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
  SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
  SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
  SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS null_freight
FROM olist_order_items;

-- Check 2: Price & freight range
SELECT
  MIN(price) AS min_price,
  MAX(price) AS max_price,
  AVG(price) AS avg_price,
  MIN(freight_value) AS min_freight,
  MAX(freight_value) AS max_freight
FROM olist_order_items;

-- Check 3: Referential integrity - items without a valid order
SELECT COUNT(*) AS orphan_items
FROM olist_order_items i
LEFT JOIN olist_orders o ON i.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Moving to Table 4 — olist_order_payments

-- Check 1: Null check
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS null_payment_type,
  SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS null_payment_value
FROM olist_order_payments;

-- Check 2: Payment type distinct values
SELECT payment_type, COUNT(*) AS count
FROM olist_order_payments
GROUP BY payment_type
ORDER BY count DESC;

-- Check 3: Payment value range
SELECT
  MIN(payment_value) AS min_value,
  MAX(payment_value) AS max_value,
  AVG(payment_value) AS avg_value
FROM olist_order_payments;

-- Inspect the 3 not_defined payment rows
SELECT *
FROM olist_order_payments
WHERE payment_type = 'not_defined';

-- ⚠️ DATA QUALITY NOTE: olist_order_payments
-- 3 rows found with payment_type = 'not_defined' and payment_value = 0.00
-- Order IDs:
--   00b1cb0320190ca0daa2c88b35206009
--   4637ca194b6387e2d538dc89b124b0ee
--   c8c528189310eaa44a745b8d9d26908b
-- These appear to be cancelled/test orders with no payment recorded.
-- Action: Exclude from payment analysis using WHERE payment_type != 'not_defined'
-- Decision: Flagged, NOT deleted (preserving raw data integrity)

-- Table 5 — olist_order_reviews
-- Check 1: Null check on critical columns
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS null_review_id,
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS null_score,
  SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS null_comment
FROM olist_order_reviews;

-- Check 2: Review score range (should be 1 to 5 only)
SELECT review_score, COUNT(*) AS count
FROM olist_order_reviews
GROUP BY review_score
ORDER BY review_score;

-- Check 3: Duplicate review_ids
SELECT review_id, COUNT(*) AS count
FROM olist_order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
LIMIT 5;

-- Moving to Table 6 — olist_products

-- Check 1: Null check
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
  SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_category,
  SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS null_weight,
  SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS null_length
FROM olist_products;

-- Check 2: Duplicate product_ids
SELECT product_id, COUNT(*) AS count
FROM olist_products
GROUP BY product_id
HAVING COUNT(*) > 1
LIMIT 5;

-- Check 3: Value ranges
SELECT
  MIN(product_weight_g) AS min_weight,
  MAX(product_weight_g) AS max_weight,
  MIN(product_photos_qty) AS min_photos,
  MAX(product_photos_qty) AS max_photos
FROM olist_products;

-- Two small flags — check how many affected rows
-- Flag 1: Products with 0 weight
SELECT COUNT(*) AS zero_weight_products
FROM olist_products
WHERE product_weight_g = 0;

-- Flag 2: Products with 0 photos
SELECT COUNT(*) AS zero_photo_products
FROM olist_products
WHERE product_photos_qty = 0;

-- ⚠️ DATA QUALITY NOTE: olist_products
-- Flag 1: 6 products have product_weight_g = 0
--   Likely data entry errors. Exclude from weight/freight analysis.
--   Action: Use WHERE product_weight_g > 0 in freight-related queries.

-- Flag 2: 610 products have product_photos_qty = 0 (~1.85% of total)
--   Products listed without any photos — incomplete listings.
--   Not deleted — flagged for business insight analysis in EDA.
--   Potential insight: Do zero-photo products have lower sales or worse reviews?

-- Table 7 — olist_sellers

-- Check 1: Null check
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
  SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip,
  SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS null_city,
  SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM olist_sellers;

-- Check 2: Duplicate seller_ids
SELECT seller_id, COUNT(*) AS count
FROM olist_sellers
GROUP BY seller_id
HAVING COUNT(*) > 1
LIMIT 5;

-- Check 3: Distinct states (should be valid Brazilian state codes)
SELECT seller_state, COUNT(*) AS count
FROM olist_sellers
GROUP BY seller_state
ORDER BY count DESC;

-- Moving to Table 8 — olist_geolocation
-- Check 1: Null check
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip,
  SUM(CASE WHEN geolocation_lat IS NULL THEN 1 ELSE 0 END) AS null_lat,
  SUM(CASE WHEN geolocation_lng IS NULL THEN 1 ELSE 0 END) AS null_lng,
  SUM(CASE WHEN geolocation_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM olist_geolocation;

-- Check 2: Lat/Lng range (Brazil is roughly lat -34 to 5, lng -74 to -34)
SELECT
  MIN(geolocation_lat) AS min_lat,
  MAX(geolocation_lat) AS max_lat,
  MIN(geolocation_lng) AS min_lng,
  MAX(geolocation_lng) AS max_lng
FROM olist_geolocation;

-- Check 3: Duplicate zip entries (geolocation can have multiple rows per zip — just check how many)
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT geolocation_zip_code_prefix) AS distinct_zips
FROM olist_geolocation;

-- Action — Count how many out-of-range rows exist
-- Count rows outside Brazil's valid lat/lng boundaries
SELECT COUNT(*) AS out_of_range_coords
FROM olist_geolocation
WHERE geolocation_lat NOT BETWEEN -34 AND 5
   OR geolocation_lng NOT BETWEEN -74 AND -34;

-- ⚠️ DATA QUALITY NOTE: olist_geolocation
-- 42 rows found with lat/lng coordinates outside Brazil's valid boundaries
--   Valid Brazil range: lat BETWEEN -34 AND 5, lng BETWEEN -74 AND -34
--   42 rows fall outside this range — likely GPS data entry errors.
--   Impact: 0.004% of 1,000,163 rows — negligible.
--   Action: Exclude using WHERE geolocation_lat BETWEEN -34 AND 5
--                          AND geolocation_lng BETWEEN -74 AND -34
--           in any map/geo-based analysis queries.
--   Decision: Flagged, NOT deleted (preserving raw data integrity).

-- Last Table — Table 9: product_category_name_translation
-- Check 1: Null check
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_pt_name,
  SUM(CASE WHEN product_category_name_english IS NULL THEN 1 ELSE 0 END) AS null_en_name
FROM product_category_name_translation;

-- Check 2: Duplicates
SELECT product_category_name, COUNT(*) AS count
FROM product_category_name_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;

-- Check 3: Quick sample to verify translations look correct
SELECT * FROM product_category_name_translation LIMIT 10;
