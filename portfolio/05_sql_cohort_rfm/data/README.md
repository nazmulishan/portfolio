# Data

The Olist Brazilian E-commerce dataset is **not** committed to this repository because of its size (~140 MB) and because Kaggle's terms encourage download via their platform.

## To run the analysis with real data

1. Go to **kaggle.com/datasets/olistbr/brazilian-ecommerce**
2. Click "Download" (free Kaggle account required)
3. Unzip the 9 CSV files into `data/raw/`
4. Run `psql -d olist -f code/run_all.sql`

## Expected files in data/raw/

```
olist_customers_dataset.csv
olist_geolocation_dataset.csv
olist_order_items_dataset.csv
olist_order_payments_dataset.csv
olist_order_reviews_dataset.csv
olist_orders_dataset.csv
olist_products_dataset.csv
olist_sellers_dataset.csv
product_category_name_translation.csv
```

## Dataset license

Public on Kaggle, redistributed under CC BY-NC-SA 4.0 (Olist's choice). Analysis code is MIT.
