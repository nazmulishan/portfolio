-- =====================================================================
-- Amazon Sales Analysis — Basic to Intermediate Queries (25 questions)
-- Author: Md Nazmul Islam Ishan
-- =====================================================================

-- ---------------------------------------------------------------------
-- Q1. How many customers do we have, and how many are in each segment?
-- ---------------------------------------------------------------------
SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM customers
GROUP BY customer_segment
ORDER BY customers DESC;

-- ---------------------------------------------------------------------
-- Q2. Total revenue, total orders, and average order value (AOV)
-- ---------------------------------------------------------------------
SELECT
    COUNT(DISTINCT o.order_id)                     AS total_orders,
    ROUND(SUM(oi.line_revenue)::numeric, 2)        AS total_revenue,
    ROUND(AVG(oi.line_revenue)::numeric, 2)        AS avg_line_revenue,
    ROUND((SUM(oi.line_revenue)
          / NULLIF(COUNT(DISTINCT o.order_id), 0))::numeric, 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered';

-- ---------------------------------------------------------------------
-- Q3. Top 10 customers by lifetime spend
-- ---------------------------------------------------------------------
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    COUNT(DISTINCT o.order_id)                  AS orders,
    ROUND(SUM(oi.line_revenue)::numeric, 2)     AS lifetime_spend
FROM customers c
JOIN orders     o  ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id  = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.customer_segment
ORDER BY lifetime_spend DESC
LIMIT 10;

-- ---------------------------------------------------------------------
-- Q4. Top 5 product categories by revenue
-- ---------------------------------------------------------------------
SELECT
    p.category,
    SUM(oi.quantity)                        AS units_sold,
    ROUND(SUM(oi.line_revenue)::numeric, 2) AS revenue,
    ROUND(AVG(oi.line_revenue)::numeric, 2) AS avg_line
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC
LIMIT 5;

-- ---------------------------------------------------------------------
-- Q5. Most popular product (by units sold) in each category
-- ---------------------------------------------------------------------
SELECT category, product_name, units_sold FROM (
    SELECT
        p.category,
        p.product_name,
        SUM(oi.quantity) AS units_sold,
        ROW_NUMBER() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity) DESC) AS rn
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY p.category, p.product_name
) ranked
WHERE rn = 1;

-- ---------------------------------------------------------------------
-- Q6. Monthly revenue trend (last 12 months)
-- ---------------------------------------------------------------------
SELECT
    DATE_TRUNC('month', o.order_date)::DATE  AS month,
    COUNT(DISTINCT o.order_id)               AS orders,
    ROUND(SUM(oi.line_revenue)::numeric, 2)  AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;

-- ---------------------------------------------------------------------
-- Q7. Day-of-week analysis — which weekday has highest revenue?
-- ---------------------------------------------------------------------
SELECT
    TO_CHAR(o.order_date, 'Day')             AS weekday,
    EXTRACT(DOW FROM o.order_date)           AS dow_num,
    COUNT(DISTINCT o.order_id)               AS orders,
    ROUND(SUM(oi.line_revenue)::numeric, 2)  AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY TO_CHAR(o.order_date, 'Day'), EXTRACT(DOW FROM o.order_date)
ORDER BY dow_num;

-- ---------------------------------------------------------------------
-- Q8. Payment method distribution
-- ---------------------------------------------------------------------
SELECT
    payment_method,
    COUNT(*)                                   AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_orders
FROM orders
GROUP BY payment_method
ORDER BY orders DESC;

-- ---------------------------------------------------------------------
-- Q9. Order status breakdown
-- ---------------------------------------------------------------------
SELECT
    order_status,
    COUNT(*)                                   AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- ---------------------------------------------------------------------
-- Q10. Profit margin per category
-- ---------------------------------------------------------------------
SELECT
    p.category,
    ROUND(SUM(oi.line_revenue)::numeric, 2)              AS revenue,
    ROUND(SUM(oi.quantity * p.unit_cost)::numeric, 2)    AS cost,
    ROUND(SUM(oi.line_revenue - oi.quantity * p.unit_cost)::numeric, 2)  AS profit,
    ROUND(100.0 * SUM(oi.line_revenue - oi.quantity * p.unit_cost)
          / NULLIF(SUM(oi.line_revenue), 0), 1)          AS margin_pct
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY margin_pct DESC;

-- ---------------------------------------------------------------------
-- Q11. Customers who have never returned an order
-- ---------------------------------------------------------------------
SELECT
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN returns r ON r.order_id = o.order_id
WHERE r.return_id IS NULL
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) > 0
ORDER BY orders DESC;

-- ---------------------------------------------------------------------
-- Q12. Customers who have made >= 3 orders (high frequency)
-- ---------------------------------------------------------------------
SELECT
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.line_revenue)::numeric, 2) AS total_spend
FROM customers c
JOIN orders o      ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id  = o.order_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) >= 3
ORDER BY total_spend DESC;

-- ---------------------------------------------------------------------
-- Q13. Tag each order as Small / Medium / Large by revenue
-- ---------------------------------------------------------------------
SELECT
    o.order_id,
    o.order_date,
    SUM(oi.line_revenue) AS order_value,
    CASE
        WHEN SUM(oi.line_revenue) < 50   THEN 'Small'
        WHEN SUM(oi.line_revenue) < 150  THEN 'Medium'
        ELSE 'Large'
    END                  AS order_tier
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY o.order_id, o.order_date
ORDER BY order_value DESC;

