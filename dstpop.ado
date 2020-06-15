*! version 1.0.1 15jun2020
program define dstpop
version 16.1
syntax , FYear(real) TYear(real) ///
	[AREA(string) AGE SEX Quarter(numlist integer)] ///
	[VALlab(string) NOCONVERT DEBUG CLEAR]

*** Check syntax input
if "`debug'"=="debug" {
di _n(2) "INPUTS" ///
	_n "FY: `fyear'" ///
	_n "TY: `tyear'" ///
	_n "Area: `area'" ///
	_n "Age: `age'" ///
	_n "Sex: `sex'" ///
	_n "Quarter: `quarter'" ///
	_n "Vallab: `vallab'" ///
	_n "Noconvert: `noconvert'" ///
	_n "Clear: `clear'" ///
	_n "Debug: `debug'"
}

** Check for errors
* clear
if "`c(changed)'"=="1" & "`clear'"!="clear" {
	error 4 // dataset in memory changed
}
else {
	clear
}

* Time period
if `fyear'<1971 | mi(`fyear') | `tyear'>2020 | mi(`tyear') {
	di as error "Invalid fyear() or tyear() option (from/to year). Must be 1971-2020"
	exit
}
* Area
if inlist("`area'", "", "total", "all", "c_kom", "c_reg")==0 {
	di as error "Invalid area() option. Specify total (default), all, c_kom, or c_reg"
	exit
}
* Convert old municipalities
if mi("`noconvert'") & "`area'"=="all" {
	di as error "Convertion of old municipalities does not work with area(all)." _n "Either change area option to area(c_kom|c_reg|total) or specify noconvert option"
	exit
}
* Value or label
if inlist("`vallab'", "", "code", "value", "both")==0 {
	di as error "Invalid vallab() option. Specify code (default), value, or both"
	exit
}
if inlist("`vallab'", "value", "both") & "`noconvert'"=="" {
	di as error "Convertion of old municipalities does not work with vallab(value|both)." _n "Either change value label option to vallab(code) or specify noconvert option"
	exit
}
* q (quarterly population from FOLK1A)
if !mi("`quarter'"){
	if inlist("`quarter'", "1", "2", "3", "4", "0")==0 {
		di as error "Invalid q option. Specify 1 (default), 2, 3, 4 or 0 (all)"
		exit
	}
	if inlist("`quarter'", "1", "2", "3", "4", "0")==1 & `fyear'<2008 & `tyear'<2008 {
		di as error "Invalid combination of options. Specified quarter(`'quarter'), fyear(`fyear`), and tyear(`'tyear') but quarterly populations are only available since 2008."
		exit
	}
}

** Set empty options to default
* Quarter
if mi("`quarter'") {
	local quarter = 1
}
* Convert (i.e. missing noconvert)
if mi("`noconvert'") & inlist("`area'", "c_kom", "c_reg")==1 & (`fyear'<2007 | `tyear'<2007) {
	local textconvert = `"_n _col(5)  "Convert: yes (from old c_kom to post-2007 `area')" "'
}
* Vallab
if mi("`vallab'") {
	local vallab = "code"
}


*** Define API (URL) input parameters
if "`debug'"=="debug" {
	di _n(2) "INPUTS (after default added)" ///
		_n "FY: `fyear'" ///
		_n "TY: `tyear'" ///
		_n "Area: `area'" ///
		_n "Age: `age'" ///
		_n "Sex: `sex'" ///
		_n "Quarter: `quarter'" ///
		_n "Vallab: `vallab'" ///
		_n "Noconvert: `noconvert'" ///
		_n "Clear: `clear'" ///
		_n "Debug: `debug'"
}

