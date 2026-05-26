-- Run MySQL client with: mysql --local-infile=1 -u root -p
-- Ensure local_infile is enabled before executing this script

USE olist_e_commerce;

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '/path/to/your/csv/Olist-e-commerce-dataset/olist_customers_dataset.csv'
INTO TABLE olist_customer
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state);

LOAD DATA LOCAL INFILE '/path/to/your/csv/Olist-e-commerce-dataset/olist_orders_dataset.csv'
INTO TABLE olist_orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at,
 order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date);

LOAD DATA LOCAL INFILE '/path/to/your/csv/Olist-e-commerce-dataset/olist_order_items_dataset.csv'
INTO TABLE olist_order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value);

LOAD DATA LOCAL INFILE '/path/to/your/csv/Olist-e-commerce-dataset/olist_order_payments_dataset.csv'
INTO TABLE olist_order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, payment_sequential, payment_type, payment_installments, payment_value);

LOAD DATA LOCAL INFILE '/path/to/your/csv/Olist-e-commerce-dataset/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(review_id, order_id, review_score, review_comment_title, review_comment_message,
 review_creation_date, review_answer_timestamp);

LOAD DATA LOCAL INFILE '/path/to/your/csv/Olist-e-commerce-dataset/olist_products_dataset.csv'
INTO TABLE olist_products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, product_category_name, product_name_lenght, product_description_lenght,
 product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm);

LOAD DATA LOCAL INFILE '/path/to/your/csv/Olist-e-commerce-dataset/olist_sellers_dataset.csv'
INTO TABLE olist_sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(seller_id, seller_zip_code_prefix, seller_city, seller_state);

LOAD DATA LOCAL INFILE '/path/to/your/csv/Olist-e-commerce-dataset/olist_geolocation_dataset.csv'
INTO TABLE olist_geolocation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state);

LOAD DATA LOCAL INFILE '/path/to/your/csv/Olist-e-commerce-dataset/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_category_name, product_category_name_english);
