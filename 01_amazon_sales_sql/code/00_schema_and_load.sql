-- =====================================================================
-- Amazon Sales Analysis — schema, indexes, and sample data load
-- PostgreSQL 14+
-- =====================================================================

DROP TABLE IF EXISTS returns      CASCADE;
DROP TABLE IF EXISTS order_items  CASCADE;
DROP TABLE IF EXISTS orders       CASCADE;
DROP TABLE IF EXISTS products     CASCADE;
DROP TABLE IF EXISTS customers    CASCADE;

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email         VARCHAR(150) UNIQUE,
    city          VARCHAR(80),
    state         CHAR(2),
    country       VARCHAR(60)  DEFAULT 'USA',
    signup_date   DATE         NOT NULL,
    customer_segment VARCHAR(20)  -- 'Consumer', 'Corporate', 'Home Office'
);

CREATE TABLE products (
    product_id    SERIAL PRIMARY KEY,
    product_name  VARCHAR(200) NOT NULL,
    category      VARCHAR(60),
    sub_category  VARCHAR(80),
    unit_price    NUMERIC(10, 2) NOT NULL,
    unit_cost     NUMERIC(10, 2) NOT NULL,
    brand         VARCHAR(80),
    weight_kg     NUMERIC(8, 3)
);

CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id),
    order_date      DATE NOT NULL,
    ship_date       DATE,
    delivery_date   DATE,
    payment_method  VARCHAR(30),   -- 'Credit Card', 'Debit Card', 'Prime Pay', 'Gift Card', 'EMI'
    order_status    VARCHAR(20),   -- 'Delivered', 'Cancelled', 'Returned', 'Pending'
    shipping_cost   NUMERIC(8, 2)  DEFAULT 0
);

CREATE TABLE order_items (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INT NOT NULL REFERENCES orders(order_id),
    product_id      INT NOT NULL REFERENCES products(product_id),
    quantity        INT  NOT NULL,
    unit_price_paid NUMERIC(10, 2),    -- price the customer actually paid (after discount)
    discount_pct    NUMERIC(5,  2)  DEFAULT 0,
    line_revenue    NUMERIC(12, 2)     -- quantity * unit_price_paid
);

CREATE TABLE returns (
    return_id     SERIAL PRIMARY KEY,
    order_id      INT REFERENCES orders(order_id),
    return_date   DATE,
    return_reason VARCHAR(80)         -- 'Defective', 'Wrong Item', 'No longer needed', etc.
);

-- Performance indexes
CREATE INDEX idx_orders_customer  ON orders(customer_id);
CREATE INDEX idx_orders_date      ON orders(order_date);
CREATE INDEX idx_items_order      ON order_items(order_id);
CREATE INDEX idx_items_product    ON order_items(product_id);
CREATE INDEX idx_returns_order    ON returns(order_id);
CREATE INDEX idx_customers_segment ON customers(customer_segment);
CREATE INDEX idx_products_category ON products(category);

-- =====================================================================
-- Sample data (small, to verify queries run end-to-end)
-- For real Amazon-scale analysis, replace these inserts with
-- COPY statements from the Kaggle Amazon dataset CSVs.
-- =====================================================================

INSERT INTO customers (customer_name, email, city, state, signup_date, customer_segment) VALUES
('Anders Nielsen',  'anders.n@example.com',  'Copenhagen', 'CA', '2023-01-15', 'Consumer'),
('Maria Hansen',    'maria.h@example.com',   'Aarhus',     'NY', '2023-02-08', 'Corporate'),
('Lars Christensen','lars.c@example.com',    'Odense',     'TX', '2023-03-20', 'Consumer'),
('Sofie Pedersen',  'sofie.p@example.com',   'Aalborg',    'FL', '2023-04-11', 'Home Office'),
('Jakob Mortensen', 'jakob.m@example.com',   'Esbjerg',    'WA', '2023-05-02', 'Consumer'),
('Ida Sørensen',    'ida.s@example.com',     'Randers',    'IL', '2023-06-17', 'Corporate'),
('Mikkel Rasmussen','mikkel.r@example.com',  'Kolding',    'CO', '2023-07-29', 'Consumer'),
('Emma Jensen',     'emma.j@example.com',    'Horsens',    'MA', '2023-08-12', 'Consumer'),
('Oliver Olsen',    'oliver.o@example.com',  'Vejle',      'GA', '2023-09-03', 'Home Office'),
('Freja Andersen',  'freja.a@example.com',   'Roskilde',   'OR', '2023-10-25', 'Consumer');

INSERT INTO products (product_name, category, sub_category, unit_price, unit_cost, brand) VALUES
('Echo Dot (5th Gen)',         'Electronics', 'Smart Speakers', 49.99,  22.50, 'Amazon'),
('Kindle Paperwhite',          'Electronics', 'E-Readers',      139.99, 78.00, 'Amazon'),
('Fire TV Stick 4K',           'Electronics', 'Streaming',      49.99,  21.00, 'Amazon'),
('Atomic Habits',              'Books',       'Self-Help',      18.99,   5.20, 'Penguin'),
('The Psychology of Money',    'Books',       'Finance',        16.99,   4.80, 'Harriman'),
('Instant Pot Duo 7-in-1',     'Home & Kitchen', 'Appliances',  99.99,  42.00, 'Instant'),
('Stanley Quencher Tumbler',   'Home & Kitchen', 'Drinkware',   45.00,  14.00, 'Stanley'),
('Adidas Running Shoes',       'Sports',      'Footwear',       89.99,  36.00, 'Adidas'),
('Yoga Mat Premium',           'Sports',      'Fitness',        29.99,   9.50, 'Liforme'),
('CeraVe Moisturizing Cream',  'Beauty',      'Skincare',       19.99,   6.20, 'CeraVe');

