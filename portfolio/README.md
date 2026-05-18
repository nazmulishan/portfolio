# Portfolio — Md Nazmul Islam Ishan

Public, reviewable work samples that back up the technical claims on my CV. Built using public datasets (Energinet, Kaggle, Maersk Annual Reports) wherever possible; synthetic data is clearly labelled.

| # | Project | What it demonstrates | Data |
|---|---|---|---|
| 1 | ESG Disclosure & Financial Performance — research synthesis | ESG / sustainability subject-matter expertise, academic writing, citation discipline | 5 real cited studies |
| 2 | Ørsted DCF Valuation Model — Excel | Financial modelling, formula chains, sensitivity analysis | Illustrative (calibrated to public Ørsted figures) |
| 3 | Danish Energy Production Dashboard — Power BI / Excel | Data analysis, dashboarding, KPI cards, slicers | Calibrated to Energinet patterns; **upgrade path to real Energinet API included** |
| 4 | MSc Thesis — sustainability reporting empirical analysis | Stata + Python, panel regression with fixed effects, IV, event study | Code only (data licensed) |
| 5 | SQL Cohort & RFM Analysis — Brazilian E-commerce | Multi-table joins, window functions, CTEs, cohort logic | Olist Kaggle public dataset (~100k orders) |
| 6 | Maersk Financial Dashboard 2018-2024 — Excel | Financial-statement literacy, public-data reconciliation, interpretive narrative | **Real public data from Maersk Annual Reports** |
| 7 | HR Analytics Dashboard — Power BI / Excel | Workforce analytics, attrition decomposition, segment analysis | IBM HR schema (Kaggle); synthetic at 1,470 employees |

## CV Projects section

These map to the `PROJECTS` section of my CV like this:

```
PROJECTS

ESG Disclosure & Financial Performance — Research Synthesis
Two-page synthesis of empirical evidence with Danish CSRD implications.
github.com/<me>/portfolio/01_esg_analysis

Ørsted DCF Valuation Model — Excel
Six-sheet model: assumptions, income statement, free cash flow, WACC,
valuation, sensitivity (color-scale matrix).
github.com/<me>/portfolio/02_excel_dcf

Danish Energy Production Dashboard — Power BI
Source mix analysis using DAX measures, slicers, and visual storytelling.
Live: app.powerbi.com/view?r=<id>
github.com/<me>/portfolio/03_powerbi_dashboard

MSc Thesis — Sustainability Reporting Empirical Analysis
Panel regression with firm/year FE, IV with peer-industry instrument,
event-study CARs. Stata + Python.
github.com/<me>/portfolio/04_github_thesis_repo

SQL Cohort & RFM Analysis — Brazilian E-commerce
Window functions, CTEs, cohort retention and RFM segmentation on
100,000+ Olist transactions.
github.com/<me>/portfolio/05_sql_cohort_rfm

Maersk Financial Dashboard 2018-2024 — Excel
Revenue, margin, cash flow, and balance-sheet analysis built from
seven years of public Maersk Annual Reports.
github.com/<me>/portfolio/06_maersk_financial_dashboard

HR Analytics — Employee Attrition Dashboard
Attrition decomposition by department, overtime, tenure, satisfaction.
1,470-employee IBM-schema dataset.
github.com/<me>/portfolio/07_hr_analytics_powerbi
```

## Data sources, summarised

| Project | Where data really comes from |
|---|---|
| 01 ESG analysis | Real published studies (Berg/Friede/Khan/Christensen/Eccles) |
| 02 Ørsted DCF | Illustrative inputs calibrated to public Ørsted figures |
| 03 Energy dashboard | Synthetic now; upgrade path to **Energinet open API** documented |
| 04 Thesis repo | Code only; data was licensed Refinitiv/CRSP/Compustat |
| 05 SQL cohort/RFM | **Real Olist Kaggle public dataset** |
| 06 Maersk dashboard | **Real Maersk Annual Report data (investor.maersk.com)** |
| 07 HR analytics | Synthetic IBM HR Attrition schema; real Kaggle file is drop-in compatible |

## How to deploy

1. Create a GitHub repo `portfolio` (private is fine)
2. Upload all seven folders + the top-level `README.md`
3. For project 3 (Power BI), follow the build guide to publish to Power BI Service and get the public link
4. For project 5 (SQL), download the Olist Kaggle CSVs into `data/raw/` to actually run the queries
5. Update your CV's `PROJECTS` section with the GitHub URLs

## Honest interview defence for each project

- **01 ESG**: "Original literature synthesis. Cited studies are real, framing for Danish CSRD is mine."
- **02 DCF**: "Portfolio modelling exercise with illustrative inputs calibrated to public Ørsted figures. The model logic is mine. Not an investment recommendation."
- **03 Energy**: "Dashboard built on data following real Energinet reporting patterns. Synthetic now; upgrade to live API documented in the project."
- **04 Thesis**: "Cleaned analytical code from my MSc thesis at SDU. Licensed data not redistributed."
- **05 SQL**: "Real Olist Kaggle public dataset. SQL is mine."
- **06 Maersk**: "100% real public financial data from Maersk Annual Reports 2018-2024. Reconciled figures myself."
- **07 HR**: "1,470-employee dataset following IBM HR Attrition schema. Patterns calibrated to match published benchmarks; real Kaggle data drops in identically."
