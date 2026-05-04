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

	
********************************************************************************
**### Info Effect
********************************************************************************

* Testing whether the difference is different from zero
	
* Info eff 584
	ttest			info_eff_584 == 0 if day == 1
	
*Info eff  793
	ttest 			info_eff_793 == 0 if day == 1
	
* Info eff 356
	ttest			info_eff_356 == 0 if day == 2
		
* Info eff 831
	ttest			info_eff_831 == 0 if day == 2
	
	
********************************************************************************
**### Tasting Effect
********************************************************************************

* Testing whether the differnce is differnt from zero

* Tasting eff 584 
	ttest				taste_eff_584 == 0 if day == 1

* Tasting eff 793
* Test whether the tasting effect differs from zero.
	ttest				taste_eff_793 == 0 if day == 1

* Tasting eff  356
* Test whether the tasting effect differs from zero.
	ttest				taste_eff_356 == 0 if day == 2

* Tasting eff 831
* Test whether the tasting effect differs from zero.
	ttest				taste_eff_831 == 0 if day == 2
	
	
********************************************************************************
**# Export one-sample t-tests to CSV
********************************************************************************

capture program drop post_one_sample_ttest

program define post_one_sample_ttest
	syntax varname [if], Null(real) Test(string) Group(string) Handle(name)

	quietly ttest		`varlist' == `null' `if'

	local N				= r(N_1)
	local mean			= r(mu_1)
	local sd			= r(sd_1)
	local se			= r(se)
	local diff			= r(mu_1) - `null'
	local tstat			= r(t)
	local df			= r(df_t)
	local pval			= r(p)

* confidence interval for the difference from the null value
	local tcrit			= invttail(`df', .025)
	local ci_low		= `diff' - `tcrit' * `se'
	local ci_high		= `diff' + `tcrit' * `se'

	post `handle'		("`group'") ///
						("`test'") ///
						("`varlist'") ///
						(`null') ///
						(`N') ///
						(`mean') ///
						(`diff') ///
						(`sd') ///
						(`se') ///
						(`tstat') ///
						(`df') ///
						(`pval') ///
						(`ci_low') ///
						(`ci_high')
end


********************************************************************************
**## Run t-tests and export results
********************************************************************************

preserve

	tempfile ttest_results
	postutil clear

	postfile ttest_post ///
		str30 group ///
		str60 test ///
		str25 variable ///
		double null_value ///
		double N ///
		double mean ///
		double diff_from_null ///
		double sd ///
		double se ///
		double t_stat ///
		double df ///
		double p_value ///
		double ci_low_diff ///
		double ci_high_diff ///
		using "`ttest_results'", replace


********************************************************************************
**## Baseline WTP
********************************************************************************

	post_one_sample_ttest	wtp_1, ///
								null(2.50) ///
								test("Baseline WTP: full sample") ///
								group("Baseline WTP") ///
								handle(ttest_post)

	post_one_sample_ttest	wtp_1 if day == 1, ///
								null(2.50) ///
								test("Baseline WTP: Day 1") ///
								group("Baseline WTP") ///
								handle(ttest_post)

	post_one_sample_ttest	wtp_1 if day == 2, ///
								null(2.50) ///
								test("Baseline WTP: Day 2") ///
								group("Baseline WTP") ///
								handle(ttest_post)


********************************************************************************
**## Information effects
********************************************************************************

	post_one_sample_ttest	info_eff_584 if day == 1, ///
								null(0) ///
								test("Information effect: Day 1 Product 584") ///
								group("Information Effects") ///
								handle(ttest_post)

	post_one_sample_ttest	info_eff_793 if day == 1, ///
								null(0) ///
								test("Information effect: Day 1 Product 793") ///
								group("Information Effects") ///
								handle(ttest_post)

	post_one_sample_ttest	info_eff_356 if day == 2, ///
								null(0) ///
								test("Information effect: Day 2 Product 356") ///
								group("Information Effects") ///
								handle(ttest_post)

	post_one_sample_ttest	info_eff_831 if day == 2, ///
								null(0) ///
								test("Information effect: Day 2 Product 831") ///
								group("Information Effects") ///
								handle(ttest_post)


********************************************************************************
**## Tasting effects
********************************************************************************

	post_one_sample_ttest	taste_eff_584 if day == 1, ///
								null(0) ///
								test("Tasting effect: Day 1 Product 584") ///
								group("Tasting Effects") ///
								handle(ttest_post)

	post_one_sample_ttest	taste_eff_793 if day == 1, ///
								null(0) ///
								test("Tasting effect: Day 1 Product 793") ///
								group("Tasting Effects") ///
								handle(ttest_post)

	post_one_sample_ttest	taste_eff_356 if day == 2, ///
								null(0) ///
								test("Tasting effect: Day 2 Product 356") ///
								group("Tasting Effects") ///
								handle(ttest_post)

	post_one_sample_ttest	taste_eff_831 if day == 2, ///
								null(0) ///
								test("Tasting effect: Day 2 Product 831") ///
								group("Tasting Effects") ///
								handle(ttest_post)


********************************************************************************
**## Export t-test results
********************************************************************************

	postclose			ttest_post

	use					"`ttest_results'", clear

	format				mean diff_from_null sd se t_stat p_value ///
							ci_low_diff ci_high_diff %9.4f

	export delimited	using "$final_output/ttest_results.csv", replace

restore	
	
	
********************************************************************************
**# gender / exercise ttests
********************************************************************************

**### info eff 584
ttest				info_eff_584 if day == 1, by(gender) unequal
ttest				info_eff_584 if day == 1, by(active_3plus) unequal

**### info eff 793
ttest 				info_eff_793 if day == 1, by(gender) unequal
ttest 				info_eff_793 if day == 1, by(active_3plus) unequal

**### info eff 356
ttest 				info_eff_356 if day == 2, by(gender) unequal
ttest 				info_eff_356 if day == 2, by(active_3plus) unequal

**### info eff 831
ttest 				info_eff_831 if day == 2, by(gender) unequal
ttest 				info_eff_831 if day == 2, by(active_3plus) unequal


********************************************************************************
**# Export H2 information-effect t-tests to CSV
********************************************************************************

capture program drop post_twosample_ttest

program define post_twosample_ttest
	syntax varname [if], By(varname) Test(string) Group1(string) Group2(string) Handle(name)

	quietly ttest		`varlist' `if', by(`by') unequal

	local N1			= r(N_1)
	local N2			= r(N_2)
	local mean1			= r(mu_1)
	local mean2			= r(mu_2)
	local sd1			= r(sd_1)
	local sd2			= r(sd_2)
	local diff			= r(mu_1) - r(mu_2)
	local se			= r(se)
	local tstat			= r(t)
	local df			= r(df_t)
	local p_two			= r(p)

* confidence interval for group 1 minus group 2
	local tcrit			= invttail(`df', .025)
	local ci_low		= `diff' - `tcrit' * `se'
	local ci_high		= `diff' + `tcrit' * `se'

	post `handle'		("`test'") ///
						("`varlist'") ///
						("`by'") ///
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
						(`tstat') ///
						(`df') ///
						(`p_two') ///
						(`ci_low') ///
						(`ci_high')
end


********************************************************************************
**## Run H2 information-effect t-tests and export results
********************************************************************************

preserve

	tempfile h2_info_ttest_results
	postutil clear

	postfile h2_info_ttest_post ///
		str80 test ///
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
		double p_value_two_tailed ///
		double ci_low ///
		double ci_high ///
		using "`h2_info_ttest_results'", replace


********************************************************************************
**## H2: Information effects by gender
********************************************************************************

* Difference is Male minus Female.

	post_twosample_ttest	info_eff_584 if day == 1, ///
								by(gender) ///
								test("Information effect: Day 1 Product 584 by gender") ///
								group1("Male") ///
								group2("Female") ///
								handle(h2_info_ttest_post)

	post_twosample_ttest	info_eff_793 if day == 1, ///
								by(gender) ///
								test("Information effect: Day 1 Product 793 by gender") ///
								group1("Male") ///
								group2("Female") ///
								handle(h2_info_ttest_post)

	post_twosample_ttest	info_eff_356 if day == 2, ///
								by(gender) ///
								test("Information effect: Day 2 Product 356 by gender") ///
								group1("Male") ///
								group2("Female") ///
								handle(h2_info_ttest_post)

	post_twosample_ttest	info_eff_831 if day == 2, ///
								by(gender) ///
								test("Information effect: Day 2 Product 831 by gender") ///
								group1("Male") ///
								group2("Female") ///
								handle(h2_info_ttest_post)


********************************************************************************
**## H2: Information effects by physical activity
********************************************************************************

* Difference is fewer than 3 days per week minus 3 or more days per week.

	post_twosample_ttest	info_eff_584 if day == 1, ///
								by(active_3plus) ///
								test("Information effect: Day 1 Product 584 by physical activity") ///
								group1("Fewer than 3 days per week") ///
								group2("3 or more days per week") ///
								handle(h2_info_ttest_post)

	post_twosample_ttest	info_eff_793 if day == 1, ///
								by(active_3plus) ///
								test("Information effect: Day 1 Product 793 by physical activity") ///
								group1("Fewer than 3 days per week") ///
								group2("3 or more days per week") ///
								handle(h2_info_ttest_post)

	post_twosample_ttest	info_eff_356 if day == 2, ///
								by(active_3plus) ///
								test("Information effect: Day 2 Product 356 by physical activity") ///
								group1("Fewer than 3 days per week") ///
								group2("3 or more days per week") ///
								handle(h2_info_ttest_post)

	post_twosample_ttest	info_eff_831 if day == 2, ///
								by(active_3plus) ///
								test("Information effect: Day 2 Product 831 by physical activity") ///
								group1("Fewer than 3 days per week") ///
								group2("3 or more days per week") ///
								handle(h2_info_ttest_post)


********************************************************************************
**## Export H2 information-effect t-test results
********************************************************************************

	postclose			h2_info_ttest_post

	use					"`h2_info_ttest_results'", clear

	format				mean_1 mean_2 diff_1_minus_2 sd_1 sd_2 ///
							se_diff t_stat p_value_two_tailed ///
							ci_low ci_high %9.4f

	export delimited	using "$final_output/h2_info_ttest_results.csv", replace

restore



********************************************************************************
**## H1 regressions
********************************************************************************

********************************************************************************
**### Information effects
********************************************************************************

* Product 584: magnesium/lab beverage, Day 1.
	reg					info_eff_584 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

* Product 793: competitor beverage, Day 1.
	reg					info_eff_793 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

* Product 356: blueberry beverage, Day 2.
	reg					info_eff_356 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_1 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust

* Product 831: pineapple beverage, Day 2.
	reg					info_eff_831 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_7 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust
							
							tab 		flavor_pref1_5

********************************************************************************
**## Tasting effects
********************************************************************************

* Product 584: magnesium/lab beverage, Day 1.
	reg					taste_eff_584 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

* Product 793: competitor beverage, Day 1.
	reg					taste_eff_793 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_5 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 1, robust

* Product 356: blueberry beverage, Day 2.
	reg					taste_eff_356 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_1 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust
							
						

* Product 831: pineapple beverage, Day 2.
	reg					taste_eff_831 ///
							i.sweet_high ///
							i.sugar_lowmod_high ///
							i.flavor_pref1_7 ///
							i.ingred_high ///
							i.health_high ///
							i.magn_know_high ///
							if day == 2, robust

********************************************************************************
**# H2 regressions
********************************************************************************

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




********************************************************************************
**# H2 regressions with consumption situation and gender-exercise interaction
********************************************************************************

eststo clear


********************************************************************************
**## Product 584: magnesium/lab beverage
********************************************************************************

* Main H2 model: information effect for the magnesium/lab beverage.
* Gender is interacted with exercise frequency.
* Consumption situation controls indicate whether respondents usually drink
* sports beverages before, during, or after exercise.

eststo h2_info_584: ///
	reg					info_eff_584 ///
							i.gender##c.exercise ///
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


********************************************************************************
**## Product 793: competitor beverage
********************************************************************************

* Supporting comparison model: information effect for the Day 1 competitor.

eststo h2_info_793: ///
	reg					info_eff_793 ///
							i.gender##c.exercise ///
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


********************************************************************************
**## Product 356: blueberry beverage
********************************************************************************

* Supporting comparison model: information effect for the Day 2 blueberry beverage.

eststo h2_info_356: ///
	reg					info_eff_356 ///
							i.gender##c.exercise ///
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


********************************************************************************
**## Product 831: pineapple beverage
********************************************************************************

* Supporting comparison model: information effect for the Day 2 pineapple beverage.

eststo h2_info_831: ///
	reg					info_eff_831 ///
							i.gender##c.exercise ///
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


esttab h2_info_584 h2_info_793 h2_info_356 h2_info_831 ///
	using "$final_output/h2_info_regressions_consumption_gender_exercise.csv", ///
	replace ///
	csv ///
	b(%9.4f) ///
	se(%9.4f) ///
	r2 ///
	ar2 ///
	label ///
	title("H2 Information-Effect Regressions with Consumption Situation and Gender-Exercise Interaction")