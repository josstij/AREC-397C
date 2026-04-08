* course: AREC 397C
* assignment: 1
* created on: 7 april 2026
* created by: jmt
* edited on: 8 april 2026
* edited by: jmt
* Stata v.19.5

* does
	
	
* needs
	* all
	
	clear				all
	
	cap log 		close
	log using		"$logs/\assignment_tijerina.smcl", append	
**********************************************************************
**# 0 - Describing Relationships - TO DO
**********************************************************************
/*
* Clean the dataset with clear variable names 

* Submit your code file along with your input data for this assignment.

* Create one table that shows the key descriptive statistics of all key variables related to your hypotheses. 

* Clearly label the table with a table number and title. 
"Descriptive Statistics"


* Four charts and/or figures to demonstrate findings related to your research questions. 

*Clearly label each chart/figure with a continuing number and intuitive title 

* One concise paragraph under each chart, figure, or table to discuss the results
*/

**********************************************************************
**# 1.1 - Load data
**********************************************************************
* import data from CSV
	import delimited		using "$data/spors_bev_data_use_me.csv"
	describe

**## 1.2 - drop the un-finished responses
	drop 					if finished != 1

**## 1.3 - adjust display settings	
	set						linesize 200 // adjust line size for readability
	
**## 1.4 - replace specific -999 missing codes 
	foreach	var 			of varlist age edu income { 
								replace `var' = . if `var' == -999
	}
		*** 26 changes made to income
	
**********************************************************************
**# 2 - Generate variables and clean
**********************************************************************
**## 2.1 - inspect WTP variables
	describe				wtp_*
	*** all WTP variables are aready numeric (float)

**## 2.2 - Create WTP after blind tasting (pre-mag info)
	gen 					wtp_post_blindtaste = .
	*** 143 missing values generated
	
	foreach var 			in wtp_2b_584 wtp_2b_793 wtp_2b_356 wtp_2b_831 {
    replace 				wtp_post_blindtaste = `var' if ///
							wtp_post_blindtaste == . & `var' != .
}
	*** wtp_2b_584 34 changes made, wtp_2b_356 38 changes made
	
	label var 				wtp_post_blindtaste ///
							"WTP after blind tasting (pre-mag info)"
							
**## 2.3 - Create WTP after magnesium information
	gen 					wtp_post_maginfo = .
	
	foreach var 			in wtp_3a_584 wtp_3a_793 wtp_3a_356 wtp_3a_831 {
    replace wtp_post_maginfo = `var' if wtp_post_maginfo == . & `var' != .
}

	label var 				wtp_post_maginfo ///
				"WTP after tasting & mag info provided for specific product"
				
**## 2.4 - Create final WTP variable
	global 					final_wtp_var "final_wtp"
	
	gen 					${final_wtp_var} = wtp_post_maginfo
	
	replace 				${final_wtp_var} = wtp_post_blindtaste ///
							if ${final_wtp_var} == . & wtp_post_blindtaste != .
		*** 72 changes made
							
	label variable			${final_wtp_var} "Ultimate WTP decision in survey flow"
							
**## 2.5 - product identifiers and treatment variables
* identify which product was evaluated
	gen						product_id = .
		***143 missing values generated
		
	replace 				product_id = 584 if product_id == . & ///
							(wtp_2b_584 != . | wtp_2a_info_584 != . | ///
							wtp_3b_info_584 != . | wtp_3a_584 != .)

	replace 				product_id = 793 if product_id == . & ///
							(wtp_2b_793 != . | wtp_2a_info_793 != . | ///
							wtp_3b_info_793 != . | wtp_3a_793 != .)
							
	replace 				product_id = 356 if product_id == . & ///
							(wtp_2b_356 != . | wtp_2a_info_356 != . | ///
							wtp_3b_info_356 != . | wtp_3a_356 != .)

	replace 				product_id = 831 if product_id == . & ///
							(wtp_2b_831 != . | wtp_2a_info_831 != . | ///
							wtp_3b_info_831 != . | wtp_3a_831 != .)

	label var 				product_id "Product Tasted"

	label 					define product_labels ///
								584 "UA Lemon-Lime" ///
								793 "Gatorade Lemon-Lime" ///
								356 "Blueberry" ///
								831 "Pineapple"

	label 					values product_id product_labels

**## 2.6 - Product characteristics
* dummy for novel flavors (Blueberry or Pineapple)
	gen 					is_novel_flavor = (product_id == 356 | product_id == 831)

	label var 				is_novel_flavor ///
							"Tasted Novel Flavor (Blueberry/Pineapple, 1=Yes)"


**********************************************************************
**## 2.7 - Magnesium information treatment
**********************************************************************

