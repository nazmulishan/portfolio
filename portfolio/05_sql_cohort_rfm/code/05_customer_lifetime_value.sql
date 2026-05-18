-- =====================================================================
-- Customer Lifetime Value (CLV) by cohort
--
-- For each acquisition month, what is the cumulative revenue per
-- customer at month 0, 3, 6, 12? Combines window functions with
-- cohort logic.
-- =====================================================================

WITH

first_purchase AS (
    SELECT customer_unique_id, MIN(order_month) AS cohort_month
    FROM v_order_items_full
    GROUP BY customer_unique_id
),

monthly_revenue AS (
    SELECT
        fp.cohort_month,
        v.customer_unique_id,
        ((EXTRACT(YEAR FROM v.order_month)  * 12 + EXTRACT(MONTH FROM v.order_month))
       - (EXTRACT(YEAR FROM fp.cohort_month) * 12 + EXTRACT(MONTH FROM fp.cohort_month))
        )::INT                              AS months_since_first,
        SUM(v.gross_value)                  AS revenue
    FROM v_order_items_full v
    JOIN first_purchase fp USING (customer_unique_id)
    GROUP BY fp.cohort_month, v.customer_unique_id, v.order_month
),

cumulative AS (
    SELECT
        cohort_month,
        customer_unique_id,
        months_since_first,
        revenue,
        SUM(revenue) OVER (
            PARTITION BY customer_unique_id
            ORDER BY     months_since_first
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM monthly_revenue
),

cohort_clv AS (
    SELECT
        cohort_month,
        months_since_first,
        AVG(cumulative_revenue)              AS avg_clv,
        COUNT(DISTINCT customer_unique_id)   AS customers
    FROM cumulative
    WHERE months_since_first IN (0, 3, 6, 12)
    GROUP BY cohort_month, months_since_first
)

SELECT
    cohort_month,
    MAX(customers)                                  FILTER (WHERE months_since_first = 0)  AS cohort_size,
    ROUND(MAX(avg_clv)::numeric, 2)                 FILTER (WHERE months_since_first = 0)  AS clv_m0,
    ROUND(MAX(avg_clv)::numeric, 2)                 FILTER (WHERE months_since_first = 3)  AS clv_m3,
    ROUND(MAX(avg_clv)::numeric, 2)                 FILTER (WHERE months_since_first = 6)  AS clv_m6,
    ROUND(MAX(avg_clv)::numeric, 2)                 FILTER (WHERE months_since_first = 12) AS clv_m12
FROM cohort_clv
GROUP BY cohort_month
ORDER BY cohort_month;
