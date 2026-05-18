-- =====================================================================
-- RFM (Recency, Frequency, Monetary) segmentation
--
-- Classic customer-segmentation technique:
--   R = days since last purchase (lower is better)
--   F = number of orders          (higher is better)
--   M = total spend               (higher is better)
--
-- Each customer is scored 1-5 on each dimension using NTILE, then
-- bucketed into named segments.
-- =====================================================================

WITH

-- Reference date = most recent purchase in the dataset
ref_date AS (
    SELECT MAX(order_ts)::DATE AS today FROM v_order_items_full
),

-- 1. Compute raw R, F, M per customer
customer_rfm AS (
    SELECT
        v.customer_unique_id,
        (SELECT today FROM ref_date) - MAX(v.order_ts)::DATE AS recency_days,
        COUNT(DISTINCT v.order_id)                            AS frequency,
        SUM(v.gross_value)                                    AS monetary
    FROM v_order_items_full v
    GROUP BY v.customer_unique_id
),

-- 2. Score each dimension 1-5 using NTILE
scored AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary,
        -- Lower recency_days = better → invert: 6 - NTILE(5)
        (6 - NTILE(5) OVER (ORDER BY recency_days ASC))  AS r_score,
        NTILE(5)  OVER (ORDER BY frequency  ASC)         AS f_score,
        NTILE(5)  OVER (ORDER BY monetary   ASC)         AS m_score
    FROM customer_rfm
),

-- 3. Assign named segments based on score combinations
segmented AS (
    SELECT
        s.*,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2                  THEN 'New Customers'
            WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score >= 3 THEN 'Big Spenders Lost'
            WHEN r_score <= 1                                   THEN 'Lost'
            ELSE 'Need Attention'
        END AS segment,
        (r_score * 100 + f_score * 10 + m_score) AS rfm_score_numeric
    FROM scored s
)

SELECT
    segment,
    COUNT(*)                                                     AS customer_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)           AS pct_of_customers,
    ROUND(AVG(recency_days)::numeric, 1)                         AS avg_recency_days,
    ROUND(AVG(frequency)::numeric,    2)                         AS avg_orders,
    ROUND(AVG(monetary)::numeric,     2)                         AS avg_spend,
    ROUND(SUM(monetary)::numeric,     2)                         AS total_revenue,
    ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1) AS pct_of_revenue
FROM segmented
GROUP BY segment
ORDER BY total_revenue DESC;

-- ----------------------------------------------------------------------
-- Drilldown: top 10 customers by RFM score (potential VIP outreach list)
-- ----------------------------------------------------------------------
WITH ref_date AS (
    SELECT MAX(order_ts)::DATE AS today FROM v_order_items_full
),
customer_rfm AS (
    SELECT
        customer_unique_id,
        (SELECT today FROM ref_date) - MAX(order_ts)::DATE AS recency_days,
        COUNT(DISTINCT order_id)                            AS frequency,
        SUM(gross_value)                                    AS monetary
    FROM v_order_items_full
    GROUP BY customer_unique_id
)
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    ROUND(monetary::numeric, 2) AS total_spend
FROM customer_rfm
ORDER BY monetary DESC, frequency DESC, recency_days ASC
LIMIT 10;
