# dstpop
 Stata program for importing the Danish population by year, area, sex, age, and marital status, using Statistics Denmark's API.

## Introduction
Statistics Denmark (DST or "Danmarks Statistic") offer a free and open API for downloading public data, including the Danish population since 1971. The population is available in total, by area, sex, age, or marital status, or by a combination of those. Due to different data breaches, population data is stored in several registries (BEF1, BEF1A, BEF1A07, and FOLK1A) with slightly different data structures.

This makes it rather time-consuming to get Danish population numbers over a long time period. Also, due to the Structural Reform ("Kommunalreformen") in 2007, the 298 old municipalities were combined into 98 new municipalities, making the process even more cumbersome.

The purpose of this package is to enable easy download of the Danish population 1971-2020 with options for downloading population by area, sex, age, and marital status. The included **dkconvert** package also provide the option of converting old pre-2007 municipalities into new municipalities or regions.


## Installation
```stata
net install github, from("https://haghish.github.io/github/")
github install andreasebbehoj/dstpop
```

## Syntax
`dstpop, clear year(numlist) [area(c_kom|c_reg|total)] [sex] [age] [maritalstatus] [noconvert] [other options]`

For detailed documentation and examples, install **dstpop** in Stata and type `help dstpop`.


## Dependencies
**dstpop**  requires the **dkconvert** and **labutil** packages. Both should be installed automatically with but can otherwise be manually installed in Stata:

```stata
ssc install labutil
github install andreasebbehoj/dkconvert
```

## Update
```stata
github uninstall dstpop
github uninstall dkconvert
github install andreasebbehoj/dstpop
```
