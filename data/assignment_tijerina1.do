* course: AREC 397C
* assignment: 1
* created on: 7 april 2026
* created by: jmt
* edited on: 27 april 2026
* edited by: jmt
* Stata v.19.5

* does
	
	
* needs
	* finished
	
	clear				all
	
	cap log 		close
	log using		"$logs/assignment_tijerina1", append	
	set 			scheme s2color
	graph set 		window fontface "Arial"
	ssc 			install estout, replace
	
**********************************************************************
**# 0 - hypothesis testing without regression - TO DO
**********************************************************************
/*
* Clean the dataset with clear variable names 

* Submit your code file along with your input data for this assignment.

* Define the main hypothesis: 
	* Ho: mean WTP after magnesium info = mean WTP before magnesium info
	* H1: mean WTP after magnesium info does not equal mean WTP before magnesium info
	
* Conduct summary stats for the key WTP variables: 
	* report mean, standard deviation, min, max, and N
	* include coefficient of variation
	
* Conduct one-sample t-tests
	* test whether WTP is different from the benchmark price of $2.50
	
* Conduct paired t-tests	
	* test whether WTP changes after magnesium information
	
* Report 95% confidence intervals with the test results

* Create clearly labeled tables for the word doc
	* Table 1: Summary Statistics
	* Table 2: benchmark tests against $2.50
	Table 3: Paired t-tests before vs after magnesium information
*/


**********************************************************************
**# 1 - Load data and basic cleaning
**********************************************************************

* clear memory
clear all

* close any open logs
cap log close

* start log file
log using "$logs/regression_assignment_day1", replace

* import data from CSV
import delimited using "$data/spors_bev_data_use_me.csv", clear

* inspect data
describe

* drop unfinished responses
drop if finished != 1

* adjust display settings
set linesize 200

* replace -999 missing codes
foreach var of varlist age edu income {
    replace `var' = . if `var' == -999
}

* check survey day
tab day


**********************************************************************
**# 2 - Generate variables and clean: Day 1 only, 584 vs 793
**********************************************************************

**## 2.1 - inspect WTP variables
describe wtp_*

* keep Day 1 only
keep if day == 1

* keep only variables needed for Day 1 regression analysis
keep wtp_1 ///
     wtp_2b_584 wtp_3b_info_584 ///
     wtp_2b_793 wtp_3b_info_793 ///
     wtp_2a_info_584 wtp_2a_info_793 ///
     after_info_3b_d1_useful after_info_2a_d1_useful ///
     mag_benefit_3b_d1_musle mag_benefit_3b_d1_cramps ///
     mag_benefit_3b_d1_sugar mag_benefit_3b_d1_bone ///
     mag_benefit_3b_d1_sleep ///
     mag_benefit_2a_d1_muscle mag_benefit_2a_d1_cramps ///
     mag_benefit_2a_d1_sugar mag_benefit_2a_d1_bone ///
     mag_benefit_2a_d1_sleep ///
     preknow_5_magn day randomizer ///
     age gender income exercise con_freq

**## 2.2 - create pathway-specific WTP change variables

* Path B: taste first, then magnesium information
gen diffB_584 = wtp_3b_info_584 - wtp_2b_584
gen diffB_793 = wtp_3b_info_793 - wtp_2b_793

* Path A: magnesium information first
gen diffA_584 = wtp_2a_info_584 - wtp_1
gen diffA_793 = wtp_2a_info_793 - wtp_1

**## 2.3 - combine Path A and Path B into one outcome variable

gen diff_584 = diffB_584
replace diff_584 = diffA_584 if missing(diff_584)

gen diff_793 = diffB_793
replace diff_793 = diffA_793 if missing(diff_793)

**## 2.4 - create deviation from market price ($2.50)

gen devB_584_taste = wtp_2b_584 - 2.5
gen devB_584_info  = wtp_3b_info_584 - 2.5

gen devB_793_taste = wtp_2b_793 - 2.5
gen devB_793_info  = wtp_3b_info_793 - 2.5

gen devA_584_info  = wtp_2a_info_584 - 2.5
gen devA_793_info  = wtp_2a_info_793 - 2.5
gen dev_baseline   = wtp_1 - 2.5


**********************************************************************
**# 3 - Label variables and save clean dataset
**********************************************************************

