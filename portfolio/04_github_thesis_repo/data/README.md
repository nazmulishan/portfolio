# Data

The actual thesis data (Refinitiv ESG, CRSP-Compustat, Compustat Global) is licensed and **not** redistributed in this repository. The code is structured so that anyone with access to those data sources can reproduce the analysis end-to-end.

## Expected file structure

```
data/
├── raw/
│   ├── refinitiv_esg.csv         # firm-year ESG scores
│   ├── compustat_us.csv          # US firm-year financials + returns
│   ├── compustat_global.csv      # Danish firm-year financials + returns
│   ├── event_returns.csv         # firm-day stock and market returns (event window)
│   └── event_dates.csv           # firm + sustainability report event date
└── processed/
    └── (created by data_prep.py)
```

## Required columns per file

See header of `code/data_prep.py` for `refinitiv_esg.csv`, `compustat_us.csv`, and `compustat_global.csv` schemas.

`event_returns.csv` columns: `gvkey`, `date` (YYYY-MM-DD), `ret_firm`, `ret_market`, `country`

`event_dates.csv` columns: `gvkey`, `event_date` (YYYY-MM-DD), `country`

## Anonymisation

If you are reproducing on a different sample and want to share results publicly, replace the `gvkey` identifiers with sequential integers before committing any processed output, and remove any company names from intermediate files.
