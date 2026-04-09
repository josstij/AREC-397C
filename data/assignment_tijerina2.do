* course: AREC 397C
* assignment: 1
* created on: 7 april 2026
* created by: jmt
* edited on: 9 april 2026
* edited by: jmt
* Stata v.19.5

* does
	
	
* needs
	* all
	
	clear				all
	
	cap log 		close
	log using		"$logs/assignment_tijerina2", append	
	set 			scheme s2color
	graph set 		window fontface "Arial"
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

* keep day 1 only
	keep if 				day == 2
	*** 73 observations deleted
	
	summarize					wtp_*
	lidjoidoimoied
* keep only the variables needed
	keep 					wtp_2b_584 wtp_3b_info_584 ///
							wtp_2b_793 wtp_3b_info_793 ///
							after_info_3b_d1_useful preknow_5_magn ///
							age gender income exercise con_freq
							
* Change in willingness to pay caused by magnesium information
	gen 					diff_584 = wtp_3b_info_584 - wtp_2b_584
	gen 					diff_793 = wtp_3b_info_793 - wtp_2b_793
	
**## 2.2 - create main WTP info
	* average WTP (after tasting and after info) 
	gen 					wtp_after_taste = (wtp_2b_584 + wtp_2b_793)/2
	gen 					wtp_after_info  = (wtp_3b_info_584 + wtp_3b_info_793)/2

	* Deviation from market price ($2.50)
	gen 					dev_584_taste = wtp_2b_584 - 2.5
	gen 					dev_584_info  = wtp_3b_info_584 - 2.5

	gen 					dev_793_taste = wtp_2b_793 - 2.5
	gen 					dev_793_info  = wtp_3b_info_793 - 2.5

	* Average deviation
	gen 					dev_avg_taste = wtp_after_taste - 2.5
	gen 					dev_avg_info  = wtp_after_info - 2.5
		*** Here is the change in willingness to pay caused by magnesium information
		
	label variable wtp_2b_584           "WTP 584 before magnesium info"
	label variable wtp_3b_info_584      "WTP 584 after magnesium info"
	label variable wtp_2b_793           "WTP 793 before magnesium info"
	label variable wtp_3b_info_793      "WTP 793 after magnesium info"

	label variable wtp_after_taste      "Average WTP before magnesium info"
	label variable wtp_after_info       "Average WTP after magnesium info"

	label variable dev_584_taste        "584 deviation from $2.50 before info"
	label variable dev_584_info         "584 deviation from $2.50 after info"
	label variable dev_793_taste        "793 deviation from $2.50 before info"
	label variable dev_793_info         "793 deviation from $2.50 after info"

	label variable diff_584             "Change in WTP for 584 after magnesium info"
	label variable diff_793             "Change in WTP for 793 after magnesium info"

	label variable after_info_3b_d1_useful "Magnesium information was useful"
	label variable preknow_5_magn          "Prior knowledge of magnesium benefits"
	label variable exercise                "Days of moderate/vigorous exercise"
	label variable con_freq                "Sports drink consumption frequency"

**********************************************************************
**# 3 - Descriptive statistics table
**********************************************************************
	summarize 				wtp_2b_584 wtp_3b_info_584 ///
							wtp_2b_793 wtp_3b_info_793 ///
							after_info_3b_d1_useful preknow_5_magn ///
							age exercise con_freq
	
/*

   
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  wtp_2b_584 |         34    2.617647     .761864        .75        4.5
wtp_3b_i~584 |         34    2.808824    .8002339          0        4.5
  wtp_2b_793 |         34    2.757353    .8083028       1.25        4.5
wtp_3b_i~793 |         34    2.470588    .8698761          0        4.5
after_info~l |         34    3.764706    1.207522          1          5
-------------+---------------------------------------------------------
preknow_5_~n |         70    3.571429    .9258201          1          5
         age |         70    25.67143    10.90801       18.5         55
    exercise |         70    2.814286    .8894365          1          4
    con_freq |         70    2.071429    1.171168          0          5

*/

	tabstat wtp_2b_584 wtp_3b_info_584 ///
        wtp_2b_793 wtp_3b_info_793 ///
        diff_584 diff_793 ///
        dev_avg_taste dev_avg_info ///
        after_info_3b_d1_useful preknow_5_magn ///
        age exercise con_freq, ///
        stats(mean sd min max n) columns(statistics)
