* course: AREC 397C
* assignment: regs analysis 
* created on: 23 apr 2026
* created by: tml jmt
* edited on: 23 apr 2026
* edited by: tml
* Stata v.19.5

* does
	
	
	

************************************************************ Import the data
* import data from CSV

	import delimited		using "$data/spors_bev_data_use_me.csv", clear
	describe
	

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


********************************************************************************
**## Value labels
********************************************************************************


	label define		gender_lbl 1 "Male" 2 "Female", replace
	label define		day_lbl 1 "Day 1" 2 "Day 2", replace
	label define		yesno_lbl 0 "No" 1 "Yes", replace

* this is how the paths were chosen. need this for determining taste-first /
* info first 
	label define		randomizer_lbl ///
						1 "Randomizer 1" ///
						2 "Randomizer 2" ///
						3 "Randomizer 3" ///
						4 "Randomizer 4", replace

* 5 point importance scale
	label define		imp5_lbl ///
						1 "Not at all important" ///
						2 "Slightly important" ///
						3 "Moderately important" ///
						4 "Very important" ///
						5 "Extremely important", replace
						
						* lower flavor importance binary label
	label define		flavor_low_lbl ///
						0 "Very or extremely important" ///
						1 "Moderately important", replace

* 3 point certainty scale
	label define		sure3_lbl ///
						1 "Low certainty" ///
						2 "Moderate certainty" ///
						3 "High certainty", replace
	
* 5 point agreement scale
	label define		agree5_lbl ///
						1 "Strongly disagree" ///
						2 "Disagree" ///
						3 "Neither agree nor disagree" ///
						4 "Agree" ///
						5 "Strongly agree", replace
* flavors
	label define		flavor2_lbl ///
						1 "Blueberry" ///
						2 "Berry blend" ///
						3 "Fruit Punch" ///
						4 "Grape" ///
						5 "Lemon Lime" ///
						6 "Orange" ///
						7 "Pineapple" ///
						8 "None of them" ///
						9 "Other", replace
* 9 point hedonic scale
	label define		hedonic9_lbl ///
						1 "Dislike extremely" ///
						2 "Dislike very much" ///
						3 "Dislike moderately" ///
						4 "Dislike slightly" ///
						5 "Neither like nor dislike" ///
						6 "Like slightly" ///
						7 "Like moderately" ///
						8 "Like very much" ///
						9 "Like extremely", replace


* 0 to 4 intake frequency scale
	label define		intake5_lbl ///
						0 "Never" ///
						1 "Rarely" ///
						2 "Sometimes" ///
						3 "Often" ///
						4 "Very often", replace
						
********************************************************************************
**## Randomizer / Demo Data
*******************************************************************************

* gender
	label var			gender "Gender"
	label values		gender gender_lbl
	tab					gender, missing

* age
	capture destring	age, replace
	label var			age "Age"
	sum					age, detail

* day
	label var			day "Survey day"
	label values		day day_lbl
	tab					day, missing

* randomizer
* This is what determines what the respondants got first, taste or information
	label var			randomizer "Randomization path"
	label values		randomizer randomizer_lbl
	tab					randomizer, missing

* finished
	label var			finished "Survey completed"
	label values		finished yesno_lbl
	tab					finished, missing

********************************************************************************
**## Preference Vars
********************************************************************************
	
	* pref_sweet
	label var			pref_sweet "Importance of sweetness"
	label values		pref_sweet imp5_lbl
	tab					pref_sweet, missing

* pref_sugar
	label var			pref_sugar "Importance of sugar level"
	label values		pref_sugar imp5_lbl
	tab					pref_sugar, missing

* pref_ingred
	label var			pref_ingred "Importance of functional ingredients"
	label values		pref_ingred imp5_lbl
	tab					pref_ingred, missing

* pref_health
	label var			pref_health "Importance of health claims"
	label values		pref_health imp5_lbl
	tab					pref_health, missing
	
	* lower flavor importance
	capture drop		flavor_low
	gen					flavor_low = pref_flavor == 3 ///
							if !missing(pref_flavor)

	label var			flavor_low ///
							"Flavor importance is moderate rather than very/extremely important"

	label values		flavor_low flavor_low_lbl

	tab					flavor_low, missing
	tab					pref_flavor flavor_low, missing
	
* high sweetness importance binary label
	label define		sweet_high_lbl ///
						0 "Slightly or moderately important" ///
						1 "Very or extremely important", replace
						
* high sugar importance binary label
	label define		sugar_high_lbl ///
						0 "Not at all, slightly, or moderately important" ///
						1 "Very or extremely important", replace

* high functional ingredient importance binary label
	label define		ingred_high_lbl ///
						0 "Not at all, slightly, or moderately important" ///
						1 "Very or extremely important", replace
						
* high health claim importance binary label
	label define		health_high_lbl ///
						0 "Not at all, slightly, or moderately important" ///
						1 "Very or extremely important", replace
						
* high prior magnesium knowledge binary label
	label define		magn_know_high_lbl ///
						0 "Strongly disagree, disagree, or neither" ///
						1 "Agree or strongly agree", replace


********************************************************************************
**## baseline wtp_1
********************************************************************************

* wtp_1
	capture destring	wtp_1, replace
	label var			wtp_1 "Baseline willingness to pay"
	sum					wtp_1, detail

********************************************************************************
**## Flavor Pref
********************************************************************************

* flavor_pref1_1
	replace				flavor_pref1_1 = 0 if missing(flavor_pref1_1)
	label var			flavor_pref1_1 "Selected Blueberry"
	label values		flavor_pref1_1 yesno_lbl
	tab					flavor_pref1_1, missing

* flavor_pref1_2
	replace				flavor_pref1_2 = 0 if missing(flavor_pref1_2)
	label var			flavor_pref1_2 "Selected Berry blend"
	label values		flavor_pref1_2 yesno_lbl
	tab					flavor_pref1_2, missing

* flavor_pref1_3
	replace				flavor_pref1_3 = 0 if missing(flavor_pref1_3)
	label var			flavor_pref1_3 "Selected Fruit Punch"
	label values		flavor_pref1_3 yesno_lbl
	tab					flavor_pref1_3, missing

* flavor_pref1_4
	replace				flavor_pref1_4 = 0 if missing(flavor_pref1_4)
	label var			flavor_pref1_4 "Selected Grape"
	label values		flavor_pref1_4 yesno_lbl
	tab					flavor_pref1_4, missing

* flavor_pref1_5
	replace				flavor_pref1_5 = 0 if missing(flavor_pref1_5)
	label var			flavor_pref1_5 "Selected Lemon Lime"
	label values		flavor_pref1_5 yesno_lbl
	tab					flavor_pref1_5, missing

* flavor_pref1_6
	replace				flavor_pref1_6 = 0 if missing(flavor_pref1_6)
	label var			flavor_pref1_6 "Selected Orange"
	label values		flavor_pref1_6 yesno_lbl
	tab					flavor_pref1_6, missing

* flavor_pref1_7
	replace				flavor_pref1_7 = 0 if missing(flavor_pref1_7)
	label var			flavor_pref1_7 "Selected Pineapple"
	label values		flavor_pref1_7 yesno_lbl
	tab					flavor_pref1_7, missing

* flavor_pref1_8
	replace				flavor_pref1_8 = 0 if missing(flavor_pref1_8)
	label var			flavor_pref1_8 "Selected None of them"
	label values		flavor_pref1_8 yesno_lbl
	tab					flavor_pref1_8, missing

* flavor_pref1_9
	replace				flavor_pref1_9 = 0 if missing(flavor_pref1_9)
	label var			flavor_pref1_9 "Selected Other flavor"
	label values		flavor_pref1_9 yesno_lbl
	tab					flavor_pref1_9, missing
	
********************************************************************************
**## Prior Knowledge
********************************************************************************

* preknow_vitd
	label var			preknow_vitd "Prior knowledge of Vitamin D"
	label values		preknow_vitd agree5_lbl
	tab					preknow_vitd, missing

* preknow_vitc
	label var			preknow_vitc "Prior knowledge of Vitamin C"
	label values		preknow_vitc agree5_lbl
	tab					preknow_vitc, missing

* preknow_calc
	label var			preknow_calc "Prior knowledge of Calcium"
	label values		preknow_calc agree5_lbl
	tab					preknow_calc, missing

* preknow_iron
	label var			preknow_iron "Prior knowledge of Iron"
	label values		preknow_iron agree5_lbl
	tab					preknow_iron, missing

* preknow_pota
	label var			preknow_pota "Prior knowledge of Potassium"
	label values		preknow_pota agree5_lbl
	tab					preknow_pota, missing

* preknow_5_magn
	rename				preknow_5_magn preknow_magn
	label var			preknow_magn "Prior knowledge of Magnesium"
	label values		preknow_magn agree5_lbl
	tab					preknow_magn, missing

********************************************************************************
**## 584 Mag
********************************************************************************
* label all sensory variables: hedonic 1-9

* overall liking
* sensory_584_overall
	label var			sensory_584_overall "584 overall liking"
	label values		sensory_584_overall hedonic9_lbl
	tab					sensory_584_overall, missing
	
	
* flavor liking 	
* sensory_584_flavor
	label var			sensory_584_flavor "584 flavor liking"
	label values		sensory_584_flavor hedonic9_lbl
	tab					sensory_584_flavor, missing

* lemon-lime liking
* sensory_584_lemon
	label var			sensory_584_lemon "584 lemon-lime liking"
	label values		sensory_584_lemon hedonic9_lbl
	tab					sensory_584_lemon, missing

* sweetness liking	
* sensory_584_sweet
	label var			sensory_584_sweet "584 sweetness liking"
	label values		sensory_584_sweet hedonic9_lbl
	tab					sensory_584_sweet, missing

	
********************************************************************************
**## 793 No Mag
********************************************************************************

* sensory_793_overall
	label var			sensory_793_overall "793 overall liking"
	label values		sensory_793_overall hedonic9_lbl
	tab					sensory_793_overall, missing
	
	
	
* sensory_793_flavor
	label var			sensory_793_flavor "793 flavor liking"
	label values		sensory_793_flavor hedonic9_lbl
	tab					sensory_793_flavor, missing

* sensory_793_lemon
	label var			sensory_793_lemon "793 lemon-lime liking"
	label values		sensory_793_lemon hedonic9_lbl
	tab					sensory_793_lemon, missing

* sensory_793_sweet
	label var			sensory_793_sweet "793 sweetness liking"
	label values		sensory_793_sweet hedonic9_lbl
	tab					sensory_793_sweet, missing
	
********************************************************************************
**## Day 1 WTP
********************************************************************************

* wtp_2b_584: taste-first
	capture destring	wtp_2b_584, replace
	label var			wtp_2b_584 "WTP for 584, tasting first"
	sum					wtp_2b_584, detail

* sure_2b_584
	label var			sure_2b_584 "Certainty in WTP for 584, tasting first"
	label values		sure_2b_584 sure3_lbl
	tab					sure_2b_584, missing
	
* taste first
* wtp_2b_793
	capture destring	wtp_2b_793, replace
	label var			wtp_2b_793 "WTP for 793, tasting first"
	sum					wtp_2b_793, detail

* Sure_2b_793
	label var			sure_2b_793 "Certainty in WTP for 793, tasting first"
	label values		sure_2b_793 sure3_lbl
	tab					sure_2b_793, missing


* wtp_3b_info_584
	capture destring	wtp_3b_info_584, replace
	label var			wtp_3b_info_584 "WTP for 584 after information, tasting first"
	sum					wtp_3b_info_584, detail

* wtp_3b_info_793
	capture destring	wtp_3b_info_793, replace
	label var			wtp_3b_info_793 "WTP for 793 after information, tasting first"
	sum					wtp_3b_info_793, detail

* sure_3b_info_584
	label var			sure_3b_info_584 "Certainty in WTP for 584 after information, tasting first"
	label values		sure_3b_info_584 sure3_lbl
	tab					sure_3b_info_584, missing

* sure_3b_info_793
	label var			sure_3b_info_793 "Certainty in WTP for 793 after information, tasting first"
	label values		sure_3b_info_793 sure3_lbl
	tab					sure_3b_info_793, missing


********************************************************************************
**## Day 1 WTP Info First
********************************************************************************

* wtp_2a_info_584
	capture destring	wtp_2a_info_584, replace
	label var			wtp_2a_info_584 "WTP for 584, information first"
	sum					wtp_2a_info_584, detail

* wtp_2a_info_793
	capture destring	wtp_2a_info_793, replace
	label var			wtp_2a_info_793 "WTP for 793, information first"
	sum					wtp_2a_info_793, detail

* sure_2a_info_584
	label var			sure_2a_info_584 "Certainty in WTP for 584, information first"
	label values		sure_2a_info_584 sure3_lbl
	tab					sure_2a_info_584, missing

* sure_2a_info_793
	label var			sure_2a_info_793 "Certainty in WTP for 793, information first"
	label values		sure_2a_info_793 sure3_lbl
	tab					sure_2a_info_793, missing

* wtp_3a_584
	capture destring	wtp_3a_584, replace
	label var			wtp_3a_584 "WTP for 584 after information first, then tasting"
	sum					wtp_3a_584, detail

* sure_3a_584
	label var			sure_3a_584 "Certainty in WTP for 584 information first, then tasting"
	label values		sure_3a_584 sure3_lbl
	tab					sure_3a_584, missing

* wtp_3a_793
	capture destring	wtp_3a_793, replace
	label var			wtp_3a_793 "WTP for 793 information first, then tasting"
	sum					wtp_3a_793, detail
	
* sure_3a_793
	label var			sure_3a_793 "Certainty in WTP for 793 information first, then tasting"
	label values		sure_3a_793 sure3_lbl
	tab					sure_3a_793, missing


********************************************************************************
**## Day 1 Info Reaction
********************************************************************************

* after_info_3b_d1_new
	label var			after_info_3b_d1_new "Magnesium information was new"
	label values		after_info_3b_d1_new agree5_lbl
	tab					after_info_3b_d1_new, missing

* after_info_3b_d1_useful
	label var			after_info_3b_d1_useful "Magnesium information was useful"
	label values		after_info_3b_d1_useful agree5_lbl
	tab					after_info_3b_d1_useful, missing

* after_info_2a_d1_new
	label var			after_info_2a_d1_new "Magnesium information was new"
	label values		after_info_2a_d1_new agree5_lbl
	tab					after_info_2a_d1_new, missing

* after_info_2a_d1_useful
	label var			after_info_2a_d1_useful "Magnesium information was useful"
	label values		after_info_2a_d1_useful agree5_lbl
	tab					after_info_2a_d1_useful, missing


********************************************************************************
**## Day 1 Mag Benefits
********************************************************************************

* mag_benefit_3b_d1_musle
	label var			mag_benefit_3b_d1_musle "Importance of magnesium for muscle recovery"
	sum					mag_benefit_3b_d1_musle, detail

* mag_benefit_3b_d1_cramps
	label var			mag_benefit_3b_d1_cramps "Importance of magnesium for cramp reduction"
	sum					mag_benefit_3b_d1_cramps, detail

* mag_benefit_3b_d1_sugar
	label var			mag_benefit_3b_d1_sugar "Importance of magnesium for blood sugar support"
	sum					mag_benefit_3b_d1_sugar, detail

* mag_benefit_3b_d1_bone
	label var			mag_benefit_3b_d1_bone "Importance of magnesium for bone health"
	sum					mag_benefit_3b_d1_bone, detail

* mag_benefit_3b_d1_sleep
	label var			mag_benefit_3b_d1_sleep "Importance of magnesium for sleep support"
	sum					mag_benefit_3b_d1_sleep, detail

* mag_benefit_2a_d1_muscle
	label var			mag_benefit_2a_d1_muscle "Importance of magnesium for muscle recovery"
	sum					mag_benefit_2a_d1_muscle, detail

* mag_benefit_2a_d1_cramps
	label var			mag_benefit_2a_d1_cramps "Importance of magnesium for cramp reduction"
	sum					mag_benefit_2a_d1_cramps, detail

* mag_benefit_2a_d1_sugar
	label var			mag_benefit_2a_d1_sugar "Importance of magnesium for blood sugar support"
	sum					mag_benefit_2a_d1_sugar, detail

* mag_benefit_2a_d1_bone
	label var			mag_benefit_2a_d1_bone "Importance of magnesium for bone health"
	sum					mag_benefit_2a_d1_bone, detail

* mag_benefit_2a_d1_sleep
	label var			mag_benefit_2a_d1_sleep "Importance of magnesium for sleep support"
	sum					mag_benefit_2a_d1_sleep, detail


********************************************************************************
**## Day 1 Mag Intake
********************************************************************************

* mag_intake_d1_magsupp
	label var			mag_intake_d1_magsupp "Magnesium supplement intake"
	label values		mag_intake_d1_magsupp intake5_lbl
	tab					mag_intake_d1_magsupp, missing

* mag_intake_d1_multivit
	label var			mag_intake_d1_multivit "Multivitamin intake"
	label values		mag_intake_d1_multivit intake5_lbl
	tab					mag_intake_d1_multivit, missing

* mag_intake_2a_d1_magsupp
	label var			mag_intake_2a_d1_magsupp "Magnesium supplement intake"
	label values		mag_intake_2a_d1_magsupp intake5_lbl
	tab					mag_intake_2a_d1_magsupp, missing

* mag_intake_2a_d1_multivit
	label var			mag_intake_2a_d1_multivit "Multivitamin intake"
	label values		mag_intake_2a_d1_multivit intake5_lbl
	tab					mag_intake_2a_d1_multivit, missing

	
********************************************************************************
**# Day 2
********************************************************************************

********************************************************************************
**## 356 Blueberry
********************************************************************************

* sensory_356_overall
	label var			sensory_356_overall "356 overall liking"
	label values		sensory_356_overall hedonic9_lbl
	tab					sensory_356_overall, missing
	
	
* sensory_356_flavor
	label var			sensory_356_flavor "356 flavor liking"
	label values		sensory_356_flavor hedonic9_lbl
	tab					sensory_356_flavor, missing

* sensory_356_blueberry
	label var			sensory_356_blueberry "356 blueberry liking"
	label values		sensory_356_blueberry hedonic9_lbl
	tab					sensory_356_blueberry, missing

* sensory_356_sweet
	label var			sensory_356_sweet "356 sweetness liking"
	label values		sensory_356_sweet hedonic9_lbl
	tab					sensory_356_sweet, missing
	
********************************************************************************
**## 831 Pineapple
********************************************************************************

* sensory_831_overall
	label var			sensory_831_overall "831 overall liking"
	label values		sensory_831_overall hedonic9_lbl
	tab					sensory_831_overall, missing

	
* sensory_831_flavor
	label var			sensory_831_flavor "831 flavor liking"
	label values		sensory_831_flavor hedonic9_lbl
	tab					sensory_831_flavor, missing
	
* sensory_831_pineapple
	label var			sensory_831_pineapple "831 pineapple liking"
	label values		sensory_831_pineapple hedonic9_lbl
	tab					sensory_831_pineapple, missing

* sensory_831_sweet
	label var			sensory_831_sweet "831 sweetness liking"
	label values		sensory_831_sweet hedonic9_lbl
	tab					sensory_831_sweet, missing

	
********************************************************************************
**## Day 2 WTP Taste First
********************************************************************************

