********************************************************************************************************************************************************************************************************************
******************Patent Trades*************************************************************************************************************************************************************************************
********************************************************************************************************************************************************************************************************************
*The patent assignment data is hosted by the USPTO and can be found here: https://www.uspto.gov/ip-policy/economic-research/research-datasets/patent-assignment-dataset
/*
Desired Output: list of patent numbers, execution date, record date, rf_id, and cleaned list of parties on either side of the transaction, party type (public/private/troll) and permno if applicable

*/

/*
Code Outline
1) use PatentsView data on disambiguated assignee names to identify all potential spellings for a given entity and have a unique ID and organization type
2) link the PatentsView unique ID to Kogan et al. permno/permco if applicable
3) in the assignment data, identify any instance of an assignee name with the spelling variations etc, and link to a PatentsView unique ID
4) clean up the assignment data so it's only true sales following Serrano 2010 things and removing sales within an entity
5) create applicable sales variables (e.g., number of patents in package, number of tech classes in package (or its concentration), number of applications, number of lemons (applications never granted) etc.
*/

cd "*****insert filepath here******\Data\patent_trade_data"


******************Prep PatentsView data**********************************************************************************************************************************************************
/*
1) Combine patent-level dataset
2) Prepare PatentsView assignee data to have org type for each unique ID

PatentsView data is updated regularly and can be found here: https://patentsview.org/download/data-download-tables
*/

****1a) combine patent-level datasets - first for granted patents
*bring in dates, current CPC
use "*****insert filepath here******\Data\Patent data\PatentsView_20221017\g_patent.dta", clear
*drop text fields to reduce dataset size
drop patent_title patent_abstract filename

*only retain utility patents
keep if patent_type=="utility"

*format date
gen patent_date2=date(patent_date,"YMD")
format patent_date2 %td
gen iyear=year(patent_date2)
tab iyear
drop patent_date
rename patent_date2 patent_date

*bring in first listed cpc
*create dataset of first-listed current cpc
use "*****insert filepath here******\Data\Patent data\PatentsView_20221017\g_cpc_current.dta",clear
sort patent_id cpc_sequence
bysort patent_id: egen num_cpc=count(cpc_group)
duplicates drop patent_id, force
tostring patent_id, replace
save g_cpc_first, replace

merge 1:1 patent_id using g_cpc_first
drop if _m==2
drop _m

*bring in application date
merge 1:1 patent_id using "*****insert filepath here******\Data\Patent data\PatentsView_20221017\g_application.dta", keepusing(application_id filing_date)
drop if _m==2
drop _m

*format date
gen filing_date2=date(filing_date,"YMD")
format filing_date2 %td
gen fyear=year(filing_date2)
tab fyear
drop filing_date
rename filing_date2 filing_date
replace filing_date=. if fyear<1800
replace filing_date=. if fyear>2022

*bring in pre-grant publication date for granted patents
merge 1:m patent_id using "*****insert filepath here******\Data\Patent data\PatentsView_20221017\pg_granted_patent_crosswalk.dta",keepusing(pgpub_id)
drop if _m==2
drop _m

merge m:1 pgpub_id using "*****insert filepath here******\Data\Patent data\PatentsView_20221017\pg_published_application.dta", keepusing(published_date)
drop if _m==2
drop _m

*format date
gen published_date2=date(published_date,"YMD")
format published_date2 %td
gen pyear=year(published_date2)
tab pyear
drop published_date
rename published_date2 published_date

*save dataset
save g_patent_combo, replace

*the above can have multiple rows for a given patent grant id due to multiple pre-grant publications or applications
*create dataset unique for each patent grant
use g_patent_combo, clear
drop application_id filing_date fyear pgpub_id published_date pyear
duplicates drop
save g_patent_combo2, replace







****1b) combine patent-level datasets - next for pre-grant publications ultimately not granted
*bring in dates, current CPC
use "*****insert filepath here******\Data\Patent data\PatentsView_20221017\pg_published_application.dta", clear
*drop text fields to reduce dataset size
drop application_title application_abstract rule_47_flag filename

*only retain utility patents
keep if patent_type=="utility"|patent_type=="new-utility"

*format date
foreach var in filing_date published_date{
gen `var'2=date(`var',"YMD")
format `var'2 %td

drop `var'
rename `var'2 `var'
}

