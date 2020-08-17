*! version 1.1.0 17aug2020
program define dstpop
version 16.1
syntax , Year(numlist integer) ///
	[AREA(string) AGE SEX MARitalstatus Quarter(numlist integer)] ///
	[NOCONVERT DEBUG CLEAR]


*** Check syntax input 
** Check for errors
* clear
if "`c(changed)'"=="1" & "`clear'"!="clear" {
	error 4 // dataset in memory changed
}
else {
	clear
}
* Time period
local fyear=9999
local tyear=0

foreach value in `year' {
	if  `value'<`fyear' { // lowest year in numlist
		local fyear=`value' 
	}
	if  `value'>`tyear' { // highest year in numlist
		local tyear=`value' 
	}
	if `fyear'<1971 | `tyear' >2020 {
		di as error "Invalid year value(s). Must be between 1971-2020"
		exit
	}
}
* q (quarterly population from FOLK1A)
if !mi("`quarter'") {
	if inlist("`quarter'", "1", "2", "3", "4", "0")==0 {
		di as error "Invalid q option. Specify 1 (default), 2, 3, 4 or 0 (all)"
		exit
	}
	if inlist("`quarter'", "1", "2", "3", "4", "0")==1 & `fyear'<2008 & `tyear'<2008 {
		di as error "Invalid combination of options. Specified quarter(`'quarter') and year(`year') but quarterly populations are only available 2008-2020."
		exit
	}
}
* Area
if inlist("`area'", "", "total", "all", "c_kom", "c_reg")==0 {
	di as error "Invalid area() option. Specify total (default), all, c_kom, or c_reg"
	exit
}
* Convert old municipalities
if mi("`noconvert'") & "`area'"=="all" {
	di as error "Convertion of old municipalities does not work with area(all)." ///
			_n "Either change area option to area(c_kom|c_reg|total) or specify noconvert option"
	exit
}

** Set empty options to default
* Quarter
if mi("`quarter'") {
	local quarter = 1
}

** Summarize input
if "`debug'"=="debug" {
	di _n(2) "INPUTS" ///
		_n "Years: `year'" ///
		_n "Area: `area'" ///
		_n "Age: `age'" ///
		_n "Sex: `sex'" ///
		_n "Marital status: `maritalstatus'" ///
		_n "Quarter: `quarter'" ///
		_n "Noconvert: `noconvert'" ///
		_n "Clear: `clear'" ///
		_n "Debug: `debug'"
}


*** Define years and registries to include
local add_BEF1 = 0
local add_BEF1A = 0
local add_BEF1A07 = 0
local add_FOLK1A = 0
local reg = ""

foreach x in `year' {
	** BEF1 1971-2002
	if inrange(`x', 1971, 2002) {
		local add_BEF1 = `add_BEF1' + 1
		local time_BEF1 = "`time_BEF1' `x'"
	}

	** BEF1A 2003-2006
	if inrange(`x', 2003, 2006) {
		local add_BEF1A = `add_BEF1A' + 1
		local time_BEF1A = "`time_BEF1A' `x'"
	}

	** BEF1A07 2007
	if inrange(`x', 2007, 2007) {
		local add_BEF1A07 = `add_BEF1A07' + 1
		local time_BEF1A07 = "`time_BEF1A07' `x'"
	}

	** FOLK1A 
	* 2008-2019 (years with full datasets)
	if inrange(`x', 2008, 2019) {
		local add_FOLK1A = `add_FOLK1A' + 1
		if inlist("`quarter'", "1", "2", "3", "4") {
			local time_FOLK1A = "`time_FOLK1A' `x'K`quarter'"
		}
		if "`quarter'"=="0" {
			forvalues q = 1(1)4 {
				local time_FOLK1A = "`time_FOLK1A' `x'K`q'"
			}
		}
	}
	* 2020 (current year with limited data)
	if inrange(`x', 2020, 2020) {
		local add_FOLK1A = `add_FOLK1A' + 1
		if inlist("`quarter'", "1", "2", "3") {
			local time_FOLK1A = "`time_FOLK1A' `x'K`quarter'"
		}
		if "`quarter'"=="4" {
			local time_FOLK1A = "`time_FOLK1A' `x'K3"
			di as error "Obs: specified 2020 and quarter(4), but dstpop and/or Statistics Denmark are only updated up until 2020 Q3." 
			di as text "Downloaded Q3 for 2020 instead."
		}
		if "`quarter'"=="0" {
			local time_FOLK1A = "`time_FOLK1A' 2020K1 2020K2 2020K3"
		}
	}



} // end year loop

