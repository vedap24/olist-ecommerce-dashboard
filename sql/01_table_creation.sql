
-- ============================================================
-- 01_table_creation.sql
-- Project: Olist E-Commerce Dashboard
-- Description: Create all 9 raw tables to load Olist CSV data
-- ============================================================

CREATE DATABASE IF NOT EXISTS olist;
USE olist_e_commerce;

-- -----------------------------------------------------------
-- 1. Customers
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

-- -----------------------------------------------------------
-- 2. Geolocation
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(18,15),
    geolocation_lng DECIMAL(18,15),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

-- -----------------------------------------------------------
-- 3. Orders
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

-- -----------------------------------------------------------
-- 4. Order Items
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

-- -----------------------------------------------------------
-- 5. Order Payments
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

-- -----------------------------------------------------------
-- 6. Order Reviews
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(100),
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

-- -----------------------------------------------------------
-- 7. Products
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- -----------------------------------------------------------
-- 8. Sellers
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

-- -----------------------------------------------------------
-- 9. Product Category Name Translation
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS product_category_name_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

