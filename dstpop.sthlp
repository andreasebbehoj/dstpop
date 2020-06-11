{smcl}
{* *! version 1.0.0  11jun2020}{...}
{title:dstpop}

{phang}
{bf:dstpop} {hline 2} Import Danish population by year, sex, age, and area, using Statistics Denmark's API.


{title:Syntax}

{p 8 17 2}
{cmd:dstpop}
{cmd:,}
{cmdab:fy:ear}({it:year})
{cmdab:ty:ear}({it:year})
[{cmd:sex}]
[{cmd:age}]
[{cmd:area}({it:val_opt})]
{cmd:convert}()
[{it:other options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt fy:ear}}population from {it:year} (range 1971-2020)... {p_end}
{synopt:{opt ty:ear}}... to {it:year} (range 1971-2020) {p_end}
{syntab:Population by (optional)}
{synopt:{opt sex}}get population by sex.{p_end}
{synopt:{opt age}}get population by age (1-year intervals 0-98, 99-125 combined into 99+).{p_end}
{p2coldent:* {opt area}({it:area_opt})}get population by area, where {it:area_opt} can be {it:total} (default), {it:c_kom} (by municipality), {it:c_reg} (by region), or {it:all} (municipality, county, and region #). {p_end}
{synoptline}
{syntab:Other options}
{synopt:{opt clear}}specifies that it is okay to replace the data in memory, even though the current data have not been saved to disk.{p_end}
{p2coldent:* {opt conv:ert}} {p_end}
{p2coldent:* {opt val:lab}({it:val_opt})} {it:total}|{it:c_kom}|{it:c_reg}|{it:all}{p_end}
{synopt:{opt q:uarter}} {p_end}
{synopt:{opt debug}}make program output more detailed. Enable to trouble-shoot program.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2} * {opt conv:ert} does not work if {opt val:lab}({it:val_opt}) is set to {it:value} or {it:both} or if {opt area}({it:area_opt}) is set to {it:all}.{p_end}
{p 4 6 2} # {opt area}({it:all}) provide population by old municipalities and counties 1971-2004 and new municipalities and region 2005-2020 (not recommended).


{title:Description}

{pstd}
{cmd:dstpop} makes it easy to download the Danish population for each year from {it:fyear} to {it:tyear} (range 1971-2020).

{pstd}
Population can be total Danish population (default), or by sex, age, area, or a combination of all three.

{pstd}
DST stores population data in four different registries (BEF1, BEF1A, BEF1A07, and FOLK1A). Each registry cover different time periods and have slightly different data structures, which makes DST's API rather cumbersome to use. Importantly, the Structural Reform ("Kommunalreformen") in 2007 combined the previous 271 municipalities into 98 larger municipalities. At the same time, the 16 administrative counties ("amter") were replaced by 5 regions. Some municipalities continued unchanged, while others were combined and split. This introduce a databreach and some municipalities cannot be directly compared geographically (marked with *).

{pstd}
Data is downloaded using the API provided by Statistics Denmark (DST or "Danmarks Statistik").

{pstd}
DST's API is documented {browse "https://www.dst.dk/da/Statistik/statistikbanken/api":here}.


{title:Dependencies}
{cmd:dstpop} requires {cmd:dkconvert} for the {opt conv:ert} option to work.

{cmd:dstpop} can be installed with the {cmd:github} package by E.F. Haghish ({browse "https://github.com/haghish/github":link})

. net install github, from("https://haghish.github.io/github/")
. github install andreasebbehoj/dkconvert


{title:Remarks}

{pstd}
For more details on dstpop, including how to update, see {browse "https://github.com/andreasebbehoj/dstpop":the readme.md at GitHub}


{title:Examples}

Download total Danish population by year 1971-2020
. dstpop, fy(1971) ty(2020) clear

Population 2000-2020 by each municipality
. dstpop, fy(2000) ty(2020) area(c_kom) clear

Population 2000-2020 by each region
. dstpop, fy(2000) ty(2020) area(c_reg) clear

Population 1977-1990 in the old municipalities (pre-2007)
. dstpop, fy(1977) ty(1990) area(c_reg) convert(no) clear

Population 2000-2020 by sex and age
. dstpop, fy(2000) ty(2020) sex age clear

Population 1971-2020 by sex, age, and municipality (large file!)
. dstpop, fy(1971) ty(2020) sex age area(c_kom) clear

syntax , FYear(real) TYear(real) ///
	[AREA(string) AGE SEX Quarter(numlist integer)] ///
	[VALlab(string) CONVert(string) DEBUG CLEAR]

{title:Author}

{pstd}
Andreas Ebbehoj, MD & PhD student, Aarhus University, Denmark
