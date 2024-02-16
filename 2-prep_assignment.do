********************************************************************************************************************************************************************************************************************
******************Patent Trades*************************************************************************************************************************************************************************************
********************************************************************************************************************************************************************************************************************

cd "*****insert filepath here******\Data\patent_trade_data"

******************
*prep datasets before merging in - prep the execution date
use "*****insert filepath here******\Data\Assignment data\assignor.dta",clear
keep rf_id exec_dt
duplicates drop
*some sales had multiple execution dates, so calculate the maximum execution date and minimum execution date
*probably just keep the max execution date (latest date), but we may want to know the minimum date as well for a lower bound
bysort rf_id: egen exec_dt_max=max(exec_dt)
bysort rf_id: egen exec_dt_min=min(exec_dt)
format exec_dt_max exec_dt_min %td
drop exec_dt
duplicates drop
duplicates report rf_id
save assignor_v2.dta, replace

*start with patent level assignment data
use "*****insert filepath here******\Data\Assignment data\documentid.dta",clear

*bring in execution dates
merge m:1 rf_id using assignor_v2
drop _m
gen sale_year_max=year(exec_dt_max)
gen sale_year_min=year(exec_dt_min)
/*
*there is no difference in execution dates 84% of the time
gen same=0
replace same=1 if exec_dt_max ==exec_dt_min
tab same
       same |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |  2,653,314       16.32       16.32
          1 | 13,600,751       83.68      100.00
------------+-----------------------------------
      Total | 16,254,065      100.00
*/

*merge in sale info
merge m:1 rf_id using "*****insert filepath here******\Data\Assignment data\assignment.dta", keepusing(file_id convey_text record_dt page_count)
drop _m
/*
*there are no duplicate record_dt within an rf_id
keep rf_id record_dt
duplicates drop
duplicates report rf_id
*/
*create unique document id number - most often a grant number
gen doc_num=grant_doc_num
replace doc_num=appno_doc_num if doc_num==""
drop if doc_num==""
duplicates drop
*there are duplicates because sometimes multiple applications are linked to one grant number, likely due to continuations
**so create variables using application data and then drop the application related variables to avoid duplicates

*create variable for applications not granted
*note this variable will be incorrectly coded one more often later in the sample period, but should be ameliorated with year FE
gen lemon=0
replace lemon=1 if grant_doc_num==""

*create variable to label patents transferred as applications and age at execution date
*about 2% of the time, the application date or grant date field is missing in the assignment data, meaning these variables are missing
gen app_sale=1 if exec_dt_min < grant_date & appno_date!=. & exec_dt_min!=. & grant_date!=.
replace app_sale=0 if app_sale!=1 & appno_date!=. & exec_dt_min!=. & grant_date!=.

gen age_app=(exec_dt_min-appno_date)/30.5
*sum age_app, d
*the application age is actually often below zero (5.8M out of 16.2M records and negative at the 25th percentile)
*my guess is this is due to applications that are part of a family and that the execution date is for an agreement that required later applications in the same family to be transferred as well.
*if that is the case, then applications should at least be dated prior to the record date
*count if appno_date> record_dt & appno_date !=. & record_dt!=.
* 131,816 records have an application date after the record date with the USPTO, so less than 1%. This seems to substantiate my guess.

*create variable to label patents transferred after grant date and age at execution date
gen grant_sale=1 if exec_dt_min > grant_date & exec_dt_min!=. & grant_date!=.
replace grant_sale=0 if grant_sale!=1 & exec_dt_min!=. & grant_date!=.

gen age_grant=(exec_dt_min-grant_date)/30.5 if grant_sale==1


drop title lang appno_doc_num appno_date appno_country pgpub_doc_num pgpub_date pgpub_country
duplicates drop
duplicates report rf_id doc_num
*there are still some instances with multiple doc_num due to missing grant_doc_num entries
*force removal of duplicates, retaining the record with a grant_doc_num
duplicates tag rf_id doc_num , gen(dup)
drop if dup>0 & lemon==1
duplicates report rf_id doc_num
drop dup

*there are instances with different age_app variables, so retain the smaller one
sort rf_id doc_num age_app
duplicates drop rf_id doc_num, force

*bring in assignment type
merge m:1 rf_id using "*****insert filepath here******\Data\Assignment data\assignment_conveyance.dta"
drop _m
duplicates report rf_id doc_num
save all_assignments, replace

*get rid of assignments that are to employers and related to security agreements/administrative changes
use all_assignments, clear
drop if employer_assign==1
/*
. tab convey_ty
  
  convey_ty |      Freq.     Percent        Cum.
------------+-----------------------------------
 assignment |  3,212,484       38.00       38.00
    correct |    588,028        6.96       44.95
     govern |    116,558        1.38       46.33
     merger |    405,021        4.79       51.12
    missing |     31,033        0.37       51.49
    namechg |  1,003,673       11.87       63.36
      other |     41,488        0.49       63.85
    release |  1,182,868       13.99       77.85
   security |  1,872,963       22.15      100.00
------------+-----------------------------------
      Total |  8,454,116      100.00

	  
browse convey_text if convey_ty =="govern"

see Serrano 2010 "First, because our main
interest in the new data ultimately lies in the reallocation of the ownership of patents for
technological purposes, we separate assignments recorded as administrative events, such as a
name change, a security interest, a correction, and so on."

Accordingly, we omit "correct", "namechg", "missing", "other", "security" and "release"
release looks like the secured party releases rights -having to do with a loan
*/

keep if convey_ty =="assignment" |convey_ty=="govern"|convey_ty=="merger"
duplicates drop
save sale_assignments, replace