* indicator for whether WTP was recorded after mag info
	gen mag_info_provided = 0

	replace mag_info_provided = 1 if wtp_post_maginfo != .

	label var mag_info_provided ///
		"Magnesium Info Provided for this WTP (1=Yes)"

	label define mag_info_status ///
		0 "No Mag Info (Post-Blind Taste)" ///
		1 "Mag Info Provided (Post-Info)"

	label values mag_info_provided mag_info_status

	
	
	
	
							
							
							
label var ${final_wtp_var} "Ultimate WTP decision in survey flow"
* -- Product Identifiers --
* Reconstruct 'product_id' based on which WTP variables are not missing.
* This logic is based on which set of product-specific `wtp_2b_`, `wtp_2a_info_`, or `wtp_3b_info_` values were answered by the participant.
gen product_id = .
replace product_id = 584 if wtp_2b_584 != . | wtp_2a_info_584 != . | wtp_3b_info_584 != . | wtp_3a_584 != .
replace product_id = 793 if wtp_2b_793 != . | wtp_2a_info_793 != . | wtp_3b_info_793 != . | wtp_3a_793 != .
replace product_id = 356 if wtp_2b_356 != . | wtp_2a_info_356 != . | wtp_3b_info_356 != . | wtp_3a_356 != .
replace product_id = 831 if wtp_2b_831 != . | wtp_2a_info_831 != . | wtp_3b_info_831 != . | wtp_3a_831 != .
label var product_id "Product Tasted (584=UA, 793=Gatorade, 356=Blueberry, 831=Pineapple)"
label define product_labels 584 "UA Lemon-Lime" 793 "Gatorade Lemon-Lime" 356 "Blueberry" 831 "Pineapple"
label values product_id product_labels
* Create dummy for novel flavors (Blueberry or Pineapple) vs. traditional
gen is_novel_flavor = (product_id == 356 | product_id == 831)
label var is_novel_flavor "Tasted Novel Flavor (Blueberry/Pineapple, 1=Yes)"
* -- Magnesium Information Treatment Status (for H3) --
* Based on your survey text, all participants *eventually* received magnesium information.
* H3 needs to compare WTP *before* mag info vs. WTP *after* mag info for the *same product*.
* So, this is a within-subject, pre-post comparison if the flow allowed it, or a between-subject if people were split.
* Let `mag_info_provided` be a dummy for whether this particular WTP value (`$final_wtp_var`) was asked *after* mag info was provided.
gen mag_info_provided = 0
replace mag_info_provided = 1 if wtp_post_maginfo != . // If their final_wtp came from a post-mag-info stage
label var mag_info_provided "Magnesium Info Provided for this WTP (1=Yes, 0=No)"
label define mag_info_status 0 "No Mag Info Applied (WTP Post-Blind Taste)" 1 "Mag Info Applied (WTP Post-Info)"
label values mag_info_provided mag_info_status
* -- Demographic and Control Variables --
* Recode gender (1=Male, 2=Female, 3=Non-binary, 4=Prefer not to answer)
replace gender = . if gender == 4
label define gender_labels 1 "Male" 2 "Female" 3 "Non-binary"
label values gender gender_labels
* Ensure 'day' is numeric and correctly labeled for categorical analysis
destring day, replace ignore("NA") // 'ignore' in case "NA" strings were present
label define day_labels 1 "Day 1 (Lemon-Lime)" 2 "Day 2 (Novel Flavors)"
label values day day_labels
* Ensure `exercise`, `edu`, `income` are numeric
* 'exercise' scale: 1 (0 days), 2 (1-2 days), 3 (3-4 days), 4 (5+ days) -> Treat as ordinal categorical for robustness
destring exercise, replace ignore("Just be...")
label define exercise_labels 1 "0 days" 2 "1-2 days" 3 "3-4 days" 4 "5+ days"
label values exercise exercise_labels
* Create dummy for $0 WTP responses
gen zero_wtp_final = (${final_wtp_var} == 0)
label var zero_wtp_final "Final WTP is $0 (1=Yes, 0=No)"
* -- `pref_sugar` variable (for H1/H2) --
* From survey: "How important are the following statements to you when you consume sports beverages? 'The amount of sugar per serving is low to moderate.'"
* Scale: 1="Not at all important" to 5="Extremely important".
* So, higher `pref_sugar` = more important for sugar content to be low/moderate.
label var pref_sugar "Importance of Low/Moderate Sugar Content (Higher = More Important)"
* -- `total_mag_benefit_perception` (for H2/H3) --
* From survey: "How important was each of the following health benefits of magnesium..." Scale 0-100.
* A `rowmean` across the `mag_benefit_3b_d1_...` and `mag_benefit_3b_d2_...` variables creates this composite score.
egen total_mag_benefit_perception = rowmean(mag_benefit_3b_d1_musle  ///
                                             mag_benefit_3b_d1_cramps ///
                                             mag_benefit_3b_d1_sugar  ///
                                             mag_benefit_3b_d1_bone   ///
                                             mag_benefit_3b_d1_sleep  ///
                                             mag_benefit_3b_d2_muscle ///
                                             mag_benefit_3b_d2_cramps ///
                                             mag_benefit_3b_d2_sugar  ///
                                             mag_benefit_3b_d2_bone   ///
                                             mag_benefit_3b_d2_sleep)
