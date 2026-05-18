-- =====================================================================
-- Cohort retention analysis
--
-- Q: Of the customers acquired in each calendar month (their "cohort"),
--    what fraction are still buying 1, 2, 3 ... 12 months later?
--
-- Uses CTEs and date arithmetic. Pure analytical SQL — no procedural code.
-- =====================================================================

WITH

-- 1. Identify each customer's FIRST purchase month (cohort assignment).
first_purchase AS (
    SELECT
        customer_unique_id,
        MIN(order_month) AS cohort_month
    FROM v_order_items_full
    GROUP BY customer_unique_id
),

-- 2. For every actual order, calculate months-since-cohort-month.
customer_orders AS (
    SELECT
        v.customer_unique_id,
        fp.cohort_month,
        v.order_month,
        -- months between first purchase month and this purchase month
        ((EXTRACT(YEAR FROM v.order_month)  * 12 + EXTRACT(MONTH FROM v.order_month))
       - (EXTRACT(YEAR FROM fp.cohort_month) * 12 + EXTRACT(MONTH FROM fp.cohort_month))
        )::INT AS months_since_first
    FROM v_order_items_full v
    JOIN first_purchase     fp USING (customer_unique_id)
),

-- 3. Active customers per (cohort, months_since_first) cell.
cohort_activity AS (
    SELECT
        cohort_month,
        months_since_first,
        COUNT(DISTINCT customer_unique_id) AS active_customers
    FROM customer_orders
    GROUP BY cohort_month, months_since_first
),

-- 4. Cohort size = customers active at month 0
cohort_sizes AS (
    SELECT cohort_month, active_customers AS cohort_size
    FROM cohort_activity
    WHERE months_since_first = 0
)

-- 5. Retention rate per cell
SELECT
    ca.cohort_month,
    ca.months_since_first,
    cs.cohort_size,
    ca.active_customers,
    ROUND(100.0 * ca.active_customers / NULLIF(cs.cohort_size, 0), 2) AS retention_pct
FROM cohort_activity ca
JOIN cohort_sizes    cs USING (cohort_month)
WHERE ca.months_since_first <= 12
ORDER BY ca.cohort_month, ca.months_since_first;

-- ----------------------------------------------------------------------
-- Wide-format retention matrix (cohort_month on rows, months 0..12 on columns)
-- ----------------------------------------------------------------------
WITH base AS (
    SELECT
        cohort_month,
        months_since_first,
        ROUND(100.0 * active_customers
              / NULLIF(MAX(active_customers) FILTER (WHERE months_since_first = 0)
                       OVER (PARTITION BY cohort_month), 0),
              1) AS retention_pct
    FROM (
        SELECT
            fp.cohort_month,
            ((EXTRACT(YEAR FROM v.order_month)  * 12 + EXTRACT(MONTH FROM v.order_month))
           - (EXTRACT(YEAR FROM fp.cohort_month) * 12 + EXTRACT(MONTH FROM fp.cohort_month))
            )::INT AS months_since_first,
            COUNT(DISTINCT v.customer_unique_id) AS active_customers
        FROM v_order_items_full v
        JOIN (
            SELECT customer_unique_id, MIN(order_month) AS cohort_month
            FROM v_order_items_full GROUP BY customer_unique_id
        ) fp USING (customer_unique_id)
        GROUP BY fp.cohort_month, months_since_first
    ) t
)
SELECT
    cohort_month,
    MAX(retention_pct) FILTER (WHERE months_since_first =  0) AS m0,
    MAX(retention_pct) FILTER (WHERE months_since_first =  1) AS m1,
    MAX(retention_pct) FILTER (WHERE months_since_first =  2) AS m2,
    MAX(retention_pct) FILTER (WHERE months_since_first =  3) AS m3,
    MAX(retention_pct) FILTER (WHERE months_since_first =  6) AS m6,
    MAX(retention_pct) FILTER (WHERE months_since_first = 12) AS m12
FROM base
WHERE months_since_first IN (0, 1, 2, 3, 6, 12)
GROUP BY cohort_month
ORDER BY cohort_month;
