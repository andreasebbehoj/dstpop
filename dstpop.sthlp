{smcl}
{* *! version 1.1.0  17aug2020}{...}
{title:dstpop}

{phang}
{bf:dstpop} {hline 2} Import Danish population by year, sex, age, and area, using Statistics Denmark's API.


{title:Syntax}

{p 8 17 2}
{cmd:dstpop}
{cmd:,}
{cmdab:y:ear}({it:numlist})
[{cmd:sex}]
[{cmd:age}]
[{cmd:area}({it:area_opt})]
[{cmdab:mar:italstatus}]
[{cmd:clear}]
[{it:other options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt y:ear}}get population from {it:year} (range 1971-2020).{p_end}
{syntab:Population by (optional):}
{synopt:{opt sex}}get population by sex.{p_end}
{synopt:{opt age}}get population by age.{p_end}
{synopt:{opt mar:italstatus}}get population by marital status.{p_end}
{p2coldent:* {opt area}({it:area_opt})}get population by area, where {it:area_opt} can be {it:total} (default), {it:c_kom} (by municipality), {it:c_reg} (by region), or {it:all} (municipality, county, and region). #{p_end}
{synoptline}
{syntab:Other options}
{synopt:{opt clear}}specifies that it is okay to replace the data in memory, even though the current data have not been saved to disk.{p_end}
{p2coldent:* {opt noconvert}}disables conversion of old municipalities into in new municipalities/regions and conversion of old marital status codes into new ones.{p_end}
{p2coldent:^ {opt q:uarter}({it:int})}specifies which quarter to get population for, where {it:int} can be 1-4 or 0 (for all). Default is Q1.{p_end}
{synopt:{opt debug}}make program output more detailed, such as the API URL. Enable to trouble-shoot program.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2} * Old municipalities cannot be converted into new municipalities or regions for {opt area}({it:all}). Either change to {opt area}({it:c_kom}|{it:c_reg}) or specify {opt noconvert} to disable convertion.{p_end}
{p 4 6 2} # Old municipalities and counties are available 1971-2006 and new municipalities and regions are available 2007-2020.{p_end}
{p 4 6 2} ^ Quarterly populations are only available since 2008.{p_end}


{title:Description}

{pstd}Statistics Denmark (DST) stores data on the Danish population 1971-2020 in four different registries (BEF1, BEF1A, BEF1A07, and FOLK1A). Each registry cover different time periods and have slightly different data structures, which makes DST's API rather cumbersome to use. DSTPOP automates this process.

{pstd}{cmd:dstpop} automates the process of downloading data on the Danish population from from BEF1 (1971-2002), BEF1A (2003-2006), BEF1A07 (2007), and FOLK1A (2008-) using DST' API.

{pstd}{cmd:dstpop} can download the total Danish population (default), by area, sex, age, marital status, or by a combination of those.


{title:Examples}

Download total Danish population by year 1971-2020
. dstpop, y(1971/2020) clear

Population in 1980, 1990, 2000, 2010 and 2020 by each municipality
. dstpop, y(1980(10)2020) area(c_kom) clear

Population 2015-2020 by each quarter
. dstpop, y(2015/2020) quarter(0) clear

Population 2000-2020 by each region
. dstpop, y(2000/2020) area(c_reg) clear

Population 1977-2006 in the old municipalities (pre-2007)
. dstpop, y(1977/2006) area(c_kom) noconvert clear

Population 2000-2020 by sex, age, and maritalstatus
. dstpop, y(2000/2020) sex age maritalstatus clear

Population 2015-2020 by sex, age, and municipality
. dstpop, y(2015/2020) sex age area(c_kom) clear


{title:Remarks}

{pstd}For more details on {cmd:dstpop}, including how to update, see {browse "https://github.com/andreasebbehoj/dstpop":the readme.md at GitHub}

{ul:Dependencies}
{pstd}{cmd:dstpop} requires {cmd:dkconvert} to convert old municipalities and to label regions/municipalities.

{pstd}{cmd:dkconvert} can be installed with the {cmd:github} package by E.F. Haghish ({browse "https://github.com/haghish/github":link})

. net install github, from("https://haghish.github.io/github/")
. github install andreasebbehoj/dkconvert

Alternatively, the convertion function can be deactivated by the option {opt noconvert}.

{ul:API limiations}
{pstd}As per June 2020, DST has imposed limitations on their API, so it is now only possible to download 500,000 cells per API call.

{pstd}This is mainly a problem, when downloading population by both {opt age} and {opt area} at the same time. To circumvent this, {cmd:dstpop} will download data for each separately when both options are specified. The syntax is the same, but the command now takes longer to run.

{pstd}However, this limitation does mean that it is not possible to specify all options at the same time (age, sex, marital status, and area) even for one year, and Stata will return the error "server refused to send file". To circumvent this, you will need to download data directly from DST' API using the "bulk format". Alternatively, you can manually write a loop that uses the DSTPOP subroutines for each registry (dstpop_BEF1, dstpop_BEF1A, dstpop_BEF1A07 and dstpop_BEF1A07). Contact me, if you need help with this.

{ul:The Structural Reform}
{pstd}In the 2007 Structural Reform ("Kommunalreformen"), the previous 271 Danish municipalities were combined into 98 larger municipalities. At the same time, the 16 administrative counties ("amter") were replaced by 5 regions. Some municipalities continued unchanged, while others were combined and split. This introduce a databreak and some municipalities cannot be compared before and after 2007.

{pstd}{cmd:dstpop} automatically adds the population of old municipalities that were split into the new municipalities, where the majority of their population went. To see details on how these split municipalities are handled, type:

. use "https://github.com/andreasebbehoj/dkconvert/raw/master/dkconvert_table.dta"


{title:References}

{pstd}
The population data is hosted by Statistics Denmark. Documentation on methods, data breaks, the Structural Reform, etc, can be found at {browse "https://www.dst.dk/en/Statistik/dokumentation/documentationofstatistics/the-population":their webpage}.

{pstd}
DST's API is documented {browse "https://www.dst.dk/da/Statistik/statistikbanken/api":here}.


{title:Author}
Andreas Ebbehoj, MD & PhD student, Aarhus University, Denmark