* wtp_2b_356
	capture destring	wtp_2b_356, replace
	label var			wtp_2b_356 "WTP for 356, tasting first"
	sum					wtp_2b_356, detail

* sure_2b_356
	label var			sure_2b_356 "Certainty in WTP for 356, tasting first"
	label values		sure_2b_356 sure3_lbl
	tab					sure_2b_356, missing

* wtp_2b_831
	capture destring	wtp_2b_831, replace
	label var			wtp_2b_831 "WTP for 831, tasting first"
	sum					wtp_2b_831, detail

* sure_2b_831
	label var			sure_2b_831 "Certainty in WTP for 831, tasting first"
	label values		sure_2b_831 sure3_lbl
	tab					sure_2b_831, missing

* wtp_3b_info_356
	capture destring	wtp_3b_info_356, replace
	label var			wtp_3b_info_356 "WTP for 356 after information, tasting first"
	sum					wtp_3b_info_356, detail

* wtp_3b_info_831
	capture destring	wtp_3b_info_831, replace
	label var			wtp_3b_info_831 "WTP for 831 after information, tasting first"
	sum					wtp_3b_info_831, detail
	
********************************************************************************
**## Day 2 WTP - Info First
********************************************************************************

* wtp_2a_info_356
	capture destring	wtp_2a_info_356, replace
	label var			wtp_2a_info_356 "WTP for 356, information first"
	sum					wtp_2a_info_356, detail

* wtp_2a_info_831
	capture destring	wtp_2a_info_831, replace
	label var			wtp_2a_info_831 "WTP for 831, information first"
	sum				wtp_2a_info_831, detail

* sure_2a_info_356
	label var			sure_2a_info_356 "Certainty in WTP for 356, information first"
	label values		sure_2a_info_356 sure3_lbl
	tab					sure_2a_info_356, missing

* sure_2a_info_831
	label var			sure_2a_info_831 "Certainty in WTP for 831, information first"
	label values		sure_2a_info_831 sure3_lbl
	tab					sure_2a_info_831, missing

* wtp_3a_356
	capture destring	wtp_3a_356, replace
	label var			wtp_3a_356 "WTP for 356 information first, then tasting"
	sum					wtp_3a_356, detail
	
	
	********************************************************************************
**## Day 2 Mag Benefits
********************************************************************************

* mag_benefit_3b_d2_muscle
	label var			mag_benefit_3b_d2_muscle "Importance of magnesium for muscle recovery"
	sum					mag_benefit_3b_d2_muscle, detail

* mag_benefit_3b_d2_cramps
	label var			mag_benefit_3b_d2_cramps "Importance of magnesium for cramp reduction"
	sum				mag_benefit_3b_d2_cramps, detail

* mag_benefit_3b_d2_sugar
	label var			mag_benefit_3b_d2_sugar "Importance of magnesium for blood sugar support"
	sum				mag_benefit_3b_d2_sugar, detail

* mag_benefit_3b_d2_bone
	label var			mag_benefit_3b_d2_bone "Importance of magnesium for bone health"
	sum				mag_benefit_3b_d2_bone, detail

* mag_benefit_3b_d2_sleep
	label var			mag_benefit_3b_d2_sleep "Importance of magnesium for sleep support"
	sum				mag_benefit_3b_d2_sleep, detail

* mag_benefit_2a_d2_muscle
	label var			mag_benefit_2a_d2_muscle "Importance of magnesium for muscle recovery"
	sum					mag_benefit_2a_d2_muscle, detail

* mag_benefit_2a_d2_cramps
	label var			mag_benefit_2a_d2_cramps "Importance of magnesium for cramp reduction"
	sum					mag_benefit_2a_d2_cramps, detail

* mag_benefit_2a_d2_sugar
	label var			mag_benefit_2a_d2_sugar "Importance of magnesium for blood sugar support"
	sum					mag_benefit_2a_d2_sugar, detail

* mag_benefit_2a_d2_bone
	label var			mag_benefit_2a_d2_bone "Importance of magnesium for bone health"
	sum					mag_benefit_2a_d2_bone, detail

* mag_benefit_2a_d2_sleep
	label var			mag_benefit_2a_d2_sleep "Importance of magnesium for sleep support"
	sum					mag_benefit_2a_d2_sleep, detail


********************************************************************************
**## Day 2 Mag Intake
********************************************************************************

* mag_intake_3b_d2_magsupp
	label var			mag_intake_3b_d2_magsupp "Magnesium supplement intake"
	label values		mag_intake_3b_d2_magsupp intake5_lbl
	tab					mag_intake_3b_d2_magsupp, missing

* mag_intake_3b_d2_multivit
	label var			mag_intake_3b_d2_multivit "Multivitamin intake"
	label values		mag_intake_3b_d2_multivit intake5_lbl
	tab					mag_intake_3b_d2_multivit, missing

* mag_intake_2a_d2_magsupp
	label var			mag_intake_2a_d2_magsupp "Magnesium supplement intake"
	label values		mag_intake_2a_d2_magsupp intake5_lbl
	tab					mag_intake_2a_d2_magsupp, missing

* mag_intake_2a_d2_multivit
	label var			mag_intake_2a_d2_multivit "Multivitamin intake"
	label values		mag_intake_2a_d2_multivit intake5_lbl
	tab					mag_intake_2a_d2_multivit, missing
	

*** participants who exercise more
* exercise
*** 30 minutes / days
*** it's a string, need to destring it

	cap destring			exercise, replace
	label var				exercise "Days per week of 30+ min of moderate to vigourous physical activity"
	sum						exercise, detail
	
	
	*** consumption situation
* con_situation 

* con_situation_1 = Before Exercise
	* con_situation_1
	replace				con_situation_1 = 0 if missing(con_situation_1)
	label var			con_situation_1 "Before exercise"
	label values		con_situation_1 yesno_lbl
	tab					con_situation_1, missing

* con_situation_2 = During Exercise
	replace				con_situation_2 = 0 if missing(con_situation_2)
	label var			con_situation_2 "During exercise"
	label values		con_situation_2 yesno_lbl
	tab					con_situation_2, missing

* con_situation_3 = After Exercise
	replace				con_situation_3 = 0 if missing(con_situation_3)
	label var			con_situation_3 "After exercise"
	label values		con_situation_3 yesno_lbl
	tab					con_situation_3, missing
	
	
********************************************************************************
* Exercise groups
********************************************************************************

	capture drop 		exercise_hi
	gen 				exercise_hi = exercise >= 3 if !missing(exercise)

	label define 		exercise_hi_lbl 0 "Low exercise" 1 "High exercise", replace
	label values 		exercise_hi exercise_hi_lbl

	tab 				exercise, missing
	tab 				exercise_hi, missing
	
	
	
	
	
********************************************************************************
**## brainstorm hyp 1 regs
********************************************************************************

* Are changes in willingness to pay mainly explained by sensory experience, ///
 especially flavor and sweetness, or does magnesium information/functionality ///
 add explanatory power beyond taste?
 
 * let's start by setting our dependent. This will be reused for both hyps
 
 **## wtp_3 dependent differences
 
* wtp_3[final_path]_[beverage] - wtp_1


**### Day 1 final wtp

