* course: AREC 397C
* assignment: 1
* created on: 7 april 2026
* created by: jmt
* edited on: 20 april 2026
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
**# 1.1 - Load data
**********************************************************************
* import data from CSV
	import delimited		using "$data/spors_bev_data_use_me.csv", clear
	describe

**## 1.2 - drop unfinished responses
	drop 					if finished != 1

**## 1.3 - adjust display settings	
	set						linesize 200 
	
**## 1.4 - replace specific -999 missing codes 
	foreach	var 			of varlist age edu income { 
								replace `var' = . if `var' == -999
	}
		*** 26 changes made to income
	
**## 1.5 - inspect day variable
	tab						day
	
/*
    Day |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |         70       48.95       48.95
          2 |         73       51.05      100.00
------------+-----------------------------------
      Total |        143      100.00

*/


**********************************************************************
**# 2 - Generate variables and clean
**********************************************************************
**## 2.1 - inspect WTP variables
	describe				wtp_*
	*** all WTP variables are aready numeric (float)

	
* keep only the variables needed
	keep 					wtp_2b_584 wtp_3b_info_584 ///
							wtp_2b_793 wtp_3b_info_793 ///
							wtp_2b_356 wtp_3b_info_356 ///
							wtp_2b_831 wtp_3b_info_831 ///
							preknow_5_magn day ///
							age gender income exercise con_freq
							
* Change in willingness to pay caused after magnesium information
	gen 					diff_584 = wtp_3b_info_584 - wtp_2b_584
	gen 					diff_793 = wtp_3b_info_793 - wtp_2b_793
	gen						diff_356 = wtp_3b_info_356 - wtp_2b_356
	gen						diff_831 = wtp_3b_info_831 - wtp_2b_831
	
**## 2.2 - create deviation from market price ($2.50)
* 584
	gen 					dev_584_taste = wtp_2b_584 - 2.5
	gen 					dev_584_info  = wtp_3b_info_584 - 2.5
	
* 793
	gen 					dev_793_taste = wtp_2b_793 - 2.5
	gen 					dev_793_info  = wtp_3b_info_793 - 2.5

* 356
	gen 					dev_356_taste = wtp_2b_356 - 2.5
	gen						dev_356_info = wtp_3b_info_356 - 2.5
	
* 831
	gen 					dev_831_taste = wtp_2b_831 - 2.5
	gen						dev_831_info = wtp_3b_info_831 - 2.5
	
**## 2.4 - label variables	
	label variable day                  "Survey day"

	label variable wtp_2b_584           "WTP 584 before magnesium info"
	label variable wtp_3b_info_584      "WTP 584 after magnesium info"
	label variable wtp_2b_793           "WTP 793 before magnesium info"
	label variable wtp_3b_info_793      "WTP 793 after magnesium info"

	label variable wtp_2b_356           "WTP 356 before magnesium info"
	label variable wtp_3b_info_356      "WTP 356 after magnesium info"
	label variable wtp_2b_831           "WTP 831 before magnesium info"
	label variable wtp_3b_info_831      "WTP 831 after magnesium info"

	label variable diff_584             "Change in WTP for 584 after magnesium info"
	label variable diff_793             "Change in WTP for 793 after magnesium info"
	label variable diff_356             "Change in WTP for 356 after magnesium info"
	label variable diff_831             "Change in WTP for 831 after magnesium info"

	label variable dev_584_taste        "584 deviation from $2.50 before info"
	label variable dev_584_info         "584 deviation from $2.50 after info"
	label variable dev_793_taste        "793 deviation from $2.50 before info"
	label variable dev_793_info         "793 deviation from $2.50 after info"

	label variable dev_356_taste        "356 deviation from $2.50 before info"
	label variable dev_356_info         "356 deviation from $2.50 after info"
	label variable dev_831_taste        "831 deviation from $2.50 before info"
	label variable dev_831_info         "831 deviation from $2.50 after info"

	label variable preknow_5_magn       "Prior knowledge of magnesium benefits"
	label variable exercise             "Days of moderate/vigorous exercise"
	label variable con_freq             "Sports drink consumption frequency"

