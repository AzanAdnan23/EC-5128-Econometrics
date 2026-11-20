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
summarize return_bab r_BAB_L return_ftse r__FTSE
