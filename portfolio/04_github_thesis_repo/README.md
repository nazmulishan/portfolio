# Sustainability Reporting and Financial Performance — Empirical Analysis

A cleaned and anonymised version of the analytical code from my MSc thesis at the University of Southern Denmark (2025).

**Thesis title:** *The Short-Term and Long-Term Financial Impact of Sustainability Reporting: A Comparative Study Between Denmark and the USA*

**Methods:** Event study with abnormal returns, panel regression with firm and year fixed effects, instrumental variables for endogeneity, and standard robustness checks.

---

## What is in this repository

```
.
├── code/
│   ├── data_prep.py        # Python data assembly + cleaning
│   ├── main_analysis.do    # Stata: panel regressions, fixed effects, IV
│   └── event_study.do      # Stata: market-model abnormal returns + CARs
├── docs/
│   └── methodology.md      # Methodology explanation, identification strategy
├── data/
│   └── README.md           # Data sources and license notes (no actual data committed)
└── requirements.txt        # Python dependencies
```

The actual thesis data is **not** committed to this repository because the licensed Refinitiv ESG and CRSP-Compustat extracts cannot be redistributed. The code is structured so anyone with access to those data sources can reproduce the analysis end-to-end.

## Reproducing the analysis

1. Obtain Refinitiv ESG, CRSP-Compustat, and Compustat Global extracts for the firms and years in `docs/methodology.md`
2. Place raw CSV files in `data/raw/` (paths matched in `code/data_prep.py`)
3. Run Python data preparation: `python code/data_prep.py` — produces `data/processed/panel.csv`
4. Run Stata main analysis: `do code/main_analysis.do`
5. Run Stata event study: `do code/event_study.do`
6. Outputs save to `output/` (regression tables, CARs by event window, robustness checks)

## Author

Md Nazmul Islam Ishan
MSc Economics and Business Administration, Management Accounting profile
University of Southern Denmark, Aug 2025

## License

Code released under MIT. Data are not redistributed.
