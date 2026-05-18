# HR Analytics Dashboard — Employee Attrition

A workforce analytics dashboard analysing attrition patterns across 1,470 employees, identifying high-risk segments and quantifying the impact of overtime, satisfaction, and tenure on attrition.

## Data

This repository uses a **synthetic dataset** that matches the schema and distributional patterns of the [IBM HR Analytics Employee Attrition](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset) Kaggle dataset (1,470 employees, 35 features).

**To run the analysis on the real Kaggle data:**

1. Download the IBM HR dataset from the Kaggle link above (free)
2. Save as `data/employee_attrition.csv` (overwriting the synthetic version)
3. Open `HR_Analytics_Dashboard.xlsx` — all formulas update automatically

The synthetic data is calibrated to reproduce the headline metrics from the real Kaggle file (overall attrition ~16%, overtime effect ~3× multiplier, etc.) so the dashboard tells the same story either way.

## What this dashboard shows

- **5 KPI cards**: total employees, attrition rate, average monthly income, overtime share, average tenure
- **Attrition by department** table and bar chart
- **Attrition by overtime** comparison
- **Insights block** with five observations about workforce risk patterns

## Key findings

- Overall attrition rate ~16% (matches IBM's published benchmark of 16.1%)
- Employees working overtime show ~3× the attrition rate of those who do not
- Sales department has the highest attrition; R&D the lowest
- Low job satisfaction (rating 1 of 4) strongly predicts attrition
- The first two years at company are the highest-risk period

## Files

```
.
├── README.md                          (this file)
├── data/
│   └── employee_attrition.csv         (1,470 rows, synthetic IBM-schema)
├── HR_Analytics_Dashboard.xlsx        (interactive Excel dashboard)
└── build_hr.py                        (regenerates the dataset)
```

## To rebuild in Power BI Desktop

1. Power BI Desktop → Get Data → Text/CSV → `data/employee_attrition.csv`
2. Drag `Department`, `OverTime`, `JobSatisfaction` to slicers
3. Build these 4 visuals:
   - KPI cards (Headcount, Attrition rate, Avg Income)
   - Stacked bar: Attrition by Department
   - Donut: Attrition rate split by OverTime (Yes/No)
   - Line: Attrition rate by YearsAtCompany
4. Apply Calibri 11pt theme, navy accents
5. Publish → File → Share → Generate link

## Why this matters for the job hunt

Demonstrates: (a) clean data preparation and modelling, (b) standard HR-analytics method (attrition rate decomposition, segment analysis), (c) ability to translate raw HR data into actionable workforce signals.

Useful for: Reporting Analyst roles, Operations Analyst roles, HR Analytics roles in shared service centres, BI Developer Junior roles.

## Author

Md Nazmul Islam Ishan