**********************************************************************
**# 3 - Descriptive statistics table
**********************************************************************
	summarize 				wtp_2b_584 wtp_3b_info_584 ///
							wtp_2b_793 wtp_3b_info_793 ///
							wtp_2b_356 wtp_3b_info_356 ///
							wtp_2b_831 wtp_3b_info_831 ///
							preknow_5_magn ///
							age exercise con_freq
							
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  wtp_2b_584 |         34    2.617647     .761864        .75        4.5
wtp_3b_i~584 |         34    2.808824    .8002339          0        4.5
  wtp_2b_793 |         34    2.757353    .8083028       1.25        4.5
wtp_3b_i~793 |         34    2.470588    .8698761          0        4.5
  wtp_2b_356 |         38    2.776316    .8458753          0        4.5
-------------+---------------------------------------------------------
wtp_3b_i~356 |         38    3.006579    .8805075          0        4.5
  wtp_2b_831 |         38    2.552632    .7378701          0          4
wtp_3b_i~831 |         38    2.789474    .8728764          0       4.75
preknow_5_~n |        143    3.692308    .9437024          1          5
         age |        143    25.08392    10.02988       18.5         55
-------------+---------------------------------------------------------
    exercise |        143     2.79021     .878965          1          4
    con_freq |        143    2.160839    1.214063          0          5
*/

	tabstat 				wtp_2b_584 wtp_3b_info_584 ///
							wtp_2b_793 wtp_3b_info_793 ///
							wtp_2b_356 wtp_3b_info_356 ///
							wtp_2b_831 wtp_3b_info_831 ///
							diff_584 diff_793 diff_356 diff_831 ///
							preknow_5_magn ///
							age exercise con_freq, ///
							stats(mean sd min max n) columns(statistics)
							
/*
    Variable |      Mean        SD       Min       Max         N
-------------+--------------------------------------------------
  wtp_2b_584 |  2.617647   .761864       .75       4.5        34
wtp_3b_i~584 |  2.808824  .8002339         0       4.5        34
  wtp_2b_793 |  2.757353  .8083028      1.25       4.5        34
wtp_3b_i~793 |  2.470588  .8698761         0       4.5        34
  wtp_2b_356 |  2.776316  .8458753         0       4.5        38
wtp_3b_i~356 |  3.006579  .8805075         0       4.5        38
  wtp_2b_831 |  2.552632  .7378701         0         4        38
wtp_3b_i~831 |  2.789474  .8728764         0      4.75        38
    diff_584 |  .1911765  .4729774        -1      1.25        34
    diff_793 | -.2867647  .6517237      -2.5       .75        34
    diff_356 |  .2302632  .4206718       -.5       1.5        38
    diff_831 |  .2368421  .4148729         0      1.75        38
preknow_5_~n |  3.692308  .9437024         1         5       143
         age |  25.08392  10.02988      18.5        55       143
    exercise |   2.79021   .878965         1         4       143
    con_freq |  2.160839  1.214063         0         5       143
----------------------------------------------------------------	
*/

