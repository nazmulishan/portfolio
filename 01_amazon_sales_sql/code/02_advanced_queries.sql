-- =====================================================================
-- Amazon Sales Analysis — Advanced Queries (15 questions)
-- Window functions, recursive CTEs, cohort, RFM, Pareto, market basket.
-- Author: Md Nazmul Islam Ishan
-- =====================================================================

-- ---------------------------------------------------------------------
-- Q1. Running cumulative revenue per month
-- ---------------------------------------------------------------------
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::DATE AS month,
        SUM(oi.line_revenue)                    AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT
    month,
    ROUND(revenue::numeric, 2)                                                AS month_revenue,
    ROUND(SUM(revenue) OVER (ORDER BY month
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)::numeric, 2)      AS cumulative_revenue
FROM monthly
ORDER BY month;

-- ---------------------------------------------------------------------
-- Q2. Rank customers within their segment by spend
-- ---------------------------------------------------------------------
SELECT
    c.customer_name,
    c.customer_segment,
    ROUND(SUM(oi.line_revenue)::numeric, 2) AS spend,
    RANK()       OVER (PARTITION BY c.customer_segment ORDER BY SUM(oi.line_revenue) DESC) AS rank_in_segment,
    DENSE_RANK() OVER (PARTITION BY c.customer_segment ORDER BY SUM(oi.line_revenue) DESC) AS dense_rank
FROM customers c
JOIN orders o      ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id  = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.customer_segment
ORDER BY c.customer_segment, rank_in_segment;

-- ---------------------------------------------------------------------
-- Q3. Each customer's previous and next order date (LAG / LEAD)
-- ---------------------------------------------------------------------
SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    LAG(o.order_date)  OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS previous_order,
    LEAD(o.order_date) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS next_order,
    o.order_date - LAG(o.order_date) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS days_since_previous
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
ORDER BY c.customer_name, o.order_date;