**## 3.1 - label key variables clearly

label variable wtp_1              "Baseline WTP before product info"

label variable wtp_2b_584         "Path B: WTP 584 after tasting"
label variable wtp_3b_info_584    "Path B: WTP 584 after magnesium info"

label variable wtp_2b_793         "Path B: WTP 793 after tasting"
label variable wtp_3b_info_793    "Path B: WTP 793 after magnesium info"

label variable wtp_2a_info_584    "Path A: WTP 584 after magnesium info"
label variable wtp_2a_info_793    "Path A: WTP 793 after magnesium info"

label variable diff_584           "Change in WTP for 584 due to magnesium info (A & B)"
label variable diff_793           "Change in WTP for 793 due to magnesium info (A & B)"

label variable preknow_5_magn     "Prior knowledge of magnesium"
label variable exercise           "Exercise frequency"
label variable con_freq           "Sports drink consumption frequency"
label variable randomizer         "Randomization pathway"

**## 3.2 - save clean dataset for regression

save "$logs/clean_data_day1_584_793.dta", replace

	
**********************************************************************
**# 4 - Regression models
**********************************************************************

* install estout if needed
cap which esttab
if _rc ssc install estout, replace

* clear stored models
eststo clear

**## 4.1 - Model 1: Magnesium product 584
eststo m1: reg diff_584 ///
    preknow_5_magn ///
    exercise ///
    con_freq ///
    age ///
    i.gender ///
    i.randomizer

**## 4.2 - Model 2: Non-magnesium product 793
eststo m2: reg diff_793 ///
    preknow_5_magn ///
    exercise ///
    con_freq ///
    age ///
    i.gender ///
    i.randomizer
	

**********************************************************************
**# 5 - Extended regression models (include baseline WTP)
**********************************************************************

**## 5.1 - Model 3: 584 with baseline control
eststo m3: reg diff_584 ///
    wtp_1 ///
    preknow_5_magn ///
    exercise ///
    con_freq ///
    age ///
    i.gender ///
    i.randomizer

**## 5.2 - Model 4: 793 with baseline control
eststo m4: reg diff_793 ///
    wtp_1 ///
    preknow_5_magn ///
    exercise ///
    con_freq ///
    age ///
    i.gender ///
    i.randomizer
	

**********************************************************************
**# 6 - Export regression results table
**********************************************************************

esttab m1 m2 m3 m4 using "$logs/regression_results_day1.rtf", ///
    replace ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label ///
    title("Regression Results for Change in Willingness to Pay")
	

**********************************************************************
**# 7 - Summary statistics table
**********************************************************************

**## 7.1 - summarize key variables

summarize wtp_1 ///
          wtp_2b_584 wtp_3b_info_584 ///
          wtp_2b_793 wtp_3b_info_793 ///
          wtp_2a_info_584 wtp_2a_info_793 ///
          diffA_584 diffA_793 ///
          diffB_584 diffB_793 ///
          diff_584 diff_793 ///
          preknow_5_magn exercise con_freq age

**## 7.2 - formatted summary table

tabstat wtp_1 ///
        wtp_2b_584 wtp_3b_info_584 ///
        wtp_2b_793 wtp_3b_info_793 ///
        wtp_2a_info_584 wtp_2a_info_793 ///
        diffA_584 diffA_793 ///
        diffB_584 diffB_793 ///
        diff_584 diff_793 ///
        preknow_5_magn exercise con_freq age, ///
        stats(mean sd min max n) columns(statistics)
		
		
**********************************************************************
**# 8 - Hypothesis testing (paired t-tests, Day 1 only)
**********************************************************************

**## H1: Magnesium information changes WTP for product 584 (Path B)
ttest wtp_3b_info_584 == wtp_2b_584

/*
H0: mean(WTP after info - WTP after taste) = 0
H1: ≠ 0
*/

**## H2: Magnesium information changes WTP for product 793 (Path B)
ttest wtp_3b_info_793 == wtp_2b_793

/*
H0: mean(WTP after info - WTP after taste) = 0
H1: ≠ 0
*/



**## H3: Magnesium information changes WTP for product 584 (Path A)
ttest wtp_2a_info_584 == wtp_1

/*
H0: mean(WTP after info - baseline) = 0
H1: ≠ 0
*/

