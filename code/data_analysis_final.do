* course: AREC 397C
* assignment: regs analysis 
* created on: 23 apr 2026
* created by: tml jmt
* edited on: 23 apr 2026
* edited by: tml
* Stata v.19.5

* does
	
	
	

********************************************************************************
**# Import the data
********************************************************************************

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
**## baseline wtp_1
********************************************************************************

* wtp_1
	capture destring	wtp_1, replace
	label var			wtp_1 "Baseline willingness to pay"
	sum					wtp_1, detail
	
	
********************************************************************************
**## exercise 
********************************************************************************


*** participants who exercise more
* exercise
*** 30 minutes / days
*** it's a string, need to destring it

	cap destring			exercise, replace
	label var				exercise "Days per week of 30+ min of moderate to vigourous physical activity"
	sum						exercise, detail

********************************************************************************
* Exercise groups
********************************************************************************

	capture drop 		exercise_hi
	gen 				exercise_hi = exercise >= 3 if !missing(exercise)

	label define 		exercise_hi_lbl 0 "Low exercise" 1 "High exercise", replace
	label values 		exercise_hi exercise_hi_lbl

	tab 				exercise, missing
	tab 				exercise_hi, missing

	
**## con_situation - exercise

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
**# regression on wtp_1
********************************************************************************


* dependent = y = wtp_1

* independent = x = gender, exercise_hi, con_situation 1, 2, & 3



/*
TASTING EFFECT
If randomizer = 1 or 2 then the tasting effect is WTP 2b - WTP 1 
THIS ONE IS TASTE ON TASTE


If randomizer = 3 or 4 then the tasting effect is WTP_3a - WTP_2a
CANCELS OUT INFORMATION 
********************************************************************************
INFO EFFECT
If randomizer = 1 or 2 then WTP_3b - WTP 2b
CANCELS OUT TASTE

If randomizer = 3 or 4 then info effect is WTP 2a - WTP_1
JUST INFORMATION
*/

	reg			wtp_1 flavor_pref1_1 flavor_pref1_2 flavor_pref1_3 ///
					flavor_pref1_4 flavor_pref1_5 flavor_pref1_6 ///
					flavor_pref1_7 

	