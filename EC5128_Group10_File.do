*****
* EC5128 Group Practical Assignment
* Group 10
* Babcock International Group plc
* Babcock's Yahoo ticker, plus the FTSE 100's
* 17 Nov 2027
*****

************************************************
************************************************
clear all
getsymbols ^FTSE BAB.L, fd(1) fm(10) fy(2016)  ld(30) lm(9) ly(2026) freq(d) yahoo clear price(adjclose)
cd "/Users/john/Documents/FIN/EC-5128/Raw_data"
save babcock_ftse_raw, replace
/// saves as csv
export delimited using babcock_ftse_raw.csv, replace
/// FTSE price is missing on 22 Dec 2020
list if missing(p_adjclose__FTSE )
sort period
generate trading_day = _n
tsset trading_day
generate return_bab = ln(p_adjclose_BAB_L) - ln(L.p_adjclose_BAB_L)
generate return_ftse = ln(p_adjclose__FTSE) - ln(L.p_adjclose__FTSE)
summarize return_bab r_BAB_L return_ftse r__FTSE

twoway line p_adjclose_BAB_L period, title("Babcock: Daily Adjusted Closing Price") ytitle("Price (pence)") xtitle("Date") xlabel(#10, format(%tdCCYY)) ylabel(200(200)1600)
twoway line p_adjclose__FTSE  period, title("FTSE 100: Daily Adjusted Closing Level") ytitle("Index Level (points)") xtitle("Date") xlabel(#10, format(%tdCCYY))
twoway line return_bab  period, title("Babcock Daily Log Return") ytitle("Log Return (in decimal)") xtitle("Date") xlabel(#10, format(%tdCCYY)) ylabel(-.2(.1).3)
twoway line return_ftse  period, title("FTSE 100 Daily Log Return") ytitle("Log Return (in decimal)") xtitle("Date") xlabel(#10, format(%tdCCYY)) ylabel(-.2(.1).3)

list period return_bab return_ftse if abs(return_bab) > 0.15 & !missing(return_bab)
summarize return_bab return_ftse if !missing(return_bab, return_ftse)

regress return_bab return_ftse
test return_ftse = 1

gen weekdays = dow(period)
tab weekdays
regress return_bab return_ftse i.weekdays
test 2.weekdays 3.weekdays 4.weekdays 5.weekdays

reg return_bab return_ftse i.weekdays
predict u, residuals
predict yhat, xb
rvfplot, yline(0)
estat hettest, iid
estat imtest, white
