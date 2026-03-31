* course: AREC 397C
* assignment: 1
* created on: 26 mar 2026
* created by: jmt
* edited on: 26 mar 2026
* edited by: jmt
* Stata v.19.5

* does
	
	
* needs
	* all
	
	clear				all
	
	cap log 		close
	log using		"$logs/assignment_leavy", append	
**********************************************************************
**# 0 - Describing Relationships
**********************************************************************
	
**## 0.1 - objectives
	
	* Create a scatter plot of two variables
	* Write code to manipulate how the plot looks
	* Describe the relationship between two variables
	* Represent condition distributions and conditional means
	* Fit a line to data
	* Evaluate the relationship between two variables
	
	
**********************************************************************
**# 1 - Basic Scatter Plots
**********************************************************************
	
	import delimited		using "$data/spors_bev_data_use_me.csv"
	describe
	
	
	