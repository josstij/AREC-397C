* course: AREC 397C
* assignment: 3
* created on: 27 april 2026
* created by: jmt
* edited on: 27 april 2026
* edited by: jmt
* Stata v.19.5

* does
	* cleans sport beverage data for regression analysis
	* creates WTP change variables using both A-path and B-path survey groups
	* estimates regression models explaining WTP change
	* exports regression tables for Word document

* needs
	* spors_bev_data_use_me.csv
	* finished responses
	* estout package
	
	clear				all
	
	cap log 		close
	log using		"$logs/assignment_tijerina3", replace	
	set 			scheme s2color
	graph set 		window fontface "Arial"
	set				linesize 200
	ssc 			install estout, replace
	

**********************************************************************
**# 0 - regression analysis - TO DO
**********************************************************************
/*
* Clean the dataset with clear variable names.

* Use BOTH Day 1 and Day 2 data.

* Create WTP change variables using BOTH survey paths:
	* B-path: after tasting WTP to after magnesium information WTP
	* A-path: baseline WTP to magnesium information WTP

* Define regression outcome variables:
	* diff_584
	* diff_793
	* diff_356
	* diff_831

* Create common magnesium driver variables:
	* information usefulness
	* muscle recovery
	* cramp reduction
	* blood sugar support
	* bone health
	* relaxation / sleep

* Estimate regression models:
	* main models: magnesium products 584, 356, and 831
	* comparison model: non-magnesium product 793, if useful

* Justify model choice:
	* OLS regression is used because WTP change is a continuous outcome.

* Export clearly labeled regression tables for the Word document.

* Discuss results in one page:
	* identify which magnesium attributes significantly affect WTP change
	* report p-values / significance levels
	* connect findings back to the hypothesis
*/


**********************************************************************
**# 1 - Load and clean data
**********************************************************************

**## 1.1 - load data
	import delimited "$data/spors_bev_data_use_me.csv", clear

**## 1.2 - keep completed responses only
	keep if finished == 1
	*** drops incomplete survey responses

**## 1.3 - inspect key variables
	describe wtp_* day randomizer
	summarize day randomizer

**## 1.4 - replace invalid values
	foreach var of varlist _all {
    capture confirm numeric variable `var'
    if !_rc {
        replace `var' = . if `var' == -999
    }
}
**## 1.5 - check missingness in WTP variables
	summarize wtp_*

**## 1.6 - confirm both survey paths exist
	tab randomizer
	tab day

	
**********************************************************************
**# 2 - Create WTP change variables (A-path + B-path)
**********************************************************************

**## 2.1 - B-path (after tasting → after info)

	gen diff_584_b = wtp_3b_info_584 - wtp_2b_584
	gen diff_793_b = wtp_3b_info_793 - wtp_2b_793

	gen diff_356_b = wtp_3b_info_356 - wtp_2b_356
	gen diff_831_b = wtp_3b_info_831 - wtp_2b_831


**## 2.2 - A-path (baseline → info first)

	gen diff_584_a = wtp_2a_info_584 - wtp_1
	gen diff_793_a = wtp_2a_info_793 - wtp_1

	gen diff_356_a = wtp_2a_info_356 - wtp_1
	gen diff_831_a = wtp_2a_info_831 - wtp_1


**## 2.3 - Combine paths (THIS FIXES YOUR FEEDBACK)

	gen diff_584 = diff_584_b
	replace diff_584 = diff_584_a if missing(diff_584)

	gen diff_793 = diff_793_b
	replace diff_793 = diff_793_a if missing(diff_793)

	gen diff_356 = diff_356_b
	replace diff_356 = diff_356_a if missing(diff_356)

	gen diff_831 = diff_831_b
	replace diff_831 = diff_831_a if missing(diff_831)


**## 2.4 - check results

	summarize diff_584 diff_793 diff_356 diff_831
	
/*
        summarize diff_584 diff_793 diff_356 diff_831

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
    diff_584 |         70    .0428571    .5516304       -1.5       1.75
    diff_793 |         70   -.5214286    .7319604         -3        .75
    diff_356 |         73    -.130137    .8240205         -3        1.5
    diff_831 |         73   -.0068493    .5788107         -2       1.75

*/


**********************************************************************
**# 3 - Create magnesium driver variables (combined across days)
**********************************************************************

**## 3.1 - information usefulness
	gen info_useful = after_info_3b_d1_useful
	replace info_useful = after_info_3b_d2_useful if missing(info_useful)


**## 3.2 - muscle recovery
	gen benefit_muscle = mag_benefit_3b_d1_musle
	replace benefit_muscle = mag_benefit_3b_d2_muscle if missing(benefit_muscle)


**## 3.3 - reduce cramps
	gen benefit_cramps = mag_benefit_3b_d1_cramps
	replace benefit_cramps = mag_benefit_3b_d2_cramps if missing(benefit_cramps)


**## 3.4 - blood sugar support
	gen benefit_sugar = mag_benefit_3b_d1_sugar
	replace benefit_sugar = mag_benefit_3b_d2_sugar if missing(benefit_sugar)


