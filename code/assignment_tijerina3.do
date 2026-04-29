* course: AREC 397C
* assignment: 3
* created on: 27 april 2026
* created by: jmt
* edited on: 29 april 2026
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
**# 0 - analysis roadmap (Day 1 only)
**********************************************************************
/*
	Goal: Test how magnesium information affects WTP

	Design:
	- Day 1 only
	- Product 584 (magnesium) vs 793 (no magnesium)
	- Path A (info first) vs Path B (taste first)

	Requirements:
	1. Table 1: Summary statistics
	2. Table 2: Benchmark t-tests (alpha = 0.05)
	3. Table 3: WTP change tests (alpha = 0.05)
	4. Correlation analysis:
	   - correlation matrix
	   - scatterplots
	5. Simple regression:
	   - ΔWTP = f(overall liking)
	6. Multiple regression:
	   - ΔWTP = f(liking + controls)

	Notes:
	- Keep sensory_584_overall and sensory_793_overall
	- Do not mix products
	- Interpret p-values at 5% significance
*/


**********************************************************************
**# 1 - Load and clean data
**********************************************************************

	import delimited "$data/spors_bev_data_use_me.csv", clear

	* keep completed responses
	keep if finished == 1
	
	*confirm liking variables exist
	summarize sensory_584_overall sensory_793_overall 

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
**# 2 - Create Day 1 WTP variables using all randomizers ******CLARITY ISSUE
**********************************************************************

* keep Day 1 only
keep if day == 1

/*
Definition of WTP change variables:

Path B (taste → info):
diff_584_b = WTP after magnesium info − WTP after tasting
diff_793_b = WTP after magnesium info − WTP after tasting

Path A (info → taste):
diff_584_a = WTP after magnesium info − baseline WTP (wtp_1)
diff_793_a = WTP after magnesium info − baseline WTP (wtp_1)

Combined variables:
diff_584 = uses both A and B observations
diff_793 = uses both A and B observations

Positive values = increase in WTP
Negative values = decrease in WTP
*/

**## 2.1 - B-path: tasting first, then magnesium info
gen before_584_b = wtp_2b_584
gen after_584_b  = wtp_3b_info_584
gen diff_584_b   = after_584_b - before_584_b

gen before_793_b = wtp_2b_793
gen after_793_b  = wtp_3b_info_793
gen diff_793_b   = after_793_b - before_793_b

**## 2.2 - A-path: baseline WTP, then magnesium info first
gen before_584_a = wtp_1
gen after_584_a  = wtp_2a_info_584
gen diff_584_a   = after_584_a - before_584_a

gen before_793_a = wtp_1
gen after_793_a  = wtp_2a_info_793
gen diff_793_a   = after_793_a - before_793_a

**## 2.3 - Combined variables using all randomizers
gen before_584 = before_584_b
replace before_584 = before_584_a if missing(before_584)

gen after_584 = after_584_b
replace after_584 = after_584_a if missing(after_584)

gen diff_584 = diff_584_b
replace diff_584 = diff_584_a if missing(diff_584)

gen before_793 = before_793_b
replace before_793 = before_793_a if missing(before_793)

gen after_793 = after_793_b
replace after_793 = after_793_a if missing(after_793)

gen diff_793 = diff_793_b
replace diff_793 = diff_793_a if missing(diff_793)

**## 2.4 - Labels
label variable before_584 "WTP before info: UA Lemon Lime 584"
label variable after_584  "WTP after info: UA Lemon Lime 584"
label variable diff_584   "WTP change: UA Lemon Lime 584"

label variable before_793 "WTP before info: Gatorade 793"
label variable after_793  "WTP after info: Gatorade 793"
label variable diff_793   "WTP change: Gatorade 793"

label variable diff_584_b "WTP change 584: B-path"
label variable diff_584_a "WTP change 584: A-path"
label variable diff_793_b "WTP change 793: B-path"
label variable diff_793_a "WTP change 793: A-path"

**## 2.5 - Checks
summarize before_584 after_584 diff_584 before_793 after_793 diff_793
tab randomizer if !missing(diff_584)
tab randomizer if !missing(diff_793)

save "$logs/day1_clean.dta", replace


**********************************************************************
**# 3 - Table 1: Summary Statistics
**********************************************************************

/*
Table 1 notes:

diff_584_b = WTP after magnesium info − WTP after tasting (Path B)
diff_584_a = WTP after magnesium info − baseline WTP (Path A)

diff_793_b = same definition for product 793 (Path B)
diff_793_a = same definition for product 793 (Path A)

diff_584 and diff_793 are combined measures using both Path A and B.

These variables represent the change in willingness to pay due to magnesium information.
*/

