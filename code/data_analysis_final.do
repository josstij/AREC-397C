* course: AREC 397C
* assignment: regs analysis 
* created on: 30 apr 2026
* created by: tml jmt
* edited on: 2 may 2026
* edited by: tml
* Stata v.19.5


	
	
	

********************************************************************************
**# Import the data and clean up
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
	
* confirm clean sample
	count

********************************************************************************
**# Basic demographics and randomization variables
********************************************************************************
	
* define basic value labels
	label define		gender_lbl 1 "Male" 2 "Female", replace
	label define		day_lbl 1 "day 1" 2 "day 2", replace
	label define		yesno_lbl 0 "No" 1 "Yes", replace

* this is how the paths were chosen. need this for determining taste-first /
* info-first 
	label define		randomizer_lbl ///
						1 "Randomizer 1" ///
						2 "Randomizer 2" ///
						3 "Randomizer 3" ///
						4 "Randomizer 4", replace

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
* this is what determines what the respondents got first, taste or information
	label var			randomizer "Randomization path"
	label values		randomizer randomizer_lbl
	tab					randomizer, missing

* finished
	label var			finished "Survey completed"
	label values		finished yesno_lbl
	tab					finished, missing
	
********************************************************************************
**# Value labels
********************************************************************************

* 5 point importance scale
	label define		imp5_lbl ///
						1 "Not at all important" ///
						2 "Slightly important" ///
						3 "Moderately important" ///
						4 "Very important" ///
						5 "Extremely important", replace
						
	
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
**# Preference Vars
********************************************************************************
	
**## pref_sweet
* This variable measures how important sweetness is to the respondent.
* Scale: 1 = Not at all important; 5 = Extremely important.
	label var			pref_sweet "Importance of sweetness"
	label values		pref_sweet imp5_lbl
	tab					pref_sweet, missing
	
* sweet_high
* Binary variable equal to 1 if sweetness is very or extremely important.
	capture drop		sweet_high
	gen					sweet_high = inlist(pref_sweet, 4, 5) ///
							if !missing(pref_sweet)

	label define		sweet_high_lbl ///
						0 "Not very important" ///
						1 "Very or extremely important", replace

	label var			sweet_high ///
							"Sweetness is very or extremely important"

	label values		sweet_high sweet_high_lbl

	tab					pref_sweet sweet_high, missing
	
	
**## pref_sugar
* This variable measures how important it is to the respondent that
* the amount of sugar per serving is low to moderate.
* Scale: 1 = Not at all important; 5 = Extremely important.
	label var			pref_sugar "Importance of low-to-moderate sugar per serving"
	label values		pref_sugar imp5_lbl
	tab					pref_sugar, missing

* sugar_lowmod_high
* Binary variable equal to 1 if low-to-moderate sugar per serving
* is very or extremely important to the respondent.
	capture drop		sugar_lowmod_high
	gen					sugar_lowmod_high = inlist(pref_sugar, 4, 5) ///
							if !missing(pref_sugar)

	label define		sugar_lowmod_high_lbl ///
						0 "Not very important" ///
						1 "Very or extremely important", replace

	label var			sugar_lowmod_high ///
							"Low-to-moderate sugar per serving is very/extremely important"

	label values		sugar_lowmod_high sugar_lowmod_high_lbl

	tab					pref_sugar sugar_lowmod_high, missing
	
	
	
**## pref_ingred
* This variable measures how important it is to the respondent that
* the drink contains ingredients that support performance and/or recovery.
* Scale: 1 = Not at all important; 5 = Extremely important.
	label var			pref_ingred "Importance of performance/recovery ingredients"
	label values		pref_ingred imp5_lbl
	tab					pref_ingred, missing
	
* ingred_high
* Binary variable equal to 1 if performance/recovery ingredients
* are very or extremely important to the respondent.
	capture drop		ingred_high
	gen					ingred_high = inlist(pref_ingred, 4, 5) ///
							if !missing(pref_ingred)

	label define		ingred_high_lbl ///
						0 "Not very important" ///
						1 "Very or extremely important", replace

	label var			ingred_high ///
							"Performance/recovery ingredients are very/extremely important"

	label values		ingred_high ingred_high_lbl

	tab					pref_ingred ingred_high, missing
	
	
**## pref_health
* This variable measures how important it is to the respondent that
* the drink claims a general health benefit.
* Scale: 1 = Not at all important; 5 = Extremely important.
	label var			pref_health "Importance of general health benefit claims"
	label values		pref_health imp5_lbl
	tab					pref_health, missing
	
* health_high
* Binary variable equal to 1 if general health benefit claims
* are very or extremely important to the respondent.
	capture drop		health_high
	gen					health_high = inlist(pref_health, 4, 5) ///
							if !missing(pref_health)

	label define		health_high_lbl ///
						0 "Not very important" ///
						1 "Very or extremely important", replace

	label var			health_high ///
							"General health benefit claims are very/extremely important"

	label values		health_high health_high_lbl

	tab					pref_health health_high, missing
	
	
	
**## preknow_5_magn
* This variable measures whether the respondent agrees that they are
* aware of specific benefits of magnesium.
* Scale: 1 = Strongly disagree; 5 = Strongly agree.
	label var			preknow_5_magn "Awareness of specific magnesium benefits"
	label values		preknow_5_magn agree5_lbl
	tab					preknow_5_magn, missing

* magn_know_high
* Binary variable equal to 1 if the respondent agrees or strongly agrees
* that they are aware of specific benefits of magnesium.
	capture drop		magn_know_high
	gen					magn_know_high = inlist(preknow_5_magn, 4, 5) ///
							if !missing(preknow_5_magn)

	label define		magn_know_high_lbl ///
						0 "Does not agree or is neutral" ///
						1 "Agrees or strongly agrees", replace

	label var			magn_know_high ///
							"Aware of specific magnesium benefits"

	label values		magn_know_high magn_know_high_lbl

	tab					preknow_5_magn magn_know_high, missing




********************************************************************************
**## Flavor Preferences
********************************************************************************

* check raw number of selected preferred flavors before replacing missing values
	capture drop		flavor_pref_raw_n
	egen				flavor_pref_raw_n = rownonmiss( ///
							flavor_pref1_1 flavor_pref1_2 flavor_pref1_3 ///
							flavor_pref1_4 flavor_pref1_5 flavor_pref1_6 ///
							flavor_pref1_7 flavor_pref1_8 flavor_pref1_9)

	tab					flavor_pref_raw_n, missing

* flavor_pref1_1
	replace				flavor_pref1_1 = 0 if missing(flavor_pref1_1)
	label var			flavor_pref1_1 "Selected Blueberry"
	label values		flavor_pref1_1 yesno_lbl
	tab					flavor_pref1_1, missing

* flavor_pref1_2
	replace				flavor_pref1_2 = 0 if missing(flavor_pref1_2)
	label var			flavor_pref1_2 "Selected Berry Blend"
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
	label var			flavor_pref1_8 "Selected None of Them"
	label values		flavor_pref1_8 yesno_lbl
	tab					flavor_pref1_8, missing

* flavor_pref1_9
	replace				flavor_pref1_9 = 0 if missing(flavor_pref1_9)
	label var			flavor_pref1_9 "Selected Other Flavor"
	label values		flavor_pref1_9 yesno_lbl
	tab					flavor_pref1_9, missing

* check number of preferred flavors selected after cleaning
	capture drop		flavor_pref_n
	egen				flavor_pref_n = rowtotal( ///
							flavor_pref1_1 flavor_pref1_2 flavor_pref1_3 ///
							flavor_pref1_4 flavor_pref1_5 flavor_pref1_6 ///
							flavor_pref1_7 flavor_pref1_8 flavor_pref1_9)

	label var			flavor_pref_n "Number of preferred flavors selected"

	tab					flavor_pref_n, missing

* check whether "None of them" was selected with another flavor
	count				if flavor_pref1_8 == 1 & flavor_pref_n > 1

********************************************************************************
**## Physical Activity
********************************************************************************

* exercise
* This variable measures the number of days in a typical week that the
* respondent does at least 30 minutes of moderate to vigorous physical activity.
	label var			exercise ///
							"days per week with 30+ minutes of moderate/vigorous physical activity"

	tab					exercise, missing
	sum					exercise, detail

* active_3plus
* Binary variable equal to 1 if the respondent reports at least 3 days per week
* with 30+ minutes of moderate to vigorous physical activity.
	capture drop		active_3plus
	gen					active_3plus = (exercise >= 3) ///
							if !missing(exercise)

	label define		active_3plus_lbl ///
						0 "Fewer than 3 days per week" ///
						1 "3 or more days per week", replace

	label var			active_3plus ///
							"3+ days per week with 30+ minutes physical activity"

	label values		active_3plus active_3plus_lbl

	tab					exercise active_3plus, missing
	tab					active_3plus, missing


********************************************************************************
**## Consumption Situation
********************************************************************************

* con_situation_1
* Respondent most often drinks sports beverages before exercise.
	replace				con_situation_1 = 0 if missing(con_situation_1)
	label var			con_situation_1 "Drinks sports beverages before exercise"
	label values		con_situation_1 yesno_lbl
	tab					con_situation_1, missing

* con_situation_2
* Respondent most often drinks sports beverages during exercise.
	replace				con_situation_2 = 0 if missing(con_situation_2)
	label var			con_situation_2 "Drinks sports beverages during exercise"
	label values		con_situation_2 yesno_lbl
	tab					con_situation_2, missing

* con_situation_3
* Respondent most often drinks sports beverages after exercise.
	replace				con_situation_3 = 0 if missing(con_situation_3)
	label var			con_situation_3 "Drinks sports beverages after exercise"
	label values		con_situation_3 yesno_lbl
	tab					con_situation_3, missing

* con_situation_n
* Count of exercise-related sports beverage consumption situations selected.
	capture drop		con_situation_n
	egen				con_situation_n = rowtotal( ///
							con_situation_1 con_situation_2 con_situation_3)

	label var			con_situation_n ///
							"Number of exercise-related consumption situations selected"

	tab					con_situation_n, missing
	
* uses_sportsbev_exercise
* Binary variable equal to 1 if the respondent most often drinks sports
* beverages before, during, or after exercise.
	capture drop		uses_sportsbev_exercise
	gen					uses_sportsbev_exercise = (con_situation_n > 0) ///
							if !missing(con_situation_n)

	label define		uses_sportsbev_exercise_lbl ///
						0 "Does not select exercise-related use" ///
						1 "Selects exercise-related use", replace

	label var			uses_sportsbev_exercise ///
							"Usually drinks sports beverages around exercise"

	label values		uses_sportsbev_exercise uses_sportsbev_exercise_lbl

	tab					uses_sportsbev_exercise, missing
	
	
