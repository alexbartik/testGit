
*******************************************
* clean_long.do
* Last Edited By: Alex Bartik
* Date Last Edited: 1/26/2013
*******************************************
clear all
mat drop _all
set more off
set matsize 5000

************************************************
* ROOT
local awb_dir0 = "C:\Users\bartika\"
local awb_dir1 = "C:\Users\Bartik\"
local dan_dir = "/Users/dstuart"

* DIRECTORIES
local fracfolder = "Dropbox\Fracing_National\"
local DIRECTORY = "`awb_dir1'\`fracfolder'"
local INPUT "Data\Output\Final\Stata\"
local RESULTS "Results/"
local LOG "`RESULTS'/Log/"

* INPUTS 
local input = "`INPUT'\`geo'_input.dta"

*********************
* 1.1 LOADING DATA
*********************

use "`input'", clear


**********************
* 1.2 CODING VARIABLES
**********************
local potoutcomes "valScore`datenum'"
levelsof year, local(yearsall)

egen yearstate = group(year statefips)
egen shalegroup1 = group(shale1)
replace shalegroup1 = 99 if shalegroup1==.
egen yearshale = group(year shalegroup1)

quietly tab year, gen(yearfe)	
quietly sum year
local ymin = `r(min)'
disp "`ymin'"
gen time = year - `ymin'
destring stateFIPS, replace 
levelsof stateFIPS, local(statefipsall)

foreach statefipsnum of local statefipsall {
	quietly gen statefipstrend`statefipsnum' = time
	quietly replace statefipstrend`statefipsnum'=0 if stateFIPS!=`statefipsnum'
	}

gen lmine = log(mining_emp)
gen lemp_tot = log(emp_tot)
gen linc = log(income_percap)
gen lpop_tot = log(pop_tot)

*********************
* 2 Coding Gas Variables
*********************
local JBTU = 1083/1.2027

gen gasBTU = gas*1030*1000
gen oilBTU = oil*5.6*(10^6)

gen gasJ = gasBTU*`JBTU'
gen oilJ = oilBTU*`JBTU'
gen totJ = gasJ + oilJ

gen gaskWh = gasBTU/8152
gen oilkWh = oilBTU/10829

gen gas_GWh = gaskWh/1000000
gen oil_GWh = oilkWh/1000000
gen tot_GWh = gas_GWh + oil_GWh

replace gasJ = gasJ/1000000000
replace oilJ = oilJ/1000000000
replace totJ = totJ/1000000000

gen gasval = gas*`gasprice'
gen oilval = oil*`oilprice'
gen totval = gasval + oilval

replace gasval = gasval/1000000
replace oilval = oilval/1000000
replace totval = totval/1000000

replace gas = gas/1000000
replace oil = oil/1000000

gen z = 1 if mining_emp!=. & year==2011
egen samplelmine = min(z), by(`geoVar')
replace samplelmine=0 if samplelmine==.

local allvars = "anywell oilwell gaswell oil gas gasval oilval totval gasJ oilJ totJ gas_GWh oil_GWh tot_GWh lemp_tot linc  lpop_tot" 	
foreach var of local allvars {
	gen sample`var'=1
	}

local hpdivars = "anywell gaswell oilwell oil gas gasval oilval totval gasJ oilJ totJ gas_GWh oil_GWh tot_GWh "
foreach var of local hpdivars {
	replace `var' = 0 if `var'==.
	}