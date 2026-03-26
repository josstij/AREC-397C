* course: AREC 397C
* created on: 26 mar 2026
* created by: jmt
* edited on: 26 mar 2026
* edited by: jmt
* Stata v.19.5


* does 
	* establishes identical development environment for users
	* sets globals that define absolute paths
	* loads any user written packages needed for analysis
	* runs all assignment do-files

* assumes
	* access to all data and code

* TO DO:
	* ALL
	
	
******************************************************************
**# 0 - setup
******************************************************************

* set $pack to 0 to skip package installation
	global 			pack 	1
		
* Specify Stata version in use
    global          stataVersion 19.5
    version         $stataVersion
	
	
******************************************************************
**## 0.1 - Create user specific paths
******************************************************************

* Define root folder globals
	* Define root folder globals
	if `"`c(username)'"' == "tijer" {
		global	code	"C:/Users/tijer/OneDrive - University of Arizona/AREC 397C/AREC-397C/code"
		global	data	"C:/Users/tijer/OneDrive - University of Arizona/AREC 397C/AREC-397C/data"
		global	logs	"C:/Users/tijer/OneDrive - University of Arizona/AREC 397C/AREC-397C/logs"
	}
	
	
******************************************************************
**# 1 - run assignment files
******************************************************************
*	do 		"$code/week1/assignment_01.do"


