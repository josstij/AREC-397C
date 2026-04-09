* course: AREC 397C
* assignment: 1
* created on: 7 april 2026
* created by: jmt
* edited on: 7 april 2026
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
**# 1 - Importing the data
**********************************************************************
* import data from CSV
	import delimited		using "$data/spors_bev_data_use_me.csv"
	describe

* drop the un-finished responses
	drop 			if finished != 1

	set				linesize 200 // adjust line size for readability of output
	
* replace specific -999 missing codes 
	foreach			var of varlist age edu income { 
						replace `var' = . if `var' == -999
	}
		*** 26 changes made to income
	
**********************************************************************
**# 2 - Generate variables and clean
**********************************************************************
* WTP Variable Consolidation 

* IDs: 584 (UA Lemon-Lime), 793 (Gatorade Lemon-Lime), 356 (Blueberry), 831 (Pineapple)

* Consolidate WTP after blind tasting (pre-magnesium info), from wtp_2b_XYZ vars
	gen 			wtp_after_tasting = .
	
	foreach 		var in wtp_2b_584 wtp_2b_793 wtp_2b_356 wtp_2b_831 {
					replace wtp_after_tasting = `var' if wtp_after_tasting == . & `var' != .
		}
		
	label 			var wtp_after_tasting "WTP after blind tasting (pre-mag info)"
	
* Consolidate WTP for control group (no mag info later), from wtp_2a_info_XYZ vars
	gen 			wtp_control_no_mag = .
	
	foreach 		var in wtp_2a_info_584 wtp_2a_info_793 wtp_2a_info_356 wtp_2a_info_831 {
						replace wtp_control_no_mag = `var' if wtp_control_no_mag == . & `var' != .
		}
		
	label 			var wtp_control_no_mag "WTP control group (no further mag info given)"
	
* Consolidate WTP for treatment group (with mag info given), from wtp_3b_info_XYZ vars
	gen 			wtp_treatment_mag_info = .
	
	foreach 		var in wtp_3b_info_584 wtp_3b_info_793 wtp_3b_info_356 wtp_3b_info_831 {
					replace wtp_treatment_mag_info = `var' if wtp_treatment_mag_info == . & `var' != .
		}
	
	label 			var wtp_treatment_mag_info "WTP Treatment Group (with mag info given)"
	
* Create a dummy indicating if a respondent was assigned to the magnesium information treatment path
* (i.e., they saw the WTP question after receiving magnesium benefits information)
	gen 			mag_info_treatment_path = 0
replace mag_info_treatment_path = 1 if wtp_treatment_mag_info != .
label var mag_info_treatment_path "Participant received Magnesium Info (1=Yes, 0=No)"
label define mag_path_label 0 "Control Path (No Mag Info)" 1 "Treatment Path (With Mag Info)"
label values mag_info_treatment_path mag_path_label
* Create a single 'final_wtp' variable for all respondents, reflecting their WTP from
* whichever path (control or treatment) they completed.
gen final_wtp = wtp_treatment_mag_info
replace final_wtp = wtp_control_no_mag if final_wtp == . & wtp_control_no_mag != .
label var final_wtp "Final WTP after all stages/info applicable to participant"
	
	
	
	
	
	
	
	