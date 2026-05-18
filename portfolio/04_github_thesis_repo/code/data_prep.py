"""
Data preparation for the sustainability-reporting / financial-performance
panel analysis.

Reads three raw extracts:
  - data/raw/refinitiv_esg.csv       (firm-year ESG scores and components)
  - data/raw/compustat_us.csv        (US firm-year financials)
  - data/raw/compustat_global.csv    (Danish firm-year financials)

Produces:
  - data/processed/panel.csv         (long firm-year panel ready for Stata)

Input columns expected:
  refinitiv_esg.csv:    isin, year, esg_total, env_score, soc_score, gov_score,
                        disclosure_quality, country_iso
  compustat_us.csv:     gvkey, year, sale, ni, at, ceq, dlc, dltt, ret_1d,
                        ret_30d, ret_90d, ret_1y, ret_3y, mkt_cap, beta_60m
  compustat_global.csv: gvkey, year, sale, ni, at, ceq, dlc, dltt, ret_1d,
                        ret_30d, ret_90d, ret_1y, ret_3y, mkt_cap, beta_60m

Run from project root:
    python code/data_prep.py
"""

from pathlib import Path
import logging

import pandas as pd
import numpy as np

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("data_prep")

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "data" / "raw"
PROC = ROOT / "data" / "processed"
PROC.mkdir(parents=True, exist_ok=True)


def winsorize(series: pd.Series, lower: float = 0.01, upper: float = 0.99) -> pd.Series:
    """Symmetric winsorisation at the 1st and 99th percentiles by default."""
    lo, hi = series.quantile([lower, upper])
    return series.clip(lower=lo, upper=hi)


def main() -> None:
    log.info("Loading raw extracts…")
    esg = pd.read_csv(RAW / "refinitiv_esg.csv")
    us  = pd.read_csv(RAW / "compustat_us.csv")
    eu  = pd.read_csv(RAW / "compustat_global.csv")

    # ----------------------------------------------------------------
    # 1. Merge financials with ESG on isin + year
    # ----------------------------------------------------------------
    log.info("Stacking US and Danish financial extracts…")
    us["country"] = "US"
    eu["country"] = "DK"
    fin = pd.concat([us, eu], ignore_index=True)

    log.info("Joining ESG to financial data…")
    panel = fin.merge(esg, on=["isin", "year"], how="inner",
                      suffixes=("", "_esg"))
    log.info(f"Panel after merge: {len(panel):,} rows, "
             f"{panel['gvkey'].nunique():,} firms, "
             f"{panel['year'].nunique()} years")

    # ----------------------------------------------------------------
    # 2. Construct accounting ratios used as controls
    # ----------------------------------------------------------------
    log.info("Constructing accounting controls…")
    panel["roa"]      = panel["ni"] / panel["at"]
    panel["leverage"] = (panel["dlc"] + panel["dltt"]) / panel["at"]
    panel["size"]     = np.log(panel["at"].replace(0, np.nan))
    panel["mtb"]      = panel["mkt_cap"] / panel["ceq"]
    panel["sale_growth"] = panel.groupby("gvkey")["sale"].pct_change()

    # ----------------------------------------------------------------
    # 3. Winsorise financial variables symmetrically by country
    # ----------------------------------------------------------------
    log.info("Winsorising at 1%/99% by country…")
    fin_vars = ["roa", "leverage", "size", "mtb", "sale_growth",
                "ret_30d", "ret_90d", "ret_1y", "ret_3y"]
    for col in fin_vars:
        panel[col] = panel.groupby("country")[col].transform(winsorize)

    # ----------------------------------------------------------------
    # 4. Build the headline disclosure-quality flag
    # ----------------------------------------------------------------
    log.info("Constructing high-disclosure dummy (top tercile by country-year)…")
    def top_tercile(s: pd.Series) -> pd.Series:
        # Returns 1 if value is in the top tercile of its group, else 0
        cutoff = s.quantile(2 / 3)
        return (s >= cutoff).astype(int)

    panel["high_disclosure"] = (
        panel.groupby(["country", "year"])["disclosure_quality"]
             .transform(top_tercile)
    )

    # Simple lead/lag features for short- and long-term performance windows
    panel = panel.sort_values(["gvkey", "year"])
    for lag in [1, 2, 3]:
        panel[f"ret_1y_l{lag}"] = panel.groupby("gvkey")["ret_1y"].shift(lag)
        panel[f"ret_1y_f{lag}"] = panel.groupby("gvkey")["ret_1y"].shift(-lag)

    # ----------------------------------------------------------------
    # 5. Drop firms with fewer than 3 years of observations
    # ----------------------------------------------------------------
    counts = panel.groupby("gvkey")["year"].count()
    keep = counts[counts >= 3].index
    n_before = len(panel)
    panel = panel[panel["gvkey"].isin(keep)].reset_index(drop=True)
    log.info(f"Dropped {n_before - len(panel):,} short-history rows.")

    # ----------------------------------------------------------------
    # 6. Save processed panel
    # ----------------------------------------------------------------
    out = PROC / "panel.csv"
    panel.to_csv(out, index=False)
    log.info(f"Wrote processed panel: {out} ({len(panel):,} rows)")

    # Sanity summary
    log.info("Country-year coverage:")
    log.info("\n" + str(panel.groupby(["country", "year"])["gvkey"]
                        .nunique().unstack().fillna(0).astype(int)))


if __name__ == "__main__":
    main()
