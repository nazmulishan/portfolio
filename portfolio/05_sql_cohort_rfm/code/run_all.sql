-- One-command pipeline. Run with:  psql -d olist -f run_all.sql
\i 00_schema.sql
\i 01_data_load.sql
\i 02_unified_view.sql
\i 03_cohort_retention.sql
\i 04_rfm_segmentation.sql
\i 05_customer_lifetime_value.sql