gen fyear=year(filing_date)

gen pyear=year(published_date)


*bring in first listed cpc
*create dataset of first-listed current cpc
use "*****insert filepath here******\Data\Patent data\PatentsView_20221017\pg_cpc_current.dta",clear
sort pgpub_id cpc_sequence
bysort pgpub_id: egen num_cpc=count(cpc_group)
duplicates drop pgpub_id, force
tostring pgpub_id, replace
save pg_cpc_first, replace


merge 1:1 pgpub_id using pg_cpc_first
drop if _m==2
drop _m

*bring in patent_id to see if the patent was granted
merge 1:m pgpub_id using "*****insert filepath here******\Data\Patent data\PatentsView_20221017\pg_granted_patent_crosswalk.dta",keepusing(patent_id)
*keep only observations with no patent grant
keep if _m==1
drop _m patent_id

*save dataset
save pg_patent_combo, replace




******************PatentsView unique entity IDs and org type**********************************************************************************************************************************************************
***start with the raw assignee data that has multiple spellings/punctuation etc. for a given organization
***the pre-grant publication and granted patent datasets have the same unique assignee_id, so combine the two datasets

***************
***prep Kogan data for merging
***************
**Kogan et al. 2017 data is also updated regularly and can be found here: https://github.com/KPSS2017/Technological-Innovation-Resource-Allocation-and-Growth-Extended-Data
use "*****insert filepath here******\Data\Patent data\Kogan et al\KPSS_2020_public.dta", clear
merge 1:1 patent_num using "*****insert filepath here******\Data\Patent data\Kogan et al\patent_permco_permno_match_public_2020.dta", keepusing(permco)
drop _m
tostring patent_num, gen(patent_id)
save kogan_combo, replace



***************
***bring in Permnos to PatentsView data
***************

*start with link between patent and assignee tables that has the assignee_id
*then merge in names from CRSP and from disambiguated assignee file to reconcile differences
*once reconciled, clean up the disambiguated assignee file to have a single "name" variable (See code below) and no inconsistencies in type or permnos
*then merge in the cleaned up assignee_id to the rawassignee file to have a mapping from messy spelling/org names to the clean assignee_id that maps nicely to type and permno
use "E:\Dropbox\Research\KV3\Data\Patent data\PatentsView_20221017\g_assignee_not_disambiguated.dta", clear
duplicates drop
merge m:1 patent_id using kogan_combo, keepusing(permno permco iyear)
drop if _m==2
drop _m iyear

**reduce dataset to those with non-missing organization names
**If we left those in, that would mean any time we saw the names of those individuals, we would map them to a corporation.
**since inventors can move around, that wouldn't be appropriate. thus, we drop any missing an organization name. 
*given the small number of patents affected, this probably won't make much difference
drop if raw_assignee_organization==""
gen patview_name= strupper(raw_assignee_organization)

*only retain corporations
/*
PatentsView lists the following assignee types:
assignee type (1- Unassigned, 2 - US Company or Corporation, 3 - Foreign Company or Corporation, 4 - US Individual, 
5 - Foreign Individual, 6 - US Federal Government, 7 - Foreign Government, 8 - US County Government, 9 - US State Government. 
Note: A "1" appearing before any of these codes signifies part interest)
*/

keep if assignee_type==12|assignee_type==2|assignee_type==13|assignee_type==3

*bring in CRSP header name
*downloaded from https://wrds-www.wharton.upenn.edu/pages/get-data/center-research-security-prices-crsp/annual-update/stock-security-files/stock-header-info/ on 6/7/22
*really only used in the cases where we need to break a tie so that a signle assignee_id is only ever mapped to one permno
merge m:1 permno using crsp_header, keepusing(HCOMNAM)
drop if _m==2
drop _m
rename HCOMNAM crsp_name

*reduce to assignee level
keep assignee_id permno patview_name crsp_name
duplicates drop

**dataset that has the assignee_id to patview_name with all the variations linked
save assignee_permno_match_temp, replace

*************separate dataset into public and private
use assignee_permno_match_temp, clear
keep if permno==.
keep assignee_id patview_name
gen prv=1
save assignee_prv_temp, replace

use assignee_permno_match_temp, clear
keep if permno!=.
save assignee_pub_temp, replace


