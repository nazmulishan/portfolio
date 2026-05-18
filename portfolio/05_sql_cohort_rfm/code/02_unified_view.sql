-- =====================================================================
-- Denormalised analytical view — one row per order item with all the
-- attributes the analysis queries need. Built once, used by every
-- downstream query.
-- =====================================================================

DROP MATERIALIZED VIEW IF EXISTS v_order_items_full;

CREATE MATERIALIZED VIEW v_order_items_full AS
SELECT
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_state,
    c.customer_city,
    o.order_status,
    o.order_purchase_timestamp                         AS order_ts,
    DATE_TRUNC('month', o.order_purchase_timestamp)::DATE AS order_month,
    EXTRACT(YEAR FROM o.order_purchase_timestamp)::INT AS order_year,
    oi.product_id,
    p.product_category_name,
    COALESCE(t.product_category_name_english, p.product_category_name) AS category_en,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value)                      AS gross_value,
    -- Payment aggregated to order level
    pay.payment_type,
    pay.payment_installments,
    pay.payment_value,
    -- Review (single per order)
    r.review_score
FROM       olist_order_items                  oi
JOIN       olist_orders                       o   ON o.order_id  = oi.order_id
JOIN       olist_customers                    c   ON c.customer_id = o.customer_id
LEFT JOIN  olist_products                     p   ON p.product_id  = oi.product_id
LEFT JOIN  product_category_translation       t   ON t.product_category_name = p.product_category_name
LEFT JOIN  (
            -- one payment row per order (sum across installments)
            SELECT
                order_id,
                MIN(payment_type)                AS payment_type,
                SUM(payment_installments)        AS payment_installments,
                SUM(payment_value)               AS payment_value
            FROM olist_order_payments
            GROUP BY order_id
           )                                   pay ON pay.order_id = o.order_id
LEFT JOIN  (
            -- one review row per order (latest if duplicates)
            SELECT DISTINCT ON (order_id)
                   order_id, review_score, review_creation_date
            FROM olist_order_reviews
            ORDER BY order_id, review_creation_date DESC
           )                                   r   ON r.order_id   = o.order_id
WHERE      o.order_status = 'delivered';

CREATE INDEX idx_v_items_customer_unique ON v_order_items_full(customer_unique_id);
CREATE INDEX idx_v_items_month           ON v_order_items_full(order_month);
CREATE INDEX idx_v_items_category        ON v_order_items_full(category_en);

ANALYZE v_order_items_full;