-- ---------------------------------------------------------------------
-- Q4. NTILE-based RFM score (1-5 on each dimension)
-- ---------------------------------------------------------------------
WITH ref AS (SELECT MAX(order_date) AS today FROM orders WHERE order_status = 'Delivered'),
customer_rfm AS (
    SELECT
        c.customer_id,
        c.customer_name,
        (SELECT today FROM ref) - MAX(o.order_date)  AS recency_days,
        COUNT(DISTINCT o.order_id)                    AS frequency,
        SUM(oi.line_revenue)                          AS monetary
    FROM customers c
    JOIN orders o      ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id  = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    recency_days, frequency, ROUND(monetary::numeric, 2) AS monetary,
    (6 - NTILE(5) OVER (ORDER BY recency_days)) AS r_score,
    NTILE(5)     OVER (ORDER BY frequency)      AS f_score,
    NTILE(5)     OVER (ORDER BY monetary)       AS m_score
FROM customer_rfm
ORDER BY r_score DESC, f_score DESC, m_score DESC;

-- ---------------------------------------------------------------------
-- Q5. Pareto / 80-20 — what fraction of products drives 80% of revenue?
-- ---------------------------------------------------------------------
WITH product_rev AS (
    SELECT
        p.product_id, p.product_name,
        SUM(oi.line_revenue) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name
),
ranked AS (
    SELECT
        product_name, revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC
                           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        / SUM(revenue) OVER ()                                  AS cumulative_share,
        ROW_NUMBER() OVER (ORDER BY revenue DESC)               AS rank_n,
        COUNT(*) OVER ()                                        AS total_products
    FROM product_rev
)
SELECT
    product_name,
    ROUND(revenue::numeric, 2)        AS revenue,
    ROUND(cumulative_share::numeric, 3) AS cum_share,
    rank_n,
    ROUND(100.0 * rank_n / total_products, 1) AS pct_of_products
FROM ranked
WHERE cumulative_share <= 0.80
ORDER BY rank_n;

-- ---------------------------------------------------------------------
-- Q6. Cohort retention: signup-month cohort × months since signup
-- ---------------------------------------------------------------------
WITH first_order AS (
    SELECT
        customer_id,
        MIN(DATE_TRUNC('month', order_date))::DATE AS cohort_month
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
activity AS (
    SELECT
        fo.cohort_month,
        o.customer_id,
        ((EXTRACT(YEAR FROM o.order_date)  * 12 + EXTRACT(MONTH FROM o.order_date))
       - (EXTRACT(YEAR FROM fo.cohort_month) * 12 + EXTRACT(MONTH FROM fo.cohort_month))
        )::INT AS months_since_first
    FROM orders o
    JOIN first_order fo ON fo.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
)
SELECT
    cohort_month,
    months_since_first,
    COUNT(DISTINCT customer_id) AS active_customers
FROM activity
WHERE months_since_first <= 12
GROUP BY cohort_month, months_since_first
ORDER BY cohort_month, months_since_first;

-- ---------------------------------------------------------------------
-- Q7. Recursive CTE — generate a calendar table for date dimension
-- ---------------------------------------------------------------------
WITH RECURSIVE date_dim AS (
    SELECT '2024-01-01'::DATE AS d
    UNION ALL
    SELECT d + INTERVAL '1 day' FROM date_dim WHERE d < '2024-12-31'
)
SELECT
    d::DATE AS calendar_date,
    EXTRACT(YEAR    FROM d)::INT AS year,
    EXTRACT(MONTH   FROM d)::INT AS month,
    EXTRACT(QUARTER FROM d)::INT AS quarter,
    EXTRACT(DOW     FROM d)::INT AS day_of_week,
    TO_CHAR(d, 'Day')            AS weekday_name
FROM date_dim
LIMIT 30;  -- preview first 30 days

-- ---------------------------------------------------------------------
-- Q8. Market basket: products frequently bought together
-- ---------------------------------------------------------------------
SELECT
    p1.product_name                              AS product_a,
    p2.product_name                              AS product_b,
    COUNT(DISTINCT oi1.order_id)                 AS times_bought_together
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id   = oi2.order_id
                    AND oi1.product_id < oi2.product_id   -- avoid duplicates
JOIN products    p1   ON p1.product_id = oi1.product_id
JOIN products    p2   ON p2.product_id = oi2.product_id
GROUP BY p1.product_name, p2.product_name
HAVING COUNT(DISTINCT oi1.order_id) >= 2
ORDER BY times_bought_together DESC
LIMIT 20;

-- ---------------------------------------------------------------------
-- Q9. Top product per month by revenue
-- ---------------------------------------------------------------------
WITH monthly_product AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::DATE AS month,
        p.product_name,
        SUM(oi.line_revenue)                    AS revenue,
        ROW_NUMBER() OVER (PARTITION BY DATE_TRUNC('month', o.order_date)
                           ORDER BY SUM(oi.line_revenue) DESC) AS rn
    FROM orders o
    JOIN order_items oi ON oi.order_id   = o.order_id
    JOIN products p     ON p.product_id  = oi.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY DATE_TRUNC('month', o.order_date), p.product_name
)
SELECT month, product_name, ROUND(revenue::numeric, 2) AS revenue
FROM monthly_product
WHERE rn = 1
ORDER BY month;

-- ---------------------------------------------------------------------
-- Q10. Moving average revenue (3-month window)
-- ---------------------------------------------------------------------
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::DATE AS month,
        SUM(oi.line_revenue)                    AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT
    month,
    ROUND(revenue::numeric, 2)                                                       AS revenue,
    ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)::numeric, 2) AS ma_3_month
FROM monthly
ORDER BY month;

-- ---------------------------------------------------------------------
-- Q11. Customer's cumulative spend over time
-- ---------------------------------------------------------------------
SELECT
    c.customer_name,
    o.order_date,
    ROUND(oi.line_revenue::numeric, 2) AS order_value,
    ROUND(SUM(oi.line_revenue) OVER (
            PARTITION BY c.customer_id
            ORDER BY     o.order_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
         )::numeric, 2) AS cumulative_spend
FROM customers c
JOIN orders o      ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id  = o.order_id
WHERE o.order_status = 'Delivered'
ORDER BY c.customer_name, o.order_date;