-- 30 orders across the customers (small sample)
INSERT INTO orders (customer_id, order_date, ship_date, delivery_date, payment_method, order_status, shipping_cost) VALUES
(1, '2024-01-05', '2024-01-06', '2024-01-08', 'Prime Pay',   'Delivered',  0.00),
(2, '2024-01-12', '2024-01-13', '2024-01-15', 'Credit Card', 'Delivered',  4.99),
(3, '2024-02-03', '2024-02-04', '2024-02-07', 'Debit Card',  'Delivered',  4.99),
(4, '2024-02-18', '2024-02-19', '2024-02-22', 'Prime Pay',   'Returned',   0.00),
(5, '2024-03-09', '2024-03-10', '2024-03-12', 'Credit Card', 'Delivered',  0.00),
(6, '2024-03-22', '2024-03-23', '2024-03-26', 'Gift Card',   'Cancelled',  0.00),
(7, '2024-04-01', '2024-04-02', '2024-04-05', 'Prime Pay',   'Delivered',  0.00),
(8, '2024-04-15', '2024-04-16', '2024-04-19', 'EMI',         'Delivered',  0.00),
(9, '2024-05-04', '2024-05-05', '2024-05-08', 'Credit Card', 'Delivered',  4.99),
(10,'2024-05-19', '2024-05-20', '2024-05-22', 'Prime Pay',   'Delivered',  0.00),
(1, '2024-06-08', '2024-06-09', '2024-06-11', 'Prime Pay',   'Delivered',  0.00),
(2, '2024-06-25', '2024-06-26', '2024-06-29', 'Credit Card', 'Delivered',  4.99),
(3, '2024-07-12', '2024-07-13', '2024-07-15', 'Debit Card',  'Delivered',  4.99),
(4, '2024-07-30', '2024-07-31', '2024-08-03', 'Prime Pay',   'Delivered',  0.00),
(5, '2024-08-14', '2024-08-15', '2024-08-17', 'Credit Card', 'Delivered',  0.00),
(6, '2024-08-28', '2024-08-29', '2024-09-01', 'Gift Card',   'Delivered',  4.99),
(7, '2024-09-10', '2024-09-11', '2024-09-13', 'Prime Pay',   'Delivered',  0.00),
(8, '2024-09-24', '2024-09-25', '2024-09-27', 'EMI',         'Returned',   0.00),
(9, '2024-10-07', '2024-10-08', '2024-10-10', 'Credit Card', 'Delivered',  4.99),
(10,'2024-10-21', '2024-10-22', '2024-10-24', 'Prime Pay',   'Delivered',  0.00),
(1, '2024-11-05', '2024-11-06', '2024-11-08', 'Prime Pay',   'Delivered',  0.00),
(2, '2024-11-19', '2024-11-20', '2024-11-22', 'Credit Card', 'Delivered',  4.99),
(3, '2024-12-03', '2024-12-04', '2024-12-06', 'Debit Card',  'Delivered',  4.99),
(4, '2024-12-15', '2024-12-16', '2024-12-19', 'Prime Pay',   'Delivered',  0.00),
(5, '2024-12-27', '2024-12-28', '2024-12-30', 'Credit Card', 'Delivered',  0.00);

INSERT INTO order_items (order_id, product_id, quantity, unit_price_paid, discount_pct, line_revenue) VALUES
(1,  1, 2, 49.99, 0,  99.98),
(2,  6, 1, 99.99, 0,  99.99),
(3,  4, 3, 18.99, 0,  56.97),
(4,  3, 1, 49.99, 0,  49.99),
(5,  2, 1, 139.99, 0, 139.99),
(6,  7, 2, 45.00, 10, 81.00),
(7,  9, 1, 29.99, 0,  29.99),
(8,  8, 1, 89.99, 0,  89.99),
(9,  5, 2, 16.99, 0,  33.98),
(10, 10, 3, 19.99, 0, 59.97),
(11, 1, 1, 49.99, 5,  47.49),
(12, 6, 1, 99.99, 0,  99.99),
(13, 4, 2, 18.99, 0,  37.98),
(14, 3, 2, 49.99, 0,  99.98),
(15, 2, 1, 139.99, 0, 139.99),
(16, 7, 1, 45.00, 0,  45.00),
(17, 9, 2, 29.99, 0,  59.98),
(18, 8, 1, 89.99, 0,  89.99),
(19, 5, 1, 16.99, 0,  16.99),
(20, 10, 2, 19.99, 0, 39.98),
(21, 1, 3, 49.99, 0, 149.97),
(22, 6, 1, 99.99, 5, 94.99),
(23, 4, 4, 18.99, 0, 75.96),
(24, 3, 1, 49.99, 0,  49.99),
(25, 2, 2, 139.99, 0, 279.98);

INSERT INTO returns (order_id, return_date, return_reason) VALUES
(4,  '2024-02-25', 'Defective'),
(18, '2024-09-30', 'No longer needed');

-- Verify load
SELECT 'customers'   AS table_name, COUNT(*) AS rows FROM customers
UNION ALL SELECT 'products',  COUNT(*) FROM products
UNION ALL SELECT 'orders',    COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'returns',   COUNT(*) FROM returns;