** Summarize years and registries
if `add_BEF1'>0 {
	local reg = "BEF1 "
}
if `add_BEF1A'>0 {
	local reg = "`reg'" + "BEF1A "
}
if `add_BEF1A07'>0 {
	local reg = "`reg'" + "BEF1A07 "
}
if `add_FOLK1A'>0 {
		local reg = "`reg'" + "FOLK1A "
}

if "`debug'"=="debug" {
	di _n(2) "Years and registries included:" ///
		_n _col(5) "Registries: `reg'" ///
		_n _col(5) "BEF1 time: `time_BEF1' (no. of years = `add_BEF1')" ///
		_n _col(5) "BEF1A time: `time_BEF1A' (no. of years = `add_BEF1A')" ///
		_n _col(5) "BEF1A07 time: `time_BEF1A07' (no. of years = `add_BEF1A07')" ///
		_n _col(5) "FOLK1A time: `time_FOLK1A' (no. of years = `add_FOLK1A')" ///
		_n
}


*** Download from registries
/*
DST has imposed a maximum download limit of 500,000 cells per API call when using the formatted CSV download. DST calculates the number of cells based on the number of cells they need to access in the dataset in order to calculate the population by each of the specified variables. 

Since not all registries have precalculated "total" values for sex (BEF BEF1 and BEF1A07), marital status (BEF BEF1 and BEF1A07), and age (BEF1A and BEF1A07), the number of cells DST need to access varies considerably between registries. 

The limit of 500,000 is mainly a problem when downloading population for multiple years for both area(all|c_reg|c_kom) and age at the same time. Therefore, when both are specified in dstpop, dstpop downloads each year separately. 
This limit makes it impossible to download the population on all variables in BEF1A even for a single year. This needs to be done manually with DST bulk command on their API webpage.

Note: Since data is recorded in variables ...:
	TID	CIVILSTAND	ALDER	KOEN	OMRÅDE	INDHOLD
	1987	Never married	0 years	Men	Copenhagen and Frederiksberg	2655

... DST need to access 6 cells for each population estimate, so the number of cells accessed are 6 times higher than the number of combinations, you think you are asking for.
*/

** Download data
tempfile outfile
qui: save `outfile', replace empty
di _n "Download settings:" ///
	_n _col(5) "Time period: `fyear'-`tyear'" ///
	_n _col(5) "Registries: `reg'" ///
	_n _col(5) "Population by: `area' `sex' `age' `maritalstatus'" //

di _n "Downloading from:"

foreach file of local reg {
	di 	_col(5) "`file' (years:`time_`file'')"
	
	* All data at once
	if inlist("`area'", "c_kom", "c_reg", "all")==0 | "`age'"=="" {
		dstpop_`file', tid(`time_`file'') alder(`age') omraade(`area') koen(`sex') civilstand(`maritalstatus')

		if "`debug'"=="debug" {
			di "`r(apiurl)'"
		}
		
		qui: copy "`r(apiurl)'"  "dstpop_`file'.csv", replace
		qui: import delimited "dstpop_`file'.csv", clear encoding(UTF-8)
		qui: save "dstpopdebug_`file'.dta", replace
		
		qui: erase "dstpop_`file'.csv"
	}
	
	* Download one year at a time
	else {
		clear
		qui: tempfile download_combined
		qui: save `download_combined', empty replace
		
		foreach download_year of local time_`file' {
			di _col(10) "`download_year'"
			dstpop_`file', tid(`download_year') alder(`age') omraade(`area') koen(`sex') civilstand(`maritalstatus')

			if "`debug'"=="debug" {
				di "`file' - `download_year' - `r(apiurl)'"
			}
				
			qui: copy "`r(apiurl)'"  "download.csv", replace
			
			qui: import delimited "download.csv", clear encoding(UTF-8)
			qui: save "download.dta", replace
			
			qui: use `download_combined', clear
			qui: append using "download.dta"
			qui: save `download_combined', replace
			
			qui: erase "download.csv"
			erase "download.dta"
		} // end year loop
		
	qui: save "dstpopdebug_`file'.dta", replace
	}

} // end file loop


