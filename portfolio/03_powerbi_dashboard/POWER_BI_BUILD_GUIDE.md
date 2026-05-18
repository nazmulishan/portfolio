# Power BI dashboard — build guide

This guide walks you from the included CSV dataset to a published Power BI dashboard you can link from your CV. Time required: ~30 minutes.

## What you have

- `data/danish_energy_production_2018_2024.csv` — 504 rows, six energy sources, monthly granularity, 2018-2024 (illustrative figures calibrated to Energinet/Energistyrelsen reporting patterns)
- `Danish_Energy_Dashboard.xlsx` — fully working Excel dashboard built from the same data, with KPI cards, stacked bar chart, and pie chart
- This guide

## Why both Excel AND Power BI?

The Excel dashboard is your immediate portfolio piece — it works without any Microsoft account and you can host it on GitHub today. The Power BI version is the one you put a public link to from your CV. The same dataset, two formats, two skills demonstrated.

---

## Step 1: install Power BI Desktop (one-time)

1. Go to **powerbi.microsoft.com/desktop**
2. Click "Download free"
3. Install. Open Power BI Desktop. Sign in with the same Microsoft account you'll use to publish.

(If you don't have a Microsoft account, create a free one at outlook.com first.)

## Step 2: load the data

1. Open Power BI Desktop
2. Click **Home → Get data → Text/CSV**
3. Browse to `data/danish_energy_production_2018_2024.csv`
4. Click **Load** (no transformations needed — it's already clean)
5. The data appears in the right-side **Data** pane

## Step 3: build the visuals

Aim for **4 visuals on a single page**, each in its own quadrant.

### Visual 1 (top-left): KPI cards row

1. Click the **Card** visual in the Visualizations pane
2. Drag `Production_GWh` into the Fields well — it shows as Sum
3. The card displays total production. Resize small (~3cm wide).
4. Duplicate the card three times (Ctrl+C, Ctrl+V) — change the field's filter to one source per card:
   - Card 2: filter Source = Wind, rename to "Wind GWh"
   - Card 3: filter Source = Solar, rename to "Solar GWh"
   - Card 4: filter Source = Coal, rename to "Coal GWh"
5. Line up four cards in a row across the top of the page

### Visual 2 (top-right): Annual production by source — stacked bar

1. Click **Stacked column chart** in Visualizations
2. Drag `Year` to the X-axis
3. Drag `Source` to the Legend
4. Drag `Production_GWh` to the Y-axis (it sums automatically)
5. Title: "Annual production by source (GWh)"
6. Resize to fill the top-right quadrant

### Visual 3 (bottom-left): 2024 source mix — donut

1. Click **Donut chart**
2. Drag `Source` to Legend
3. Drag `Production_GWh` to Values
4. In the **Filters on this visual** pane, drag `Year` and set "is" `2024`
5. Title: "2024 source mix"

### Visual 4 (bottom-right): Monthly trend — line chart

1. Click **Line chart**
2. Drag `Date` to X-axis (Power BI treats it as a date hierarchy — keep month-year)
3. Drag `Production_GWh` to Y-axis
4. Drag `Source` to Legend (creates one line per source)
5. Title: "Monthly production trend"

## Step 4: add slicers (interactivity)

1. Click **Slicer** visual
2. Drag `Year` to Field
3. Slicer style: Dropdown
4. Resize small, place top of page above visuals
5. Repeat for `Quarter` (place next to year slicer)
6. Repeat for `Source` (multi-select dropdown)

Now any selection on these slicers filters all four visuals at once.

## Step 5: theme and polish

1. Home tab → **Themes → Default → ESG accent** (or pick any blue theme)
2. Add a text box at the top of the page:
   - "Danish Energy Production Dashboard 2018-2024"
   - "Source: Energinet / Energistyrelsen reporting (illustrative dataset)"
   - "Author: Md Nazmul Islam Ishan"
3. Use the Format pane to clean up: hide axis titles where unnecessary, increase font size on titles, align everything to a grid

## Step 6: publish to Power BI Service

1. Click **Home → Publish**
2. Choose your workspace (My workspace is fine)
3. Once uploaded, open **app.powerbi.com**
4. Find your report. Click it.
5. Click **File → Share → Publish to web** (or "Share" → "Generate link")
6. Power BI gives you an embeddable public link
7. Copy that link

## Step 7: add to CV and GitHub

In your CV's PROJECTS section:

```
Power BI Dashboard — Danish Energy Production 2018-2024
Source-mix and trend analysis using DAX measures, slicers, and visual storytelling.
Live: app.powerbi.com/view?r=<your-id>
Source data and Excel version: github.com/<your-username>/portfolio/03_powerbi_dashboard
```

In your GitHub `portfolio` repo, commit the `03_powerbi_dashboard/` folder including this guide, the CSV, and the Excel file. Add the Power BI link to that folder's README.

---

## Troubleshooting

**"Can't publish — workspace not found"**
You need a Power BI Pro trial OR free workspace. Sign up free at app.powerbi.com.

**"Public link feature is greyed out"**
Some tenants restrict Publish to web. Use **Share → Get embed link** instead, or make the workspace public.

**"My visuals look different from the screenshot"**
That's fine — the layout is just suggested. Power BI defaults vary by version.

## What this project demonstrates

When someone asks at interview "tell me about a Power BI project", you say:

"I built a dashboard analysing seven years of Danish energy production by source. The dataset has 504 monthly records across six sources. I built four visuals — KPI cards for headline figures, a stacked column for annual mix, a donut for the 2024 snapshot, and a line chart for monthly trends — with three slicers for year, quarter, and source so the entire page filters interactively. I also built the same dashboard in Excel as a fallback for environments where Power BI isn't available, using SUMIFS formulas, conditional formatting, and pivot-style aggregations."

That's a real, defensible answer. Have the link open on your phone during the interview.