/*

  
  Variable |      Mean        SD       Min       Max         N
-------------+--------------------------------------------------
  wtp_2b_584 |  2.617647   .761864       .75       4.5        34
wtp_3b_i~584 |  2.808824  .8002339         0       4.5        34
  wtp_2b_793 |  2.757353  .8083028      1.25       4.5        34
wtp_3b_i~793 |  2.470588  .8698761         0       4.5        34
    diff_584 |  .1911765  .4729774        -1      1.25        34
    diff_793 | -.2867647  .6517237      -2.5       .75        34
dev_avg_ta~e |     .1875  .6651854     -.875         2        34
dev_avg_info |  .1397059  .6431197      -1.5       1.5        34
after_info~l |  3.764706  1.207522         1         5        34
preknow_5_~n |  3.571429  .9258201         1         5        70
         age |  25.67143  10.90801      18.5        55        70
    exercise |  2.814286  .8894365         1         4        70
    con_freq |  2.071429  1.171168         0         5        70
----------------------------------------------------------------
					
*/

 * standard error 
	foreach var of varlist wtp_2b_584 wtp_3b_info_584 wtp_2b_793 wtp_3b_info_793 {
    summarize `var'
    display "`var' SE = " r(sd)/sqrt(r(N))
}

/*

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  wtp_2b_584 |         34    2.617647     .761864        .75        4.5
wtp_2b_584 SE = .13065859

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
wtp_3b_i~584 |         34    2.808824    .8002339          0        4.5
wtp_3b_info_584 SE = .13723899

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  wtp_2b_793 |         34    2.757353    .8083028       1.25        4.5
wtp_2b_793 SE = .13862278

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
wtp_3b_i~793 |         34    2.470588    .8698761          0        4.5
wtp_3b_info_793 SE = .14918253

*/

	
**********************************************************************
**# 4 - Summary checks for figure construction
**********************************************************************
	summarize				wtp_2b_584 wtp_3b_info_584
	
/*
   Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  wtp_2b_584 |         34    2.617647     .761864        .75        4.5
wtp_3b_i~584 |         34    2.808824    .8002339          0        4.5
*/

	summarize 				wtp_2b_793 wtp_3b_info_793
	
/*
	  Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  wtp_2b_793 |         34    2.757353    .8083028       1.25        4.5
wtp_3b_i~793 |         34    2.470588    .8698761          0        4.5
*/

	summarize 				diff_584 diff_793
	
/*

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
    diff_584 |         34    .1911765    .4729774         -1       1.25
    diff_793 |         34   -.2867647    .6517237       -2.5        .75

*/


**********************************************************************
**# 5 - Paired t-tests
**********************************************************************
	ttest					wtp_3b_info_584 == wtp_2b_584

/*
Paired t test
------------------------------------------------------------------------------
Variable |     Obs        Mean    Std. err.   Std. dev.   [95% conf. interval]
---------+--------------------------------------------------------------------
wtp_3b~4 |      34    2.808824     .137239    .8002339    2.529609    3.088038
wtp_2b~4 |      34    2.617647    .1306586     .761864     2.35182    2.883474
---------+--------------------------------------------------------------------
    diff |      34    .1911765     .081115    .4729774    .0261468    .3562061
------------------------------------------------------------------------------
     mean(diff) = mean(wtp_3b_info_584 - wtp_2b_584)              t =   2.3569
 H0: mean(diff) = 0                              Degrees of freedom =       33

 Ha: mean(diff) < 0           Ha: mean(diff) != 0           Ha: mean(diff) > 0
 Pr(T < t) = 0.9877         Pr(|T| > |t|) = 0.0245          Pr(T > t) = 0.0123
	*** Product 584: WTP increased significantly (p = 0.0245)
 
*/

	ttest 					wtp_3b_info_793 == wtp_2b_793

