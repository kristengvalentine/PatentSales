cd "*****insert filepath here******\Data\patent_litigation_data"

****************************************************************************************************************************************************************
***********************clean NPE name file***************************************************************************************************************
****************************************************************************************************************************************************************
*bring in NPE data from Stanford's dataset - obtained from https://npe.law.stanford.edu
/*
import delimited "*****insert filepath here******\Data\patent_litigation_data\asserters-with-codes-2023-01-05PST06-00-12.csv", bindquote(strict) encoding(utf8)
save asserters, replace

import delimited "*****insert filepath here******\Data\patent_litigation_data\cases-2023-01-05PST06-00-37.csv", bindquote(strict) encoding(utf8)
save cases, replace
*/

/*
Asserter categories obtained from https://npe.law.stanford.edu/cases
1 Acquired patents
2 University heritage or tie
3 Failed startup
4 Corporate heritage
5 Individual-inventor-started
6 University/ Government/ Non-profit 
7 Startup, pre-product
8 Product Company
9 Individual
10 Undetermined
11 Industry consortium
12 IP subsidiary of product company
13 Corporate-inventor-started company
*see also table 1 in Miller 2018 article in Stanford Technology Law Review:
Category 1 includes any NPE primarily in the business of asserting
patents it has acquired from other entities. We include in this category
large patent aggregators such as Acacia and Intellectual Ventures.
*/

*keep unique NPE names
use asserters, clear
*retain only NPEs
keep if assertercategory==1
keep asserter_id patentasserter
rename patentasserter npe_name
rename asserter_id npe_id
duplicates drop
save npe, replace