label var total_mag_benefit_perception "Average perceived importance of magnesium benefits (0-100)"
**********************************************************************
**# 3 - descriptive statistics
**********************************************************************
* Overall summary for key WTP stages
tabstat wtp_1 wtp_post_blindtaste wtp_post_maginfo ${final_wtp_var}, ///
        stats(mean sd min max n) col(stat) format(%9.2f) ///
        title("Summary Statistics: Willingness to Pay Across Stages")
* Summary of final WTP by product type
tabstat ${final_wtp_var}, stats(mean sd n) by(product_id) format(%9.2f) ///
        title("Final WTP by Product Type")
* Summary of final WTP by Magnesium Information Status
tabstat ${final_wtp_var}, stats(mean sd n) by(mag_info_provided) format(%9.2f) ///
        title("Final WTP by Magnesium Information Provided Status")
* Benchmark Price Comparison ($2.50)
local benchmark_price = 2.50
di _newline "--- Comparison to Benchmark Price ($`benchmark_price') ---"
ttest ${final_wtp_var} == `benchmark_price' ///
      , title("T-test: Final WTP vs. Benchmark Price ($`benchmark_price')")
* Paired t-test to compare WTP for same product before vs after mag info (for H3)
* This assumes that for a given product and individual, you have both a "blind taste WTP" and an "informed WTP".
* This is hard to do with the current WTP aggregation, as `wtp_post_blindtaste` pulls one value and `wtp_post_maginfo` pulls one value.
* We cannot assume these come from the same product for the same person easily after collapsing.
* Better: create product-specific pre/post variables.
* Let's take the UA Lemon-Lime (584) or Blueberry (356) as examples since they are the "new" product with magnesium.
* We want to compare `wtp_2b_584` (blind taste) to `wtp_3a_584` (informed taste, mag content).
* This works *only* for those who provide both.
gen delta_wtp_UA_LL_maginfo = wtp_3a_584 - wtp_2b_584
ttest delta_wtp_UA_LL_maginfo == 0 ///
      if wtp_3a_584 != . & wtp_2b_584 != . ///
      , title("Paired T-test: Change in WTP for UA Lemon-Lime after Mag Info")
gen delta_wtp_Blueberry_maginfo = wtp_3a_356 - wtp_2b_356
ttest delta_wtp_Blueberry_maginfo == 0 ///
      if wtp_3a_356 != . & wtp_2b_356 != . ///
      , title("Paired T-test: Change in WTP for Blueberry after Mag Info")
* Distribution of WTP values and proportion of $0 WTP
histogram ${final_wtp_var}, bin(20) addlabels title("Overall Distribution of Final WTP") name(hist_final_wtp, replace)
graph export "$export/hist_final_wtp.png", as(png) replace
tabulate zero_wtp_final, summarize(${final_wtp_var}) mean ///
         title("Frequency of $0 WTP Responses")
* Demographics summary
tabulate gender
tabulate exercise
tabstat age edu income, stats(mean sd min max n) col(stat) format(%9.1f) ///
         title("Summary Statistics: Demographics and Behavioral Characteristics")
* Summarize key preference variables
tabstat pref_sugar total_mag_benefit_perception, stats(mean sd min max n) col(stat) format(%9.2f) ///
         title("Summary Statistics: Preference Variables")
