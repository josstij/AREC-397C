* course: AREC 397C
* assignment: regs analysis 
* created on: 23 apr 2026
* created by: tml jmt
* edited on: 23 apr 2026
* edited by: tml
* Stata v.19.5

* does
	
	
* needs
	* all
	
	clear				all
	
	cap log 		close
	log using		"$logs/assignment_leavy.smcl", append	
************************************************************ Import the data
* import data from CSV

	import delimited		using "$data/spors_bev_data_use_me.csv"
	describe
	tab

* drop the un-finished responses
	drop 			if finished != 1
	
* keep male and female because there are only two obs that are not male and female
	tab			gender, missing
	keep		if inlist(gender, 1, 2)
	
* flag respondents who finished in under 300 seconds
	gen			speeder_300 = (durationinseconds < 300) if !missing(durationinseconds)
	label var 	speeder_300 "Completed survey in under 300 seconds"

	label 		define speeder_lbl 0 "No" 1 "Yes", replace
	label 		values speeder_300 speeder_lbl

	tab 		speeder_300, missing
	sum 		durationinseconds, detail
	
	count if 	speeder_300 == 1
	count if 	speeder_300 == 0
	
	drop if			speeder_300 == 1

	

********************************************************************************
**# regression strategy
********************************************************************************


/*
Need to justify WHY we chose our X's and our Y's, for what reasons

Literature
OR
Economic Theory

Probably just doing OLS for the estimation of the regression

Refer back to Na's "The effect of the oil and gas boom on schooling" 
for information on how to properly set up the empirical model 
and Regression specification





* can do a lot of copy paste from previous files, but need to decide on what to ///
reg on what and for what ///
the following will be the strategic plan

	
********************************************************************************
**# gen - label  - define
********************************************************************************
*/



	
