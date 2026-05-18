********************************************************************************
* Main panel regressions: ESG disclosure quality and financial performance
* MSc thesis — Md Nazmul Islam Ishan, SDU 2025
*
* Specifications run:
*   1. Pooled OLS (baseline)
*   2. Firm fixed effects
*   3. Firm + year fixed effects (preferred)
*   4. Country-specific subsamples (DK vs US)
*   5. Instrumental variables (industry-average disclosure as instrument)
*
* Inputs:
*   data/processed/panel.csv (produced by code/data_prep.py)
*
* Outputs:
*   output/table_main.rtf   (regression table for thesis)
*   output/table_iv.rtf     (IV results)
*   output/sumstats.rtf     (summary statistics)
********************************************************************************

clear all
set more off
capture log close
log using "output/main_analysis.log", replace text

* Load processed panel
import delimited "data/processed/panel.csv", clear varnames(1) case(lower)

* Encode panel id and year
encode gvkey, gen(firm_id)
xtset firm_id year

* Sample restriction: same firms across both years
keep if !missing(roa, leverage, size, mtb, ret_1y, high_disclosure)

* ------------------------------------------------------------------------------
* Summary statistics by country
* ------------------------------------------------------------------------------
estpost summarize roa leverage size mtb ret_1y ret_3y disclosure_quality, ///
    detail
esttab using "output/sumstats.rtf", ///
    cells("mean(fmt(3)) sd(fmt(3)) min(fmt(2)) max(fmt(2))") ///
    label nonumber replace ///
    title("Summary statistics, full sample")

* ------------------------------------------------------------------------------
* Specification 1: Pooled OLS — short-term return
* ------------------------------------------------------------------------------
reg ret_1y high_disclosure roa leverage size mtb sale_growth ///
    i.year, vce(cluster firm_id)
estimates store m1

* Specification 2: Firm fixed effects
xtreg ret_1y high_disclosure roa leverage size mtb sale_growth ///
    i.year, fe vce(cluster firm_id)
estimates store m2

* Specification 3: Firm + year fixed effects (preferred)
reghdfe ret_1y high_disclosure roa leverage size mtb sale_growth, ///
    absorb(firm_id year) vce(cluster firm_id)
estimates store m3

* Specification 4a: Denmark subsample
reghdfe ret_1y high_disclosure roa leverage size mtb sale_growth ///
    if country == "DK", absorb(firm_id year) vce(cluster firm_id)
estimates store m4_dk

* Specification 4b: US subsample
reghdfe ret_1y high_disclosure roa leverage size mtb sale_growth ///
    if country == "US", absorb(firm_id year) vce(cluster firm_id)
estimates store m4_us

* Export combined main table
esttab m1 m2 m3 m4_dk m4_us using "output/table_main.rtf", replace ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(high_disclosure roa leverage size mtb sale_growth) ///
    label nonumber ///
    mtitles("Pooled OLS" "Firm FE" "Firm+Year FE" "Denmark" "USA") ///
    addnotes("Standard errors clustered at firm level. *** p<0.01, ** p<0.05, * p<0.10.")

* ------------------------------------------------------------------------------
* Specification 5: Instrumental variables
* Instrument: industry-year average disclosure quality (excluding focal firm)
* Rationale: peer disclosure pressure is correlated with own disclosure
*            but should not directly affect own returns conditional on controls.
* ------------------------------------------------------------------------------
* Build leave-one-out industry-year mean (assumes "sic2" two-digit industry code)
egen ind_yr_mean = mean(disclosure_quality), by(sic2 year)
egen ind_yr_n    = count(disclosure_quality), by(sic2 year)
gen iv_peer_disc = (ind_yr_mean * ind_yr_n - disclosure_quality) / (ind_yr_n - 1)

* IV (2SLS) with firm + year FE
ivreghdfe ret_1y (high_disclosure = iv_peer_disc) ///
    roa leverage size mtb sale_growth, ///
    absorb(firm_id year) cluster(firm_id) first

estimates store m_iv

esttab m_iv using "output/table_iv.rtf", replace ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber ///
    title("IV (2SLS) results — peer-industry disclosure as instrument") ///
    addnotes("Dependent variable: 1-year stock return. Instrument: industry-year leave-one-out average disclosure quality. SEs clustered at firm level.")

* ------------------------------------------------------------------------------
* Long-term horizon: 3-year forward return
* ------------------------------------------------------------------------------
reghdfe ret_1y_f3 high_disclosure roa leverage size mtb sale_growth, ///
    absorb(firm_id year) vce(cluster firm_id)
estimates store m_long

esttab m_long using "output/table_long_run.rtf", replace ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber ///
    title("Long-run effect: 3-year forward return") ///
    addnotes("3-year forward 1-year return regressed on contemporaneous high-disclosure dummy with firm and year FE.")

log close
display "Main analysis complete. See output/ for tables."
