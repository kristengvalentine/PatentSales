cd "*****insert filepath here******\Data\patent_trade_data"

********************************************************************************************************************************************************************************************************************
******************Patent Trades*************************************************************************************************************************************************************************************
********************************************************************************************************************************************************************************************************************

*start with assignment data and merge in name matched data
use sale_assignments, clear
keep rf_id
duplicates drop
merge 1:m rf_id using "*****insert filepath here******\Data\Assignment data\assignor.dta", keepusing(or_name exec_dt)
drop if _m==2
drop _m
duplicates drop
save rfid_seller, replace

use sale_assignments, clear
keep rf_id
duplicates drop
merge 1:m rf_id using "*****insert filepath here******\Data\Assignment data\assignee.dta", keepusing(ee_name)
drop if _m==2
drop _m
duplicates drop
save rfid_buyer, replace

*seller dataset
use rfid_seller, clear
gen assign_name=or_name
merge m:1 assign_name using best_match_stem_final
keep if _m==3
drop _m len

*merge in org type
merge m:m patview_name using patview_orgtype_final
keep if _m==3
drop _m
save rfid_seller_matched, replace

*buyer dataset
use rfid_buyer, clear
gen assign_name=ee_name
merge m:1 assign_name using best_match_stem_final
keep if _m==3
drop _m len

*merge in org type
merge m:m patview_name using patview_orgtype_final
keep if _m==3
drop _m
save rfid_buyer_matched, replace


*create NPE name matched files
use assignment_names_clean_stem2, clear
gen len=length(assign_name)
sum len, d
recast str428 assign_name
save assignment_names_clean_stem3, replace

*****SELLER
use rfid_seller, clear
gen assign_name=or_name
drop or_name exec_dt
*bring in assign_id to merge in npe data
merge m:1 assign_name using assignment_names_clean_stem3, keepusing(assign_id)
keep if _m==3
drop _m

merge m:1 assign_id using orgtype_npe_id_temp1, keepusing(npe_id npe_name org_id permno)
keep if _m==3
drop _m

gen npe=1

save rfid_seller_npe, replace

*****BUYER
use rfid_buyer, clear
gen assign_name=ee_name
drop ee_name 

merge m:1 assign_name using assignment_names_clean_stem3, keepusing(assign_id)
keep if _m==3
drop _m

merge m:1 assign_id using orgtype_npe_id_temp1, keepusing(npe_id npe_name org_id permno)
keep if _m==3
drop _m

gen npe=1

save rfid_buyer_npe, replace

********************************************************************************************************************************************************************************************************************
******************Consolidate to sale level and remove within entity transfers**************************************************************************************************************************************
********************************************************************************************************************************************************************************************************************

*begin with assignment data that already removes non-sales. see "2-prep_assignment.do" file
**dataset is at the sale-patent level
use sale_assignments, clear

*calculate variables at the sale level
foreach var in lemon app_sale grant_sale page_count{
bysort rf_id: egen `var'_sum=sum(`var')
}
foreach var in lemon app_sale age_app grant_sale age_grant{
bysort rf_id: egen `var'_avg=mean(`var')
}
bysort rf_id: egen tot_pats=count(doc_num)
keep rf_id exec_dt_max exec_dt_min sale_year_max sale_year_min tot_pats page_count *_sum *_avg
duplicates drop
duplicates report rf_id

save sale_level, replace

*bring in variables about parties to the transaction
use sale_level, clear
merge 1:m rf_id using "*****insert filepath here******\Data\Assignment data\assignor.dta", keepusing(or_name)
drop if _m==2
drop _m
bysort rf_id: egen no_seller_all=count(or_name)
drop or_name
duplicates drop
duplicates report rf_id

merge 1:m rf_id using "*****insert filepath here******\Data\Assignment data\assignee.dta", keepusing(ee_name)
drop if _m==2
drop _m
bysort rf_id: egen no_buyer_all=count(ee_name)
drop ee_name
duplicates drop
duplicates report rf_id

merge 1:m rf_id using rfid_seller_matched, keepusing(permno pub prv org_id)
drop if _m==2
drop _m
foreach var in permno pub prv org_id{
rename `var' `var'_seller
}

merge m:m rf_id using rfid_buyer_matched, keepusing(permno pub prv org_id)
drop if _m==2
drop _m
foreach var in permno pub prv org_id{
rename `var' `var'_buyer
}
format org_id_buyer %12.0f
format org_id_seller %12.0f

**next bring in npe identification (see code at end of this file on line 264 - need to run first)
*npe buyer
merge m:m rf_id using rfid_buyer_npe, keepusing(npe_id npe)
drop if _m==2
drop _m
foreach var in npe_id npe{
rename `var' `var'_buyer
}

replace prv_buyer=1 if npe_id_buyer!=.&prv_buyer==.
replace pub_buyer=0 if npe_id_buyer!=.&pub_buyer==.
*max org_id = 39001501696
*max npe_id = 234907
replace org_id_buyer = npe_id_buyer+1000000000000 if npe_id_buyer!=. & org_id_buyer==.
format org_id_buyer %30.0f


*npe seller
merge m:m rf_id using rfid_seller_npe, keepusing(npe_id npe)
drop if _m==2
drop _m
foreach var in npe_id npe{
rename `var' `var'_seller
}

replace prv_seller=1 if npe_id_seller!=.&prv_seller==.
replace pub_seller=0 if npe_id_seller!=.&pub_seller==.
replace org_id_seller = npe_id_seller+1000000000000 if npe_id_seller!=. & org_id_seller==.
format org_id_seller %30.0f


