# Amazon Sales Dashboard — Power BI

An interactive Power BI dashboard analysing 2024 Amazon sales by category, region, and time. KPI cards, trend charts, regional split, and category performance — all on one page with cross-filtering slicers.

## Dashboard preview

![Amazon Sales Dashboard Preview](images/dashboard_preview.png)

## What the dashboard shows

- **5 KPI cards** at the top: Total Revenue, Total Orders, Unique Customers, Average Order Value, Top Category — each with year-over-year change indicator
- **Monthly revenue trend** with category breakouts (line chart with category overlay)
- **Revenue by category** (horizontal bar chart, sorted)
- **Revenue share by region** (donut chart)
- **Category performance table** showing revenue and order count per category
- **Monthly category mix** (stacked bar chart) showing how the product mix changes through the year
- **Slicers** for Year, Quarter, Region, Category (interactive filtering on every visual)

## Dataset

- **288 rows** of aggregated Amazon-style sales data across 2024
- 6 categories (Electronics, Home & Kitchen, Books, Sports, Beauty, Toys)
- 4 regions (North America, Europe, Asia Pacific, Latin America)
- Monthly granularity, full 12 months


The dataset is generated to mirror real Amazon-scale sales patterns (seasonality peaks in November and December, electronics as top category, North America as largest region). For real Amazon data analysis, the Kaggle Amazon Reviews 2023 dataset is a drop-in replacement.

## Key findings

1. **Total revenue: $29.6M** for 2024 across 82K orders and 53K unique customers
2. **November–December seasonality is strong**: combined Q4 revenue ~38% higher than Q1
3. **Electronics is the top category** at $9.7M (33% of revenue)
4. **North America accounts for ~52%** of revenue; Europe is second at ~24%
5. **Average order value: $361** — consistent with Amazon's premium-product mix

## Author

Md Nazmul Islam Ishan
linkedin.com/in/nazmul-islam-ishan-b707b8171

