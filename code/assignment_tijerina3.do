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

	import delimited "$data/spors_bev_data_use_me.csv", clear

	* keep completed responses
	keep if finished == 1

	* replace invalid values (-999 → missing)
	ds, has(type numeric)
	foreach var of varlist `r(varlist)' {
		replace `var' = . if `var' == -999
	}

	* check structure
	summarize day randomizer
	tab randomizer
	tab day


**********************************************************************
**# 2 - Create Day 1 WTP change variables
**********************************************************************

	* keep Day 1 only
	keep if day == 1

	* B-path
	gen diff_584_b = wtp_3b_info_584 - wtp_2b_584
	gen diff_793_b = wtp_3b_info_793 - wtp_2b_793

	* A-path (FIXED — correct logic)
	gen diff_584_a = wtp_3a_584 - wtp_2a_info_584
	gen diff_793_a = wtp_3a_793 - wtp_2a_info_793

	* combine
	gen diff_584 = diff_584_b
	replace diff_584 = diff_584_a if missing(diff_584)

	gen diff_793 = diff_793_b
	replace diff_793 = diff_793_a if missing(diff_793)

	* check
	summarize diff_584 diff_793
	tab randomizer if !missing(diff_584)

**********************************************************************
**# 2.1 - Label variables (for clean tables)
**********************************************************************

	* products
	label variable wtp_2b_584 "WTP before info (UA Lemon Lime - 584)"
	label variable wtp_3b_info_584 "WTP after info (UA Lemon Lime - 584)"

	label variable wtp_2b_793 "WTP before info (Gatorade - 793)"
	label variable wtp_3b_info_793 "WTP after info (Gatorade - 793)"

	* main variables
	label variable diff_584 "WTP change (UA Lemon Lime - Magnesium)"
	label variable diff_793 "WTP change (Gatorade - No Magnesium)"
	
	
**********************************************************************
**# 2.2 - Table 1: Summary statistics
**********************************************************************

	tabstat wtp_2b_584 wtp_3b_info_584 ///
			wtp_2b_793 wtp_3b_info_793 ///
			diff_584 diff_793, ///
			stats(mean sd n) columns(statistics)
			
		
**********************************************************************
**# 3 - Table 2: Benchmark tests ($2.50)
**********************************************************************

	tempname memhold
	postfile `memhold' str12 variable mean tstat pvalue ci_low ci_high ///
	using "$logs/table2_benchmark.dta", replace

	* 584
	ttest wtp_3b_info_584 == 2.5
	post `memhold' ("584") (r(mu_1)) (r(t)) (r(p)) (r(lb_1)) (r(ub_1))

	* 793
	ttest wtp_3b_info_793 == 2.5
	post `memhold' ("793") (r(mu_1)) (r(t)) (r(p)) (r(lb_1)) (r(ub_1))

	postclose `memhold'

	use "$logs/table2_benchmark.dta", clear
	list, clean noobs


**********************************************************************
**# 4 - Table 3: WTP change (main result)
**********************************************************************

	tempname memhold
	postfile `memhold' str12 product mean_change tstat pvalue ci_low ci_high ///
	using "$logs/table3_diff.dta", replace

	* 584
	ttest diff_584 == 0
	post `memhold' ("584") (r(mu_1)) (r(t)) (r(p)) (r(lb_1)) (r(ub_1))

	* 793
	ttest diff_793 == 0
	post `memhold' ("793") (r(mu_1)) (r(t)) (r(p)) (r(lb_1)) (r(ub_1))

	postclose `memhold'

	use "$logs/table3_diff.dta", clear
	list, clean noobs

	