-- =====================================================================
-- Load Olist CSV files into staged tables.
-- Run AFTER 00_schema.sql.
-- Requires CSVs in ../data/raw/ from the Kaggle download.
-- =====================================================================

-- PostgreSQL COPY statements. For SQLite use .mode csv and .import.

\COPY olist_customers              FROM '../data/raw/olist_customers_dataset.csv'              WITH CSV HEADER;
\COPY olist_sellers                FROM '../data/raw/olist_sellers_dataset.csv'                WITH CSV HEADER;
\COPY olist_products               FROM '../data/raw/olist_products_dataset.csv'               WITH CSV HEADER;
\COPY product_category_translation FROM '../data/raw/product_category_name_translation.csv'    WITH CSV HEADER;
\COPY olist_orders                 FROM '../data/raw/olist_orders_dataset.csv'                 WITH CSV HEADER;
\COPY olist_order_items            FROM '../data/raw/olist_order_items_dataset.csv'            WITH CSV HEADER;
\COPY olist_order_payments         FROM '../data/raw/olist_order_payments_dataset.csv'         WITH CSV HEADER;
\COPY olist_order_reviews          FROM '../data/raw/olist_order_reviews_dataset.csv'          WITH CSV HEADER;

-- Quick row counts so you can sanity-check the load
SELECT 'customers'   AS table, COUNT(*) AS rows FROM olist_customers
UNION ALL SELECT 'sellers',                COUNT(*) FROM olist_sellers
UNION ALL SELECT 'products',               COUNT(*) FROM olist_products
UNION ALL SELECT 'category_translation',   COUNT(*) FROM product_category_translation
UNION ALL SELECT 'orders',                 COUNT(*) FROM olist_orders
UNION ALL SELECT 'order_items',            COUNT(*) FROM olist_order_items
UNION ALL SELECT 'order_payments',         COUNT(*) FROM olist_order_payments
UNION ALL SELECT 'order_reviews',          COUNT(*) FROM olist_order_reviews;

-- Expected row counts (full Kaggle dataset):
--   customers           99,441
--   sellers              3,095
--   products            32,951
--   category_translation    71
--   orders              99,441
--   order_items        112,650
--   order_payments     103,886
--   order_reviews       99,224