**********************************************************************
**# 4 - hypothesis testing with regression
**********************************************************************
* Use robust standard errors to account for potential heteroskedasticity.
* `i.` prefix for categorical variables (creates dummy variables).
* `c.` prefix for continuous variables (treats as continuous).
* Baseline controls for regressions (gender and exercise are now `i.`)
local controls "i.gender c.age i.exercise c.edu c.income"
* -- RQ1/H1: Effect of displayed sugar content on WTP --
* H1: Higher displayed sugar content reduces WTP.
* `pref_sugar`: Higher value means "low/moderate sugar content is more important."
* Expectation: WTP would be higher for those for whom low sugar is more important, thus a positive coefficient on `i.pref_sugar`.
regress ${final_wtp_var} i.pref_sugar `controls', robust
est store H1_model
* -- RQ2/H2: Trade-offs: functional attributes vs. sweetness --
* H2: Functional benefits (Magnesium) may offset negative effect of high sugar on WTP.
* Here: `pref_sugar` (importance of low sugar) interacts with `total_mag_benefit_perception` (importance of mag benefits).
* If low sugar is important (high `pref_sugar`) AND mag benefits are important (high `total_mag_benefit_perception`), does WTP change?
regress ${final_wtp_var} i.pref_sugar c.total_mag_benefit_perception i.pref_sugar#c.total_mag_benefit_perception `controls', robust
est store H2_model
* -- RQ3/H3: Impact of magnesium information --
* H3: Higher magnesium benefits increase WTP.
* This tests the causal effect of *receiving the information treatment*.
* `mag_info_provided`: 1 if this WTP value was asked after mag info (based on `wtp_post_maginfo`).
regress ${final_wtp_var} i.mag_info_provided `controls', robust
est store H3_model
* -- Additional Analysis: Factors for $0 WTP --
* Using a logit model to predict the likelihood of stating a $0 WTP.
logit zero_wtp_final i.pref_sugar c.total_mag_benefit_perception i.mag_info_provided `controls', robust
est store zero_wtp_model
* Display all regression models in a single table for your report
est table H1_model H2_model H3_model zero_wtp_model, ///
          b(%8.3f) se(%8.3f) star(.05 .01 .001) ///
          title("Regression Results for Hypotheses and Zero WTP") ///
          keep(i.pref_sugar c.total_mag_benefit_perception i.mag_info_provided ///
               i.gender c.age i.exercise c.edu c.income _cons) // Keep relevant variables
* Export regression table (example to tab-separated for Excel)
est table H1_model H2_model H3_model zero_wtp_model, ///
          b(%8.3f) se(%8.3f) star(.05 .01 .001) ///
          title("Regression Results for Hypotheses and Zero WTP") ///
          keep(i.pref_sugar c.total_mag_benefit_perception i.mag_info_provided ///
                i.gender c.age i.exercise c.edu c.income _cons) ///
          varlabels using "$export/regression_results.txt", replace ///
          cells(b(fmt(%9.3f)) se(fmt(%9.3f) pvalues(fmt(%9.3f))))
**********************************************************************
**# 5 - visualizations for presentation
**********************************************************************
* WTP comparison across different stages (for presentation slide)
graph box wtp_1 wtp_post_blindtaste wtp_post_maginfo ${final_wtp_var}, ///
    title("Willingness to Pay Across Stages") ///
    ylabel(, angle(0)) ///
    legend(label(1 "Initial WTP") label(2 "WTP Post-Blind-Tasting") label(3 "WTP Post-Mag Info") label(4 "Final WTP")) ///
    name(wtp_stages_box, replace)
graph export "$export/wtp_stages_box.png", as(png) replace
* Final WTP by Magnesium Information Status (for presentation slide H3)
graph box ${final_wtp_var}, by(mag_info_provided) ///
    title("Final WTP by Magnesium Information Status") ///
    ylabel(, angle(0)) ///
    legend(label(0 "WTP Post-Blind-Taste") label(1 "WTP Post-Mag Info")) ///
    name(wtp_by_mag_status, replace)
graph export "$export/wtp_by_mag_status.png", as(png) replace
* Final WTP by Product Type
graph box ${final_wtp_var}, by(product_id) ///
    title("Final WTP by Product Tasted") ///
    ylabel(, angle(0)) ///
    legend(off) ///
    name(wtp_by_product, replace)
graph export "$export/wtp_by_product.png", as(png) replace
* Example: WTP by gender (demographic exploration)
graph box ${final_wtp_var}, by(gender) ///
    title("Final WTP by Gender") ///
    ylabel(, angle(0)) ///
    name(wtp_by_gender, replace)
graph export "$export/wtp_by_gender.png", as(png) replace
* Example: WTP by exercise frequency
graph box ${final_wtp_var}, by(exercise) ///
    title("Final WTP by Exercise Frequency") ///
    ylabel(, angle(0)) ///
    name(wtp_by_exercise, replace)
graph export "$export/wtp_by_exercise.png", as(png) replace
* Histograms of preference variables
histogram pref_sugar, discrete ///
                      title("Distribution of Importance of Low/Moderate Sugar") ///
                      xlabel(1 "Not at all" 2 "Slightly" 3 "Moderately" 4 "Very" 5 "Extremely") ///
                      name(hist_pref_sugar, replace)
graph export "$export/hist_pref_sugar.png", as(png) replace
histogram total_mag_benefit_perception, bin(20) ///
                                      title("Distribution of Perceived Magnesium Benefit Importance") ///
                                      name(hist_mag_benefit, replace)
graph export "$export/hist_mag_benefit.png", as(png) replace
**********************************************************************
**# 6 - close log
**********************************************************************
log close
	
	
	
	
	