** Registries and year range
* BEF1 1971-2002
local add = 0
forvalues x = `fyear'(1)`tyear' {
	if inrange(`x', 1971, 2002) {
		local add = `add' + 1
	}
}
if `add'>0 {
	local reg = "`reg'" + " BEF1"
	* Define first and last year in registry
	if `fyear' >=1971 {
		local BEF1_f= "`fyear'"
	}
	else {
		local BEF1_f = 1971
	}
	if `tyear' <=2002 {
		local BEF1_t = "`tyear'"
	}
	else {
		local BEF1_t = 2002
	}
	local time_BEF1 = "&Tid=" ///
		+ "%3E%3D" + "`BEF1_f'" /// >=
		+ "%3C%3D" + "`BEF1_t'" // <=
}
* BEF1A 2003-2004
local add = 0
forvalues x = `fyear'(1)`tyear' {
	if inrange(`x', 2003, 2004) {
		local add = `add' + 1
	}
}
if `add'>0 {
	local reg = "`reg'" + " BEF1A"
	if `fyear' >=2003 {
		local BEF1A_f = "`fyear'"
	}
	else {
		local BEF1A_f = 2003
	}
	if `tyear' <=2004 {
		local BEF1A_t = "`tyear'"
	}
	else {
		local BEF1A_t = 2004
	}
	local time_BEF1A = "&Tid=" ///
		+ "%3E%3D" + "`BEF1A_f'" /// >=
		+ "%3C%3D" + "`BEF1A_t'" // <=
}
* BEF1A07 2005-2007
local add = 0
forvalues x = `fyear'(1)`tyear' {
	if inrange(`x', 2005, 2007) {
		local add = `add' + 1
	}
}
if `add'>0 {
	local reg = "`reg'" + " BEF1A07"
	if `fyear' >=2005 {
		local BEF1A07_f = "`fyear'"
	}
	else {
		local BEF1A07_f = 2005
	}
	if `tyear' <=2007 {
		local BEF1A07_t = "`tyear'"
	}
	else {
		local BEF1A07_t = 2007
	}
	local time_BEF1A07 = "&Tid=" ///
		+ "%3E%3D" + "`BEF1A07_f'" /// >=
		+ "%3C%3D" + "`BEF1A07_t'" // <=
}
* FOLK1A 2008-2020
local add = 0
forvalues x = `fyear'(1)`tyear' {
	if inrange(`x', 2008, 2020) {
		local add = `add' + 1
	}
}
if `add'>0 {
	local reg = "`reg'" + " FOLK1A"
	if "`quarter'"=="0" { // All quarters
		if `fyear' >=2008 {
		local FOLK1A_f = "`fyear'K1"
		}
		else {
			local FOLK1A_f = "2008K1"
		}
		if `tyear' <2020 {
			local FOLK1A_t = "`tyear'K4"
		}
		else {
			local FOLK1A_t = "2020K2"
		}
	}
	else { // `quarter' only, default is 1
		if `fyear' >=2008 {
			local FOLK1A_f = "`fyear'K`quarter'"
		}
		else {
			local FOLK1A_f = "2008K`quarter'"
		}
		if `tyear' <2020 {
			local FOLK1A_t = "`tyear'K`quarter'"
		}
		else {
			if inlist("`quarter'", "3", "4") { // Newest data is 2020K2
				local FOLK1A_t = "2020K2"
				di as error "Warning: specified tyear(`tyear') and quarter(`quarter') but newest data are from 2020Q2"
			}
			if inlist("`quarter'", "1", "2") {
				local FOLK1A_t = "2020K`quarter'"
			}
		}
	}
	local time_FOLK1A = "&Tid=" ///
		+ "%3E%3D" + "`FOLK1A_f'" /// >=
		+ "%3C%3D" + "`FOLK1A_t'" // <=
	if "`quarter'"=="0" {
		local textquarter = `"_n _col(5)  "Quarter: Q1-Q4 (only 2008-`tyear' in FOLK1A)" "'
	}
	else {
		local textquarter = `"_n _col(5)  "Quarter: Q`quarter' (only 2008-`tyear' in FOLK1A)" "'
	}
}


** Age
if "`age'"=="age" {
	local textage = "Age: by age (0-98, +99 combined)"

	local age_BEF1 = "&Alder=%3E=0%3C=99-" // BEF1 has age 0 to 99-

	local age_BEF1A = "&Alder=%3E=0%3C=98," + /// 0-98
"sum(99-|[da%2099-%20%C3%A5r][en%2099-%20years]=99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125)" // 99-125 combined to 99-

	local age_BEF1A07 = "&Alder=%3E=0%3C=98," + /// 0-98
"sum(99-|[da%2099-%20%C3%A5r][en%2099-%20years]=99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125)" // 99-125 combined to 99-

	local age_FOLK1A = "&Alder=%3E=0%3C=98," + /// 0-98
"sum(99-|[da%2099-%20%C3%A5r][en%2099-%20years]=99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125)" // 99-125 combined to 99-

}

else {
	local textage = "Age: Total"
}


