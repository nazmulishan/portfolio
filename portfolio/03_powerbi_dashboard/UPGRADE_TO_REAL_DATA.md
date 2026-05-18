# Upgrade this project to use real Energinet API data (30 minutes)

The included `data/danish_energy_production_2018_2024.csv` is a synthetic dataset calibrated to match Energinet/Energistyrelsen reporting patterns. To replace it with **real, live data from Energinet's open API** — and upgrade your portfolio piece from "illustrative" to "real" — follow the steps below.

## Why bother

A recruiter who clicks into this project and sees real Energinet API data being pulled in real time is more impressed than one who sees synthetic data, however well calibrated. The dashboard visuals look identical, but the credibility step-change is large.

## What you need

- Free Energinet account (no credit card)
- Python 3.10+ (already installed if you've set up the rest of the agent)
- 30 minutes

## Step 1: Find the right Energinet dataset

Energinet's open data portal is at **energidataservice.dk**. Datasets relevant to this project:

| Dataset ID | What it contains | Update frequency |
|---|---|---|
| `Productionconsumptionsettlement` | Production by source by area | Daily |
| `ElectricityProdex5MinRealtime` | Real-time production by source, 5-minute intervals | Every 5 min |
| `PowerProductionByCountryAndType` | EU-level production by source | Daily |

For this project, **`Productionconsumptionsettlement`** is the right one. It contains monthly aggregated production by energy source, exactly what the dashboard needs.

## Step 2: Pull a sample from the API in your browser

The API is REST and requires no authentication. Open this URL in your browser:

```
https://api.energidataservice.dk/dataset/Productionconsumptionsettlement?start=2024-01-01&end=2024-12-31&columns=HourDK,PriceArea,GrossConsumptionMWh,CentralPowerMWh,OffshoreWindMWh,OnshoreWindMWh,SolarPowerMWh
```

You should see JSON come back with the records. This confirms the API is reachable from your network.

## Step 3: Pull historical data via a small Python script

Save this as `pull_real_energy_data.py` in the project folder:

```python
import requests, pandas as pd

URL = "https://api.energidataservice.dk/dataset/Productionconsumptionsettlement"

params = {
    "start": "2018-01-01",
    "end":   "2024-12-31",
    "columns": "HourDK,PriceArea,GrossConsumptionMWh,CentralPowerMWh,"
               "OffshoreWindMWh,OnshoreWindMWh,SolarPowerMWh",
    "limit": 1000000,   # one big pull, no pagination needed
}
r = requests.get(URL, params=params)
r.raise_for_status()
records = r.json()["records"]
print(f"Got {len(records):,} hourly records")

df = pd.DataFrame(records)
df["HourDK"] = pd.to_datetime(df["HourDK"])
df["Year"]  = df["HourDK"].dt.year
df["Month"] = df["HourDK"].dt.month

# Aggregate hourly → monthly by source (sum MWh, convert to GWh)
agg = df.groupby(["Year", "Month"], as_index=False).agg({
    "OffshoreWindMWh": "sum",
    "OnshoreWindMWh":  "sum",
    "SolarPowerMWh":   "sum",
    "CentralPowerMWh": "sum",
})

# Convert MWh -> GWh
for col in ["OffshoreWindMWh", "OnshoreWindMWh", "SolarPowerMWh", "CentralPowerMWh"]:
    agg[col.replace("MWh", "GWh")] = agg[col] / 1000.0
    agg = agg.drop(columns=[col])

# Reshape to long format matching the project's expected schema
long = agg.melt(id_vars=["Year", "Month"], var_name="Source", value_name="Production_GWh")
long["Source"] = long["Source"].str.replace("GWh", "").str.replace("Power", "")
long["Date"] = pd.to_datetime(long[["Year", "Month"]].assign(Day=1))
long["Quarter"] = "Q" + ((long["Month"] - 1) // 3 + 1).astype(str)
long = long[["Year", "Month", "Date", "Source", "Production_GWh", "Quarter"]]

long.to_csv("data/danish_energy_production_2018_2024.csv", index=False)
print("Saved real Energinet data")
```

Run it:

```
pip install requests pandas
python pull_real_energy_data.py
```

## Step 4: Re-open the Excel dashboard

`Danish_Energy_Dashboard.xlsx` reads `data/danish_energy_production_2018_2024.csv` via SUMIFS — when you overwrite the CSV with real data, the dashboard updates automatically. No formula edits.

## Step 5: Re-publish to Power BI

If you have a Power BI version, refresh the data source in Power BI Desktop and republish to Power BI Service. Total 5 minutes.

## Step 6: Update the project README

Change the sentence

> "data is synthesised from Energinet / Energistyrelsen reporting patterns"

to

> "live data pulled from Energinet's open API ([energidataservice.dk](https://energidataservice.dk))"

Mention in your CV that you built a Power BI dashboard powered by Energinet's open data API. Recruiters know what that means.

## Alternative if you want to skip the upgrade

The synthetic data is *good enough* for a portfolio piece — the README clearly labels it as illustrative. The upgrade is for when you have 30 spare minutes and want the project to be unambiguously real.