* Make sure baseline and final WTP variables are numeric
foreach v in ///
		wtp_1 ///
		wtp_3b_info_584 wtp_3b_info_793 ///
		wtp_3a_584      wtp_3a_793 ///
		wtp_3b_info_356 wtp_3b_info_831 ///
		wtp_3a_356      wtp_3a_831 {
		
		capture destring	`v', replace ignore("$, ")
	}


********************************************************************************
**## Day 1 - final WTP change from baseline
********************************************************************************

* 584, taste-first path
	capture drop		d1_dwtp_3b_584
	gen					d1_dwtp_3b_584 = wtp_3b_info_584 - wtp_1 ///
							if day == 1 & !missing(wtp_3b_info_584, wtp_1)
	label var			d1_dwtp_3b_584 ///
							"Day 1: WTP change for 584 from baseline, taste-first final WTP"

* 793, taste-first path
	capture drop		d1_dwtp_3b_793
	gen					d1_dwtp_3b_793 = wtp_3b_info_793 - wtp_1 ///
							if day == 1 & !missing(wtp_3b_info_793, wtp_1)
	label var			d1_dwtp_3b_793 ///
							"Day 1: WTP change for 793 from baseline, taste-first final WTP"

* 584, info-first path
	capture drop		d1_dwtp_3a_584
	gen					d1_dwtp_3a_584 = wtp_3a_584 - wtp_1 ///
							if day == 1 & !missing(wtp_3a_584, wtp_1)
	label var			d1_dwtp_3a_584 ///
							"Day 1: WTP change for 584 from baseline, info-first final WTP"

* 793, info-first path
	capture drop		d1_dwtp_3a_793
	gen					d1_dwtp_3a_793 = wtp_3a_793 - wtp_1 ///
							if day == 1 & !missing(wtp_3a_793, wtp_1)
	label var			d1_dwtp_3a_793 ///
							"Day 1: WTP change for 793 from baseline, info-first final WTP"


********************************************************************************
**## Day 2 - final WTP change from baseline
********************************************************************************

* 356, taste-first path
	capture drop		d2_dwtp_3b_356
	gen					d2_dwtp_3b_356 = wtp_3b_info_356 - wtp_1 ///
							if day == 2 & !missing(wtp_3b_info_356, wtp_1)
	label var			d2_dwtp_3b_356 ///
							"Day 2: WTP change for 356 from baseline, taste-first final WTP"

* 831, taste-first path
	capture drop		d2_dwtp_3b_831
	gen					d2_dwtp_3b_831 = wtp_3b_info_831 - wtp_1 ///
							if day == 2 & !missing(wtp_3b_info_831, wtp_1)
	label var			d2_dwtp_3b_831 ///
							"Day 2: WTP change for 831 from baseline, taste-first final WTP"

* 356, info-first path
	capture drop		d2_dwtp_3a_356
	gen					d2_dwtp_3a_356 = wtp_3a_356 - wtp_1 ///
							if day == 2 & !missing(wtp_3a_356, wtp_1)
	label var			d2_dwtp_3a_356 ///
							"Day 2: WTP change for 356 from baseline, info-first final WTP"

* 831, info-first path
	capture drop		d2_dwtp_3a_831
	gen					d2_dwtp_3a_831 = wtp_3a_831 - wtp_1 ///
							if day == 2 & !missing(wtp_3a_831, wtp_1)
	label var			d2_dwtp_3a_831 ///
							"Day 2: WTP change for 831 from baseline, info-first final WTP"


********************************************************************************
**## Check dependent variables
********************************************************************************

	sum					d1_dwtp_3b_584 d1_dwtp_3b_793 ///
							d1_dwtp_3a_584 d1_dwtp_3a_793 ///
							d2_dwtp_3b_356 d2_dwtp_3b_831 ///
							d2_dwtp_3a_356 d2_dwtp_3a_831, detail



* Looks good. Let's consider what flavors someone from day 1 may
* have an effect on their wtp of day 1


* lemon lime would be the obvious choice for day 1



********************************************************************************
**## Day 1 - Lemon-Lime preferred flavor
********************************************************************************

* Lemon-Lime preferred flavor indicator
	capture drop		d1_pref_lemon
	gen					d1_pref_lemon = flavor_pref1_5 ///
							if day == 1 & !missing(flavor_pref1_5)

	label var			d1_pref_lemon ///
							"Day 1: Selected Lemon-Lime as preferred flavor"

	label values		d1_pref_lemon yesno_lbl

* Check Lemon-Lime preference among Day 1 respondents
	tab					d1_pref_lemon if day == 1, missing

* Check Lemon-Lime preference by randomization path
	tab					d1_pref_lemon randomizer if day == 1, missing

********************************************************************************
**## General flavor importance
********************************************************************************

* pref_flavor
	label var			pref_flavor "Importance of flavor"
	label values		pref_flavor imp5_lbl
	tab					pref_flavor, missing

* Check flavor importance among Day 1 respondents
	tab					pref_flavor if day == 1, missing

* Check flavor importance by Lemon-Lime preference among Day 1 respondents
	tab					pref_flavor d1_pref_lemon if day == 1, missing


********************************************************************************
**## Flavor importance category
********************************************************************************

* lower flavor importance
	capture drop		flavor_low
	gen					flavor_low = pref_flavor == 3 ///
							if !missing(pref_flavor)

	label var			flavor_low ///
							"Flavor importance is moderate rather than very/extremely important"

	label values		flavor_low flavor_low_lbl

	tab					flavor_low, missing
	tab					pref_flavor flavor_low, missing

* Check lower flavor importance among Day 1 respondents
	tab					flavor_low if day == 1, missing

* Check lower flavor importance by Lemon-Lime preference among Day 1 respondents
	tab					flavor_low d1_pref_lemon if day == 1, missing
	
	
	********************************************************************************
**## General sweetness importance
********************************************************************************

* pref_sweet
	label var			pref_sweet "Importance of sweetness"
	label values		pref_sweet imp5_lbl
	tab					pref_sweet, missing

* Check sweetness importance among Day 1 respondents
	tab					pref_sweet if day == 1, missing

* Check sweetness importance by Lemon-Lime preference among Day 1 respondents
	tab					pref_sweet d1_pref_lemon if day == 1, missing

* Check sweetness importance by flavor importance category among Day 1 respondents
	tab					pref_sweet flavor_low if day == 1, missing
	
	
********************************************************************************
**## General sweetness importance
********************************************************************************

* pref_sweet
	label var			pref_sweet "Importance of sweetness"
	label values		pref_sweet imp5_lbl
	tab					pref_sweet, missing

* high sweetness importance
	capture drop		sweet_high
	gen					sweet_high = inlist(pref_sweet, 4, 5) ///
							if !missing(pref_sweet)

	label var			sweet_high ///
							"Sweetness is very or extremely important"

	label values		sweet_high sweet_high_lbl

	tab					sweet_high, missing
	tab					pref_sweet sweet_high, missing
	
	
********************************************************************************
**## General sugar importance
********************************************************************************

* pref_sugar
	label var			pref_sugar "Importance of sugar level"
	label values		pref_sugar imp5_lbl
	tab					pref_sugar, missing

* high sugar importance
	capture drop		sugar_high
	gen					sugar_high = inlist(pref_sugar, 4, 5) ///
							if !missing(pref_sugar)

	label var			sugar_high ///
							"Sugar level is very or extremely important"

	label values		sugar_high sugar_high_lbl

	tab					sugar_high, missing
	tab					pref_sugar sugar_high, missing

* Check sugar importance among Day 1 respondents
	tab					pref_sugar if day == 1, missing

* Check high sugar importance among Day 1 respondents
	tab					sugar_high if day == 1, missing

* Check high sugar importance by Lemon-Lime preference among Day 1 respondents
	tab					sugar_high d1_pref_lemon if day == 1, missing

* Check high sugar importance by sweetness importance among Day 1 respondents
	tab					sugar_high sweet_high if day == 1, missing
	

********************************************************************************
**## General functional ingredient importance
********************************************************************************

* pref_ingred
	label var			pref_ingred "Importance of functional ingredients"
	label values		pref_ingred imp5_lbl
	tab					pref_ingred, missing

* high functional ingredient importance
	capture drop		ingred_high
	gen					ingred_high = inlist(pref_ingred, 4, 5) ///
							if !missing(pref_ingred)

	label var			ingred_high ///
							"Functional ingredients are very or extremely important"

	label values		ingred_high ingred_high_lbl

	tab					ingred_high, missing
	tab					pref_ingred ingred_high, missing

* Check functional ingredient importance among Day 1 respondents
	tab					pref_ingred if day == 1, missing

* Check high functional ingredient importance among Day 1 respondents
	tab					ingred_high if day == 1, missing

* Check high functional ingredient importance by Lemon-Lime preference among Day 1 respondents
	tab					ingred_high d1_pref_lemon if day == 1, missing

* Check high functional ingredient importance by sweetness importance among Day 1 respondents
	tab					ingred_high sweet_high if day == 1, missing

* Check high functional ingredient importance by sugar importance among Day 1 respondents
	tab					ingred_high sugar_high if day == 1, missing
	
	
	
********************************************************************************
**## General health claim importance
********************************************************************************

* pref_health
	label var			pref_health "Importance of health claims"
	label values		pref_health imp5_lbl
	tab					pref_health, missing

* Check health claim importance among Day 1 respondents
	tab					pref_health if day == 1, missing

* Check health claim importance by Lemon-Lime preference among Day 1 respondents
	tab					pref_health d1_pref_lemon if day == 1, missing

* Check health claim importance by sweetness importance among Day 1 respondents
	tab					pref_health sweet_high if day == 1, missing

* Check health claim importance by sugar importance among Day 1 respondents
	tab					pref_health sugar_high if day == 1, missing

* Check health claim importance by functional ingredient importance among Day 1 respondents
	tab					pref_health ingred_high if day == 1, missing
	
********************************************************************************
**## General health claim importance
********************************************************************************

* pref_health
	label var			pref_health "Importance of health claims"
	label values		pref_health imp5_lbl
	tab					pref_health, missing

* high health claim importance
	capture drop		health_high
	gen					health_high = inlist(pref_health, 4, 5) ///
							if !missing(pref_health)

	label var			health_high ///
							"Health claims are very or extremely important"

	label values		health_high health_high_lbl

	tab					health_high, missing
	tab					pref_health health_high, missing

* Check health claim importance among Day 1 respondents
	tab					pref_health if day == 1, missing

* Check high health claim importance among Day 1 respondents
	tab					health_high if day == 1, missing

* Check high health claim importance by Lemon-Lime preference among Day 1 respondents
	tab					health_high d1_pref_lemon if day == 1, missing

* Check high health claim importance by sweetness importance among Day 1 respondents
	tab					health_high sweet_high if day == 1, missing

* Check high health claim importance by sugar importance among Day 1 respondents
	tab					health_high sugar_high if day == 1, missing

* Check high health claim importance by functional ingredient importance among Day 1 respondents
	tab					health_high ingred_high if day == 1, missing
	
	
********************************************************************************
**## Prior magnesium knowledge
********************************************************************************

* preknow_magn
	label var			preknow_magn "Prior knowledge of Magnesium"
	label values		preknow_magn agree5_lbl
	tab					preknow_magn, missing

* high prior magnesium knowledge
	capture drop		magn_know_high
	gen					magn_know_high = inlist(preknow_magn, 4, 5) ///
							if !missing(preknow_magn)

	label var			magn_know_high ///
							"Prior magnesium knowledge is agree or strongly agree"

	label values		magn_know_high magn_know_high_lbl

	tab					magn_know_high, missing
	tab					preknow_magn magn_know_high, missing

* Check prior magnesium knowledge among Day 1 respondents
	tab					preknow_magn if day == 1, missing

* Check high prior magnesium knowledge among Day 1 respondents
	tab					magn_know_high if day == 1, missing

* Check high prior magnesium knowledge by Lemon-Lime preference among Day 1 respondents
	tab					magn_know_high d1_pref_lemon if day == 1, missing

* Check high prior magnesium knowledge by sweetness importance among Day 1 respondents
	tab					magn_know_high sweet_high if day == 1, missing

* Check high prior magnesium knowledge by sugar importance among Day 1 respondents
	tab					magn_know_high sugar_high if day == 1, missing

* Check high prior magnesium knowledge by functional ingredient importance among Day 1 respondents
	tab					magn_know_high ingred_high if day == 1, missing

* Check high prior magnesium knowledge by health claim importance among Day 1 respondents
	tab					magn_know_high health_high if day == 1, missing
	
* going to export all of these new tables to csv so that i can call to them /// 
quickly and as necessary. They are found in reg_tables


********************************************************************************
**# first regs
********************************************************************************

**## dependent vars
/*
d1_dwtp_3b_584
d1_dwtp_3b_793
d1_dwtp_3a_584
d1_dwtp_3a_793
*/




********************************************************************************
**## Set H1 explanatory variables
********************************************************************************

	local h1_x			d1_pref_lemon ///
						flavor_low ///
						sweet_high ///
						sugar_high ///
						ingred_high ///
						health_high ///
						magn_know_high


********************************************************************************
**## Day 1 - 584, taste-first path
********************************************************************************

	reg					d1_dwtp_3b_584 ///
							`h1_x', robust

	estimates store		h1_d1_3b_584

	esttab				h1_d1_3b_584 ///
							using "$reg_tables/h1_d1_3b_584.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle


********************************************************************************
**## Day 1 - 793, taste-first path
********************************************************************************

	reg					d1_dwtp_3b_793 ///
							`h1_x', robust

	estimates store		h1_d1_3b_793

	esttab				h1_d1_3b_793 ///
							using "$reg_tables/h1_d1_3b_793.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle


********************************************************************************
**## Day 1 - 584, info-first path
********************************************************************************

	reg					d1_dwtp_3a_584 ///
							`h1_x', robust

	estimates store		h1_d1_3a_584

	esttab				h1_d1_3a_584 ///
							using "$reg_tables/h1_d1_3a_584.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle


********************************************************************************
**## Day 1 - 793, info-first path
********************************************************************************

	reg					d1_dwtp_3a_793 ///
							`h1_x', robust

	estimates store		h1_d1_3a_793

	esttab				h1_d1_3a_793 ///
							using "$reg_tables/h1_d1_3a_793.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle
							
							
********************************************************************************
**## Day 2 - product-specific preferred flavors
********************************************************************************

* Blueberry preferred flavor indicator
	capture drop		d2_pref_blueberry
	gen					d2_pref_blueberry = flavor_pref1_1 ///
							if day == 2 & !missing(flavor_pref1_1)

	label var			d2_pref_blueberry ///
							"Day 2: Selected Blueberry as preferred flavor"

	label values		d2_pref_blueberry yesno_lbl

	tab					d2_pref_blueberry if day == 2, missing
	tab					d2_pref_blueberry randomizer if day == 2, missing


* Pineapple preferred flavor indicator
	capture drop		d2_pref_pineapple
	gen					d2_pref_pineapple = flavor_pref1_7 ///
							if day == 2 & !missing(flavor_pref1_7)

	label var			d2_pref_pineapple ///
							"Day 2: Selected Pineapple as preferred flavor"

	label values		d2_pref_pineapple yesno_lbl

	tab					d2_pref_pineapple if day == 2, missing
	tab					d2_pref_pineapple randomizer if day == 2, missing
	
	
local h1_x_356		d2_pref_blueberry ///
					flavor_low ///
					sweet_high ///
					sugar_high ///
					ingred_high ///
					health_high ///
					magn_know_high

local h1_x_831		d2_pref_pineapple ///
					flavor_low ///
					sweet_high ///
					sugar_high ///
					ingred_high ///
					health_high ///
					magn_know_high
					

********************************************************************************
**## Day 2 regs - 356, taste-first path
********************************************************************************

	reg					d2_dwtp_3b_356 ///
							`h1_x_356', robust

	estimates store		h1_d2_3b_356

	esttab				h1_d2_3b_356 ///
							using "$reg_tables/h1_d2_3b_356.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle


********************************************************************************
**## Day 2 - 831, taste-first path
********************************************************************************

	reg					d2_dwtp_3b_831 ///
							`h1_x_831', robust

	estimates store		h1_d2_3b_831

	esttab				h1_d2_3b_831 ///
							using "$reg_tables/h1_d2_3b_831.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle


********************************************************************************
**## Day 2 - 356, info-first path
********************************************************************************

	reg					d2_dwtp_3a_356 ///
							`h1_x_356', robust

	estimates store		h1_d2_3a_356

	esttab				h1_d2_3a_356 ///
							using "$reg_tables/h1_d2_3a_356.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle


********************************************************************************
**## Day 2 - 831, info-first path
********************************************************************************

	reg					d2_dwtp_3a_831 ///
							`h1_x_831', robust

	estimates store		h1_d2_3a_831

	esttab				h1_d2_3a_831 ///
							using "$reg_tables/h1_d2_3a_831.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle


********************************************************************************
**## Check exported Day 2 H1 regression CSVs
********************************************************************************

	dir					"$reg_tables\h1_d2_*.csv"
	
********************************************************************************
**# H1 comparison table
********************************************************************************

********************************************************************************
**## Re-run H1 models with aligned product-specific preference variable
********************************************************************************

	estimates clear

	capture drop		product_pref
	gen					product_pref = .

	label var			product_pref ///
							"Product-specific preferred flavor"

	label values		product_pref yesno_lbl


********************************************************************************
**## Day 1 - 584, taste-first path
********************************************************************************

	replace				product_pref = d1_pref_lemon if day == 1

	reg					d1_dwtp_3b_584 ///
							product_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1_cmp_d1_3b_584


********************************************************************************
**## Day 1 - 793, taste-first path
********************************************************************************

	replace				product_pref = d1_pref_lemon if day == 1

	reg					d1_dwtp_3b_793 ///
							product_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1_cmp_d1_3b_793


********************************************************************************
**## Day 1 - 584, info-first path
********************************************************************************

	replace				product_pref = d1_pref_lemon if day == 1

	reg					d1_dwtp_3a_584 ///
							product_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1_cmp_d1_3a_584


********************************************************************************
**## Day 1 - 793, info-first path
********************************************************************************

	replace				product_pref = d1_pref_lemon if day == 1

	reg					d1_dwtp_3a_793 ///
							product_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1_cmp_d1_3a_793


********************************************************************************
**## Day 2 - 356, taste-first path
********************************************************************************

	replace				product_pref = d2_pref_blueberry if day == 2

	reg					d2_dwtp_3b_356 ///
							product_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1_cmp_d2_3b_356


********************************************************************************
**## Day 2 - 831, taste-first path
********************************************************************************

	replace				product_pref = d2_pref_pineapple if day == 2

	reg					d2_dwtp_3b_831 ///
							product_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1_cmp_d2_3b_831


********************************************************************************
**## Day 2 - 356, info-first path
********************************************************************************

	replace				product_pref = d2_pref_blueberry if day == 2

	reg					d2_dwtp_3a_356 ///
							product_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1_cmp_d2_3a_356


********************************************************************************
**## Day 2 - 831, info-first path
********************************************************************************

	replace				product_pref = d2_pref_pineapple if day == 2

	reg					d2_dwtp_3a_831 ///
							product_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1_cmp_d2_3a_831


********************************************************************************
**## Export H1 comparison table
********************************************************************************

	esttab				h1_cmp_d1_3b_584 ///
						h1_cmp_d1_3b_793 ///
						h1_cmp_d1_3a_584 ///
						h1_cmp_d1_3a_793 ///
						h1_cmp_d2_3b_356 ///
						h1_cmp_d2_3b_831 ///
						h1_cmp_d2_3a_356 ///
						h1_cmp_d2_3a_831 ///
							using "$reg_tables/h1_comparison_all_models.csv", ///
							replace csv label ///
							mtitles("D1 584 3b" ///
									"D1 793 3b" ///
									"D1 584 3a" ///
									"D1 793 3a" ///
									"D2 356 3b" ///
									"D2 831 3b" ///
									"D2 356 3a" ///
									"D2 831 3a") ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							order(product_pref ///
									flavor_low ///
									sweet_high ///
									sugar_high ///
									ingred_high ///
									health_high ///
									magn_know_high ///
									_cons) ///
							coeflabels(product_pref ///
										"Product-specific preferred flavor" ///
										flavor_low ///
										"Flavor importance is moderate rather than very/extremely important" ///
										sweet_high ///
										"Sweetness is very or extremely important" ///
										sugar_high ///
										"Sugar level is very or extremely important" ///
										ingred_high ///
										"Functional ingredients are very or extremely important" ///
										health_high ///
										"Health claims are very or extremely important" ///
										magn_know_high ///
										"Prior magnesium knowledge is agree or strongly agree" ///
										_cons ///
										"Constant") ///
							noobs nonumber

	dir					"$reg_tables\h1_comparison_all_models.csv"
	
********************************************************************************
**## Flavor-family preference variables
********************************************************************************

********************************************************************************
**### Day 1 - Lemon-Lime family
********************************************************************************

* Lemon-Lime family preferred flavor indicator
* Includes Lemon-Lime, Orange, Fruit Punch, and Pineapple
	capture drop		d1_pref_lemon_family
	gen					d1_pref_lemon_family = ///
							(flavor_pref1_5 == 1 | ///
							 flavor_pref1_6 == 1 | ///
							 flavor_pref1_3 == 1 | ///
							 flavor_pref1_7 == 1) ///
							if day == 1

	label var			d1_pref_lemon_family ///
							"Day 1: Selected Lemon-Lime family as preferred flavor"

	label values		d1_pref_lemon_family yesno_lbl

	tab					d1_pref_lemon_family if day == 1, missing
	tab					d1_pref_lemon_family d1_pref_lemon if day == 1, missing
	tab					d1_pref_lemon_family randomizer if day == 1, missing


********************************************************************************
**### Day 2 - Blueberry family
********************************************************************************

* Blueberry family preferred flavor indicator
* Includes Blueberry, Berry blend, Grape, and Lemon-Lime
	capture drop		d2_pref_blueberry_family
	gen					d2_pref_blueberry_family = ///
							(flavor_pref1_1 == 1 | ///
							 flavor_pref1_2 == 1 | ///
							 flavor_pref1_4 == 1 | ///
							 flavor_pref1_5 == 1) ///
							if day == 2

	label var			d2_pref_blueberry_family ///
							"Day 2: Selected Blueberry family as preferred flavor"

	label values		d2_pref_blueberry_family yesno_lbl

	tab					d2_pref_blueberry_family if day == 2, missing
	tab					d2_pref_blueberry_family d2_pref_blueberry if day == 2, missing
	tab					d2_pref_blueberry_family randomizer if day == 2, missing


********************************************************************************
**### Day 2 - Pineapple family
********************************************************************************

* Pineapple family preferred flavor indicator
* Includes Lemon-Lime, Fruit Punch, Orange, and Pineapple
	capture drop		d2_pref_pineapple_family
	gen					d2_pref_pineapple_family = ///
							(flavor_pref1_5 == 1 | ///
							 flavor_pref1_3 == 1 | ///
							 flavor_pref1_6 == 1 | ///
							 flavor_pref1_7 == 1) ///
							if day == 2

	label var			d2_pref_pineapple_family ///
							"Day 2: Selected Pineapple family as preferred flavor"

	label values		d2_pref_pineapple_family yesno_lbl

	tab					d2_pref_pineapple_family if day == 2, missing
	tab					d2_pref_pineapple_family d2_pref_pineapple if day == 2, missing
	tab					d2_pref_pineapple_family randomizer if day == 2, missing
	
********************************************************************************
**## Set H1 flavor-family explanatory variables
********************************************************************************

	local h1_x_d1_family	d1_pref_lemon_family ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high

	local h1_x_356_family	d2_pref_blueberry_family ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high

	local h1_x_831_family	d2_pref_pineapple_family ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high
							
********************************************************************************
**## Day 1 family model - 584, taste-first path
********************************************************************************

	reg					d1_dwtp_3b_584 ///
							`h1_x_d1_family', robust

	estimates store		h1fam_d1_3b_584

	esttab				h1fam_d1_3b_584 ///
							using "$reg_tables/h1fam_d1_3b_584.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle


********************************************************************************
**## Day 1 family model - 793, taste-first path
********************************************************************************

	reg					d1_dwtp_3b_793 ///
							`h1_x_d1_family', robust

	estimates store		h1fam_d1_3b_793

	esttab				h1fam_d1_3b_793 ///
							using "$reg_tables/h1fam_d1_3b_793.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle


********************************************************************************
**## Day 1 family model - 584, info-first path
********************************************************************************

	reg					d1_dwtp_3a_584 ///
							`h1_x_d1_family', robust

	estimates store		h1fam_d1_3a_584

	esttab				h1fam_d1_3a_584 ///
							using "$reg_tables/h1fam_d1_3a_584.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle


********************************************************************************
**## Day 1 family model - 793, info-first path
********************************************************************************

	reg					d1_dwtp_3a_793 ///
							`h1_x_d1_family', robust

	estimates store		h1fam_d1_3a_793

	esttab				h1fam_d1_3a_793 ///
							using "$reg_tables/h1fam_d1_3a_793.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle
							
********************************************************************************
**## Day 2 family model - 356, taste-first path
********************************************************************************

	reg					d2_dwtp_3b_356 ///
							`h1_x_356_family', robust

	estimates store		h1fam_d2_3b_356

	esttab				h1fam_d2_3b_356 ///
							using "$reg_tables/h1fam_d2_3b_356.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle


********************************************************************************
**## Day 2 family model - 831, taste-first path
********************************************************************************

	reg					d2_dwtp_3b_831 ///
							`h1_x_831_family', robust

	estimates store		h1fam_d2_3b_831

	esttab				h1fam_d2_3b_831 ///
							using "$reg_tables/h1fam_d2_3b_831.csv",  ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle


********************************************************************************
**## Day 2 family model - 356, info-first path
********************************************************************************

	reg					d2_dwtp_3a_356 ///
							`h1_x_356_family', robust

	estimates store		h1fam_d2_3a_356

	esttab				h1fam_d2_3a_356 ///
							using "$reg_tables/h1fam_d2_3a_356.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle


********************************************************************************
**## Day 2 family model - 831, info-first path
********************************************************************************

	reg					d2_dwtp_3a_831 ///
							`h1_x_831_family', robust

	estimates store		h1fam_d2_3a_831

	esttab				h1fam_d2_3a_831 ///
							using "$reg_tables/h1fam_d2_3a_831.csv", ///
							replace csv label ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							noobs nonumber nomtitle


********************************************************************************
**## Check exported H1 flavor-family regression CSVs
********************************************************************************

	dir					"$reg_tables\h1fam_*.csv"
	
	
********************************************************************************
**# H1 flavor-family comparison table
********************************************************************************

********************************************************************************
**## Re-run H1 family models with aligned family-preference variable
********************************************************************************

	estimates clear

	capture drop		family_pref
	gen					family_pref = .

	label var			family_pref ///
							"Flavor-family preferred flavor"

	label values		family_pref yesno_lbl


********************************************************************************
**## Day 1 family model - 584, taste-first path
********************************************************************************

	replace				family_pref = .
	replace				family_pref = d1_pref_lemon_family if day == 1

	reg					d1_dwtp_3b_584 ///
							family_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1fam_cmp_d1_3b_584


********************************************************************************
**## Day 1 family model - 793, taste-first path
********************************************************************************

	replace				family_pref = .
	replace				family_pref = d1_pref_lemon_family if day == 1

	reg					d1_dwtp_3b_793 ///
							family_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1fam_cmp_d1_3b_793


********************************************************************************
**## Day 1 family model - 584, info-first path
********************************************************************************

	replace				family_pref = .
	replace				family_pref = d1_pref_lemon_family if day == 1

	reg					d1_dwtp_3a_584 ///
							family_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1fam_cmp_d1_3a_584


********************************************************************************
**## Day 1 family model - 793, info-first path
********************************************************************************

	replace				family_pref = .
	replace				family_pref = d1_pref_lemon_family if day == 1

	reg					d1_dwtp_3a_793 ///
							family_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1fam_cmp_d1_3a_793


********************************************************************************
**## Day 2 family model - 356, taste-first path
********************************************************************************

	replace				family_pref = .
	replace				family_pref = d2_pref_blueberry_family if day == 2

	reg					d2_dwtp_3b_356 ///
							family_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1fam_cmp_d2_3b_356


********************************************************************************
**## Day 2 family model - 831, taste-first path
********************************************************************************

	replace				family_pref = .
	replace				family_pref = d2_pref_pineapple_family if day == 2

	reg					d2_dwtp_3b_831 ///
							family_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1fam_cmp_d2_3b_831


********************************************************************************
**## Day 2 family model - 356, info-first path
********************************************************************************

	replace				family_pref = .
	replace				family_pref = d2_pref_blueberry_family if day == 2

	reg					d2_dwtp_3a_356 ///
							family_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1fam_cmp_d2_3a_356


********************************************************************************
**## Day 2 family model - 831, info-first path
********************************************************************************

	replace				family_pref = .
	replace				family_pref = d2_pref_pineapple_family if day == 2

	reg					d2_dwtp_3a_831 ///
							family_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1fam_cmp_d2_3a_831
	
	
********************************************************************************
**## Export H1 flavor-family comparison table
********************************************************************************

	esttab				h1fam_cmp_d1_3b_584 ///
						h1fam_cmp_d1_3b_793 ///
						h1fam_cmp_d1_3a_584 ///
						h1fam_cmp_d1_3a_793 ///
						h1fam_cmp_d2_3b_356 ///
						h1fam_cmp_d2_3b_831 ///
						h1fam_cmp_d2_3a_356 ///
						h1fam_cmp_d2_3a_831 ///
							using "$reg_tables/h1fam_comparison_all_models.csv", ///
							replace csv label ///
							mtitles("D1 584 3b" ///
									"D1 793 3b" ///
									"D1 584 3a" ///
									"D1 793 3a" ///
									"D2 356 3b" ///
									"D2 831 3b" ///
									"D2 356 3a" ///
									"D2 831 3a") ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							order(family_pref ///
									flavor_low ///
									sweet_high ///
									sugar_high ///
									ingred_high ///
									health_high ///
									magn_know_high ///
									_cons) ///
							coeflabels(family_pref ///
										"Flavor-family preferred flavor" ///
										flavor_low ///
										"Flavor importance is moderate rather than very/extremely important" ///
										sweet_high ///
										"Sweetness is very or extremely important" ///
										sugar_high ///
										"Sugar level is very or extremely important" ///
										ingred_high ///
										"Functional ingredients are very or extremely important" ///
										health_high ///
										"Health claims are very or extremely important" ///
										magn_know_high ///
										"Prior magnesium knowledge is agree or strongly agree" ///
										_cons ///
										"Constant") ///
							noobs nonumber

	dir					"$reg_tables\h1fam_comparison_all_models.csv"
	
	
********************************************************************************
**# Hypothesis 2
********************************************************************************

***Hyp 2:
/* NULL HYPOTHESIS
Our null hypothesis is that males and females respond the same way and magnesium 
does not increase willingness to pay beyond flavor and sweetness. ly depending on gender and activity level.

ALT HYPOTHESIS
The alternative hypothesis is that magnesium increases willingness to pay more 
for females than males, or for participants who exercise more, showing that 
functional benefits like magnesium can influence choices different
*/

********************************************************************************
**## H2 respondent characteristics
********************************************************************************

* respondent id for clustered standard errors in pooled long models
	capture drop		resp_id
	gen long			resp_id = _n

	label var			resp_id ///
							"Respondent identifier"


* female respondent indicator
	capture drop		female
	gen					female = gender == 2 ///
							if inlist(gender, 1, 2)

	label define		female_lbl ///
							0 "Male" ///
							1 "Female", replace

	label values		female female_lbl

	label var			female ///
							"Female respondent"

	tab					female, missing


********************************************************************************
**## Check existing exercise split
********************************************************************************

* exercise_hi should already exist from the earlier exercise block
	tab					exercise, missing
	tab					exercise_hi, missing
	tab					female exercise_hi, missing
	
********************************************************************************
**## H2 Day 1 magnesium premium outcomes
********************************************************************************

* Taste-first final WTP premium for 584 over 793
	capture drop		d1_mag_premium_3b
	gen					d1_mag_premium_3b = wtp_3b_info_584 - wtp_3b_info_793 ///
							if day == 1 & !missing(wtp_3b_info_584, wtp_3b_info_793)

	label var			d1_mag_premium_3b ///
							"Day 1: Final WTP premium for 584 over 793, taste-first"


* Info-first final WTP premium for 584 over 793
	capture drop		d1_mag_premium_3a
	gen					d1_mag_premium_3a = wtp_3a_584 - wtp_3a_793 ///
							if day == 1 & !missing(wtp_3a_584, wtp_3a_793)

	label var			d1_mag_premium_3a ///
							"Day 1: Final WTP premium for 584 over 793, info-first"


********************************************************************************
**## Check H2 Day 1 magnesium premium outcomes
********************************************************************************

	sum					d1_mag_premium_3b d1_mag_premium_3a, detail

	tab					day if !missing(d1_mag_premium_3b), missing
	tab					day if !missing(d1_mag_premium_3a), missing
	
********************************************************************************
**## Build H2 pooled long dataset
********************************************************************************

	tempfile			h2_long
	local first			1

	foreach spec in ///
		`"1 584 1 d1_dwtp_3b_584 d1_pref_lemon"' ///
		`"1 584 2 d1_dwtp_3a_584 d1_pref_lemon"' ///
		`"2 356 1 d2_dwtp_3b_356 d2_pref_blueberry"' ///
		`"2 356 2 d2_dwtp_3a_356 d2_pref_blueberry"' ///
		`"2 831 1 d2_dwtp_3b_831 d2_pref_pineapple"' ///
		`"2 831 2 d2_dwtp_3a_831 d2_pref_pineapple"' {

		tokenize		`"`spec'"'

		local h2_day		`1'
		local h2_prod		`2'
		local h2_pathnum	`3'
		local h2_y			`4'
		local h2_pref		`5'

		preserve

			keep		if day == `h2_day'

			capture drop	h2_dwtp
			capture drop	h2_product
			capture drop	h2_path
			capture drop	h2_product_pref

			gen			h2_dwtp = `h2_y'
			gen			h2_product = `h2_prod'
			gen			h2_path = `h2_pathnum'
			gen			h2_product_pref = `h2_pref'

			label var	h2_dwtp ///
							"Final WTP change from baseline"

			label var	h2_product ///
							"Product"

			label var	h2_path ///
							"Path"

			label var	h2_product_pref ///
							"Product-specific preferred flavor"

			keep		resp_id h2_dwtp h2_product h2_path h2_product_pref ///
						female exercise_hi ///
						flavor_low sweet_high sugar_high ///
						ingred_high health_high magn_know_high

			keep		if !missing(h2_dwtp, female, exercise_hi)

			if `first' == 1 {
				save	`h2_long', replace
				local	first 0
			}
			else {
				append	using `h2_long'
				save	`h2_long', replace
			}

		restore
	}
	