*** Import files and unify formats
foreach file of local reg {
	qui: use "dstpopdebug_`file'.dta", clear 
	if "`debug'"=="debug" {
		di _n "Importing and formatting `file'"
	}
	else {
		qui: erase "dstpopdebug_`file'.dta"
	}
	
	** Names and labels
	capture: rename tid year
	capture: rename alder age
	capture: rename køn sex
	capture: rename koen sex
	capture: rename indhold pop
	capture: rename område area
	capture: rename civilstand maritalstatus
	
	** Age
	capture: replace age = subinstr(age, "-", "", 1) // Remove - from 99-
	capture: destring age, replace
	
	** Sex
	capture: replace sex = "1" if sex=="M"
	capture: replace sex = "2" if sex=="K"
	capture: destring sex, replace

	** Convert area (only BEF1 and BEF1A)
	if mi("`noconvert'") & inlist("`area'", "c_kom", "c_reg") & inlist("`file'", "BEF1", "BEF1A")  {
		if "`area'"=="c_kom" {
			qui: dkconvert area, from(oldkom) to(newkom) replace assert
		}
		if "`area'"=="c_reg" {
			qui: dkconvert area, from(oldkom) to(region) replace assert
		}
	
		* Combine pop estimates
		qui: ds year area pop, not
		local bysortlist = "`r(varlist)'"
		qui: bysort year area `bysortlist': egen totalpop=total(pop)
		qui: replace pop = totalpop
		drop totalpop
		qui: duplicates drop
		}
	
	** Label area (only BEF1A07 and FOLK1A)
	if mi("`noconvert'") & inlist("`area'", "c_kom", "c_reg") & inlist("`file'", "BEF1A07", "FOLK1A")  {
		if "`area'"=="c_kom" {
			qui: dkconvert area, from(newkom) labelonly assert
		}
		if "`area'"=="c_reg" {
			qui: dkconvert area, from(region) labelonly assert
		}
	}
	
	** Convert marital status to FOLK1A categories
	if mi("`noconvert'") & !mi("`maritalstatus'") {
		* Unmarried
		qui: replace maritalstatus = "1"  if inlist(maritalstatus, "U", "UG")
		* Married/separated (incl. registered partnerships before 2007)
		qui: replace maritalstatus = "2" if inlist(maritalstatus, "G", "P", "GI") 
		* Widow/widower (incl. registered partnerships before 2007)
		qui: replace maritalstatus = "3" if inlist(maritalstatus, "E", "L", "EN") 
		* Divorced
		qui: replace maritalstatus = "4" if inlist(maritalstatus, "F", "O", "SK") 
		
		* Combine pop estimates
		qui: destring maritalstatus, replace
		qui: ds year maritalstatus pop, not
		local bysortlist = "`r(varlist)'"
		qui: bysort year maritalstatus `bysortlist': egen totalpop=total(pop)
		qui: replace pop = totalpop
		drop totalpop
		qui: duplicates drop
	}
	
	** Year & quarters (only FOLK1A)
	if "`file'"=="FOLK1A" {
		if "`quarter'"=="0" {
			qui: gen quarter = real(substr(year, -1, 1))
			label var quarter "Quarter"
		}
		else {
			qui: keep if substr(year, -1, 1)=="`quarter'"
		}

		qui: replace year = substr(year, -6, 4)
		qui: destring year, replace
	}

	** Append
	tempfile import`file'
	qui: save `import`file'', replace
	if "`debug'"=="debug" { //
		qui: save "dstpopdebug_`file'.dta", replace
	}
	if mi("`debug'") { // Remove debug files
		capture: erase "dstpopdebug_`file'.dta"
	}
	qui: use `outfile', clear
	qui: append using `import`file'', force
	capture: order quarter, after(year)
	qui: save `outfile', replace
}


*** Add labels
capture: label var year "Year"
capture: label var age "Age"
capture: label var sex "Sex"
capture: label var area "Area (`area')"
capture: label var maritalstatus "Marital status"
capture: label var pop "Population"


if "`age'"=="age" {
	qui: label define age_ 99 "99+", replace
	qui: label value age age_
}

if "`sex'"=="sex" {
	qui: label define sex_ 1 "Men" 2 "Women", replace
	qui: label value sex sex_
}

if "`maritalstatus'"=="maritalstatus" & mi("`noconvert'") {
	qui: label define maritalstatus_ 1 "Unmarried" 2 "Married/separated" 3 "Widow/widower" 4 "Divorced", replace
	qui: label value maritalstatus maritalstatus_
}

end