**## H4: Magnesium information changes WTP for product 793 (Path A)
ttest wtp_2a_info_793 == wtp_1

/*
H0: mean(WTP after info - baseline) = 0
H1: ≠ 0
*/


**********************************************************************
**# 9 - Compare magnesium vs non-magnesium effect (Day 1)
**********************************************************************

ttest diff_584 == diff_793

/*
H0: Change in WTP for magnesium product = Change in WTP for non-magnesium product
H1: They are different
*/


**********************************************************************
**# 10 - Table 1: Summary Statistics Output
**********************************************************************

use "$logs/clean_data_day1_584_793.dta", clear

tempname memhold
postfile `memhold' str50 variable mean sd min max n cv ///
    using "$logs/table1_day1_sumstats.dta", replace

foreach var of varlist ///
    wtp_1 ///
    wtp_2b_584 wtp_3b_info_584 ///
    wtp_2b_793 wtp_3b_info_793 ///
    wtp_2a_info_584 wtp_2a_info_793 ///
    diffB_584 diffB_793 ///
    diffA_584 diffA_793 ///
    diff_584 diff_793 ///
    preknow_5_magn exercise con_freq age {

    quietly summarize `var'

    local lab : variable label `var'
    if "`lab'" == "" local lab "`var'"

    post `memhold' ///
        ("`lab'") ///
        (r(mean)) ///
        (r(sd)) ///
        (r(min)) ///
        (r(max)) ///
        (r(N)) ///
        (r(sd)/r(mean))
}

postclose `memhold'

use "$logs/table1_day1_sumstats.dta", clear

label variable variable "Variable"
label variable mean "Mean"
label variable sd "Std. Dev."
label variable min "Min"
label variable max "Max"
label variable n "N"
label variable cv "Coefficient of Variation"

list, clean noobs

export delimited using "$logs/table1_day1_sumstats.csv", replace


**********************************************************************
**# 11 - Table 2: One-sample t-tests (Day 1, benchmark = $2.50)
**********************************************************************

use "$logs/clean_data_day1_584_793.dta", clear

tempname memhold
postfile `memhold' str50 variable mean tstat pvalue ci_low ci_high ///
    using "$logs/table2_day1_onesample.dta", replace

foreach var of varlist ///
    wtp_3b_info_584 ///
    wtp_3b_info_793 ///
    wtp_2a_info_584 ///
    wtp_2a_info_793 {

    quietly ttest `var' == 2.5

    local lab : variable label `var'
    if "`lab'" == "" local lab "`var'"

    post `memhold' ///
        ("`lab'") ///
        (r(mu_1)) ///
        (r(t)) ///
        (r(p)) ///
        (r(lb_1)) ///
        (r(ub_1))
}

postclose `memhold'

use "$logs/table2_day1_onesample.dta", clear

label variable variable "Variable"
label variable mean "Mean WTP"
label variable tstat "t-statistic"
label variable pvalue "p-value"
label variable ci_low "95% CI (Lower)"
label variable ci_high "95% CI (Upper)"

list, clean noobs

export delimited using "$logs/table2_day1_onesample.csv", replace


**********************************************************************
**# 12 - Table 3: Paired t-tests (Day 1, Path A and Path B)
**********************************************************************

use "$logs/clean_data_day1_584_793.dta", clear

tempname memhold
postfile `memhold' str15 pathway str10 product str40 comparison ///
    mean_before mean_after diff pvalue ci_low ci_high ///
    using "$logs/table3_day1_paired.dta", replace

*--------------------------------------------------------------------
* Path B: Taste → Info
*--------------------------------------------------------------------

quietly ttest wtp_3b_info_584 == wtp_2b_584
post `memhold' ///
    ("Path B") ("584") ("After info minus after tasting") ///
    (r(mu_2)) (r(mu_1)) (r(mu_1)-r(mu_2)) (r(p)) (r(lb_diff)) (r(ub_diff))

quietly ttest wtp_3b_info_793 == wtp_2b_793
post `memhold' ///
    ("Path B") ("793") ("After info minus after tasting") ///
    (r(mu_2)) (r(mu_1)) (r(mu_1)-r(mu_2)) (r(p)) (r(lb_diff)) (r(ub_diff))

*--------------------------------------------------------------------
* Path A: Info → baseline
*--------------------------------------------------------------------

