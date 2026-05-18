# Maersk Financial Analysis Dashboard 2018–2024

Seven-year financial dashboard for A.P. Møller-Maersk (CPH:MAERSK B), built from publicly disclosed annual report data.

## Data source

**100% public, real data** sourced from Maersk's annual reports 2018-2024 at [investor.maersk.com](https://investor.maersk.com). All figures are USD billions as Maersk reports in USD.

| Source | What |
|---|---|
| Maersk Annual Report 2018-2024 | Revenue, EBITDA, EBIT, Net Income, Free Cash Flow, Capex, Net Debt |
| Fleet & headcount disclosures | Vessels operated, container volumes (TEU), headcount |

## What this dashboard shows

- KPI cards: revenue, EBITDA, net income, free cash flow, EBITDA margin (2024)
- Line chart: 7-year trend of all four profitability series
- Margin evolution: EBITDA, EBIT, and net margin year-by-year
- Insights block: 5 observations about Maersk's strategic transformation 2018-2024

## Key observations from the analysis

- Revenue more than doubled from $39B (2018) to $81B (2022) on the COVID-era container shipping boom
- EBITDA margin peaked at 45% in 2022 — historically unprecedented for shipping — and has since normalised to ~22% in 2024
- Net debt swung from $11.7B (2019) to *negative* $10.0B net cash (2022), then back to $8.1B as Maersk deployed capital into terminals and logistics acquisitions
- Vessel fleet shrunk from 787 to 689 as Maersk pivots from pure shipping to integrated logistics
- Capex stepped up materially from 2022 onward, reflecting the logistics investment programme

## Files

```
.
├── README.md                       (this file)
├── data/
│   └── maersk_financials_2018_2024.csv   (real public data, 7 years × 10 metrics)
├── Maersk_Financial_Dashboard.xlsx (interactive dashboard with KPI cards, charts)
└── build_maersk.py                 (Python script that builds the dashboard)
```

## To rebuild in Power BI

1. Open Power BI Desktop
2. Get Data → Text/CSV → select `data/maersk_financials_2018_2024.csv`
3. Drag `Year` to a slicer
4. Build 4 visuals: revenue line chart, profitability stacked bar, margin trend, KPI cards
5. Publish to Power BI Service and copy the public link

## Why this matters for the job hunt

Demonstrates: (a) ability to source and reconcile public financial data, (b) financial-statement literacy (revenue, EBITDA, margins, net debt swings), (c) interpretive narrative on a real Danish C25 company's strategic story.

Useful for: Junior Financial Analyst, Reporting Analyst, Equity Research junior roles, Big Four audit roles where Maersk is a client.

## Author

Md Nazmul Islam Ishan