**## 3.5 - bone health
	gen benefit_bone = mag_benefit_3b_d1_bone
	replace benefit_bone = mag_benefit_3b_d2_bone if missing(benefit_bone)


**## 3.6 - relaxation / sleep
	gen benefit_sleep = mag_benefit_3b_d1_sleep
	replace benefit_sleep = mag_benefit_3b_d2_sleep if missing(benefit_sleep)

	
**## 3.7 - check results
	summarize info_useful benefit_muscle benefit_cramps ///
			  benefit_sugar benefit_bone benefit_sleep
			  
			  
**********************************************************************
**# 4 - Label variables
**********************************************************************

**## 4.1 - dependent variables (WTP change)

	label variable diff_584 "WTP change (Product 584, magnesium)"
	label variable diff_793 "WTP change (Product 793, no magnesium)"
	label variable diff_356 "WTP change (Product 356, magnesium)"
	label variable diff_831 "WTP change (Product 831, magnesium)"


**## 4.2 - driver variables

	label variable info_useful   "Perceived usefulness of magnesium information"
	label variable benefit_muscle "Importance: muscle recovery"
	label variable benefit_cramps "Importance: reduce cramps"
	label variable benefit_sugar  "Importance: blood sugar support"
	label variable benefit_bone   "Importance: bone health"
	label variable benefit_sleep  "Importance: relaxation / sleep"


**## 4.3 - control variables (optional but good)

	label variable age         "Age"
	label variable exercise    "Exercise frequency"
	label variable con_freq    "Sports drink consumption frequency"
	label variable preknow_5_magn "Prior knowledge of magnesium benefits"
	
	save "$logs/regression_ready.dta", replace
**********************************************************************
**# 5 - Regression models
**********************************************************************

**## 5.1 - magnesium products (drivers only)

	reg diff_584 ///
		benefit_sleep benefit_cramps benefit_muscle ///
		benefit_sugar benefit_bone info_useful

	eststo m1_584
	* sleep benefit is marginally sig p = 0.052

	reg diff_356 ///
		benefit_sleep benefit_cramps benefit_muscle ///
		benefit_sugar benefit_bone info_useful

	eststo m2_356
	* sleep benefit is borderline sig p = 0.082
	* cramps benefit is borderline sig p = 0.057

	reg diff_831 ///
		benefit_sleep benefit_cramps benefit_muscle ///
		benefit_sugar benefit_bone info_useful

	eststo m3_831
	* mag info usefulness marginally sig p = 0.089


**## 5.2 - add controls (stronger model)

	reg diff_584 ///
		benefit_sleep benefit_cramps benefit_muscle ///
		benefit_sugar benefit_bone info_useful ///
		age exercise con_freq preknow_5_magn

	eststo m4_584_ctrl

	reg diff_356 ///
		benefit_sleep benefit_cramps benefit_muscle ///
		benefit_sugar benefit_bone info_useful ///
		age exercise con_freq preknow_5_magn

	eststo m5_356_ctrl
	* sleep benefit is sig p = 0.043 with controls
	
	reg diff_831 ///
		benefit_sleep benefit_cramps benefit_muscle ///
		benefit_sugar benefit_bone info_useful ///
		age exercise con_freq preknow_5_magn

	eststo m6_831_ctrl
	* muscle recovery is marginally significant p = 0.086
	

**********************************************************************
**# 6 - Table 1: Regression results - drivers only
**********************************************************************

	use "$logs/regression_ready.dta", clear

	tempname memhold
	postfile `memhold' str12 product str30 variable coef se pvalue using "$logs/table1_reg_drivers.dta", replace

	local drivers benefit_sleep benefit_cramps benefit_muscle benefit_sugar benefit_bone info_useful

	foreach y in diff_584 diff_356 diff_831 {

		reg `y' benefit_sleep benefit_cramps benefit_muscle ///
			benefit_sugar benefit_bone info_useful

		foreach x of local drivers {
			post `memhold' ("`y'") ("`x'") (_b[`x']) (_se[`x']) (2*ttail(e(df_r), abs(_b[`x']/_se[`x'])))
		}
	}

	postclose `memhold'

	use "$logs/table1_reg_drivers.dta", clear

	replace product = "Product 584" if product == "diff_584"
	replace product = "Product 356" if product == "diff_356"
	replace product = "Product 831" if product == "diff_831"

	replace variable = "Relaxation / sleep" if variable == "benefit_sleep"
	replace variable = "Reduce cramps" if variable == "benefit_cramps"
	replace variable = "Muscle recovery" if variable == "benefit_muscle"
	replace variable = "Blood sugar support" if variable == "benefit_sugar"
	replace variable = "Bone health" if variable == "benefit_bone"
	replace variable = "Info usefulness" if variable == "info_useful"

	label variable product  "Product"
	label variable variable "Variable"
	label variable coef     "Coefficient"
	label variable se       "Std. Error"
	label variable pvalue   "p-value"

	list, clean noobs