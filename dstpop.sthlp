{smcl}
{* *! version 1.0.0  11jun2020}{...}
{title:dstpop}

{phang}
{bf:dstpop} {hline 2} Import Danish population from Statistics Denmark since 1971 by year, sex, age, and area.


{title:Syntax}

{p 8 17 2}
{cmdab:dstpop}
{varname}
{cmd:,}
{cmdab:f:rom}(oldkom|newkom)
{cmdab:t:o}(newkom|county|region)
({cmd:replace}|{cmdab:gen:erate}(newvar)
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt f:rom}}converted from (oldkom|newkom) {p_end}
{synopt:{opt t:o}}converted to (newkom|county|region) {p_end}
{synopt:*{opth gen:erate(newvar)}}creates  {it:newvar} containing the to() values and value labels {p_end}
{synopt:*{opt replace}}replace {it:varname} with the to() values and value labels {p_end}
{syntab:Optional}
{synopt:{opt assert}}require all values in varname to match a valid code and terminates program if not {p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:dstpop} facilitate the use of Statistics Denmark's API (DST or "Danmarks Statistik") to download data on Danish population data since 1971.

DST stores population data in four different registries (BEF1, BEF1A, BEF1A07, and FOLK1A). Each registry cover different time periods and have slightly different data structures, which makes DST's API rather cumbersome to use. Importantly, the Structural Reform ("Kommunalreformen") in 2007 combined the previous 271 municipalities into 98 larger municipalities. At the same time, the 16 administrative counties ("amter") were replaced by 5 regions. Some municipalities continued unchanged, while others were combined and split. This introduce a databreach and some municipalities cannot be directly compared geographically (marked with *).

DST's API is documented here: https://www.dst.dk/da/Statistik/statistikbanken/api

Dependencies:
capture: github uninstall dkconvert
github install andreasebbehoj/dkconvert


{title:Remarks}

{pstd}
For more details on dstpop, including how to update, see {browse "https://github.com/andreasebbehoj/dstpop": the readme.md at GitHub}


{title:Examples}



. import delimited "test.csv", clear encoding(UTF-8)

. rename område c_kom


Convert and replace old municipality codes with new codes:

. dstpop c_kom, from(oldkom) to(newkom) replace assert


Generate new variable with corresponding regions:

. dstpop c_kom, from(newkom) to(region) gen(c_reg) assert


{title:Author}

{pstd}
Andreas Ebbehoj, MD & PhD student, Aarhus University, Denmark
