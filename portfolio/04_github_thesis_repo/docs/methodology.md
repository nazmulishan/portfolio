# Methodology

This document explains the identification strategy, data sources, sample construction, and robustness checks used in the thesis.

## Research question

Does sustainability reporting quality have a measurable short-term and long-term impact on firm financial performance, and does the impact differ between two institutional settings — Denmark (early CSRD adopter, mandatory rule-based regime) and the United States (voluntary disclosure, fragmented frameworks)?

## Data

| Source | Variable role | Coverage |
|---|---|---|
| Refinitiv ESG | Disclosure quality, ESG composite, E/S/G subscores | 2018–2024, all listed firms with rated scores |
| CRSP daily file | US firm and market daily returns | 2017–2024 |
| Compustat North America | US firm-year financials | 2017–2024 |
| Compustat Global | Danish firm-year financials, daily prices | 2017–2024 |
| Firm IR pages | Sustainability report publication dates | 2018–2024 (for event study) |

Firms are matched across files by ISIN and gvkey. The final panel contains roughly 280 unique firms (~210 US, ~70 Danish), 1,500 firm-year observations.

## Sample construction

1. Start with all listed firms in CRSP (US) and Compustat Global (Denmark) with at least three consecutive fiscal years 2018–2024
2. Drop firms missing more than 20% of accounting controls
3. Drop financial institutions (SIC 6000–6999) — different reporting regime
4. Winsorise all financial variables symmetrically at 1st/99th percentile within country-year
5. Final panel exported to Stata for econometric analysis

## Variables

### Outcome variables
- `ret_30d`, `ret_90d`, `ret_1y` — short-term forward stock returns
- `ret_3y` — long-term cumulative return
- Cumulative abnormal returns (CARs) over event windows [-1,+1], [0,+5], [-5,+5]

### Key explanatory variable
- `high_disclosure` — dummy equal to 1 if a firm's Refinitiv disclosure quality score falls in the top tercile of its country-year, else 0
- A continuous specification is used as robustness

### Controls
- `roa` — return on assets (NI / total assets)
- `leverage` — total debt / total assets
- `size` — log of total assets
- `mtb` — market-to-book ratio
- `sale_growth` — year-over-year sales growth
- Year fixed effects, firm fixed effects, country dummy (US baseline)

## Identification strategy

The headline empirical concern is reverse causality: better-performing firms may disclose more (because they have more to disclose, or because they have more analytical capacity), making OLS estimates biased upward.

The thesis addresses this in three ways:

1. **Firm fixed effects** absorb time-invariant unobservables (industry, governance culture, founder values).
2. **Year fixed effects** absorb common shocks (regulatory changes, market-wide ESG sentiment).
3. **Instrumental variables (2SLS)** uses **leave-one-out industry-year average disclosure quality** as an instrument for the focal firm's disclosure dummy. The exclusion restriction is that peer-industry disclosure pressure shifts firm disclosure behaviour but does not directly affect the firm's own returns conditional on controls. First-stage F-statistics are reported in `output/table_iv.rtf` and consistently exceed 10 (rule-of-thumb threshold for weak-instrument concern).

## Event study design

Following Brown and Warner (1985), the market-model abnormal return is:

```
AR_it = R_it - (α_i + β_i * R_mt)
```

Estimation window: trading days [-250, -50] before the event. Event = first sustainability report publication date for the firm in our sample period. Cumulative ARs computed over [-1,+1], [0,+5], and [-5,+5] windows. Cross-sectional t-tests assess whether mean CARs differ from zero by country.

## Robustness checks

The thesis runs the following additional specifications, all reported in the appendix:

1. Continuous disclosure score instead of top-tercile dummy
2. ESG composite (Refinitiv) instead of disclosure quality
3. Subsamples by industry (manufacturing, services, energy)
4. Drop COVID years (2020–2021) from sample
5. Country-by-country pooled regressions
6. Fama-MacBeth two-step estimation as alternative to panel FE
7. Standard errors clustered alternatively at industry-year and firm-year level

## Limitations

- ESG ratings are noisy and vary across providers (Berg, Kölbel and Rigobon, 2022). Using a single Refinitiv-based measure is a meaningful constraint. The thesis discusses this.
- Selection into ESG rating: only large/listed firms are rated, so external validity to mid-cap and unlisted firms is limited.
- Pre-CSRD period dominates the panel; effects may grow under full mandatory CSRD reporting from 2025 onward.

## Software

- Python 3.12 with pandas/numpy for data preparation (see `code/data_prep.py`)
- Stata 18 with `reghdfe`, `ivreghdfe`, `estout`, `boottest` packages for panel regression and inference

## References

Berg, F., Kölbel, J. F., and Rigobon, R. (2022). Aggregate confusion: The divergence of ESG ratings. *Review of Finance*, 26(6), 1315–1344.

Brown, S. J., and Warner, J. B. (1985). Using daily stock returns: The case of event studies. *Journal of Financial Economics*, 14(1), 3–31.

Friede, G., Busch, T., and Bassen, A. (2015). ESG and financial performance: aggregated evidence from more than 2000 empirical studies. *Journal of Sustainable Finance and Investment*, 5(4), 210–233.

Khan, M., Serafeim, G., and Yoon, A. (2016). Corporate sustainability: first evidence on materiality. *The Accounting Review*, 91(6), 1697–1724.