********************************************************************************
**## Check H2 pooled long dataset
********************************************************************************

	preserve

		use				`h2_long', clear

		label define	h2_product_lbl ///
							356 "356" ///
							584 "584" ///
							831 "831", replace

		label define	h2_path_lbl ///
							1 "Taste-first" ///
							2 "Info-first", replace

		label values	h2_product h2_product_lbl
		label values	h2_path h2_path_lbl
		label values	h2_product_pref yesno_lbl
		label values	female female_lbl
		label values	exercise_hi exercise_hi_lbl

		tab				h2_product, missing
		tab				h2_path, missing
		tab				h2_product h2_path, missing

		tab				female exercise_hi, missing

		sum				h2_dwtp, detail

		save			"$data/h2_long.dta", replace

	restore
	
********************************************************************************
**## H2 regressions - clean factor-variable setup
********************************************************************************

	estimates clear


********************************************************************************
**### H2 pooled models
********************************************************************************

	preserve

		use					"$data/h2_long.dta", clear


********************************************************************************
**#### Pooled additive model
********************************************************************************

		reg					h2_dwtp ///
								i.female ///
								i.exercise_hi ///
								h2_product_pref ///
								flavor_low ///
								sweet_high ///
								sugar_high ///
								ingred_high ///
								health_high ///
								magn_know_high ///
								i.h2_product ///
								i.h2_path, ///
								vce(cluster resp_id)

		estimates store		h2_pool_add_clean


********************************************************************************
**#### Pooled interaction model
********************************************************************************

		reg					h2_dwtp ///
								i.female##i.exercise_hi ///
								h2_product_pref ///
								flavor_low ///
								sweet_high ///
								sugar_high ///
								ingred_high ///
								health_high ///
								magn_know_high ///
								i.h2_product ///
								i.h2_path, ///
								vce(cluster resp_id)

		estimates store		h2_pool_int_clean

	restore


********************************************************************************
**### H2 Day 1 premium models
********************************************************************************

********************************************************************************
**#### Day 1 premium - taste-first additive
********************************************************************************

	reg						d1_mag_premium_3b ///
								i.female ///
								i.exercise_hi ///
								d1_pref_lemon ///
								flavor_low ///
								sweet_high ///
								sugar_high ///
								ingred_high ///
								health_high ///
								magn_know_high, robust

	estimates store			h2_prem_3b_add_clean


********************************************************************************
**#### Day 1 premium - info-first additive
********************************************************************************

	reg						d1_mag_premium_3a ///
								i.female ///
								i.exercise_hi ///
								d1_pref_lemon ///
								flavor_low ///
								sweet_high ///
								sugar_high ///
								ingred_high ///
								health_high ///
								magn_know_high, robust

	estimates store			h2_prem_3a_add_clean


********************************************************************************
**#### Day 1 premium - taste-first interaction
********************************************************************************

	reg						d1_mag_premium_3b ///
								i.female##i.exercise_hi ///
								d1_pref_lemon ///
								flavor_low ///
								sweet_high ///
								sugar_high ///
								ingred_high ///
								health_high ///
								magn_know_high, robust

	estimates store			h2_prem_3b_int_clean


********************************************************************************
**#### Day 1 premium - info-first interaction
********************************************************************************

	reg						d1_mag_premium_3a ///
								i.female##i.exercise_hi ///
								d1_pref_lemon ///
								flavor_low ///
								sweet_high ///
								sugar_high ///
								ingred_high ///
								health_high ///
								magn_know_high, robust

	estimates store			h2_prem_3a_int_clean


********************************************************************************
**## Export clean H2 comparison table
********************************************************************************

	esttab					h2_pool_add_clean ///
							h2_pool_int_clean ///
							h2_prem_3b_add_clean ///
							h2_prem_3a_add_clean ///
							h2_prem_3b_int_clean ///
							h2_prem_3a_int_clean ///
								using "$reg_tables/h2_comparison_all_models_clean.csv", ///
								replace csv label ///
								mtitles("Pooled Add." ///
										"Pooled Int." ///
										"D1 3b Premium Add." ///
										"D1 3a Premium Add." ///
										"D1 3b Premium Int." ///
										"D1 3a Premium Int.") ///
								cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
								stats(N r2, ///
									labels("Observations" "R-squared") ///
									fmt(0 3)) ///
								keep(1.female ///
									 1.exercise_hi ///
									 1.female#1.exercise_hi ///
									 h2_product_pref ///
									 d1_pref_lemon ///
									 flavor_low ///
									 sweet_high ///
									 sugar_high ///
									 ingred_high ///
									 health_high ///
									 magn_know_high ///
									 584.h2_product ///
									 831.h2_product ///
									 2.h2_path ///
									 _cons) ///
								order(1.female ///
									  1.exercise_hi ///
									  1.female#1.exercise_hi ///
									  h2_product_pref ///
									  d1_pref_lemon ///
									  flavor_low ///
									  sweet_high ///
									  sugar_high ///
									  ingred_high ///
									  health_high ///
									  magn_know_high ///
									  584.h2_product ///
									  831.h2_product ///
									  2.h2_path ///
									  _cons) ///
								coeflabels(1.female ///
											"Female respondent" ///
											1.exercise_hi ///
											"High exercise" ///
											1.female#1.exercise_hi ///
											"Female x High exercise" ///
											h2_product_pref ///
											"Product-specific preferred flavor" ///
											d1_pref_lemon ///
											"Day 1: Selected Lemon-Lime as preferred flavor" ///
											flavor_low ///
											"Flavor importance is moderate rather than very/extremely important" ///
											sweet_high ///
											"Sweetness is very or extremely important" ///
											sugar_high ///
											"Sugar level is very or extremely important" ///
											ingred_high ///
											"Functional ingredients are very or extremely important" ///
											health_high ///
											"Health claims are very or extremely important" ///
											magn_know_high ///
											"Prior magnesium knowledge is agree or strongly agree" ///
											584.h2_product ///
											"Product 584" ///
											831.h2_product ///
											"Product 831" ///
											2.h2_path ///
											"Info-first path" ///
											_cons ///
											"Constant") ///
								nobaselevels noomitted ///
								noobs nonumber

	dir						"$reg_tables\h2_comparison_all_models_clean.csv"
	
********************************************************************************
**## H2 Day 2 product premium outcomes
********************************************************************************

* Taste-first final WTP premium for 356 over 831
	capture drop		d2_product_premium_3b
	gen					d2_product_premium_3b = wtp_3b_info_356 - wtp_3b_info_831 ///
							if day == 2 & !missing(wtp_3b_info_356, wtp_3b_info_831)

	label var			d2_product_premium_3b ///
							"Day 2: Final WTP premium for 356 over 831, taste-first"


* Info-first final WTP premium for 356 over 831
	capture drop		d2_product_premium_3a
	gen					d2_product_premium_3a = wtp_3a_356 - wtp_3a_831 ///
							if day == 2 & !missing(wtp_3a_356, wtp_3a_831)

	label var			d2_product_premium_3a ///
							"Day 2: Final WTP premium for 356 over 831, info-first"


********************************************************************************
**## Check H2 Day 2 product premium outcomes
********************************************************************************

	sum					d2_product_premium_3b d2_product_premium_3a, detail

	tab					day if !missing(d2_product_premium_3b), missing
	tab					day if !missing(d2_product_premium_3a), missing
	
********************************************************************************
**## H2 Day 2 product premium regressions
********************************************************************************

********************************************************************************
**## Set H2 Day 2 product premium explanatory variables
********************************************************************************

	local h2_d2premium_x		i.female ///
							i.exercise_hi ///
							d2_pref_blueberry ///
							d2_pref_pineapple ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high


********************************************************************************
**### Day 2 product premium - taste-first additive
********************************************************************************

	reg						d2_product_premium_3b ///
								`h2_d2premium_x', robust

	estimates store			h2_d2prem_3b_add


********************************************************************************
**### Day 2 product premium - info-first additive
********************************************************************************

	reg						d2_product_premium_3a ///
								`h2_d2premium_x', robust

	estimates store			h2_d2prem_3a_add


********************************************************************************
**### Day 2 product premium - taste-first interaction
********************************************************************************

	reg						d2_product_premium_3b ///
								i.female##i.exercise_hi ///
								d2_pref_blueberry ///
								d2_pref_pineapple ///
								flavor_low ///
								sweet_high ///
								sugar_high ///
								ingred_high ///
								health_high ///
								magn_know_high, robust

	estimates store			h2_d2prem_3b_int


********************************************************************************
**### Day 2 product premium - info-first interaction
********************************************************************************

	reg						d2_product_premium_3a ///
								i.female##i.exercise_hi ///
								d2_pref_blueberry ///
								d2_pref_pineapple ///
								flavor_low ///
								sweet_high ///
								sugar_high ///
								ingred_high ///
								health_high ///
								magn_know_high, robust

	estimates store			h2_d2prem_3a_int


********************************************************************************
**## Export H2 Day 2 product premium comparison table
********************************************************************************

	esttab					h2_d2prem_3b_add ///
							h2_d2prem_3a_add ///
							h2_d2prem_3b_int ///
							h2_d2prem_3a_int ///
								using "$reg_tables/h2_day2_product_premium.csv", ///
								replace csv label ///
								mtitles("D2 3b Premium Add." ///
										"D2 3a Premium Add." ///
										"D2 3b Premium Int." ///
										"D2 3a Premium Int.") ///
								cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
								stats(N r2, ///
									labels("Observations" "R-squared") ///
									fmt(0 3)) ///
								keep(1.female ///
									 1.exercise_hi ///
									 1.female#1.exercise_hi ///
									 d2_pref_blueberry ///
									 d2_pref_pineapple ///
									 flavor_low ///
									 sweet_high ///
									 sugar_high ///
									 ingred_high ///
									 health_high ///
									 magn_know_high ///
									 _cons) ///
								order(1.female ///
									  1.exercise_hi ///
									  1.female#1.exercise_hi ///
									  d2_pref_blueberry ///
									  d2_pref_pineapple ///
									  flavor_low ///
									  sweet_high ///
									  sugar_high ///
									  ingred_high ///
									  health_high ///
									  magn_know_high ///
									  _cons) ///
								coeflabels(1.female ///
											"Female respondent" ///
											1.exercise_hi ///
											"High exercise" ///
											1.female#1.exercise_hi ///
											"Female x High exercise" ///
											d2_pref_blueberry ///
											"Day 2: Selected Blueberry as preferred flavor" ///
											d2_pref_pineapple ///
											"Day 2: Selected Pineapple as preferred flavor" ///
											flavor_low ///
											"Flavor importance is moderate rather than very/extremely important" ///
											sweet_high ///
											"Sweetness is very or extremely important" ///
											sugar_high ///
											"Sugar level is very or extremely important" ///
											ingred_high ///
											"Functional ingredients are very or extremely important" ///
											health_high ///
											"Health claims are very or extremely important" ///
											magn_know_high ///
											"Prior magnesium knowledge is agree or strongly agree" ///
											_cons ///
											"Constant") ///
								nobaselevels noomitted ///
								noobs nonumber

	dir						"$reg_tables\h2_day2_product_premium.csv"
	
	
********************************************************************************
**## Build H2 pooled long dataset with consumption situation
********************************************************************************

	tempfile			h2_long_context
	local first			1

	foreach spec in ///
		`"1 584 1 d1_dwtp_3b_584 d1_pref_lemon"' ///
		`"1 584 2 d1_dwtp_3a_584 d1_pref_lemon"' ///
		`"2 356 1 d2_dwtp_3b_356 d2_pref_blueberry"' ///
		`"2 356 2 d2_dwtp_3a_356 d2_pref_blueberry"' ///
		`"2 831 1 d2_dwtp_3b_831 d2_pref_pineapple"' ///
		`"2 831 2 d2_dwtp_3a_831 d2_pref_pineapple"' {

		tokenize		`"`spec'"'

		local h2_day		`1'
		local h2_prod		`2'
		local h2_pathnum	`3'
		local h2_y			`4'
		local h2_pref		`5'

		preserve

			keep		if day == `h2_day'

			capture drop	h2_dwtp
			capture drop	h2_product
			capture drop	h2_path
			capture drop	h2_product_pref

			gen			h2_dwtp = `h2_y'
			gen			h2_product = `h2_prod'
			gen			h2_path = `h2_pathnum'
			gen			h2_product_pref = `h2_pref'

			label var	h2_dwtp ///
							"Final WTP change from baseline"

			label var	h2_product ///
							"Product"

			label var	h2_path ///
							"Path"

			label var	h2_product_pref ///
							"Product-specific preferred flavor"

			keep		resp_id h2_dwtp h2_product h2_path h2_product_pref ///
						female exercise_hi ///
						con_situation_1 con_situation_2 con_situation_3 ///
						flavor_low sweet_high sugar_high ///
						ingred_high health_high magn_know_high

			keep		if !missing(h2_dwtp, female, exercise_hi)

			if `first' == 1 {
				save	`h2_long_context', replace
				local	first 0
			}
			else {
				append	using `h2_long_context'
				save	`h2_long_context', replace
			}

		restore
	}


