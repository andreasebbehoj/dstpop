*! version 1.1.0 17aug2020
program define dstpop_BEF1A07, rclass
version 15
syntax, tid(string) [omraade(string) civilstand(string) alder(string) koen(string)  ]  

*** Define variables and input
** Year
local api_tid = 			"&TID=" 		+ subinstr(trim("`tid'"), " ", "%2C", .)

** Marital status
if !mi("`civilstand'") {
    local api_civilstand =	"&CIVILSTAND="	+ subinstr("U G E F P L O", " ", "%2C", .)
}

** Age
if "`alder'"=="age" {
    local api_alder = 		"&ALDER=" + "%3E=0%3C=98," + /// 0-98
"sum(99-|[da%2099-%20%C3%A5r][en%2099-%20years]=99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125)" // 99-125 combined to 99-
}

** Sex
if !mi("`koen'") {
    local api_koen = 		"&KOEN=" 		+ subinstr("M K", " ", "%2C", .)
}

** Area
if "`omraade'"=="c_kom" {
    local api_omraade = 	"&OMR%C3%85DE="	+ subinstr("101 147 155 185 165 151 153 157 159 161 163 167 169 183 173 175 187 201 240 210 250 190 270 260 217 219 223 230 400 411 253 259 350 265 269 320 376 316 326 360 370 306 329 330 340 336 390 420 430 440 482 410 480 450 461 479 492 530 561 563 607 510 621 540 550 573 575 630 580 710 766 615 707 727 730 741 740 746 706 751 657 661 756 665 760 779 671 791 810 813 860 849 825 846 773 840 787 820 851", " ", "%2C", .) // Municipality Reform in 2007
}

if "`omraade'"=="c_reg" {
    local api_omraade = 	"&OMR%C3%85DE="	+ subinstr("081 082 083 084 085", " ", "%2C", .)

}

if "`omraade'"=="all" {
    local api_omraade = 	"&OMR%C3%85DE="	+ "*"
}

if inlist("`omraade'", "total", "all", "c_kom", "c_reg", "")==0 {
    local api_omraade = 	"&OMR%C3%85DE="	+ subinstr("`omraade'", " ", "%2C", .)
}


*** Output 
return local apiurl = "https://api.statbank.dk/v1/data/BEF1A07" /// URL to registry´s API
	/// Common settings
	+ "/CSV?" /// csv format
	+ "lang=en" ///
	+ "&valuePresentation=Code" /// Data in code format
	/// Inputs
	+ "`api_tid'" /// By year
	+ "`api_civilstand'" /// By marrital status
	+ "`api_alder'" /// By age
	+ "`api_koen'" /// By sex
	+ "`api_omraade'" // By area

end