/*
Paired t test
------------------------------------------------------------------------------
Variable |     Obs        Mean    Std. err.   Std. dev.   [95% conf. interval]
---------+--------------------------------------------------------------------
wtp_3b~3 |      34    2.470588    .1491825    .8698761    2.167074    2.774102
wtp_2b~3 |      34    2.757353    .1386228    .8083028    2.475323    3.039383
---------+--------------------------------------------------------------------
    diff |      34   -.2867647    .1117697    .6517237   -.5141618   -.0593676
------------------------------------------------------------------------------
     mean(diff) = mean(wtp_3b_info_793 - wtp_2b_793)              t =  -2.5657
 H0: mean(diff) = 0                              Degrees of freedom =       33

 Ha: mean(diff) < 0           Ha: mean(diff) != 0           Ha: mean(diff) > 0
 Pr(T < t) = 0.0075         Pr(|T| > |t|) = 0.0150          Pr(T > t) = 0.9925

*/
	*** product 793: WTP decreased significantly (p = 0.0150)


**********************************************************************
**# 6 - Figures
**********************************************************************

**## 6.1 - Figure 1: WTP before vs after magnesium info
	graph 					bar (mean) wtp_2b_584 wtp_3b_info_584 ///
									wtp_2b_793 wtp_3b_info_793, ///
								bar(1, color(navy)) ///
								bar(2, color(eltblue)) ///
								bar(3, color(maroon)) ///
								bar(4, color(pink)) ///
								blabel(bar, format(%4.2f)) ///
								title("Figure 1: WTP Before and After Magnesium Information") ///
								ytitle("Willingness to Pay ($)") ///
								ylabel(0(1)5, grid) ///
								legend(label(1 "584 Before Info") ///
									   label(2 "584 After Info") ///
									   label(3 "793 Before Info") ///
									   label(4 "793 After Info")) ///
								graphregion(color(white))
								
	graph export 				"$logs/figure1.png", replace width(2000)
	
**## 6.2 - Figure 2: Deviation from baseline price ($2.50)
	graph 					bar (mean) dev_584_taste dev_584_info ///
									dev_793_taste dev_793_info, ///
								bar(1, color(forest_green)) ///
								bar(2, color(lime)) ///
								bar(3, color(orange_red)) ///
								bar(4, color(gs10)) ///
								blabel(bar, format(%4.2f)) ///
								title("Figure 2: Deviation from Baseline Price ($2.50)") ///
								ytitle("Deviation from $2.50 ($)") ///
								yline(0, lcolor(black) lpattern(dash)) ///
								ylabel(-1(0.5)2, grid) ///
								legend(label(1 "584 Before Info") ///
									   label(2 "584 After Info") ///
									   label(3 "793 Before Info") ///
									   label(4 "793 After Info")) ///
								graphregion(color(white))
	
	graph export 			"$logs/figure2.png", replace width(2000)
								
**## 6.3 - Figure 3: Change in WTP after magnesium information
	graph 					bar (mean) diff_584 diff_793, ///
								bar(1, color(navy)) ///
								bar(2, color(maroon)) ///
								blabel(bar, format(%4.2f)) ///
								title("Figure 3: Change in WTP After Magnesium Information") ///
								ytitle("Change in WTP ($)") ///
								yline(0, lcolor(black) lpattern(dash)) ///
								ylabel(-1(0.5)1.5, grid) ///
								legend(label(1 "584 (Magnesium)") ///
								   label(2 "793 (No Magnesium)")) ///
								graphregion(color(white))

	graph export 			"$logs/figure3.png", replace width(2000)
	
**## 6.4 - Figure 4: Change in WTP for magnesium product by gender
	tab 						gender
	capture label 				define genderlbl 1 "Male" 2 "Female" 3 "Other / Prefer not to say"
	capture label 				values gender genderlbl

	graph 					bar (mean) diff_584, over(gender) ///
								bar(1, color(teal)) ///
								blabel(bar, format(%4.2f)) ///
								title("Figure 4: Change in WTP by Gender", size(medsmall)) ///
								subtitle("Magnesium product (584)", size(small)) ///
								ytitle("Change in WTP ($)") ///
								yline(0, lcolor(black) lpattern(dash)) ///
								ylabel(-1(0.5)1.5, grid) ///
								graphregion(color(white))
	
	graph export 			"$logs/figure4.png", replace width(2000)


**********************************************************************
**# 7 - close log
**********************************************************************
	log 					close




	
	
	