* standard error 
	foreach var 			of varlist wtp_2b_584 wtp_3b_info_584 ///
							wtp_2b_793 wtp_3b_info_793 ///
							wtp_2b_356 wtp_3b_info_356 ///
							wtp_2b_831 wtp_3b_info_831 {

	summarize 				`var'
	display 				"`var' SE = " r(sd)/sqrt(r(N))
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

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  wtp_2b_356 |         38    2.776316    .8458753          0        4.5
wtp_2b_356 SE = .13721909

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
wtp_3b_i~356 |         38    3.006579    .8805075          0        4.5
wtp_3b_info_356 SE = .14283717

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  wtp_2b_831 |         38    2.552632    .7378701          0          4
wtp_2b_831 SE = .11969834

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
wtp_3b_i~831 |         38    2.789474    .8728764          0       4.75
wtp_3b_info_831 SE = .14159925
*/


**********************************************************************
**# 4 - Paired t-tests
**********************************************************************
**## 4.1 - Day 1 magnesium product (584)
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

**## 4.2 - Day 1 non-magnesium product (793)
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

**## 4.3 - Day 2 magnesium product (356)
	ttest					wtp_3b_info_356 == wtp_2b_356

/*
Paired t test
------------------------------------------------------------------------------
Variable |     Obs        Mean    Std. err.   Std. dev.   [95% conf. interval]
---------+--------------------------------------------------------------------
wtp_3b~6 |      38    3.006579    .1428372    .8805075    2.717163    3.295995
wtp_2b~6 |      38    2.776316    .1372191    .8458753    2.498284    3.054348
---------+--------------------------------------------------------------------
    diff |      38    .2302632     .068242    .4206718    .0919918    .3685345
------------------------------------------------------------------------------
     mean(diff) = mean(wtp_3b_info_356 - wtp_2b_356)              t =   3.3742
 H0: mean(diff) = 0                              Degrees of freedom =       37

 Ha: mean(diff) < 0           Ha: mean(diff) != 0           Ha: mean(diff) > 0
 Pr(T < t) = 0.9991         Pr(|T| > |t|) = 0.0017          Pr(T > t) = 0.0009
*/
	*** product 356: WTP increases significantly (p = 0.0017)
	
**## 4.4 - Day 2 magnesium product (831)
	ttest					wtp_3b_info_831 == wtp_2b_831
	
/*
Paired t test
------------------------------------------------------------------------------
Variable |     Obs        Mean    Std. err.   Std. dev.   [95% conf. interval]
---------+--------------------------------------------------------------------
wtp_3b~1 |      38    2.789474    .1415993    .8728764    2.502566    3.076381
wtp_2b~1 |      38    2.552632    .1196983    .7378701      2.3101    2.795163
---------+--------------------------------------------------------------------
    diff |      38    .2368421    .0673013    .4148729    .1004768    .3732074
------------------------------------------------------------------------------
     mean(diff) = mean(wtp_3b_info_831 - wtp_2b_831)              t =   3.5191
 H0: mean(diff) = 0                              Degrees of freedom =       37

 Ha: mean(diff) < 0           Ha: mean(diff) != 0           Ha: mean(diff) > 0
 Pr(T < t) = 0.9994         Pr(|T| > |t|) = 0.0012          Pr(T > t) = 0.0006
*/
	*** product 831: WTP increases significantly (p = 0.0012)
	
**## 4.5 - magnesium vs non-magnesium effect (Day 1)
	ttest					diff_584 == diff_793
	
/*
Paired t test
------------------------------------------------------------------------------
Variable |     Obs        Mean    Std. err.   Std. dev.   [95% conf. interval]
---------+--------------------------------------------------------------------
diff_584 |      34    .1911765     .081115    .4729774    .0261468    .3562061
diff_793 |      34   -.2867647    .1117697    .6517237   -.5141618   -.0593676
---------+--------------------------------------------------------------------
    diff |      34    .4779412    .1294302    .7547015    .2146134     .741269
------------------------------------------------------------------------------
     mean(diff) = mean(diff_584 - diff_793)                       t =   3.6927
 H0: mean(diff) = 0                              Degrees of freedom =       33

 Ha: mean(diff) < 0           Ha: mean(diff) != 0           Ha: mean(diff) > 0
 Pr(T < t) = 0.9996         Pr(|T| > |t|) = 0.0008          Pr(T > t) = 0.0004
*/

	
**********************************************************************
**# 5 - One-sample t-tests (benchmark price = $2.50)
**********************************************************************
**## 5.1 - Day 1 magnesium product (584)
	ttest					wtp_3b_info_584 == 2.5
	
/*
One-sample t test
------------------------------------------------------------------------------
Variable |     Obs        Mean    Std. err.   Std. dev.   [95% conf. interval]
---------+--------------------------------------------------------------------
wtp_3b~4 |      34    2.808824     .137239    .8002339    2.529609    3.088038
------------------------------------------------------------------------------
    mean = mean(wtp_3b_info_584)                                  t =   2.2503
H0: mean = 2.5                                   Degrees of freedom =       33

   Ha: mean < 2.5               Ha: mean != 2.5               Ha: mean > 2.5
 Pr(T < t) = 0.9844         Pr(|T| > |t|) = 0.0312          Pr(T > t) = 0.0156
*/

**## 5.2 - Day 1 non-magnesium product (793)
	ttest					wtp_3b_info_793 == 2.5
	
/*
One-sample t test
------------------------------------------------------------------------------
Variable |     Obs        Mean    Std. err.   Std. dev.   [95% conf. interval]
---------+--------------------------------------------------------------------
wtp_3b~3 |      34    2.470588    .1491825    .8698761    2.167074    2.774102
------------------------------------------------------------------------------
    mean = mean(wtp_3b_info_793)                                  t =  -0.1972
H0: mean = 2.5                                   Degrees of freedom =       33

   Ha: mean < 2.5               Ha: mean != 2.5               Ha: mean > 2.5
 Pr(T < t) = 0.4225         Pr(|T| > |t|) = 0.8449          Pr(T > t) = 0.5775
*/

**## 5.3 - Day 2 magnesium product (356)
	ttest					wtp_3b_info_356 == 2.5
	
/*
One-sample t test
------------------------------------------------------------------------------
Variable |     Obs        Mean    Std. err.   Std. dev.   [95% conf. interval]
---------+--------------------------------------------------------------------
wtp_3b~6 |      38    3.006579    .1428372    .8805075    2.717163    3.295995
------------------------------------------------------------------------------
    mean = mean(wtp_3b_info_356)                                  t =   3.5465
H0: mean = 2.5                                   Degrees of freedom =       37

   Ha: mean < 2.5               Ha: mean != 2.5               Ha: mean > 2.5
 Pr(T < t) = 0.9995         Pr(|T| > |t|) = 0.0011          Pr(T > t) = 0.0005
*/

**## 5.4 - Day 2 magnesium product (831)
	ttest					wtp_3b_info_831 == 2.5
	
/*
One-sample t test
------------------------------------------------------------------------------
Variable |     Obs        Mean    Std. err.   Std. dev.   [95% conf. interval]
---------+--------------------------------------------------------------------
wtp_3b~1 |      38    2.789474    .1415993    .8728764    2.502566    3.076381
------------------------------------------------------------------------------
    mean = mean(wtp_3b_info_831)                                  t =   2.0443
H0: mean = 2.5                                   Degrees of freedom =       37

   Ha: mean < 2.5               Ha: mean != 2.5               Ha: mean > 2.5
 Pr(T < t) = 0.9760         Pr(|T| > |t|) = 0.0481          Pr(T > t) = 0.0240
*/


**********************************************************************
**# 6 - Coefficient of variation (CV)
**********************************************************************
* CV = sd / mean

	foreach var of varlist	wtp_2b_584 wtp_3b_info_584 ///
							wtp_2b_793 wtp_3b_info_793 ///
							wtp_2b_356 wtp_3b_info_356 ///
							wtp_2b_831 wtp_3b_info_831 {
								
	summarize `var'
	display	"`var' CV = " r(sd)/r(mean)
							}
							
/*
   Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  wtp_2b_584 |         34    2.617647     .761864        .75        4.5
wtp_2b_584 CV = .29104916

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
wtp_3b_i~584 |         34    2.808824    .8002339          0        4.5
wtp_3b_info_584 CV = .28490004

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  wtp_2b_793 |         34    2.757353    .8083028       1.25        4.5
wtp_2b_793 CV = .29314448

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
wtp_3b_i~793 |         34    2.470588    .8698761          0        4.5
wtp_3b_info_793 CV = .35209272

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  wtp_2b_356 |         38    2.776316    .8458753          0        4.5
wtp_2b_356 CV = .30467545

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
wtp_3b_i~356 |         38    3.006579    .8805075          0        4.5
wtp_3b_info_356 CV = .29286025

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  wtp_2b_831 |         38    2.552632    .7378701          0          4
wtp_2b_831 CV = .28906253

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
wtp_3b_i~831 |         38    2.789474    .8728764          0       4.75
wtp_3b_info_831 CV = .31291796
*/

	
**********************************************************************
**# 7 - Correlation coefficients
**********************************************************************
* correlation between before and after WTP
	pwcorr 					wtp_2b_584 wtp_3b_info_584, sig
	*** correlation coefficient (r) = 0.8177, positive and strong
	* people who had higher WTP before also tend to have higher WTP after
	* p = 0.000, statistically significant, not due to random chance
	
	pwcorr	 				wtp_2b_793 wtp_3b_info_793, sig
	*** correlation coefficient (r) = 0.7007, positive and strong
	* people who had higher WTP before also tend to have higher WTP after
	* p = 0.000, statistically significant, not due to random chance
	
	pwcorr 					wtp_2b_356 wtp_3b_info_356, sig
	*** correlation coefficient (r) = 0.8820, positive and strong
	* people who had higher WTP before also tend to have higher WTP after
	* p = 0.000, statistically significant, not due to random chance
	
	pwcorr 					wtp_2b_831 wtp_3b_info_831, sig
	*** correlation coefficient (r) = 0.8805, positive and strong
	* people who had higher WTP before also tend to have higher WTP after
	* p = 0.000, statistically significant, not due to random chance
	
* correlation between changes in WTP
	pwcorr 					diff_584 diff_793 diff_356 diff_831, sig
	*** diff_584 vs 793: correlation coefficient (r) = 0.1279 p = 0.4709
	* very weak and not statistically significant
	* changes in wtp for mag product are not related to changes for non mag
	*** diff_356 vs 831: correlation coefficient (r) = 0.7534 p = 0.000
	* strong positive and statistically significant
	* people who increased WTP for 356 also increased WTP for product 831
	
	
**********************************************************************
**# 8 - Table 1: Summary Statistics
**********************************************************************
	tempname 				memhold
	postfile `memhold' 		str20 variable mean sd n cv using "$logs/table1_sumstats.dta", replace

	foreach var of varlist 	wtp_2b_584 wtp_3b_info_584 ///
							wtp_2b_793 wtp_3b_info_793 ///
							wtp_2b_356 wtp_3b_info_356 ///
							wtp_2b_831 wtp_3b_info_831 {

		summarize `var'
		local mean = r(mean)
		local sd   = r(sd)
		local n    = r(N)
		local cv   = r(sd)/r(mean)

		post `memhold' ("`var'") (`mean') (`sd') (`n') (`cv')
	}

	postclose `memhold'

	use "$logs/table1_sumstats.dta", clear

	label variable variable "Variable"
	label variable mean     "Mean"
	label variable sd       "Std. Dev."
	label variable n        "N"
	label variable cv       "Coefficient of Variation"

	list, clean noobs

	export delimited using "$logs/table1_sumstats.csv", replace
	

**********************************************************************
**# 9 - Table 2: One-sample t-tests
**********************************************************************
	tempname 			memhold
	postfile `memhold' 	str20 variable mean tstat pvalue ci_low ci_high using "$logs/table2_onesample.dta", replace

	foreach var of varlist 	wtp_3b_info_584 ///
						wtp_3b_info_793 ///
						wtp_3b_info_356 ///
						wtp_3b_info_831 {

	ttest `var' == 2.5

	local mean    = r(mu_1)
	local tstat   = r(t)
	local pvalue  = r(p)
	local ci_low  = r(lb)
	local ci_high = r(ub)

	post `memhold' ("`var'") (`mean') (`tstat') (`pvalue') (`ci_low') (`ci_high')
}

	postclose `memhold'

	use "$logs/table2_onesample.dta", clear

	label variable variable "Variable"
	label variable mean     "Mean WTP"
	label variable tstat    "t-stat"
	label variable pvalue   "p-value"
	label variable ci_low   "95% CI Lower"
	label variable ci_high  "95% CI Upper"

	list, clean noobs
	
	sljslks
**********************************************************************
**# 10 - Table 3: Paired t-tests
**********************************************************************
	tempname memhold
	postfile `memhold' str20 product mean_before mean_after diff pvalue ci_low ci_high using "$logs/table3_paired.dta", replace

	ttest wtp_3b_info_584 == wtp_2b_584
	post `memhold' ("584") (r(mu_2)) (r(mu_1)) (r(mu_1)-r(mu_2)) (r(p)) (r(lb)) (r(ub))

	ttest wtp_3b_info_793 == wtp_2b_793
	post `memhold' ("793") (r(mu_2)) (r(mu_1)) (r(mu_1)-r(mu_2)) (r(p)) (r(lb)) (r(ub))

	ttest wtp_3b_info_356 == wtp_2b_356
	post `memhold' ("356") (r(mu_2)) (r(mu_1)) (r(mu_1)-r(mu_2)) (r(p)) (r(lb)) (r(ub))

	ttest wtp_3b_info_831 == wtp_2b_831
	post `memhold' ("831") (r(mu_2)) (r(mu_1)) (r(mu_1)-r(mu_2)) (r(p)) (r(lb)) (r(ub))

	postclose `memhold'

	use "$logs/table3_paired.dta", clear

	label variable product     "Product"
	label variable mean_before "Mean Before"
	label variable mean_after  "Mean After"
	label variable diff        "Difference"
	label variable pvalue      "p-value"
	label variable ci_low      "95% CI Lower"
	label variable ci_high     "95% CI Upper"

	list, clean noobs


**********************************************************************
**# 11 - close log
**********************************************************************
	log 					close




	
	
	