-- ---------------------------------------------------------------------
-- Q14. Customer tier classification (Bronze / Silver / Gold / Platinum)
-- ---------------------------------------------------------------------
SELECT
    c.customer_name,
    ROUND(SUM(oi.line_revenue)::numeric, 2) AS lifetime_spend,
    CASE
        WHEN SUM(oi.line_revenue) <  100 THEN 'Bronze'
        WHEN SUM(oi.line_revenue) <  300 THEN 'Silver'
        WHEN SUM(oi.line_revenue) <  600 THEN 'Gold'
        ELSE 'Platinum'
    END AS tier
FROM customers c
JOIN orders o      ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id  = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY lifetime_spend DESC;

-- ---------------------------------------------------------------------
-- Q15. Average shipping time (order_date to delivery_date) by region
-- ---------------------------------------------------------------------
SELECT
    c.state,
    COUNT(*)                                            AS orders,
    ROUND(AVG(o.delivery_date - o.order_date), 1)       AS avg_days_to_deliver
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.delivery_date IS NOT NULL
GROUP BY c.state
ORDER BY avg_days_to_deliver;

-- ---------------------------------------------------------------------
-- Q16. Products that have NEVER been ordered
-- ---------------------------------------------------------------------
SELECT p.product_id, p.product_name, p.category
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.order_item_id IS NULL;

-- ---------------------------------------------------------------------
-- Q17. Year-over-year revenue growth
-- ---------------------------------------------------------------------
WITH yearly AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date)::INT AS year,
        SUM(oi.line_revenue)                 AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY EXTRACT(YEAR FROM o.order_date)
)
SELECT
    year,
    ROUND(revenue::numeric, 2)                  AS revenue,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY year))::numeric, 2) AS yoy_change,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY year))
          / NULLIF(LAG(revenue) OVER (ORDER BY year), 0), 1)         AS yoy_pct
FROM yearly
ORDER BY year;

-- ---------------------------------------------------------------------
-- Q18. Products outselling their category average
-- ---------------------------------------------------------------------
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity)                                AS units_sold,
    ROUND(AVG(SUM(oi.quantity)) OVER (PARTITION BY p.category)::numeric, 1) AS category_avg
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
HAVING SUM(oi.quantity) > (
    SELECT AVG(unit_sum) FROM (
        SELECT SUM(oi2.quantity) AS unit_sum
        FROM order_items oi2
        JOIN products p2 ON p2.product_id = oi2.product_id
        WHERE p2.category = p.category
        GROUP BY p2.product_id
    ) sub
)
ORDER BY units_sold DESC;

-- ---------------------------------------------------------------------
-- Q19. Repeat-customer rate (customers with >1 order / total customers)
-- ---------------------------------------------------------------------
WITH customer_orders AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS orders
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    COUNT(*) FILTER (WHERE orders > 1)              AS repeat_customers,
    COUNT(*)                                        AS total_customers,
    ROUND(100.0 * COUNT(*) FILTER (WHERE orders > 1) / NULLIF(COUNT(*), 0), 1) AS repeat_rate_pct
FROM customer_orders;

-- ---------------------------------------------------------------------
-- Q20. Most profitable product (by absolute profit)
-- ---------------------------------------------------------------------
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity)                                              AS units_sold,
    ROUND(SUM(oi.line_revenue - oi.quantity * p.unit_cost)::numeric, 2) AS profit
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY profit DESC
LIMIT 10;

-- ---------------------------------------------------------------------
-- Q21. Quarter-by-quarter revenue
-- ---------------------------------------------------------------------
SELECT
    EXTRACT(YEAR    FROM o.order_date)::INT AS year,
    EXTRACT(QUARTER FROM o.order_date)::INT AS quarter,
    COUNT(DISTINCT o.order_id)              AS orders,
    ROUND(SUM(oi.line_revenue)::numeric, 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY EXTRACT(YEAR FROM o.order_date), EXTRACT(QUARTER FROM o.order_date)
ORDER BY year, quarter;

-- ---------------------------------------------------------------------
-- Q22. Average discount given per category
-- ---------------------------------------------------------------------
SELECT
    p.category,
    ROUND(AVG(oi.discount_pct)::numeric, 2)             AS avg_discount_pct,
    ROUND(MAX(oi.discount_pct)::numeric, 2)             AS max_discount_pct
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_discount_pct DESC;

-- ---------------------------------------------------------------------
-- Q23. Customers acquired per month (signup cohort sizes)
-- ---------------------------------------------------------------------
SELECT
    DATE_TRUNC('month', signup_date)::DATE AS signup_month,
    COUNT(*)                               AS new_customers
FROM customers
GROUP BY DATE_TRUNC('month', signup_date)
ORDER BY signup_month;

-- ---------------------------------------------------------------------
-- Q24. State-level performance ranking
-- ---------------------------------------------------------------------
SELECT
    c.state,
    COUNT(DISTINCT c.customer_id)                                AS customers,
    COUNT(DISTINCT o.order_id)                                   AS orders,
    ROUND(SUM(oi.line_revenue)::numeric, 2)                      AS revenue,
    ROUND((SUM(oi.line_revenue) / COUNT(DISTINCT c.customer_id))::numeric, 2) AS rev_per_customer
FROM customers c
JOIN orders o      ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id  = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.state
ORDER BY revenue DESC;

-- ---------------------------------------------------------------------
-- Q25. Return rate per product
-- ---------------------------------------------------------------------
SELECT
    p.product_name,
    p.category,
    COUNT(DISTINCT oi.order_id)                                       AS orders_with_product,
    COUNT(DISTINCT r.return_id)                                       AS returns,
    ROUND(100.0 * COUNT(DISTINCT r.return_id) / NULLIF(COUNT(DISTINCT oi.order_id), 0), 1) AS return_rate_pct
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN returns r ON r.order_id     = oi.order_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY return_rate_pct DESC;
