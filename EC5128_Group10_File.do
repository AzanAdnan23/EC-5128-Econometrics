*****
* EC5128 Group Practical Assignment
* Group 10
* Babcock International Group plc
* Babcock's Yahoo ticker, plus the FTSE 100's
* 17 Nov 2026
*****

************************************************
* DATA: download, save and prepare
************************************************
clear all

* Download daily adjusted closing prices for the FTSE 100 (^FTSE) and Babcock (BAB.L)
* from Yahoo Finance, 1 Oct 2016 to 30 Sep 2026
getsymbols ^FTSE BAB.L, fd(1) fm(10) fy(2016)  ld(30) lm(9) ly(2026) freq(d) yahoo clear price(adjclose)

* Working folder: CHANGE this path to your own folder before running
cd "/Users/john/Documents/FIN/EC-5128/Raw_data"

* Save a copy of the raw data (Stata format and CSV)
save babcock_ftse_raw, replace
export delimited using babcock_ftse_raw.csv, replace

* Missing data check: the FTSE 100 price is missing on 22 Dec 2020 (left as missing)
list if missing(p_adjclose__FTSE )

* Trading-day time index: weekends are not treated as zero-return days;
* the calendar date (period) is kept for graphs and day-of-the-week analysis
sort period
generate trading_day = _n
tsset trading_day

************************************************
* QUESTION 1: Exploring the data
************************************************

* Daily log returns: ln(P_t) - ln(P_t-1)
generate return_bab = ln(p_adjclose_BAB_L) - ln(L.p_adjclose_BAB_L)
generate return_ftse = ln(p_adjclose__FTSE) - ln(L.p_adjclose__FTSE)

* Check: our log returns match the log returns created by getsymbols (r_)
summarize return_bab r_BAB_L return_ftse r__FTSE

* Figure 1.1: Babcock adjusted closing price
twoway line p_adjclose_BAB_L period, title("Babcock: Daily Adjusted Closing Price") ytitle("Price (pence)") xtitle("Date") xlabel(#10, format(%tdCCYY)) ylabel(200(200)1600)

* Figure 1.2: FTSE 100 closing level
twoway line p_adjclose__FTSE  period, title("FTSE 100: Daily Adjusted Closing Level") ytitle("Index Level (points)") xtitle("Date") xlabel(#10, format(%tdCCYY))

* Figure 1.3: Babcock daily log return
twoway line return_bab  period, title("Babcock Daily Log Return") ytitle("Log Return (in decimal)") xtitle("Date") xlabel(#10, format(%tdCCYY)) ylabel(-.2(.1).3)

* Figure 1.4: FTSE 100 daily log return
twoway line return_ftse  period, title("FTSE 100 Daily Log Return") ytitle("Log Return (in decimal)") xtitle("Date") xlabel(#10, format(%tdCCYY)) ylabel(-.2(.1).3)

* Unusual observations: Babcock days with a move larger than 15%
list period return_bab return_ftse if abs(return_bab) > 0.15 & !missing(return_bab)

* Summary statistics on the common sample (days where both returns exist, N = 2,522)
summarize return_bab return_ftse if !missing(return_bab, return_ftse)

************************************************
* QUESTION 2: Market model
************************************************

* OLS market model: Babcock return on FTSE 100 return (Table 2.1)
regress return_bab return_ftse

* Q2(3): test whether beta equals 1 (H0: beta = 1)
test return_ftse = 1

************************************************
* QUESTION 3: Day-of-the-week effects
************************************************

* Weekday variable: dow() gives 0 = Sunday ... 6 = Saturday; only 1 (Mon) to 5 (Fri) appear
gen weekdays = dow(period)

* Number of observations on each weekday
tab weekdays

* Market model with weekday dummies; Monday (1) is the omitted reference category (Table 3.1)
regress return_bab return_ftse i.weekdays

* Joint F-test: H0: Tuesday to Friday coefficients are all zero
test 2.weekdays 3.weekdays 4.weekdays 5.weekdays

************************************************
* QUESTION 4: Model diagnostics
************************************************

* Re-estimate the Question 3 model and save residuals and fitted values
reg return_bab return_ftse i.weekdays
predict u, residuals
predict yhat, xb

* Heteroskedasticity: residuals vs fitted values graph
rvfplot, yline(0)

* Heteroskedasticity: Breusch-Pagan test (H0: constant variance)
estat hettest, iid

* Heteroskedasticity: White's test (H0: homoskedasticity)
estat imtest, white