** Sex
if "`sex'"=="sex" {
	local textsex = "Sex: By sex"
	local sex_BEF1 = "&K%C3%98N=M%2CK" // køn=M,K
	local sex_BEF1A = "&KOEN=M%2CK" // koen=M,K
	local sex_BEF1A07 = "&KOEN=M%2CK" // koen=M,K
	local sex_FOLK1A = "&K%C3%98N=1%2C2" // køn=1,2
}

else {
	local textsex = "Sex: Total"
}


** Area
* Denmark total population
if "`area'"=="total" | "`area'"=="" {
	local textplace = "Area: Total"
}
* All regions, counties and municipalities
if "`area'"=="all" {
	local textplace = "Area: All regions, counties and municipalities"
	local placeall = "&Omr%C3%A5de=*"
}
* All municipalities
if "`area'"=="c_kom" {
	local textplace = "Area: All municipalities"

	local place_BEF1 = "&Omr%C3%A5de=" + subinstr("101 147 165 151 153 155 157 159 161 163 167 169 183 171 173 175 181 185 187 189 201 205 207 208 209 211 213 215 217 219 221 223 225 227 229 231 233 235 237 251 253 255 257 259 261 263 265 267 269 271 301 303 305 307 309 311 313 315 317 319 321 323 325 327 329 331 333 335 337 339 341 343 345 351 353 355 357 359 361 363 365 367 369 371 373 375 377 379 381 383 385 387 389 391 393 395 397 401 403 405 407 409 411 421 423 425 427 429 431 433 435 437 439 441 443 445 447 449 451 461 471 473 475 477 479 481 483 485 487 489 491 492 493 495 497 499 501 503 505 507 509 511 513 515 517 519 521 523 525 527 529 531 533 535 537 539 541 543 545 551 553 555 557 559 561 563 565 567 569 571 573 575 577 601 603 605 607 609 611 613 615 617 619 621 623 625 627 629 631 651 653 655 657 659 661 663 665 667 669 671 673 675 677 679 681 683 685 701 703 705 707 709 711 713 715 717 719 721 723 725 727 729 731 733 735 737 739 741 743 745 747 749 751 761 763 765 767 769 771 773 775 777 779 781 783 785 787 789 791 793 801 803 805 807 809 811 813 815 817 819 821 823 825 827 829 831 833 835 837 839 841 843 845 847 849 851 861", " ", "%2C", .) // 400 was Bornholm County up to 2002

	local place_BEF1A = "&Omr%C3%A5de=" + subinstr("101 147 165 151 153 155 157 159 161 163 167 169 183 171 173 175 181 185 187 189 201 205 207 208 209 211 213 215 217 219 221 223 225 227 229 231 233 235 237 251 253 255 257 259 261 263 265 267 269 271 301 303 305 307 309 311 313 315 317 319 321 323 325 327 329 331 333 335 337 339 341 343 345 351 353 355 357 359 361 363 365 367 369 371 373 375 377 379 381 383 385 387 389 391 393 395 397 400 411 421 423 425 427 429 431 433 435 437 439 441 443 445 447 449 451 461 471 473 475 477 479 481 483 485 487 489 491 492 493 495 497 499 501 503 505 507 509 511 513 515 517 519 521 523 525 527 529 531 533 535 537 539 541 543 545 551 553 555 557 559 561 563 565 567 569 571 573 575 577 601 603 605 607 609 611 613 615 617 619 621 623 625 627 629 631 651 653 655 657 659 661 663 665 667 669 671 673 675 677 679 681 683 685 701 703 705 707 709 711 713 715 717 719 721 723 725 727 729 731 733 735 737 739 741 743 745 747 749 751 761 763 765 767 769 771 773 775 777 779 781 783 785 787 789 791 793 801 803 805 807 809 811 813 815 817 819 821 823 825 827 829 831 833 835 837 839 841 843 845 847 849 851 861", " ", "%2C", .) // 401 403 405 407 and 409 was combined into Bornholm Municipality 400 in 2003

	local place_BEF1A07 = "&Omr%C3%A5de=" + subinstr("101 147 155 185 165 151 153 157 159 161 163 167 169 183 173 175 187 201 240 210 250 190 270 260 217 219 223 230 400 411 253 259 350 265 269 320 376 316 326 360 370 306 329 330 340 336 390 420 430 440 482 410 480 450 461 479 492 530 561 563 607 510 621 540 550 573 575 630 580 710 766 615 707 727 730 741 740 746 706 751 657 661 756 665 760 779 671 791 810 813 860 849 825 846 773 840 787 820 851", " ", "%2C", .)

	local place_FOLK1A = "&Omr%C3%A5de=" + subinstr("101 147 155 185 165 151 153 157 159 161 163 167 169 183 173 175 187 201 240 210 250 190 270 260 217 219 223 230 400 411 253 259 350 265 269 320 376 316 326 360 370 306 329 330 340 336 390 420 430 440 482 410 480 450 461 479 492 530 561 563 607 510 621 540 550 573 575 630 580 710 766 615 707 727 730 741 740 746 706 751 657 661 756 665 760 779 671 791 810 813 860 849 825 846 773 840 787 820 851", " ", "%2C", .)
}

