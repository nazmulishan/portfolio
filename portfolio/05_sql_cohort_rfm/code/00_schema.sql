-- =====================================================================
-- Olist Brazilian E-commerce — schema and indexes
--
-- Designed for PostgreSQL 14+. Mostly compatible with SQLite 3
-- (replace TIMESTAMP with DATETIME if you use SQLite).
-- =====================================================================

DROP TABLE IF EXISTS olist_order_items   CASCADE;
DROP TABLE IF EXISTS olist_order_payments CASCADE;
DROP TABLE IF EXISTS olist_order_reviews  CASCADE;
DROP TABLE IF EXISTS olist_orders         CASCADE;
DROP TABLE IF EXISTS olist_products       CASCADE;
DROP TABLE IF EXISTS olist_sellers        CASCADE;
DROP TABLE IF EXISTS olist_customers      CASCADE;
DROP TABLE IF EXISTS product_category_translation CASCADE;

CREATE TABLE olist_customers (
    customer_id              VARCHAR(40) PRIMARY KEY,
    customer_unique_id       VARCHAR(40) NOT NULL,
    customer_zip_code_prefix VARCHAR(10),
    customer_city            VARCHAR(80),
    customer_state           CHAR(2)
);

CREATE TABLE olist_sellers (
    seller_id              VARCHAR(40) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10),
    seller_city            VARCHAR(80),
    seller_state           CHAR(2)
);

CREATE TABLE olist_products (
    product_id                 VARCHAR(40) PRIMARY KEY,
    product_category_name      VARCHAR(80),
    product_name_length        INT,
    product_description_length INT,
    product_photos_qty         INT,
    product_weight_g           INT,
    product_length_cm          INT,
    product_height_cm          INT,
    product_width_cm           INT
);

CREATE TABLE product_category_translation (
    product_category_name         VARCHAR(80) PRIMARY KEY,
    product_category_name_english VARCHAR(80)
);

CREATE TABLE olist_orders (
    order_id                      VARCHAR(40) PRIMARY KEY,
    customer_id                   VARCHAR(40) REFERENCES olist_customers(customer_id),
    order_status                  VARCHAR(20),
    order_purchase_timestamp      TIMESTAMP,
    order_approved_at             TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE olist_order_items (
    order_id            VARCHAR(40) REFERENCES olist_orders(order_id),
    order_item_id       INT,
    product_id          VARCHAR(40) REFERENCES olist_products(product_id),
    seller_id           VARCHAR(40) REFERENCES olist_sellers(seller_id),
    shipping_limit_date TIMESTAMP,
    price               NUMERIC(10, 2),
    freight_value       NUMERIC(10, 2),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE olist_order_payments (
    order_id            VARCHAR(40) REFERENCES olist_orders(order_id),
    payment_sequential  INT,
    payment_type        VARCHAR(20),
    payment_installments INT,
    payment_value       NUMERIC(10, 2),
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE olist_order_reviews (
    review_id               VARCHAR(40) PRIMARY KEY,
    order_id                VARCHAR(40) REFERENCES olist_orders(order_id),
    review_score            INT,
    review_comment_title    TEXT,
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

-- Performance-critical indexes for the analysis queries
CREATE INDEX idx_orders_customer       ON olist_orders(customer_id);
CREATE INDEX idx_orders_purchase_ts    ON olist_orders(order_purchase_timestamp);
CREATE INDEX idx_items_order           ON olist_order_items(order_id);
CREATE INDEX idx_items_product         ON olist_order_items(product_id);
CREATE INDEX idx_payments_order        ON olist_order_payments(order_id);
CREATE INDEX idx_reviews_order         ON olist_order_reviews(order_id);
CREATE INDEX idx_customers_unique      ON olist_customers(customer_unique_id);
CREATE INDEX idx_customers_state       ON olist_customers(customer_state);