/*
EXAMINE MAPPING FROM ASSIGNEE NAME TO PERMNO
THERE ARE TIMES WHEN THE SAME ASSIGNEE_ID IS MAPPED TO MULTIPLE PERMNOS
IN THOSE CASES, USE A NAME MATCH TO CHOOSE A PERMNO

THERE ARE ALSO INSTANCES WHERE THE SAME PERMNO IS MAPPED TO MULTIPLE ASSIGNEE_IDS
IN THOSE CASES, WE ALLOW A GIVEN PERMNO TO BE MAPPED TO MULTIPLE ASSIGNEE_IDS

*/

***take care of duplicate permnos for a given assignee_id
*********
***1) USE A NAME MATCH TO CHOOSE A PERMNO 
*********

*start with observations that only have one permno per assignee_id
use assignee_pub_temp, clear
keep assignee_id permno
duplicates drop
bysort assignee_id: egen dup_permno_per_assign=count(permno)
drop if dup_permno_per_assign>1
save assignee_pub_temp1, replace

*create variable for number of duplicate permnos per assignee that is unique to the assignee_id (not the variations in spelling)
use assignee_pub_temp, clear
keep assignee_id permno
duplicates drop
bysort assignee_id: egen dup_permno_per_assign=count(permno)
keep assignee_id dup_permno_per_assign
duplicates drop
save pub_dups, replace

*clean up observations with duplicate permnos using name match
use assignee_pub_temp, clear
merge m:1 assignee_id using pub_dups, keepusing(dup_permno_per_assign)
drop _m

keep if dup_permno_per_assign>1
matchit crsp_name patview_name, weights(simple) similmethod(token) override time diagnose stopwordsauto swt(0.1)
*retain observation with the highest similarity score
gen similscore_inv = -1*similscore
sort assignee_id similscore_inv
duplicates drop assignee_id, force
*looks like retaining observations with a similscore >.1 does a decent job matching
keep if similscore>.1
keep assignee_id permno
duplicates drop
save assignee_pub_temp2, replace

*append datasets and save for name matching
use assignee_pub_temp1, clear
append using assignee_pub_temp2
drop dup_permno_per_assign
**final check that a single assignee maps to one permno
bysort assignee_id: egen dup_permno_per_assign=count(permno)
tab dup_permno_per_assign
drop dup_permno_per_assign
gen pub=1
save assignee_permno_match_1, replace


***************
****prepare rawassignee file for matchit routine
***************

**dataset that has the assignee_id to patview_name with all the variations linked - for use in matchit in STATA
*based on the g_assignee_not_disambiguated PatentsView dataset and includes only assignee_type = 2 or 3 (or 12/13) as well as raw_assignee_organization !=""
use assignee_permno_match_temp, clear
keep assignee_id patview_name
duplicates drop
duplicates report patview_name
gen pv_id=_n
save patview_name_1, replace




*create file linking assignee_id to reconciled organization type information
use assignee_permno_match_1, clear
append using assignee_prv_temp
drop patview_name
replace prv=0 if prv==.
replace pub=0 if pub==.
duplicates drop
*duplicates report assignee_id
*duplicates tag assignee_id , gen(dup)
*there are some instances where a given assignee is in both the public and private datasets because the permno wasn't initially linked to that assignee_id per the Kogan merge, but the later reconciliation step did
*if the later reconciliation identified an org as being public, classify the org as public. private is simply defined as an org per patentsview that does not have a permno link
sort assignee_id prv
duplicates drop assignee_id, force
save org_id, replace

*create file linking pv_id to org type
use patview_name_1, clear
merge m:1 assignee_id using org_id, keepusing(permno pub prv)
*the _m obs that didn't merge are those where we were unable to reconcile down to a unique permno within a given assignee_id
*above the code requires the name match to break ties to have a similarity score of at least 0.1
drop if _m==1
drop _m
save patview_orgtype, replace

*create a unique id for an entity - since a permno can be mapped to multiple assignees, use permno if available and then assignee_id after that
use patview_orgtype, clear
*the largest permno is 5 digits
keep assignee_id
duplicates drop
gen org_id=_n*100000
save orgtype_temp, replace

use patview_orgtype, clear
merge m:1 assignee_id using orgtype_temp, keepusing(org_id)
drop _m
gen org_id2=permno
replace org_id2=org_id if org_id2==.
drop org_id
rename org_id2 org_id
save patview_orgtype_final, replace


