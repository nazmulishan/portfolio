# SQL Cohort & RFM Analysis — Brazilian E-commerce

Customer cohort retention and RFM (Recency, Frequency, Monetary) segmentation built on the Olist Brazilian E-commerce public dataset.

## Dataset

**Source:** [Olist Brazilian E-commerce Public Dataset on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

- 100,000+ orders placed between September 2016 and October 2018
- Real anonymised transactions from Olist, a Brazilian marketplace
- 9 related tables: orders, order items, customers, products, sellers, payments, reviews, geolocation, categories
- Free to download, public, well-documented

This repository ships a **sample subset** (5,000 orders) for quick exploration and CI, plus the SQL scripts that work identically on the full Kaggle download.

## What this project demonstrates

| Skill | Where in the code |
|---|---|
| Multi-table joins (9 tables, several many-to-many) | `code/01_data_load.sql`, `code/02_unified_view.sql` |
| Window functions (LAG, LEAD, ROW_NUMBER, NTILE) | `code/04_rfm_segmentation.sql` |
| CTEs (recursive and chained) | `code/03_cohort_retention.sql` |
| Date arithmetic and cohorts | `code/03_cohort_retention.sql` |
| Performance-aware indexing | `code/00_schema.sql` |
| Reproducible analytical pipelines | `code/run_all.sql` |

## Setup (PostgreSQL or SQLite)

1. Install PostgreSQL 14+ or SQLite 3
2. Clone this repo
3. Download the Olist dataset CSVs from the Kaggle link above into `data/raw/`
4. Run `psql -d olist -f code/run_all.sql` (PostgreSQL) or `sqlite3 olist.db < code/run_all.sql` (SQLite)
5. Outputs are written to `output/` as CSV

## Key findings (from the analysis on the full dataset)

- **Cohort retention** drops rapidly: ~85% of customers never make a second purchase within 12 months
- **RFM segmentation** identifies a "Champions" segment (top RFM scores) representing ~7% of customers but ~28% of revenue
- **Best customer geography**: São Paulo state customers show ~40% higher average order value than national mean
- **Payment method matters**: customers paying with boleto bancário show 12% lower repeat rate than credit card customers

## Files

```
.
├── README.md                       (this file)
├── code/
│   ├── 00_schema.sql               table definitions, indexes
│   ├── 01_data_load.sql            load Kaggle CSVs into tables
│   ├── 02_unified_view.sql         denormalised view for analysis
│   ├── 03_cohort_retention.sql     month-cohort retention matrix
│   ├── 04_rfm_segmentation.sql     RFM scoring + customer segments
│   ├── 05_customer_lifetime_value.sql  CLV by cohort
│   └── run_all.sql                 single-command pipeline
├── data/
│   ├── README.md                   data source notes
│   └── raw/                        place Kaggle CSVs here (gitignored)
└── output/                         analysis results in CSV
```

## Author

Md Nazmul Islam Ishan
MSc Economics and Business Administration, Management Accounting
University of Southern Denmark, 2025

## License

MIT (code only — data licensing per Olist/Kaggle terms)
