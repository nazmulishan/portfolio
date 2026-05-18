# Amazon Sales Data Analysis using SQL

An end-to-end SQL analytics project on Amazon-style transactional data. 40+ queries across three difficulty tiers — basic, intermediate, advanced. PostgreSQL 14+ (SQLite compatible).

## What's inside

**`code/00_schema_and_load.sql`** — 5 normalised tables (customers, products, orders, order_items, returns), indexes, plus sample data so the queries run end-to-end.

**`code/01_basic_to_intermediate.sql`** — 25 queries: aggregations, GROUP BY, JOINs, CASE logic, subqueries, HAVING, date functions.

**`code/02_advanced_queries.sql`** — 15 queries: window functions, CTEs, recursive CTEs, cohort analysis, RFM, Pareto / 80-20, market basket.

## Sample queries from the project

### 1. Top 5 product categories by revenue

```sql
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
```

### 2. Customer tier classification (Bronze / Silver / Gold / Platinum)

```sql
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
```

### 3. Month-over-month revenue growth (window function)

```sql
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::DATE AS month,
        SUM(oi.line_revenue) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT
    month,
    ROUND(revenue::numeric, 2)              AS revenue,
    LAG(revenue) OVER (ORDER BY month)      AS prev_month,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
          / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1) AS mom_growth_pct
FROM monthly
ORDER BY month;
```

### 4. RFM segmentation with NTILE (advanced)

```sql
WITH ref AS (SELECT MAX(order_date) AS today FROM orders WHERE order_status='Delivered'),
customer_rfm AS (
    SELECT
        c.customer_id,
        c.customer_name,
        (SELECT today FROM ref) - MAX(o.order_date) AS recency_days,
        COUNT(DISTINCT o.order_id)                  AS frequency,
        SUM(oi.line_revenue)                        AS monetary
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
```

### 5. Pareto / 80-20 — which products drive 80% of revenue?

```sql
WITH product_rev AS (
    SELECT p.product_id, p.product_name, SUM(oi.line_revenue) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name
),
ranked AS (
    SELECT
        product_name, revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC
                           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        / SUM(revenue) OVER ()                 AS cumulative_share,
        ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rank_n,
        COUNT(*) OVER ()                        AS total_products
    FROM product_rev
)
SELECT
    product_name,
    ROUND(revenue::numeric, 2)                  AS revenue,
    ROUND(cumulative_share::numeric, 3)         AS cum_share,
    ROUND(100.0 * rank_n / total_products, 1)   AS pct_of_products
FROM ranked
WHERE cumulative_share <= 0.80
ORDER BY rank_n;
```

### 6. Market basket — products frequently bought together

```sql
SELECT
    p1.product_name AS product_a,
    p2.product_name AS product_b,
    COUNT(DISTINCT oi1.order_id) AS times_bought_together
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id  = oi2.order_id
                    AND oi1.product_id < oi2.product_id
JOIN products p1 ON p1.product_id = oi1.product_id
JOIN products p2 ON p2.product_id = oi2.product_id
GROUP BY p1.product_name, p2.product_name
HAVING COUNT(DISTINCT oi1.order_id) >= 2
ORDER BY times_bought_together DESC
LIMIT 20;
```

## Full topic list

### 25 basic-to-intermediate queries
Customer counts and segments, total revenue and AOV, top 10 customers by spend, top 5 categories, most popular product per category, monthly revenue trend, day-of-week analysis, payment method distribution, order status breakdown, profit margin per category, never-returned customers, high-frequency customers, order tier tagging, customer tier classification, shipping time by region, never-ordered products, year-over-year growth, products outselling category average, repeat-customer rate, most profitable product, quarter-by-quarter revenue, average discount per category, signup cohort sizes, state-level performance ranking, return rate per product.

### 15 advanced queries
Running cumulative revenue, rank within segment (RANK/DENSE_RANK), LAG/LEAD on order dates, NTILE-based RFM, Pareto 80-20, cohort retention matrix, recursive CTE date dimension, market basket, top product per month, 3-month moving average revenue, cumulative customer spend, statistical outlier orders, percentile ranking (PERCENT_RANK), self-join for state-level customer similarity, pivot-style revenue by category × quarter using FILTER.

## Database schema

| Table | Key columns |
|---|---|
| `customers` | customer_id, customer_name, city, state, signup_date, customer_segment |
| `products` | product_id, product_name, category, sub_category, unit_price, unit_cost |
| `orders` | order_id, customer_id, order_date, payment_method, order_status |
| `order_items` | order_id, product_id, quantity, unit_price_paid, discount_pct, line_revenue |
| `returns` | return_id, order_id, return_date, return_reason |

## How to run

```
psql -d amazon -f code/00_schema_and_load.sql
psql -d amazon -f code/01_basic_to_intermediate.sql
psql -d amazon -f code/02_advanced_queries.sql
```

For SQLite: change `DATE_TRUNC` to `strftime`, `NTILE` to `ROW_NUMBER` substitution, replace `::numeric` casts.

## Author

Md Nazmul Islam Ishan
linkedin.com/in/nazmul-islam-ishan-b707b8171
