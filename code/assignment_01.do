* course: 497A
* assignment: 5
* created on: 13 feb 2026
* created by: jmt
* edited on: 19 feb 2026
* edited by: jmt
* Stata v.19.5

* does
	* assignment 5
	
* needs
	* left off on 7.3
	
	clear				all
	
	cap log 		close
	log using		"$logs/assignment_05", append	
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
	
	use				"$data/eth_allrounds_final"
	