quietly ttest wtp_2a_info_584 == wtp_1
post `memhold' ///
    ("Path A") ("584") ("After info minus baseline") ///
    (r(mu_2)) (r(mu_1)) (r(mu_1)-r(mu_2)) (r(p)) (r(lb_diff)) (r(ub_diff))

quietly ttest wtp_2a_info_793 == wtp_1
post `memhold' ///
    ("Path A") ("793") ("After info minus baseline") ///
    (r(mu_2)) (r(mu_1)) (r(mu_1)-r(mu_2)) (r(p)) (r(lb_diff)) (r(ub_diff))

postclose `memhold'

use "$logs/table3_day1_paired.dta", clear

label variable pathway "Randomization Path"
label variable product "Product"
label variable comparison "Definition of Change"
label variable mean_before "Mean Before"
label variable mean_after "Mean After"
label variable diff "Mean Difference"
label variable pvalue "p-value"
label variable ci_low "95% CI (Lower)"
label variable ci_high "95% CI (Upper)"

list, clean noobs

export delimited using "$logs/table3_day1_paired.csv", replace


**********************************************************************
**# 13 - Create combined driver variables (Path A + Path B)
**********************************************************************

use "$logs/clean_data_day1_584_793.dta", clear

* Combine info usefulness
gen info_useful = after_info_3b_d1_useful
replace info_useful = after_info_2a_d1_useful if missing(info_useful)

* Combine magnesium benefit drivers
gen mag_muscle = mag_benefit_3b_d1_musle
replace mag_muscle = mag_benefit_2a_d1_muscle if missing(mag_muscle)

gen mag_cramps = mag_benefit_3b_d1_cramps
replace mag_cramps = mag_benefit_2a_d1_cramps if missing(mag_cramps)

gen mag_sugar = mag_benefit_3b_d1_sugar
replace mag_sugar = mag_benefit_2a_d1_sugar if missing(mag_sugar)

gen mag_bone = mag_benefit_3b_d1_bone
replace mag_bone = mag_benefit_2a_d1_bone if missing(mag_bone)

gen mag_sleep = mag_benefit_3b_d1_sleep
replace mag_sleep = mag_benefit_2a_d1_sleep if missing(mag_sleep)

* Label clearly
label variable info_useful "Info usefulness (combined A & B)"
label variable mag_muscle "Magnesium: muscle recovery importance"
label variable mag_cramps "Magnesium: cramp reduction importance"
label variable mag_sugar "Magnesium: blood sugar importance"
label variable mag_bone "Magnesium: bone health importance"
label variable mag_sleep "Magnesium: sleep/relaxation importance"

save "$logs/clean_data_day1_drivers.dta", replace


**********************************************************************
**# 14 - Table 4: Functional magnesium benefit drivers (Day 1)
**********************************************************************
use "$logs/clean_data_day1_drivers.dta", clear

* Pathway dummy based on random assignment
* randomizer 1 or 2 = Path B (taste first)
* randomizer 3 or 4 = Path A (info first)
gen pathA = inlist(randomizer, 3, 4)
label variable pathA "Path A dummy: info first"

eststo clear

* Model 1: 584 benefits only
eststo m1: reg diff_584 mag_sleep mag_cramps mag_muscle mag_sugar mag_bone info_useful

* Model 2: 793 benefits only
eststo m2: reg diff_793 mag_sleep mag_cramps mag_muscle mag_sugar mag_bone info_useful

* Model 3: 584 with path control
eststo m3: reg diff_584 mag_sleep mag_cramps mag_muscle mag_sugar mag_bone info_useful pathA

* Model 4: 793 with path control
eststo m4: reg diff_793 mag_sleep mag_cramps mag_muscle mag_sugar mag_bone info_useful pathA

esttab m1 m2 m3 m4 using "$logs/table4_regression_updated.rtf", ///
    replace se b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Table 4. Regression Results: Functional Benefit Drivers and Pathway Effects") ///
    mtitles("584: Benefits Only" "793: Benefits Only" ///
            "584: Benefits + Path A" "793: Benefits + Path A") ///
    label ///
    addnotes("Path A dummy = 1 if information occurred before tasting; 0 if tasting occurred before information.", ///
             "Dependent variables are WTP change: Product 584 and Product 793.", ///
             "Positive coefficients indicate higher WTP change; negative coefficients indicate lower WTP change.")
	
kjkjkjkjkjk
**********************************************************************
**# 15 - Table 5: Demographic drivers of WTP change (Day 1)
**********************************************************************

use "$logs/clean_data_day1_drivers.dta", clear

tempname memhold
postfile `memhold' str45 driver ///
    corr_584 p_584 ///
    corr_793 p_793 ///
    using "$logs/table5_demographic_drivers_day1.dta", replace