* All regions
if "`area'"=="c_reg" {
	local textplace = "Area: All regions"

	local place_BEF1 = "&Omr%C3%A5de=" + subinstr("101 147 165 151 153 155 157 159 161 163 167 169 183 171 173 175 181 185 187 189 201 205 207 208 209 211 213 215 217 219 221 223 225 227 229 231 233 235 237 251 253 255 257 259 261 263 265 267 269 271 301 303 305 307 309 311 313 315 317 319 321 323 325 327 329 331 333 335 337 339 341 343 345 351 353 355 357 359 361 363 365 367 369 371 373 375 377 379 381 383 385 387 389 391 393 395 397 401 403 405 407 409 411 421 423 425 427 429 431 433 435 437 439 441 443 445 447 449 451 461 471 473 475 477 479 481 483 485 487 489 491 492 493 495 497 499 501 503 505 507 509 511 513 515 517 519 521 523 525 527 529 531 533 535 537 539 541 543 545 551 553 555 557 559 561 563 565 567 569 571 573 575 577 601 603 605 607 609 611 613 615 617 619 621 623 625 627 629 631 651 653 655 657 659 661 663 665 667 669 671 673 675 677 679 681 683 685 701 703 705 707 709 711 713 715 717 719 721 723 725 727 729 731 733 735 737 739 741 743 745 747 749 751 761 763 765 767 769 771 773 775 777 779 781 783 785 787 789 791 793 801 803 805 807 809 811 813 815 817 819 821 823 825 827 829 831 833 835 837 839 841 843 845 847 849 851 861", " ", "%2C", .)

	local place_BEF1A = "&Omr%C3%A5de=" + subinstr("101 147 165 151 153 155 157 159 161 163 167 169 183 171 173 175 181 185 187 189 201 205 207 208 209 211 213 215 217 219 221 223 225 227 229 231 233 235 237 251 253 255 257 259 261 263 265 267 269 271 301 303 305 307 309 311 313 315 317 319 321 323 325 327 329 331 333 335 337 339 341 343 345 351 353 355 357 359 361 363 365 367 369 371 373 375 377 379 381 383 385 387 389 391 393 395 397 400 411 421 423 425 427 429 431 433 435 437 439 441 443 445 447 449 451 461 471 473 475 477 479 481 483 485 487 489 491 492 493 495 497 499 501 503 505 507 509 511 513 515 517 519 521 523 525 527 529 531 533 535 537 539 541 543 545 551 553 555 557 559 561 563 565 567 569 571 573 575 577 601 603 605 607 609 611 613 615 617 619 621 623 625 627 629 631 651 653 655 657 659 661 663 665 667 669 671 673 675 677 679 681 683 685 701 703 705 707 709 711 713 715 717 719 721 723 725 727 729 731 733 735 737 739 741 743 745 747 749 751 761 763 765 767 769 771 773 775 777 779 781 783 785 787 789 791 793 801 803 805 807 809 811 813 815 817 819 821 823 825 827 829 831 833 835 837 839 841 843 845 847 849 851 861", " ", "%2C", .)

	local place_BEF1A07 = "&Omr%C3%A5de=" + subinstr("081 082 083 084 085", " ", "%2C", .)

	local place_FOLK1A = "&Omr%C3%A5de=" + subinstr("081 082 083 084 085", " ", "%2C", .)
}

** Value or code
if mi("`vallab'") | "`vallab'"=="code" {
	local value = "&valuePresentation=Code"
}
if "`vallab'"=="value" {
	local value = "&valuePresentation=Value"
}
if "`vallab'"=="both" {
	local value = "&valuePresentation=CodeAndValue"
}