-- ---------------------------------------------------------------------
-- Q12. Identify outlier orders (revenue > 2 SD above customer mean)
-- ---------------------------------------------------------------------
WITH customer_stats AS (
    SELECT
        o.customer_id,
        AVG(oi.line_revenue) AS avg_order,
        STDDEV(oi.line_revenue) AS sd_order
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY o.customer_id
)
SELECT
    o.order_id,
    c.customer_name,
    ROUND(oi.line_revenue::numeric, 2) AS order_value,
    ROUND(cs.avg_order::numeric, 2)     AS avg_for_customer,
    ROUND(cs.sd_order::numeric, 2)      AS sd_for_customer
FROM orders o
JOIN customers c       ON c.customer_id = o.customer_id
JOIN order_items oi    ON oi.order_id   = o.order_id
JOIN customer_stats cs ON cs.customer_id = o.customer_id
WHERE oi.line_revenue > cs.avg_order + 2 * COALESCE(cs.sd_order, 0)
ORDER BY oi.line_revenue DESC;

-- ---------------------------------------------------------------------
-- Q13. Percentile ranking of customers
-- ---------------------------------------------------------------------
SELECT
    c.customer_name,
    ROUND(SUM(oi.line_revenue)::numeric, 2)                          AS spend,
    ROUND(100 * PERCENT_RANK() OVER (ORDER BY SUM(oi.line_revenue))::numeric, 1)
                                                                     AS percentile,
    CASE
        WHEN PERCENT_RANK() OVER (ORDER BY SUM(oi.line_revenue)) >= 0.90 THEN 'Top 10%'
        WHEN PERCENT_RANK() OVER (ORDER BY SUM(oi.line_revenue)) >= 0.75 THEN 'Top 25%'
        WHEN PERCENT_RANK() OVER (ORDER BY SUM(oi.line_revenue)) >= 0.50 THEN 'Top 50%'
        ELSE 'Bottom 50%'
    END                                                              AS percentile_band
FROM customers c
JOIN orders o      ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id  = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY spend DESC;

-- ---------------------------------------------------------------------
-- Q14. Self-join: find customers from same state who order similar products
-- ---------------------------------------------------------------------
SELECT
    c1.customer_name        AS customer_a,
    c2.customer_name        AS customer_b,
    c1.state,
    p.product_name
FROM customers c1
JOIN orders o1    ON o1.customer_id = c1.customer_id
JOIN order_items oi1 ON oi1.order_id = o1.order_id
JOIN customers c2 ON c2.state = c1.state AND c2.customer_id < c1.customer_id
JOIN orders o2    ON o2.customer_id = c2.customer_id
JOIN order_items oi2 ON oi2.order_id = o2.order_id AND oi2.product_id = oi1.product_id
JOIN products p   ON p.product_id    = oi1.product_id
GROUP BY c1.customer_name, c2.customer_name, c1.state, p.product_name
ORDER BY c1.state, c1.customer_name;

-- ---------------------------------------------------------------------
-- Q15. Pivot-style: revenue by category × quarter using FILTER
-- ---------------------------------------------------------------------
SELECT
    p.category,
    ROUND(SUM(oi.line_revenue) FILTER (WHERE EXTRACT(QUARTER FROM o.order_date) = 1)::numeric, 2) AS q1,
    ROUND(SUM(oi.line_revenue) FILTER (WHERE EXTRACT(QUARTER FROM o.order_date) = 2)::numeric, 2) AS q2,
    ROUND(SUM(oi.line_revenue) FILTER (WHERE EXTRACT(QUARTER FROM o.order_date) = 3)::numeric, 2) AS q3,
    ROUND(SUM(oi.line_revenue) FILTER (WHERE EXTRACT(QUARTER FROM o.order_date) = 4)::numeric, 2) AS q4,
    ROUND(SUM(oi.line_revenue)::numeric, 2)                                                       AS full_year
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o       ON o.order_id    = oi.order_id
WHERE o.order_status = 'Delivered'
  AND EXTRACT(YEAR FROM o.order_date) = 2024
GROUP BY p.category
ORDER BY full_year DESC;
