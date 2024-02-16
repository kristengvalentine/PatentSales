cd "*****insert filepath here******\Data\patent_trade_data"

****************************************************************************************************************************************************************
***********************run matchit - between assignment dataset and patentsview*********************************************************************************
****************************************************************************************************************************************************************
use assignment_names_clean_stem2, clear

matchit assign_id assign_name_clean using patview_name_1_final_clean_stem2.dta, idusing(patview_id) txtusing(patview_name_clean) weights(simple) similmethod(token) override time diagnose stopwordsauto swt(0.1)

save all_match_clean, replace
display "$S_TIME  $S_DATE"

use all_match_clean, clear
gen similscore_inv = -1*similscore
sort assign_id similscore_inv
duplicates drop assign_id, force
keep if similscore>.9
save best_match_clean, replace


*merge in name data to link with assignment dataset
use best_match_clean, clear
merge 1:1 assign_id using assignment_names_clean_stem2
drop if _m==2
drop _m

merge m:1 patview_id using patview_name_1_final_clean_stem2
drop if _m==2
drop _m
gen len=length(assign_name)
sum len, d
recast str386 assign_name
save best_match_clean_final, replace





****************************************************************************************************************************************************************
***********************run matchit - between assignment dataset and npe dataset*********************************************************************************
****************************************************************************************************************************************************************

use assignment_names_clean_stem2, clear

matchit assign_id assign_name_clean using npe_names_clean_stem2.dta, idusing(npe_id) txtusing(npe_name_clean) weights(simple) similmethod(token) override time diagnose stopwordsauto swt(0.1)

save npe_all_match_clean, replace
display "$S_TIME  $S_DATE"

use npe_all_match_clean, clear


