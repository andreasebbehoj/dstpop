{smcl}
{* *! version 1.0.2  15jun2020}{...}
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
[{cmd:clear}]
[{it:other options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt fy:ear}}population from {it:year} (range 1971-2020)... {p_end}
{synopt:{opt ty:ear}}... to {it:year} (range 1971-2020) {p_end}
{syntab:Population by (optional)}
{synopt:{opt sex}}get population by sex.{p_end}
{synopt:{opt age}}get population by age.{p_end}
{p2coldent:* {opt area}({it:area_opt})}get population by area, where {it:area_opt} can be {it:total} (default), {it:c_kom} (by municipality), {it:c_reg} (by region), or {it:all} (municipality, county, and region) ~. {p_end}
{synoptline}
{syntab:Other options}
{synopt:{opt clear}}specifies that it is okay to replace the data in memory, even though the current data have not been saved to disk.{p_end}
{p2coldent:* {opt val:lab}({it:val_opt})}return sex/age/area in {it:code} (default), {it:values}, or {it:both}.{p_end}
{p2coldent:* {opt noconvert}}disables convertion of pre-2007 municipalities into in new municipalities/regions.{p_end}
{p2coldent:^ {opt q:uarter}({it:int})}specifies which quarter to get population for, where {it:int} can be 1-4 or 0 (for all). Default is Q1 {p_end}
{synopt:{opt debug}}make program output more detailed. Enable to trouble-shoot program.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2} * Old municipalities cannot be converted into new municipalities or regions for {opt val:lab}({it:value}|{it:both}) and {opt area}({it:all}). Either change to {opt val:lab}({it:code}) and {opt area}({it:c_kom}|{it:c_reg}) or specify {opt noconvert} to disable convertion.{p_end}
{p 4 6 2} ~ Old municipalities and counties are available 1971-2006 and new municipalities and regions are available 2007-2020.{p_end}
{p 4 6 2} ^ Quarterly populations are only available since 2008.{p_end}


{title:Description}

{pstd}
{cmd:dstpop} makes it easy to download the Danish population for each year from {it:fyear} to {it:tyear} (range 1971-2020).

{pstd}
Population can be total Danish population (default), or by sex, age, area, or a combination of all three.

{pstd}
DST stores population data in four different registries (BEF1, BEF1A, BEF1A07, and FOLK1A). Each registry cover different time periods and have slightly different data structures, which makes DST's API rather cumbersome to use. Importantly, the Structural Reform ("Kommunalreformen") in 2007 combined the previous 271 municipalities into 98 larger municipalities. At the same time, the 16 administrative counties ("amter") were replaced by 5 regions. Some municipalities continued unchanged, while others were combined and split. This introduce a databreach and some municipalities cannot be directly compared geographically (value labels marked with *).

{pstd}
Data is from BEF1 (1971-2002), BEF1A (2003-2006), BEF1A07 (2007), and FOLK1A (2008-)

{pstd}
Data is downloaded using the API provided by Statistics Denmark (DST or "Danmarks Statistik").

{pstd}
DST's API is documented {browse "https://www.dst.dk/da/Statistik/statistikbanken/api":here}.


{title:Dependencies}
{cmd:dstpop} requires {cmd:dkconvert} to convert old municipalities.

{cmd:dkconvert} can be installed with the {cmd:github} package by E.F. Haghish ({browse "https://github.com/haghish/github":link})

. net install github, from("https://haghish.github.io/github/")
. github install andreasebbehoj/dkconvert

Otherwise, the convertion function can be deactivated by the option {opt noconvert}.


{title:Remarks}

{pstd}
For more details on {cmd:dstpop}, including how to update, see {browse "https://github.com/andreasebbehoj/dstpop":the readme.md at GitHub}


{title:Examples}

Download total Danish population by year 1971-2020
. dstpop, fy(1971) ty(2020) clear

Population 2000-2020 by each municipality
. dstpop, fy(2000) ty(2020) area(c_kom) clear

Population 2000-2020 by each region
. dstpop, fy(2000) ty(2020) area(c_reg) clear

Population 1977-1990 in the old municipalities (pre-2007)
. dstpop, fy(1977) ty(1990) area(c_kom) noconvert clear

Population 2000-2020 by sex and age
. dstpop, fy(2000) ty(2020) sex age clear

Population 1971-2020 by sex, age, and municipality (large file!)
. dstpop, fy(1971) ty(2020) sex age area(c_kom) clear


{title:References}

{pstd}
The population data is hosted by Statistics Denmark. Documentation on methods, data breaks, the Structural Reform, etc, can be found at {browse "https://www.dst.dk/en/Statistik/dokumentation/documentationofstatistics/the-population":their webpage}.


{title:Author}
Andreas Ebbehoj, MD & PhD student, Aarhus University, Denmark
