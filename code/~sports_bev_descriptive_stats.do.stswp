* course: AREC 397C
* assignment: 1
* created on: 26 mar 2026
* created by: jmt
* edited on: 18 apr 2026
* edited by: tml
* Stata v.19.5

* does
	
	
* needs
	* all
	
	clear				all
	
	cap log 		close
	log using		"$logs/\assignment_leavy.smcl", append	
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
**# 1 Importing the data
**********************************************************************
* needs
	* all
	
	clear				all
	
	cap log 		close
	log using		"$logs/assignment_leavy.smcl", append	
************************************************************ Import the data
* import data from CSV

	import delimited		using "$data/spors_bev_data_use_me.csv"
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
	
***********************************************************************
**# hypotheses (original)
***********************************************************************	
	
*** first we need to determine what vars should be inspected based on 
*the hypotheses

*** Hypotheses 1:
* This one primarily concerns magnesium and flavor
*********
/* NULL HYPOTHESIS
After controlling for sugar
level, consumer choices, purchase likelihood, and WTP are driven primarily by flavor liking and perceived sweetness. 
Magnesium information and higher magnesium content in the lab-produced
beverage do not meaningfully change the probability that a participant 
would choose the lab beverage over the competitor or the WTP for it.
*********
ALT HYPOTHESIS 
Alternatively, we can state that magnesium functionality
information and higher magnesium content increase the probability 
that the lab-produced beverage is chosen and raise WTP and 
purchase likelihood for it, while flavor liking and perceived sweetness remain
important but not exclusively dominant drivers of choice.
*/

**## Restricted Hypotheses
/*
Null: Differences in WTP are not meaningfully driven by magnesium information 
or magnesium content; instead, WTP is primarily associated with flavor liking.
Alternative: Magnesium information and/or magnesium content increase WTP, 
even when flavor liking remains important.
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
	
* 584 overall flavor liking 	
* sensory_584_flavor
	label var			sensory_584_flavor "584 flavor liking"
	label values		sensory_584_flavor hedonic9_lbl
	tab					sensory_584_flavor, missing	

* 793 overall flavor liking 
* sensory_793_flavor
	label var			sensory_793_flavor "793 flavor liking"
	label values		sensory_793_flavor hedonic9_lbl
	tab					sensory_793_flavor, missing
	
* 356 overall flavor liking 
* sensory_356_flavor
	label var			sensory_356_flavor "356 flavor liking"
	label values		sensory_356_flavor hedonic9_lbl
	tab					sensory_356_flavor, missing
	
* 831 overall flavor liking 
* sensory_831_flavor
	label var			sensory_831_flavor "831 flavor liking"
	label values		sensory_831_flavor hedonic9_lbl
	tab					sensory_831_flavor, missing

	
**## WTP	
	
* baseline wtp_1
	capture destring	wtp_1, replace
	label var			wtp_1 "Baseline willingness to pay"	

* WTP variables

* Taste-first
	capture destring    wtp_2b_584, replace
	label var           wtp_2b_584 "WTP for 584, tasting first"
	sum                 wtp_2b_584, detail
	
	capture destring    wtp_2b_793, replace
	label var           wtp_2b_793 "WTP for 793, tasting first"
	sum                 wtp_2b_793, detail
	
	capture destring    wtp_2b_356, replace
	label var           wtp_2b_356 "WTP for 356, tasting first"
	sum                 wtp_2b_356, detail
	
	capture destring    wtp_2b_831, replace
	label var           wtp_2b_831 "WTP for 831, tasting first"
	sum                 wtp_2b_831, detail
	
	
* After information, tasting first
	capture destring    wtp_3b_info_584, replace
	label var           wtp_3b_info_584 "WTP for 584 after information, tasting first"
	sum                 wtp_3b_info_584, detail

	capture destring    wtp_3b_info_793, replace
	label var           wtp_3b_info_793 "WTP for 793 after information, tasting first"
	sum                 wtp_3b_info_793, detail
	
	capture destring    wtp_3b_info_356, replace
	label var           wtp_3b_info_356 "WTP for 356 after information, tasting first"
	sum                 wtp_3b_info_356, detail
	
	capture destring    wtp_3b_info_831, replace
	label var           wtp_3b_info_831 "WTP for 831 after information, tasting first"
	sum                 wtp_3b_info_831, detail
	
	
* Information-first
	capture destring    wtp_2a_info_584, replace
	label var           wtp_2a_info_584 "WTP for 584, information first"
	sum                 wtp_2a_info_584, detail
	
	capture destring    wtp_2a_info_793, replace
	label var           wtp_2a_info_793 "WTP for 793, information first"
	sum                 wtp_2a_info_793, detail
	
	capture destring    wtp_2a_info_356, replace
	label var           wtp_2a_info_356 "WTP for 356, information first"
	sum                 wtp_2a_info_356, detail
	
	capture destring    wtp_2a_info_831, replace
	label var           wtp_2a_info_831 "WTP for 831, information first"
	sum                 wtp_2a_info_831, detail
	
	
* After tasting, information first
	capture destring    wtp_3a_584, replace
	label var           wtp_3a_584 "WTP for 584 after tasting, information first"
	sum                 wtp_3a_584, detail

	capture destring    wtp_3a_793, replace
	label var           wtp_3a_793 "WTP for 793 after tasting, information first"
	sum                 wtp_3a_793, detail

	capture destring    wtp_3a_356, replace
	label var           wtp_3a_356 "WTP for 356 after tasting, information first"
	sum                 wtp_3a_356, detail
	
	capture destring    wtp_3a_831, replace
	label var           wtp_3a_831 "WTP for 831 after tasting, information first"
	sum                 wtp_3a_831, detail


********************************************************************************
**# Restricted Summary Stats	
********************************************************************************

* print a new summary stats table with only these vars

	local			hyp1_vars ///
						wtp_1 ///
						wtp_2b_584 wtp_2b_793 wtp_2b_356 wtp_2b_831 ///
						wtp_3b_info_584 wtp_3b_info_793 wtp_3b_info_356 wtp_3b_info_831 ///
						wtp_2a_info_584 wtp_2a_info_793 wtp_2a_info_356 wtp_2a_info_831 ///
						wtp_3a_584 wtp_3a_793 wtp_3a_356 wtp_3a_831 ///
						sensory_584_flavor sensory_793_flavor sensory_356_flavor sensory_831_flavor

	estpost 		summarize `hyp1_vars'
	esttab 			using "$data/hyp1_summary_stats.csv", ///
						cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3))") ///
						label noobs nonumber nomtitle plain replace csv
						
********************************************************************************
**# hyp testing
********************************************************************************