********************************************************************************
**## Check H2 pooled long dataset with consumption situation
********************************************************************************

	preserve

		use				`h2_long_context', clear

		label define	h2_product_lbl ///
							356 "356" ///
							584 "584" ///
							831 "831", replace

		label define	h2_path_lbl ///
							1 "Taste-first" ///
							2 "Info-first", replace

		label values	h2_product h2_product_lbl
		label values	h2_path h2_path_lbl
		label values	h2_product_pref yesno_lbl
		label values	female female_lbl
		label values	exercise_hi exercise_hi_lbl

		tab				h2_product, missing
		tab				h2_path, missing
		tab				h2_product h2_path, missing

		tab				con_situation_1, missing
		tab				con_situation_2, missing
		tab				con_situation_3, missing

		tab				female exercise_hi, missing

		sum				h2_dwtp, detail

		save			"$data/h2_long_context.dta", replace

	restore
	
********************************************************************************
**## H2 pooled regressions with consumption situation controls
********************************************************************************

	estimates clear

	preserve

		use					"$data/h2_long_context.dta", clear


********************************************************************************
**### H2 pooled context model - additive
********************************************************************************

		reg					h2_dwtp ///
								i.female ///
								i.exercise_hi ///
								con_situation_1 ///
								con_situation_2 ///
								con_situation_3 ///
								h2_product_pref ///
								flavor_low ///
								sweet_high ///
								sugar_high ///
								ingred_high ///
								health_high ///
								magn_know_high ///
								i.h2_product ///
								i.h2_path, ///
								vce(cluster resp_id)

		estimates store		h2_context_add


********************************************************************************
**### H2 pooled context model - female by exercise interaction
********************************************************************************

		reg					h2_dwtp ///
								i.female##i.exercise_hi ///
								con_situation_1 ///
								con_situation_2 ///
								con_situation_3 ///
								h2_product_pref ///
								flavor_low ///
								sweet_high ///
								sugar_high ///
								ingred_high ///
								health_high ///
								magn_know_high ///
								i.h2_product ///
								i.h2_path, ///
								vce(cluster resp_id)

		estimates store		h2_context_int


********************************************************************************
**## Export H2 context comparison table
********************************************************************************

		esttab				h2_context_add ///
							h2_context_int ///
								using "$reg_tables/h2_context_comparison.csv", ///
								replace csv label ///
								mtitles("Context Add." ///
										"Context Int.") ///
								cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
								stats(N r2, ///
									labels("Observations" "R-squared") ///
									fmt(0 3)) ///
								keep(1.female ///
									 1.exercise_hi ///
									 1.female#1.exercise_hi ///
									 con_situation_1 ///
									 con_situation_2 ///
									 con_situation_3 ///
									 h2_product_pref ///
									 flavor_low ///
									 sweet_high ///
									 sugar_high ///
									 ingred_high ///
									 health_high ///
									 magn_know_high ///
									 584.h2_product ///
									 831.h2_product ///
									 2.h2_path ///
									 _cons) ///
								order(1.female ///
									  1.exercise_hi ///
									  1.female#1.exercise_hi ///
									  con_situation_1 ///
									  con_situation_2 ///
									  con_situation_3 ///
									  h2_product_pref ///
									  flavor_low ///
									  sweet_high ///
									  sugar_high ///
									  ingred_high ///
									  health_high ///
									  magn_know_high ///
									  584.h2_product ///
									  831.h2_product ///
									  2.h2_path ///
									  _cons) ///
								coeflabels(1.female ///
											"Female respondent" ///
											1.exercise_hi ///
											"High exercise" ///
											1.female#1.exercise_hi ///
											"Female x High exercise" ///
											con_situation_1 ///
											"Consumes before exercise" ///
											con_situation_2 ///
											"Consumes during exercise" ///
											con_situation_3 ///
											"Consumes after exercise" ///
											h2_product_pref ///
											"Product-specific preferred flavor" ///
											flavor_low ///
											"Flavor importance is moderate rather than very/extremely important" ///
											sweet_high ///
											"Sweetness is very or extremely important" ///
											sugar_high ///
											"Sugar level is very or extremely important" ///
											ingred_high ///
											"Functional ingredients are very or extremely important" ///
											health_high ///
											"Health claims are very or extremely important" ///
											magn_know_high ///
											"Prior magnesium knowledge is agree or strongly agree" ///
											584.h2_product ///
											"Product 584" ///
											831.h2_product ///
											"Product 831" ///
											2.h2_path ///
											"Info-first path" ///
											_cons ///
											"Constant") ///
								nobaselevels noomitted ///
								noobs nonumber

		dir					"$reg_tables\h2_context_comparison.csv"

	restore
	
********************************************************************************
**# regression checks
********************************************************************************

* I'm going to run some checks on the regressions* I'm a little worried that
* there may be too many explanatory vars after looking at how little* stat signif
* there is in these regressions. This may be the case but I think it's worht
* running some checks.


********************************************************************************
**## check 1 - dependent variables are restricted to the correct day
********************************************************************************

* Day 1 outcomes should only exist for Day 1
	foreach y in ///
		d1_dwtp_3b_584 ///
		d1_dwtp_3b_793 ///
		d1_dwtp_3a_584 ///
		d1_dwtp_3a_793 ///
		d1_mag_premium_3b ///
		d1_mag_premium_3a {

		count			if day != 1 & !missing(`y')
		display			"`y' nonmissing outside Day 1 = " r(N)

		tab				day if !missing(`y'), missing
	}


* Day 2 outcomes should only exist for Day 2
	foreach y in ///
		d2_dwtp_3b_356 ///
		d2_dwtp_3b_831 ///
		d2_dwtp_3a_356 ///
		d2_dwtp_3a_831 ///
		d2_product_premium_3b ///
		d2_product_premium_3a {

		count			if day != 2 & !missing(`y')
		display			"`y' nonmissing outside Day 2 = " r(N)

		tab				day if !missing(`y'), missing
	}

* Audit result: Yes. The dependent variables are restricted to the correct day.


********************************************************************************
**## check 2 - dependent-variable sample sizes match the correct path
********************************************************************************

* Summarize Day 1 final WTP-change outcomes
	sum					d1_dwtp_3b_584 ///
						d1_dwtp_3b_793 ///
						d1_dwtp_3a_584 ///
						d1_dwtp_3a_793

* Summarize Day 2 final WTP-change outcomes
	sum					d2_dwtp_3b_356 ///
						d2_dwtp_3b_831 ///
						d2_dwtp_3a_356 ///
						d2_dwtp_3a_831

* Count Day 1 path-specific observations
	count				if !missing(d1_dwtp_3b_584)
	count				if !missing(d1_dwtp_3a_584)

* Count Day 2 path-specific observations
	count				if !missing(d2_dwtp_3b_356)
	count				if !missing(d2_dwtp_3a_356)

* Audit result: Yes. The sample sizes are restricted to their paths.


********************************************************************************
**## check 3 - product-specific flavor variables are restricted to the correct day
********************************************************************************

* Day 1 Lemon-Lime preference should only be defined for Day 1
	tab					d1_pref_lemon if day == 1, missing
	tab					d1_pref_lemon if day == 2, missing

* Day 2 Blueberry preference should only be defined for Day 2
	tab					d2_pref_blueberry if day == 1, missing
	tab					d2_pref_blueberry if day == 2, missing

* Day 2 Pineapple preference should only be defined for Day 2
	tab					d2_pref_pineapple if day == 1, missing
	tab					d2_pref_pineapple if day == 2, missing

* Audit result: Yes. Product-specific flavor variables are restricted correctly.


********************************************************************************
**## check 4 - flavor importance category matches final table coding
********************************************************************************

* Keep flavor_low consistent with the final regression tables.
* This identifies respondents who rated flavor as moderately important.
	capture drop		flavor_low

	gen					flavor_low = pref_flavor == 3 ///
							if !missing(pref_flavor)

	label var			flavor_low ///
							"Flavor importance is moderate versus other reported levels"

	label values		flavor_low flavor_low_lbl

	tab					pref_flavor flavor_low, missing
	tab					flavor_low, missing


********************************************************************************
**## check 5 - full model sample sizes are correct
********************************************************************************

********************************************************************************
**### H1 Day 1 full model sample sizes
********************************************************************************

	foreach y in ///
		d1_dwtp_3b_584 ///
		d1_dwtp_3b_793 ///
		d1_dwtp_3a_584 ///
		d1_dwtp_3a_793 {

		reg				`y' ///
							d1_pref_lemon ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

		display			"`y' full model N = " e(N)
	}


********************************************************************************
**### H1 Day 2 full model sample sizes - 356
********************************************************************************

	foreach y in ///
		d2_dwtp_3b_356 ///
		d2_dwtp_3a_356 {

		reg				`y' ///
							d2_pref_blueberry ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

		display			"`y' full model N = " e(N)
	}


********************************************************************************
**### H1 Day 2 full model sample sizes - 831
********************************************************************************

	foreach y in ///
		d2_dwtp_3b_831 ///
		d2_dwtp_3a_831 {

		reg				`y' ///
							d2_pref_pineapple ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

		display			"`y' full model N = " e(N)
	}

* Audit result: Yes. Full model sample sizes are consistent with path availability.


********************************************************************************
**## check 6 - H2 pooled models are not driven by over-control
********************************************************************************

	estimates clear

	preserve

		use				"$data/h2_long.dta", clear


********************************************************************************
**### H2 pooled audit - simple model
********************************************************************************

* Simple model: gender, exercise, gender-by-exercise, product, and path
	reg					h2_dwtp ///
							i.female##i.exercise_hi ///
							i.h2_product ///
							i.h2_path, ///
							vce(cluster resp_id)

	estimates store		h2_audit_simple


********************************************************************************
**### H2 pooled audit - core model
********************************************************************************

* Core model: simple model plus product-specific flavor, flavor importance, and sweetness
	reg					h2_dwtp ///
							i.female##i.exercise_hi ///
							h2_product_pref ///
							flavor_low ///
							sweet_high ///
							i.h2_product ///
							i.h2_path, ///
							vce(cluster resp_id)

	estimates store		h2_audit_core


********************************************************************************
**### H2 pooled audit - full model
********************************************************************************

* Full model: core model plus sugar, functional ingredients, health claims, and magnesium knowledge
	reg					h2_dwtp ///
							i.female##i.exercise_hi ///
							h2_product_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high ///
							i.h2_product ///
							i.h2_path, ///
							vce(cluster resp_id)

	estimates store		h2_audit_full

	restore


********************************************************************************
**### export H2 specification audit table
********************************************************************************

	esttab				h2_audit_simple ///
						h2_audit_core ///
						h2_audit_full ///
							using "$reg_tables/h2_specification_audit.csv", ///
							replace csv label ///
							mtitles("Simple" ///
									"Core" ///
									"Full") ///
							cells("b(fmt(3)) se(fmt(3)) p(fmt(3))") ///
							stats(N r2, ///
								labels("Observations" "R-squared") ///
								fmt(0 3)) ///
							nobaselevels noomitted ///
							noobs nonumber

* Audit result: H2 gender and exercise results are stable across simple, core, and full specifications.


********************************************************************************
**## check 7 - H1 models are not driven by over-control
********************************************************************************

	estimates clear

********************************************************************************
**### Day 1 - 584, taste-first
********************************************************************************

	reg					d1_dwtp_3b_584 ///
							d1_pref_lemon, robust

	estimates store		h1audit_d1_3b_584_simple


	reg					d1_dwtp_3b_584 ///
							d1_pref_lemon ///
							flavor_low ///
							sweet_high, robust

	estimates store		h1audit_d1_3b_584_core


	reg					d1_dwtp_3b_584 ///
							d1_pref_lemon ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1audit_d1_3b_584_full


********************************************************************************
**### Day 1 - 793, taste-first
********************************************************************************

	reg					d1_dwtp_3b_793 ///
							d1_pref_lemon, robust

	estimates store		h1audit_d1_3b_793_simple


	reg					d1_dwtp_3b_793 ///
							d1_pref_lemon ///
							flavor_low ///
							sweet_high, robust

	estimates store		h1audit_d1_3b_793_core


	reg					d1_dwtp_3b_793 ///
							d1_pref_lemon ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1audit_d1_3b_793_full


********************************************************************************
**### Day 1 - 584, info-first
********************************************************************************

	reg					d1_dwtp_3a_584 ///
							d1_pref_lemon, robust

	estimates store		h1audit_d1_3a_584_simple


	reg					d1_dwtp_3a_584 ///
							d1_pref_lemon ///
							flavor_low ///
							sweet_high, robust

	estimates store		h1audit_d1_3a_584_core


	reg					d1_dwtp_3a_584 ///
							d1_pref_lemon ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1audit_d1_3a_584_full


********************************************************************************
**### Day 1 - 793, info-first
********************************************************************************

	reg					d1_dwtp_3a_793 ///
							d1_pref_lemon, robust

	estimates store		h1audit_d1_3a_793_simple


	reg					d1_dwtp_3a_793 ///
							d1_pref_lemon ///
							flavor_low ///
							sweet_high, robust

	estimates store		h1audit_d1_3a_793_core


	reg					d1_dwtp_3a_793 ///
							d1_pref_lemon ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1audit_d1_3a_793_full


********************************************************************************
**### Day 2 - 356, taste-first
********************************************************************************

	reg					d2_dwtp_3b_356 ///
							d2_pref_blueberry, robust

	estimates store		h1audit_d2_3b_356_simple


	reg					d2_dwtp_3b_356 ///
							d2_pref_blueberry ///
							flavor_low ///
							sweet_high, robust

	estimates store		h1audit_d2_3b_356_core


	reg					d2_dwtp_3b_356 ///
							d2_pref_blueberry ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1audit_d2_3b_356_full


********************************************************************************
**### Day 2 - 831, taste-first
********************************************************************************

	reg					d2_dwtp_3b_831 ///
							d2_pref_pineapple, robust

	estimates store		h1audit_d2_3b_831_simple


	reg					d2_dwtp_3b_831 ///
							d2_pref_pineapple ///
							flavor_low ///
							sweet_high, robust

	estimates store		h1audit_d2_3b_831_core


	reg					d2_dwtp_3b_831 ///
							d2_pref_pineapple ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1audit_d2_3b_831_full


********************************************************************************
**### Day 2 - 356, info-first
********************************************************************************

	reg					d2_dwtp_3a_356 ///
							d2_pref_blueberry, robust

	estimates store		h1audit_d2_3a_356_simple


	reg					d2_dwtp_3a_356 ///
							d2_pref_blueberry ///
							flavor_low ///
							sweet_high, robust

	estimates store		h1audit_d2_3a_356_core


	reg					d2_dwtp_3a_356 ///
							d2_pref_blueberry ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1audit_d2_3a_356_full


********************************************************************************
**### Day 2 - 831, info-first
********************************************************************************

	reg					d2_dwtp_3a_831 ///
							d2_pref_pineapple, robust

	estimates store		h1audit_d2_3a_831_simple


	reg					d2_dwtp_3a_831 ///
							d2_pref_pineapple ///
							flavor_low ///
							sweet_high, robust

	estimates store		h1audit_d2_3a_831_core


	reg					d2_dwtp_3a_831 ///
							d2_pref_pineapple ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

	estimates store		h1audit_d2_3a_831_full
	
	
********************************************************************************
**# Graphs - Hyp 1
********************************************************************************

********************************************************************************
**# H1 graph 1 - product-specific flavor preference coefficients
********************************************************************************

* This graph shows the coefficient on the product-specific preferred flavor variable
* across all eight H1 product/path models.
*
* The graph answers:
* Does preferring the product's matching flavor predict final WTP change?

* Day 1 product-specific flavor variable:
*		d1_pref_lemon

* Day 2 product-specific flavor variables:
*		d2_pref_blueberry
*		d2_pref_pineapple

*  H1 controls:
*		flavor_low
*		sweet_high
*		sugar_high
*		ingred_high
*		health_high
*		magn_know_high


********************************************************************************
**## Build graphing dataset
********************************************************************************

preserve

	tempfile			h1_flavor_coef
	tempname			memhold

	postfile			`memhold' ///
							str30 model ///
							str60 model_label ///
							int plot_order ///
							double b se p ci_lo ci_hi ///
							using `h1_flavor_coef', replace


********************************************************************************
**## Run full H1 models and store product-specific flavor coefficients
********************************************************************************

* Each line below identifies:
*		1. dependent variable
*		2. product-specific flavor preference variable
*		3. graph order
*		4. graph label

	foreach spec in ///
		`"d1_dwtp_3b_584 d1_pref_lemon     8 "D1 584 3b: Taste-first""' ///
		`"d1_dwtp_3b_793 d1_pref_lemon     7 "D1 793 3b: Taste-first""' ///
		`"d1_dwtp_3a_584 d1_pref_lemon     6 "D1 584 3a: Info-first""' ///
		`"d1_dwtp_3a_793 d1_pref_lemon     5 "D1 793 3a: Info-first""' ///
		`"d2_dwtp_3b_356 d2_pref_blueberry 4 "D2 356 3b: Taste-first""' ///
		`"d2_dwtp_3b_831 d2_pref_pineapple 3 "D2 831 3b: Taste-first""' ///
		`"d2_dwtp_3a_356 d2_pref_blueberry 2 "D2 356 3a: Info-first""' ///
		`"d2_dwtp_3a_831 d2_pref_pineapple 1 "D2 831 3a: Info-first""' {

		tokenize		`"`spec'"'

		local y			"`1'"
		local pref		"`2'"
		local order		"`3'"
		local label		`"`4'"'


		********************************************************************************
**### Run full H1 model
		********************************************************************************

		reg				`y' ///
							`pref' ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust


		********************************************************************************
**### Store coefficient, standard error, p-value, and 95 percent confidence interval
		********************************************************************************

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							(`order') ///
							(_b[`pref']) ///
							(_se[`pref']) ///
							(2 * ttail(e(df_r), abs(_b[`pref'] / _se[`pref']))) ///
							(_b[`pref'] - invttail(e(df_r), .025) * _se[`pref']) ///
							(_b[`pref'] + invttail(e(df_r), .025) * _se[`pref'])
	}


********************************************************************************
**## Save graphing dataset
********************************************************************************

	postclose			`memhold'

	use					`h1_flavor_coef', clear

	sort				plot_order

	list				model_label b se p ci_lo ci_hi, clean noobs

	export delimited	using "$reg_tables/h1_graph_1_product_flavor_coefficients_data.csv", ///
							replace


********************************************************************************
**## Create coefficient plot
********************************************************************************

	graph twoway ///
		(rcap ci_hi ci_lo plot_order, horizontal) ///
		(scatter plot_order b), ///
		xline(0, lpattern(dash)) ///
		ylabel(1 "D2 831 3a" ///
			   2 "D2 356 3a" ///
			   3 "D2 831 3b" ///
			   4 "D2 356 3b" ///
			   5 "D1 793 3a" ///
			   6 "D1 584 3a" ///
			   7 "D1 793 3b" ///
			   8 "D1 584 3b", ///
			   angle(0) labsize(small) noticks) ///
		xlabel(, labsize(small)) ///
		xtitle("Coefficient on product-specific preferred flavor", ///
			   size(small) margin(medsmall)) ///
		ytitle("") ///
		title("H1: Product-specific flavor preference and WTP change", ///
			  size(medsmall) span justification(center)) ///
		subtitle("Full H1 models with 95% confidence intervals", ///
				 size(small) span justification(center)) ///
		note("Model key: D1/D2 = survey day; 3a = info-first; 3b = taste-first.", ///
			 size(vsmall) span justification(center)) ///
		legend(off) ///
		graphregion(margin(l+30 r+20 t+10 b+10)) ///
		plotregion(margin(l+2 r+4 t+2 b+2)) ///
		xsize(14) ///
		ysize(6)


********************************************************************************
**## Export coefficient plot
********************************************************************************

	graph export		"$reg_tables/h1_graph_1_product_flavor_coefficients.png", ///
							replace width(3200)
							
	restore
	
********************************************************************************
**# H1 graph 2A - Day 1 taste-related control coefficients
********************************************************************************

********************************************************************************
**## Purpose
********************************************************************************

* This graph shows the Day 1 coefficients on the main taste-related controls
* across the four Day 1 H1 models.
*
* The graph answers:
* On Day 1, are WTP changes related to flavor importance,
* sweetness importance, or sugar importance?
*
* Day 1 models:
*		d1_dwtp_3b_584
*		d1_dwtp_3b_793
*		d1_dwtp_3a_584
*		d1_dwtp_3a_793


********************************************************************************
**## Build graphing dataset
********************************************************************************

preserve

	tempfile			h1_day1_taste_coef
	tempname			memhold

	postfile			`memhold' ///
							str30 model ///
							str40 model_label ///
							str30 coef_name ///
							str80 coef_label ///
							int coef_id ///
							int plot_order ///
							double y_plot b se p ci_lo ci_hi ///
							using `h1_day1_taste_coef', replace


********************************************************************************
**## Run Day 1 full H1 models and store taste-related coefficients
********************************************************************************

	foreach spec in ///
		`"d1_dwtp_3b_584 d1_pref_lemon 4 "D1 584 3b""' ///
		`"d1_dwtp_3b_793 d1_pref_lemon 3 "D1 793 3b""' ///
		`"d1_dwtp_3a_584 d1_pref_lemon 2 "D1 584 3a""' ///
		`"d1_dwtp_3a_793 d1_pref_lemon 1 "D1 793 3a""' {

		tokenize		`"`spec'"'

		local y			"`1'"
		local pref		"`2'"
		local order		"`3'"
		local label		`"`4'"'


********************************************************************************
**### Run full H1 model
********************************************************************************

		reg				`y' ///
							`pref' ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust


********************************************************************************
**### Store flavor importance coefficient
********************************************************************************

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("flavor_low") ///
							("Flavor: moderate") ///
							(1) ///
							(`order') ///
							(`order' + .18) ///
							(_b[flavor_low]) ///
							(_se[flavor_low]) ///
							(2 * ttail(e(df_r), abs(_b[flavor_low] / _se[flavor_low]))) ///
							(_b[flavor_low] - invttail(e(df_r), .025) * _se[flavor_low]) ///
							(_b[flavor_low] + invttail(e(df_r), .025) * _se[flavor_low])


********************************************************************************
**### Store sweetness importance coefficient
********************************************************************************

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("sweet_high") ///
							("Sweetness high") ///
							(2) ///
							(`order') ///
							(`order') ///
							(_b[sweet_high]) ///
							(_se[sweet_high]) ///
							(2 * ttail(e(df_r), abs(_b[sweet_high] / _se[sweet_high]))) ///
							(_b[sweet_high] - invttail(e(df_r), .025) * _se[sweet_high]) ///
							(_b[sweet_high] + invttail(e(df_r), .025) * _se[sweet_high])


********************************************************************************
**### Store sugar importance coefficient
********************************************************************************

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("sugar_high") ///
							("Sugar high") ///
							(3) ///
							(`order') ///
							(`order' - .18) ///
							(_b[sugar_high]) ///
							(_se[sugar_high]) ///
							(2 * ttail(e(df_r), abs(_b[sugar_high] / _se[sugar_high]))) ///
							(_b[sugar_high] - invttail(e(df_r), .025) * _se[sugar_high]) ///
							(_b[sugar_high] + invttail(e(df_r), .025) * _se[sugar_high])
	}


********************************************************************************
**## Save graphing dataset
********************************************************************************

	postclose			`memhold'

	use					`h1_day1_taste_coef', clear

	sort				plot_order coef_id

	list				model_label coef_label b se p ci_lo ci_hi, clean noobs

	export delimited	using ///
							"$reg_tables/h1_graph_2a_day1_taste_controls_data.csv", ///
							replace


********************************************************************************
**## Create coefficient plot
********************************************************************************

	graph twoway ///
		(rcap ci_hi ci_lo y_plot if coef_id == 1, horizontal) ///
		(scatter y_plot b if coef_id == 1, msymbol(circle) mcolor(navy)) ///
		(rcap ci_hi ci_lo y_plot if coef_id == 2, horizontal) ///
		(scatter y_plot b if coef_id == 2, msymbol(triangle) mcolor(orange)) ///
		(rcap ci_hi ci_lo y_plot if coef_id == 3, horizontal) ///
		(scatter y_plot b if coef_id == 3, msymbol(square) mcolor(forest green)) ///
		, ///
		xline(0, lpattern(dash)) ///
		ylabel(1 "D1 793 3a" ///
			   2 "D1 584 3a" ///
			   3 "D1 793 3b" ///
			   4 "D1 584 3b", ///
			   angle(0) labsize(small) noticks) ///
		xlabel(, labsize(small)) ///
		xtitle("Coefficient on taste-related controls", ///
			   size(small) margin(medsmall)) ///
		ytitle("") ///
		title("H1 Day 1: Taste-related controls and WTP change", ///
			  size(medsmall) span justification(center)) ///
		subtitle("Full Day 1 H1 models with 95% confidence intervals", ///
				 size(small) span justification(center)) ///
		note("3a = info-first; 3b = taste-first.", ///
			 size(vsmall) span justification(center)) ///
		legend(order(2 "Flavor: moderate" ///
					 4 "Sweetness high" ///
					 6 "Sugar high") ///
			   rows(1) size(small) position(6)) ///
		graphregion(margin(l+30 r+20 t+10 b+10)) ///
		plotregion(margin(l+2 r+4 t+2 b+2)) ///
		xsize(14) ///
		ysize(6)


********************************************************************************
**## Export coefficient plot
********************************************************************************

	graph export		"$reg_tables/h1_graph_2a_day1_taste_controls.png", ///
							replace width(4000)

restore


********************************************************************************
**# H1 graph 2B - Day 2 taste-related control coefficients
********************************************************************************

********************************************************************************
**## Purpose
********************************************************************************

* This graph shows the Day 2 coefficients on the main taste-related controls
* across the four Day 2 H1 models.
*
* The graph answers:
* On Day 2, are WTP changes related to flavor importance,
* sweetness importance, or sugar importance?
*
* Day 2 models:
*		d2_dwtp_3b_356
*		d2_dwtp_3b_831
*		d2_dwtp_3a_356
*		d2_dwtp_3a_831


********************************************************************************
**## Build graphing dataset
********************************************************************************

preserve

	tempfile			h1_day2_taste_coef
	tempname			memhold

	postfile			`memhold' ///
							str30 model ///
							str40 model_label ///
							str30 coef_name ///
							str80 coef_label ///
							int coef_id ///
							int plot_order ///
							double y_plot b se p ci_lo ci_hi ///
							using `h1_day2_taste_coef', replace


********************************************************************************
**## Run Day 2 full H1 models and store taste-related coefficients
********************************************************************************

	foreach spec in ///
		`"d2_dwtp_3b_356 d2_pref_blueberry 4 "D2 356 3b""' ///
		`"d2_dwtp_3b_831 d2_pref_pineapple 3 "D2 831 3b""' ///
		`"d2_dwtp_3a_356 d2_pref_blueberry 2 "D2 356 3a""' ///
		`"d2_dwtp_3a_831 d2_pref_pineapple 1 "D2 831 3a""' {

		tokenize		`"`spec'"'

		local y			"`1'"
		local pref		"`2'"
		local order		"`3'"
		local label		`"`4'"'


********************************************************************************
**### Run full H1 model
********************************************************************************

		reg				`y' ///
							`pref' ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust


********************************************************************************
**### Store flavor importance coefficient
********************************************************************************

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("flavor_low") ///
							("Flavor: moderate") ///
							(1) ///
							(`order') ///
							(`order' + .18) ///
							(_b[flavor_low]) ///
							(_se[flavor_low]) ///
							(2 * ttail(e(df_r), abs(_b[flavor_low] / _se[flavor_low]))) ///
							(_b[flavor_low] - invttail(e(df_r), .025) * _se[flavor_low]) ///
							(_b[flavor_low] + invttail(e(df_r), .025) * _se[flavor_low])


********************************************************************************
**### Store sweetness importance coefficient
********************************************************************************

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("sweet_high") ///
							("Sweetness high") ///
							(2) ///
							(`order') ///
							(`order') ///
							(_b[sweet_high]) ///
							(_se[sweet_high]) ///
							(2 * ttail(e(df_r), abs(_b[sweet_high] / _se[sweet_high]))) ///
							(_b[sweet_high] - invttail(e(df_r), .025) * _se[sweet_high]) ///
							(_b[sweet_high] + invttail(e(df_r), .025) * _se[sweet_high])


********************************************************************************
**### Store sugar importance coefficient
********************************************************************************

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("sugar_high") ///
							("Sugar high") ///
							(3) ///
							(`order') ///
							(`order' - .18) ///
							(_b[sugar_high]) ///
							(_se[sugar_high]) ///
							(2 * ttail(e(df_r), abs(_b[sugar_high] / _se[sugar_high]))) ///
							(_b[sugar_high] - invttail(e(df_r), .025) * _se[sugar_high]) ///
							(_b[sugar_high] + invttail(e(df_r), .025) * _se[sugar_high])
	}


********************************************************************************
**## Save graphing dataset
********************************************************************************

	postclose			`memhold'

	use					`h1_day2_taste_coef', clear

	sort				plot_order coef_id

	list				model_label coef_label b se p ci_lo ci_hi, clean noobs

	export delimited	using ///
							"$reg_tables/h1_graph_2b_day2_taste_controls_data.csv", ///
							replace


********************************************************************************
**## Create coefficient plot
********************************************************************************

	graph twoway ///
		(rcap ci_hi ci_lo y_plot if coef_id == 1, horizontal) ///
		(scatter y_plot b if coef_id == 1, msymbol(circle) mcolor(navy)) ///
		(rcap ci_hi ci_lo y_plot if coef_id == 2, horizontal) ///
		(scatter y_plot b if coef_id == 2, msymbol(triangle) mcolor(orange)) ///
		(rcap ci_hi ci_lo y_plot if coef_id == 3, horizontal) ///
		(scatter y_plot b if coef_id == 3, msymbol(square) mcolor(forest green)) ///
		, ///
		xline(0, lpattern(dash)) ///
		ylabel(1 "D2 831 3a" ///
			   2 "D2 356 3a" ///
			   3 "D2 831 3b" ///
			   4 "D2 356 3b", ///
			   angle(0) labsize(small) noticks) ///
		xlabel(, labsize(small)) ///
		xtitle("Coefficient on taste-related controls", ///
			   size(small) margin(medsmall)) ///
		ytitle("") ///
		title("H1 Day 2: Taste-related controls and WTP change", ///
			  size(medsmall) span justification(center)) ///
		subtitle("Full Day 2 H1 models with 95% confidence intervals", ///
				 size(small) span justification(center)) ///
		note("3a = info-first; 3b = taste-first.", ///
			 size(vsmall) span justification(center)) ///
		legend(order(2 "Flavor: moderate" ///
					 4 "Sweetness high" ///
					 6 "Sugar high") ///
			   rows(1) size(small) position(6)) ///
		graphregion(margin(l+30 r+20 t+10 b+10)) ///
		plotregion(margin(l+2 r+4 t+2 b+2)) ///
		xsize(14) ///
		ysize(6)

********************************************************************************
**## Export coefficient plot
********************************************************************************

	graph export		"$reg_tables/h1_graph_2b_day2_taste_controls.png", ///
							replace width(4000)

restore


********************************************************************************
**# H1 graph 3A - Day 1 functional, health, and magnesium coefficients
********************************************************************************

********************************************************************************
**## Purpose
********************************************************************************

* This graph shows the Day 1 coefficients on functional ingredients,
* health claims, and prior magnesium knowledge across the four Day 1 H1 models.
*
* The graph answers:
* On Day 1, are WTP changes related to functional ingredient importance,
* health claim importance, or prior magnesium knowledge?
*
* Day 1 models:
*		d1_dwtp_3b_584
*		d1_dwtp_3b_793
*		d1_dwtp_3a_584
*		d1_dwtp_3a_793
*
* Functional / health / magnesium controls:
*		ingred_high
*		health_high
*		magn_know_high
*
* Full H1 model controls:
*		product-specific preferred flavor
*		flavor_low
*		sweet_high
*		sugar_high
*		ingred_high
*		health_high
*		magn_know_high


********************************************************************************
**## Build graphing dataset
********************************************************************************

preserve

	tempfile			h1_day1_fhm_coef
	tempname			memhold

	postfile			`memhold' ///
							str30 model ///
							str40 model_label ///
							str30 coef_name ///
							str80 coef_label ///
							int coef_id ///
							int plot_order ///
							double y_plot b se p ci_lo ci_hi ///
							using `h1_day1_fhm_coef', replace


********************************************************************************
**## Run Day 1 full H1 models and store functional / health / magnesium coefficients
********************************************************************************

	foreach spec in ///
		`"d1_dwtp_3b_584 d1_pref_lemon 4 "D1 584 3b""' ///
		`"d1_dwtp_3b_793 d1_pref_lemon 3 "D1 793 3b""' ///
		`"d1_dwtp_3a_584 d1_pref_lemon 2 "D1 584 3a""' ///
		`"d1_dwtp_3a_793 d1_pref_lemon 1 "D1 793 3a""' {

		tokenize		`"`spec'"'

		local y			"`1'"
		local pref		"`2'"
		local order		"`3'"
		local label		`"`4'"'


********************************************************************************
**### Run full H1 model
********************************************************************************

		reg				`y' ///
							`pref' ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust


********************************************************************************
**### Store functional ingredient importance coefficient
********************************************************************************

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("ingred_high") ///
							("Functional ingredients high") ///
							(1) ///
							(`order') ///
							(`order' + .18) ///
							(_b[ingred_high]) ///
							(_se[ingred_high]) ///
							(2 * ttail(e(df_r), abs(_b[ingred_high] / _se[ingred_high]))) ///
							(_b[ingred_high] - invttail(e(df_r), .025) * _se[ingred_high]) ///
							(_b[ingred_high] + invttail(e(df_r), .025) * _se[ingred_high])


********************************************************************************
**### Store health claim importance coefficient
********************************************************************************

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("health_high") ///
							("Health claims high") ///
							(2) ///
							(`order') ///
							(`order') ///
							(_b[health_high]) ///
							(_se[health_high]) ///
							(2 * ttail(e(df_r), abs(_b[health_high] / _se[health_high]))) ///
							(_b[health_high] - invttail(e(df_r), .025) * _se[health_high]) ///
							(_b[health_high] + invttail(e(df_r), .025) * _se[health_high])


********************************************************************************
**### Store prior magnesium knowledge coefficient
********************************************************************************

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("magn_know_high") ///
							("Prior magnesium knowledge high") ///
							(3) ///
							(`order') ///
							(`order' - .18) ///
							(_b[magn_know_high]) ///
							(_se[magn_know_high]) ///
							(2 * ttail(e(df_r), abs(_b[magn_know_high] / _se[magn_know_high]))) ///
							(_b[magn_know_high] - invttail(e(df_r), .025) * _se[magn_know_high]) ///
							(_b[magn_know_high] + invttail(e(df_r), .025) * _se[magn_know_high])
	}


********************************************************************************
**## Save graphing dataset
********************************************************************************

	postclose			`memhold'

	use					`h1_day1_fhm_coef', clear

	sort				plot_order coef_id

	list				model_label coef_label b se p ci_lo ci_hi, clean noobs

	export delimited	using ///
							"$reg_tables/h1_graph_3a_day1_functional_health_magnesium_data.csv", ///
							replace


********************************************************************************
**## Create coefficient plot
********************************************************************************

* Each model has three nearby points:
*		ingred_high			= slightly above model line
*		health_high			= centered on model line
*		magn_know_high		= slightly below model line
*
* Use short y-axis labels so text does not get cut off.
* Use span so titles and notes are centered across the full graph region.

	graph twoway ///
		(rcap ci_hi ci_lo y_plot if coef_id == 1, horizontal) ///
		(scatter y_plot b if coef_id == 1, msymbol(circle) mcolor(navy)) ///
		(rcap ci_hi ci_lo y_plot if coef_id == 2, horizontal) ///
		(scatter y_plot b if coef_id == 2, msymbol(triangle) mcolor(orange)) ///
		(rcap ci_hi ci_lo y_plot if coef_id == 3, horizontal) ///
		(scatter y_plot b if coef_id == 3, msymbol(square) mcolor(forest green)) ///
		, ///
		xline(0, lpattern(dash)) ///
		ylabel(1 "D1 793 3a" ///
			   2 "D1 584 3a" ///
			   3 "D1 793 3b" ///
			   4 "D1 584 3b", ///
			   angle(0) labsize(small) noticks) ///
		xlabel(, labsize(small)) ///
		xtitle("Coefficient on functional, health, and magnesium controls", ///
			   size(small) margin(medsmall)) ///
		ytitle("") ///
		title("H1 Day 1: Functional, health, and magnesium controls", ///
			  size(medsmall) span justification(center)) ///
		subtitle("Full Day 1 H1 models with 95% confidence intervals", ///
				 size(small) span justification(center)) ///
		note("3a = info-first; 3b = taste-first.", ///
			 size(vsmall) span justification(center)) ///
		legend(order(2 "Functional ingredients high" ///
					 4 "Health claims high" ///
					 6 "Prior magnesium knowledge high") ///
			   rows(2) size(small) position(6)) ///
		graphregion(margin(l+30 r+20 t+10 b+10)) ///
		plotregion(margin(l+2 r+4 t+2 b+2)) ///
		xsize(14) ///
		ysize(6)


********************************************************************************
**## Export coefficient plot
********************************************************************************

	graph export		"$reg_tables/h1_graph_3a_day1_functional_health_magnesium.png", ///
							replace width(4000)

restore


********************************************************************************
**# H1 graph 3B - Day 2 functional, health, and magnesium coefficients
********************************************************************************

********************************************************************************
**## Purpose
********************************************************************************

* This graph shows the Day 2 coefficients on functional ingredients,
* health claims, and prior magnesium knowledge across the four Day 2 H1 models.
*
* The graph answers:
* On Day 2, are WTP changes related to functional ingredient importance,
* health claim importance, or prior magnesium knowledge?
*
* Day 2 models:
*		d2_dwtp_3b_356
*		d2_dwtp_3b_831
*		d2_dwtp_3a_356
*		d2_dwtp_3a_831
*
* Functional / health / magnesium controls:
*		ingred_high
*		health_high
*		magn_know_high
*
* Full H1 model controls:
*		product-specific preferred flavor
*		flavor_low
*		sweet_high
*		sugar_high
*		ingred_high
*		health_high
*		magn_know_high


********************************************************************************
**## Build graphing dataset
********************************************************************************

preserve

	tempfile			h1_day2_fhm_coef
	tempname			memhold

	postfile			`memhold' ///
							str30 model ///
							str40 model_label ///
							str30 coef_name ///
							str80 coef_label ///
							int coef_id ///
							int plot_order ///
							double y_plot b se p ci_lo ci_hi ///
							using `h1_day2_fhm_coef', replace


********************************************************************************
**## Run Day 2 full H1 models and store functional / health / magnesium coefficients
********************************************************************************

	foreach spec in ///
		`"d2_dwtp_3b_356 d2_pref_blueberry 4 "D2 356 3b""' ///
		`"d2_dwtp_3b_831 d2_pref_pineapple 3 "D2 831 3b""' ///
		`"d2_dwtp_3a_356 d2_pref_blueberry 2 "D2 356 3a""' ///
		`"d2_dwtp_3a_831 d2_pref_pineapple 1 "D2 831 3a""' {

		tokenize		`"`spec'"'

		local y			"`1'"
		local pref		"`2'"
		local order		"`3'"
		local label		`"`4'"'


********************************************************************************
**### Run full H1 model
********************************************************************************

		reg				`y' ///
							`pref' ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust


********************************************************************************
**### Store functional ingredient importance coefficient
********************************************************************************

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("ingred_high") ///
							("Functional ingredients high") ///
							(1) ///
							(`order') ///
							(`order' + .18) ///
							(_b[ingred_high]) ///
							(_se[ingred_high]) ///
							(2 * ttail(e(df_r), abs(_b[ingred_high] / _se[ingred_high]))) ///
							(_b[ingred_high] - invttail(e(df_r), .025) * _se[ingred_high]) ///
							(_b[ingred_high] + invttail(e(df_r), .025) * _se[ingred_high])


********************************************************************************
**### Store health claim importance coefficient
********************************************************************************

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("health_high") ///
							("Health claims high") ///
							(2) ///
							(`order') ///
							(`order') ///
							(_b[health_high]) ///
							(_se[health_high]) ///
							(2 * ttail(e(df_r), abs(_b[health_high] / _se[health_high]))) ///
							(_b[health_high] - invttail(e(df_r), .025) * _se[health_high]) ///
							(_b[health_high] + invttail(e(df_r), .025) * _se[health_high])


********************************************************************************
**### Store prior magnesium knowledge coefficient
********************************************************************************

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("magn_know_high") ///
							("Prior magnesium knowledge high") ///
							(3) ///
							(`order') ///
							(`order' - .18) ///
							(_b[magn_know_high]) ///
							(_se[magn_know_high]) ///
							(2 * ttail(e(df_r), abs(_b[magn_know_high] / _se[magn_know_high]))) ///
							(_b[magn_know_high] - invttail(e(df_r), .025) * _se[magn_know_high]) ///
							(_b[magn_know_high] + invttail(e(df_r), .025) * _se[magn_know_high])
	}


********************************************************************************
**## Save graphing dataset
********************************************************************************

	postclose			`memhold'

	use					`h1_day2_fhm_coef', clear

	sort				plot_order coef_id

	list				model_label coef_label b se p ci_lo ci_hi, clean noobs

	export delimited	using ///
							"$reg_tables/h1_graph_3b_day2_functional_health_magnesium_data.csv", ///
							replace


********************************************************************************
**## Create coefficient plot
********************************************************************************

* Each model has three nearby points:
*		ingred_high			= slightly above model line
*		health_high			= centered on model line
*		magn_know_high		= slightly below model line
*
* Use short y-axis labels so text does not get cut off.
* Use span so titles and notes are centered across the full graph region.

	graph twoway ///
		(rcap ci_hi ci_lo y_plot if coef_id == 1, horizontal) ///
		(scatter y_plot b if coef_id == 1, msymbol(circle) mcolor(navy)) ///
		(rcap ci_hi ci_lo y_plot if coef_id == 2, horizontal) ///
		(scatter y_plot b if coef_id == 2, msymbol(triangle) mcolor(orange)) ///
		(rcap ci_hi ci_lo y_plot if coef_id == 3, horizontal) ///
		(scatter y_plot b if coef_id == 3, msymbol(square) mcolor(forest green)) ///
		, ///
		xline(0, lpattern(dash)) ///
		ylabel(1 "D2 831 3a" ///
			   2 "D2 356 3a" ///
			   3 "D2 831 3b" ///
			   4 "D2 356 3b", ///
			   angle(0) labsize(small) noticks) ///
		xlabel(, labsize(small)) ///
		xtitle("Coefficient on functional, health, and magnesium controls", ///
			   size(small) margin(medsmall)) ///
		ytitle("") ///
		title("H1 Day 2: Functional, health, and magnesium controls", ///
			  size(medsmall) span justification(center)) ///
		subtitle("Full Day 2 H1 models with 95% confidence intervals", ///
				 size(small) span justification(center)) ///
		note("3a = info-first; 3b = taste-first.", ///
			 size(vsmall) span justification(center)) ///
		legend(order(2 "Functional ingredients high" ///
					 4 "Health claims high" ///
					 6 "Prior magnesium knowledge high") ///
			   rows(2) size(small) position(6)) ///
		graphregion(margin(l+30 r+20 t+10 b+10)) ///
		plotregion(margin(l+2 r+4 t+2 b+2)) ///
		xsize(14) ///
		ysize(6)


********************************************************************************
**## Export coefficient plot
********************************************************************************

	graph export		"$reg_tables/h1_graph_3b_day2_functional_health_magnesium.png", ///
							replace width(4000)

restore


********************************************************************************
**# H1 graph 5 - exact versus family flavor preference coefficients
********************************************************************************

********************************************************************************
**## Purpose
********************************************************************************

* This graph compares exact product-specific flavor preference coefficients
* against broader flavor-family preference coefficients.
*
* The graph answers:
* Did broader flavor families explain WTP change better than exact flavor preference?
*
* Exact flavor variables:
*		Day 1: d1_pref_lemon
*		Day 2 356: d2_pref_blueberry
*		Day 2 831: d2_pref_pineapple
*
* Family flavor variables:
*		Day 1 Lemon-Lime family
*		Day 2 Blueberry family
*		Day 2 Pineapple family


********************************************************************************
**## Set family flavor variable names
********************************************************************************

* Family flavor variables already created in the H1 family block.
	local d1_family_var			d1_pref_lemon_family
	local d2_blue_family_var		d2_pref_blueberry_family
	local d2_pine_family_var		d2_pref_pineapple_family


********************************************************************************
**## Confirm family flavor variables exist
********************************************************************************

	confirm variable			`d1_family_var'
	confirm variable			`d2_blue_family_var'
	confirm variable			`d2_pine_family_var'

********************************************************************************
**## Build graphing dataset
********************************************************************************

preserve

	tempfile			h1_exact_family_coef
	tempname			memhold

	postfile			`memhold' ///
							str30 model ///
							str40 model_label ///
							str20 flavor_type ///
							int flavor_id ///
							int plot_order ///
							double y_plot b se p ci_lo ci_hi ///
							using `h1_exact_family_coef', replace


********************************************************************************
**## Run exact and family flavor models
********************************************************************************

	foreach spec in ///
		`"d1_dwtp_3b_584 d1_pref_lemon     `d1_family_var'       8 "D1 584 3b""' ///
		`"d1_dwtp_3b_793 d1_pref_lemon     `d1_family_var'       7 "D1 793 3b""' ///
		`"d1_dwtp_3a_584 d1_pref_lemon     `d1_family_var'       6 "D1 584 3a""' ///
		`"d1_dwtp_3a_793 d1_pref_lemon     `d1_family_var'       5 "D1 793 3a""' ///
		`"d2_dwtp_3b_356 d2_pref_blueberry `d2_blue_family_var'  4 "D2 356 3b""' ///
		`"d2_dwtp_3b_831 d2_pref_pineapple `d2_pine_family_var'  3 "D2 831 3b""' ///
		`"d2_dwtp_3a_356 d2_pref_blueberry `d2_blue_family_var'  2 "D2 356 3a""' ///
		`"d2_dwtp_3a_831 d2_pref_pineapple `d2_pine_family_var'  1 "D2 831 3a""' {

		tokenize		`"`spec'"'

		local y			"`1'"
		local exact		"`2'"
		local family	"`3'"
		local order		"`4'"
		local label		`"`5'"'


********************************************************************************
**### Exact flavor model
********************************************************************************

		reg				`y' ///
							`exact' ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("Exact flavor") ///
							(1) ///
							(`order') ///
							(`order' + .12) ///
							(_b[`exact']) ///
							(_se[`exact']) ///
							(2 * ttail(e(df_r), abs(_b[`exact'] / _se[`exact']))) ///
							(_b[`exact'] - invttail(e(df_r), .025) * _se[`exact']) ///
							(_b[`exact'] + invttail(e(df_r), .025) * _se[`exact'])


********************************************************************************
**### Flavor-family model
********************************************************************************

		reg				`y' ///
							`family' ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("Flavor family") ///
							(2) ///
							(`order') ///
							(`order' - .12) ///
							(_b[`family']) ///
							(_se[`family']) ///
							(2 * ttail(e(df_r), abs(_b[`family'] / _se[`family']))) ///
							(_b[`family'] - invttail(e(df_r), .025) * _se[`family']) ///
							(_b[`family'] + invttail(e(df_r), .025) * _se[`family'])
	}


********************************************************************************
**## Save graphing dataset
********************************************************************************

	postclose			`memhold'

	use					`h1_exact_family_coef', clear

	sort				plot_order flavor_id

	list				model_label flavor_type b se p ci_lo ci_hi, clean noobs

	export delimited	using "$reg_tables/h1_graph_5_exact_vs_family_flavor_data.csv", ///
							replace


********************************************************************************
**## Create coefficient plot
********************************************************************************

	graph twoway ///
		(rcap ci_hi ci_lo y_plot if flavor_id == 1, horizontal) ///
		(scatter y_plot b if flavor_id == 1, msymbol(circle) mcolor(navy) msize(small)) ///
		(rcap ci_hi ci_lo y_plot if flavor_id == 2, horizontal) ///
		(scatter y_plot b if flavor_id == 2, msymbol(triangle) mcolor(maroon) msize(small)) ///
		, ///
		xline(0, lpattern(dash)) ///
		ylabel(1 "D2 831 3a" ///
			   2 "D2 356 3a" ///
			   3 "D2 831 3b" ///
			   4 "D2 356 3b" ///
			   5 "D1 793 3a" ///
			   6 "D1 584 3a" ///
			   7 "D1 793 3b" ///
			   8 "D1 584 3b", ///
			   angle(0) labsize(small) noticks) ///
		xlabel(, labsize(small)) ///
		xtitle("Flavor coefficient estimate", ///
			   size(small) margin(small)) ///
		ytitle("") ///
		title("H1: Exact flavor vs. flavor-family preference", ///
			  size(small) span justification(center)) ///
		subtitle("Full H1 models with 95% confidence intervals", ///
				 size(vsmall) span justification(center)) ///
		note("Exact = product-specific flavor. Family = broader flavor-family grouping.", ///
			 size(vsmall) span justification(center)) ///
		legend(order(2 "Exact flavor" ///
					 4 "Flavor family") ///
			   rows(1) size(small) position(6) ///
			   region(lstyle(none))) ///
		graphregion(margin(l+30 r+20 t+10 b+10)) ///
		plotregion(margin(l+2 r+4 t+2 b+2)) ///
		xsize(14) ///
		ysize(6)


********************************************************************************
**## Export coefficient plot
********************************************************************************

	graph export		"$reg_tables/h1_graph_5_exact_vs_family_flavor.png", ///
							replace width(4800)
							
	restore
	
********************************************************************************
**# H2 graph 1 - gender and exercise across products
********************************************************************************

********************************************************************************
**## Purpose
********************************************************************************

* This graph shows the main H2 pooled interaction model.
*
* The graph answers:
* Across the main H2 product/path observations, do female respondents,
* high-exercise respondents, or high-exercise females show different WTP changes?
*
* The graph also includes the info-first path coefficient because it is the
* strongest and most stable result in the H2 pooled models.
*
* Dependent variable:
*		h2_dwtp
*
* Main H2 variables:
*		female
*		exercise_hi
*		female x exercise_hi
*
* Product and path controls:
*		i.h2_product
*		i.h2_path
*
* Full H2 controls:
*		h2_product_pref
*		flavor_low
*		sweet_high
*		sugar_high
*		ingred_high
*		health_high
*		magn_know_high


********************************************************************************
**## Build graphing dataset
********************************************************************************

preserve

	use					"$data/h2_long.dta", clear

	tempfile			h2_pool_coef
	tempname			memhold

	postfile			`memhold' ///
							str40 coef_name ///
							str60 coef_label ///
							int plot_order ///
							double b se p ci_lo ci_hi ///
							using `h2_pool_coef', replace


********************************************************************************
**## Run main pooled H2 interaction model
********************************************************************************

* This is the main H2 pooled interaction model.
* Standard errors are clustered by respondent because respondents can appear
* more than once in the long H2 dataset.

	reg					h2_dwtp ///
							i.female##i.exercise_hi ///
							h2_product_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high ///
							i.h2_product ///
							i.h2_path, ///
							vce(cluster resp_id)


********************************************************************************
**## Store female respondent coefficient
********************************************************************************

* Female respondent:
* Difference between low-exercise females and low-exercise males.

	post				`memhold' ///
							("1.female") ///
							("Female respondent") ///
							(4) ///
							(_b[1.female]) ///
							(_se[1.female]) ///
							(2 * ttail(e(df_r), abs(_b[1.female] / _se[1.female]))) ///
							(_b[1.female] - invttail(e(df_r), .025) * _se[1.female]) ///
							(_b[1.female] + invttail(e(df_r), .025) * _se[1.female])


********************************************************************************
**## Store high exercise coefficient
********************************************************************************

* High exercise:
* Difference between high-exercise males and low-exercise males.

	post				`memhold' ///
							("1.exercise_hi") ///
							("High exercise") ///
							(3) ///
							(_b[1.exercise_hi]) ///
							(_se[1.exercise_hi]) ///
							(2 * ttail(e(df_r), abs(_b[1.exercise_hi] / _se[1.exercise_hi]))) ///
							(_b[1.exercise_hi] - invttail(e(df_r), .025) * _se[1.exercise_hi]) ///
							(_b[1.exercise_hi] + invttail(e(df_r), .025) * _se[1.exercise_hi])


********************************************************************************
**## Store female by high exercise interaction coefficient
********************************************************************************

* Female x High exercise:
* Extra difference for high-exercise females, beyond the separate female
* and high-exercise effects.

	post				`memhold' ///
							("1.female#1.exercise_hi") ///
							("Female x High exercise") ///
							(2) ///
							(_b[1.female#1.exercise_hi]) ///
							(_se[1.female#1.exercise_hi]) ///
							(2 * ttail(e(df_r), abs(_b[1.female#1.exercise_hi] / _se[1.female#1.exercise_hi]))) ///
							(_b[1.female#1.exercise_hi] - invttail(e(df_r), .025) * _se[1.female#1.exercise_hi]) ///
							(_b[1.female#1.exercise_hi] + invttail(e(df_r), .025) * _se[1.female#1.exercise_hi])


********************************************************************************
**## Store info-first path coefficient
********************************************************************************

* Info-first path:
* Difference between info-first and taste-first respondents.
* Taste-first is the reference path.

	post				`memhold' ///
							("2.h2_path") ///
							("Info-first path") ///
							(1) ///
							(_b[2.h2_path]) ///
							(_se[2.h2_path]) ///
							(2 * ttail(e(df_r), abs(_b[2.h2_path] / _se[2.h2_path]))) ///
							(_b[2.h2_path] - invttail(e(df_r), .025) * _se[2.h2_path]) ///
							(_b[2.h2_path] + invttail(e(df_r), .025) * _se[2.h2_path])


********************************************************************************
**## Save graphing dataset
********************************************************************************

	postclose			`memhold'

	use					`h2_pool_coef', clear

	sort				plot_order

	list				coef_label b se p ci_lo ci_hi, clean noobs

	export delimited	using "$reg_tables/h2_graph_1_gender_exercise_across_products_data.csv", ///
							replace


********************************************************************************
**## Create coefficient plot
********************************************************************************

* Dots show coefficient estimates.
* Horizontal lines show 95 percent confidence intervals.
* The vertical zero line represents no estimated effect.
* A confidence interval crossing zero is not statistically clear at the 95 percent level.

	graph twoway ///
		(rcap ci_hi ci_lo plot_order, horizontal) ///
		(scatter plot_order b, msymbol(circle) mcolor(navy) msize(medsmall)) ///
		, ///
		xline(0, lpattern(dash)) ///
		ylabel(1 "Info-first path" ///
			   2 "Female x High exercise" ///
			   3 "High exercise" ///
			   4 "Female respondent", ///
			   angle(0) labsize(small) noticks) ///
		xlabel(, labsize(small)) ///
		xtitle("Coefficient estimate", ///
			   size(small) margin(small)) ///
		ytitle("") ///
		title("H2: Gender and exercise across products", ///
			  size(medsmall) span justification(center)) ///
		subtitle("Main pooled interaction model with 95% confidence intervals", ///
				 size(small) span justification(center)) ///
		note("Dependent variable is final WTP change from baseline. Product and path controls included.", ///
			 size(vsmall) span justification(center)) ///
		legend(off) ///
		graphregion(margin(l+30 r+20 t+10 b+10)) ///
		plotregion(margin(l+2 r+4 t+2 b+2)) ///
		xsize(14) ///
		ysize(6)


********************************************************************************
**## Export coefficient plot
********************************************************************************

	graph export		"$reg_tables/h2_graph_1_gender_exercise_across_products.png", ///
							replace width(4000)

restore


********************************************************************************
**# H2 graph 2 - Day 1 magnesium premium interaction models
********************************************************************************

********************************************************************************
**## Purpose
********************************************************************************

* This graph shows the H2 Day 1 magnesium premium interaction models.
*
* The graph answers:
* On Day 1, do female respondents, high-exercise respondents,
* or high-exercise females show a different WTP premium for 584 over 793?
*
* Day 1 premium outcomes:
*		d1_mag_premium_3b = final WTP for 584 - final WTP for 793, taste-first
*		d1_mag_premium_3a = final WTP for 584 - final WTP for 793, info-first
*
* Main H2 variables:
*		female
*		exercise_hi
*		female x exercise_hi
*
* Additional coefficient shown:
*		health_high
*
* Full premium model controls:
*		d1_pref_lemon
*		flavor_low
*		sweet_high
*		sugar_high
*		ingred_high
*		health_high
*		magn_know_high


********************************************************************************
**## Build graphing dataset
********************************************************************************

preserve

	tempfile			h2_d1_premium_coef
	tempname			memhold

	postfile			`memhold' ///
							str30 model ///
							str40 model_label ///
							str40 coef_name ///
							str60 coef_label ///
							int coef_id ///
							int plot_order ///
							double y_plot b se p ci_lo ci_hi ///
							using `h2_d1_premium_coef', replace


********************************************************************************
**## Run Day 1 premium interaction models and store selected coefficients
********************************************************************************

* Each line below identifies:
*		1. dependent variable
*		2. graph order
*		3. graph label
*
* 3b = taste-first
* 3a = info-first

	foreach spec in ///
		`"d1_mag_premium_3b 2 "D1 584-793 3b""' ///
		`"d1_mag_premium_3a 1 "D1 584-793 3a""' {

		tokenize		`"`spec'"'

		local y			"`1'"
		local order		"`2'"
		local label		`"`3'"'


********************************************************************************
**### Run Day 1 premium interaction model
********************************************************************************

		reg				`y' ///
							i.female##i.exercise_hi ///
							d1_pref_lemon ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust


********************************************************************************
**### Store female respondent coefficient
********************************************************************************

* Female respondent:
* Difference between low-exercise females and low-exercise males.

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("1.female") ///
							("Female respondent") ///
							(1) ///
							(`order') ///
							(`order' + .24) ///
							(_b[1.female]) ///
							(_se[1.female]) ///
							(2 * ttail(e(df_r), abs(_b[1.female] / _se[1.female]))) ///
							(_b[1.female] - invttail(e(df_r), .025) * _se[1.female]) ///
							(_b[1.female] + invttail(e(df_r), .025) * _se[1.female])


********************************************************************************
**### Store high exercise coefficient
********************************************************************************

* High exercise:
* Difference between high-exercise males and low-exercise males.

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("1.exercise_hi") ///
							("High exercise") ///
							(2) ///
							(`order') ///
							(`order' + .08) ///
							(_b[1.exercise_hi]) ///
							(_se[1.exercise_hi]) ///
							(2 * ttail(e(df_r), abs(_b[1.exercise_hi] / _se[1.exercise_hi]))) ///
							(_b[1.exercise_hi] - invttail(e(df_r), .025) * _se[1.exercise_hi]) ///
							(_b[1.exercise_hi] + invttail(e(df_r), .025) * _se[1.exercise_hi])


********************************************************************************
**### Store female by high exercise interaction coefficient
********************************************************************************

* Female x High exercise:
* Extra difference for high-exercise females, beyond the separate female
* and high-exercise effects.

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("1.female#1.exercise_hi") ///
							("Female x High exercise") ///
							(3) ///
							(`order') ///
							(`order' - .08) ///
							(_b[1.female#1.exercise_hi]) ///
							(_se[1.female#1.exercise_hi]) ///
							(2 * ttail(e(df_r), abs(_b[1.female#1.exercise_hi] / _se[1.female#1.exercise_hi]))) ///
							(_b[1.female#1.exercise_hi] - invttail(e(df_r), .025) * _se[1.female#1.exercise_hi]) ///
							(_b[1.female#1.exercise_hi] + invttail(e(df_r), .025) * _se[1.female#1.exercise_hi])


********************************************************************************
**### Store health-claim importance coefficient
********************************************************************************

* Health claims high:
* Difference for respondents who rated health claims as very or extremely important.

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("health_high") ///
							("Health claims high") ///
							(4) ///
							(`order') ///
							(`order' - .24) ///
							(_b[health_high]) ///
							(_se[health_high]) ///
							(2 * ttail(e(df_r), abs(_b[health_high] / _se[health_high]))) ///
							(_b[health_high] - invttail(e(df_r), .025) * _se[health_high]) ///
							(_b[health_high] + invttail(e(df_r), .025) * _se[health_high])
	}


********************************************************************************
**## Save graphing dataset
********************************************************************************

	postclose			`memhold'

	use					`h2_d1_premium_coef', clear

	sort				plot_order coef_id

	list				model_label coef_label b se p ci_lo ci_hi, clean noobs

	export delimited	using "$reg_tables/h2_graph_2_day1_magnesium_premium_data.csv", ///
							replace


********************************************************************************
**## Create coefficient plot
********************************************************************************

* Dots show coefficient estimates.
* Horizontal lines show 95 percent confidence intervals.
* The vertical zero line represents no estimated effect.
* A confidence interval crossing zero is not statistically clear at the 95 percent level.
*
* Positive coefficients mean higher WTP premium for 584 over 793.
* Negative coefficients mean lower WTP premium for 584 over 793.

	graph twoway ///
		(rcap ci_hi ci_lo y_plot if coef_id == 1, horizontal lcolor(gs8)) ///
		(scatter y_plot b if coef_id == 1, msymbol(circle) msize(medsmall) mcolor(navy)) ///
		(rcap ci_hi ci_lo y_plot if coef_id == 2, horizontal lcolor(gs8)) ///
		(scatter y_plot b if coef_id == 2, msymbol(triangle) msize(medsmall) mcolor(maroon)) ///
		(rcap ci_hi ci_lo y_plot if coef_id == 3, horizontal lcolor(gs8)) ///
		(scatter y_plot b if coef_id == 3, msymbol(square) msize(medsmall) mcolor(forest_green)) ///
		(rcap ci_hi ci_lo y_plot if coef_id == 4, horizontal lcolor(gs8)) ///
		(scatter y_plot b if coef_id == 4, msymbol(diamond) msize(medsmall) mcolor(orange)) ///
		, ///
		xline(0, lpattern(dash)) ///
		ylabel(1 "Info-first: 3a" ///
			   2 "Taste-first: 3b", ///
			   angle(0) labsize(small) noticks) ///
		xlabel(, labsize(small)) ///
		xtitle("Coefficient estimate for 584-over-793 premium", ///
			   size(small) margin(small)) ///
		ytitle("") ///
		title("H2 Day 1: 584 vs. 793 magnesium premium", ///
			  size(medsmall) span justification(center)) ///
		subtitle("Interaction models with 95% confidence intervals", ///
				 size(small) span justification(center)) ///
		note("Positive values indicate a higher WTP premium for 584 over 793.", ///
			 size(vsmall) span justification(center)) ///
		legend(order(2 "Female" ///
					 4 "High exercise" ///
					 6 "Female x High exercise" ///
					 8 "Health claims high") ///
			   rows(2) size(small) position(6) ///
			   region(lstyle(none))) ///
		graphregion(margin(l+30 r+20 t+10 b+10)) ///
		plotregion(margin(l+2 r+4 t+2 b+2)) ///
		xsize(14) ///
		ysize(6)


********************************************************************************
**## Export coefficient plot
********************************************************************************

	graph export		"$reg_tables/h2_graph_2_day1_magnesium_premium.png", ///
							replace width(4000)

restore


********************************************************************************
**# H2 graph 3 - Day 2 product premium interaction models
********************************************************************************

********************************************************************************
**## Purpose
********************************************************************************

* This graph shows the H2 Day 2 product premium interaction models.
*
* The graph answers:
* On Day 2, do female respondents, high-exercise respondents,
* or high-exercise females show a different WTP premium for 356 over 831?
*
* Day 2 product premium outcomes:
*		d2_product_premium_3b = final WTP for 356 - final WTP for 831, taste-first
*		d2_product_premium_3a = final WTP for 356 - final WTP for 831, info-first
*
* Main H2 variables:
*		female
*		exercise_hi
*		female x exercise_hi
*
* Product preference controls:
*		d2_pref_blueberry
*		d2_pref_pineapple
*
* Full premium model controls:
*		flavor_low
*		sweet_high
*		sugar_high
*		ingred_high
*		health_high
*		magn_know_high
*
* Note:
* This is a Day 2 product comparison, not a clean magnesium-versus-competitor
* comparison. Positive coefficients indicate a higher WTP premium for 356 over 831.


********************************************************************************
**## Build graphing dataset
********************************************************************************

preserve

	tempfile			h2_d2_product_premium_coef
	tempname			memhold

	postfile			`memhold' ///
							str30 model ///
							str40 model_label ///
							str40 coef_name ///
							str60 coef_label ///
							int coef_id ///
							int plot_order ///
							double y_plot b se p ci_lo ci_hi ///
							using `h2_d2_product_premium_coef', replace


********************************************************************************
**## Run Day 2 product premium interaction models and store selected coefficients
********************************************************************************

* Each line below identifies:
*		1. dependent variable
*		2. graph order
*		3. graph label
*
* 3b = taste-first
* 3a = info-first

	foreach spec in ///
		`"d2_product_premium_3b 2 "Taste-first: 3b""' ///
		`"d2_product_premium_3a 1 "Info-first: 3a""' {

		tokenize		`"`spec'"'

		local y			"`1'"
		local order		"`2'"
		local label		`"`3'"'


********************************************************************************
**### Run Day 2 product premium interaction model
********************************************************************************

		reg				`y' ///
							i.female##i.exercise_hi ///
							d2_pref_blueberry ///
							d2_pref_pineapple ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high, robust


********************************************************************************
**### Store female respondent coefficient
********************************************************************************

* Female respondent:
* Difference between low-exercise females and low-exercise males.

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("1.female") ///
							("Female respondent") ///
							(1) ///
							(`order') ///
							(`order' + .16) ///
							(_b[1.female]) ///
							(_se[1.female]) ///
							(2 * ttail(e(df_r), abs(_b[1.female] / _se[1.female]))) ///
							(_b[1.female] - invttail(e(df_r), .025) * _se[1.female]) ///
							(_b[1.female] + invttail(e(df_r), .025) * _se[1.female])


********************************************************************************
**### Store high exercise coefficient
********************************************************************************

* High exercise:
* Difference between high-exercise males and low-exercise males.

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("1.exercise_hi") ///
							("High exercise") ///
							(2) ///
							(`order') ///
							(`order') ///
							(_b[1.exercise_hi]) ///
							(_se[1.exercise_hi]) ///
							(2 * ttail(e(df_r), abs(_b[1.exercise_hi] / _se[1.exercise_hi]))) ///
							(_b[1.exercise_hi] - invttail(e(df_r), .025) * _se[1.exercise_hi]) ///
							(_b[1.exercise_hi] + invttail(e(df_r), .025) * _se[1.exercise_hi])


********************************************************************************
**### Store female by high exercise interaction coefficient
********************************************************************************

* Female x High exercise:
* Extra difference for high-exercise females, beyond the separate female
* and high-exercise effects.

		post			`memhold' ///
							("`y'") ///
							(`"`label'"') ///
							("1.female#1.exercise_hi") ///
							("Female x High exercise") ///
							(3) ///
							(`order') ///
							(`order' - .16) ///
							(_b[1.female#1.exercise_hi]) ///
							(_se[1.female#1.exercise_hi]) ///
							(2 * ttail(e(df_r), abs(_b[1.female#1.exercise_hi] / _se[1.female#1.exercise_hi]))) ///
							(_b[1.female#1.exercise_hi] - invttail(e(df_r), .025) * _se[1.female#1.exercise_hi]) ///
							(_b[1.female#1.exercise_hi] + invttail(e(df_r), .025) * _se[1.female#1.exercise_hi])
	}


********************************************************************************
**## Save graphing dataset
********************************************************************************

	postclose			`memhold'

	use					`h2_d2_product_premium_coef', clear

	sort				plot_order coef_id

	list				model_label coef_label b se p ci_lo ci_hi, clean noobs

	export delimited	using "$reg_tables/h2_graph_3_day2_product_premium_data.csv", ///
							replace


********************************************************************************
**## Create coefficient plot
********************************************************************************

* Dots show coefficient estimates.
* Horizontal lines show 95 percent confidence intervals.
* The vertical zero line represents no estimated effect.
* A confidence interval crossing zero is not statistically clear at the 95 percent level.
*
* Positive coefficients mean higher WTP premium for 356 over 831.
* Negative coefficients mean lower WTP premium for 356 over 831.

	graph twoway ///
		(rcap ci_hi ci_lo y_plot if coef_id == 1, horizontal lcolor(gs8)) ///
		(scatter y_plot b if coef_id == 1, msymbol(circle) msize(medsmall) mcolor(navy)) ///
		(rcap ci_hi ci_lo y_plot if coef_id == 2, horizontal lcolor(gs8)) ///
		(scatter y_plot b if coef_id == 2, msymbol(triangle) msize(medsmall) mcolor(maroon)) ///
		(rcap ci_hi ci_lo y_plot if coef_id == 3, horizontal lcolor(gs8)) ///
		(scatter y_plot b if coef_id == 3, msymbol(square) msize(medsmall) mcolor(forest_green)) ///
		, ///
		xline(0, lpattern(dash)) ///
		ylabel(1 "Info-first: 3a" ///
			   2 "Taste-first: 3b", ///
			   angle(0) labsize(small) noticks) ///
		xlabel(, labsize(small)) ///
		xtitle("Coefficient estimate for 356-over-831 premium", ///
			   size(small) margin(small)) ///
		ytitle("") ///
		title("H2 Day 2: 356 vs. 831 product premium", ///
			  size(medsmall) span justification(center)) ///
		subtitle("Interaction models with 95% confidence intervals", ///
				 size(small) span justification(center)) ///
		note("Positive values indicate a higher WTP premium for 356 over 831. This is a product comparison, not a magnesium premium.", ///
			 size(vsmall) span justification(center)) ///
		legend(order(2 "Female" ///
					 4 "High exercise" ///
					 6 "Female x High exercise") ///
			   rows(1) size(small) position(6) ///
			   region(lstyle(none))) ///
		graphregion(margin(l+30 r+20 t+10 b+10)) ///
		plotregion(margin(l+2 r+4 t+2 b+2)) ///
		xsize(14) ///
		ysize(6)


********************************************************************************
**## Export coefficient plot
********************************************************************************

	graph export		"$reg_tables/h2_graph_3_day2_product_premium.png", ///
							replace width(4000)

restore

********************************************************************************
**# H2 graph 4 - consumption-context robustness
********************************************************************************

********************************************************************************
**## Purpose
********************************************************************************

* This graph shows the H2 pooled interaction model with consumption-context
* controls added.
*
* The graph answers:
* Do the H2 gender and exercise results change after controlling for whether
* respondents consume sports beverages before, during, or after exercise?
*
* Dependent variable:
*		h2_dwtp
*
* Main H2 variables:
*		female
*		exercise_hi
*		female x exercise_hi
*
* Consumption-context controls:
*		con_situation_1
*		con_situation_2
*		con_situation_3
*
* Product and path controls:
*		i.h2_product
*		i.h2_path
*
* Full H2 controls:
*		h2_product_pref
*		flavor_low
*		sweet_high
*		sugar_high
*		ingred_high
*		health_high
*		magn_know_high


********************************************************************************
**## Build graphing dataset
********************************************************************************

preserve

	use					"$data/h2_long_context.dta", clear

	tempfile			h2_context_coef
	tempname			memhold

	postfile			`memhold' ///
							str40 coef_name ///
							str70 coef_label ///
							int plot_order ///
							double b se p ci_lo ci_hi ///
							using `h2_context_coef', replace


********************************************************************************
**## Run H2 pooled interaction model with consumption-context controls
********************************************************************************

* This model adds before/during/after-exercise consumption controls.
* Standard errors are clustered by respondent because respondents can appear
* more than once in the long H2 dataset.

	reg					h2_dwtp ///
							i.female##i.exercise_hi ///
							con_situation_1 ///
							con_situation_2 ///
							con_situation_3 ///
							h2_product_pref ///
							flavor_low ///
							sweet_high ///
							sugar_high ///
							ingred_high ///
							health_high ///
							magn_know_high ///
							i.h2_product ///
							i.h2_path, ///
							vce(cluster resp_id)


********************************************************************************
**## Store female respondent coefficient
********************************************************************************

* Female respondent:
* Difference between low-exercise females and low-exercise males.

	post				`memhold' ///
							("1.female") ///
							("Female respondent") ///
							(7) ///
							(_b[1.female]) ///
							(_se[1.female]) ///
							(2 * ttail(e(df_r), abs(_b[1.female] / _se[1.female]))) ///
							(_b[1.female] - invttail(e(df_r), .025) * _se[1.female]) ///
							(_b[1.female] + invttail(e(df_r), .025) * _se[1.female])


********************************************************************************
**## Store high exercise coefficient
********************************************************************************

* High exercise:
* Difference between high-exercise males and low-exercise males.

	post				`memhold' ///
							("1.exercise_hi") ///
							("High exercise") ///
							(6) ///
							(_b[1.exercise_hi]) ///
							(_se[1.exercise_hi]) ///
							(2 * ttail(e(df_r), abs(_b[1.exercise_hi] / _se[1.exercise_hi]))) ///
							(_b[1.exercise_hi] - invttail(e(df_r), .025) * _se[1.exercise_hi]) ///
							(_b[1.exercise_hi] + invttail(e(df_r), .025) * _se[1.exercise_hi])


********************************************************************************
**## Store female by high exercise interaction coefficient
********************************************************************************

* Female x High exercise:
* Extra difference for high-exercise females, beyond the separate female
* and high-exercise effects.

	post				`memhold' ///
							("1.female#1.exercise_hi") ///
							("Female x High exercise") ///
							(5) ///
							(_b[1.female#1.exercise_hi]) ///
							(_se[1.female#1.exercise_hi]) ///
							(2 * ttail(e(df_r), abs(_b[1.female#1.exercise_hi] / _se[1.female#1.exercise_hi]))) ///
							(_b[1.female#1.exercise_hi] - invttail(e(df_r), .025) * _se[1.female#1.exercise_hi]) ///
							(_b[1.female#1.exercise_hi] + invttail(e(df_r), .025) * _se[1.female#1.exercise_hi])


********************************************************************************
**## Store before-exercise consumption coefficient
********************************************************************************

* Consumes before exercise:
* Difference for respondents who report consuming sports beverages before exercise.

	post				`memhold' ///
							("con_situation_1") ///
							("Consumes before exercise") ///
							(4) ///
							(_b[con_situation_1]) ///
							(_se[con_situation_1]) ///
							(2 * ttail(e(df_r), abs(_b[con_situation_1] / _se[con_situation_1]))) ///
							(_b[con_situation_1] - invttail(e(df_r), .025) * _se[con_situation_1]) ///
							(_b[con_situation_1] + invttail(e(df_r), .025) * _se[con_situation_1])


********************************************************************************
**## Store during-exercise consumption coefficient
********************************************************************************

* Consumes during exercise:
* Difference for respondents who report consuming sports beverages during exercise.

	post				`memhold' ///
							("con_situation_2") ///
							("Consumes during exercise") ///
							(3) ///
							(_b[con_situation_2]) ///
							(_se[con_situation_2]) ///
							(2 * ttail(e(df_r), abs(_b[con_situation_2] / _se[con_situation_2]))) ///
							(_b[con_situation_2] - invttail(e(df_r), .025) * _se[con_situation_2]) ///
							(_b[con_situation_2] + invttail(e(df_r), .025) * _se[con_situation_2])


********************************************************************************
**## Store after-exercise consumption coefficient
********************************************************************************

* Consumes after exercise:
* Difference for respondents who report consuming sports beverages after exercise.

	post				`memhold' ///
							("con_situation_3") ///
							("Consumes after exercise") ///
							(2) ///
							(_b[con_situation_3]) ///
							(_se[con_situation_3]) ///
							(2 * ttail(e(df_r), abs(_b[con_situation_3] / _se[con_situation_3]))) ///
							(_b[con_situation_3] - invttail(e(df_r), .025) * _se[con_situation_3]) ///
							(_b[con_situation_3] + invttail(e(df_r), .025) * _se[con_situation_3])


********************************************************************************
**## Store info-first path coefficient
********************************************************************************

* Info-first path:
* Difference between info-first and taste-first respondents.
* Taste-first is the reference path.

	post				`memhold' ///
							("2.h2_path") ///
							("Info-first path") ///
							(1) ///
							(_b[2.h2_path]) ///
							(_se[2.h2_path]) ///
							(2 * ttail(e(df_r), abs(_b[2.h2_path] / _se[2.h2_path]))) ///
							(_b[2.h2_path] - invttail(e(df_r), .025) * _se[2.h2_path]) ///
							(_b[2.h2_path] + invttail(e(df_r), .025) * _se[2.h2_path])


********************************************************************************
**## Save graphing dataset
********************************************************************************

	postclose			`memhold'

	use					`h2_context_coef', clear

	sort				plot_order

	list				coef_label b se p ci_lo ci_hi, clean noobs

	export delimited	using "$reg_tables/h2_graph_4_consumption_context_robustness_data.csv", ///
							replace


********************************************************************************
**## Create coefficient plot
********************************************************************************

* Dots show coefficient estimates.
* Horizontal lines show 95 percent confidence intervals.
* The vertical zero line represents no estimated effect.
* A confidence interval crossing zero is not statistically clear at the 95 percent level.

	graph twoway ///
		(rcap ci_hi ci_lo plot_order, horizontal lcolor(gs8)) ///
		(scatter plot_order b, msymbol(circle) msize(medsmall) mcolor(navy)) ///
		, ///
		xline(0, lpattern(dash)) ///
		ylabel(1 "Info-first path" ///
			   2 "Consumes after exercise" ///
			   3 "Consumes during exercise" ///
			   4 "Consumes before exercise" ///
			   5 "Female x High exercise" ///
			   6 "High exercise" ///
			   7 "Female respondent", ///
			   angle(0) labsize(small) noticks) ///
		xlabel(, labsize(small)) ///
		xtitle("Coefficient estimate", ///
			   size(small) margin(small)) ///
		ytitle("") ///
		title("H2: Consumption-context robustness", ///
			  size(medsmall) span justification(center)) ///
		subtitle("Pooled interaction model with 95% confidence intervals", ///
				 size(small) span justification(center)) ///
		note("Consumption context controls added. Product and path controls included.", ///
			 size(vsmall) span justification(center)) ///
		legend(off) ///
		graphregion(margin(l+30 r+20 t+10 b+10)) ///
		plotregion(margin(l+2 r+4 t+2 b+2)) ///
		xsize(14) ///
		ysize(6)



********************************************************************************
**## Export coefficient plot
********************************************************************************

	graph export		"$reg_tables/h2_graph_4_consumption_context_robustness.png", ///
							replace width(4000)

restore