**bring in SICH completness check - see code below
merge m:1 org_id_buyer using orgtype_npe_id_temp2, keepusing(npe_buyer2)
drop if _m==2
drop _m
merge m:1 org_id_seller using orgtype_npe_id_temp2, keepusing(npe_seller2)
drop if _m==2
drop _m
replace npe_buyer=1 if npe_buyer2==1
replace npe_seller=1 if npe_seller2==1
drop npe_seller2 npe_buyer2


*need to fill in the npe_buyer/seller variables within an org_id
foreach var in seller buyer{
bysort org_id_`var': egen npe_`var'2=sum(npe_`var')
replace npe_`var'=1 if npe_`var'2>0
drop npe_`var'2
}

*delete the npe_id* vars as they are not informative when missing within an org_id group
drop npe_id_buyer npe_id_seller


*reduce to transactions that have an entity we've identified on at least one side of the transaction
*doesn't matter if prv_buyer==0, the count function still includes it
bysort rf_id: egen no_prv_b=count(prv_buyer)
bysort rf_id: egen no_prv_s=count(prv_seller)
drop if no_prv_b==0 & no_prv_s==0
drop no_prv_s no_prv_b

replace npe_buyer=0 if npe_buyer==.
replace npe_seller=0 if npe_seller==.


*remove instances where the same permno exists on both sides of the transaction
duplicates tag rf_id, gen(dup)
tab dup
*93% of transactions don't have more than one buyer or seller


*see https://www.statalist.org/forums/forum/general-stata-discussion/general/1673711-removing-groups-with-the-same-value-occurring-for-any-observation-in-the-group
sort rf_id
rangestat (count) matched = org_id_buyer, by(rf_id) interval(org_id_seller org_id_buyer org_id_buyer)
replace matched = 0 if missing(matched)
by rf_id (matched), sort: replace matched = matched[_N]
drop if matched
drop matched dup
duplicates drop

*winsorize data
winsor2 tot_pats page_count no_seller no_buyer *_sum *_avg, replace

*merge in type of assignment
merge m:1 rf_id using "*****insert filepath here******\Data\Assignment data\assignment_conveyance.dta", keepusing(convey_ty)
drop if _m==2
drop _m

save total_sales_20230202, replace

*count if permno_buyer==permno_seller & permno_buyer!=. & permno_seller!=.
*0
*count if org_id_buyer ==org_id_seller
*0

*****************************************************************************************************
*************************link rf_id to patent level data*********************************************
*****************************************************************************************************
*start with patent level assignment data
use "*****insert filepath here******\Data\Assignment data\documentid.dta",clear
gen patent_id=grant_doc_num
keep rf_id patent_id
drop if patent_id==""
duplicates drop
merge m:1 patent_id using g_patent_combo2
drop if _m==2
drop _m
save total_sale_patent, replace


*****************************************************************************************************
*************************identify NPEs*********************************************
*****************************************************************************************************
**The 2b-npe_names.do and 4-matchit.do files identify NPEs and match the assignment data to NPEs based on name
**there are multiple potential matches for a given NPE name and it's unclear whether one NPE name should map to multiple assignee names or not
**so we'll leverage the above work that reconciled the assign_id in the assignment dataset to the org_id that represents the reconciled Kogan/PatentsView data to let us know if there should be a common entity
use rfid_seller_matched, clear
keep assign_id org_id
duplicates drop
gen datasetname="seller"
save seller_orgmatch_temp, replace

use rfid_buyer_matched, clear
keep assign_id org_id
duplicates drop
gen datasetname="buyer"
save buyer_orgmatch_temp, replace

use buyer_orgmatch_temp, clear
append using seller_orgmatch_temp
*double check for consistency across buyer/seller datasets
drop datasetname
duplicates drop
sort org_id assign_id
duplicates report assign_id
*save dataset of unique org_id assign_id
save orgmatch, replace


*bring in permno to see if some of the unintuitive matches are due to the kogan reconciliation
use patview_orgtype_final, clear
keep org_id permno
duplicates drop
save orgtype_permno_temp, replace

*bring in the org_id for the NPEs with a name match
use npe_all_match_stem, clear
merge m:1 assign_id using orgmatch
drop if _m==2
drop _m
sort npe_id org_id

merge m:1 org_id using orgtype_permno_temp, keepusing(permno)
drop if _m==2
drop _m

*bring in full names on either side
merge m:1 npe_id using npe_names_clean_stem2, keepusing(npe_name)
drop if _m==2
drop _m

merge m:1 assign_id using assignment_names_clean_stem2, keepusing(assign_name)
drop if _m==2
drop _m

*retain best match within an org_id
gen similscore_inv = -1*similscore
sort org_id similscore_inv
**problem here is that there is not always an org_id for NPEs since they do not have to show up in the patent grant dataset, so removing duplicates by org_id removes all the blank org_ids
duplicates drop org_id if org_id!=., force
*by manual inspection, seems like there are more false positives and so use a high threshold for retaining a match
keep if similscore>.999

sort assign_id
duplicates drop assign_id, force

save npe_best_match_stem_final, replace



*goal is to determine if a given org_id should be identified as an NPE or not
use npe_best_match_stem_final, clear
keep org_id
duplicates drop
gen npe=1
gen org_id_buyer=org_id
gen org_id_seller=org_id
save orgtype_npe, replace

********
*identify the specific NPE identify rather than just an indicator for use in the sales data
********
**The strategy is to just use our prior assign_id/org_id mapping and identify within an assign_id/org_id if that is an npe or not
use npe_best_match_stem_final, clear
******check for false positives
format org_id %12.0f

**check to see if a given org_id is mapped to only one assign_id
sort org_id npe_id
duplicates tag org_id, gen(dup)
count if dup>0&org_id!=.
drop dup
sort npe_id
duplicates tag npe_id, gen(dup)
tab dup

*the duplicates seem to be when the same npe_id gets appropriately mapped to multiple assign_id/org_ids
*in these cases, we want to override the org_id with the npe_id, much like we did for the permno
*manually inspecting the duplicates, it looks like those with only a few duplicates are appropriately the same entity based on the name
*but those with a higher number of duplicates seem to need more editing. e.g., the npe_name "Technologies, S.A." has more false positivessort npe_id org_id
sort npe_id dup
*browse assign_id npe_id org_id permno npe_name assign_name dup if dup>0
***copied over to an excel file to manually adjust

drop if assign_id==933881
drop if assign_id==1144949
drop if assign_id==1062933
drop if assign_id==1026343
drop if assign_id==398254
drop if assign_id==1090053
drop if assign_id==176656
drop if assign_id==1102825
drop if assign_id==268090
drop if assign_id==964514
drop if assign_id==925922
drop if assign_id==316242
drop if assign_id==53952
drop if assign_id==14450
drop if assign_id==988357
drop if assign_id==967135
drop if assign_id==1117324
drop if assign_id==988356
drop if assign_id==988358
drop if assign_id==81284
drop if assign_id==972774
drop if assign_id==79139
drop if assign_id==452107
drop if assign_id==21749
drop if assign_id==1023608
drop if assign_id==957212
drop if assign_id==1132530
drop if assign_id==256825
drop if assign_id==291599
drop if assign_id==326525
drop if assign_id==310258
drop if assign_id==464225
drop if assign_id==500840
drop if assign_id==420148
drop if assign_id==946017
drop if assign_id==46341
drop if assign_id==1044255
drop if assign_id==107066
drop if assign_id==1005947
drop if assign_id==541281
drop if assign_id==563388
drop if assign_id==953563
drop if assign_id==176158
drop if assign_id==54672
drop if assign_id==989004
drop if assign_id==1086051
drop if assign_id==1004953
drop if assign_id==96090
drop if assign_id==1122334
drop if assign_id==313019
drop if assign_id==993920
drop if assign_id==301311
drop if assign_id==400953
drop if assign_id==1057763
drop if assign_id==202974
drop if assign_id==79643
drop if assign_id==539416
drop if assign_id==982523
drop if assign_id==954076
drop if assign_id==962424
drop if assign_id==984940
drop if assign_id==195906
drop if assign_id==967716
drop if assign_id==409567
drop if assign_id==243465
drop if assign_id==832
drop if assign_id==277570
drop if assign_id==440139
drop if assign_id==1000273
drop if assign_id==1052156
drop if assign_id==43627
drop if assign_id==1008162
drop if assign_id==260639
drop if assign_id==364672
drop if assign_id==1061629
drop if assign_id==209466
drop if assign_id==104911
drop if assign_id==975961
drop if assign_id==1001851
drop if assign_id==427193
drop if assign_id==1005767
drop if assign_id==989348
drop if assign_id==994331
drop if assign_id==428290
drop if assign_id==275742
drop if assign_id==197097
drop if assign_id==27361
drop if assign_id==523940
drop if assign_id==1072147
drop if assign_id==538747
drop if assign_id==1106868
drop if assign_id==42600
drop if assign_id==1106096
drop if assign_id==1004046
drop if assign_id==463770
drop if assign_id==184015
drop if assign_id==213696
drop if assign_id==908773
drop if assign_id==957467
drop if assign_id==73366
drop if assign_id==276622
drop if assign_id==949217
drop if assign_id==1021500
drop if assign_id==1051460
drop if assign_id==74684
drop if assign_id==126648
drop if assign_id==339374
drop if assign_id==477141
drop if assign_id==1003012
drop if assign_id==444960
drop if assign_id==1015139
drop if assign_id==1124661
drop if assign_id==407488
drop if assign_id==324883
drop if assign_id==401
drop if assign_id==335625
drop if assign_id==1097386
drop if assign_id==902450
drop if assign_id==961663
drop if assign_id==536252
drop if assign_id==1050651
drop if assign_id==158615
drop if assign_id==398231
drop if assign_id==1086299
drop if assign_id==294650
drop if assign_id==1070059
drop if assign_id==957698
drop if assign_id==1153099
drop if assign_id==1034966
drop if assign_id==1038763
drop if assign_id==162327
drop if assign_id==156084
drop if assign_id==1041873
drop if assign_id==446075
drop if assign_id==194673
drop if assign_id==285682
drop if assign_id==562829
drop if assign_id==993205
drop if assign_id==515381
drop if assign_id==225577
drop if assign_id==1050917
drop if assign_id==290338
drop if assign_id==959225
drop if assign_id==975411
drop if assign_id==468133
drop if assign_id==559666
drop if assign_id==340197
drop if assign_id==376139
drop if assign_id==257121
drop if assign_id==911826
drop if assign_id==325328
drop if assign_id==1029261
drop if assign_id==39459
drop if assign_id==227867
drop if assign_id==340874
drop if assign_id==444677
drop if assign_id==376154
drop if assign_id==428393
drop if assign_id==1126927
drop if assign_id==541911
drop if assign_id==503148
drop if assign_id==548392
drop if assign_id==413457
drop if assign_id==1096096
drop if assign_id==60632
drop if assign_id==1077875
drop if assign_id==362888
drop if assign_id==1000223
drop if assign_id==435296
drop if assign_id==608817
drop if assign_id==474904
drop if assign_id==1044935
drop if assign_id==1084787
drop if assign_id==178954
drop if assign_id==1003224
drop if assign_id==534288
drop if assign_id==996075
drop if assign_id==1026624
drop if assign_id==1008224
drop if assign_id==131772
drop if assign_id==1111695
drop if assign_id==33363
drop if assign_id==149320
drop if assign_id==1135226
drop if assign_id==1020465
drop if assign_id==206737
drop if assign_id==134305
drop if assign_id==342920
drop if assign_id==263343
drop if assign_id==142362
drop if assign_id==959922
drop if assign_id==247231
drop if assign_id==1029094
drop if assign_id==990750
drop if assign_id==298980
drop if assign_id==900607
drop if assign_id==1036502
drop if assign_id==18162
drop if assign_id==54406
drop if assign_id==935919
drop if assign_id==91594
drop if assign_id==74093
drop if assign_id==443561
drop if assign_id==1063260
drop if assign_id==1022813
drop if assign_id==1024928
drop if assign_id==1054562
drop if assign_id==370822
drop if assign_id==518647
drop if assign_id==363275
drop if assign_id==1061359
drop if assign_id==659083
drop if assign_id==348246
drop if assign_id==189578
drop if assign_id==56827
drop if assign_id==130004
drop if assign_id==106249
drop if assign_id==1013024
drop if assign_id==979687
drop if assign_id==986999
drop if assign_id==1056466
drop if assign_id==140703
drop if assign_id==540709
drop if assign_id==1105355
drop if assign_id==1107625
drop if assign_id==1096097
drop if assign_id==533330
drop if assign_id==1098752
drop if assign_id==1097621
drop if assign_id==1008928
drop if assign_id==445187
drop if assign_id==369404
drop if assign_id==1109807
drop if assign_id==172230
drop if assign_id==482689
drop if assign_id==1081924
drop if assign_id==506293
drop if assign_id==948268
drop if assign_id==120875
drop if assign_id==293664
drop if assign_id==7467
drop if assign_id==85927
drop if assign_id==1074580
drop if assign_id==186861
drop if assign_id==398288
drop if assign_id==372096
drop if assign_id==1041280
drop if assign_id==106557
drop if assign_id==82843
drop if assign_id==499205
drop if assign_id==328797
drop if assign_id==492102
drop if assign_id==1136501
drop if assign_id==552957
drop if assign_id==1012563
drop if assign_id==402369
drop if assign_id==110448
drop if assign_id==105190
drop if assign_id==347651
drop if assign_id==495640
drop if assign_id==1043500
drop if assign_id==543336
drop if assign_id==1127815
drop if assign_id==1067572
drop if assign_id==193858
drop if assign_id==405345
drop if assign_id==202858
drop if assign_id==1102698
drop if assign_id==263910
drop if assign_id==467478
drop if assign_id==1060190
drop if assign_id==55591
drop if assign_id==52056
drop if assign_id==351069
drop if assign_id==390570
drop if assign_id==108876
drop if assign_id==147177
drop if assign_id==630651
drop if assign_id==914793
drop if assign_id==106986
drop if assign_id==53009
drop if assign_id==937724
drop if assign_id==987673
drop if assign_id==227638
drop if assign_id==12958
drop if assign_id==93619
drop if assign_id==82562
drop if assign_id==336219
drop if assign_id==1078805
drop if assign_id==542454
drop if assign_id==100985
drop if assign_id==1090866
drop if assign_id==906233
drop if assign_id==1011823
drop if assign_id==987830
drop if assign_id==483524
drop if assign_id==923023
drop if assign_id==1118993
drop if assign_id==1069079
drop if assign_id==1064418
drop if assign_id==1021806
drop if assign_id==150103
drop if assign_id==235042
drop if assign_id==359578
drop if assign_id==916743
drop if assign_id==134072
drop if assign_id==197522
drop if assign_id==434031
drop if assign_id==1060147
drop if assign_id==980206
drop if assign_id==1024189
drop if assign_id==79077
drop if assign_id==318528
drop if assign_id==469324
drop if assign_id==1077665
drop if assign_id==67471
drop if assign_id==198094
drop if assign_id==1013801
drop if assign_id==1025928
drop if assign_id==351696
drop if assign_id==1039968
drop if assign_id==1102848
drop if assign_id==174232
drop if assign_id==1123284
drop if assign_id==998262
drop if assign_id==84123
drop if assign_id==1003374
drop if assign_id==495955
drop if assign_id==1111467
drop if assign_id==415386
drop if assign_id==1053215
drop if assign_id==96913
drop if assign_id==334688
drop if assign_id==66487
drop if assign_id==107306
drop if assign_id==1128236
drop if assign_id==1012445
drop if assign_id==1085643
drop if assign_id==1143373
drop if assign_id==1128360
drop if assign_id==1090719
drop if assign_id==1061068
drop if assign_id==5811
drop if assign_id==205688
drop if assign_id==452349
drop if assign_id==965020
drop if assign_id==55430
drop if assign_id==1114326
drop if assign_id==795905
drop if assign_id==525546
drop if assign_id==914358
drop if assign_id==1124461
drop if assign_id==1128724
drop if assign_id==1051915
drop if assign_id==1091463
drop if assign_id==494592
drop if assign_id==520183
drop if assign_id==253274
drop if assign_id==74681
drop if assign_id==1022841
drop if assign_id==953575
drop if assign_id==487795
drop if assign_id==342830
drop if assign_id==222655
drop if assign_id==235773
drop if assign_id==276297
drop if assign_id==410665
drop if assign_id==1057287
drop if assign_id==963602
drop if assign_id==953448
drop if assign_id==969637
drop if assign_id==981329
drop if assign_id==999595
drop if assign_id==1095218
drop if assign_id==1128700
drop if assign_id==1075875
drop if assign_id==910683
drop if assign_id==553383
drop if assign_id==436219
drop if assign_id==1020110
drop if assign_id==1002990
drop if assign_id==1003386
drop if assign_id==320192
drop if assign_id==405546
drop if assign_id==1052211
drop if assign_id==1125229
drop if assign_id==1146700
drop if assign_id==103771
drop if assign_id==514667
drop if assign_id==160220
drop if assign_id==998170
drop if assign_id==396036
drop if assign_id==32624
drop if assign_id==974363
drop if assign_id==901420
drop if assign_id==239672
drop if assign_id==344206
drop if assign_id==167949
drop if assign_id==228706
drop if assign_id==1125651
drop if assign_id==1124279
drop if assign_id==88788
drop if assign_id==994383
drop if assign_id==1127031
drop if assign_id==355937
drop if assign_id==201599
drop if assign_id==136272
drop if assign_id==1018855
drop if assign_id==144137
drop if assign_id==1021664
drop if assign_id==1125151
drop if assign_id==1094272
drop if assign_id==1066873
drop if assign_id==300945
drop if assign_id==990903
drop if assign_id==127752
drop if assign_id==1136114
drop if assign_id==1082078
drop if assign_id==172869
drop if assign_id==205707
drop if assign_id==1136488
drop if assign_id==1126318
drop if assign_id==161163
drop if assign_id==552570
drop if assign_id==1133019
drop if assign_id==1091996
drop if assign_id==1043348
drop if assign_id==15161
drop if assign_id==493088
drop if assign_id==244030
drop if assign_id==969577
drop if assign_id==1136734
drop if assign_id==683581
drop if assign_id==40959
drop if assign_id==1027380
drop if assign_id==530353
drop if assign_id==85227
drop if assign_id==158161
drop if assign_id==404970
drop if assign_id==1025124
drop if assign_id==1010063
drop if assign_id==1096349
drop if assign_id==295238
drop if assign_id==162179
drop if assign_id==997111
drop if assign_id==210629
drop if assign_id==40044
drop if assign_id==545655
drop if assign_id==1152292
drop if assign_id==230243
drop if assign_id==1086773
drop if assign_id==6042
drop if assign_id==990028
drop if assign_id==928997
drop if assign_id==489008
drop if assign_id==490549
drop if assign_id==258403
drop if assign_id==268252
drop if assign_id==284924
drop if assign_id==977274
drop if assign_id==414682
drop if assign_id==302639
drop if assign_id==508376
drop if assign_id==999109
drop if assign_id==450341
drop if assign_id==473682
drop if assign_id==1074382
drop if assign_id==142854
drop if assign_id==770590
drop if assign_id==497639
drop if assign_id==1095193
drop if assign_id==980245
drop if assign_id==148968
drop if assign_id==362957
drop if assign_id==948795
drop if assign_id==341044
drop if assign_id==1146964
drop if assign_id==1128293
drop if assign_id==259876
drop if assign_id==429181
drop if assign_id==1081446
drop if assign_id==384255
drop if assign_id==1097586
drop if assign_id==488884
drop if assign_id==130574
drop if assign_id==957748
drop if assign_id==1095329
drop if assign_id==294880
drop if assign_id==971469
drop if assign_id==285041
drop if assign_id==14012
drop if assign_id==299665
drop if assign_id==528453
drop if assign_id==1087177
drop if assign_id==113902
drop if assign_id==370053
drop if assign_id==997834
drop if assign_id==294750
drop if assign_id==271521
drop if assign_id==209224
drop if assign_id==291125
drop if assign_id==98819
drop if assign_id==525815
drop if assign_id==1123868
drop if assign_id==339503
drop if assign_id==172788
drop if assign_id==1067348
drop if assign_id==518683
drop if assign_id==987498
drop if assign_id==307194
drop if assign_id==271118
drop if assign_id==1097012
drop if assign_id==335134
drop if assign_id==235518
drop if assign_id==530735
drop if assign_id==189612
drop if assign_id==1058147
drop if assign_id==153398
drop if assign_id==710964
drop if assign_id==482214
drop if assign_id==546858
drop if assign_id==314002
drop if assign_id==305771
drop if assign_id==75041
drop if assign_id==301274
drop if assign_id==605981
drop if assign_id==65649
drop if assign_id==1059155
drop if assign_id==1114659
drop if assign_id==444392
drop if assign_id==188693
drop if assign_id==9070
drop if assign_id==908537
drop if assign_id==351804
drop if assign_id==988377
drop if assign_id==7346
drop if assign_id==6827
drop if assign_id==207122
drop if assign_id==1043743
drop if assign_id==113183
drop if assign_id==112525
drop if assign_id==397833
drop if assign_id==1048843
drop if assign_id==1067415
drop if assign_id==469107
drop if assign_id==1079189
drop if assign_id==1046388
drop if assign_id==1130673
drop if assign_id==490019
drop if assign_id==1093640
drop if assign_id==1018541
drop if assign_id==521622
drop if assign_id==403512
drop if assign_id==895
drop if assign_id==135407
drop if assign_id==1044251
drop if assign_id==433031
drop if assign_id==323530
drop if assign_id==250421
drop if assign_id==1102783
drop if assign_id==1113032
drop if assign_id==1087401
drop if assign_id==229291
drop if assign_id==1018742
drop if assign_id==274242
drop if assign_id==113331
drop if assign_id==104079
drop if assign_id==979363
drop if assign_id==405021
drop if assign_id==182512
drop if assign_id==1076923
drop if assign_id==558325
drop if assign_id==240535
drop if assign_id==1081064
drop if assign_id==686778
drop if assign_id==400843
drop if assign_id==997279
drop if assign_id==976648
drop if assign_id==242200
drop if assign_id==1000420
drop if assign_id==1017670
drop if assign_id==583573
drop if assign_id==544384
drop if assign_id==1032892
drop if assign_id==379752
drop if assign_id==529978
drop if assign_id==1087510
drop if assign_id==946776
drop if assign_id==326276
drop if assign_id==255858
drop if assign_id==446283
drop if assign_id==1065409
drop if assign_id==561342
drop if assign_id==1011399
drop if assign_id==903793
drop if assign_id==155974
drop if assign_id==105699
drop if assign_id==76990
drop if assign_id==972477
drop if assign_id==1135879
drop if assign_id==116912
drop if assign_id==1099577
drop if assign_id==963977
drop if assign_id==985394
drop if assign_id==276812
drop if assign_id==247
drop if assign_id==206374
drop if assign_id==1047297
drop if assign_id==1088980
drop if assign_id==439596
drop if assign_id==101147
drop if assign_id==954208
drop if assign_id==925801
drop if assign_id==103381
drop if assign_id==106709
drop if assign_id==164637
drop if assign_id==1005713
drop if assign_id==1034239
drop if assign_id==956638
drop if assign_id==175100
drop if assign_id==450691
drop if assign_id==454429
drop if assign_id==9367
drop if assign_id==1081486
drop if assign_id==170771
drop if assign_id==1073146
drop if assign_id==1057910
drop if assign_id==69575
drop if assign_id==409744
drop if assign_id==1059619
drop if assign_id==414556
drop if assign_id==313998
drop if assign_id==817087
drop if assign_id==7391
drop if assign_id==425438
drop if assign_id==194515
drop if assign_id==950970
drop if assign_id==209462
drop if assign_id==130586
drop if assign_id==1061416
drop if assign_id==382699
drop if assign_id==1002346
drop if assign_id==1033804
drop if assign_id==1127508
drop if assign_id==1033153
drop if assign_id==1046735
drop if assign_id==291584
drop if assign_id==351458
drop if assign_id==934245
drop if assign_id==409911
drop if assign_id==272161
drop if assign_id==548039
drop if assign_id==331881
drop if assign_id==1060425
drop if assign_id==221119
drop if assign_id==9730
drop if assign_id==192552
drop if assign_id==200659
drop if assign_id==1088376
drop if assign_id==256019
drop if assign_id==220146
drop if assign_id==971642
drop if assign_id==1054344
drop if assign_id==332000
drop if assign_id==988527
drop if assign_id==970734
drop if assign_id==321351
drop if assign_id==1116600
drop if assign_id==146974
drop if assign_id==977584
drop if assign_id==233960
drop if assign_id==1106820
drop if assign_id==312577
drop if assign_id==284323
drop if assign_id==107980
drop if assign_id==236823
drop if assign_id==320800
drop if assign_id==169746
drop if assign_id==961447
drop if assign_id==1046832
drop if assign_id==179177
drop if assign_id==480186
drop if assign_id==1138807
drop if assign_id==1134075
drop if assign_id==388965
drop if assign_id==448687
drop if assign_id==389728
drop if assign_id==104718
drop if assign_id==350686
drop if assign_id==1118135
drop if assign_id==1146707
drop if assign_id==140969
drop if assign_id==1114547
drop if assign_id==442939
drop if assign_id==947234
drop if assign_id==1046554
drop if assign_id==963990
drop if assign_id==1060478
drop if assign_id==942946
drop if assign_id==91597
drop if assign_id==1083604
drop if assign_id==402261
drop if assign_id==1035406
drop if assign_id==139108
drop if assign_id==1089635
drop if assign_id==186931
drop if assign_id==1012805
drop if assign_id==1131633
drop if assign_id==342776
drop if assign_id==98515
drop if assign_id==480375
drop if assign_id==491800
drop if assign_id==480689
drop if assign_id==1083431
drop if assign_id==1088277
drop if assign_id==207867
drop if assign_id==1039919
drop if assign_id==155536
drop if assign_id==104229
drop if assign_id==961440
drop if assign_id==201032
drop if assign_id==71083
drop if assign_id==128885
drop if assign_id==260033
drop if assign_id==320025
drop if assign_id==984813
drop if assign_id==1102836
drop if assign_id==430763
drop if assign_id==234666
drop if assign_id==285228
drop if assign_id==242011
drop if assign_id==1142125
drop if assign_id==185485
drop if assign_id==246921
drop if assign_id==1070391
drop if assign_id==291165
drop if assign_id==159651
drop if assign_id==265736
drop if assign_id==229637
drop if assign_id==1074045
drop if assign_id==1019990
drop if assign_id==991135
drop if assign_id==1074574
drop if assign_id==74128
drop if assign_id==1037084
drop if assign_id==982017
drop if assign_id==952280
drop if assign_id==955262
drop if assign_id==903802
drop if assign_id==449750
drop if assign_id==544311
drop if assign_id==778766
drop if assign_id==1098703
drop if assign_id==160392
drop if assign_id==195339
drop if assign_id==565381
drop if assign_id==174503
drop if assign_id==56001
drop if assign_id==336536
drop if assign_id==150181
drop if assign_id==1138955
drop if assign_id==490745
drop if assign_id==523326
drop if assign_id==117297
drop if assign_id==1118587
drop if assign_id==1074170
drop if assign_id==952135
drop if assign_id==596886
drop if assign_id==1080913
drop if assign_id==30880
drop if assign_id==208457
drop if assign_id==1000164
drop if assign_id==975306
drop if assign_id==1054760
drop if assign_id==1042734
drop if assign_id==426012
drop if assign_id==781887
drop if assign_id==295016
drop if assign_id==106663
drop if assign_id==1120521
drop if assign_id==980952
drop if assign_id==111897
drop if assign_id==493124
drop if assign_id==285157
drop if assign_id==1033143
drop if assign_id==260557
drop if assign_id==431126
drop if assign_id==447029
drop if assign_id==518223
drop if assign_id==1015035
drop if assign_id==1113504
drop if assign_id==1092257
drop if assign_id==342516
drop if assign_id==1132068
drop if assign_id==452557
drop if assign_id==971978
drop if assign_id==173953
drop if assign_id==542577
drop if assign_id==929729
drop if assign_id==910875
drop if assign_id==1043172
drop if assign_id==201124
drop if assign_id==1072715
drop if assign_id==594822
drop if assign_id==1027912
drop if assign_id==1078590
drop if assign_id==476448
drop if assign_id==204232
drop if assign_id==195959
drop if assign_id==1011056
drop if assign_id==1080064
drop if assign_id==1030500
drop if assign_id==1041626
drop if assign_id==979275
drop if assign_id==938466
drop if assign_id==991997
drop if assign_id==98311
drop if assign_id==131071
drop if assign_id==363060
drop if assign_id==557062
drop if assign_id==981757
drop if assign_id==120687
drop if assign_id==406815
drop if assign_id==240546
drop if assign_id==1133480
drop if assign_id==549688
drop if assign_id==225613
drop if assign_id==75638
drop if assign_id==885391
drop if assign_id==458439
drop if assign_id==1056090
drop if assign_id==1024086
drop if assign_id==374556
drop if assign_id==114438
drop if assign_id==177297
drop if assign_id==987221
drop if assign_id==1112077
drop if assign_id==1033782
drop if assign_id==1158656
drop if assign_id==977606
drop if assign_id==543188
drop if assign_id==465040
drop if assign_id==245688
drop if assign_id==233676
drop if assign_id==1007163
drop if assign_id==1035732
drop if assign_id==1008525
drop if assign_id==1065017
drop if assign_id==170889
drop if assign_id==52710
drop if assign_id==992312
drop if assign_id==1035532
drop if assign_id==1114537
drop if assign_id==993819
drop if assign_id==595914
drop if assign_id==185930
drop if assign_id==69902
drop if assign_id==415592
drop if assign_id==960668
drop if assign_id==1095415
drop if assign_id==7731
drop if assign_id==990552
drop if assign_id==214578
drop if assign_id==930440
drop if assign_id==1062490
drop if assign_id==19805
drop if assign_id==1004311
drop if assign_id==12430
drop if assign_id==262622
drop if assign_id==306526
drop if assign_id==1139199
drop if assign_id==132136
drop if assign_id==962057
drop if assign_id==1014025
drop if assign_id==654485
drop if assign_id==613947
drop if assign_id==121842
drop if assign_id==530430
drop if assign_id==362582
drop if assign_id==1126085
drop if assign_id==1051884
drop if assign_id==518305
drop if assign_id==427795
drop if assign_id==1092718
drop if assign_id==352243
drop if assign_id==1070708
drop if assign_id==429882
drop if assign_id==1131598
drop if assign_id==135635
drop if assign_id==983133
drop if assign_id==1061513
drop if assign_id==1063114
drop if assign_id==364362
drop if assign_id==957405
drop if assign_id==417214
drop if assign_id==973612
drop if assign_id==992825
drop if assign_id==942132
drop if assign_id==178057
drop if assign_id==1081692
drop if assign_id==345200
drop if assign_id==1078652
drop if assign_id==238956
drop if assign_id==1062295
drop if assign_id==559956
drop if assign_id==1080156
drop if assign_id==460091
drop if assign_id==482564
drop if assign_id==1070188
drop if assign_id==998271
drop if assign_id==1112993
drop if assign_id==1119531
drop if assign_id==192928
drop if assign_id==452968
drop if assign_id==519611
drop if assign_id==74766
drop if assign_id==1020078
drop if assign_id==522546
drop if assign_id==32448
drop if assign_id==978138
drop if assign_id==157194
drop if assign_id==152394
drop if assign_id==1117182
drop if assign_id==944778
drop if assign_id==49250
drop if assign_id==1139860
drop if assign_id==1006512
drop if assign_id==555658
drop if assign_id==443278
drop if assign_id==493991
drop if assign_id==1135536
drop if assign_id==190604
drop if assign_id==1043010
drop if assign_id==317061
drop if assign_id==1135569
drop if assign_id==910992
drop if assign_id==209735
drop if assign_id==303545
drop if assign_id==1035751
drop if assign_id==333996
drop if assign_id==520709
drop if assign_id==28065
drop if assign_id==309966
drop if assign_id==122503
drop if assign_id==178767
drop if assign_id==537629
drop if assign_id==20164
drop if assign_id==76131
drop if assign_id==313544
drop if assign_id==1133020
drop if assign_id==226355
drop if assign_id==474564
drop if assign_id==399317
drop if assign_id==274089
drop if assign_id==995095
drop if assign_id==124464
drop if assign_id==974621
drop if assign_id==925911
drop if assign_id==510602
drop if assign_id==1020077
drop if assign_id==967045
drop if assign_id==983632
drop if assign_id==448961
drop if assign_id==1066316
drop if assign_id==165995
drop if assign_id==291499
drop if assign_id==460507
drop if assign_id==510391
drop if assign_id==148627
drop if assign_id==1038868
drop if assign_id==510502
drop if assign_id==944149
drop if assign_id==983042
drop if assign_id==1014034
drop if assign_id==1051032
drop if assign_id==1115859
drop if assign_id==449441
drop if assign_id==1027807
drop if assign_id==96245
drop if assign_id==161044
drop if assign_id==11991
drop if assign_id==1007533
drop if assign_id==512315
drop if assign_id==201415
drop if assign_id==1049654
drop if assign_id==158408
drop if assign_id==414295
drop if assign_id==950616
drop if assign_id==984365
drop if assign_id==114070
drop if assign_id==385917
drop if assign_id==249951
drop if assign_id==982032
drop if assign_id==1052039
drop if assign_id==55246
drop if assign_id==163874
drop if assign_id==357817
drop if assign_id==1004111
drop if assign_id==1077987
drop if assign_id==438069
drop if assign_id==185314
drop if assign_id==1034385
drop if assign_id==986153
drop if assign_id==1077477
drop if assign_id==294889
drop if assign_id==512680
drop if assign_id==486436
drop if assign_id==1085943
drop if assign_id==963128
drop if assign_id==1057836
drop if assign_id==20072
drop if assign_id==1032309
drop if assign_id==1110335
drop if assign_id==524437
drop if assign_id==121830
drop if assign_id==243883
drop if assign_id==1468
drop if assign_id==1137601
drop if assign_id==1071770
drop if assign_id==143264
drop if assign_id==249489
drop if assign_id==1086179
drop if assign_id==1000280
drop if assign_id==426755
drop if assign_id==280812
drop if assign_id==247347
drop if assign_id==430655
drop if assign_id==510234
drop if assign_id==520034
drop if assign_id==376114
drop if assign_id==476070
drop if assign_id==485632
drop if assign_id==231004
drop if assign_id==934219
drop if assign_id==1068921
drop if assign_id==877
drop if assign_id==910057
drop if assign_id==1134300
drop if assign_id==497727
drop if assign_id==985066
drop if assign_id==1109161
drop if assign_id==1049007
drop if assign_id==1019021
drop if assign_id==1031575
drop if assign_id==1094012
drop if assign_id==51862
drop if assign_id==170565
drop if assign_id==35023
drop if assign_id==1066425
drop if assign_id==254934
drop if assign_id==958411
drop if assign_id==1120103
drop if assign_id==996840
drop if assign_id==246591
drop if assign_id==1092716
drop if assign_id==1056789
drop if assign_id==1134436
drop if assign_id==985117
drop if assign_id==195967
drop if assign_id==411892
drop if assign_id==530389
drop if assign_id==1098585
drop if assign_id==1113180
drop if assign_id==1054354
drop if assign_id==957825
drop if assign_id==1081083
drop if assign_id==204915
drop if assign_id==1124276
drop if assign_id==77557
drop if assign_id==1125422
drop if assign_id==214479
drop if assign_id==913604
drop if assign_id==1015195
drop if assign_id==956940
drop if assign_id==1018235
drop if assign_id==186173


**now check for duplicates
drop dup
duplicates tag npe_id, gen(dup)
*these duplicates are appropriate instances where one npe_id is mapped to multiple assign_id because the assignment data doesn't have name standardization

*adjust the three instances where the npe name search revealed another assignment name should be linked to a permno.
replace org_id=10145 if assign_id==354264
replace org_id=92399 if assign_id==64179
replace org_id=81642 if assign_id==1038579

replace permno=10145 if assign_id==354264
replace permno=92399 if assign_id==64179
replace permno=81642 if assign_id==1038579

save orgtype_npe_id_temp1, replace

*****************
******then check for false negatives
*****************

*start with the patview_orgtype_final file created in the 1-prep_patview_permno.do file
use patview_orgtype_final, clear
*first, for public firms, bring in their SIC and classify those as NPEs as well (6794-Patent owners and lessors - Acacia is in this SIC code)
merge m:1 permno using permno_sic, keepusing(sich)
drop if _m==2
drop _m
gen npe=1 if sich==6794
keep if npe==1
keep org_id npe
duplicates drop 
*looks like only org_id 34936, 66368, and 81624 were identified as NPEs in both the stanford NPE dataset and the sic code
*looking to sich adds 29 additional org_id
gen org_id_buyer=org_id
gen org_id_seller=org_id
gen npe_buyer2=1
gen npe_seller2=1
save orgtype_npe_id_temp2, replace