********************************************************************************
**# WTP variables
********************************************************************************

**## raw WTP variables
* These variables measure willingness to pay at baseline and after each
* survey step. Baseline WTP is wtp_1.

	local wtpvars		wtp_1 ///
						wtp_2b_584 wtp_2b_793 wtp_2b_356 wtp_2b_831 ///
						wtp_3b_info_584 wtp_3b_info_793 ///
						wtp_3b_info_356 wtp_3b_info_831 ///
						wtp_2a_info_584 wtp_2a_info_793 ///
						wtp_2a_info_356 wtp_2a_info_831 ///
						wtp_3a_584 wtp_3a_793 ///
						wtp_3a_356 wtp_3a_831

* confirm all WTP variables exist before constructing effects
	foreach var of local wtpvars {
		confirm variable `var'
	}

* destring WTP variables if needed
	foreach var of local wtpvars {
		capture confirm string variable `var'
		if !_rc {
			destring		`var', replace
		}
	}
	
	
	label var			wtp_1 "Baseline willingness to pay"

	sum					`wtpvars', detail
	

	
********************************************************************************
**# Tasting and information effects
********************************************************************************

**## effect variables
	capture drop		taste_eff_584 taste_eff_793 taste_eff_356 taste_eff_831
	capture drop		info_eff_584 info_eff_793 info_eff_356 info_eff_831

	gen					taste_eff_584 = .
	gen					taste_eff_793 = .
	gen					taste_eff_356 = .
	gen					taste_eff_831 = .

	gen					info_eff_584 = .
	gen					info_eff_793 = .
	gen					info_eff_356 = .
	gen					info_eff_831 = .


********************************************************************************
**# Day 1: Product 584
********************************************************************************

* Taste-first path: tasting effect is post-taste WTP minus baseline WTP.
	replace				taste_eff_584 = wtp_2b_584 - wtp_1 ///
							if day == 1 ///
							& inlist(randomizer, 1, 2) ///
							& !missing(wtp_2b_584, wtp_1)

* Taste-first path: information effect is post-information WTP minus post-taste WTP.
	replace				info_eff_584 = wtp_3b_info_584 - wtp_2b_584 ///
							if day == 1 ///
							& inlist(randomizer, 1, 2) ///
							& !missing(wtp_3b_info_584, wtp_2b_584)

* Info-first path: information effect is post-information WTP minus baseline WTP.
	replace				info_eff_584 = wtp_2a_info_584 - wtp_1 ///
							if day == 1 ///
							& inlist(randomizer, 3, 4) ///
							& !missing(wtp_2a_info_584, wtp_1)

* Info-first path: tasting effect is post-taste WTP minus post-information WTP.
	replace				taste_eff_584 = wtp_3a_584 - wtp_2a_info_584 ///
							if day == 1 ///
							& inlist(randomizer, 3, 4) ///
							& !missing(wtp_3a_584, wtp_2a_info_584)


********************************************************************************
**# Day 1: Product 793
********************************************************************************

* Taste-first path: tasting effect is post-taste WTP minus baseline WTP.
	replace				taste_eff_793 = wtp_2b_793 - wtp_1 ///
							if day == 1 ///
							& inlist(randomizer, 1, 2) ///
							& !missing(wtp_2b_793, wtp_1)

* Taste-first path: information effect is post-information WTP minus post-taste WTP.
	replace				info_eff_793 = wtp_3b_info_793 - wtp_2b_793 ///
							if day == 1 ///
							& inlist(randomizer, 1, 2) ///
							& !missing(wtp_3b_info_793, wtp_2b_793)

* Info-first path: information effect is post-information WTP minus baseline WTP.
	replace				info_eff_793 = wtp_2a_info_793 - wtp_1 ///
							if day == 1 ///
							& inlist(randomizer, 3, 4) ///
							& !missing(wtp_2a_info_793, wtp_1)

* Info-first path: tasting effect is post-taste WTP minus post-information WTP.
	replace				taste_eff_793 = wtp_3a_793 - wtp_2a_info_793 ///
							if day == 1 ///
							& inlist(randomizer, 3, 4) ///
							& !missing(wtp_3a_793, wtp_2a_info_793)


********************************************************************************
**# Day 2: Product 356
********************************************************************************

* Taste-first path: tasting effect is post-taste WTP minus baseline WTP.
	replace				taste_eff_356 = wtp_2b_356 - wtp_1 ///
							if day == 2 ///
							& inlist(randomizer, 1, 2) ///
							& !missing(wtp_2b_356, wtp_1)

* Taste-first path: information effect is post-information WTP minus post-taste WTP.
	replace				info_eff_356 = wtp_3b_info_356 - wtp_2b_356 ///
							if day == 2 ///
							& inlist(randomizer, 1, 2) ///
							& !missing(wtp_3b_info_356, wtp_2b_356)

* Info-first path: information effect is post-information WTP minus baseline WTP.
	replace				info_eff_356 = wtp_2a_info_356 - wtp_1 ///
							if day == 2 ///
							& inlist(randomizer, 3, 4) ///
							& !missing(wtp_2a_info_356, wtp_1)

* Info-first path: tasting effect is post-taste WTP minus post-information WTP.
	replace				taste_eff_356 = wtp_3a_356 - wtp_2a_info_356 ///
							if day == 2 ///
							& inlist(randomizer, 3, 4) ///
							& !missing(wtp_3a_356, wtp_2a_info_356)


********************************************************************************
**# Day 2: Product 831
********************************************************************************

* Taste-first path: tasting effect is post-taste WTP minus baseline WTP.
	replace				taste_eff_831 = wtp_2b_831 - wtp_1 ///
							if day == 2 ///
							& inlist(randomizer, 1, 2) ///
							& !missing(wtp_2b_831, wtp_1)

* Taste-first path: information effect is post-information WTP minus post-taste WTP.
	replace				info_eff_831 = wtp_3b_info_831 - wtp_2b_831 ///
							if day == 2 ///
							& inlist(randomizer, 1, 2) ///
							& !missing(wtp_3b_info_831, wtp_2b_831)

* Info-first path: information effect is post-information WTP minus baseline WTP.
	replace				info_eff_831 = wtp_2a_info_831 - wtp_1 ///
							if day == 2 ///
							& inlist(randomizer, 3, 4) ///
							& !missing(wtp_2a_info_831, wtp_1)

* Info-first path: tasting effect is post-taste WTP minus post-information WTP.
	replace				taste_eff_831 = wtp_3a_831 - wtp_2a_info_831 ///
							if day == 2 ///
							& inlist(randomizer, 3, 4) ///
							& !missing(wtp_3a_831, wtp_2a_info_831)


********************************************************************************
**# Label generated variables
********************************************************************************

	label var			taste_eff_584 "Tasting effect: Product 584"
	label var			taste_eff_793 "Tasting effect: Product 793"
	label var			taste_eff_356 "Tasting effect: Product 356"
	label var			taste_eff_831 "Tasting effect: Product 831"

	label var			info_eff_584 "Information effect: Product 584"
	label var			info_eff_793 "Information effect: Product 793"
	label var			info_eff_356 "Information effect: Product 356"
	label var			info_eff_831 "Information effect: Product 831"


********************************************************************************
**# Check generated effect variables
********************************************************************************

	sum					taste_eff_584 taste_eff_793 ///
						taste_eff_356 taste_eff_831 ///
						info_eff_584 info_eff_793 ///
						info_eff_356 info_eff_831, detail

	tabstat				taste_eff_584 taste_eff_793 ///
						taste_eff_356 taste_eff_831 ///
						info_eff_584 info_eff_793 ///
						info_eff_356 info_eff_831, ///
						statistics(n mean sd min max)


						
						
********************************************************************************
**# Sensory Vars
********************************************************************************
********************************************************************************
**## 584 Mag
********************************************************************************
* label all sensory variables: hedonic 1-9

	
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
**## 356 Blueberry
********************************************************************************

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
**# Analysis readiness checks
********************************************************************************

* check clean analysis sample by day and randomization path
	tab					day randomizer, missing

* check H1 and H2 controls
	tab					gender, missing
	tab					active_3plus, missing
	tab					uses_sportsbev_exercise, missing
	tab					magn_know_high, missing

	tab					sweet_high, missing
	tab					sugar_lowmod_high, missing
	tab					ingred_high, missing
	tab					health_high, missing

* check key flavor preference controls
	tab					flavor_pref1_5, missing
	tab					flavor_pref1_1, missing
	tab					flavor_pref1_7, missing

* check nonmissing effect variables
	count				if !missing(taste_eff_584)
	count				if !missing(info_eff_584)

	count				if !missing(taste_eff_793)
	count				if !missing(info_eff_793)

	count				if !missing(taste_eff_356)
	count				if !missing(info_eff_356)

	count				if !missing(taste_eff_831)
	count				if !missing(info_eff_831)

* check effect variables by gender
	tabstat				info_eff_584 taste_eff_584 ///
						info_eff_793 taste_eff_793, ///
						by(gender) statistics(n mean sd)

* check effect variables by physical activity group
	tabstat				info_eff_584 taste_eff_584 ///
						info_eff_793 taste_eff_793, ///
						by(active_3plus) statistics(n mean sd)
						
						
********************************************************************************
**# Product contrast variables
********************************************************************************

**## Day 1 contrast: Product 584 vs Product 793
* These paired differences compare the magnesium/lab beverage to the
* competitor beverage for the same Day 1 respondents.

	capture drop		info_diff_584_793 taste_diff_584_793

	gen					info_diff_584_793 = info_eff_584 - info_eff_793 ///
							if day == 1 ///
							& !missing(info_eff_584, info_eff_793)

	gen					taste_diff_584_793 = taste_eff_584 - taste_eff_793 ///
							if day == 1 ///
							& !missing(taste_eff_584, taste_eff_793)

	label var			info_diff_584_793 ///
							"Information effect difference: Product 584 minus Product 793"

	label var			taste_diff_584_793 ///
							"Tasting effect difference: Product 584 minus Product 793"

	sum					info_diff_584_793 taste_diff_584_793, detail

	tabstat				info_diff_584_793 taste_diff_584_793, ///
							statistics(n mean sd min max)
							
							
							
********************************************************************************		
**# T-Tests
********************************************************************************

**## wtp_1 ttests

* wtp_1 compared to the baseline of 2.5: both days
	ttest			wtp_1 == 2.50
	
	
* wtp_1 compared to the baseline of 2.5 for day 1
	ttest			wtp_1 == 2.50 if day == 1
	
* wtp_1 compared to the baseline of 2.5 for day 2
	ttest			wtp_1 == 2.50 if day == 2

**### export wtp_1 ttests

********************************************************************************
**## wtp_1 ttests
********************************************************************************

	tempfile wtp1_ttests
	postutil clear

	postfile			wtp1_post ///
							str20 sample ///
							double N ///
							double mean ///
							double diff_from_250 ///
							double se ///
							double t_stat ///
							double df ///
							double p_value ///
							double ci_low ///
							double ci_high ///
							using "`wtp1_ttests'", replace


* wtp_1 compared to the baseline of 2.5: both days
	ttest			wtp_1 == 2.50
	
	local N			= r(N_1)
	local mean		= r(mu_1)
	local diff		= r(mu_1) - 2.50
	local se		= r(se)
	local t_stat	= r(t)
	local df		= r(df_t)
	local p_value	= r(p)
	local tcrit		= invttail(`df', .025)
	local ci_low	= `diff' - `tcrit' * `se'
	local ci_high	= `diff' + `tcrit' * `se'

	post wtp1_post	("Both days") ///
						(`N') ///
						(`mean') ///
						(`diff') ///
						(`se') ///
						(`t_stat') ///
						(`df') ///
						(`p_value') ///
						(`ci_low') ///
						(`ci_high')
	
	
* wtp_1 compared to the baseline of 2.5 for day 1
	ttest			wtp_1 == 2.50 if day == 1
	
	local N			= r(N_1)
	local mean		= r(mu_1)
	local diff		= r(mu_1) - 2.50
	local se		= r(se)
	local t_stat	= r(t)
	local df		= r(df_t)
	local p_value	= r(p)
	local tcrit		= invttail(`df', .025)
	local ci_low	= `diff' - `tcrit' * `se'
	local ci_high	= `diff' + `tcrit' * `se'

	post wtp1_post	("Day 1") ///
						(`N') ///
						(`mean') ///
						(`diff') ///
						(`se') ///
						(`t_stat') ///
						(`df') ///
						(`p_value') ///
						(`ci_low') ///
						(`ci_high')
	
	
* wtp_1 compared to the baseline of 2.5 for day 2
	ttest			wtp_1 == 2.50 if day == 2
	
	local N			= r(N_1)
	local mean		= r(mu_1)
	local diff		= r(mu_1) - 2.50
	local se		= r(se)
	local t_stat	= r(t)
	local df		= r(df_t)
	local p_value	= r(p)
	local tcrit		= invttail(`df', .025)
	local ci_low	= `diff' - `tcrit' * `se'
	local ci_high	= `diff' + `tcrit' * `se'

	post wtp1_post	("Day 2") ///
						(`N') ///
						(`mean') ///
						(`diff') ///
						(`se') ///
						(`t_stat') ///
						(`df') ///
						(`p_value') ///
						(`ci_low') ///
						(`ci_high')

	postclose			wtp1_post


********************************************************************************
**## Export wtp_1 ttests
********************************************************************************

preserve

	use				"`wtp1_ttests'", clear

	format			mean diff_from_250 se t_stat p_value ci_low ci_high %9.4f
	format			N df %9.0f

	export delimited using "$final_output/wtp_1_ttests.csv", replace

restore
	
	
********************************************************************************
**## Info Effect
********************************************************************************

	tempfile info_eff_ttests
	postutil clear

	postfile			info_post ///
							str20 product ///
							str20 sample ///
							double N ///
							double mean ///
							double diff_from_zero ///
							double se ///
							double t_stat ///
							double df ///
							double p_value ///
							double ci_low ///
							double ci_high ///
							using "`info_eff_ttests'", replace


* Testing whether the difference is different from zero

* Info eff 584
	ttest			info_eff_584 == 0 if day == 1
	
	local N			= r(N_1)
	local mean		= r(mu_1)
	local diff		= r(mu_1)
	local se		= r(se)
	local t_stat	= r(t)
	local df		= r(df_t)
	local p_value	= r(p)
	local tcrit		= invttail(`df', .025)
	local ci_low	= `diff' - `tcrit' * `se'
	local ci_high	= `diff' + `tcrit' * `se'

	post info_post	("584") ///
						("Day 1") ///
						(`N') ///
						(`mean') ///
						(`diff') ///
						(`se') ///
						(`t_stat') ///
						(`df') ///
						(`p_value') ///
						(`ci_low') ///
						(`ci_high')
	
	
* Info eff 793
	ttest			info_eff_793 == 0 if day == 1
	
	local N			= r(N_1)
	local mean		= r(mu_1)
	local diff		= r(mu_1)
	local se		= r(se)
	local t_stat	= r(t)
	local df		= r(df_t)
	local p_value	= r(p)
	local tcrit		= invttail(`df', .025)
	local ci_low	= `diff' - `tcrit' * `se'
	local ci_high	= `diff' + `tcrit' * `se'

	post info_post	("793") ///
						("Day 1") ///
						(`N') ///
						(`mean') ///
						(`diff') ///
						(`se') ///
						(`t_stat') ///
						(`df') ///
						(`p_value') ///
						(`ci_low') ///
						(`ci_high')
	
	
* Info eff 356
	ttest			info_eff_356 == 0 if day == 2
	
	local N			= r(N_1)
	local mean		= r(mu_1)
	local diff		= r(mu_1)
	local se		= r(se)
	local t_stat	= r(t)
	local df		= r(df_t)
	local p_value	= r(p)
	local tcrit		= invttail(`df', .025)
	local ci_low	= `diff' - `tcrit' * `se'
	local ci_high	= `diff' + `tcrit' * `se'

	post info_post	("356") ///
						("Day 2") ///
						(`N') ///
						(`mean') ///
						(`diff') ///
						(`se') ///
						(`t_stat') ///
						(`df') ///
						(`p_value') ///
						(`ci_low') ///
						(`ci_high')
	
	
* Info eff 831
	ttest			info_eff_831 == 0 if day == 2
	
	local N			= r(N_1)
	local mean		= r(mu_1)
	local diff		= r(mu_1)
	local se		= r(se)
	local t_stat	= r(t)
	local df		= r(df_t)
	local p_value	= r(p)
	local tcrit		= invttail(`df', .025)
	local ci_low	= `diff' - `tcrit' * `se'
	local ci_high	= `diff' + `tcrit' * `se'

	post info_post	("831") ///
						("Day 2") ///
						(`N') ///
						(`mean') ///
						(`diff') ///
						(`se') ///
						(`t_stat') ///
						(`df') ///
						(`p_value') ///
						(`ci_low') ///
						(`ci_high')

postclose			info_post


********************************************************************************
**## Export info-effect ttests
********************************************************************************

	preserve

	use				"`info_eff_ttests'", clear

	format			mean diff_from_zero se t_stat p_value ci_low ci_high %9.4f
	format			N df %9.0f

	export delimited using "$final_output/info_effect_ttests.csv", replace

restore
	

	
********************************************************************************
**## Tasting Effect
********************************************************************************

	tempfile taste_eff_ttests
	postutil clear

	postfile			taste_post ///
							str20 product ///
							str20 sample ///
							double N ///
							double mean ///
							double diff_from_zero ///
							double se ///
							double t_stat ///
							double df ///
							double p_value ///
							double ci_low ///
							double ci_high ///
							using "`taste_eff_ttests'", replace


* Testing whether the difference is different from zero

* Tasting eff 584
		ttest				taste_eff_584 == 0 if day == 1
			
		local N			= r(N_1)
		local mean		= r(mu_1)
		local diff		= r(mu_1)
		local se		= r(se)
		local t_stat	= r(t)
		local df		= r(df_t)
		local p_value	= r(p)
		local tcrit		= invttail(`df', .025)
		local ci_low	= `diff' - `tcrit' * `se'
		local ci_high	= `diff' + `tcrit' * `se'
	
		post 			taste_post	("584") ///
							("Day 1") ///
							(`N') ///
							(`mean') ///
							(`diff') ///
							(`se') ///
							(`t_stat') ///
							(`df') ///
							(`p_value') ///
							(`ci_low') ///
							(`ci_high')


* Tasting eff 793
	ttest			taste_eff_793 == 0 if day == 1
	
	local N			= r(N_1)
	local mean		= r(mu_1)
	local diff		= r(mu_1)
	local se		= r(se)
	local t_stat	= r(t)
	local df		= r(df_t)
	local p_value	= r(p)
	local tcrit		= invttail(`df', .025)
	local ci_low	= `diff' - `tcrit' * `se'
	local ci_high	= `diff' + `tcrit' * `se'

	post taste_post	("793") ///
						("Day 1") ///
						(`N') ///
						(`mean') ///
						(`diff') ///
						(`se') ///
						(`t_stat') ///
						(`df') ///
						(`p_value') ///
						(`ci_low') ///
						(`ci_high')


* Tasting eff 356
	ttest			taste_eff_356 == 0 if day == 2
	
	local N			= r(N_1)
	local mean		= r(mu_1)
	local diff		= r(mu_1)
	local se		= r(se)
	local t_stat	= r(t)
	local df		= r(df_t)
	local p_value	= r(p)
	local tcrit		= invttail(`df', .025)
	local ci_low	= `diff' - `tcrit' * `se'
	local ci_high	= `diff' + `tcrit' * `se'

	post taste_post	("356") ///
						("Day 2") ///
						(`N') ///
						(`mean') ///
						(`diff') ///
						(`se') ///
						(`t_stat') ///
						(`df') ///
						(`p_value') ///
						(`ci_low') ///
						(`ci_high')


* Tasting eff 831
	ttest			taste_eff_831 == 0 if day == 2
	
	local N			= r(N_1)
	local mean		= r(mu_1)
	local diff		= r(mu_1)
	local se		= r(se)
	local t_stat	= r(t)
	local df		= r(df_t)
	local p_value	= r(p)
	local tcrit		= invttail(`df', .025)
	local ci_low	= `diff' - `tcrit' * `se'
	local ci_high	= `diff' + `tcrit' * `se'

	post taste_post	("831") ///
						("Day 2") ///
						(`N') ///
						(`mean') ///
						(`diff') ///
						(`se') ///
						(`t_stat') ///
						(`df') ///
						(`p_value') ///
						(`ci_low') ///
						(`ci_high')

postclose			taste_post


********************************************************************************
**### Export tasting-effect ttests
********************************************************************************

preserve

	use				"`taste_eff_ttests'", clear

	format			mean diff_from_zero se t_stat p_value ci_low ci_high %9.4f
	format			N df %9.0f

	export delimited using "$final_output/tasting_effect_ttests.csv", replace

restore
	
	
********************************************************************************
**# Information Effect by Gender
********************************************************************************

	capture program drop post_twosample_ttest

	program			define post_twosample_ttest
	syntax 			varname [if], Product(string) Sample(string) Groupvar(string) ///
		Group1(string) Group2(string) Handle(name)

	ttest				`varlist' `if', by(`groupvar') unequal

	local N1			= r(N_1)
	local N2			= r(N_2)
	local mean1			= r(mu_1)
	local mean2			= r(mu_2)
	local diff			= r(mu_1) - r(mu_2)
	local sd1			= r(sd_1)
	local sd2			= r(sd_2)
	local se			= r(se)
	local t_stat		= r(t)
	local df			= r(df_t)
	local p_value		= r(p)

* confidence interval for group 1 minus group 2
	local tcrit			= invttail(`df', .025)
	local ci_low		= `diff' - `tcrit' * `se'
	local ci_high		= `diff' + `tcrit' * `se'

	post `handle'		("`product'") ///
							("`sample'") ///
							("`varlist'") ///
							("`groupvar'") ///
							("`group1'") ///
							("`group2'") ///
							(`N1') ///
							(`N2') ///
							(`mean1') ///
							(`mean2') ///
							(`diff') ///
							(`sd1') ///
							(`sd2') ///
							(`se') ///
							(`t_stat') ///
							(`df') ///
							(`p_value') ///
							(`ci_low') ///
							(`ci_high')
end


	tempfile info_eff_gender_ttests
	postutil clear

	postfile 			info_gender_post ///
							str20 product ///
							str20 sample ///
							str25 outcome ///
							str25 group_variable ///
							str35 group_1 ///
							str35 group_2 ///
							double N_1 ///
							double N_2 ///
							double mean_1 ///
							double mean_2 ///
							double diff_1_minus_2 ///
							double sd_1 ///
							double sd_2 ///
							double se_diff ///
							double t_stat ///
							double df ///
							double p_value ///
							double ci_low ///
							double ci_high ///
							using "`info_eff_gender_ttests'", replace


********************************************************************************
**### info eff 584
********************************************************************************

	post_twosample_ttest	info_eff_584 if day == 1, ///
									product("584") ///
									sample("Day 1") ///
									groupvar(gender) ///
									group1("Male") ///
									group2("Female") ///
									handle(info_gender_post)


********************************************************************************
**### info eff 793
********************************************************************************

	post_twosample_ttest	info_eff_793 if day == 1, ///
								product("793") ///
								sample("Day 1") ///
								groupvar(gender) ///
								group1("Male") ///
								group2("Female") ///
								handle(info_gender_post)


********************************************************************************
**### info eff 356
********************************************************************************

	post_twosample_ttest	info_eff_356 if day == 2, ///
								product("356") ///
								sample("Day 2") ///
								groupvar(gender) ///
								group1("Male") ///
								group2("Female") ///
								handle(info_gender_post)


********************************************************************************
**### info eff 831
********************************************************************************

	post_twosample_ttest	info_eff_831 if day == 2, ///
								product("831") ///
								sample("Day 2") ///
								groupvar(gender) ///
								group1("Male") ///
								group2("Female") ///
								handle(info_gender_post)

postclose				info_gender_post


********************************************************************************
**### Export information-effect gender ttests
********************************************************************************

	preserve

	use					"`info_eff_gender_ttests'", clear

	format				mean_1 mean_2 diff_1_minus_2 sd_1 sd_2 ///
							se_diff t_stat p_value ci_low ci_high %9.4f
	format				N_1 N_2 %9.0f
	format				df %9.2f

	export delimited using "$final_output/info_effect_gender_ttests.csv", replace

	restore

********************************************************************************
**# Information Effect by Exercise Group
********************************************************************************

capture program drop post_twosample_ttest

	program define post_twosample_ttest
	syntax varname [if], Product(string) Sample(string) Handle(name)

	ttest				`varlist' `if', by(active_3plus) unequal

	local N1			= r(N_1)
	local N2			= r(N_2)
	local mean1			= r(mu_1)
	local mean2			= r(mu_2)
	local diff			= r(mu_1) - r(mu_2)
	local sd1			= r(sd_1)
	local sd2			= r(sd_2)
	local se			= r(se)
	local t_stat		= r(t)
	local df			= r(df_t)
	local p_value		= r(p)

* confidence interval for group 1 minus group 2
	local tcrit			= invttail(`df', .025)
	local ci_low		= `diff' - `tcrit' * `se'
	local ci_high		= `diff' + `tcrit' * `se'

	post `handle'		("`product'") ///
							("`sample'") ///
							("`varlist'") ///
							("active_3plus") ///
							("Fewer than 3 days") ///
							("3 or more days") ///
							(`N1') ///
							(`N2') ///
							(`mean1') ///
							(`mean2') ///
							(`diff') ///
							(`sd1') ///
							(`sd2') ///
							(`se') ///
							(`t_stat') ///
							(`df') ///
							(`p_value') ///
							(`ci_low') ///
							(`ci_high')
	end


	tempfile info_eff_exercise_ttests
	postutil clear

	postfile info_exercise_post ///
		str20 product ///
		str20 sample ///
		str25 outcome ///
		str25 group_variable ///
		str35 group_1 ///
		str35 group_2 ///
		double N_1 ///
		double N_2 ///
		double mean_1 ///
		double mean_2 ///
		double diff_1_minus_2 ///
		double sd_1 ///
		double sd_2 ///
		double se_diff ///
		double t_stat ///
		double df ///
		double p_value ///
		double ci_low ///
		double ci_high ///
		using "`info_eff_exercise_ttests'", replace


********************************************************************************
**### Info eff 584
********************************************************************************

	post_twosample_ttest	info_eff_584 if day == 1, ///
								product("584") ///
								sample("Day 1") ///
								handle(info_exercise_post)


********************************************************************************
**### Info eff 793
********************************************************************************

	post_twosample_ttest	info_eff_793 if day == 1, ///
								product("793") ///
								sample("Day 1") ///
								handle(info_exercise_post)


********************************************************************************
**### Info eff 356
********************************************************************************

	post_twosample_ttest	info_eff_356 if day == 2, ///
								product("356") ///
								sample("Day 2") ///
								handle(info_exercise_post)


********************************************************************************
**### Info eff 831
********************************************************************************

	post_twosample_ttest	info_eff_831 if day == 2, ///
								product("831") ///
								sample("Day 2") ///
								handle(info_exercise_post)

	postclose				info_exercise_post


********************************************************************************
**## Export information-effect exercise ttests
********************************************************************************

preserve

	use					"`info_eff_exercise_ttests'", clear

	format				mean_1 mean_2 diff_1_minus_2 sd_1 sd_2 ///
							se_diff t_stat p_value ci_low ci_high %9.4f
	format				N_1 N_2 %9.0f
	format				df %9.2f

	export delimited using "$final_output/info_effect_exercise_ttests.csv", replace

restore

********************************************************************************
**# H1 regressions
********************************************************************************

********************************************************************************
**## Information effects
********************************************************************************

capture program drop post_reg_terms

program define post_reg_terms
	syntax, Product(string) Outcome(string) Sample(string) ///
		Flavorcoef(string) Flavorlabel(string) Handle(name)

	local N				= e(N)
	local r2			= e(r2)
	local df			= e(df_r)

	local coefs			"1.sweet_high 1.sugar_lowmod_high `flavorcoef' 1.ingred_high 1.health_high 1.magn_know_high _cons"

	foreach coef of local coefs {
	
		local term		"`coef'"
		
		if "`coef'" == "1.sweet_high" {
			local term	"High sweetness importance"
		}
		
		if "`coef'" == "1.sugar_lowmod_high" {
			local term	"High low-to-moderate sugar importance"
		}
		
		if "`coef'" == "`flavorcoef'" {
			local term	"`flavorlabel'"
		}
		
		if "`coef'" == "1.ingred_high" {
			local term	"High functional ingredient importance"
		}
		
		if "`coef'" == "1.health_high" {
			local term	"High health-claim importance"
		}
		
		if "`coef'" == "1.magn_know_high" {
			local term	"High magnesium knowledge"
		}
		
		if "`coef'" == "_cons" {
			local term	"Constant"
		}

		capture local b	= _b[`coef']
		
		if _rc == 0 {
		
			local se		= _se[`coef']
			local t_stat	= `b' / `se'
			local p_value	= 2 * ttail(`df', abs(`t_stat'))
			local tcrit		= invttail(`df', .025)
			local ci_low	= `b' - `tcrit' * `se'
			local ci_high	= `b' + `tcrit' * `se'

			post `handle'	("`product'") ///
							("`outcome'") ///
							("`sample'") ///
							("`term'") ///
							("`coef'") ///
							(`b') ///
							(`se') ///
							(`t_stat') ///
							(`p_value') ///
							(`ci_low') ///
							(`ci_high') ///
							(`N') ///
							(`r2')
		}
	}
end


tempfile info_reg_results
postutil clear

postfile info_reg_post ///
	str20 product ///
	str25 outcome ///
	str20 sample ///
	str50 term ///
	str30 coefficient ///
	double beta ///
	double se ///
	double t_stat ///
	double p_value ///
	double ci_low ///
	double ci_high ///
	double N ///
	double r2 ///
	using "`info_reg_results'", replace


********************************************************************************
**### Product 584: magnesium/lab beverage, Day 1
********************************************************************************

	reg					info_eff_584 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

	post_reg_terms,		product("584") ///
						outcome("info_eff_584") ///
						sample("Day 1") ///
						flavorcoef("1.flavor_pref1_5") ///
						flavorlabel("Selected Lemon Lime flavor") ///
						handle(info_reg_post)


********************************************************************************
**### Product 793: competitor beverage, Day 1
********************************************************************************

	reg					info_eff_793 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

	post_reg_terms,		product("793") ///
						outcome("info_eff_793") ///
						sample("Day 1") ///
						flavorcoef("1.flavor_pref1_5") ///
						flavorlabel("Selected Lemon Lime flavor") ///
						handle(info_reg_post)


********************************************************************************
**### Product 356: blueberry beverage, Day 2
********************************************************************************

	reg					info_eff_356 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_1 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust

	post_reg_terms,		product("356") ///
						outcome("info_eff_356") ///
						sample("Day 2") ///
						flavorcoef("1.flavor_pref1_1") ///
						flavorlabel("Selected Blueberry flavor") ///
						handle(info_reg_post)


********************************************************************************
**### Product 831: pineapple beverage, Day 2
********************************************************************************

	reg					info_eff_831 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_7 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust

	post_reg_terms,		product("831") ///
						outcome("info_eff_831") ///
						sample("Day 2") ///
						flavorcoef("1.flavor_pref1_7") ///
						flavorlabel("Selected Pineapple flavor") ///
						handle(info_reg_post)

postclose				info_reg_post


********************************************************************************
**## Export information-effect regressions
********************************************************************************

preserve

	use					"`info_reg_results'", clear

	format				beta se t_stat p_value ci_low ci_high r2 ///
	%9.4f
	format				N %9.0f

	export delimited	using "$final_output/info_effect_regressions.csv", replace

restore



********************************************************************************
**# Path controls
********************************************************************************
* I think we need to control for paths because I think they're going to have a ///
a considerable effect on these regressions after looking at the first round ///
of results
* info-first will go with info effects
* taste first will go with taste effects

	capture drop info_first
	capture drop taste_first

	gen					info_first = inlist(randomizer, 3, 4)
	gen					taste_first = inlist(randomizer, 1, 2)

	label var			info_first "Information-first path"
	label var			taste_first "Taste-first path"

	label values		info_first yesno_lbl
	label values		taste_first yesno_lbl
	
	
	
********************************************************************************
**# Information effects with information-first path control
********************************************************************************

capture program drop post_info_reg_terms

program define post_info_reg_terms
	syntax, Product(string) Depvar(string) Sampleday(string) ///
		Flavorcoef(string) Flavorlabel(string) Handle(name)

	local N				= e(N)
	local r2			= e(r2)
	local df			= e(df_r)

	local coefs			"1.info_first 1.sweet_high 1.sugar_lowmod_high `flavorcoef' 1.ingred_high 1.health_high 1.magn_know_high _cons"

	foreach coef of local coefs {
	
		local term		"`coef'"
		
		if "`coef'" == "1.info_first" {
			local term	"Information-first path"
		}
		
		if "`coef'" == "1.sweet_high" {
			local term	"High sweetness importance"
		}
		
		if "`coef'" == "1.sugar_lowmod_high" {
			local term	"High low-to-moderate sugar importance"
		}
		
		if "`coef'" == "`flavorcoef'" {
			local term	"`flavorlabel'"
		}
		
		if "`coef'" == "1.ingred_high" {
			local term	"High functional ingredient importance"
		}
		
		if "`coef'" == "1.health_high" {
			local term	"High health-claim importance"
		}
		
		if "`coef'" == "1.magn_know_high" {
			local term	"High magnesium knowledge"
		}
		
		if "`coef'" == "_cons" {
			local term	"Constant"
		}

		capture local b	= _b[`coef']
		
		if _rc == 0 {
		
			local se		= _se[`coef']
			local t_stat	= `b' / `se'
			local p_value	= 2 * ttail(`df', abs(`t_stat'))
			local tcrit		= invttail(`df', .025)
			local ci_low	= `b' - `tcrit' * `se'
			local ci_high	= `b' + `tcrit' * `se'

			post `handle'	("`product'") ///
							("`depvar'") ///
							("`sampleday'") ///
							("`term'") ///
							("`coef'") ///
							(`N') ///
							(`b') ///
							(`se') ///
							(`t_stat') ///
							(`p_value') ///
							(`ci_low') ///
							(`ci_high') ///
							(`r2')
		}
	}
end


tempfile info_reg_results
postutil clear

postfile info_reg_post ///
	str20 product ///
	str25 dependent_var ///
	str20 sample_day ///
	str55 term ///
	str30 coefficient ///
	double N ///
	double beta ///
	double se ///
	double t_stat ///
	double p_value ///
	double ci_low ///
	double ci_high ///
	double r2 ///
	using "`info_reg_results'", replace


********************************************************************************
**### Product 584: magnesium/lab beverage, Day 1
********************************************************************************

	reg					info_eff_584 ///
							i.info_first ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

	post_info_reg_terms, product("584") ///
							depvar("info_eff_584") ///
							sampleday("Day 1") ///
							flavorcoef("1.flavor_pref1_5") ///
							flavorlabel("Selected Lemon Lime flavor") ///
							handle(info_reg_post)


********************************************************************************
**### Product 793: competitor beverage, Day 1
********************************************************************************

	reg					info_eff_793 ///
							i.info_first ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

	post_info_reg_terms, product("793") ///
							depvar("info_eff_793") ///
							sampleday("Day 1") ///
							flavorcoef("1.flavor_pref1_5") ///
							flavorlabel("Selected Lemon Lime flavor") ///
							handle(info_reg_post)


********************************************************************************
**### Product 356: blueberry beverage, Day 2
********************************************************************************

	reg					info_eff_356 ///
							i.info_first ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_1 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust

	post_info_reg_terms, product("356") ///
							depvar("info_eff_356") ///
							sampleday("Day 2") ///
							flavorcoef("1.flavor_pref1_1") ///
							flavorlabel("Selected Blueberry flavor") ///
							handle(info_reg_post)


********************************************************************************
**### Product 831: pineapple beverage, Day 2
********************************************************************************

	reg					info_eff_831 ///
							i.info_first ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_7 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust

	post_info_reg_terms, product("831") ///
							depvar("info_eff_831") ///
							sampleday("Day 2") ///
							flavorcoef("1.flavor_pref1_7") ///
							flavorlabel("Selected Pineapple flavor") ///
							handle(info_reg_post)

postclose				info_reg_post


********************************************************************************
**## Export information-effect regressions
********************************************************************************

preserve

	use					"`info_reg_results'", clear

	format				beta se t_stat p_value ci_low ci_high r2 %9.4f
	format				N %9.0f

	export delimited	using "$final_output/info_effect_regressions_with_path.csv", replace

restore

********************************************************************************
**## Tasting effects
********************************************************************************
capture program drop post_taste_reg_terms

program define post_taste_reg_terms
	syntax, Product(string) Depvar(string) Sampleday(string) ///
		Flavorcoef(string) Flavorlabel(string) Handle(name)

	local N				= e(N)
	local r2			= e(r2)
	local df			= e(df_r)

	local coefs			"1.sweet_high 1.sugar_lowmod_high `flavorcoef' 1.ingred_high 1.health_high 1.magn_know_high _cons"

	foreach coef of local coefs {
	
		local term		"`coef'"
		
		if "`coef'" == "1.sweet_high" {
			local term	"High sweetness importance"
		}
		
		if "`coef'" == "1.sugar_lowmod_high" {
			local term	"High low-to-moderate sugar importance"
		}
		
		if "`coef'" == "`flavorcoef'" {
			local term	"`flavorlabel'"
		}
		
		if "`coef'" == "1.ingred_high" {
			local term	"High functional ingredient importance"
		}
		
		if "`coef'" == "1.health_high" {
			local term	"High health-claim importance"
		}
		
		if "`coef'" == "1.magn_know_high" {
			local term	"High magnesium knowledge"
		}
		
		if "`coef'" == "_cons" {
			local term	"Constant"
		}

		capture local b	= _b[`coef']
		
		if _rc == 0 {
		
			local se		= _se[`coef']
			local t_stat	= `b' / `se'
			local p_value	= 2 * ttail(`df', abs(`t_stat'))
			local tcrit		= invttail(`df', .025)
			local ci_low	= `b' - `tcrit' * `se'
			local ci_high	= `b' + `tcrit' * `se'

			post `handle'	("`product'") ///
							("`depvar'") ///
							("`sampleday'") ///
							("`term'") ///
							("`coef'") ///
							(`N') ///
							(`b') ///
							(`se') ///
							(`t_stat') ///
							(`p_value') ///
							(`ci_low') ///
							(`ci_high') ///
							(`r2')
		}
	}
end


	tempfile 			taste_reg_results
	postutil clear

	postfile 			taste_reg_post ///
							str20 product ///
							str25 dependent_var ///
							str20 sample_day ///
							str55 term ///
							str30 coefficient ///
							double N ///
							double beta ///
							double se ///
							double t_stat ///
							double p_value ///
							double ci_low ///
							double ci_high ///
							double r2 ///
							using "`taste_reg_results'", replace


********************************************************************************
**### Product 584: magnesium/lab beverage, Day 1
********************************************************************************

	reg					taste_eff_584 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

	post_taste_reg_terms, product("584") ///
							depvar("taste_eff_584") ///
							sampleday("Day 1") ///
							flavorcoef("1.flavor_pref1_5") ///
							flavorlabel("Selected Lemon Lime flavor") ///
							handle(taste_reg_post)


********************************************************************************
**### Product 793: competitor beverage, Day 1
********************************************************************************

	reg					taste_eff_793 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

	post_taste_reg_terms, product("793") ///
							depvar("taste_eff_793") ///
							sampleday("Day 1") ///
							flavorcoef("1.flavor_pref1_5") ///
							flavorlabel("Selected Lemon Lime flavor") ///
							handle(taste_reg_post)


********************************************************************************
**### Product 356: blueberry beverage, Day 2
********************************************************************************

	reg					taste_eff_356 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_1 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust

	post_taste_reg_terms, product("356") ///
							depvar("taste_eff_356") ///
							sampleday("Day 2") ///
							flavorcoef("1.flavor_pref1_1") ///
							flavorlabel("Selected Blueberry flavor") ///
							handle(taste_reg_post)


********************************************************************************
**### Product 831: pineapple beverage, Day 2
********************************************************************************

	reg					taste_eff_831 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_7 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust

	post_taste_reg_terms, product("831") ///
							depvar("taste_eff_831") ///
							sampleday("Day 2") ///
							flavorcoef("1.flavor_pref1_7") ///
							flavorlabel("Selected Pineapple flavor") ///
							handle(taste_reg_post)

postclose				taste_reg_post


********************************************************************************
**## Export tasting-effect regressions
********************************************************************************

preserve

	use					"`taste_reg_results'", clear

	format				beta se t_stat p_value ci_low ci_high r2 %9.4f
	format				N %9.0f

	export delimited	using "$final_output/tasting_effect_regressions.csv", 		replace
	
	restore



label var				taste_first "Taste-first path"

capture label define	yesno_lbl 0 "No" 1 "Yes", replace
label values			taste_first yesno_lbl


********************************************************************************
**## Tasting effects with taste-first path control
********************************************************************************

	capture program drop post_taste_reg_terms

	program define post_taste_reg_terms
	syntax, Product(string) Depvar(string) Sampleday(string) ///
		Flavorcoef(string) Flavorlabel(string) Handle(name)

	local N				= e(N)
	local r2			= e(r2)
	local df			= e(df_r)

	local coefs			"1.taste_first 1.sweet_high 1.sugar_lowmod_high `flavorcoef' 1.ingred_high 1.health_high 1.magn_know_high _cons"

	foreach coef of local coefs {
	
		local term		"`coef'"
		
		if "`coef'" == "1.taste_first" {
			local term	"Taste-first path"
		}
		
		if "`coef'" == "1.sweet_high" {
			local term	"High sweetness importance"
		}
		
		if "`coef'" == "1.sugar_lowmod_high" {
			local term	"High low-to-moderate sugar importance"
		}
		
		if "`coef'" == "`flavorcoef'" {
			local term	"`flavorlabel'"
		}
		
		if "`coef'" == "1.ingred_high" {
			local term	"High functional ingredient importance"
		}
		
		if "`coef'" == "1.health_high" {
			local term	"High health-claim importance"
		}
		
		if "`coef'" == "1.magn_know_high" {
			local term	"High magnesium knowledge"
		}
		
		if "`coef'" == "_cons" {
			local term	"Constant"
		}

		capture local b	= _b[`coef']
		
		if _rc == 0 {
		
			local se		= _se[`coef']
			local t_stat	= `b' / `se'
			local p_value	= 2 * ttail(`df', abs(`t_stat'))
			local tcrit		= invttail(`df', .025)
			local ci_low	= `b' - `tcrit' * `se'
			local ci_high	= `b' + `tcrit' * `se'

			post `handle'	("`product'") ///
							("`depvar'") ///
							("`sampleday'") ///
							("`term'") ///
							("`coef'") ///
							(`N') ///
							(`b') ///
							(`se') ///
							(`t_stat') ///
							(`p_value') ///
							(`ci_low') ///
							(`ci_high') ///
							(`r2')
		}
	}
end


	tempfile 			taste_reg_results_path
	postutil clear

	postfile taste_reg_post ///
				str20 product ///
				str25 dependent_var ///
				str20 sample_day ///
				str55 term ///
				str30 coefficient ///
				double N ///
				double beta ///
				double se ///
				double t_stat ///
				double p_value ///
				double ci_low ///
				double ci_high ///
				double r2 ///
				using "`taste_reg_results_path'", replace


********************************************************************************
**### Product 584: magnesium/lab beverage, Day 1
********************************************************************************

	reg					taste_eff_584 ///
							i.taste_first ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

	post_taste_reg_terms, product("584") ///
							depvar("taste_eff_584") ///
							sampleday("Day 1") ///
							flavorcoef("1.flavor_pref1_5") ///
							flavorlabel("Selected Lemon Lime flavor") ///
							handle(taste_reg_post)


********************************************************************************
**### Product 793: competitor beverage, Day 1
********************************************************************************

	reg					taste_eff_793 ///
							i.taste_first ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

	post_taste_reg_terms, product("793") ///
							depvar("taste_eff_793") ///
							sampleday("Day 1") ///
							flavorcoef("1.flavor_pref1_5") ///
							flavorlabel("Selected Lemon Lime flavor") ///
							handle(taste_reg_post)


********************************************************************************
**### Product 356: blueberry beverage, Day 2
********************************************************************************

	reg					taste_eff_356 ///
							i.taste_first ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_1 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust

	post_taste_reg_terms, product("356") ///
							depvar("taste_eff_356") ///
							sampleday("Day 2") ///
							flavorcoef("1.flavor_pref1_1") ///
							flavorlabel("Selected Blueberry flavor") ///
							handle(taste_reg_post)


********************************************************************************
**### Product 831: pineapple beverage, Day 2
********************************************************************************

	reg					taste_eff_831 ///
							i.taste_first ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_7 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust

	post_taste_reg_terms, product("831") ///
							depvar("taste_eff_831") ///
							sampleday("Day 2") ///
							flavorcoef("1.flavor_pref1_7") ///
							flavorlabel("Selected Pineapple flavor") ///
							handle(taste_reg_post)

postclose				taste_reg_post


********************************************************************************
**## Export tasting-effect regressions with path control
********************************************************************************

preserve

	use					"`taste_reg_results_path'", clear

	format				beta se t_stat p_value ci_low ci_high r2 %9.4f
	format				N %9.0f

	export delimited	using "$final_output/tasting_effect_regressions_with_path.csv", replace

restore

********************************************************************************
**# H2 regressions
********************************************************************************

********************************************************************************
**## H2 information-effect regressions
********************************************************************************

capture program drop post_h2_info_reg_terms

program define post_h2_info_reg_terms
	syntax, Product(string) Depvar(string) Sampleday(string) Modelrole(string) ///
		Flavorcoef(string) Flavorlabel(string) Handle(name)

	local N				= e(N)
	local r2			= e(r2)
	local df			= e(df_r)

	local coefs			"2.gender 1.active_3plus 1.sweet_high 1.sugar_lowmod_high `flavorcoef' 1.ingred_high 1.health_high 1.magn_know_high _cons"

	foreach coef of local coefs {
	
		local term		"`coef'"
		
		if "`coef'" == "2.gender" {
			local term	"Female"
		}
		
		if "`coef'" == "1.active_3plus" {
			local term	"Three or more exercise days"
		}
		
		if "`coef'" == "1.sweet_high" {
			local term	"High sweetness importance"
		}
		
		if "`coef'" == "1.sugar_lowmod_high" {
			local term	"High low-to-moderate sugar importance"
		}
		
		if "`coef'" == "`flavorcoef'" {
			local term	"`flavorlabel'"
		}
		
		if "`coef'" == "1.ingred_high" {
			local term	"High functional ingredient importance"
		}
		
		if "`coef'" == "1.health_high" {
			local term	"High health-claim importance"
		}
		
		if "`coef'" == "1.magn_know_high" {
			local term	"High magnesium knowledge"
		}
		
		if "`coef'" == "_cons" {
			local term	"Constant"
		}

		capture local b	= _b[`coef']
		
		if _rc == 0 {
		
			local se		= _se[`coef']
			local t_stat	= `b' / `se'
			local p_value	= 2 * ttail(`df', abs(`t_stat'))
			local tcrit		= invttail(`df', .025)
			local ci_low	= `b' - `tcrit' * `se'
			local ci_high	= `b' + `tcrit' * `se'

			post `handle'	("`product'") ///
							("`depvar'") ///
							("`sampleday'") ///
							("`modelrole'") ///
							("`term'") ///
							("`coef'") ///
							(`N') ///
							(`b') ///
							(`se') ///
							(`t_stat') ///
							(`p_value') ///
							(`ci_low') ///
							(`ci_high') ///
							(`r2')
		}
	}
end


tempfile h2_info_reg_results
postutil clear

postfile h2_info_reg_post ///
	str20 product ///
	str25 dependent_var ///
	str20 sample_day ///
	str25 model_role ///
	str55 term ///
	str30 coefficient ///
	double N ///
	double beta ///
	double se ///
	double t_stat ///
	double p_value ///
	double ci_low ///
	double ci_high ///
	double r2 ///
	using "`h2_info_reg_results'", replace


********************************************************************************
**## Product 584: magnesium/lab beverage
********************************************************************************

* Main H2 model: gender and physical activity differences in the
* Product 584 information effect.
	reg					info_eff_584 ///
							i.gender ///
							i.active_3plus ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

	post_h2_info_reg_terms, product("584") ///
							depvar("info_eff_584") ///
							sampleday("Day 1") ///
							modelrole("Main H2 model") ///
							flavorcoef("1.flavor_pref1_5") ///
							flavorlabel("Selected Lemon Lime flavor") ///
							handle(h2_info_reg_post)


********************************************************************************
**## Product 793: competitor beverage
********************************************************************************

* Supporting model: gender and physical activity differences in the
* Product 793 information effect.
	reg					info_eff_793 ///
							i.gender ///
							i.active_3plus ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

	post_h2_info_reg_terms, product("793") ///
							depvar("info_eff_793") ///
							sampleday("Day 1") ///
							modelrole("Supporting model") ///
							flavorcoef("1.flavor_pref1_5") ///
							flavorlabel("Selected Lemon Lime flavor") ///
							handle(h2_info_reg_post)


********************************************************************************
**## Product 356: blueberry beverage
********************************************************************************

* Supporting model: gender and physical activity differences in the
* Product 356 information effect.
	reg					info_eff_356 ///
							i.gender ///
							i.active_3plus ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_1 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust

	post_h2_info_reg_terms, product("356") ///
							depvar("info_eff_356") ///
							sampleday("Day 2") ///
							modelrole("Supporting model") ///
							flavorcoef("1.flavor_pref1_1") ///
							flavorlabel("Selected Blueberry flavor") ///
							handle(h2_info_reg_post)


********************************************************************************
**## Product 831: pineapple beverage
********************************************************************************

* Supporting model: gender and physical activity differences in the
* Product 831 information effect.
	reg					info_eff_831 ///
							i.gender ///
							i.active_3plus ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_7 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust

	post_h2_info_reg_terms, product("831") ///
							depvar("info_eff_831") ///
							sampleday("Day 2") ///
							modelrole("Supporting model") ///
							flavorcoef("1.flavor_pref1_7") ///
							flavorlabel("Selected Pineapple flavor") ///
							handle(h2_info_reg_post)

postclose				h2_info_reg_post


********************************************************************************
**## Export H2 information-effect regressions
********************************************************************************

preserve

	use					"`h2_info_reg_results'", clear

	format				beta se t_stat p_value ci_low ci_high r2 %9.4f
	format				N %9.0f

	export delimited	using "$final_output/h2_info_effect_regressions.csv", replace

restore


********************************************************************************
**## H2 information-effect regressions with consumption situation
********************************************************************************

capture program drop post_h2_info_reg_terms

program define post_h2_info_reg_terms
	syntax, Product(string) Depvar(string) Sampleday(string) Modelrole(string) ///
		Flavorcoef(string) Flavorlabel(string) Handle(name)

	local N				= e(N)
	local r2			= e(r2)
	local df			= e(df_r)

	local coefs			"2.gender 1.active_3plus 1.con_situation_1 1.con_situation_2 1.con_situation_3 1.sweet_high 1.sugar_lowmod_high `flavorcoef' 1.ingred_high 1.health_high 1.magn_know_high _cons"

	foreach coef of local coefs {
	
		local term		"`coef'"
		
		if "`coef'" == "2.gender" {
			local term	"Female"
		}
		
		if "`coef'" == "1.active_3plus" {
			local term	"Three or more exercise days"
		}
		
		if "`coef'" == "1.con_situation_1" {
			local term	"Consumes before exercise"
		}
		
		if "`coef'" == "1.con_situation_2" {
			local term	"Consumes during exercise"
		}
		
		if "`coef'" == "1.con_situation_3" {
			local term	"Consumes after exercise"
		}
		
		if "`coef'" == "1.sweet_high" {
			local term	"High sweetness importance"
		}
		
		if "`coef'" == "1.sugar_lowmod_high" {
			local term	"High low-to-moderate sugar importance"
		}
		
		if "`coef'" == "`flavorcoef'" {
			local term	"`flavorlabel'"
		}
		
		if "`coef'" == "1.ingred_high" {
			local term	"High functional ingredient importance"
		}
		
		if "`coef'" == "1.health_high" {
			local term	"High health-claim importance"
		}
		
		if "`coef'" == "1.magn_know_high" {
			local term	"High magnesium knowledge"
		}
		
		if "`coef'" == "_cons" {
			local term	"Constant"
		}

		capture local b	= _b[`coef']
		
		if _rc == 0 {
		
			local se		= _se[`coef']
			local t_stat	= `b' / `se'
			local p_value	= 2 * ttail(`df', abs(`t_stat'))
			local tcrit		= invttail(`df', .025)
			local ci_low	= `b' - `tcrit' * `se'
			local ci_high	= `b' + `tcrit' * `se'

			post `handle'	("`product'") ///
							("`depvar'") ///
							("`sampleday'") ///
							("`modelrole'") ///
							("`term'") ///
							("`coef'") ///
							(`N') ///
							(`b') ///
							(`se') ///
							(`t_stat') ///
							(`p_value') ///
							(`ci_low') ///
							(`ci_high') ///
							(`r2')
		}
	}
end


tempfile h2_info_reg_results_cons
postutil clear

postfile h2_info_reg_post ///
	str20 product ///
	str25 dependent_var ///
	str20 sample_day ///
	str25 model_role ///
	str55 term ///
	str30 coefficient ///
	double N ///
	double beta ///
	double se ///
	double t_stat ///
	double p_value ///
	double ci_low ///
	double ci_high ///
	double r2 ///
	using "`h2_info_reg_results_cons'", replace


********************************************************************************
**## Product 584: magnesium/lab beverage
********************************************************************************

* Main H2 model: gender, physical activity, and consumption-situation
* differences in the Product 584 information effect.
	reg					info_eff_584 ///
							i.gender ///
							i.active_3plus ///
							i.con_situation_1 ///
							i.con_situation_2 ///
							i.con_situation_3 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

	post_h2_info_reg_terms, product("584") ///
							depvar("info_eff_584") ///
							sampleday("Day 1") ///
							modelrole("Main H2 model") ///
							flavorcoef("1.flavor_pref1_5") ///
							flavorlabel("Selected Lemon Lime flavor") ///
							handle(h2_info_reg_post)


********************************************************************************
**## Product 793: competitor beverage
********************************************************************************

* Supporting model: gender, physical activity, and consumption-situation
* differences in the Product 793 information effect.
	reg					info_eff_793 ///
							i.gender ///
							i.active_3plus ///
							i.con_situation_1 ///
							i.con_situation_2 ///
							i.con_situation_3 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

	post_h2_info_reg_terms, product("793") ///
							depvar("info_eff_793") ///
							sampleday("Day 1") ///
							modelrole("Supporting model") ///
							flavorcoef("1.flavor_pref1_5") ///
							flavorlabel("Selected Lemon Lime flavor") ///
							handle(h2_info_reg_post)


********************************************************************************
**## Product 356: blueberry beverage
********************************************************************************

* Supporting model: gender, physical activity, and consumption-situation
* differences in the Product 356 information effect.
	reg					info_eff_356 ///
							i.gender ///
							i.active_3plus ///
							i.con_situation_1 ///
							i.con_situation_2 ///
							i.con_situation_3 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_1 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust

	post_h2_info_reg_terms, product("356") ///
							depvar("info_eff_356") ///
							sampleday("Day 2") ///
							modelrole("Supporting model") ///
							flavorcoef("1.flavor_pref1_1") ///
							flavorlabel("Selected Blueberry flavor") ///
							handle(h2_info_reg_post)


********************************************************************************
**## Product 831: pineapple beverage
********************************************************************************

* Supporting model: gender, physical activity, and consumption-situation
* differences in the Product 831 information effect.
	reg					info_eff_831 ///
							i.gender ///
							i.active_3plus ///
							i.con_situation_1 ///
							i.con_situation_2 ///
							i.con_situation_3 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_7 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust

	post_h2_info_reg_terms, product("831") ///
							depvar("info_eff_831") ///
							sampleday("Day 2") ///
							modelrole("Supporting model") ///
							flavorcoef("1.flavor_pref1_7") ///
							flavorlabel("Selected Pineapple flavor") ///
							handle(h2_info_reg_post)

postclose				h2_info_reg_post




********************************************************************************
**## Export H2 information-effect regressions with consumption situation
********************************************************************************

preserve

	use					"`h2_info_reg_results_cons'", clear

	format				beta se t_stat p_value ci_low ci_high r2 %9.4f
	format				N %9.0f

	export delimited	using "$final_output/h2_info_effect_regressions_consumption_situation.csv", replace

restore


********************************************************************************
**# Final graphs
********************************************************************************

********************************************************************************
**## Graph 1: Baseline WTP Compared with $2.50 Benchmark
********************************************************************************

preserve

	clear

	input str12 sample mean ci_low ci_high
	"Both days"	3.039	2.927	3.152
	"Day 1"		3.066	2.898	3.234
	"Day 2"		3.014	2.859	3.169
	end

	gen				sample_order = _n

	label define	sample_lbl ///
						1 "Both days" ///
						2 "Day 1" ///
						3 "Day 2", replace

	label values	sample_order sample_lbl

	twoway ///
		(rcap ci_low ci_high sample_order, ///
			lcolor(navy) ///
			lwidth(medthick)) ///
		(scatter mean sample_order, ///
			msymbol(circle) ///
			msize(large) ///
			mcolor(maroon)), ///
		yline(2.50, ///
			lcolor(forest_green) ///
			lpattern(dash) ///
			lwidth(medthick)) ///
		xlabel(1 "Both days" 2 "Day 1" 3 "Day 2", labsize(medlarge)) ///
		ylabel(2.4(.2)3.3, angle(horizontal) labsize(medlarge)) ///
		xtitle("") ///
		ytitle("Baseline willingness to pay ($)", size(medlarge)) ///
		title("Baseline Willingness to Pay Exceeded the $2.50 Benchmark", size(medsmall)) ///
		subtitle("Mean baseline WTP with 95% confidence intervals", size(small)) ///
		note("Dashed line marks the $2.50 benchmark price.", size(small)) ///
		legend(off) ///
		graphregion(color(white)) ///
		plotregion(color(white)) ///
		name(g_baseline_wtp, replace)

	graph export "$final_output/graph_1_baseline_wtp.png", replace width(2400)

restore

********************************************************************************
**## Graph 2: Information Effects by Product
********************************************************************************

preserve

	clear

	input product_order str24 product mean ci_low ci_high
	1	"584: Magnesium/Lab"		0.037	-0.098	 0.172
	2	"793: Competitor"		   -0.544	-0.721	-0.368
	3	"356: Blueberry"		   -0.139	-0.333	 0.055
	4	"831: Pineapple"		   -0.007	-0.144	 0.130
	end

	label define	product_lbl ///
						1 "584: Magnesium/Lab" ///
						2 "793: Competitor" ///
						3 "356: Blueberry" ///
						4 "831: Pineapple", replace

	label values	product_order product_lbl

	twoway ///
		(rcap ci_low ci_high product_order, ///
			lcolor(navy) ///
			lwidth(medthick)) ///
		(scatter mean product_order, ///
			msymbol(circle) ///
			msize(large) ///
			mcolor(maroon)), ///
		yline(0, ///
			lcolor(forest_green) ///
			lpattern(dash) ///
			lwidth(medthick)) ///
		xlabel(1 "584: Magnesium/Lab" ///
			   2 "793: Competitor" ///
			   3 "356: Blueberry" ///
			   4 "831: Pineapple", ///
			   angle(30) labsize(medium)) ///
		ylabel(-0.8(.2)0.2, angle(horizontal) labsize(medlarge)) ///
		xtitle("") ///
		ytitle("Change in WTP information ($)", size(medlarge)) ///
		title("Product Information Did Not Increase WTP for Product 584", size(medsmall)) ///
		subtitle("Mean information effects with 95% confidence intervals", size(small)) ///
		note("Dashed line marks zero change in WTP.", size(small)) ///
		legend(off) ///
		graphregion(color(white)) ///
		plotregion(color(white)) ///
		name(g_info_effects, replace)

	graph export "${final_output}/graph_2_information_effects.png", replace width(2400)

restore


********************************************************************************
**# Graph 3: Tasting Effects by Product
********************************************************************************

preserve

	clear

	input product_order str24 product mean ci_low ci_high
	1	"584: Magnesium/Lab"	   -0.335	-0.520	-0.149
	2	"793: Competitor"		    0.188	 0.024	 0.351
	3	"356: Blueberry"		   -0.188	-0.416	 0.041
	4	"831: Pineapple"		   -0.302	-0.488	-0.116
	end

	label define	product_lbl ///
						1 "584: Magnesium/Lab" ///
						2 "793: Competitor" ///
						3 "356: Blueberry" ///
						4 "831: Pineapple", replace

	label values	product_order product_lbl

	twoway ///
		(rcap ci_low ci_high product_order, ///
			lcolor(navy) ///
			lwidth(medthick)) ///
		(scatter mean product_order, ///
			msymbol(circle) ///
			msize(large) ///
			mcolor(maroon)), ///
		yline(0, ///
			lcolor(forest_green) ///
			lpattern(dash) ///
			lwidth(medthick)) ///
		xlabel(1 "584: Magnesium/Lab" ///
			   2 "793: Competitor" ///
			   3 "356: Blueberry" ///
			   4 "831: Pineapple", ///
			   angle(30) labsize(medium)) ///
		ylabel(-0.6(.2)0.4, angle(horizontal) labsize(medlarge)) ///
		xtitle("") ///
		ytitle("Change in WTP after tasting ($)", size(medlarge)) ///
		title("Tasting Reduced WTP for Product 584 but Increased WTP for Product 793", size(medsmall)) ///
		subtitle("Mean tasting effects with 95% confidence intervals", size(small)) ///
		note("Dashed line marks zero change in WTP.", size(small)) ///
		legend(off) ///
		graphregion(color(white)) ///
		plotregion(color(white)) ///
		xsize(9) ///
		ysize(5) ///
		name(g_taste_effects, replace)

	graph export "$final_output/graph_3_tasting_effects.png", replace width(2400)

restore



********************************************************************************
**# Graph 4: Information-Driven WTP Change for Day 1 Products
********************************************************************************

preserve

	keep if					day == 1

	* identify survey path
	capture drop				info_first
	gen						info_first = inlist(randomizer, 3, 4)

	gen						obs_id = _n

	* Product 584 information effect
	gen						info_change_584 = .
	replace					info_change_584 = wtp_2a_info_584 - wtp_1 ///
								if info_first == 1
	replace					info_change_584 = wtp_3b_info_584 - wtp_2b_584 ///
								if info_first == 0

	* Product 793 information effect
	gen						info_change_793 = .
	replace					info_change_793 = wtp_2a_info_793 - wtp_1 ///
								if info_first == 1
	replace					info_change_793 = wtp_3b_info_793 - wtp_2b_793 ///
								if info_first == 0

	keep					obs_id info_first info_change_584 info_change_793

	reshape long			info_change_, i(obs_id) j(product)

	rename					info_change_ info_change

	drop if					missing(info_change)

	collapse				(count) N = info_change ///
							(mean) mean = info_change ///
							(sd) sd = info_change, ///
							by(product info_first)

	gen						se = sd / sqrt(N)
	gen						ci_low = mean - invttail(N - 1, 0.025) * se
	gen						ci_high = mean + invttail(N - 1, 0.025) * se

	gen						product_order = .
	replace					product_order = 1 if product == 584
	replace					product_order = 2 if product == 793

	gen						xpos = product_order
	replace					xpos = product_order - 0.18 if info_first == 0
	replace					xpos = product_order + 0.18 if info_first == 1

	gen						mean_label = cond(mean >= 0, ///
								"+$" + string(mean, "%4.2f"), ///
								"-$" + string(abs(mean), "%4.2f"))

	twoway ///
		(bar mean xpos if info_first == 0, ///
			base(0) ///
			barwidth(0.32) ///
			fcolor(navy%55) ///
			lcolor(navy)) ///
		(bar mean xpos if info_first == 1, ///
			base(0) ///
			barwidth(0.32) ///
			fcolor(maroon%55) ///
			lcolor(maroon)) ///
		(scatter mean xpos if mean >= 0, ///
			msymbol(none) ///
			mlabel(mean_label) ///
			mlabposition(12) ///
			mlabsize(small) ///
			mlabcolor(black)) ///
		(scatter mean xpos if mean < 0, ///
			msymbol(none) ///
			mlabel(mean_label) ///
			mlabposition(6) ///
			mlabsize(small) ///
			mlabcolor(black)), ///
		yline(0, ///
			lcolor(forest_green) ///
			lpattern(dash) ///
			lwidth(medthick)) ///
		xlabel(1 "584: Magnesium/Lab" ///
			   2 "793: Competitor", ///
			   labsize(medlarge)) ///
		ylabel(-1(.25).5, angle(horizontal) labsize(medlarge)) ///
		yscale(range(-1.05 .55)) ///
		xtitle("") ///
		ytitle("Change in WTP after information ($)", size(medlarge)) ///
		title("How Product Information Moved WTP for Day 1 Beverages", size(medsmall)) ///
		subtitle("Mean information effects by survey order with 95% confidence intervals", size(small)) ///
		note("Bars above zero mean information increased WTP. Bars below zero mean information reduced WTP.", size(small)) ///
		legend(order(1 "Taste first, then information" ///
					 2 "Information first, then tasting") ///
			   rows(1) ///
			   size(small) ///
			   position(6)) ///
		graphregion(color(white)) ///
		plotregion(color(white)) ///
		xsize(9) ///
		ysize(5) ///
		name(g_day1_info_change_bars, replace)

	graph export "$final_output/graph_4_day1_information_change_bars.png", replace width(2400)

restore
********************************************************************************
**# Graph 5: Gender Differences in Information Effects
********************************************************************************

preserve

	clear

	input product_order str24 product diff ci_low ci_high
	4	"584: Magnesium/Lab"	   -0.013	-0.284	 0.259
	3	"793: Competitor"		   -0.356	-0.705	-0.007
	2	"356: Blueberry"		    0.361	-0.023	 0.745
	1	"831: Pineapple"		    0.208	-0.063	 0.480
	end

	label define	product_lbl ///
						4 "584: Magnesium/Lab" ///
						3 "793: Competitor" ///
						2 "356: Blueberry" ///
						1 "831: Pineapple", replace

	label values	product_order product_lbl

	twoway ///
		(rcap ci_low ci_high product_order, ///
			horizontal ///
			lcolor(navy) ///
			lwidth(medthick)) ///
		(scatter product_order diff, ///
			msymbol(circle) ///
			msize(large) ///
			mcolor(maroon)), ///
		xline(0, ///
			lcolor(forest_green) ///
			lpattern(dash) ///
			lwidth(medthick)) ///
		ylabel(1 "831 Pineapple" ///
			   2 "356 Blueberry" ///
			   3 "793 Competitor" ///
			   4 "584 Magnesium/Lab", ///
			   angle(horizontal) labsize(medlarge)) ///
		xlabel(-0.8(.2)0.8, labsize(medlarge)) ///
		ytitle("") ///
		xtitle("Gender difference in information effect ($)", size(medlarge)) ///
		title("Product 584 Showed No Gender Difference in Information Response", size(medsmall)) ///
		subtitle("Male minus female mean information effects with 95% confidence intervals", size(small)) ///
		legend(off) ///
		graphregion(color(white)) ///
		plotregion(color(white)) ///
		xsize(9) ///
		ysize(5) ///
		name(g_gender_info_effects, replace)

	graph export "$final_output/graph_5_gender_info_effects.png", replace width(2400)

restore


********************************************************************************
**# Graph 6: Exercise Differences in Information Effects
********************************************************************************

preserve

	clear

	input product_order str24 product diff ci_low ci_high
	4	"584: Magnesium/Lab"	   -0.084	-0.390	 0.221
	3	"793: Competitor"		    0.025	-0.352	 0.402
	2	"356: Blueberry"		    0.205	-0.216	 0.625
	1	"831: Pineapple"		    0.202	-0.084	 0.489
	end

	label define	product_lbl ///
						4 "584: Magnesium/Lab" ///
						3 "793: Competitor" ///
						2 "356: Blueberry" ///
						1 "831: Pineapple", replace

	label values	product_order product_lbl

	twoway ///
		(rcap ci_low ci_high product_order, ///
			horizontal ///
			lcolor(navy) ///
			lwidth(medthick)) ///
		(scatter product_order diff, ///
			msymbol(circle) ///
			msize(large) ///
			mcolor(maroon)), ///
		xline(0, ///
			lcolor(forest_green) ///
			lpattern(dash) ///
			lwidth(medthick)) ///
		ylabel(1 "831 Pineapple" ///
			   2 "356 Blueberry" ///
			   3 "793 Competitor" ///
			   4 "584 Magnesium/Lab", ///
			   angle(horizontal) labsize(medlarge)) ///
		xlabel(-0.5(.25)0.75, labsize(medlarge)) ///
		ytitle("") ///
		xtitle("Exercise difference in information effect ($)", size(medlarge)) ///
		title("More Active Respondents Did Not Have Stronger Information Effects for Product 584", size(medsmall)) ///
		subtitle("Three or more exercise days minus fewer than three days, with 95% confidence intervals", size(small)) ///
		legend(off) ///
		graphregion(color(white)) ///
		plotregion(color(white)) ///
		xsize(9) ///
		ysize(5) ///
		name(g_exercise_info_effects, replace)

	graph export "${final_output}/graph_6_exercise_info_effects.png", replace width(2400)

restore


********************************************************************************
**# Graph 7: Product 584 H2 Regression Coefficients
********************************************************************************

preserve

	clear

	input coef_order str40 variable beta se p_value
	11	"Female"								-0.024	0.146	0.869
	10	"Three or more exercise days"			-0.093	0.181	0.611
	9	"Consumes before exercise"				 0.095	0.293	0.747
	8	"Consumes during exercise"				-0.002	0.196	0.992
	7	"Consumes after exercise"				 0.033	0.140	0.818
	6	"High sweetness importance"				 0.145	0.143	0.315
	5	"High low-to-moderate sugar importance"	 0.130	0.144	0.370
	4	"Selected Lemon Lime flavor"				-0.192	0.163	0.244
	3	"High functional ingredient importance"	 0.072	0.170	0.674
	2	"High health-claim importance"			-0.159	0.171	0.355
	1	"High magnesium knowledge"				-0.094	0.156	0.550
	end

	gen				ci_low  = beta - 1.96 * se
	gen				ci_high = beta + 1.96 * se

	label define	coef_lbl ///
						11 "Female" ///
						10 "Three or more exercise days" ///
						9  "Consumes before exercise" ///
						8  "Consumes during exercise" ///
						7  "Consumes after exercise" ///
						6  "High sweetness importance" ///
						5  "High low-to-moderate sugar importance" ///
						4  "Selected Lemon Lime flavor" ///
						3  "High functional ingredient importance" ///
						2  "High health-claim importance" ///
						1  "High magnesium knowledge", replace

	label values	coef_order coef_lbl

	twoway ///
		(rcap ci_low ci_high coef_order, ///
			horizontal ///
			lcolor(navy) ///
			lwidth(medthick)) ///
		(scatter coef_order beta, ///
			msymbol(circle) ///
			msize(large) ///
			mcolor(maroon)), ///
		xline(0, ///
			lcolor(forest_green) ///
			lpattern(dash) ///
			lwidth(medthick)) ///
		ylabel(1 "High magnesium knowledge" ///
			   2 "Health-claims are important" ///
			   3 "Functional ingredient is important" ///
			   4 "Selected Lemon Lime flavor" ///
			   5 "Low-moderate sugar is important" ///
			   6 "High sweetness importance" ///
			   7 "Consumes after exercise" ///
			   8 "Consumes during exercise" ///
			   9 "Consumes before exercise" ///
			   10 "Three or more exercise days" ///
			   11 "Female", ///
			   angle(horizontal) labsize(small)) ///
		xlabel(-0.8(.2)0.8, labsize(medlarge)) ///
		ytitle("") ///
		xtitle("Coefficient on Product 584 information effect ($)", size(medlarge)) ///
		title("No H2 Predictors Significantly Explained Product 584 Information Effects", size(medsmall)) ///
		legend(off) ///
		graphregion(color(white)) ///
		plotregion(color(white)) ///
		xsize(9) ///
		ysize(5.5) ///
		name(g_product584_h2_coefficients, replace)

	graph export "${final_output}/graph_7_product584_h2_coefficients.png", replace width(2400)

restore