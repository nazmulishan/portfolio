********************************************************************************
* Event study: market reaction to sustainability report publication
* MSc thesis — Md Nazmul Islam Ishan, SDU 2025
*
* Methodology: standard market-model event study following Brown & Warner (1985)
*  - Estimation window:  [-250, -50] trading days before event
*  - Event windows:      [-1, +1], [0, +5], [-5, +5]
*  - Abnormal return:    AR_it = R_it - (alpha_i + beta_i * R_mt)
*  - Cumulative AR:      CAR(t1, t2) = sum_{t=t1..t2} AR_it
*
* Inputs:
*   data/processed/event_returns.csv  (firm-day stock and market returns)
*   data/processed/event_dates.csv    (firm + sustainability report event date)
*
* Outputs:
*   output/car_summary.rtf            (mean CARs by window, by country)
*   output/car_by_window.gph          (Stata graph: CAR over [-10, +10])
********************************************************************************

clear all
set more off
capture log close
log using "output/event_study.log", replace text

* ------------------------------------------------------------------------------
* Load returns data
* ------------------------------------------------------------------------------
import delimited "data/processed/event_returns.csv", clear varnames(1) case(lower)

* Encode firm panel
encode gvkey, gen(firm_id)
gen date_fmt = date(date, "YMD")
format date_fmt %td

xtset firm_id date_fmt

* Merge event dates
merge m:1 gvkey using "data/processed/event_dates.dta", keep(master match)

* Compute event-time index for each firm-event pair
gen event_time = date_fmt - event_date

* ------------------------------------------------------------------------------
* Estimate market-model parameters (alpha, beta) per firm
* using the [-250, -50] estimation window
* ------------------------------------------------------------------------------
preserve
    keep if event_time >= -250 & event_time <= -50
    statsby alpha=_b[_cons] beta=_b[ret_market], by(gvkey) clear: ///
        regress ret_firm ret_market
    save "data/processed/market_model_params.dta", replace
restore

* Merge alpha and beta back to the daily file
merge m:1 gvkey using "data/processed/market_model_params.dta", keep(match) nogen

* ------------------------------------------------------------------------------
* Compute abnormal returns (AR) and CARs
* ------------------------------------------------------------------------------
gen ar = ret_firm - (alpha + beta * ret_market)

* Standardise abnormal return for cross-sectional inference (Patell t)
egen sd_ar_estim = sd(ar), by(gvkey) ///
    if event_time >= -250 & event_time <= -50
gen std_ar = ar / sd_ar_estim

* Cumulative AR over key event windows
foreach w in "m1p1" "0p5" "m5p5" {
    gen car_`w' = .
}
* [-1, +1] window
bysort gvkey (event_time): replace car_m1p1 = sum(ar) ///
    if event_time >= -1 & event_time <= 1
* [0, +5] window
bysort gvkey (event_time): replace car_0p5 = sum(ar) ///
    if event_time >=  0 & event_time <= 5
* [-5, +5] window
bysort gvkey (event_time): replace car_m5p5 = sum(ar) ///
    if event_time >= -5 & event_time <= 5

* Keep one row per firm-event with the maximum CAR (end of window)
collapse (max) car_m1p1 car_0p5 car_m5p5 (mean) country, by(gvkey)

* ------------------------------------------------------------------------------
* Cross-sectional t-tests on CARs by country
* ------------------------------------------------------------------------------
ttest car_m1p1 == 0
ttest car_m1p1 == 0, by(country)

ttest car_0p5 == 0
ttest car_0p5 == 0, by(country)

ttest car_m5p5 == 0
ttest car_m5p5 == 0, by(country)

* ------------------------------------------------------------------------------
* Export summary table
* ------------------------------------------------------------------------------
estpost tabstat car_m1p1 car_0p5 car_m5p5, ///
    statistics(mean sd count) by(country) columns(statistics)

esttab using "output/car_summary.rtf", replace ///
    cells("mean(fmt(4)) sd(fmt(4)) count(fmt(0))") ///
    label nonumber ///
    title("Mean cumulative abnormal returns by event window and country") ///
    addnotes("Event = sustainability report publication. Market model estimation window [-250, -50]. CAR windows: [-1,+1], [0,+5], [-5,+5]. SDs are cross-sectional.")

* ------------------------------------------------------------------------------
* Plot: average AR around the event for both countries
* ------------------------------------------------------------------------------
* (re-load full daily panel to plot AR by event time)
preserve
    use "data/processed/event_returns_with_ar.dta", clear
    collapse (mean) ar, by(country event_time)
    keep if event_time >= -10 & event_time <= 10
    twoway (line ar event_time if country=="DK", lw(medthick)) ///
           (line ar event_time if country=="US", lw(medthick)), ///
        title("Average abnormal return around sustainability report publication") ///
        ytitle("Mean AR") xtitle("Event time (trading days)") ///
        legend(label(1 "Denmark") label(2 "USA")) ///
        graphregion(color(white)) bgcolor(white) ///
        xline(0, lcolor(gs10) lpattern(dash))
    graph save "output/car_by_window.gph", replace
    graph export "output/car_by_window.png", replace width(1200)
restore

log close
display "Event study complete. See output/ for tables and graphs."