foreach var in preknow_5_magn exercise con_freq age income {

    local lab : variable label `var'
    if "`lab'" == "" local lab "`var'"

    * Correlation with magnesium product (584)
    quietly pwcorr diff_584 `var', sig
    matrix C = r(C)
    matrix P = r(sig)
    local c584 = C[1,2]
    local p584 = P[1,2]

    * Correlation with non-magnesium product (793)
    quietly pwcorr diff_793 `var', sig
    matrix C = r(C)
    matrix P = r(sig)
    local c793 = C[1,2]
    local p793 = P[1,2]

    post `memhold' ///
        ("`lab'") ///
        (`c584') (`p584') ///
        (`c793') (`p793')
}

postclose `memhold'

use "$logs/table5_demographic_drivers_day1.dta", clear

label variable driver "Demographic / behavioral driver"
label variable corr_584 "Correlation with WTP change (584)"
label variable p_584 "p-value (584)"
label variable corr_793 "Correlation with WTP change (793)"
label variable p_793 "p-value (793)"

list, clean noobs

export delimited using "$logs/table5_demographic_drivers_day1.csv", replace


**********************************************************************
**# 16 - Table 6: High vs Low functional benefit groups (Day 1)
**********************************************************************

use "$logs/clean_data_day1_drivers.dta", clear

tempname memhold
postfile `memhold' str45 driver ///
    low_584 high_584 p_584 ///
    low_793 high_793 p_793 ///
    using "$logs/table6_high_low_functional_day1.dta", replace

foreach var in info_useful mag_muscle mag_cramps mag_sugar mag_bone mag_sleep {

    local lab : variable label `var'

    * Create high vs low groups (median split)
    quietly summarize `var', detail
    gen high = `var' > r(p50) if !missing(`var')

    * Means for 584
    quietly summarize diff_584 if high == 0
    local low584 = r(mean)

    quietly summarize diff_584 if high == 1
    local high584 = r(mean)

    quietly ttest diff_584, by(high)
    local p584 = r(p)

    * Means for 793
    quietly summarize diff_793 if high == 0
    local low793 = r(mean)

    quietly summarize diff_793 if high == 1
    local high793 = r(mean)

    quietly ttest diff_793, by(high)
    local p793 = r(p)

    post `memhold' ///
        ("`lab'") ///
        (`low584') (`high584') (`p584') ///
        (`low793') (`high793') (`p793')

    drop high
}

postclose `memhold'

use "$logs/table6_high_low_functional_day1.dta", clear

label variable driver "Functional benefit driver"
label variable low_584 "Low importance mean change (584)"
label variable high_584 "High importance mean change (584)"
label variable p_584 "p-value (584)"
label variable low_793 "Low importance mean change (793)"
label variable high_793 "High importance mean change (793)"
label variable p_793 "p-value (793)"

list, clean noobs

export delimited using "$logs/table6_high_low_functional_day1.csv", replace


**********************************************************************
**# 17 - Overlap between high driver groups (Day 1)
**********************************************************************

use "$logs/clean_data_day1_drivers.dta", clear

* Create high indicators for each driver
foreach var in info_useful mag_muscle mag_cramps mag_sugar mag_bone mag_sleep {
    quietly summarize `var', detail
    gen high_`var' = `var' > r(p50) if !missing(`var')
}

* Count how many "high" drivers each person has
egen high_driver_count = rowtotal(high_info_useful high_mag_muscle high_mag_cramps high_mag_sugar high_mag_bone high_mag_sleep)

label variable high_driver_count "Number of high functional benefit ratings"

* Distribution
tab high_driver_count

* Effect on WTP change
tabstat diff_584 diff_793, by(high_driver_count) stats(mean sd n)

export delimited using "$logs/table7_overlap_day1.csv", replace