*** Download from registries
tempfile outfile
qui: save "`outfile'", replace empty
di _n "Download settings:" ///
	_n _col(5) "Time: `fyear'-`tyear'" `textquarter' ///
	_n _col(5) "Registries: `reg'" ///
	_n _col(5) "`textplace'" ///
	_n _col(5) "`textage'" ///
	_n _col(5) "`textsex'" ///
	_n _col(5) "Value or code: `vallab'" ///
	`textconvert' ///
	`textquarter'

di _n "Downloading from:"
foreach file of local reg {
	di _col(10) "`file' (``file'_f'-``file'_t')"

	** Call API with cURL
	local url = "https://api.statbank.dk/v1/data/`file'" /// URL to registry´s API
		+ "/CSV?" /// csv format
		+ "lang=en" ///
		+ "`value'" /// Value, code or both
		+ "`time_`file''" /// By time period
		+ "`age_`file''" /// By age
		+ "`sex_`file''" /// By sex
		+ "`placeall'" /// All areas (municipalities, counties, regions and totals)
		+ "`place_`file''" // By area
	if "`debug'"=="debug" {
		di _n "API call: `url'"
	}
	qui: copy "`url'"  "`file'.csv", replace
}


*** Import and format files
foreach file of local reg {
	qui: import delimited "`file'.csv", clear encoding(UTF-8)
	* Debug
	if "`debug'"=="debug" {
		di _n "Import and format `file' (``file'_f'-``file'_t')"
	}
	else {
		qui: erase "`file'.csv"
	}
	** Names and labels
	rename tid year
	label var year "Year"
	capture: rename alder age
	capture: label var age "Age"
	capture: rename køn sex
	capture: rename koen sex
	capture: label var sex "Sex"
	capture: rename indhold pop
	capture: label var pop "Population"
	capture: rename område area

	** Age
	if "`vallab'"=="code" {
		capture: replace age = subinstr(age, "-", "", 1) // Remove - from 99-
		capture: destring age, replace
	}

	if "`area'"=="c_kom" {
		capture: label var area "Municipality"
	}
	if "`area'"=="c_reg" {
		capture: label var area "Region"
	}

	** Sex
	if "`sex'"=="sex" & inlist("`file'", "BEF1", "BEF1A", "BEF1A07") & "`vallab'"=="code" {
		capture: replace sex = "1" if sex=="M"
		capture: replace sex = "2" if sex=="K"
		capture: destring sex, replace
	}

	** Convert area (only BEF1 and BEF1A)
	if mi("`noconvert'") {
		if "`area'"=="c_kom" & inlist("`file'", "BEF1", "BEF1A") {
			qui: dkconvert area, from(oldkom) to(newkom) replace assert
		}
		if "`area'"=="c_reg" & inlist("`file'", "BEF1", "BEF1A") {
			qui: dkconvert area, from(oldkom) to(region) replace assert
		}

	}

	** Year (only FOLK1A has population for each quarter)
	if "`file'"=="FOLK1A" {
		if "`quarter'"=="0" {
			qui: gen year_q = "Q" + substr(year, -1, 1)
			label var year_q "Quarter"
		}
		else {
			qui: keep if substr(year, -1, 1)=="`quarter'"
		}

		if inlist("`vallab'", "code", "value") {
			qui: replace year = substr(year, -6, 4)
			qui: destring year, replace
			}
	}

	** Append
	tempfile import`file'
	qui: save `import`file'', replace
	if "`debug'"=="debug" { //
		qui: save "`file'.dta", replace
	}
	use "`outfile'", clear
	append using `import`file'', force
	capture: order year_q, after(year)
	qui: save "`outfile'", replace
}


*** Add value labels
if "`sex'"=="sex" & "`vallab'"=="code" {
	label define _sex 1 "Men" 2 "Women", replace
	label value sex _sex
}

if "`age'"=="age" & "`vallab'"=="code" {
	label define _age 99 "99+", replace
	label value age _age
}

*** Combine converted area
if mi("`noconvert'") & inlist("`area'", "c_reg", "c_kom") & (strpos("`reg'", "BEF1 ") | strpos("`reg'", "BEF1A ")){
	qui: ds year area pop, not
	local bysortlist = "`r(varlist)'"
	if !mi("`bysortlist'") {
		di _n "Combined populations by: year area `bysortlist'"
		qui: bysort year area `bysortlist': egen totalpop=total(pop)
	}
	else {
		di _n "Combined populations by: year area"
		qui: bysort year area: egen totalpop=total(pop)
	}
	qui: replace pop = totalpop
	drop totalpop
	qui: duplicates drop
}
end