use "$logs/day1_clean.dta", clear

tempname memhold
postfile `memhold' str40 variable mean sd se n cv using "$logs/table1_summary.dta", replace

foreach var in before_584 after_584 diff_584_b diff_584_a diff_584 ///
               before_793 after_793 diff_793_b diff_793_a diff_793 {

    summarize `var'

    local mean = r(mean)
    local sd   = r(sd)
    local se   = r(sd)/sqrt(r(N))
    local n    = r(N)
    local cv   = r(sd)/r(mean)

    post `memhold' ("`var'") (`mean') (`sd') (`se') (`n') (`cv')
}

postclose `memhold'

use "$logs/table1_summary.dta", clear

replace variable = "WTP Before Info: UA Lemon Lime (584)" if variable == "before_584"
replace variable = "WTP After Info: UA Lemon Lime (584)" if variable == "after_584"
replace variable = "WTP Change: UA Lemon Lime (B-path)" if variable == "diff_584_b"
replace variable = "WTP Change: UA Lemon Lime (A-path)" if variable == "diff_584_a"
replace variable = "WTP Change: UA Lemon Lime (Combined)" if variable == "diff_584"

replace variable = "WTP Before Info: Gatorade (793)" if variable == "before_793"
replace variable = "WTP After Info: Gatorade (793)" if variable == "after_793"
replace variable = "WTP Change: Gatorade (B-path)" if variable == "diff_793_b"
replace variable = "WTP Change: Gatorade (A-path)" if variable == "diff_793_a"
replace variable = "WTP Change: Gatorade (Combined)" if variable == "diff_793"

list, clean noobs

export excel using "$logs/table1_summary.xlsx", firstrow(variables) replace


**********************************************************************
**# 4 - Table 2: Benchmark Tests ($2.50)
**********************************************************************

use "$logs/day1_clean.dta", clear

tempname memhold
postfile `memhold' str40 product mean tstat pvalue ci_low ci_high using "$logs/table2_benchmark.dta", replace

ttest after_584 == 2.5
post `memhold' ("UA Lemon Lime (584)") (r(mu_1)) (r(t)) (r(p)) (r(lb_1)) (r(ub_1))

ttest after_793 == 2.5
post `memhold' ("Gatorade (793)") (r(mu_1)) (r(t)) (r(p)) (r(lb_1)) (r(ub_1))

postclose `memhold'

use "$logs/table2_benchmark.dta", clear
list, clean noobs

export excel using "$logs/table2_benchmark.xlsx", firstrow(variables) replace


**********************************************************************
**# 5 - Table 3: WTP Change Tests
**********************************************************************

use "$logs/day1_clean.dta", clear

tempname memhold
postfile `memhold' str40 product str15 path mean_change tstat pvalue ci_low ci_high using "$logs/table3_change.dta", replace

ttest diff_584_b == 0
post `memhold' ("UA Lemon Lime (584)") ("B-path") (r(mu_1)) (r(t)) (r(p)) (r(lb_1)) (r(ub_1))

ttest diff_584_a == 0
post `memhold' ("UA Lemon Lime (584)") ("A-path") (r(mu_1)) (r(t)) (r(p)) (r(lb_1)) (r(ub_1))

ttest diff_584 == 0
post `memhold' ("UA Lemon Lime (584)") ("Combined") (r(mu_1)) (r(t)) (r(p)) (r(lb_1)) (r(ub_1))

ttest diff_793_b == 0
post `memhold' ("Gatorade (793)") ("B-path") (r(mu_1)) (r(t)) (r(p)) (r(lb_1)) (r(ub_1))

ttest diff_793_a == 0
post `memhold' ("Gatorade (793)") ("A-path") (r(mu_1)) (r(t)) (r(p)) (r(lb_1)) (r(ub_1))

ttest diff_793 == 0
post `memhold' ("Gatorade (793)") ("Combined") (r(mu_1)) (r(t)) (r(p)) (r(lb_1)) (r(ub_1))

postclose `memhold'

use "$logs/table3_change.dta", clear
list, clean noobs

export excel using "$logs/table3_change.xlsx", firstrow(variables) replace
*/

**********************************************************************
**# 6 - Create magnesium benefit driver variables
**********************************************************************

/*
Magnesium benefit driver variables:

These variables combine Path A and Path B survey responses.
If the Path B version is missing, the Path A version is used.

info_useful = perceived usefulness of magnesium information
benefit_muscle = importance of muscle recovery benefit
benefit_cramps = importance of cramp reduction benefit
benefit_sugar = importance of blood sugar support benefit
benefit_bone = importance of bone health benefit
benefit_sleep = importance of relaxation/sleep benefit

These are used to explain:
diff_584 = combined WTP change for 584 across Path A and Path B
diff_793 = combined WTP change for 793 across Path A and Path B
*/

use "$logs/day1_clean.dta", clear

gen info_useful = after_info_3b_d1_useful
replace info_useful = after_info_2a_d1_useful if missing(info_useful)

gen benefit_muscle = mag_benefit_3b_d1_musle
replace benefit_muscle = mag_benefit_2a_d1_muscle if missing(benefit_muscle)

gen benefit_cramps = mag_benefit_3b_d1_cramps
replace benefit_cramps = mag_benefit_2a_d1_cramps if missing(benefit_cramps)

gen benefit_sugar = mag_benefit_3b_d1_sugar
replace benefit_sugar = mag_benefit_2a_d1_sugar if missing(benefit_sugar)

gen benefit_bone = mag_benefit_3b_d1_bone
replace benefit_bone = mag_benefit_2a_d1_bone if missing(benefit_bone)

gen benefit_sleep = mag_benefit_3b_d1_sleep
replace benefit_sleep = mag_benefit_2a_d1_sleep if missing(benefit_sleep)

label variable info_useful    "Information usefulness"
label variable benefit_muscle "Muscle recovery"
label variable benefit_cramps "Reduce cramps"
label variable benefit_sugar  "Blood sugar support"
label variable benefit_bone   "Bone health"
label variable benefit_sleep  "Relaxation / sleep"

summarize diff_584 info_useful benefit_muscle benefit_cramps ///
          benefit_sugar benefit_bone benefit_sleep

save "$logs/day1_regression_ready.dta", replace


**********************************************************************
**# 6.5 - Bivariate analysis: 584 (liking vs WTP change)
**********************************************************************

* correlation
corr diff_584 sensory_584_overall

* scatterplot with line of best fit
twoway (scatter diff_584 sensory_584_overall) ///
       (lfit diff_584 sensory_584_overall), ///
       title("WTP Change vs Liking (584)") ///
       xtitle("Overall Liking (584)") ///
       ytitle("WTP Change (584)")

graph export "$logs/scatter_584.png", replace


**********************************************************************
**# 6.6 - Bivariate analysis: 793 (liking vs WTP change)
**********************************************************************

* correlation
corr diff_793 sensory_793_overall

* scatterplot with line of best fit
twoway (scatter diff_793 sensory_793_overall) ///
       (lfit diff_793 sensory_793_overall), ///
       title("WTP Change vs Liking (793)") ///
       xtitle("Overall Liking (793)") ///
       ytitle("WTP Change (793)")

graph export "$logs/scatter_793.png", replace


**********************************************************************
**# 6.7 - Correlation matrix
**********************************************************************
* 584 - 
pwcorr diff_584 sensory_584_flavor sensory_584_sweet ///
       sensory_584_sour sensory_584_salt sensory_584_aroma ///
       sensory_584_aftert refresh_584 sensory_584_overall, sig
	   
* 793 - 
pwcorr diff_793 sensory_793_flavor sensory_793_sweet ///
       sensory_793_sour sensory_793_salt sensory_793_aroma ///
       sensory_793_aftert refresh_793 sensory_793_overall, sig


**********************************************************************
**# 7 - Table 4: Regression Drivers of WTP Change ***************BIGGEST ISSUE
**********************************************************************

use "$logs/day1_regression_ready.dta", clear

reg diff_584 benefit_sleep benefit_cramps benefit_muscle benefit_sugar benefit_bone info_useful

tempname memhold
postfile `memhold' str40 variable coef se tstat pvalue using "$logs/table4_regression.dta", replace

foreach x in benefit_sleep benefit_cramps benefit_muscle benefit_sugar benefit_bone info_useful {

    local coef = _b[`x']
    local se   = _se[`x']
    local t    = _b[`x']/_se[`x']
    local p    = 2*ttail(e(df_r), abs(`t'))

    post `memhold' ("`x'") (`coef') (`se') (`t') (`p')
}

postclose `memhold'

use "$logs/table4_regression.dta", clear

replace variable = "Relaxation / sleep" if variable == "benefit_sleep"
replace variable = "Reduce cramps" if variable == "benefit_cramps"
replace variable = "Muscle recovery" if variable == "benefit_muscle"
replace variable = "Blood sugar support" if variable == "benefit_sugar"
replace variable = "Bone health" if variable == "benefit_bone"
replace variable = "Information usefulness" if variable == "info_useful"

list, clean noobs

export excel using "$logs/table4_regression.xlsx", firstrow(variables) replace