cd "*****insert filepath here******\Data\patent_trade_data"
set matsize 11000



****************************************************************************************************************************************************************
***********************clean name files*****************************************************************************************************************
****************************************************************************************************************************************************************
**start with list of assignments (rf_id) that are in our sample - not employer transfers, not clerical adjustments, not security interests
*from 2-prep_assignment.do file
use sale_assignments, clear
keep rf_id
duplicates drop
merge 1:m rf_id using "*****insert filepath here******\Data\Assignment data\assignor.dta", keepusing(or_name exec_dt)
drop if _m==2
drop _m
keep or_name
duplicates drop
rename or_name name
save assignor_names, replace

**start with list of assignments (rf_id) that are in our sample - not employer transfers, not clerical adjustments, not security interests
*from 2-prep_assignment.do file
use sale_assignments, clear
keep rf_id
duplicates drop
merge 1:m rf_id using "*****insert filepath here******\Data\Assignment data\assignee.dta", keepusing(ee_name)
drop if _m==2
drop _m
keep ee_name
duplicates drop
rename ee_name name
save assignee_names.dta, replace

*combine assignment dataset names into a unique set
use assignor_names, clear
append using assignee_names
duplicates drop
gen id=_n
save assignment_names, replace

*prepare patentsview and npe datasets (can loop over below)
use patview_name_1, clear
rename patview_name name
rename pv_id id
save patview_name_1_final, replace

*see 2b-npe_names.do file and *****insert filepath here******\Data\patent_litigation_data folder
use npe, clear
rename npe_name name
rename npe_id id
save npe_names, replace

*loop over patentsview versions of datasets
**will do assignment names separately as they need the code to identify a firm and it's too big to loop over
**code from NBER 2006 name standardization routines
foreach y in patview_name_1_final npe_names{
*****loop over datasets******
use `y', clear

gen standard_name = " "+trim(name)+" " 
replace standard_name=upper(standard_name)

** This section strips out all punctuation characters
** and replaces them with nulls
replace standard_name = subinstr( standard_name, "'",  "", 30)
replace standard_name = subinstr( standard_name, ";",  "", 30)
replace standard_name = subinstr( standard_name, "^",  "", 30)
replace standard_name = subinstr( standard_name, "<",  "", 30)
replace standard_name = subinstr( standard_name, ".",  "", 30)
replace standard_name = subinstr( standard_name, "`",  "", 30)
replace standard_name = subinstr( standard_name, "_",  "", 30)
replace standard_name = subinstr( standard_name, ">",  "", 30)
replace standard_name = subinstr( standard_name, "''", "", 30)
replace standard_name = subinstr( standard_name, "!",  "", 30)
replace standard_name = subinstr( standard_name, "+",  "", 30)
replace standard_name = subinstr( standard_name, "?",  "", 30)
replace standard_name = subinstr( standard_name, "(",  "", 30)
replace standard_name = subinstr( standard_name, "{",  "", 30)
replace standard_name = subinstr( standard_name, "\",  "", 30)
replace standard_name = subinstr( standard_name, ")",  "", 30)
replace standard_name = subinstr( standard_name, "$",  "", 30)
replace standard_name = subinstr( standard_name, "}",  "", 30)
replace standard_name = subinstr( standard_name, "|",  "", 30)
replace standard_name = subinstr( standard_name, ",",  "", 30)
replace standard_name = subinstr( standard_name, "%",  "", 30)
replace standard_name = subinstr( standard_name, "[",  "", 30)
replace standard_name = subinstr( standard_name, "*",  "", 30)
replace standard_name = subinstr( standard_name, "]",  "", 30)
replace standard_name = subinstr( standard_name, "/",  " ", 30) 
* BHH - need to keep names separate if joined by / 
replace standard_name = subinstr( standard_name, "@",  "", 30)
replace standard_name = subinstr( standard_name, ":",  "", 30)
replace standard_name = subinstr( standard_name, "~",  "", 30)
replace standard_name = subinstr( standard_name, "#",  "", 30)
replace standard_name = subinstr( standard_name, "-",  " ", 30) 
* BHH -need to keep names separate if joined by - 

replace standard_name = subinstr( standard_name, "  ", " ", 30) 
* BHH -recode double space to space   

********************standardize names*********************************************************************************************************************************
*use derwent_standardisation_BHH.do file
replace standard_name=upper(standard_name)

replace standard_name = subinstr( standard_name," A B "," AB ",1)
replace standard_name = subinstr( standard_name," A CALIFORNIA CORP "," CORP ",1)
replace standard_name = subinstr( standard_name," A DELAWARE CORP "," CORP ",1)
replace standard_name = subinstr( standard_name," AKTIEBOLAGET "," AB ",1)
replace standard_name = subinstr( standard_name," AKTIEBOLAG "," AB ",1)
replace standard_name = subinstr( standard_name," ACADEMY "," ACAD ",1)
replace standard_name = subinstr( standard_name," ACTIEN GESELLSCHAFT "," AG ",1)
replace standard_name = subinstr( standard_name," ACTIENGESELLSCHAFT "," AG ",1)
replace standard_name = subinstr( standard_name," AKTIEN GESELLSCHAFT "," AG ",1)
replace standard_name = subinstr( standard_name," AKTIENGESELLSCHAFT "," AG ",1)
replace standard_name = subinstr( standard_name," AGRICOLAS "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICOLA "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICOLES "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICOLE "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICOLI "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICOLTURE "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICULTURA "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICULTURAL "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICULTURE "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AKADEMIA "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIEI "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIE "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMII "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIJA "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIYA "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIYAKH "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIYAM "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIYAMI "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIYU "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMI "," AKAD ",1)
replace standard_name = subinstr( standard_name," ALLGEMEINER "," ALLG ",1)
replace standard_name = subinstr( standard_name," ALLGEMEINE "," ALLG ",1)
replace standard_name = subinstr( standard_name," ANTREPRIZA "," ANTR ",1)
replace standard_name = subinstr( standard_name," APARARII "," APAR ",1)
replace standard_name = subinstr( standard_name," APARATELOR "," APAR ",1)
replace standard_name = subinstr( standard_name," APPARATEBAU "," APP ",1)
replace standard_name = subinstr( standard_name," APPARATUS "," APP ",1)
replace standard_name = subinstr( standard_name," APPARECHHI "," APP ",1)
replace standard_name = subinstr( standard_name," APPAREILLAGES "," APP ",1)
replace standard_name = subinstr( standard_name," APPAREILLAGE "," APP ",1)
replace standard_name = subinstr( standard_name," APPAREILS "," APP ",1)
replace standard_name = subinstr( standard_name," APPAREIL "," APP ",1)
replace standard_name = subinstr( standard_name," APARATE "," APAR ",1)
replace standard_name = subinstr( standard_name," APPARATE "," APP ",1)
replace standard_name = subinstr( standard_name," APPLICATIONS "," APPL ",1)
replace standard_name = subinstr( standard_name," APPLICATION "," APPL ",1)
replace standard_name = subinstr( standard_name," APPLICAZIONE "," APPL ",1)
replace standard_name = subinstr( standard_name," APPLICAZIONI "," APPL ",1)
replace standard_name = subinstr( standard_name," ANPARTSSELSKABET "," APS ",1)
replace standard_name = subinstr( standard_name," ANPARTSSELSKAB "," APS ",1)
replace standard_name = subinstr( standard_name," A/S "," AS ",1)
replace standard_name = subinstr( standard_name," AKTIESELSKABET "," AS ",1)
replace standard_name = subinstr( standard_name," AKTIESELSKAB "," AS ",1)
replace standard_name = subinstr( standard_name," ASSOCIACAO "," ASSOC ",1)
replace standard_name = subinstr( standard_name," ASSOCIATED "," ASSOC ",1)
replace standard_name = subinstr( standard_name," ASSOCIATES "," ASSOCIATES ",1)
replace standard_name = subinstr( standard_name," ASSOCIATE "," ASSOCIATES ",1)
replace standard_name = subinstr( standard_name," ASSOCIATION "," ASSOC ",1)
replace standard_name = subinstr( standard_name," BETEILIGUNGSGESELLSCHAFT MBH "," BET GMBH ",1)
replace standard_name = subinstr( standard_name," BETEILIGUNGS GESELLSCHAFT MIT "," BET GMBH ",1)
replace standard_name = subinstr( standard_name," BETEILIGUNGSGESELLSCHAFT "," BET GES ",1)
replace standard_name = subinstr( standard_name," BESCHRANKTER HAFTUNG "," BET GMBH ",1)
replace standard_name = subinstr( standard_name," BROEDERNA "," BRDR ",1)
replace standard_name = subinstr( standard_name," BROEDRENE "," BRDR ",1)
replace standard_name = subinstr( standard_name," BRODERNA "," BRDR ",1)
replace standard_name = subinstr( standard_name," BRODRENE "," BRDR ",1)
replace standard_name = subinstr( standard_name," BROTHERS "," BROS ",1)
replace standard_name = subinstr( standard_name," BESLOTEN VENNOOTSCHAP MET "," BV ",1)
replace standard_name = subinstr( standard_name," BESLOTEN VENNOOTSCHAP "," BV ",1)
replace standard_name = subinstr( standard_name," BEPERKTE AANSPRAKELIJKHEID "," BV ",1)
replace standard_name = subinstr( standard_name," CLOSE CORPORATION "," CC ",1)
replace standard_name = subinstr( standard_name," CENTER "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRAAL "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRALA "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRALES "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRALE "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRAL "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRAUX "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRE "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRO "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRUL "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRUM "," CENT ",1)
replace standard_name = subinstr( standard_name," CERCETARE "," CERC ",1)
replace standard_name = subinstr( standard_name," CERCETARI "," CERC ",1)
replace standard_name = subinstr( standard_name," CHEMICALS "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMICAL "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMICKEJ "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMICKE "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMICKYCH "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMICKY "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMICZNE "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMICZNY "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMIE "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMII "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMISCHE "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMISCH "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMISKEJ "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMISTRY "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHIMICA "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMICE "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMICI "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMICO "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIC "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIEI "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIE "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIESKOJ "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMII "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIKO "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIQUES "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIQUE "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIYAKH "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIYAMI "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIYAM "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIYA "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIYU "," CHIM ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE FRANCAISE "," CIE FR ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE GENERALE "," CIE GEN ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE INDUSTRIALE "," CIE IND ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE INDUSTRIELLE "," CIE IND ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE INDUSTRIELLES "," CIE IND ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE INTERNATIONALE "," CIE INT ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE NATIONALE "," CIE NAT ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE PARISIENNE "," CIE PARIS ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE PARISIENN "," CIE PARIS ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE PARISIEN "," CIE PARIS ",1)
replace standard_name = subinstr( standard_name," COMPANIES "," CO ",1)
replace standard_name = subinstr( standard_name," COMPAGNIA "," CIA ",1)
replace standard_name = subinstr( standard_name," COMPANHIA "," CIA ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE "," CIE ",1)
replace standard_name = subinstr( standard_name," COMPANY "," CO ",1)
replace standard_name = subinstr( standard_name," COMBINATUL "," COMB ",1)
replace standard_name = subinstr( standard_name," COMMERCIALE "," COMML ",1)
replace standard_name = subinstr( standard_name," COMMERCIAL "," COMML ",1)
replace standard_name = subinstr( standard_name," CONSOLIDATED "," CONSOL ",1)
replace standard_name = subinstr( standard_name," CONSTRUCCIONES "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCCIONE "," CONSTR ",1) 
replace standard_name = subinstr( standard_name," CONSTRUCCION "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTIE "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTII "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTIILOR "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTIONS "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTION "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTORTUL "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTORUL "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTOR "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CO OPERATIVES "," COOP ",1)
replace standard_name = subinstr( standard_name," CO OPERATIVE "," COOP ",1)
replace standard_name = subinstr( standard_name," COOPERATIEVE "," COOP ",1)
replace standard_name = subinstr( standard_name," COOPERATIVA "," COOP ",1)
replace standard_name = subinstr( standard_name," COOPERATIVES "," COOP ",1)
replace standard_name = subinstr( standard_name," COOPERATIVE "," COOP ",1)
replace standard_name = subinstr( standard_name," INCORPORATED "," INC ",1)
replace standard_name = subinstr( standard_name," INCORPORATION "," INC ",1)
replace standard_name = subinstr( standard_name," CORPORATE "," CORP ",1)
replace standard_name = subinstr( standard_name," CORPORATION OF AMERICA "," CORP ",1)
replace standard_name = subinstr( standard_name," CORPORATION "," CORP ",1)
replace standard_name = subinstr( standard_name," CORPORASTION "," CORP ",1)
replace standard_name = subinstr( standard_name," CORPORATIOON "," CORP ",1)
replace standard_name = subinstr( standard_name," COSTRUZIONI "," COSTR ",1)
replace standard_name = subinstr( standard_name," DEUTSCHEN "," DDR ",1)
replace standard_name = subinstr( standard_name," DEUTSCHE "," DDR ",1)
replace standard_name = subinstr( standard_name," DEMOKRATISCHEN REPUBLIK "," DDR ",1)
replace standard_name = subinstr( standard_name," DEMOKRATISCHE REPUBLIK "," DDR ",1)
replace standard_name = subinstr( standard_name," DEPARTEMENT "," DEPT ",1)
replace standard_name = subinstr( standard_name," DEPARTMENT "," DEPT ",1)
replace standard_name = subinstr( standard_name," DEUTSCHES "," DEUT ",1)
replace standard_name = subinstr( standard_name," DEUTSCHEN "," DEUT ",1)
replace standard_name = subinstr( standard_name," DEUTSCHER "," DEUT ",1)
replace standard_name = subinstr( standard_name," DEUTSCHLAND "," DEUT ",1)
replace standard_name = subinstr( standard_name," DEUTSCHE "," DEUT ",1)
replace standard_name = subinstr( standard_name," DEUTSCH "," DEUT ",1)
replace standard_name = subinstr( standard_name," DEVELOPMENTS "," DEV ",1)
replace standard_name = subinstr( standard_name," DEVELOPMENT "," DEV ",1)
replace standard_name = subinstr( standard_name," DEVELOPPEMENTS "," DEV ",1)
replace standard_name = subinstr( standard_name," DEVELOPPEMENT "," DEV ",1)
replace standard_name = subinstr( standard_name," DEVELOP "," DEV ",1)
replace standard_name = subinstr( standard_name," DIVISIONE "," DIV ",1)
replace standard_name = subinstr( standard_name," DIVISION "," DIV ",1)
replace standard_name = subinstr( standard_name," ENGINEERING "," ENG ",1)
replace standard_name = subinstr( standard_name," EQUIPEMENTS "," EQUIP ",1)
replace standard_name = subinstr( standard_name," EQUIPEMENT "," EQUIP ",1)
replace standard_name = subinstr( standard_name," EQUIPMENTS "," EQUIP ",1)
replace standard_name = subinstr( standard_name," EQUIPMENT "," EQUIP ",1)
replace standard_name = subinstr( standard_name," ESTABLISHMENTS "," ESTAB ",1)
replace standard_name = subinstr( standard_name," ESTABLISHMENT "," ESTAB ",1)
replace standard_name = subinstr( standard_name," ESTABLISSEMENTS "," ESTAB ",1)
replace standard_name = subinstr( standard_name," ESTABLISSEMENT "," ESTAB ",1)
replace standard_name = subinstr( standard_name," ETABLISSEMENTS "," ETAB ",1)
replace standard_name = subinstr( standard_name," ETABLISSEMENT "," ETAB ",1)
replace standard_name = subinstr( standard_name," ETABS "," ETAB ",1)
replace standard_name = subinstr( standard_name," ETS "," ETAB ",1)
replace standard_name = subinstr( standard_name," ETUDES "," ETUD ",1)
replace standard_name = subinstr( standard_name," ETUDE "," ETUD ",1)
replace standard_name = subinstr( standard_name," EUROPAEISCHEN "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPAEISCHES "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPAEISCHE "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPAISCHEN "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPAISCHES "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPAISCHE "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPEAN "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPEENNE "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPEEN "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPEA "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPE "," EURO ",1)
replace standard_name = subinstr( standard_name," EINGETRAGENER VEREIN "," EV ",1)
replace standard_name = subinstr( standard_name," EXPLOATERINGS "," EXPL ",1)
replace standard_name = subinstr( standard_name," EXPLOATERING "," EXPL ",1)
replace standard_name = subinstr( standard_name," EXPLOITATIE "," EXPL ",1)
replace standard_name = subinstr( standard_name," EXPLOITATIONS "," EXPL ",1)
replace standard_name = subinstr( standard_name," EXPLOITATION "," EXPL ",1)
replace standard_name = subinstr( standard_name," FIRMA "," FA ",1)
replace standard_name = subinstr( standard_name," FABBRICAZIONI "," FAB ",1)
replace standard_name = subinstr( standard_name," FABBRICHE "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRICATIONS "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRICATION "," FAB ",1)
replace standard_name = subinstr( standard_name," FABBRICA "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRICA "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRIEKEN "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRIEK "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRIKER "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRIK "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRIQUES "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRIQUE "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRIZIO "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRYKA "," FAB ",1)
replace standard_name = subinstr( standard_name," FARMACEUTICA "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACEUTICE "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACEUTICHE "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACEUTICI "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACEUTICOS "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACEUTICO "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACEUTISK "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACEVTSKIH "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACIE "," FARM ",1)
replace standard_name = subinstr( standard_name," FONDATION "," FOND ",1)
replace standard_name = subinstr( standard_name," FONDAZIONE "," FOND ",1)
replace standard_name = subinstr( standard_name," FOUNDATIONS "," FOUND ",1)
replace standard_name = subinstr( standard_name," FOUNDATION "," FOUND ",1)
replace standard_name = subinstr( standard_name," FRANCAISE "," FR ",1)
replace standard_name = subinstr( standard_name," FRANCAIS "," FR ",1)
replace standard_name = subinstr( standard_name," F LLI "," FRAT ",1)
replace standard_name = subinstr( standard_name," FLLI "," FRAT ",1)
replace standard_name = subinstr( standard_name," FRATELLI "," FRAT ",1)
replace standard_name = subinstr( standard_name," GEBRODERS "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEBRODER "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEBROEDERS "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEBROEDER "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEBRUDERS "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEBRUDER "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEBRUEDERS "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEBRUEDER "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEB "," GEBR ",1)
replace standard_name = subinstr( standard_name," GENERALA "," GEN ",1)
replace standard_name = subinstr( standard_name," GENERALES "," GEN ",1)
replace standard_name = subinstr( standard_name," GENERALE "," GEN ",1)
replace standard_name = subinstr( standard_name," GENERAL "," GEN ",1)
replace standard_name = subinstr( standard_name," GENERAUX "," GEN ",1)
replace standard_name = subinstr( standard_name," GESELLSCHAFT "," GES ",1)
replace standard_name = subinstr( standard_name," GEWERKSCHAFT "," GEW ",1)
replace standard_name = subinstr( standard_name," GAKKO HOJIN "," GH ",1)
replace standard_name = subinstr( standard_name," GAKKO HOUJIN "," GH ",1)
replace standard_name = subinstr( standard_name," GUTEHOFFNUNGSCHUETTE "," GHH ",1)
replace standard_name = subinstr( standard_name," GUTEHOFFNUNGSCHUTTE "," GHH ",1)
replace standard_name = subinstr( standard_name," GOMEI GAISHA "," GK ",1)
replace standard_name = subinstr( standard_name," GOMEI KAISHA "," GK ",1)
replace standard_name = subinstr( standard_name," GOSHI KAISHA "," GK ",1)
replace standard_name = subinstr( standard_name," GOUSHI GAISHA "," GK ",1)
replace standard_name = subinstr( standard_name," GESELLSCHAFT MBH "," GMBH ",1)
replace standard_name = subinstr( standard_name," GESELLSCHAFT MIT BESCHRANKTER HAFTUNG "," GMBH ",1)
replace standard_name = subinstr( standard_name," GROUPEMENT "," GRP ",1)
replace standard_name = subinstr( standard_name," GROUPMENT "," GRP ",1)
replace standard_name = subinstr( standard_name," HANDELSMAATSCHAPPIJ "," HANDL ",1)
replace standard_name = subinstr( standard_name," HANDELSMIJ "," HANDL ",1)
replace standard_name = subinstr( standard_name," HANDELS BOLAGET "," HB ",1)
replace standard_name = subinstr( standard_name," HANDELSBOLAGET "," HB ",1)
replace standard_name = subinstr( standard_name," HER MAJESTY THE QUEEN IN RIGHT OF CANADA AS REPRESENTED BY THE MINISTER OF "," CANADA MIN OF ",1)
replace standard_name = subinstr( standard_name," HER MAJESTY THE QUEEN "," UK ",1)
replace standard_name = subinstr( standard_name," INDUSTRIAS "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIALS "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIAL "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIALA "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIALE "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIALIZARE "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIALIZAREA "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIALI "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIEELE "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIEI "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIELS "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIELLES "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIELLE "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIELL "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIEL "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIER "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIES "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRII "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIJ "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIYAKH "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIYAM "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIYAMI "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIYA "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIYU "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIA "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIE "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRI "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRY "," IND ",1)
replace standard_name = subinstr( standard_name," INGENIERIA "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIER "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURS "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURBUERO "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURBUREAU "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURBURO "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURGESELLSCHAFT "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURSBUREAU "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURTECHNISCHES "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURTECHNISCHE "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEUR "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIOERFIRMAET "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIORSFIRMAN "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIORSFIRMA "," ING ",1)
replace standard_name = subinstr( standard_name," INGENJORSFIRMA "," ING ",1)
replace standard_name = subinstr( standard_name," INGINERIE "," ING ",1)
replace standard_name = subinstr( standard_name," INSTITUTE FRANCAISE "," INST FR ",1)
replace standard_name = subinstr( standard_name," INSTITUT FRANCAIS "," INST FR ",1)
replace standard_name = subinstr( standard_name," INSTITUTE NATIONALE "," INST NAT ",1)
replace standard_name = subinstr( standard_name," INSTITUT NATIONAL "," INST NAT ",1)
replace standard_name = subinstr( standard_name," INSTITUTAMI "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTAMKH "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTAM "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTA "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTES "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTET "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTE "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTOM "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTOV "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTO "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTT "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTUL "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTU "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTY "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUT "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUUT "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITZHT "," INST ",1)
replace standard_name = subinstr( standard_name," INSTYTUT "," INST ",1)
replace standard_name = subinstr( standard_name," INSINOORITOMISTO "," INSTMSTO ",1)
replace standard_name = subinstr( standard_name," INSTRUMENTS "," INSTR ",1)
replace standard_name = subinstr( standard_name," INSTRUMENTATION "," INSTR ",1)
replace standard_name = subinstr( standard_name," INSTRUMENTE "," INSTR ",1)
replace standard_name = subinstr( standard_name," INSTRUMENT "," INSTR ",1)
replace standard_name = subinstr( standard_name," INTERNATL "," INT ",1)
replace standard_name = subinstr( standard_name," INTERNACIONAL "," INT ",1)
replace standard_name = subinstr( standard_name," INTERNATIONAL "," INT ",1)
replace standard_name = subinstr( standard_name," INTERNATIONALEN "," INT ",1)
replace standard_name = subinstr( standard_name," INTERNATIONALE "," INT ",1)
replace standard_name = subinstr( standard_name," INTERNATIONAUX "," INT ",1)
replace standard_name = subinstr( standard_name," INTERNATIONELLA "," INT ",1)
replace standard_name = subinstr( standard_name," INTERNAZIONALE "," INT ",1)
replace standard_name = subinstr( standard_name," INTL "," INT ",1)
replace standard_name = subinstr( standard_name," INTREPRINDEREA "," INTR ",1)
replace standard_name = subinstr( standard_name," ISTITUTO "," IST ",1)
replace standard_name = subinstr( standard_name," ITALIANA "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALIANE "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALIANI "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALIANO "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALIENNE "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALIEN "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALIAN "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALIA "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALI "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALO "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALY "," ITAL ",1)
replace standard_name = subinstr( standard_name," JUNIOR "," JR ",1)
replace standard_name = subinstr( standard_name," KOMMANDIT BOLAG "," KB ",1)
replace standard_name = subinstr( standard_name," KOMMANDIT BOLAGET "," KB ",1)
replace standard_name = subinstr( standard_name," KOMMANDITBOLAGET "," KB ",1)
replace standard_name = subinstr( standard_name," KOMMANDITBOLAG "," KB ",1)
replace standard_name = subinstr( standard_name," KOMMANDIT GESELLSCHAFT "," KG ",1)
replace standard_name = subinstr( standard_name," KOMMANDITGESELLSCHAFT "," KG ",1)
replace standard_name = subinstr( standard_name," KOMMANDIT GESELLSCHAFT AUF AKTIEN "," KGAA ",1)
replace standard_name = subinstr( standard_name," KOMMANDITGESELLSCHAFT AUF AKTIEN "," KGAA ",1)
replace standard_name = subinstr( standard_name," KUTATO INTEZETE "," KI ",1)
replace standard_name = subinstr( standard_name," KUTATO INTEZET "," KI ",1)
replace standard_name = subinstr( standard_name," KUTATOINTEZETE "," KI ",1)
replace standard_name = subinstr( standard_name," KUTATOINTEZET "," KI ",1)
replace standard_name = subinstr( standard_name," KABUSHIKI GAISHA "," KK ",1)
replace standard_name = subinstr( standard_name," KABUSHIKI KAISHA "," KK ",1)
replace standard_name = subinstr( standard_name," KABUSHIKI GAISYA "," KK ",1)
replace standard_name = subinstr( standard_name," KABUSHIKI KAISYA "," KK ",1)
replace standard_name = subinstr( standard_name," KABUSHIKIGAISHA "," KK ",1)
replace standard_name = subinstr( standard_name," KABUSHIKIKAISHA "," KK ",1)
replace standard_name = subinstr( standard_name," KABUSHIKIGAISYA "," KK ",1)
replace standard_name = subinstr( standard_name," KABUSHIKIKAISYA "," KK ",1)
replace standard_name = subinstr( standard_name," KOMBINATU "," KOMB ",1)
replace standard_name = subinstr( standard_name," KOMBINATY "," KOMB ",1)
replace standard_name = subinstr( standard_name," KOMBINAT "," KOMB ",1)
replace standard_name = subinstr( standard_name," KONINKLIJKE "," KONINK ",1)
replace standard_name = subinstr( standard_name," KONCERNOVY PODNIK "," KP ",1)
replace standard_name = subinstr( standard_name," KUNSTSTOFFTECHNIK "," KUNST ",1)
replace standard_name = subinstr( standard_name," KUNSTSTOFF "," KUNST ",1)
replace standard_name = subinstr( standard_name," LABORATOIRES "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATOIRE "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATOIR "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORIEI "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORIES "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORII "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORIJ "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORIOS "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORIO "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORIUM "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORI "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORY "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORTORI "," LAB ",1)
replace standard_name = subinstr( standard_name," LAVORAZA "," LAVORAZ ",1)
replace standard_name = subinstr( standard_name," LAVORAZIONE "," LAVORAZ ",1)
replace standard_name = subinstr( standard_name," LAVORAZIONI "," LAVORAZ ",1)
replace standard_name = subinstr( standard_name," LAVORAZIO "," LAVORAZ ",1)
replace standard_name = subinstr( standard_name," LAVORAZI "," LAVORAZ ",1)
replace standard_name = subinstr( standard_name," LIMITED PARTNERSHIP "," LP ",1)
replace standard_name = subinstr( standard_name," LIMITED "," LTD ",1)
replace standard_name = subinstr( standard_name," LTD LTEE "," LTD ",1)
replace standard_name = subinstr( standard_name," MASCHINENVERTRIEB "," MASCH ",1)
replace standard_name = subinstr( standard_name," MASCHINENBAUANSTALT "," MASCHBAU ",1)
replace standard_name = subinstr( standard_name," MASCHINENBAU "," MASCHBAU ",1)
replace standard_name = subinstr( standard_name," MASCHINENFABRIEK "," MASCHFAB ",1)
replace standard_name = subinstr( standard_name," MASCHINENFABRIKEN "," MASCHFAB ",1)
replace standard_name = subinstr( standard_name," MASCHINENFABRIK "," MASCHFAB ",1)
replace standard_name = subinstr( standard_name," MASCHINENFAB "," MASCHFAB ",1)
replace standard_name = subinstr( standard_name," MASCHINEN "," MASCH ",1)
replace standard_name = subinstr( standard_name," MASCHIN "," MASCH ",1)
replace standard_name = subinstr( standard_name," MIT BESCHRANKTER HAFTUNG "," MBH ",1)
replace standard_name = subinstr( standard_name," MANUFACTURINGS "," MFG ",1)
replace standard_name = subinstr( standard_name," MANUFACTURING "," MFG ",1)
replace standard_name = subinstr( standard_name," MANIFATTURAS "," MFR ",1)
replace standard_name = subinstr( standard_name," MANIFATTURA "," MFR ",1)
replace standard_name = subinstr( standard_name," MANIFATTURE "," MFR ",1)
replace standard_name = subinstr( standard_name," MANUFACTURAS "," MFR ",1)
replace standard_name = subinstr( standard_name," MANUFACTURERS "," MFR ",1)
replace standard_name = subinstr( standard_name," MANUFACTURER "," MFR ",1)
replace standard_name = subinstr( standard_name," MANUFACTURES "," MFR ",1)
replace standard_name = subinstr( standard_name," MANUFACTURE "," MFR ",1)
replace standard_name = subinstr( standard_name," MANUFATURA "," MFR ",1)
replace standard_name = subinstr( standard_name," MAATSCHAPPIJ "," MIJ ",1)
replace standard_name = subinstr( standard_name," MEDICAL "," MED ",1)
replace standard_name = subinstr( standard_name," MINISTERE "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERIUM "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERO "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVAKH "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVAM "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVAMI "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVA "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVE "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVO "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVOM "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVU "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTV "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTWO "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERUL "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTRE "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTRY "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTER "," MIN ",1)
replace standard_name = subinstr( standard_name," MAGYAR TUDOMANYOS AKADEMIA "," MTA ",1)
replace standard_name = subinstr( standard_name," NATIONAAL "," NAT ",1)
replace standard_name = subinstr( standard_name," NATIONAL "," NAT ",1)
replace standard_name = subinstr( standard_name," NATIONALE "," NAT ",1)
replace standard_name = subinstr( standard_name," NATIONAUX "," NAT ",1)
replace standard_name = subinstr( standard_name," NATL "," NAT ",1)
replace standard_name = subinstr( standard_name," NAZIONALE "," NAZ ",1)
replace standard_name = subinstr( standard_name," NAZIONALI "," NAZ ",1)
replace standard_name = subinstr( standard_name," NORDDEUTSCH "," NORDDEUT ",1)
replace standard_name = subinstr( standard_name," NORDDEUTSCHE "," NORDDEUT ",1)
replace standard_name = subinstr( standard_name," NORDDEUTSCHER "," NORDDEUT ",1)
replace standard_name = subinstr( standard_name," NORDDEUTSCHES "," NORDDEUT ",1)
replace standard_name = subinstr( standard_name," NARODNI PODNIK "," NP ",1)
replace standard_name = subinstr( standard_name," NARODNIJ PODNIK "," NP ",1)
replace standard_name = subinstr( standard_name," NARODNY PODNIK "," NP ",1)
replace standard_name = subinstr( standard_name," NAAMLOOSE VENOOTSCHAP "," NV ",1)
replace standard_name = subinstr( standard_name," NAAMLOZE VENNOOTSCHAP "," NV ",1)
replace standard_name = subinstr( standard_name," N V "," NV ",1)
replace standard_name = subinstr( standard_name," OESTERREICHISCHES "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OESTERREICHISCHE "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OESTERREICHISCH "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OESTERREICH "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OSTERREICHISCHES "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OSTERREICHISCHE "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OSTERREICHISCH "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OSTERREICH "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OFFICINE MECCANICA "," OFF MEC ",1)
replace standard_name = subinstr( standard_name," OFFICINE MECCANICHE "," OFF MEC ",1)
replace standard_name = subinstr( standard_name," OFFICINE NATIONALE "," OFF NAT ",1)
replace standard_name = subinstr( standard_name," OFFENE HANDELSGESELLSCHAFT "," OHG ",1)
replace standard_name = subinstr( standard_name," ONTWIKKELINGSBUREAU "," ONTWIK ",1)
replace standard_name = subinstr( standard_name," ONTWIKKELINGS "," ONTWIK ",1)
replace standard_name = subinstr( standard_name," OBOROVY PODNIK "," OP ",1)
replace standard_name = subinstr( standard_name," ORGANISATIE "," ORG ",1)
replace standard_name = subinstr( standard_name," ORGANISATIONS "," ORG ",1)
replace standard_name = subinstr( standard_name," ORGANISATION "," ORG ",1)
replace standard_name = subinstr( standard_name," ORGANIZATIONS "," ORG ",1)
replace standard_name = subinstr( standard_name," ORGANIZATION "," ORG ",1)
replace standard_name = subinstr( standard_name," ORGANIZZAZIONE "," ORG ",1)
replace standard_name = subinstr( standard_name," OSAKEYHTIO "," OY ",1)
replace standard_name = subinstr( standard_name," PHARMACEUTICALS "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMACEUTICAL "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMACEUTICA "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMACEUTIQUES "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMACEUTIQUE "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMAZEUTIKA "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMAZEUTISCHEN "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMAZEUTISCHE "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMAZEUTISCH "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMAZIE "," PHARM ",1)
replace standard_name = subinstr( standard_name," PUBLIC LIMITED COMPANY "," PLC ",1)
replace standard_name = subinstr( standard_name," PRELUCRAREA "," PRELUC ",1)
replace standard_name = subinstr( standard_name," PRELUCRARE "," PRELUC ",1)
replace standard_name = subinstr( standard_name," PRODOTTI "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCE "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCTS "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCT "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCTAS "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCTA "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCTIE "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCTOS "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCTO "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCTORES "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUITS "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUIT "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUKCJI "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUKTER "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUKTE "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUKT "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUSE "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUTOS "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUIT CHIMIQUES "," PROD CHIM ",1)
replace standard_name = subinstr( standard_name," PRODUIT CHIMIQUE "," PROD CHIM ",1)
replace standard_name = subinstr( standard_name," PRODUCTIONS "," PRODN ",1)
replace standard_name = subinstr( standard_name," PRODUCTION "," PRODN ",1)
replace standard_name = subinstr( standard_name," PRODUKTIONS "," PRODN ",1)
replace standard_name = subinstr( standard_name," PRODUKTION "," PRODN ",1)
replace standard_name = subinstr( standard_name," PRODUZIONI "," PRODN ",1)
replace standard_name = subinstr( standard_name," PROIECTARE "," PROI ",1)
replace standard_name = subinstr( standard_name," PROIECTARI "," PROI ",1)
replace standard_name = subinstr( standard_name," PRZEDSIEBIOSTWO "," PRZEDSIEB ",1)
replace standard_name = subinstr( standard_name," PRZEMYSLU "," PRZEYM ",1)
replace standard_name = subinstr( standard_name," PROPRIETARY "," PTY ",1)
replace standard_name = subinstr( standard_name," PERSONENVENNOOTSCHAP MET "," PVBA ",1)
replace standard_name = subinstr( standard_name," BEPERKTE AANSPRAKELIJKHEID "," PVBA ",1)
replace standard_name = subinstr( standard_name," REALISATIONS "," REAL ",1)
replace standard_name = subinstr( standard_name," REALISATION "," REAL ",1)
replace standard_name = subinstr( standard_name," RECHERCHES "," RECH ",1)
replace standard_name = subinstr( standard_name," RECHERCHE "," RECH ",1)
replace standard_name = subinstr( standard_name," RECHERCHES ET DEVELOPMENTS "," RECH & DEV ",1)
replace standard_name = subinstr( standard_name," RECHERCHE ET DEVELOPMENT "," RECH & DEV ",1)
replace standard_name = subinstr( standard_name," RECHERCHES ET DEVELOPPEMENTS "," RECH & DEV ",1)
replace standard_name = subinstr( standard_name," RECHERCHE ET DEVELOPPEMENT "," RECH & DEV ",1)
replace standard_name = subinstr( standard_name," RESEARCH & DEVELOPMENT "," RES & DEV ",1)
replace standard_name = subinstr( standard_name," RESEARCH AND DEVELOPMENT "," RES & DEV ",1)
replace standard_name = subinstr( standard_name," RESEARCH "," RES ",1)
replace standard_name = subinstr( standard_name," RIJKSUNIVERSITEIT "," RIJKSUNIV ",1)
replace standard_name = subinstr( standard_name," SECRETATY "," SECRETARY ",1)
replace standard_name = subinstr( standard_name," SECRETRY "," SECRETARY ",1)
replace standard_name = subinstr( standard_name," SECREATRY "," SECRETARY ",1)
replace standard_name = subinstr( standard_name," SOCIEDAD ANONIMA "," SA ",1)
replace standard_name = subinstr( standard_name," SOCIETE ANONYME DITE "," SA ",1)
replace standard_name = subinstr( standard_name," SOCIETE ANONYME "," SA ",1)
replace standard_name = subinstr( standard_name," SOCIETE A RESPONSABILITE LIMITEE "," SARL ",1)
replace standard_name = subinstr( standard_name," SOCIETE A RESPONSIBILITE LIMITEE "," SARL ",1)
replace standard_name = subinstr( standard_name," SOCIETA IN ACCOMANDITA SEMPLICE "," SAS ",1)
replace standard_name = subinstr( standard_name," SCHWEIZERISCHES "," SCHWEIZ ",1)
replace standard_name = subinstr( standard_name," SCHWEIZERISCHER "," SCHWEIZ ",1)
replace standard_name = subinstr( standard_name," SCHWEIZERISCHE "," SCHWEIZ ",1)
replace standard_name = subinstr( standard_name," SCHWEIZERISCH "," SCHWEIZ ",1)
replace standard_name = subinstr( standard_name," SCHWEIZER "," SCHWEIZ ",1)
replace standard_name = subinstr( standard_name," SCIENCES "," SCI ",1)
replace standard_name = subinstr( standard_name," SCIENCE "," SCI ",1)
replace standard_name = subinstr( standard_name," SCIENTIFICA "," SCI ",1)
replace standard_name = subinstr( standard_name," SCIENTIFIC "," SCI ",1)
replace standard_name = subinstr( standard_name," SCIENTIFIQUES "," SCI ",1)
replace standard_name = subinstr( standard_name," SCIENTIFIQUE "," SCI ",1)
replace standard_name = subinstr( standard_name," SHADAN HOJIN "," SH ",1)
replace standard_name = subinstr( standard_name," SIDERURGICAS "," SIDER ",1)
replace standard_name = subinstr( standard_name," SIDERURGICA "," SIDER ",1)
replace standard_name = subinstr( standard_name," SIDERURGIC "," SIDER ",1)
replace standard_name = subinstr( standard_name," SIDERURGIE "," SIDER ",1)
replace standard_name = subinstr( standard_name," SIDERURGIQUE "," SIDER ",1)
replace standard_name = subinstr( standard_name," SOCIETA IN NOME COLLECTIVO "," SNC ",1)
replace standard_name = subinstr( standard_name," SOCIETE EN NOM COLLECTIF "," SNC ",1)
replace standard_name = subinstr( standard_name," SOCIETE ALSACIENNE "," SOC ALSAC ",1)
replace standard_name = subinstr( standard_name," SOCIETE APPLICATION "," SOC APPL ",1)
replace standard_name = subinstr( standard_name," SOCIETA APPLICAZIONE "," SOC APPL ",1)
replace standard_name = subinstr( standard_name," SOCIETE AUXILIAIRE "," SOC AUX ",1)
replace standard_name = subinstr( standard_name," SOCIETE CHIMIQUE "," SOC CHIM ",1)
replace standard_name = subinstr( standard_name," SOCIEDAD CIVIL "," SOC CIV ",1)
replace standard_name = subinstr( standard_name," SOCIETE CIVILE "," SOC CIV ",1)
replace standard_name = subinstr( standard_name," SOCIETE COMMERCIALES "," SOC COMML ",1)
replace standard_name = subinstr( standard_name," SOCIETE COMMERCIALE "," SOC COMML ",1)
replace standard_name = subinstr( standard_name," SOCIEDAD ESPANOLA "," SOC ESPAN ",1)
replace standard_name = subinstr( standard_name," SOCIETE ETUDES "," SOC ETUD ",1)
replace standard_name = subinstr( standard_name," SOCIETE ETUDE "," SOC ETUD ",1)
replace standard_name = subinstr( standard_name," SOCIETE EXPLOITATION "," SOC EXPL ",1)
replace standard_name = subinstr( standard_name," SOCIETE GENERALE "," SOC GEN ",1)
replace standard_name = subinstr( standard_name," SOCIETE INDUSTRIELLES "," SOC IND ",1)
replace standard_name = subinstr( standard_name," SOCIETE INDUSTRIELLE "," SOC IND ",1)
replace standard_name = subinstr( standard_name," SOCIETE MECANIQUES "," SOC MEC ",1)
replace standard_name = subinstr( standard_name," SOCIETE MECANIQUE "," SOC MEC ",1)
replace standard_name = subinstr( standard_name," SOCIETE NATIONALE "," SOC NAT ",1)
replace standard_name = subinstr( standard_name," SOCIETE NOUVELLE "," SOC NOUV ",1)
replace standard_name = subinstr( standard_name," SOCIETE PARISIENNE "," SOC PARIS ",1)
replace standard_name = subinstr( standard_name," SOCIETE PARISIENN "," SOC PARIS ",1)
replace standard_name = subinstr( standard_name," SOCIETE PARISIEN "," SOC PARIS ",1)
replace standard_name = subinstr( standard_name," SOCIETE TECHNIQUES "," SOC TECH ",1)
replace standard_name = subinstr( standard_name," SOCIETE TECHNIQUE "," SOC TECH ",1)
replace standard_name = subinstr( standard_name," SDRUZENI PODNIKU "," SP ",1)
replace standard_name = subinstr( standard_name," SDRUZENI PODNIK "," SP ",1)
replace standard_name = subinstr( standard_name," SOCIETA PER AZIONI "," SPA ",1)
replace standard_name = subinstr( standard_name," SPITALUL "," SPITAL ",1)
replace standard_name = subinstr( standard_name," SOCIETE PRIVEE A RESPONSABILITE LIMITEE "," SPRL ",1)
replace standard_name = subinstr( standard_name," SOCIEDAD DE RESPONSABILIDAD LIMITADA "," SRL ",1)
replace standard_name = subinstr( standard_name," STIINTIFICA "," STIINT ",1)
replace standard_name = subinstr( standard_name," SUDDEUTSCHES "," SUDDEUT ",1)
replace standard_name = subinstr( standard_name," SUDDEUTSCHER "," SUDDEUT ",1)
replace standard_name = subinstr( standard_name," SUDDEUTSCHE "," SUDDEUT ",1)
replace standard_name = subinstr( standard_name," SUDDEUTSCH "," SUDDEUT ",1)
replace standard_name = subinstr( standard_name," SOCIEDADE "," SOC ",1)
replace standard_name = subinstr( standard_name," SOCIEDAD "," SOC ",1)
replace standard_name = subinstr( standard_name," SOCIETA "," SOC ",1)
replace standard_name = subinstr( standard_name," SOCIETE "," SOC ",1)
replace standard_name = subinstr( standard_name," SOCIETY "," SOC ",1)
replace standard_name = subinstr( standard_name," SA DITE "," SA ",1)
replace standard_name = subinstr( standard_name," TECHNICAL "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNICO "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNICZNY "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNIKAI "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNIKI "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNIK "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNIQUES "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNIQUE "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNISCHES "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNISCHE "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNISCH "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNOLOGY "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNOLOGIES "," TECH ",1)
replace standard_name = subinstr( standard_name," TELECOMMUNICATIONS "," TELECOM ",1)
replace standard_name = subinstr( standard_name," TELECOMMUNICACION "," TELECOM ",1)
replace standard_name = subinstr( standard_name," TELECOMMUNICATION "," TELECOM ",1)
replace standard_name = subinstr( standard_name," TELECOMMUNICAZIONI "," TELECOM ",1)
replace standard_name = subinstr( standard_name," TELECOMUNICAZIONI "," TELECOM ",1)
replace standard_name = subinstr( standard_name," TRUSTUL "," TRUST ",1)
replace standard_name = subinstr( standard_name," UNITED KINGDOM "," UK ",1)
replace standard_name = subinstr( standard_name," SECRETARY OF STATE FOR "," UK SEC FOR ",1)
replace standard_name = subinstr( standard_name," UNIVERSIDADE "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSIDAD "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITA DEGLI STUDI "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITAET "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITAIRE "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITAIR "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITATEA "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITEIT "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETAMI "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETAM "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETE "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETOM "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETOV "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETU "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETY "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETA "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITAT "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITET "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITE "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITY "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITA "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIWERSYTET "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA ADMINISTRATOR "," US ADMIN ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA AS REPRESENTED BY THE ADMINISTRATOR "," US ADMIN ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA AS REPRESENTED BY THE DEPT "," US DEPT ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA AS REPRESENTED BY THE UNITED STATES DEPT "," US DEPT ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICAN AS REPRESENTED BY THE UNITED STATES DEPT "," US DEPT ",1)
replace standard_name = subinstr( standard_name," UNITED STATES GOVERNMENT AS REPRESENTED BY THE SECRETARY OF "," US SEC ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA REPRESENTED BY THE SECRETARY "," US SEC ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA AS REPRESENTED BY THE SECRETARY "," US SEC ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICAS AS REPRESENTED BY THE SECRETARY "," US SEC ",1)
replace standard_name = subinstr( standard_name," UNITES STATES OF AMERICA AS REPRESENTED BY THE SECRETARY "," US SEC ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA SECRETARY OF "," US SEC ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA "," USA ",1)
replace standard_name = subinstr( standard_name," UNITED STATES "," USA ",1)
replace standard_name = subinstr( standard_name," UTILAJE "," UTIL ",1)
replace standard_name = subinstr( standard_name," UTILAJ "," UTIL ",1)
replace standard_name = subinstr( standard_name," UTILISATIONS VOLKSEIGENER BETRIEBE "," VEB ",1)
replace standard_name = subinstr( standard_name," UTILISATION VOLKSEIGENER BETRIEBE "," VEB ",1)
replace standard_name = subinstr( standard_name," VEB KOMBINAT "," VEB KOMB ",1)
replace standard_name = subinstr( standard_name," VEREENIGDE "," VER ",1)
replace standard_name = subinstr( standard_name," VEREINIGTES VEREINIGUNG "," VER ",1)
replace standard_name = subinstr( standard_name," VEREINIGTE VEREINIGUNG "," VER ",1)
replace standard_name = subinstr( standard_name," VEREIN "," VER ",1)
replace standard_name = subinstr( standard_name," VERENIGING "," VER ",1)
replace standard_name = subinstr( standard_name," VERWALTUNGEN "," VERW ",1)
replace standard_name = subinstr( standard_name," VERWALTUNGS "," VERW ",1)
replace standard_name = subinstr( standard_name," VERWERTUNGS "," VERW ",1)
replace standard_name = subinstr( standard_name," VERWALTUNGSGESELLSCHAFT "," VERW GES ",1)
replace standard_name = subinstr( standard_name," VYZK USTAV "," VU ",1)
replace standard_name = subinstr( standard_name," VYZKUMNY USTAV "," VU ",1)
replace standard_name = subinstr( standard_name," VYZKUMNYUSTAV "," VU ",1)
replace standard_name = subinstr( standard_name," VEREINIGUNG VOLKSEIGENER BETRIEBUNG "," VVB ",1)
replace standard_name = subinstr( standard_name," VYZK VYVOJOVY USTAV "," VVU ",1)
replace standard_name = subinstr( standard_name," VYZKUMNY VYVOJOVY USTAV "," VVU ",1)
replace standard_name = subinstr( standard_name," WERKZEUGMASCHINENKOMBINAT "," WERKZ MASCH KOMB ",1)
replace standard_name = subinstr( standard_name," WERKZEUGMASCHINENFABRIK "," WERKZ MASCHFAB ",1)
replace standard_name = subinstr( standard_name," WESTDEUTSCHES "," WESTDEUT ",1)
replace standard_name = subinstr( standard_name," WESTDEUTSCHER "," WESTDEUT ",1)
replace standard_name = subinstr( standard_name," WESTDEUTSCHE "," WESTDEUT ",1)
replace standard_name = subinstr( standard_name," WESTDEUTSCH "," WESTDEUT ",1)
replace standard_name = subinstr( standard_name," WISSENSCHAFTLICHE(S) "," WISS ",1)
replace standard_name = subinstr( standard_name," WISSENSCHAFTLICHES TECHNISCHES ZENTRUM "," WTZ ",1)
replace standard_name = subinstr( standard_name," YUGEN KAISHA "," YG YUGEN GAISHA ",1)
replace standard_name = subinstr( standard_name," YUUGEN GAISHA "," YG YUGEN GAISHA ",1)
replace standard_name = subinstr( standard_name," YUUGEN KAISHA "," YG YUGEN GAISHA ",1)
replace standard_name = subinstr( standard_name," YUUGEN KAISYA "," YG YUGEN GAISHA ",1)
replace standard_name = subinstr( standard_name," ZAVODU "," ZAVOD ",1)
replace standard_name = subinstr( standard_name," ZAVODY "," ZAVOD ",1)
replace standard_name = subinstr( standard_name," ZENTRALES "," ZENT ",1)
replace standard_name = subinstr( standard_name," ZENTRALE "," ZENT ",1)
replace standard_name = subinstr( standard_name," ZENTRALEN "," ZENT ",1)
replace standard_name = subinstr( standard_name," ZENTRALNA "," ZENT ",1)
replace standard_name = subinstr( standard_name," ZENTRUM "," ZENT ",1)
replace standard_name = subinstr( standard_name," ZENTRALINSTITUT "," ZENT INST ",1)
replace standard_name = subinstr( standard_name," ZENTRALLABORATORIUM "," ZENT LAB ",1)
replace standard_name = subinstr( standard_name," ZAIDAN HOJIN "," ZH ",1)
replace standard_name = subinstr( standard_name," ZAIDAN HOUJIN "," ZH ",1)
replace standard_name = subinstr( standard_name," LIMITED "," LTD ",1)
replace standard_name = subinstr( standard_name," LIMITADA "," LTDA ",1)
replace standard_name = subinstr( standard_name," SECRETARY "," SEC ",1)

*additonal standardization - see the standard_name.do

** 2) Perform some additional changes
replace standard_name = subinstr( standard_name, " RES & DEV ", " R&D ", 1)
replace standard_name = subinstr( standard_name, " RECH & DEV ", " R&D ", 1)

** 3) Perform some country specific work
** UNITED STATES (most of this is in Derwent)

** UNITED KINGDOM
replace standard_name = subinstr( standard_name, " PUBLIC LIMITED ", " PLC ", 1)
replace standard_name = subinstr( standard_name, " PUBLIC LIABILITY COMPANY ", " PLC ", 1)
replace standard_name = subinstr( standard_name, " HOLDINGS ", " HLDGS ", 1)
replace standard_name = subinstr( standard_name, " HOLDING ", " HLDGS ", 1)
replace standard_name = subinstr( standard_name, " GREAT BRITAIN ", " GB ", 1)
replace standard_name = subinstr( standard_name, " LTD CO ", " CO LTD ", 1)

** SPANISH
replace standard_name = subinstr( standard_name, " SOC LIMITADA ", " SL ", 1)
replace standard_name = subinstr( standard_name, " SOC EN COMMANDITA ", " SC ", 1)
replace standard_name = subinstr( standard_name, " & CIA ", " CO ", 1)

** ITALIAN
replace standard_name = subinstr( standard_name, " SOC IN ACCOMANDITA PER AZIONI ", " SA ", 1)
replace standard_name = subinstr( standard_name, " SAPA ", " SA ", 1)
replace standard_name = subinstr( standard_name, " SOC A RESPONSABILITÀ LIMITATA ", " SRL ", 1)

** SWEDISH
replace standard_name = subinstr( standard_name, " HANDELSBOLAG ", " HB  ", 1)

** GERMAN
replace standard_name = subinstr( standard_name, " KOMANDIT GESELLSCHAFT ", " KG ", 1)
replace standard_name = subinstr( standard_name, " KOMANDITGESELLSCHAFT ", " KG ", 1)
replace standard_name = subinstr( standard_name, " EINGETRAGENE GENOSSENSCHAFT ", " EG ", 1)
replace standard_name = subinstr( standard_name, " GENOSSENSCHAFT ", " EG ", 1)
replace standard_name = subinstr( standard_name, " GESELLSCHAFT M B H ", " GMBH ", 1)
replace standard_name = subinstr( standard_name, " OFFENE HANDELS GESELLSCHAFT ", " OHG ", 1)
replace standard_name = subinstr( standard_name, " GESMBH ", " GMBH ", 1)
replace standard_name = subinstr( standard_name, " GESELLSCHAFT BURGERLICHEN RECHTS ", " GBR ", 1)
replace standard_name = subinstr( standard_name, " GESELLSCHAFT ", " GMBH ", 1)
* The following is common format. If conflict assume GMBH & CO KG over GMBH & CO OHG as more common.
replace standard_name = subinstr( standard_name, " GMBH CO KG ", " GMBH & CO KG ", 1)
replace standard_name = subinstr( standard_name, " GMBH COKG ", " GMBH & CO KG ", 1)
replace standard_name = subinstr( standard_name, " GMBH U CO KG ", " GMBH & CO KG ", 1)
replace standard_name = subinstr( standard_name, " GMBH U COKG ", " GMBH & CO KG ", 1)
replace standard_name = subinstr( standard_name, " GMBH U CO ", " GMBH & CO KG ", 1)
replace standard_name = subinstr( standard_name, " GMBH CO ", " GMBH & CO KG ", 1)
replace standard_name = subinstr( standard_name, " AG CO KG ", " AG & CO KG ", 1)
replace standard_name = subinstr( standard_name, " AG COKG ", " AG & CO KG ", 1)
replace standard_name = subinstr( standard_name, " AG U CO KG ", " AG & CO KG ", 1)
replace standard_name = subinstr( standard_name, " AG U COKG ", " AG & CO KG ", 1)
replace standard_name = subinstr( standard_name, " AG U CO ", " AG & CO KG ", 1)
replace standard_name = subinstr( standard_name, " AG CO ", " AG & CO KG ", 1)
replace standard_name = subinstr( standard_name, " GMBH CO OHG ", " GMBH &CO OHG ", 1)
replace standard_name = subinstr( standard_name, " GMBH COOHG ", " GMBH & CO OHG ", 1)
replace standard_name = subinstr( standard_name, " GMBH U CO OHG ", " GMBH & CO OHG ", 1)
replace standard_name = subinstr( standard_name, " GMBH U COOHG ", " GMBH & CO OHG ", 1)
replace standard_name = subinstr( standard_name, " AG CO OHG ", " AG & CO OHG ", 1)
replace standard_name = subinstr( standard_name, " AG COOHG ", " AG & CO OHG ", 1)
replace standard_name = subinstr( standard_name, " AG U CO OHG ", " AG & CO OHG ", 1)
replace standard_name = subinstr( standard_name, " AG U COOHG ", " AG & CO OHG ", 1)

** FRENCH and BELGIAN
replace standard_name = subinstr( standard_name, " SOCIETE ANONYME SIMPLIFIEE ", " SAS ", 1)
replace standard_name = subinstr( standard_name, " SOC ANONYME ", " SA ", 1)
replace standard_name = subinstr( standard_name, " STE ANONYME ", " SA ", 1)
replace standard_name = subinstr( standard_name, " SARL UNIPERSONNELLE ", " SARLU ", 1)
replace standard_name = subinstr( standard_name, " SOC PAR ACTIONS SIMPLIFIEES ", " SAS ", 1)
replace standard_name = subinstr( standard_name, " SAS UNIPERSONNELLE ", " SASU ", 1)
replace standard_name = subinstr( standard_name, " ENTREPRISE UNIPERSONNELLE A RESPONSABILITE LIMITEE ", " EURL ", 1)
replace standard_name = subinstr( standard_name, " SOCIETE CIVILE IMMOBILIERE ", " SCI ", 1)
replace standard_name = subinstr( standard_name, " GROUPEMENT D INTERET ECONOMIQUE ", " GIE ", 1)
replace standard_name = subinstr( standard_name, " SOCIETE EN PARTICIPATION ", " SP ", 1)
replace standard_name = subinstr( standard_name, " SOCIETE EN COMMANDITE SIMPLE ", " SCS ", 1)
replace standard_name = subinstr( standard_name, " ANONYME DITE ", " SA ", 1)
replace standard_name = subinstr( standard_name, " SOC DITE ", " SA ", 1)
replace standard_name = subinstr( standard_name, " & CIE ", " CO ", 1)

** BELGIAN
** Note: the Belgians use a lot of French endings, so handle as above.
** Also, they use NV (belgian) and SA (french) interchangably, so standardise to SA

replace standard_name = subinstr( standard_name, " BV BEPERKTE AANSPRAKELIJKHEID ", " BVBA ", 1)
replace standard_name = subinstr( standard_name, " COMMANDITAIRE VENNOOTSCHAP OP AANDELEN ", " CVA ", 1)
replace standard_name = subinstr( standard_name, " GEWONE COMMANDITAIRE VENNOOTSCHAP ", " GCV ", 1)
replace standard_name = subinstr( standard_name, " SOCIETE EN COMMANDITE PAR ACTIONS ", " SCA ", 1)

* Change to French language equivalents where appropriate
* Don't do this for now
*replace standard_name = subinstr( standard_name, " GCV ", " SCS ", 1)
*replace standard_name = subinstr( standard_name, " NV ", " SA ", 1)
*replace standard_name = subinstr( standard_name, " BVBA ", " SPRL ", 1)

** DENMARK
* Usually danish identifiers have a slash (eg. A/S or K/S), but these will have been removed with all
* other punctuation earlier (so just use AS or KS).
replace standard_name = subinstr( standard_name, " ANDELSSELSKABET ", " AMBA ", 1)
replace standard_name = subinstr( standard_name, " ANDELSSELSKAB ", " AMBA ", 1)
replace standard_name = subinstr( standard_name, " INTERESSENTSKABET ", " IS ", 1)
replace standard_name = subinstr( standard_name, " INTERESSENTSKAB ", " IS ", 1)
replace standard_name = subinstr( standard_name, " KOMMANDITAKTIESELSKABET ", " KAS ", 1)
replace standard_name = subinstr( standard_name, " KOMMANDITAKTIESELSKAB ", " KAS ", 1)
replace standard_name = subinstr( standard_name, " KOMMANDITSELSKABET ", " KS ", 1)
replace standard_name = subinstr( standard_name, " KOMMANDITSELSKAB ", " KS ", 1)

** NORWAY
replace standard_name = subinstr( standard_name, " ANDELSLAGET ", " AL ", 1)
replace standard_name = subinstr( standard_name, " ANDELSLAG ", " AL ", 1)
replace standard_name = subinstr( standard_name, " ANSVARLIG SELSKAPET ", " ANS ", 1)
replace standard_name = subinstr( standard_name, " ANSVARLIG SELSKAP ", " ANS ", 1)
replace standard_name = subinstr( standard_name, " AKSJESELSKAPET ", " AS ", 1)
replace standard_name = subinstr( standard_name, " AKSJESELSKAP ", " AS ", 1)
replace standard_name = subinstr( standard_name, " ALLMENNAKSJESELSKAPET ", " ASA ", 1)
replace standard_name = subinstr( standard_name, " ALLMENNAKSJESELSKAP ", " ASA ", 1)
replace standard_name = subinstr( standard_name, " SELSKAP MED DELT ANSAR ", " DA ", 1)
replace standard_name = subinstr( standard_name, " KOMMANDITTSELSKAPET ", " KS ", 1)
replace standard_name = subinstr( standard_name, " KOMMANDITTSELSKAP ", " KS ", 1)

** NETHERLANDS
replace standard_name = subinstr( standard_name, " COMMANDITAIRE VENNOOTSCHAP ", " CV ", 1)
replace standard_name = subinstr( standard_name, " COMMANDITAIRE VENNOOTSCHAP OP ANDELEN ", " CVOA ", 1)
replace standard_name = subinstr( standard_name, " VENNOOTSCHAP ONDER FIRMA ", " VOF ", 1)

** FINLAND
replace standard_name = subinstr( standard_name, " PUBLIKT AKTIEBOLAG ", " APB ", 1)
replace standard_name = subinstr( standard_name, " KOMMANDIITTIYHTIO ", " KY ", 1)
replace standard_name = subinstr( standard_name, " JULKINEN OSAKEYHTIO ", " OYJ ", 1)

** POLAND
replace standard_name = subinstr( standard_name, " SPOLKA AKCYJNA ", " SA ", 1) 
replace standard_name = subinstr( standard_name, " SPOLKA PRAWA CYWILNEGO ", " SC ", 1)
replace standard_name = subinstr( standard_name, " SPOLKA KOMANDYTOWA ", " SK ", 1)
replace standard_name = subinstr( standard_name, " SPOLKA Z OGRANICZONA ODPOWIEDZIALNOSCIA ", " SPZOO ", 1)
replace standard_name = subinstr( standard_name, " SP Z OO ", " SPZOO ", 1)
replace standard_name = subinstr( standard_name, " SPZ OO ", " SPZOO ", 1)
replace standard_name = subinstr( standard_name, " SP ZOO ", " SPZOO ", 1)

** GREECE
replace standard_name = subinstr( standard_name, " ANONYMOS ETAIRIA ", " AE ", 1)
replace standard_name = subinstr( standard_name, " ETERRORRYTHMOS ", " EE ", 1)
replace standard_name = subinstr( standard_name, " ETAIRIA PERIORISMENIS EVTHINIS ", " EPE ", 1)
replace standard_name = subinstr( standard_name, " OMORRYTHMOS ", " OE ", 1)

** CZECH REPUBLIC
replace standard_name = subinstr( standard_name, " AKCIOVA SPOLECNOST ", " AS ", 1)
replace standard_name = subinstr( standard_name, " KOMANDITNI SPOLECNOST ", " KS ", 1)
replace standard_name = subinstr( standard_name, " SPOLECNOST S RUCENIM OMEZENYM ", " SRO ", 1)
replace standard_name = subinstr( standard_name, " VEREJNA OBCHODNI SPOLECNOST ", " VOS ", 1) 
                
** BULGARIA
replace standard_name = subinstr( standard_name, " AKTIONIERNO DRUSHESTWO ", " AD ", 1)
replace standard_name = subinstr( standard_name, " KOMANDITNO DRUSHESTWO ", " KD ", 1)
replace standard_name = subinstr( standard_name, " KOMANDITNO DRUSHESTWO S AKZII ", " KDA ", 1)
replace standard_name = subinstr( standard_name, " DRUSHESTWO S ORGRANITSCHENA OTGOWORNOST ", " OCD ", 1)



***********stem name to remove corporate IDs********************************************************************************************************************
*this section uses code from stem_name.do


gen stem_name = standard_name

** UNITED KINGDOM
replace stem_name = subinstr( stem_name, " LTD ", " ", 1)
replace stem_name = subinstr( stem_name, " CO LTD ", " ", 1)
replace stem_name = subinstr( stem_name, " TRADING LTD ", " ", 1)
replace stem_name = subinstr( stem_name, " HLDGS ", " ", 1)    
replace stem_name = subinstr( stem_name, " INST ", " ", 1)    
replace stem_name = subinstr( stem_name, " CORP ", " ", 1)       
replace stem_name = subinstr( stem_name, " INTL ", " ", 1)       
replace stem_name = subinstr( stem_name, " INC ", " ", 1)        
replace stem_name = subinstr( stem_name, " PLC ", " ", 1)        
replace stem_name = subinstr( stem_name, " SPA ", " ", 1)        
replace stem_name = subinstr( stem_name, " CLA ", " ", 1)        
replace stem_name = subinstr( stem_name, " LLP ", " ", 1)        
replace stem_name = subinstr( stem_name, " LLC ", " ", 1)        
replace stem_name = subinstr( stem_name, " AIS ", " ", 1)        
replace stem_name = subinstr( stem_name, " INVESTMENTS ", " ", 1)
replace stem_name = subinstr( stem_name, " PARTNERSHIP ", " ", 1)
replace stem_name = subinstr( stem_name, " & CO ", " ", 1)         
replace stem_name = subinstr( stem_name, " CO ", " ", 1)         
replace stem_name = subinstr( stem_name, " COS ", " ", 1)        
replace stem_name = subinstr( stem_name, " CP ", " ", 1)         
replace stem_name = subinstr( stem_name, " LP ", " ", 1)         
replace stem_name = subinstr( stem_name, " BLSA ", " ", 1)
replace stem_name = subinstr( stem_name, " GROUP ", " ", 1)

** FRANCE
replace stem_name = subinstr( stem_name, " SA ", " ", 1)         
replace stem_name = subinstr( stem_name, " SARL ", " ", 1)         
replace stem_name = subinstr( stem_name, " SAS ", " ", 1)         
replace stem_name = subinstr( stem_name, " EURL ", " ", 1)         
replace stem_name = subinstr( stem_name, " ETCIE ", " ", 1)         
replace stem_name = subinstr( stem_name, " ET CIE ", " ", 1)
replace stem_name = subinstr( stem_name, " CIE ", " ", 1)
replace stem_name = subinstr( stem_name, " GIE ", " ", 1)         
replace stem_name = subinstr( stem_name, " SC ", " ", 1)         
replace stem_name = subinstr( stem_name, " SNC ", " ", 1)         
replace stem_name = subinstr( stem_name, " SP ", " ", 1)         
replace stem_name = subinstr( stem_name, " SCS ", " ", 1)         

** GERMANY
replace stem_name = subinstr( stem_name, " GMBHCOKG ", " ", 1)         
replace stem_name = subinstr( stem_name, " EGENOSSENSCHAFT ", " ", 1)         
replace stem_name = subinstr( stem_name, " GMBHCO ", " ", 1)         
replace stem_name = subinstr( stem_name, " COGMBH ", " ", 1)         
replace stem_name = subinstr( stem_name, " GESMBH ", " ", 1)         
replace stem_name = subinstr( stem_name, " GMBH ", " ", 1)         
replace stem_name = subinstr( stem_name, " KGAA ", " ", 1)         
replace stem_name = subinstr( stem_name, " KG ", " ", 1)         
replace stem_name = subinstr( stem_name, " AG ", " ", 1)         
replace stem_name = subinstr( stem_name, " EG ", " ", 1)         
replace stem_name = subinstr( stem_name, " GMBHCOKGAA ", " ", 1)         
replace stem_name = subinstr( stem_name, " MIT ", " ", 1)         
replace stem_name = subinstr( stem_name, " OHG ", " ", 1)         
replace stem_name = subinstr( stem_name, " GRUPPE ", " ", 1)
replace stem_name = subinstr( stem_name, " GBR ", " ", 1)

** Spain
replace stem_name = subinstr( stem_name, " SL ", " ", 1)         
replace stem_name = subinstr( stem_name, " SA ", " ", 1)         
replace stem_name = subinstr( stem_name, " SC ", " ", 1)         
replace stem_name = subinstr( stem_name, " SRL ", " ", 1)
replace stem_name = subinstr( stem_name, " ESPANA ", " ", 1)

** Italy
replace stem_name = subinstr( stem_name, " SA ", " ", 1)         
replace stem_name = subinstr( stem_name, " SAS ", " ", 1)         
replace stem_name = subinstr( stem_name, " SNC ", " ", 1)         
replace stem_name = subinstr( stem_name, " SPA ", " ", 1)
replace stem_name = subinstr( stem_name, " SRL ", " ", 1)

** SWEDEN - front and back
replace stem_name = subinstr( stem_name, " AB ", " ", 1)
replace stem_name = subinstr( stem_name, " HB ", " ", 1)
replace stem_name = subinstr( stem_name, " KB ", " ", 1)

** Belgium
** Note: the belgians use a lot of French endings, so we include all the French ones.
** Also, they use NV (belgian) and SA (french) interchangably, so standardise to SA

* French ones again
replace stem_name = subinstr( stem_name, " SAS ", " ", 1)
replace stem_name = subinstr( stem_name, " SA ", " ", 1)
replace stem_name = subinstr( stem_name, " SARL ", " ", 1)
replace stem_name = subinstr( stem_name, " SARLU ", " ", 1)
replace stem_name = subinstr( stem_name, " SAS ", " ", 1)
replace stem_name = subinstr( stem_name, " SASU ", " ", 1)
replace stem_name = subinstr( stem_name, " EURL ", " ", 1)
replace stem_name = subinstr( stem_name, " ETCIE ", " ", 1)
replace stem_name = subinstr( stem_name, " CIE ", " ", 1)
replace stem_name = subinstr( stem_name, " GIE ", " ", 1)
replace stem_name = subinstr( stem_name, " SC ", " ", 1)
replace stem_name = subinstr( stem_name, " SNC ", " ", 1)
replace stem_name = subinstr( stem_name, " SP ", " ", 1)
replace stem_name = subinstr( stem_name, " SCS ", " ", 1)

* Specifically Belgian ones
replace stem_name = subinstr( stem_name, " BV ", " ", 1)
replace stem_name = subinstr( stem_name, " CVA ", " ", 1)
replace stem_name = subinstr( stem_name, " SCA ", " ", 1)
replace stem_name = subinstr( stem_name, " SPRL ", " ", 1)

* Change to French language equivalents where appropriate
replace stem_name = subinstr( stem_name, " SCS ", " ", 1)
replace stem_name = subinstr( stem_name, " SA ", " ", 1)
replace stem_name = subinstr( stem_name, " SPRL ", " ", 1)

** Denmark - front and back
* Usually danish identifiers have a slash (eg. A/S or K/S), but these will have been removed with all
* other punctuation earlier (so just use AS or KS).
replace stem_name = subinstr( stem_name, " AMBA ", " ", 1)
replace stem_name = subinstr( stem_name, " APS ", " ", 1)
replace stem_name = subinstr( stem_name, " AS ", " ", 1)
replace stem_name = subinstr( stem_name, " IS ", " ", 1)
replace stem_name = subinstr( stem_name, " KAS ", " ", 1)
replace stem_name = subinstr( stem_name, " KS ", " ", 1)
replace stem_name = subinstr( stem_name, " PF ", " ", 1)

** Norway - front and back
replace stem_name = subinstr( stem_name, " AL ", " ", 1)
replace stem_name = subinstr( stem_name, " ANS ", " ", 1)
replace stem_name = subinstr( stem_name, " AS ", " ", 1)
replace stem_name = subinstr( stem_name, " ASA ", " ", 1)
replace stem_name = subinstr( stem_name, " DA ", " ", 1)
replace stem_name = subinstr( stem_name, " KS ", " ", 1)

** Netherlands - front and back
replace stem_name = subinstr( stem_name, " BV ", " ", 1) 
replace stem_name = subinstr( stem_name, " CV ", " ", 1)
replace stem_name = subinstr( stem_name, " CVOA ", " ", 1)
replace stem_name = subinstr( stem_name, " NV ", " ", 1)
replace stem_name = subinstr( stem_name, " VOF ", " ", 1)

** Finland - front and back
** We get some LTD and PLC strings for finland. Remove.
replace stem_name = subinstr( stem_name, " AB ", " ", 1)
replace stem_name = subinstr( stem_name, " APB ", " ", 1)
replace stem_name = subinstr( stem_name, " KB ", " ", 1)
replace stem_name = subinstr( stem_name, " KY ", " ", 1)
replace stem_name = subinstr( stem_name, " OY ", " ", 1)
replace stem_name = subinstr( stem_name, " OYJ ", " ", 1)
replace stem_name = subinstr( stem_name, " OYJ AB ", " ", 1)
replace stem_name = subinstr( stem_name, " OY AB ", " ", 1)
replace stem_name = subinstr( stem_name, " LTD ", " ", 1)
replace stem_name = subinstr( stem_name, " PLC ", " ", 1)
replace stem_name = subinstr( stem_name, " INC ", " ", 1)

** Poland
replace stem_name = subinstr( stem_name, " SA ", " ", 1) 
replace stem_name = subinstr( stem_name, " SC ", " ", 1)
replace stem_name = subinstr( stem_name, " SK ", " ", 1)
replace stem_name = subinstr( stem_name, " SPZOO ", " ", 1)

** Greece
** Also see limited and so on sometimes
replace stem_name = subinstr( stem_name, " AE ", " ", 1)
replace stem_name = subinstr( stem_name, " EE ", " ", 1)
replace stem_name = subinstr( stem_name, " EPE ", " ", 1)
replace stem_name = subinstr( stem_name, " OE ", " ", 1)
replace stem_name = subinstr( stem_name, " SA ", " ", 1)
replace stem_name = subinstr( stem_name, " LTD ", " ", 1)
replace stem_name = subinstr( stem_name, " PLC ", " ", 1)
replace stem_name = subinstr( stem_name, " INC ", " ", 1)

** Czech Republic
replace stem_name = subinstr( stem_name, " AS ", " ", 1)
replace stem_name = subinstr( stem_name, " KS ", " ", 1)
replace stem_name = subinstr( stem_name, " SRO ", " ", 1)
replace stem_name = subinstr( stem_name, " VOS ", " ", 1) 

** Bulgaria
replace stem_name = subinstr( stem_name, " AD ", " ", 1)
replace stem_name = subinstr( stem_name, " KD ", " ", 1)
replace stem_name = subinstr( stem_name, " KDA ", " ", 1)
replace stem_name = subinstr( stem_name, " OCD ", " ", 1)
replace stem_name = subinstr( stem_name, " KOOP ", " ", 1)
replace stem_name = subinstr( stem_name, " DF ", " ", 1)
replace stem_name = subinstr( stem_name, " EOOD ", " ", 1)
replace stem_name = subinstr( stem_name, " EAD ", " ", 1)
replace stem_name = subinstr( stem_name, " OOD ", " ", 1)
replace stem_name = subinstr( stem_name, " KOOD ", " ", 1)
replace stem_name = subinstr( stem_name, " ET ", " ", 1)

** Japan
replace stem_name = subinstr( stem_name, " KOGYO KK ", " ", 1)
replace stem_name = subinstr( stem_name, " KK ", " ", 1)

replace standard_name = trim(subinstr(standard_name,"  "," ",30))
replace stem_name = trim(subinstr(stem_name,"  "," ",30))


rename standard_name name_clean
rename stem_name name_stem

*save dataset
save `y'_clean_stem, replace
}

*rename variables in PatentsView dataset
use patview_name_1_final_clean_stem, clear
foreach var in name id name_clean name_stem{
rename `var' patview_`var'
}
save patview_name_1_final_clean_stem2, replace

*rename variables in npe dataset
use npe_names_clean_stem, clear
foreach var in name id name_clean name_stem{
rename `var' npe_`var'
}
save npe_names_clean_stem2, replace



*clean assignment data
use assignment_names, clear

gen standard_name = " "+trim(name)+" " 
replace standard_name=upper(standard_name)

{
** This section strips out all punctuation characters
** and replaces them with nulls
replace standard_name = subinstr( standard_name, "'",  "", 30)
replace standard_name = subinstr( standard_name, ";",  "", 30)
replace standard_name = subinstr( standard_name, "^",  "", 30)
replace standard_name = subinstr( standard_name, "<",  "", 30)
replace standard_name = subinstr( standard_name, ".",  "", 30)
replace standard_name = subinstr( standard_name, "`",  "", 30)
replace standard_name = subinstr( standard_name, "_",  "", 30)
replace standard_name = subinstr( standard_name, ">",  "", 30)
replace standard_name = subinstr( standard_name, "''", "", 30)
replace standard_name = subinstr( standard_name, "!",  "", 30)
replace standard_name = subinstr( standard_name, "+",  "", 30)
replace standard_name = subinstr( standard_name, "?",  "", 30)
replace standard_name = subinstr( standard_name, "(",  "", 30)
replace standard_name = subinstr( standard_name, "{",  "", 30)
replace standard_name = subinstr( standard_name, "\",  "", 30)
replace standard_name = subinstr( standard_name, ")",  "", 30)
replace standard_name = subinstr( standard_name, "$",  "", 30)
replace standard_name = subinstr( standard_name, "}",  "", 30)
replace standard_name = subinstr( standard_name, "|",  "", 30)
replace standard_name = subinstr( standard_name, ",",  "", 30)
replace standard_name = subinstr( standard_name, "%",  "", 30)
replace standard_name = subinstr( standard_name, "[",  "", 30)
replace standard_name = subinstr( standard_name, "*",  "", 30)
replace standard_name = subinstr( standard_name, "]",  "", 30)
replace standard_name = subinstr( standard_name, "/",  " ", 30) 
* BHH - need to keep names separate if joined by / 
replace standard_name = subinstr( standard_name, "@",  "", 30)
replace standard_name = subinstr( standard_name, ":",  "", 30)
replace standard_name = subinstr( standard_name, "~",  "", 30)
replace standard_name = subinstr( standard_name, "#",  "", 30)
replace standard_name = subinstr( standard_name, "-",  " ", 30) 
* BHH -need to keep names separate if joined by - 

replace standard_name = subinstr( standard_name, "  ", " ", 30) 
* BHH -recode double space to space   

***********generate variable to try and identify a company instead of an individual***********************************************************************************************
*from "*****insert filepath here******\NBER patent data\name match programs from hall\4-corporates.do"
gen asstype="other"

replace asstype = "firm" if index(standard_name," & BRO ")>0
replace asstype = "firm" if index(standard_name," & BROTHER ")>0
replace asstype = "firm" if index(standard_name," & C ")>0
replace asstype = "firm" if index(standard_name," & CIE ")>0
replace asstype = "firm" if index(standard_name," & CO ")>0
replace asstype = "firm" if index(standard_name," & FILS ")>0
replace asstype = "firm" if index(standard_name," & PARTNER ")>0
replace asstype = "firm" if index(standard_name," & SOEHNE ")>0
replace asstype = "firm" if index(standard_name," & SOHN ")>0
replace asstype = "firm" if index(standard_name," & SON ")>0
replace asstype = "firm" if index(standard_name," & SONS ")>0
replace asstype = "firm" if index(standard_name," & ZN ")>0
replace asstype = "firm" if index(standard_name," & ZONEN ")>0
replace asstype = "firm" if index(standard_name," A ")>0
replace asstype = "firm" if index(standard_name," A G ")>0
replace asstype = "firm" if index(standard_name," A RL ")>0
replace asstype = "firm" if index(standard_name," A S ")>0
replace asstype = "firm" if index(standard_name," AANSPRAKELIJKHEID ")>0
replace asstype = "firm" if index(standard_name," AB ")>0
replace asstype = "firm" if index(standard_name," ACTIEN GESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," ACTIENGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AD ")>0
replace asstype = "firm" if index(standard_name," ADVIESBUREAU ")>0
replace asstype = "firm" if index(standard_name," AE ")>0
replace asstype = "firm" if index(standard_name," AG ")>0
replace asstype = "firm" if index(standard_name," AG & CO ")>0
replace asstype = "firm" if index(standard_name," AGG ")>0
replace asstype = "firm" if index(standard_name," AGSA ")>0
replace asstype = "firm" if index(standard_name," AK TIEBOLAGET ")>0
replace asstype = "firm" if index(standard_name," AKIEBOLAG ")>0
replace asstype = "firm" if index(standard_name," AKIEBOLG ")>0
replace asstype = "firm" if index(standard_name," AKIENGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKITENGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKITIEBOLAG ")>0
replace asstype = "firm" if index(standard_name," AKLIENGISELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKSJESELSKAP ")>0
replace asstype = "firm" if index(standard_name," AKSJESELSKAPET ")>0
replace asstype = "firm" if index(standard_name," AKSTIEBOLAGET ")>0
replace asstype = "firm" if index(standard_name," AKTAINGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTEIBOLAG ")>0
replace asstype = "firm" if index(standard_name," AKTEINGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIBOLAG ")>0
replace asstype = "firm" if index(standard_name," AKTIE BOLAGET ")>0
replace asstype = "firm" if index(standard_name," AKTIEBDAG ")>0
replace asstype = "firm" if index(standard_name," AKTIEBLOAG ")>0
replace asstype = "firm" if index(standard_name," AKTIEBOALG ")>0
replace asstype = "firm" if index(standard_name," AKTIEBOALGET ")>0
replace asstype = "firm" if index(standard_name," AKTIEBOCAG ")>0
replace asstype = "firm" if index(standard_name," AKTIEBOLAC ")>0
replace asstype = "firm" if index(standard_name," AKTIEBOLAF ")>0
replace asstype = "firm" if index(standard_name," AKTIEBOLAG ")>0
replace asstype = "firm" if index(standard_name," AKTIEBOLAGET ")>0
replace asstype = "firm" if index(standard_name," AKTIEBOLAQ ")>0
replace asstype = "firm" if index(standard_name," AKTIEBOLOG ")>0
replace asstype = "firm" if index(standard_name," AKTIEGBOLAG ")>0
replace asstype = "firm" if index(standard_name," AKTIEGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIEGOLAGET ")>0
replace asstype = "firm" if index(standard_name," AKTIELBOLAG ")>0
replace asstype = "firm" if index(standard_name," AKTIEN ")>0
replace asstype = "firm" if index(standard_name," AKTIEN GESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENBOLAG ")>0
replace asstype = "firm" if index(standard_name," AKTIENBOLAGET ")>0
replace asstype = "firm" if index(standard_name," AKTIENEGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENEGSELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGEGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESCELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELL SCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELLCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELLESCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELLESHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELLS ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELLSCAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELLSCGAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELLSCHART ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELLSCHATT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELLSCHGT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELLSCHRAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELLSHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELLSHAT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELLSHCAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESELSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESESCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESILLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESLLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESSELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGESSELSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGSELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENGTESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIENRESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTIESELSKAB ")>0
replace asstype = "firm" if index(standard_name," AKTIESELSKABET ")>0
replace asstype = "firm" if index(standard_name," AKTINGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AKTSIONERNAYA KOMPANIA ")>0
replace asstype = "firm" if index(standard_name," AKTSIONERNO ")>0
replace asstype = "firm" if index(standard_name," AKTSIONERNOE OBCHESTVO ")>0
replace asstype = "firm" if index(standard_name," AKTSIONERNOE OBSCHEDTVO ")>0
replace asstype = "firm" if index(standard_name," AKTSIONERNOE OBSCNESTVO ")>0
replace asstype = "firm" if index(standard_name," AKTSIONERNOE OBSHESTVO ")>0
replace asstype = "firm" if index(standard_name," AKTSIONERNOE OSBCHESTVO ")>0
replace asstype = "firm" if index(standard_name," AKTSIONERNOEOBSCHESTVO ")>0
replace asstype = "firm" if index(standard_name," ALTIENGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AMBA ")>0
replace asstype = "firm" if index(standard_name," AND SONS ")>0
replace asstype = "firm" if index(standard_name," ANDELSSELSKABET ")>0
replace asstype = "firm" if index(standard_name," ANLAGENGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," APPARATEBAU ")>0
replace asstype = "firm" if index(standard_name," APPERATEBAU ")>0
replace asstype = "firm" if index(standard_name," ARL ")>0
replace asstype = "firm" if index(standard_name," AS ")>0
replace asstype = "firm" if index(standard_name," ASA ")>0
replace asstype = "firm" if index(standard_name," ASKTIENGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," ASOCIADOS ")>0
replace asstype = "firm" if index(standard_name," ASSCOIATES ")>0
replace asstype = "firm" if index(standard_name," ASSOCIADOS ")>0
replace asstype = "firm" if index(standard_name," ASSOCIATE ")>0
replace asstype = "firm" if index(standard_name," ASSOCIATED ")>0
replace asstype = "firm" if index(standard_name," ASSOCIATES ")>0
replace asstype = "firm" if index(standard_name," ASSOCIATI ")>0
replace asstype = "firm" if index(standard_name," ASSOCIATO ")>0
replace asstype = "firm" if index(standard_name," ASSOCIES ")>0
replace asstype = "firm" if index(standard_name," ASSSOCIATES ")>0
replace asstype = "firm" if index(standard_name," ATELIER ")>0
replace asstype = "firm" if index(standard_name," ATELIERS ")>0
replace asstype = "firm" if index(standard_name," ATIBOLAG ")>0
replace asstype = "firm" if index(standard_name," ATKIEBOLAG ")>0
replace asstype = "firm" if index(standard_name," ATKIENGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," AVV ")>0
replace asstype = "firm" if index(standard_name," B ")>0
replace asstype = "firm" if index(standard_name," BANK ")>0
replace asstype = "firm" if index(standard_name," BANQUE ")>0
replace asstype = "firm" if index(standard_name," BEDRIJF ")>0
replace asstype = "firm" if index(standard_name," BEDRIJVEN ")>0
replace asstype = "firm" if index(standard_name," BEPERK ")>0
replace asstype = "firm" if index(standard_name," BEPERKTE AANSPREEKLIJKHEID ")>0
replace asstype = "firm" if index(standard_name," BESCHRAENKTER HAFTUNG ")>0
replace asstype = "firm" if index(standard_name," BESCHRANKTER ")>0
replace asstype = "firm" if index(standard_name," BESCHRANKTER HAFTUNG ")>0
replace asstype = "firm" if index(standard_name," BESLOTENGENOOTSCHAP ")>0
replace asstype = "firm" if index(standard_name," BESLOTENVENNOOTSCHAP ")>0
replace asstype = "firm" if index(standard_name," BETRIEBE ")>0
replace asstype = "firm" if index(standard_name," BMBH ")>0
replace asstype = "firm" if index(standard_name," BRANDS ")>0
replace asstype = "firm" if index(standard_name," BROS ")>0
replace asstype = "firm" if index(standard_name," BUSINESS ")>0
replace asstype = "firm" if index(standard_name," BV ")>0
replace asstype = "firm" if index(standard_name," BV: ")>0
replace asstype = "firm" if index(standard_name," BV? ")>0
replace asstype = "firm" if index(standard_name," BVBA ")>0
replace asstype = "firm" if index(standard_name," BVBASPRL ")>0
replace asstype = "firm" if index(standard_name," BVIO ")>0
replace asstype = "firm" if index(standard_name," BVSA ")>0
replace asstype = "firm" if index(standard_name," C{OVERSCORE O}RP ")>0
replace asstype = "firm" if index(standard_name," CAMPAGNIE ")>0
replace asstype = "firm" if index(standard_name," CAMPANY ")>0
replace asstype = "firm" if index(standard_name," CC ")>0
replace asstype = "firm" if index(standard_name," CIE ")>0
replace asstype = "firm" if index(standard_name," CMOPANY ")>0
replace asstype = "firm" if index(standard_name," CO ")>0
replace asstype = "firm" if index(standard_name," CO OPERATIVE ")>0
replace asstype = "firm" if index(standard_name," CO OPERATIVES ")>0
replace asstype = "firm" if index(standard_name," CO: ")>0
replace asstype = "firm" if index(standard_name," COFP ")>0
replace asstype = "firm" if index(standard_name," COIRPORATION ")>0
replace asstype = "firm" if index(standard_name," COMANY ")>0
replace asstype = "firm" if index(standard_name," COMAPANY ")>0
replace asstype = "firm" if index(standard_name," COMERCIAL ")>0
replace asstype = "firm" if index(standard_name," COMERCIO ")>0
replace asstype = "firm" if index(standard_name," COMMANDITE SIMPLE ")>0
replace asstype = "firm" if index(standard_name," COMMERCIALE ")>0
replace asstype = "firm" if index(standard_name," COMMERCIALISATIONS ")>0
replace asstype = "firm" if index(standard_name," COMNPANY ")>0
replace asstype = "firm" if index(standard_name," COMP ")>0
replace asstype = "firm" if index(standard_name," COMPAGNE ")>0
replace asstype = "firm" if index(standard_name," COMPAGNI ")>0
replace asstype = "firm" if index(standard_name," COMPAGNIE ")>0
replace asstype = "firm" if index(standard_name," COMPAGNIN ")>0
replace asstype = "firm" if index(standard_name," COMPAGNY ")>0
replace asstype = "firm" if index(standard_name," COMPAIGNIE ")>0
replace asstype = "firm" if index(standard_name," COMPAMY ")>0
replace asstype = "firm" if index(standard_name," COMPANAY ")>0
replace asstype = "firm" if index(standard_name," COMPANH ")>0
replace asstype = "firm" if index(standard_name," COMPANHIA ")>0
replace asstype = "firm" if index(standard_name," COMPANIA ")>0
replace asstype = "firm" if index(standard_name," COMPANIE ")>0
replace asstype = "firm" if index(standard_name," COMPANIES ")>0
replace asstype = "firm" if index(standard_name," COMPANY ")>0
replace asstype = "firm" if index(standard_name," COMPAY ")>0
replace asstype = "firm" if index(standard_name," COMPNAY ")>0
replace asstype = "firm" if index(standard_name," COMAPNY ")>0
replace asstype = "firm" if index(standard_name," COMPNY ")>0
replace asstype = "firm" if index(standard_name," COMPORATION ")>0
replace asstype = "firm" if index(standard_name," CONSORTILE PER AZIONE ")>0
replace asstype = "firm" if index(standard_name," CONSORZIO ")>0
replace asstype = "firm" if index(standard_name," CONSTRUCTIONS ")>0
replace asstype = "firm" if index(standard_name," CONSULTING ")>0
replace asstype = "firm" if index(standard_name," CONZORZIO ")>0
replace asstype = "firm" if index(standard_name," COOEPERATIE ")>0
replace asstype = "firm" if index(standard_name," COOEPERATIEVE ")>0
replace asstype = "firm" if index(standard_name," COOEPERATIEVE VERENIGING ")>0
replace asstype = "firm" if index(standard_name," COOEPERATIEVE VERKOOP ")>0
replace asstype = "firm" if index(standard_name," COOP ")>0
replace asstype = "firm" if index(standard_name," COOP A RL ")>0
replace asstype = "firm" if index(standard_name," COOPERATIE ")>0
replace asstype = "firm" if index(standard_name," COOPERATIEVE ")>0
replace asstype = "firm" if index(standard_name," COOPERATIEVE VENOOTSCHAP ")>0
replace asstype = "firm" if index(standard_name," COOPERATION ")>0
replace asstype = "firm" if index(standard_name," COOPERATIVA AGICOLA ")>0
replace asstype = "firm" if index(standard_name," COOPERATIVA LIMITADA ")>0
replace asstype = "firm" if index(standard_name," COOPERATIVA PER AZIONI ")>0
replace asstype = "firm" if index(standard_name," COORPORATION ")>0
replace asstype = "firm" if index(standard_name," COPANY ")>0
replace asstype = "firm" if index(standard_name," COPORATION ")>0
replace asstype = "firm" if index(standard_name," COPR ")>0
replace asstype = "firm" if index(standard_name," COPRORATION ")>0
replace asstype = "firm" if index(standard_name," COPRPORATION ")>0
replace asstype = "firm" if index(standard_name," COROPORTION ")>0
replace asstype = "firm" if index(standard_name," COROPRATION ")>0
replace asstype = "firm" if index(standard_name," COROPROATION ")>0
replace asstype = "firm" if index(standard_name," CORORATION ")>0
replace asstype = "firm" if index(standard_name," CORP ")>0
replace asstype = "firm" if index(standard_name," CORPARATION ")>0
replace asstype = "firm" if index(standard_name," CORPERATION ")>0
replace asstype = "firm" if index(standard_name," CORPFORATION ")>0
replace asstype = "firm" if index(standard_name," CORPN ")>0
replace asstype = "firm" if index(standard_name," CORPO ")>0
replace asstype = "firm" if index(standard_name," CORPOARTION ")>0
replace asstype = "firm" if index(standard_name," CORPOATAION ")>0
replace asstype = "firm" if index(standard_name," CORPOATION ")>0
replace asstype = "firm" if index(standard_name," CORPOIRATION ")>0
replace asstype = "firm" if index(standard_name," CORPOORATION ")>0
replace asstype = "firm" if index(standard_name," CORPOPRATION ")>0
replace asstype = "firm" if index(standard_name," CORPORAATION ")>0
replace asstype = "firm" if index(standard_name," CORPORACION ")>0
replace asstype = "firm" if index(standard_name," CORPORAION ")>0
replace asstype = "firm" if index(standard_name," CORPORAITON ")>0
replace asstype = "firm" if index(standard_name," CORPORARION ")>0
replace asstype = "firm" if index(standard_name," CORPORARTION ")>0
replace asstype = "firm" if index(standard_name," CORPORATAION ")>0
replace asstype = "firm" if index(standard_name," CORPORATE ")>0
replace asstype = "firm" if index(standard_name," CORPORATED ")>0
replace asstype = "firm" if index(standard_name," CORPORATI ")>0
replace asstype = "firm" if index(standard_name," CORPORATIION ")>0
replace asstype = "firm" if index(standard_name," CORPORATIN ")>0
replace asstype = "firm" if index(standard_name," CORPORATINO ")>0
replace asstype = "firm" if index(standard_name," CORPORATINON ")>0
replace asstype = "firm" if index(standard_name," CORPORATIO ")>0
replace asstype = "firm" if index(standard_name," CORPORATIOIN ")>0
replace asstype = "firm" if index(standard_name," CORPORATIOLN ")>0
replace asstype = "firm" if index(standard_name," CORPORATIOM ")>0
replace asstype = "firm" if index(standard_name," CORPORATION ")>0
replace asstype = "firm" if index(standard_name," CORPORATIOPN ")>0
replace asstype = "firm" if index(standard_name," CORPORATITON ")>0
replace asstype = "firm" if index(standard_name," CORPORATOIN ")>0
replace asstype = "firm" if index(standard_name," CORPORDATION ")>0
replace asstype = "firm" if index(standard_name," CORPORQTION ")>0
replace asstype = "firm" if index(standard_name," CORPORTAION ")>0
replace asstype = "firm" if index(standard_name," CORPORTATION ")>0
replace asstype = "firm" if index(standard_name," CORPORTION ")>0
replace asstype = "firm" if index(standard_name," CORPPORATION ")>0
replace asstype = "firm" if index(standard_name," CORPRATION ")>0
replace asstype = "firm" if index(standard_name," CORPROATION ")>0
replace asstype = "firm" if index(standard_name," CORPRORATION ")>0
replace asstype = "firm" if index(standard_name," CROP ")>0
replace asstype = "firm" if index(standard_name," CROPORATION ")>0
replace asstype = "firm" if index(standard_name," CRPORATION ")>0
replace asstype = "firm" if index(standard_name," CV ")>0
replace asstype = "firm" if index(standard_name," D ENTERPRISES ")>0
replace asstype = "firm" if index(standard_name," D ENTREPRISE ")>0
replace asstype = "firm" if index(standard_name," D O O ")>0
replace asstype = "firm" if index(standard_name," D’ENTREPRISE ")>0
replace asstype = "firm" if index(standard_name," DD ")>0
replace asstype = "firm" if index(standard_name," DEVELOP ")>0
replace asstype = "firm" if index(standard_name," DEVELOPPEMENT ")>0
replace asstype = "firm" if index(standard_name," DEVELOPPEMENTS ")>0
replace asstype = "firm" if index(standard_name," DOING BUSINESS ")>0
replace asstype = "firm" if index(standard_name," DOO ")>0
replace asstype = "firm" if index(standard_name," DORPORATION ")>0
replace asstype = "firm" if index(standard_name," EDMS ")>0
replace asstype = "firm" if index(standard_name," EG ")>0
replace asstype = "firm" if index(standard_name," ELECTRONIQUE ")>0
replace asstype = "firm" if index(standard_name," EN ZN ")>0
replace asstype = "firm" if index(standard_name," EN ZONEN ")>0
replace asstype = "firm" if index(standard_name," ENGINEERING ")>0
replace asstype = "firm" if index(standard_name," ENGINEERS ")>0
replace asstype = "firm" if index(standard_name," ENGINES ")>0
replace asstype = "firm" if index(standard_name," ENNOBLISSEMENT ")>0
replace asstype = "firm" if index(standard_name," ENTERPRISE ")>0
replace asstype = "firm" if index(standard_name," ENTRE PRISES ")>0
replace asstype = "firm" if index(standard_name," ENTREPOSE ")>0
replace asstype = "firm" if index(standard_name," ENTREPRISE ")>0
replace asstype = "firm" if index(standard_name," ENTREPRISES ")>0
replace asstype = "firm" if index(standard_name," EQUIP ")>0
replace asstype = "firm" if index(standard_name," EQUIPAMENTOS ")>0
replace asstype = "firm" if index(standard_name," EQUIPEMENT ")>0
replace asstype = "firm" if index(standard_name," EQUIPEMENTS ")>0
replace asstype = "firm" if index(standard_name," EQUIPMENT ")>0
replace asstype = "firm" if index(standard_name," EST ")>0
replace asstype = "firm" if index(standard_name," ESTABILSSEMENTS ")>0
replace asstype = "firm" if index(standard_name," ESTABLISHMENT ")>0
replace asstype = "firm" if index(standard_name," ESTABLISSEMENT ")>0
replace asstype = "firm" if index(standard_name," ESTABLISSEMENTS ")>0
replace asstype = "firm" if index(standard_name," ESTABLISSMENTS ")>0
replace asstype = "firm" if index(standard_name," ET FILS ")>0
replace asstype = "firm" if index(standard_name," ETABLISSEMENT ")>0
replace asstype = "firm" if index(standard_name," ETABLISSMENTS ")>0
replace asstype = "firm" if index(standard_name," ETS ")>0
replace asstype = "firm" if index(standard_name," FABRIC ")>0
replace asstype = "firm" if index(standard_name," FABRICA ")>0
replace asstype = "firm" if index(standard_name," FABRICATION ")>0
replace asstype = "firm" if index(standard_name," FABRICATIONS ")>0
replace asstype = "firm" if index(standard_name," FABRICS ")>0
replace asstype = "firm" if index(standard_name," FABRIEKEN ")>0
replace asstype = "firm" if index(standard_name," FABRIK ")>0
replace asstype = "firm" if index(standard_name," FABRIQUE ")>0
replace asstype = "firm" if index(standard_name," FABRYKA ")>0
replace asstype = "firm" if index(standard_name," FACTORY ")>0
replace asstype = "firm" if index(standard_name," FEDERATED ")>0
replace asstype = "firm" if index(standard_name," FILM ")>0
replace asstype = "firm" if index(standard_name," FINANCIERE ")>0
replace asstype = "firm" if index(standard_name," FIRM ")>0
replace asstype = "firm" if index(standard_name," FIRMA ")>0
replace asstype = "firm" if index(standard_name," GBMH ")>0
replace asstype = "firm" if index(standard_name," GBR ")>0
replace asstype = "firm" if index(standard_name," GEBR ")>0
replace asstype = "firm" if index(standard_name," GEBROEDERS ")>0
replace asstype = "firm" if index(standard_name," GEBRUEDER ")>0
replace asstype = "firm" if index(standard_name," GENERALE POUR LES TECHNIQUES NOUVELLE ")>0
replace asstype = "firm" if index(standard_name," GENOSSENSCHAFT ")>0
replace asstype = "firm" if index(standard_name," GES M B H ")>0
replace asstype = "firm" if index(standard_name," GES MB H ")>0
replace asstype = "firm" if index(standard_name," GES MBH ")>0
replace asstype = "firm" if index(standard_name," GES MHH ")>0
replace asstype = "firm" if index(standard_name," GESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," GESELLSCHAFT M B ")>0
replace asstype = "firm" if index(standard_name," GESELLSCHAFT MB H ")>0
replace asstype = "firm" if index(standard_name," GESELLSCHAFT MBH ")>0
replace asstype = "firm" if index(standard_name," GESELLSCHAFT MGH ")>0
replace asstype = "firm" if index(standard_name," GESELLSCHAFT MIT ")>0
replace asstype = "firm" if index(standard_name," GESELLSCHAFT MIT BESCHRANKTER ")>0
replace asstype = "firm" if index(standard_name," GESELLSCHAFT MIT BESCHRANKTER HAFT ")>0
replace asstype = "firm" if index(standard_name," GESELLSCHAFTMIT BESCHRANKTER ")>0
replace asstype = "firm" if index(standard_name," GESMBH ")>0
replace asstype = "firm" if index(standard_name," GES ")>0
replace asstype = "firm" if index(standard_name," GESSELLSCHAFT MIT BESCHRAENKTER HAUFTUNG ")>0
replace asstype = "firm" if index(standard_name," GIE ")>0
replace asstype = "firm" if index(standard_name," GMBA ")>0
replace asstype = "firm" if index(standard_name," GMBB ")>0
replace asstype = "firm" if index(standard_name," GMBG ")>0
replace asstype = "firm" if index(standard_name," GMBH ")>0
replace asstype = "firm" if index(standard_name," GMHB ")>0
replace asstype = "firm" if index(standard_name," GNBH ")>0
replace asstype = "firm" if index(standard_name," GORPORATION ")>0
replace asstype = "firm" if index(standard_name," GROEP ")>0
replace asstype = "firm" if index(standard_name," GROUP ")>0
replace asstype = "firm" if index(standard_name," GROUPEMENT D ENTREPRISES ")>0
replace asstype = "firm" if index(standard_name," H ")>0
replace asstype = "firm" if index(standard_name," HAFRUNG ")>0
replace asstype = "firm" if index(standard_name," HANDEL ")>0
replace asstype = "firm" if index(standard_name," HANDELABOLAGET ")>0
replace asstype = "firm" if index(standard_name," HANDELEND ONDER ")>0
replace asstype = "firm" if index(standard_name," HANDELORGANISATION ")>0
replace asstype = "firm" if index(standard_name," HANDELS ")>0
replace asstype = "firm" if index(standard_name," HANDELSBOLAG ")>0
replace asstype = "firm" if index(standard_name," HANDELSBOLAGET ")>0
replace asstype = "firm" if index(standard_name," HANDELSGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," HANDESBOLAG ")>0
replace asstype = "firm" if index(standard_name," HATFUNG ")>0
replace asstype = "firm" if index(standard_name," HB ")>0
replace asstype = "firm" if index(standard_name," HF ")>0
replace asstype = "firm" if index(standard_name," HOLDINGS ")>0
replace asstype = "firm" if index(standard_name," INC ")>0
replace asstype = "firm" if index(standard_name," INC: ")>0
replace asstype = "firm" if index(standard_name," INCOPORATED ")>0
replace asstype = "firm" if index(standard_name," INCORORATED ")>0
replace asstype = "firm" if index(standard_name," INCORPARATED ")>0
replace asstype = "firm" if index(standard_name," INCORPATED ")>0
replace asstype = "firm" if index(standard_name," INCORPORATE ")>0
replace asstype = "firm" if index(standard_name," INCORPORATED ")>0
replace asstype = "firm" if index(standard_name," INCORPORORATED ")>0
replace asstype = "firm" if index(standard_name," INCORPORTED ")>0
replace asstype = "firm" if index(standard_name," INCORPOTATED ")>0
replace asstype = "firm" if index(standard_name," INCORPRATED ")>0
replace asstype = "firm" if index(standard_name," INCORPRORATED ")>0
replace asstype = "firm" if index(standard_name," INCROPORATED ")>0
replace asstype = "firm" if index(standard_name," INDISTRIES ")>0
replace asstype = "firm" if index(standard_name," INDUSRTIES ")>0
replace asstype = "firm" if index(standard_name," INDUSTRI ")>0
replace asstype = "firm" if index(standard_name," INDUSTRIA ")>0
replace asstype = "firm" if index(standard_name," INDUSTRIAL ")>0
replace asstype = "firm" if index(standard_name," INDUSTRIAL COP ")>0
replace asstype = "firm" if index(standard_name," INDUSTRIALNA ")>0
replace asstype = "firm" if index(standard_name," INDUSTRIAS ")>0
replace asstype = "firm" if index(standard_name," INDUSTRIE ")>0
replace asstype = "firm" if index(standard_name," INDUSTRIES ")>0
replace asstype = "firm" if index(standard_name," INDUSTRIJA ")>0
replace asstype = "firm" if index(standard_name," INDUSTRIJSKO ")>0
replace asstype = "firm" if index(standard_name," INGENIEURBUERO ")>0
replace asstype = "firm" if index(standard_name," INGENIEURBURO ")>0
replace asstype = "firm" if index(standard_name," INGENIEURGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," INGENIEURSBUERO ")>0
replace asstype = "firm" if index(standard_name," INGENIEURSBUREAU ")>0
replace asstype = "firm" if index(standard_name," INGENIOERSBYRA ")>0
replace asstype = "firm" if index(standard_name," INGENJOERSFIRMA ")>0
replace asstype = "firm" if index(standard_name," INGENJOERSFIRMAN ")>0
replace asstype = "firm" if index(standard_name," INORPORATED ")>0
replace asstype = "firm" if index(standard_name," INT ")>0
replace asstype = "firm" if index(standard_name," INT L ")>0
replace asstype = "firm" if index(standard_name," INTERNAITONAL ")>0
replace asstype = "firm" if index(standard_name," INTERNATIONAL ")>0
replace asstype = "firm" if index(standard_name," INTERNATIONAL BUSINESS ")>0
replace asstype = "firm" if index(standard_name," INTERNATIONALE ")>0
replace asstype = "firm" if index(standard_name," INTERNATIONAUX ")>0
replace asstype = "firm" if index(standard_name," INTERNTIONAL ")>0
replace asstype = "firm" if index(standard_name," INTL ")>0
replace asstype = "firm" if index(standard_name," INUDSTRIE ")>0
replace asstype = "firm" if index(standard_name," INVESTMENT ")>0
replace asstype = "firm" if index(standard_name," IS ")>0
replace asstype = "firm" if index(standard_name," JOINTVENTURE ")>0
replace asstype = "firm" if index(standard_name," K G ")>0
replace asstype = "firm" if index(standard_name," K K ")>0
replace asstype = "firm" if index(standard_name," KABAUSHIKI KAISHA ")>0
replace asstype = "firm" if index(standard_name," KABISHIKI KAISHA ")>0
replace asstype = "firm" if index(standard_name," KABSUHIKI ")>0
replace asstype = "firm" if index(standard_name," KABUSHI KIKAISHA ")>0
replace asstype = "firm" if index(standard_name," KABUSHIBI KAISHA ")>0
replace asstype = "firm" if index(standard_name," KABUSHIKAISHA ")>0
replace asstype = "firm" if index(standard_name," KABUSHIKI ")>0
replace asstype = "firm" if index(standard_name," KABUSHIKKAISHA ")>0
replace asstype = "firm" if index(standard_name," KABUSHIKU KASISHA ")>0
replace asstype = "firm" if index(standard_name," KABUSHKIKI KAISHI ")>0
replace asstype = "firm" if index(standard_name," KABUSIKI ")>0
replace asstype = "firm" if index(standard_name," KABUSIKI KAISHA ")>0
replace asstype = "firm" if index(standard_name," KABUSIKI KAISYA ")>0
replace asstype = "firm" if index(standard_name," KABUSIKIKAISHA ")>0
replace asstype = "firm" if index(standard_name," KAGUSHIKI KAISHA ")>0
replace asstype = "firm" if index(standard_name," KAUSHIKI KAISHA ")>0
replace asstype = "firm" if index(standard_name," KAISHA ")>0
replace asstype = "firm" if index(standard_name," KAISYA ")>0
replace asstype = "firm" if index(standard_name," KABAUSHIKI GAISHA ")>0
replace asstype = "firm" if index(standard_name," KABISHIKI GAISHA ")>0
replace asstype = "firm" if index(standard_name," KABUSHI KIGAISHA ")>0
replace asstype = "firm" if index(standard_name," KABUSHIBI GAISHA ")>0
replace asstype = "firm" if index(standard_name," KABUSHIGAISHA ")>0
replace asstype = "firm" if index(standard_name," KABUSHIKGAISHA ")>0
replace asstype = "firm" if index(standard_name," KABUSHIKU GASISHA ")>0
replace asstype = "firm" if index(standard_name," KABUSHKIKI GAISHI ")>0
replace asstype = "firm" if index(standard_name," KABUSIKI GAISHA ")>0
replace asstype = "firm" if index(standard_name," KABUSIKI GAISYA ")>0
replace asstype = "firm" if index(standard_name," KABUSIKIGAISHA ")>0
replace asstype = "firm" if index(standard_name," KAGUSHIKI GAISHA ")>0
replace asstype = "firm" if index(standard_name," KAUSHIKI GAISHA ")>0
replace asstype = "firm" if index(standard_name," GAISHA ")>0
replace asstype = "firm" if index(standard_name," GAISYA ")>0
replace asstype = "firm" if index(standard_name," KB ")>0
replace asstype = "firm" if index(standard_name," KB KY ")>0
replace asstype = "firm" if index(standard_name," KFT ")>0
replace asstype = "firm" if index(standard_name," KG ")>0
replace asstype = "firm" if index(standard_name," KGAA ")>0
replace asstype = "firm" if index(standard_name," KK ")>0
replace asstype = "firm" if index(standard_name," KOM GES ")>0
replace asstype = "firm" if index(standard_name," KOMM GES ")>0
replace asstype = "firm" if index(standard_name," KOMMANDITBOLAG ")>0
replace asstype = "firm" if index(standard_name," KOMMANDITBOLAGET ")>0
replace asstype = "firm" if index(standard_name," KOMMANDITGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," KONSTRUKTIONEN ")>0
replace asstype = "firm" if index(standard_name," KOOPERATIVE ")>0
replace asstype = "firm" if index(standard_name," KS ")>0
replace asstype = "firm" if index(standard_name," KUBUSHIKI KAISHA ")>0
replace asstype = "firm" if index(standard_name," KY ")>0
replace asstype = "firm" if index(standard_name," L ")>0
replace asstype = "firm" if index(standard_name," L C ")>0
replace asstype = "firm" if index(standard_name," L L C ")>0
replace asstype = "firm" if index(standard_name," L P ")>0
replace asstype = "firm" if index(standard_name," LAB ")>0
replace asstype = "firm" if index(standard_name," LABARATOIRE ")>0
replace asstype = "firm" if index(standard_name," LABO ")>0
replace asstype = "firm" if index(standard_name," LABORATOIRE ")>0
replace asstype = "firm" if index(standard_name," LABORATOIRES ")>0
replace asstype = "firm" if index(standard_name," LABORATORI ")>0
replace asstype = "firm" if index(standard_name," LABORATORIA ")>0
replace asstype = "firm" if index(standard_name," LABORATORIE ")>0
replace asstype = "firm" if index(standard_name," LABORATORIES ")>0
replace asstype = "firm" if index(standard_name," LABORATORIET ")>0
replace asstype = "firm" if index(standard_name," LABORATORIUM ")>0
replace asstype = "firm" if index(standard_name," LABORATORY ")>0
replace asstype = "firm" if index(standard_name," LABRATIORIES ")>0
replace asstype = "firm" if index(standard_name," LABS ")>0
replace asstype = "firm" if index(standard_name," LC ")>0
replace asstype = "firm" if index(standard_name," LCC ")>0
replace asstype = "firm" if index(standard_name," LDA ")>0
replace asstype = "firm" if index(standard_name," LDT ")>0
replace asstype = "firm" if index(standard_name," LIIMITED ")>0
replace asstype = "firm" if index(standard_name," LIMIDADA ")>0
replace asstype = "firm" if index(standard_name," LIMINTED ")>0
replace asstype = "firm" if index(standard_name," LIMITADA ")>0
replace asstype = "firm" if index(standard_name," LIMITADO ")>0
replace asstype = "firm" if index(standard_name," LIMITATA ")>0
replace asstype = "firm" if index(standard_name," LIMITE ")>0
replace asstype = "firm" if index(standard_name," LIMITED ")>0
replace asstype = "firm" if index(standard_name," LIMITEE ")>0
replace asstype = "firm" if index(standard_name," LIMTED ")>0
replace asstype = "firm" if index(standard_name," LINITED ")>0
replace asstype = "firm" if index(standard_name," LITD ")>0
replace asstype = "firm" if index(standard_name," LLC ")>0
replace asstype = "firm" if index(standard_name," LLLC ")>0
replace asstype = "firm" if index(standard_name," LLLP ")>0
replace asstype = "firm" if index(standard_name," LLP ")>0
replace asstype = "firm" if index(standard_name," LMITED ")>0
replace asstype = "firm" if index(standard_name," LP ")>0
replace asstype = "firm" if index(standard_name," LT EE ")>0
replace asstype = "firm" if index(standard_name," LTA ")>0
replace asstype = "firm" if index(standard_name," LTC ")>0
replace asstype = "firm" if index(standard_name," LTD ")>0
replace asstype = "firm" if index(standard_name," LTD: ")>0
replace asstype = "firm" if index(standard_name," LTDA ")>0
replace asstype = "firm" if index(standard_name," LTDS ")>0
replace asstype = "firm" if index(standard_name," LTEE ")>0
replace asstype = "firm" if index(standard_name," LTEE; ")>0
replace asstype = "firm" if index(standard_name," LTS ")>0
replace asstype = "firm" if index(standard_name," MAATSCHAPPIJ ")>0
replace asstype = "firm" if index(standard_name," MANUFACTURE ")>0
replace asstype = "firm" if index(standard_name," MANUFACTURE D ARTICLES ")>0
replace asstype = "firm" if index(standard_name," MANUFACTURE DE ")>0
replace asstype = "firm" if index(standard_name," MANUFACTURING ")>0
replace asstype = "firm" if index(standard_name," MARKETING ")>0
replace asstype = "firm" if index(standard_name," MASCHINENBAU ")>0
replace asstype = "firm" if index(standard_name," MASCHINENFABRIK ")>0
replace asstype = "firm" if index(standard_name," MBH ")>0
replace asstype = "firm" if index(standard_name," MBH & CO ")>0
replace asstype = "firm" if index(standard_name," MERCHANDISING ")>0
replace asstype = "firm" if index(standard_name," MET BEPERKTE ")>0
replace asstype = "firm" if index(standard_name," MFG ")>0
replace asstype = "firm" if index(standard_name," N A ")>0
replace asstype = "firm" if index(standard_name," N V ")>0
replace asstype = "firm" if index(standard_name," NA ")>0
replace asstype = "firm" if index(standard_name," NAAMLOSE ")>0
replace asstype = "firm" if index(standard_name," NAAMLOZE ")>0
replace asstype = "firm" if index(standard_name," NAAMLOZE VENNOOTSCAP ")>0
replace asstype = "firm" if index(standard_name," NAAMLOZE VENNOOTSHCAP ")>0
replace asstype = "firm" if index(standard_name," NAAMLOZEVENNOOTSCHAP ")>0
replace asstype = "firm" if index(standard_name," NAUCHNO PRIOZVODSTVENNAYA FIRMA ")>0
replace asstype = "firm" if index(standard_name," NAUCHNO PRIOZVODSTVENNOE OBIEDINENIE ")>0
replace asstype = "firm" if index(standard_name," NAUCHNO PRIOZVODSTVENNY KOOPERATIV ")>0
replace asstype = "firm" if index(standard_name," NAUCHNO PROIZVODSTVENNOE ")>0
replace asstype = "firm" if index(standard_name," NAUCHNO PROIZVODSTVENNOE OBJEDINENIE ")>0
replace asstype = "firm" if index(standard_name," NAUCHNO TEKHNICHESKY KOOPERATIV ")>0
replace asstype = "firm" if index(standard_name," NAUCHNO TEKHNICHESKYKKOOPERATIV ")>0
replace asstype = "firm" if index(standard_name," NAUCHNO TEKHNOLOGICHESKOE ")>0
replace asstype = "firm" if index(standard_name," NAUCHNO TEKHNOLOGICHESKOEPREDPRIYATIE ")>0
replace asstype = "firm" if index(standard_name," NAUCHNOPRIOZVODSTVENNOE ")>0
replace asstype = "firm" if index(standard_name," NAUCHNOPROIZVODSTVENNOE ")>0
replace asstype = "firm" if index(standard_name," NAUCHNOTEKHNICHESKYKKOOPERATIV ")>0
replace asstype = "firm" if index(standard_name," NAUCHNOTEKNICHESKY ")>0
replace asstype = "firm" if index(standard_name," NV ")>0
replace asstype = "firm" if index(standard_name," NV SA ")>0
replace asstype = "firm" if index(standard_name," NV: ")>0
replace asstype = "firm" if index(standard_name," NVSA ")>0
replace asstype = "firm" if index(standard_name," OBIDINENIE ")>0
replace asstype = "firm" if index(standard_name," OBIED ")>0
replace asstype = "firm" if index(standard_name," OBSCHESRYO ")>0
replace asstype = "firm" if index(standard_name," OBSCHESTVO & OGRANICHENNOI OTVETSTVENNOSTJU ")>0
replace asstype = "firm" if index(standard_name," OBSCHESTVO & ORGANICHENNOI OTVETSTVENNOSTIJU ")>0
replace asstype = "firm" if index(standard_name," OBSCHESTVO C ")>0
replace asstype = "firm" if index(standard_name," OBSCHESTVO S ")>0
replace asstype = "firm" if index(standard_name," OBSCHESTVO S OGRANICHENNOI ")>0
replace asstype = "firm" if index(standard_name," OBSCHESTVO S OGRANICHENNOI OTVETSTVEN NOSTJU ")>0
replace asstype = "firm" if index(standard_name," OBSCHESTVO S OGRANICHENNOI OTVETSTVENNOSTIJU ")>0
replace asstype = "firm" if index(standard_name," OBSCHESTVO S OGRANICHENNOI OTVETSTVENNPSTJU ")>0
replace asstype = "firm" if index(standard_name," OBSCHESTVO S OGRANICHENNOY OTVETSTVENNOSTJU ")>0
replace asstype = "firm" if index(standard_name," OBSCHESTVO S OGRANICHENOI ")>0
replace asstype = "firm" if index(standard_name," OBSCHESTVO S ORGANICHENNOI OTVETSTVENNOSTIJU ")>0
replace asstype = "firm" if index(standard_name," OBSCHESTVO S ORGANICHENNOI OTVETSTVENNOSTJU ")>0
replace asstype = "firm" if index(standard_name," OBSHESTVO S ")>0
replace asstype = "firm" if index(standard_name," OBSHESTVO S OGRANNICHENNOJ ")>0
replace asstype = "firm" if index(standard_name," OBSHESTVO S ORGANICHENNOI OTVETSTVENNOSTIJU ")>0
replace asstype = "firm" if index(standard_name," OBSHESTVO S ORGANICHENNOI OTVETSTVENNOSTJU ")>0
replace asstype = "firm" if index(standard_name," OCTROOIBUREAU ")>0
replace asstype = "firm" if index(standard_name," OGRANICHENNOI OTVETSTVENNOSTIJU ")>0
replace asstype = "firm" if index(standard_name," OGRANICHENNOI OTVETSTVENNOSTIJU FIRMA ")>0
replace asstype = "firm" if index(standard_name," OGRANICHENNOI OTVETSTVENNOSTJU ")>0
replace asstype = "firm" if index(standard_name," OGRANICHENNOY OTVETSTVENNOSTYU ")>0
replace asstype = "firm" if index(standard_name," OHG ")>0
replace asstype = "firm" if index(standard_name," ONDERNEMING ")>0
replace asstype = "firm" if index(standard_name," OTVETCTVENNOSTJU ")>0
replace asstype = "firm" if index(standard_name," OTVETSTVENNOSTIJU ")>0
replace asstype = "firm" if index(standard_name," OTVETSTVENNOSTJU ")>0
replace asstype = "firm" if index(standard_name," OTVETSTVENNOSTOU ")>0
replace asstype = "firm" if index(standard_name," OTVETSTVENNOSTYU ")>0
replace asstype = "firm" if index(standard_name," OY ")>0
replace asstype = "firm" if index(standard_name," OYABLTD ")>0
replace asstype = "firm" if index(standard_name," OYG ")>0
replace asstype = "firm" if index(standard_name," OYI ")>0
replace asstype = "firm" if index(standard_name," OYJ ")>0
replace asstype = "firm" if index(standard_name," OYL ")>0
replace asstype = "firm" if index(standard_name," P ")>0
replace asstype = "firm" if index(standard_name," P C ")>0
replace asstype = "firm" if index(standard_name," P L C ")>0
replace asstype = "firm" if index(standard_name," PARNERSHIP ")>0
replace asstype = "firm" if index(standard_name," PARNTERSHIP ")>0
replace asstype = "firm" if index(standard_name," PARTNER ")>0
replace asstype = "firm" if index(standard_name," PARTNERS ")>0
replace asstype = "firm" if index(standard_name," PARTNERSHIP ")>0
replace asstype = "firm" if index(standard_name," PATENT OFFICE ")>0
replace asstype = "firm" if index(standard_name," PATENTVERWALTUNGS GESELLSCHAFT MBH ")>0
replace asstype = "firm" if index(standard_name," PATENTVERWALTUNGSGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," PATENTVERWERTUNGSGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," PATNERSHIP ")>0
replace asstype = "firm" if index(standard_name," PC ")>0
replace asstype = "firm" if index(standard_name," PER AZIONA ")>0
replace asstype = "firm" if index(standard_name," PERSONENVENNOOTSCHAP MET BE PERKTE AANSPRAKELIJKHEID ")>0
replace asstype = "firm" if index(standard_name," PHARM ")>0
replace asstype = "firm" if index(standard_name," PHARMACEUTICA ")>0
replace asstype = "firm" if index(standard_name," PHARMACEUTICAL ")>0
replace asstype = "firm" if index(standard_name," PHARMACEUTICALS ")>0
replace asstype = "firm" if index(standard_name," PHARMACEUTIQUE ")>0
replace asstype = "firm" if index(standard_name," PHARMACIA ")>0
replace asstype = "firm" if index(standard_name," PHARMACIE ")>0
replace asstype = "firm" if index(standard_name," PHARMACUETICALS ")>0
replace asstype = "firm" if index(standard_name," PLANTS ")>0
replace asstype = "firm" if index(standard_name," PLC ")>0
replace asstype = "firm" if index(standard_name," PREDPRIVATIE ")>0
replace asstype = "firm" if index(standard_name," PREDPRIYATIE ")>0
replace asstype = "firm" if index(standard_name," PREPRIVATIE ")>0
replace asstype = "firm" if index(standard_name," PRODUCE ")>0
replace asstype = "firm" if index(standard_name," PRODUCT ")>0
replace asstype = "firm" if index(standard_name," PRODUCTEURS ")>0
replace asstype = "firm" if index(standard_name," PRODUCTION ")>0
replace asstype = "firm" if index(standard_name," PRODUCTIONS ")>0
replace asstype = "firm" if index(standard_name," PRODUCTIQUE ")>0
replace asstype = "firm" if index(standard_name," PRODUCTS ")>0
replace asstype = "firm" if index(standard_name," PRODUITS ")>0
replace asstype = "firm" if index(standard_name," PRODUKTE ")>0
replace asstype = "firm" if index(standard_name," PRODUKTER ")>0
replace asstype = "firm" if index(standard_name," PRODUKTION ")>0
replace asstype = "firm" if index(standard_name," PRODUKTIONSGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," PRODUKTUTVECKLING ")>0
replace asstype = "firm" if index(standard_name," PRODURA ")>0
replace asstype = "firm" if index(standard_name," PRODUTIS ")>0
replace asstype = "firm" if index(standard_name," PROIZVODSTENNOE OBIEDINENIE ")>0
replace asstype = "firm" if index(standard_name," PROIZVODSTVENNOE ")>0
replace asstype = "firm" if index(standard_name," PROIZVODSTVENNOE OBIEDINENIE ")>0
replace asstype = "firm" if index(standard_name," PTY ")>0
replace asstype = "firm" if index(standard_name," PTY LIM ")>0
replace asstype = "firm" if index(standard_name," PTYLTD ")>0
replace asstype = "firm" if index(standard_name," PUBLISHING ")>0
replace asstype = "firm" if index(standard_name," PVBA ")>0
replace asstype = "firm" if index(standard_name," RECHERCHES ")>0
replace asstype = "firm" if index(standard_name," RESPONSABILITA LIMITATA ")>0
replace asstype = "firm" if index(standard_name," RESPONSABILITA’ LIMITATA ")>0
replace asstype = "firm" if index(standard_name," RESPONSABILITE LIMITE ")>0
replace asstype = "firm" if index(standard_name," RO ")>0
replace asstype = "firm" if index(standard_name," RT ")>0
replace asstype = "firm" if index(standard_name," S A ")>0
replace asstype = "firm" if index(standard_name," S A R L ")>0
replace asstype = "firm" if index(standard_name," S A RL ")>0
replace asstype = "firm" if index(standard_name," S COOP ")>0
replace asstype = "firm" if index(standard_name," S COOP LTDA ")>0
replace asstype = "firm" if index(standard_name," S NC ")>0
replace asstype = "firm" if index(standard_name," S OGRANICHENNOI OTVETSTVENNEST ")>0
replace asstype = "firm" if index(standard_name," S P A ")>0
replace asstype = "firm" if index(standard_name," S PA ")>0
replace asstype = "firm" if index(standard_name," S R L ")>0
replace asstype = "firm" if index(standard_name," S RL ")>0
replace asstype = "firm" if index(standard_name," S S ")>0
replace asstype = "firm" if index(standard_name," SA ")>0
replace asstype = "firm" if index(standard_name," SA A RL ")>0
replace asstype = "firm" if index(standard_name," SA RL ")>0
replace asstype = "firm" if index(standard_name," SA: ")>0
replace asstype = "firm" if index(standard_name," SAAG ")>0
replace asstype = "firm" if index(standard_name," SAARL ")>0
replace asstype = "firm" if index(standard_name," SALES ")>0
replace asstype = "firm" if index(standard_name," SANV ")>0
replace asstype = "firm" if index(standard_name," SARL ")>0
replace asstype = "firm" if index(standard_name," SARL: ")>0
replace asstype = "firm" if index(standard_name," SAS ")>0
replace asstype = "firm" if index(standard_name," SC ")>0
replace asstype = "firm" if index(standard_name," SCA ")>0
replace asstype = "firm" if index(standard_name," SCARL ")>0
replace asstype = "firm" if index(standard_name," SCIETE ANONYME ")>0
replace asstype = "firm" if index(standard_name," SCOOP ")>0
replace asstype = "firm" if index(standard_name," SCPA ")>0
replace asstype = "firm" if index(standard_name," SCRAS ")>0
replace asstype = "firm" if index(standard_name," SCRL ")>0
replace asstype = "firm" if index(standard_name," SEMPLICE ")>0
replace asstype = "firm" if index(standard_name," SERIVICES ")>0
replace asstype = "firm" if index(standard_name," SERVICE ")>0
replace asstype = "firm" if index(standard_name," SERVICES ")>0
replace asstype = "firm" if index(standard_name," SHOP ")>0
replace asstype = "firm" if index(standard_name," SIMPLIFIEE ")>0
replace asstype = "firm" if index(standard_name," SL ")>0
replace asstype = "firm" if index(standard_name," SNC ")>0
replace asstype = "firm" if index(standard_name," SOC ")>0
replace asstype = "firm" if index(standard_name," SOC ARL ")>0
replace asstype = "firm" if index(standard_name," SOC COOOP ARL ")>0
replace asstype = "firm" if index(standard_name," SOC COOP A RESP LIM ")>0
replace asstype = "firm" if index(standard_name," SOC COOP A RL ")>0
replace asstype = "firm" if index(standard_name," SOC COOP R L ")>0
replace asstype = "firm" if index(standard_name," SOC COOP RL ")>0
replace asstype = "firm" if index(standard_name," SOC IND COMM ")>0
replace asstype = "firm" if index(standard_name," SOC RL ")>0
replace asstype = "firm" if index(standard_name," SOCCOOP ARL ")>0
replace asstype = "firm" if index(standard_name," SOCCOOPARL ")>0
replace asstype = "firm" if index(standard_name," SOCIEDAD ")>0
replace asstype = "firm" if index(standard_name," SOCIEDAD ANONIMA ")>0
replace asstype = "firm" if index(standard_name," SOCIEDAD ANONIMYA ")>0
replace asstype = "firm" if index(standard_name," SOCIEDAD INDUSTRIAL ")>0
replace asstype = "firm" if index(standard_name," SOCIEDAD LIMITADA ")>0
replace asstype = "firm" if index(standard_name," SOCIEDADE LIMITADA ")>0
replace asstype = "firm" if index(standard_name," SOCIET CIVILE ")>0
replace asstype = "firm" if index(standard_name," SOCIETA ")>0
replace asstype = "firm" if index(standard_name," SOCIETA A ")>0
replace asstype = "firm" if index(standard_name," SOCIETA A RESPONSABILITA LIMITATA ")>0
replace asstype = "firm" if index(standard_name," SOCIETA ANONIMA ")>0
replace asstype = "firm" if index(standard_name," SOCIETA CONSORTILE ")>0
replace asstype = "firm" if index(standard_name," SOCIETA CONSORTILE A RESPONSABILITA ")>0
replace asstype = "firm" if index(standard_name," SOCIETA CONSORTILE ARL ")>0
replace asstype = "firm" if index(standard_name," SOCIETA CONSORTILE PER AZION ")>0
replace asstype = "firm" if index(standard_name," SOCIETA CONSORTILE PER AZIONI ")>0
replace asstype = "firm" if index(standard_name," SOCIETA COOPERATIVA ")>0
replace asstype = "firm" if index(standard_name," SOCIETA COOPERATIVA A ")>0
replace asstype = "firm" if index(standard_name," SOCIETA IN ACCOMANDITA ")>0
replace asstype = "firm" if index(standard_name," SOCIETA IN ACCOMANDITA SEMPLICE ")>0
replace asstype = "firm" if index(standard_name," SOCIETA IN NOME COLLETTIVO ")>0
replace asstype = "firm" if index(standard_name," SOCIETA INDUSTRIA ")>0
replace asstype = "firm" if index(standard_name," SOCIETA PER AXIONI ")>0
replace asstype = "firm" if index(standard_name," SOCIETA PER AZINOI ")>0
replace asstype = "firm" if index(standard_name," SOCIETA PER AZINONI ")>0
replace asstype = "firm" if index(standard_name," SOCIETA PER AZIONI ")>0
replace asstype = "firm" if index(standard_name," SOCIETA PER AZIONI: ")>0
replace asstype = "firm" if index(standard_name," SOCIETA PER L INDUSTRIA ")>0
replace asstype = "firm" if index(standard_name," SOCIETA PERAZIONI ")>0
replace asstype = "firm" if index(standard_name," SOCIETAPERAZIONI ")>0
replace asstype = "firm" if index(standard_name," SOCIETE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE A ")>0
replace asstype = "firm" if index(standard_name," SOCIETE A RESPONSABILITE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE A RESPONSABILITE DITE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE A RESPONSABILITEE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE ANANYME ")>0
replace asstype = "firm" if index(standard_name," SOCIETE ANNOYME ")>0
replace asstype = "firm" if index(standard_name," SOCIETE ANOMYME ")>0
replace asstype = "firm" if index(standard_name," SOCIETE ANOMYNE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE ANONVME ")>0
replace asstype = "firm" if index(standard_name," SOCIETE ANONYM ")>0
replace asstype = "firm" if index(standard_name," SOCIETE ANONYME ")>0
replace asstype = "firm" if index(standard_name," SOCIETE ANOYME ")>0
replace asstype = "firm" if index(standard_name," SOCIETE CHIMIQUE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE CIVILE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE COOPERATIVE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE D APPLICATIONS GENERALES ")>0
replace asstype = "firm" if index(standard_name," SOCIETE D APPLICATIONS MECANIQUES ")>0
replace asstype = "firm" if index(standard_name," SOCIETE D EQUIPEMENT ")>0
replace asstype = "firm" if index(standard_name," SOCIETE D ETUDE ET DE CONSTRUCTION ")>0
replace asstype = "firm" if index(standard_name," SOCIETE D ETUDE ET DE RECHERCHE EN VENTILATION ")>0
replace asstype = "firm" if index(standard_name," SOCIETE D ETUDES ET ")>0
replace asstype = "firm" if index(standard_name," SOCIETE D ETUDES TECHNIQUES ET D ENTREPRISES ")>0
replace asstype = "firm" if index(standard_name," SOCIETE DE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE DE CONSEILS DE RECHERCHES ET D APPLICATIONS ")>0
replace asstype = "firm" if index(standard_name," SOCIETE DE CONSTRUCTIO ")>0
replace asstype = "firm" if index(standard_name," SOCIETE DE FABRICAITON ")>0
replace asstype = "firm" if index(standard_name," SOCIETE DE FABRICATION ")>0
replace asstype = "firm" if index(standard_name," SOCIETE DE PRODUCTION ET DE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE DES TRANSPORTS ")>0
replace asstype = "firm" if index(standard_name," SOCIETE DITE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE DITE : ")>0
replace asstype = "firm" if index(standard_name," SOCIETE DITE: ")>0
replace asstype = "firm" if index(standard_name," SOCIETE EN ")>0
replace asstype = "firm" if index(standard_name," SOCIETE EN COMMANDITE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE EN COMMANDITE ENREGISTREE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE EN NOM COLLECTIF ")>0
replace asstype = "firm" if index(standard_name," SOCIETE ETUDES ET ")>0
replace asstype = "firm" if index(standard_name," SOCIETE ETUDES ET DEVELOPPEMENTS ")>0
replace asstype = "firm" if index(standard_name," SOCIETE GENERALE POUR LES ")>0
replace asstype = "firm" if index(standard_name," SOCIETE GENERALE POUR LES TECHNIQUES NOVELLES ")>0
replace asstype = "firm" if index(standard_name," SOCIETE METALLURGIQUE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE NOUVELLE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE PAR ACTIONS ")>0
replace asstype = "firm" if index(standard_name," SOCIETE PAR ACTIONS SIMPLIFEE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE PAR ACTIONS SIMPLIFIEE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE TECHNIQUE D APPLICATION ET DE RECHERCHE ")>0
replace asstype = "firm" if index(standard_name," SOCIETE TECHNIQUE DE PULVERISATION ")>0
replace asstype = "firm" if index(standard_name," SOCIETEANONYME ")>0
replace asstype = "firm" if index(standard_name," SOCIETEDITE ")>0
replace asstype = "firm" if index(standard_name," SOCIETEINDUSTRIELLE ")>0
replace asstype = "firm" if index(standard_name," SOCRL ")>0
replace asstype = "firm" if index(standard_name," SOEHNE ")>0
replace asstype = "firm" if index(standard_name," SOGRANICHENNOI OTVETSTVENNOSTJU ")>0
replace asstype = "firm" if index(standard_name," SOHN ")>0
replace asstype = "firm" if index(standard_name," SOHNE ")>0
replace asstype = "firm" if index(standard_name," SONNER ")>0
replace asstype = "firm" if index(standard_name," SP ")>0
replace asstype = "firm" if index(standard_name," SP A ")>0
replace asstype = "firm" if index(standard_name," SP Z OO ")>0
replace asstype = "firm" if index(standard_name," SP ZOO ")>0
replace asstype = "firm" if index(standard_name," SPA ")>0
replace asstype = "firm" if index(standard_name," SPOKAZOO ")>0
replace asstype = "firm" if index(standard_name," SPOL ")>0
replace asstype = "firm" if index(standard_name," SPOL S R O ")>0
replace asstype = "firm" if index(standard_name," SPOL S RO ")>0
replace asstype = "firm" if index(standard_name," SPOL SRO ")>0
replace asstype = "firm" if index(standard_name," SPOLECNOST SRO ")>0
replace asstype = "firm" if index(standard_name," SPOLKA Z OO ")>0
replace asstype = "firm" if index(standard_name," SPOLKA ZOO ")>0
replace asstype = "firm" if index(standard_name," SPOLS RO ")>0
replace asstype = "firm" if index(standard_name," SPOLSRO ")>0
replace asstype = "firm" if index(standard_name," SPRL ")>0
replace asstype = "firm" if index(standard_name," SPZ OO ")>0
replace asstype = "firm" if index(standard_name," SPZOO ")>0
replace asstype = "firm" if index(standard_name," SR ")>0
replace asstype = "firm" if index(standard_name," SR L ")>0
replace asstype = "firm" if index(standard_name," SR1 ")>0
replace asstype = "firm" if index(standard_name," SRI ")>0
replace asstype = "firm" if index(standard_name," SRL ")>0
replace asstype = "firm" if index(standard_name," SRO ")>0
replace asstype = "firm" if index(standard_name," SßRL ")>0
replace asstype = "firm" if index(standard_name," SURL ")>0
replace asstype = "firm" if index(standard_name," TEAM ")>0
replace asstype = "firm" if index(standard_name," TECHNIQUES NOUVELLE ")>0
replace asstype = "firm" if index(standard_name," TECHNOLOGIES ")>0
replace asstype = "firm" if index(standard_name," THE FIRM ")>0
replace asstype = "firm" if index(standard_name," TOHO BUSINESS ")>0
replace asstype = "firm" if index(standard_name," TOVARISCHESIVO S OGRANICHENNOI OIVETSIVENNOSTIJU ")>0
replace asstype = "firm" if index(standard_name," TOVARISCHESTVO ")>0
replace asstype = "firm" if index(standard_name," TOVARISCHESTVO S OGRANICHENNOI ")>0
replace asstype = "firm" if index(standard_name," TOVARISCHESTVO S OGRANICHENNOI OTVETSTVENNOSTJU ")>0
replace asstype = "firm" if index(standard_name," TOVARISCHESTVO S OGRANICHENNOI OTVETSVENNOSTJU ")>0
replace asstype = "firm" if index(standard_name," TOVARISCHESTVO S ORGANICHENNOI OTVETSTVENNOSTJU ")>0
replace asstype = "firm" if index(standard_name," TOVARISCHETSTVO S ORGANICHENNOI ")>0
replace asstype = "firm" if index(standard_name," TRADING ")>0
replace asstype = "firm" if index(standard_name," TRADING AS ")>0
replace asstype = "firm" if index(standard_name," TRADING UNDER ")>0
replace asstype = "firm" if index(standard_name," UGINE ")>0
replace asstype = "firm" if index(standard_name," UNTERNEHMEN ")>0
replace asstype = "firm" if index(standard_name," USA ")>0
replace asstype = "firm" if index(standard_name," USINES ")>0
replace asstype = "firm" if index(standard_name," VAKMANSCHAP ")>0
replace asstype = "firm" if index(standard_name," VENNOOTSCHAP ")>0
replace asstype = "firm" if index(standard_name," VENNOOTSCHAP ONDER FIRMA: ")>0
replace asstype = "firm" if index(standard_name," VENNOOTSHAP ")>0
replace asstype = "firm" if index(standard_name," VENNOTSCHAP ")>0
replace asstype = "firm" if index(standard_name," VENOOTSCHAP ")>0
replace asstype = "firm" if index(standard_name," VENTURE ")>0
replace asstype = "firm" if index(standard_name," VERARBEITUNG ")>0
replace asstype = "firm" if index(standard_name," VERKOOP ")>0
replace asstype = "firm" if index(standard_name," VERSICHERUNGSBUERO ")>0
replace asstype = "firm" if index(standard_name," VERTRIEBSGESELLSCHAFT ")>0
replace asstype = "firm" if index(standard_name," VOF ")>0
replace asstype = "firm" if index(standard_name," WERK ")>0
replace asstype = "firm" if index(standard_name," WERKE ")>0
replace asstype = "firm" if index(standard_name," WERKEN ")>0
replace asstype = "firm" if index(standard_name," WERKHUIZEN ")>0
replace asstype = "firm" if index(standard_name," WERKS ")>0
replace asstype = "firm" if index(standard_name," WERKSTAETTE ")>0
replace asstype = "firm" if index(standard_name," WERKSTATT ")>0
replace asstype = "firm" if index(standard_name," WERKZEUGBAU ")>0
replace asstype = "firm" if index(standard_name," WINKEL ")>0
replace asstype = "firm" if index(standard_name," WORKS ")>0
replace asstype = "firm" if index(standard_name," YUGEN KAISHA ")>0
replace asstype = "firm" if index(standard_name," YUGENKAISHA ")>0
replace asstype = "firm" if index(standard_name," YUUGEN KAISHA ")>0
replace asstype = "firm" if index(standard_name," YUUGENKAISHA ")>0
replace asstype = "firm" if index(standard_name," ZOO ")>0


********************standardize names*********************************************************************************************************************************
*use derwent_standardisation_BHH.do file
replace standard_name=upper(standard_name)

replace standard_name = subinstr( standard_name," A B "," AB ",1)
replace standard_name = subinstr( standard_name," A CALIFORNIA CORP "," CORP ",1)
replace standard_name = subinstr( standard_name," A DELAWARE CORP "," CORP ",1)
replace standard_name = subinstr( standard_name," AKTIEBOLAGET "," AB ",1)
replace standard_name = subinstr( standard_name," AKTIEBOLAG "," AB ",1)
replace standard_name = subinstr( standard_name," ACADEMY "," ACAD ",1)
replace standard_name = subinstr( standard_name," ACTIEN GESELLSCHAFT "," AG ",1)
replace standard_name = subinstr( standard_name," ACTIENGESELLSCHAFT "," AG ",1)
replace standard_name = subinstr( standard_name," AKTIEN GESELLSCHAFT "," AG ",1)
replace standard_name = subinstr( standard_name," AKTIENGESELLSCHAFT "," AG ",1)
replace standard_name = subinstr( standard_name," AGRICOLAS "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICOLA "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICOLES "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICOLE "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICOLI "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICOLTURE "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICULTURA "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICULTURAL "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AGRICULTURE "," AGRIC ",1)
replace standard_name = subinstr( standard_name," AKADEMIA "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIEI "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIE "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMII "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIJA "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIYA "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIYAKH "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIYAM "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIYAMI "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMIYU "," AKAD ",1)
replace standard_name = subinstr( standard_name," AKADEMI "," AKAD ",1)
replace standard_name = subinstr( standard_name," ALLGEMEINER "," ALLG ",1)
replace standard_name = subinstr( standard_name," ALLGEMEINE "," ALLG ",1)
replace standard_name = subinstr( standard_name," ANTREPRIZA "," ANTR ",1)
replace standard_name = subinstr( standard_name," APARARII "," APAR ",1)
replace standard_name = subinstr( standard_name," APARATELOR "," APAR ",1)
replace standard_name = subinstr( standard_name," APPARATEBAU "," APP ",1)
replace standard_name = subinstr( standard_name," APPARATUS "," APP ",1)
replace standard_name = subinstr( standard_name," APPARECHHI "," APP ",1)
replace standard_name = subinstr( standard_name," APPAREILLAGES "," APP ",1)
replace standard_name = subinstr( standard_name," APPAREILLAGE "," APP ",1)
replace standard_name = subinstr( standard_name," APPAREILS "," APP ",1)
replace standard_name = subinstr( standard_name," APPAREIL "," APP ",1)
replace standard_name = subinstr( standard_name," APARATE "," APAR ",1)
replace standard_name = subinstr( standard_name," APPARATE "," APP ",1)
replace standard_name = subinstr( standard_name," APPLICATIONS "," APPL ",1)
replace standard_name = subinstr( standard_name," APPLICATION "," APPL ",1)
replace standard_name = subinstr( standard_name," APPLICAZIONE "," APPL ",1)
replace standard_name = subinstr( standard_name," APPLICAZIONI "," APPL ",1)
replace standard_name = subinstr( standard_name," ANPARTSSELSKABET "," APS ",1)
replace standard_name = subinstr( standard_name," ANPARTSSELSKAB "," APS ",1)
replace standard_name = subinstr( standard_name," A/S "," AS ",1)
replace standard_name = subinstr( standard_name," AKTIESELSKABET "," AS ",1)
replace standard_name = subinstr( standard_name," AKTIESELSKAB "," AS ",1)
replace standard_name = subinstr( standard_name," ASSOCIACAO "," ASSOC ",1)
replace standard_name = subinstr( standard_name," ASSOCIATED "," ASSOC ",1)
replace standard_name = subinstr( standard_name," ASSOCIATES "," ASSOCIATES ",1)
replace standard_name = subinstr( standard_name," ASSOCIATE "," ASSOCIATES ",1)
replace standard_name = subinstr( standard_name," ASSOCIATION "," ASSOC ",1)
replace standard_name = subinstr( standard_name," BETEILIGUNGSGESELLSCHAFT MBH "," BET GMBH ",1)
replace standard_name = subinstr( standard_name," BETEILIGUNGS GESELLSCHAFT MIT "," BET GMBH ",1)
replace standard_name = subinstr( standard_name," BETEILIGUNGSGESELLSCHAFT "," BET GES ",1)
replace standard_name = subinstr( standard_name," BESCHRANKTER HAFTUNG "," BET GMBH ",1)
replace standard_name = subinstr( standard_name," BROEDERNA "," BRDR ",1)
replace standard_name = subinstr( standard_name," BROEDRENE "," BRDR ",1)
replace standard_name = subinstr( standard_name," BRODERNA "," BRDR ",1)
replace standard_name = subinstr( standard_name," BRODRENE "," BRDR ",1)
replace standard_name = subinstr( standard_name," BROTHERS "," BROS ",1)
replace standard_name = subinstr( standard_name," BESLOTEN VENNOOTSCHAP MET "," BV ",1)
replace standard_name = subinstr( standard_name," BESLOTEN VENNOOTSCHAP "," BV ",1)
replace standard_name = subinstr( standard_name," BEPERKTE AANSPRAKELIJKHEID "," BV ",1)
replace standard_name = subinstr( standard_name," CLOSE CORPORATION "," CC ",1)
replace standard_name = subinstr( standard_name," CENTER "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRAAL "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRALA "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRALES "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRALE "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRAL "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRAUX "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRE "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRO "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRUL "," CENT ",1)
replace standard_name = subinstr( standard_name," CENTRUM "," CENT ",1)
replace standard_name = subinstr( standard_name," CERCETARE "," CERC ",1)
replace standard_name = subinstr( standard_name," CERCETARI "," CERC ",1)
replace standard_name = subinstr( standard_name," CHEMICALS "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMICAL "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMICKEJ "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMICKE "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMICKYCH "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMICKY "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMICZNE "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMICZNY "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMIE "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMII "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMISCHE "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMISCH "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMISKEJ "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHEMISTRY "," CHEM ",1)
replace standard_name = subinstr( standard_name," CHIMICA "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMICE "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMICI "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMICO "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIC "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIEI "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIE "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIESKOJ "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMII "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIKO "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIQUES "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIQUE "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIYAKH "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIYAMI "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIYAM "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIYA "," CHIM ",1)
replace standard_name = subinstr( standard_name," CHIMIYU "," CHIM ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE FRANCAISE "," CIE FR ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE GENERALE "," CIE GEN ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE INDUSTRIALE "," CIE IND ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE INDUSTRIELLE "," CIE IND ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE INDUSTRIELLES "," CIE IND ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE INTERNATIONALE "," CIE INT ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE NATIONALE "," CIE NAT ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE PARISIENNE "," CIE PARIS ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE PARISIENN "," CIE PARIS ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE PARISIEN "," CIE PARIS ",1)
replace standard_name = subinstr( standard_name," COMPANIES "," CO ",1)
replace standard_name = subinstr( standard_name," COMPAGNIA "," CIA ",1)
replace standard_name = subinstr( standard_name," COMPANHIA "," CIA ",1)
replace standard_name = subinstr( standard_name," COMPAGNIE "," CIE ",1)
replace standard_name = subinstr( standard_name," COMPANY "," CO ",1)
replace standard_name = subinstr( standard_name," COMBINATUL "," COMB ",1)
replace standard_name = subinstr( standard_name," COMMERCIALE "," COMML ",1)
replace standard_name = subinstr( standard_name," COMMERCIAL "," COMML ",1)
replace standard_name = subinstr( standard_name," CONSOLIDATED "," CONSOL ",1)
replace standard_name = subinstr( standard_name," CONSTRUCCIONES "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCCIONE "," CONSTR ",1) 
replace standard_name = subinstr( standard_name," CONSTRUCCION "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTIE "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTII "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTIILOR "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTIONS "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTION "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTORTUL "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTORUL "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CONSTRUCTOR "," CONSTR ",1)
replace standard_name = subinstr( standard_name," CO OPERATIVES "," COOP ",1)
replace standard_name = subinstr( standard_name," CO OPERATIVE "," COOP ",1)
replace standard_name = subinstr( standard_name," COOPERATIEVE "," COOP ",1)
replace standard_name = subinstr( standard_name," COOPERATIVA "," COOP ",1)
replace standard_name = subinstr( standard_name," COOPERATIVES "," COOP ",1)
replace standard_name = subinstr( standard_name," COOPERATIVE "," COOP ",1)
replace standard_name = subinstr( standard_name," INCORPORATED "," INC ",1)
replace standard_name = subinstr( standard_name," INCORPORATION "," INC ",1)
replace standard_name = subinstr( standard_name," CORPORATE "," CORP ",1)
replace standard_name = subinstr( standard_name," CORPORATION OF AMERICA "," CORP ",1)
replace standard_name = subinstr( standard_name," CORPORATION "," CORP ",1)
replace standard_name = subinstr( standard_name," CORPORASTION "," CORP ",1)
replace standard_name = subinstr( standard_name," CORPORATIOON "," CORP ",1)
replace standard_name = subinstr( standard_name," COSTRUZIONI "," COSTR ",1)
replace standard_name = subinstr( standard_name," DEUTSCHEN "," DDR ",1)
replace standard_name = subinstr( standard_name," DEUTSCHE "," DDR ",1)
replace standard_name = subinstr( standard_name," DEMOKRATISCHEN REPUBLIK "," DDR ",1)
replace standard_name = subinstr( standard_name," DEMOKRATISCHE REPUBLIK "," DDR ",1)
replace standard_name = subinstr( standard_name," DEPARTEMENT "," DEPT ",1)
replace standard_name = subinstr( standard_name," DEPARTMENT "," DEPT ",1)
replace standard_name = subinstr( standard_name," DEUTSCHES "," DEUT ",1)
replace standard_name = subinstr( standard_name," DEUTSCHEN "," DEUT ",1)
replace standard_name = subinstr( standard_name," DEUTSCHER "," DEUT ",1)
replace standard_name = subinstr( standard_name," DEUTSCHLAND "," DEUT ",1)
replace standard_name = subinstr( standard_name," DEUTSCHE "," DEUT ",1)
replace standard_name = subinstr( standard_name," DEUTSCH "," DEUT ",1)
replace standard_name = subinstr( standard_name," DEVELOPMENTS "," DEV ",1)
replace standard_name = subinstr( standard_name," DEVELOPMENT "," DEV ",1)
replace standard_name = subinstr( standard_name," DEVELOPPEMENTS "," DEV ",1)
replace standard_name = subinstr( standard_name," DEVELOPPEMENT "," DEV ",1)
replace standard_name = subinstr( standard_name," DEVELOP "," DEV ",1)
replace standard_name = subinstr( standard_name," DIVISIONE "," DIV ",1)
replace standard_name = subinstr( standard_name," DIVISION "," DIV ",1)
replace standard_name = subinstr( standard_name," ENGINEERING "," ENG ",1)
replace standard_name = subinstr( standard_name," EQUIPEMENTS "," EQUIP ",1)
replace standard_name = subinstr( standard_name," EQUIPEMENT "," EQUIP ",1)
replace standard_name = subinstr( standard_name," EQUIPMENTS "," EQUIP ",1)
replace standard_name = subinstr( standard_name," EQUIPMENT "," EQUIP ",1)
replace standard_name = subinstr( standard_name," ESTABLISHMENTS "," ESTAB ",1)
replace standard_name = subinstr( standard_name," ESTABLISHMENT "," ESTAB ",1)
replace standard_name = subinstr( standard_name," ESTABLISSEMENTS "," ESTAB ",1)
replace standard_name = subinstr( standard_name," ESTABLISSEMENT "," ESTAB ",1)
replace standard_name = subinstr( standard_name," ETABLISSEMENTS "," ETAB ",1)
replace standard_name = subinstr( standard_name," ETABLISSEMENT "," ETAB ",1)
replace standard_name = subinstr( standard_name," ETABS "," ETAB ",1)
replace standard_name = subinstr( standard_name," ETS "," ETAB ",1)
replace standard_name = subinstr( standard_name," ETUDES "," ETUD ",1)
replace standard_name = subinstr( standard_name," ETUDE "," ETUD ",1)
replace standard_name = subinstr( standard_name," EUROPAEISCHEN "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPAEISCHES "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPAEISCHE "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPAISCHEN "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPAISCHES "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPAISCHE "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPEAN "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPEENNE "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPEEN "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPEA "," EURO ",1)
replace standard_name = subinstr( standard_name," EUROPE "," EURO ",1)
replace standard_name = subinstr( standard_name," EINGETRAGENER VEREIN "," EV ",1)
replace standard_name = subinstr( standard_name," EXPLOATERINGS "," EXPL ",1)
replace standard_name = subinstr( standard_name," EXPLOATERING "," EXPL ",1)
replace standard_name = subinstr( standard_name," EXPLOITATIE "," EXPL ",1)
replace standard_name = subinstr( standard_name," EXPLOITATIONS "," EXPL ",1)
replace standard_name = subinstr( standard_name," EXPLOITATION "," EXPL ",1)
replace standard_name = subinstr( standard_name," FIRMA "," FA ",1)
replace standard_name = subinstr( standard_name," FABBRICAZIONI "," FAB ",1)
replace standard_name = subinstr( standard_name," FABBRICHE "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRICATIONS "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRICATION "," FAB ",1)
replace standard_name = subinstr( standard_name," FABBRICA "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRICA "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRIEKEN "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRIEK "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRIKER "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRIK "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRIQUES "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRIQUE "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRIZIO "," FAB ",1)
replace standard_name = subinstr( standard_name," FABRYKA "," FAB ",1)
replace standard_name = subinstr( standard_name," FARMACEUTICA "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACEUTICE "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACEUTICHE "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACEUTICI "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACEUTICOS "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACEUTICO "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACEUTISK "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACEVTSKIH "," FARM ",1)
replace standard_name = subinstr( standard_name," FARMACIE "," FARM ",1)
replace standard_name = subinstr( standard_name," FONDATION "," FOND ",1)
replace standard_name = subinstr( standard_name," FONDAZIONE "," FOND ",1)
replace standard_name = subinstr( standard_name," FOUNDATIONS "," FOUND ",1)
replace standard_name = subinstr( standard_name," FOUNDATION "," FOUND ",1)
replace standard_name = subinstr( standard_name," FRANCAISE "," FR ",1)
replace standard_name = subinstr( standard_name," FRANCAIS "," FR ",1)
replace standard_name = subinstr( standard_name," F LLI "," FRAT ",1)
replace standard_name = subinstr( standard_name," FLLI "," FRAT ",1)
replace standard_name = subinstr( standard_name," FRATELLI "," FRAT ",1)
replace standard_name = subinstr( standard_name," GEBRODERS "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEBRODER "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEBROEDERS "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEBROEDER "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEBRUDERS "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEBRUDER "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEBRUEDERS "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEBRUEDER "," GEBR ",1)
replace standard_name = subinstr( standard_name," GEB "," GEBR ",1)
replace standard_name = subinstr( standard_name," GENERALA "," GEN ",1)
replace standard_name = subinstr( standard_name," GENERALES "," GEN ",1)
replace standard_name = subinstr( standard_name," GENERALE "," GEN ",1)
replace standard_name = subinstr( standard_name," GENERAL "," GEN ",1)
replace standard_name = subinstr( standard_name," GENERAUX "," GEN ",1)
replace standard_name = subinstr( standard_name," GESELLSCHAFT "," GES ",1)
replace standard_name = subinstr( standard_name," GEWERKSCHAFT "," GEW ",1)
replace standard_name = subinstr( standard_name," GAKKO HOJIN "," GH ",1)
replace standard_name = subinstr( standard_name," GAKKO HOUJIN "," GH ",1)
replace standard_name = subinstr( standard_name," GUTEHOFFNUNGSCHUETTE "," GHH ",1)
replace standard_name = subinstr( standard_name," GUTEHOFFNUNGSCHUTTE "," GHH ",1)
replace standard_name = subinstr( standard_name," GOMEI GAISHA "," GK ",1)
replace standard_name = subinstr( standard_name," GOMEI KAISHA "," GK ",1)
replace standard_name = subinstr( standard_name," GOSHI KAISHA "," GK ",1)
replace standard_name = subinstr( standard_name," GOUSHI GAISHA "," GK ",1)
replace standard_name = subinstr( standard_name," GESELLSCHAFT MBH "," GMBH ",1)
replace standard_name = subinstr( standard_name," GESELLSCHAFT MIT BESCHRANKTER HAFTUNG "," GMBH ",1)
replace standard_name = subinstr( standard_name," GROUPEMENT "," GRP ",1)
replace standard_name = subinstr( standard_name," GROUPMENT "," GRP ",1)
replace standard_name = subinstr( standard_name," HANDELSMAATSCHAPPIJ "," HANDL ",1)
replace standard_name = subinstr( standard_name," HANDELSMIJ "," HANDL ",1)
replace standard_name = subinstr( standard_name," HANDELS BOLAGET "," HB ",1)
replace standard_name = subinstr( standard_name," HANDELSBOLAGET "," HB ",1)
replace standard_name = subinstr( standard_name," HER MAJESTY THE QUEEN IN RIGHT OF CANADA AS REPRESENTED BY THE MINISTER OF "," CANADA MIN OF ",1)
replace standard_name = subinstr( standard_name," HER MAJESTY THE QUEEN "," UK ",1)
replace standard_name = subinstr( standard_name," INDUSTRIAS "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIALS "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIAL "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIALA "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIALE "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIALIZARE "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIALIZAREA "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIALI "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIEELE "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIEI "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIELS "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIELLES "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIELLE "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIELL "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIEL "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIER "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIES "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRII "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIJ "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIYAKH "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIYAM "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIYAMI "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIYA "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIYU "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIA "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRIE "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRI "," IND ",1)
replace standard_name = subinstr( standard_name," INDUSTRY "," IND ",1)
replace standard_name = subinstr( standard_name," INGENIERIA "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIER "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURS "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURBUERO "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURBUREAU "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURBURO "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURGESELLSCHAFT "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURSBUREAU "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURTECHNISCHES "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEURTECHNISCHE "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIEUR "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIOERFIRMAET "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIORSFIRMAN "," ING ",1)
replace standard_name = subinstr( standard_name," INGENIORSFIRMA "," ING ",1)
replace standard_name = subinstr( standard_name," INGENJORSFIRMA "," ING ",1)
replace standard_name = subinstr( standard_name," INGINERIE "," ING ",1)
replace standard_name = subinstr( standard_name," INSTITUTE FRANCAISE "," INST FR ",1)
replace standard_name = subinstr( standard_name," INSTITUT FRANCAIS "," INST FR ",1)
replace standard_name = subinstr( standard_name," INSTITUTE NATIONALE "," INST NAT ",1)
replace standard_name = subinstr( standard_name," INSTITUT NATIONAL "," INST NAT ",1)
replace standard_name = subinstr( standard_name," INSTITUTAMI "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTAMKH "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTAM "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTA "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTES "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTET "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTE "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTOM "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTOV "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTO "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTT "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTUL "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTU "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUTY "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUT "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITUUT "," INST ",1)
replace standard_name = subinstr( standard_name," INSTITZHT "," INST ",1)
replace standard_name = subinstr( standard_name," INSTYTUT "," INST ",1)
replace standard_name = subinstr( standard_name," INSINOORITOMISTO "," INSTMSTO ",1)
replace standard_name = subinstr( standard_name," INSTRUMENTS "," INSTR ",1)
replace standard_name = subinstr( standard_name," INSTRUMENTATION "," INSTR ",1)
replace standard_name = subinstr( standard_name," INSTRUMENTE "," INSTR ",1)
replace standard_name = subinstr( standard_name," INSTRUMENT "," INSTR ",1)
replace standard_name = subinstr( standard_name," INTERNATL "," INT ",1)
replace standard_name = subinstr( standard_name," INTERNACIONAL "," INT ",1)
replace standard_name = subinstr( standard_name," INTERNATIONAL "," INT ",1)
replace standard_name = subinstr( standard_name," INTERNATIONALEN "," INT ",1)
replace standard_name = subinstr( standard_name," INTERNATIONALE "," INT ",1)
replace standard_name = subinstr( standard_name," INTERNATIONAUX "," INT ",1)
replace standard_name = subinstr( standard_name," INTERNATIONELLA "," INT ",1)
replace standard_name = subinstr( standard_name," INTERNAZIONALE "," INT ",1)
replace standard_name = subinstr( standard_name," INTL "," INT ",1)
replace standard_name = subinstr( standard_name," INTREPRINDEREA "," INTR ",1)
replace standard_name = subinstr( standard_name," ISTITUTO "," IST ",1)
replace standard_name = subinstr( standard_name," ITALIANA "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALIANE "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALIANI "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALIANO "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALIENNE "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALIEN "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALIAN "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALIA "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALI "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALO "," ITAL ",1)
replace standard_name = subinstr( standard_name," ITALY "," ITAL ",1)
replace standard_name = subinstr( standard_name," JUNIOR "," JR ",1)
replace standard_name = subinstr( standard_name," KOMMANDIT BOLAG "," KB ",1)
replace standard_name = subinstr( standard_name," KOMMANDIT BOLAGET "," KB ",1)
replace standard_name = subinstr( standard_name," KOMMANDITBOLAGET "," KB ",1)
replace standard_name = subinstr( standard_name," KOMMANDITBOLAG "," KB ",1)
replace standard_name = subinstr( standard_name," KOMMANDIT GESELLSCHAFT "," KG ",1)
replace standard_name = subinstr( standard_name," KOMMANDITGESELLSCHAFT "," KG ",1)
replace standard_name = subinstr( standard_name," KOMMANDIT GESELLSCHAFT AUF AKTIEN "," KGAA ",1)
replace standard_name = subinstr( standard_name," KOMMANDITGESELLSCHAFT AUF AKTIEN "," KGAA ",1)
replace standard_name = subinstr( standard_name," KUTATO INTEZETE "," KI ",1)
replace standard_name = subinstr( standard_name," KUTATO INTEZET "," KI ",1)
replace standard_name = subinstr( standard_name," KUTATOINTEZETE "," KI ",1)
replace standard_name = subinstr( standard_name," KUTATOINTEZET "," KI ",1)
replace standard_name = subinstr( standard_name," KABUSHIKI GAISHA "," KK ",1)
replace standard_name = subinstr( standard_name," KABUSHIKI KAISHA "," KK ",1)
replace standard_name = subinstr( standard_name," KABUSHIKI GAISYA "," KK ",1)
replace standard_name = subinstr( standard_name," KABUSHIKI KAISYA "," KK ",1)
replace standard_name = subinstr( standard_name," KABUSHIKIGAISHA "," KK ",1)
replace standard_name = subinstr( standard_name," KABUSHIKIKAISHA "," KK ",1)
replace standard_name = subinstr( standard_name," KABUSHIKIGAISYA "," KK ",1)
replace standard_name = subinstr( standard_name," KABUSHIKIKAISYA "," KK ",1)
replace standard_name = subinstr( standard_name," KOMBINATU "," KOMB ",1)
replace standard_name = subinstr( standard_name," KOMBINATY "," KOMB ",1)
replace standard_name = subinstr( standard_name," KOMBINAT "," KOMB ",1)
replace standard_name = subinstr( standard_name," KONINKLIJKE "," KONINK ",1)
replace standard_name = subinstr( standard_name," KONCERNOVY PODNIK "," KP ",1)
replace standard_name = subinstr( standard_name," KUNSTSTOFFTECHNIK "," KUNST ",1)
replace standard_name = subinstr( standard_name," KUNSTSTOFF "," KUNST ",1)
replace standard_name = subinstr( standard_name," LABORATOIRES "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATOIRE "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATOIR "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORIEI "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORIES "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORII "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORIJ "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORIOS "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORIO "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORIUM "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORI "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORATORY "," LAB ",1)
replace standard_name = subinstr( standard_name," LABORTORI "," LAB ",1)
replace standard_name = subinstr( standard_name," LAVORAZA "," LAVORAZ ",1)
replace standard_name = subinstr( standard_name," LAVORAZIONE "," LAVORAZ ",1)
replace standard_name = subinstr( standard_name," LAVORAZIONI "," LAVORAZ ",1)
replace standard_name = subinstr( standard_name," LAVORAZIO "," LAVORAZ ",1)
replace standard_name = subinstr( standard_name," LAVORAZI "," LAVORAZ ",1)
replace standard_name = subinstr( standard_name," LIMITED PARTNERSHIP "," LP ",1)
replace standard_name = subinstr( standard_name," LIMITED "," LTD ",1)
replace standard_name = subinstr( standard_name," LTD LTEE "," LTD ",1)
replace standard_name = subinstr( standard_name," MASCHINENVERTRIEB "," MASCH ",1)
replace standard_name = subinstr( standard_name," MASCHINENBAUANSTALT "," MASCHBAU ",1)
replace standard_name = subinstr( standard_name," MASCHINENBAU "," MASCHBAU ",1)
replace standard_name = subinstr( standard_name," MASCHINENFABRIEK "," MASCHFAB ",1)
replace standard_name = subinstr( standard_name," MASCHINENFABRIKEN "," MASCHFAB ",1)
replace standard_name = subinstr( standard_name," MASCHINENFABRIK "," MASCHFAB ",1)
replace standard_name = subinstr( standard_name," MASCHINENFAB "," MASCHFAB ",1)
replace standard_name = subinstr( standard_name," MASCHINEN "," MASCH ",1)
replace standard_name = subinstr( standard_name," MASCHIN "," MASCH ",1)
replace standard_name = subinstr( standard_name," MIT BESCHRANKTER HAFTUNG "," MBH ",1)
replace standard_name = subinstr( standard_name," MANUFACTURINGS "," MFG ",1)
replace standard_name = subinstr( standard_name," MANUFACTURING "," MFG ",1)
replace standard_name = subinstr( standard_name," MANIFATTURAS "," MFR ",1)
replace standard_name = subinstr( standard_name," MANIFATTURA "," MFR ",1)
replace standard_name = subinstr( standard_name," MANIFATTURE "," MFR ",1)
replace standard_name = subinstr( standard_name," MANUFACTURAS "," MFR ",1)
replace standard_name = subinstr( standard_name," MANUFACTURERS "," MFR ",1)
replace standard_name = subinstr( standard_name," MANUFACTURER "," MFR ",1)
replace standard_name = subinstr( standard_name," MANUFACTURES "," MFR ",1)
replace standard_name = subinstr( standard_name," MANUFACTURE "," MFR ",1)
replace standard_name = subinstr( standard_name," MANUFATURA "," MFR ",1)
replace standard_name = subinstr( standard_name," MAATSCHAPPIJ "," MIJ ",1)
replace standard_name = subinstr( standard_name," MEDICAL "," MED ",1)
replace standard_name = subinstr( standard_name," MINISTERE "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERIUM "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERO "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVAKH "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVAM "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVAMI "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVA "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVE "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVO "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVOM "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTVU "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTV "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERSTWO "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTERUL "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTRE "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTRY "," MIN ",1)
replace standard_name = subinstr( standard_name," MINISTER "," MIN ",1)
replace standard_name = subinstr( standard_name," MAGYAR TUDOMANYOS AKADEMIA "," MTA ",1)
replace standard_name = subinstr( standard_name," NATIONAAL "," NAT ",1)
replace standard_name = subinstr( standard_name," NATIONAL "," NAT ",1)
replace standard_name = subinstr( standard_name," NATIONALE "," NAT ",1)
replace standard_name = subinstr( standard_name," NATIONAUX "," NAT ",1)
replace standard_name = subinstr( standard_name," NATL "," NAT ",1)
replace standard_name = subinstr( standard_name," NAZIONALE "," NAZ ",1)
replace standard_name = subinstr( standard_name," NAZIONALI "," NAZ ",1)
replace standard_name = subinstr( standard_name," NORDDEUTSCH "," NORDDEUT ",1)
replace standard_name = subinstr( standard_name," NORDDEUTSCHE "," NORDDEUT ",1)
replace standard_name = subinstr( standard_name," NORDDEUTSCHER "," NORDDEUT ",1)
replace standard_name = subinstr( standard_name," NORDDEUTSCHES "," NORDDEUT ",1)
replace standard_name = subinstr( standard_name," NARODNI PODNIK "," NP ",1)
replace standard_name = subinstr( standard_name," NARODNIJ PODNIK "," NP ",1)
replace standard_name = subinstr( standard_name," NARODNY PODNIK "," NP ",1)
replace standard_name = subinstr( standard_name," NAAMLOOSE VENOOTSCHAP "," NV ",1)
replace standard_name = subinstr( standard_name," NAAMLOZE VENNOOTSCHAP "," NV ",1)
replace standard_name = subinstr( standard_name," N V "," NV ",1)
replace standard_name = subinstr( standard_name," OESTERREICHISCHES "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OESTERREICHISCHE "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OESTERREICHISCH "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OESTERREICH "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OSTERREICHISCHES "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OSTERREICHISCHE "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OSTERREICHISCH "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OSTERREICH "," OESTERR ",1)
replace standard_name = subinstr( standard_name," OFFICINE MECCANICA "," OFF MEC ",1)
replace standard_name = subinstr( standard_name," OFFICINE MECCANICHE "," OFF MEC ",1)
replace standard_name = subinstr( standard_name," OFFICINE NATIONALE "," OFF NAT ",1)
replace standard_name = subinstr( standard_name," OFFENE HANDELSGESELLSCHAFT "," OHG ",1)
replace standard_name = subinstr( standard_name," ONTWIKKELINGSBUREAU "," ONTWIK ",1)
replace standard_name = subinstr( standard_name," ONTWIKKELINGS "," ONTWIK ",1)
replace standard_name = subinstr( standard_name," OBOROVY PODNIK "," OP ",1)
replace standard_name = subinstr( standard_name," ORGANISATIE "," ORG ",1)
replace standard_name = subinstr( standard_name," ORGANISATIONS "," ORG ",1)
replace standard_name = subinstr( standard_name," ORGANISATION "," ORG ",1)
replace standard_name = subinstr( standard_name," ORGANIZATIONS "," ORG ",1)
replace standard_name = subinstr( standard_name," ORGANIZATION "," ORG ",1)
replace standard_name = subinstr( standard_name," ORGANIZZAZIONE "," ORG ",1)
replace standard_name = subinstr( standard_name," OSAKEYHTIO "," OY ",1)
replace standard_name = subinstr( standard_name," PHARMACEUTICALS "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMACEUTICAL "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMACEUTICA "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMACEUTIQUES "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMACEUTIQUE "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMAZEUTIKA "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMAZEUTISCHEN "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMAZEUTISCHE "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMAZEUTISCH "," PHARM ",1)
replace standard_name = subinstr( standard_name," PHARMAZIE "," PHARM ",1)
replace standard_name = subinstr( standard_name," PUBLIC LIMITED COMPANY "," PLC ",1)
replace standard_name = subinstr( standard_name," PRELUCRAREA "," PRELUC ",1)
replace standard_name = subinstr( standard_name," PRELUCRARE "," PRELUC ",1)
replace standard_name = subinstr( standard_name," PRODOTTI "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCE "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCTS "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCT "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCTAS "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCTA "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCTIE "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCTOS "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCTO "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUCTORES "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUITS "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUIT "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUKCJI "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUKTER "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUKTE "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUKT "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUSE "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUTOS "," PROD ",1)
replace standard_name = subinstr( standard_name," PRODUIT CHIMIQUES "," PROD CHIM ",1)
replace standard_name = subinstr( standard_name," PRODUIT CHIMIQUE "," PROD CHIM ",1)
replace standard_name = subinstr( standard_name," PRODUCTIONS "," PRODN ",1)
replace standard_name = subinstr( standard_name," PRODUCTION "," PRODN ",1)
replace standard_name = subinstr( standard_name," PRODUKTIONS "," PRODN ",1)
replace standard_name = subinstr( standard_name," PRODUKTION "," PRODN ",1)
replace standard_name = subinstr( standard_name," PRODUZIONI "," PRODN ",1)
replace standard_name = subinstr( standard_name," PROIECTARE "," PROI ",1)
replace standard_name = subinstr( standard_name," PROIECTARI "," PROI ",1)
replace standard_name = subinstr( standard_name," PRZEDSIEBIOSTWO "," PRZEDSIEB ",1)
replace standard_name = subinstr( standard_name," PRZEMYSLU "," PRZEYM ",1)
replace standard_name = subinstr( standard_name," PROPRIETARY "," PTY ",1)
replace standard_name = subinstr( standard_name," PERSONENVENNOOTSCHAP MET "," PVBA ",1)
replace standard_name = subinstr( standard_name," BEPERKTE AANSPRAKELIJKHEID "," PVBA ",1)
replace standard_name = subinstr( standard_name," REALISATIONS "," REAL ",1)
replace standard_name = subinstr( standard_name," REALISATION "," REAL ",1)
replace standard_name = subinstr( standard_name," RECHERCHES "," RECH ",1)
replace standard_name = subinstr( standard_name," RECHERCHE "," RECH ",1)
replace standard_name = subinstr( standard_name," RECHERCHES ET DEVELOPMENTS "," RECH & DEV ",1)
replace standard_name = subinstr( standard_name," RECHERCHE ET DEVELOPMENT "," RECH & DEV ",1)
replace standard_name = subinstr( standard_name," RECHERCHES ET DEVELOPPEMENTS "," RECH & DEV ",1)
replace standard_name = subinstr( standard_name," RECHERCHE ET DEVELOPPEMENT "," RECH & DEV ",1)
replace standard_name = subinstr( standard_name," RESEARCH & DEVELOPMENT "," RES & DEV ",1)
replace standard_name = subinstr( standard_name," RESEARCH AND DEVELOPMENT "," RES & DEV ",1)
replace standard_name = subinstr( standard_name," RESEARCH "," RES ",1)
replace standard_name = subinstr( standard_name," RIJKSUNIVERSITEIT "," RIJKSUNIV ",1)
replace standard_name = subinstr( standard_name," SECRETATY "," SECRETARY ",1)
replace standard_name = subinstr( standard_name," SECRETRY "," SECRETARY ",1)
replace standard_name = subinstr( standard_name," SECREATRY "," SECRETARY ",1)
replace standard_name = subinstr( standard_name," SOCIEDAD ANONIMA "," SA ",1)
replace standard_name = subinstr( standard_name," SOCIETE ANONYME DITE "," SA ",1)
replace standard_name = subinstr( standard_name," SOCIETE ANONYME "," SA ",1)
replace standard_name = subinstr( standard_name," SOCIETE A RESPONSABILITE LIMITEE "," SARL ",1)
replace standard_name = subinstr( standard_name," SOCIETE A RESPONSIBILITE LIMITEE "," SARL ",1)
replace standard_name = subinstr( standard_name," SOCIETA IN ACCOMANDITA SEMPLICE "," SAS ",1)
replace standard_name = subinstr( standard_name," SCHWEIZERISCHES "," SCHWEIZ ",1)
replace standard_name = subinstr( standard_name," SCHWEIZERISCHER "," SCHWEIZ ",1)
replace standard_name = subinstr( standard_name," SCHWEIZERISCHE "," SCHWEIZ ",1)
replace standard_name = subinstr( standard_name," SCHWEIZERISCH "," SCHWEIZ ",1)
replace standard_name = subinstr( standard_name," SCHWEIZER "," SCHWEIZ ",1)
replace standard_name = subinstr( standard_name," SCIENCES "," SCI ",1)
replace standard_name = subinstr( standard_name," SCIENCE "," SCI ",1)
replace standard_name = subinstr( standard_name," SCIENTIFICA "," SCI ",1)
replace standard_name = subinstr( standard_name," SCIENTIFIC "," SCI ",1)
replace standard_name = subinstr( standard_name," SCIENTIFIQUES "," SCI ",1)
replace standard_name = subinstr( standard_name," SCIENTIFIQUE "," SCI ",1)
replace standard_name = subinstr( standard_name," SHADAN HOJIN "," SH ",1)
replace standard_name = subinstr( standard_name," SIDERURGICAS "," SIDER ",1)
replace standard_name = subinstr( standard_name," SIDERURGICA "," SIDER ",1)
replace standard_name = subinstr( standard_name," SIDERURGIC "," SIDER ",1)
replace standard_name = subinstr( standard_name," SIDERURGIE "," SIDER ",1)
replace standard_name = subinstr( standard_name," SIDERURGIQUE "," SIDER ",1)
replace standard_name = subinstr( standard_name," SOCIETA IN NOME COLLECTIVO "," SNC ",1)
replace standard_name = subinstr( standard_name," SOCIETE EN NOM COLLECTIF "," SNC ",1)
replace standard_name = subinstr( standard_name," SOCIETE ALSACIENNE "," SOC ALSAC ",1)
replace standard_name = subinstr( standard_name," SOCIETE APPLICATION "," SOC APPL ",1)
replace standard_name = subinstr( standard_name," SOCIETA APPLICAZIONE "," SOC APPL ",1)
replace standard_name = subinstr( standard_name," SOCIETE AUXILIAIRE "," SOC AUX ",1)
replace standard_name = subinstr( standard_name," SOCIETE CHIMIQUE "," SOC CHIM ",1)
replace standard_name = subinstr( standard_name," SOCIEDAD CIVIL "," SOC CIV ",1)
replace standard_name = subinstr( standard_name," SOCIETE CIVILE "," SOC CIV ",1)
replace standard_name = subinstr( standard_name," SOCIETE COMMERCIALES "," SOC COMML ",1)
replace standard_name = subinstr( standard_name," SOCIETE COMMERCIALE "," SOC COMML ",1)
replace standard_name = subinstr( standard_name," SOCIEDAD ESPANOLA "," SOC ESPAN ",1)
replace standard_name = subinstr( standard_name," SOCIETE ETUDES "," SOC ETUD ",1)
replace standard_name = subinstr( standard_name," SOCIETE ETUDE "," SOC ETUD ",1)
replace standard_name = subinstr( standard_name," SOCIETE EXPLOITATION "," SOC EXPL ",1)
replace standard_name = subinstr( standard_name," SOCIETE GENERALE "," SOC GEN ",1)
replace standard_name = subinstr( standard_name," SOCIETE INDUSTRIELLES "," SOC IND ",1)
replace standard_name = subinstr( standard_name," SOCIETE INDUSTRIELLE "," SOC IND ",1)
replace standard_name = subinstr( standard_name," SOCIETE MECANIQUES "," SOC MEC ",1)
replace standard_name = subinstr( standard_name," SOCIETE MECANIQUE "," SOC MEC ",1)
replace standard_name = subinstr( standard_name," SOCIETE NATIONALE "," SOC NAT ",1)
replace standard_name = subinstr( standard_name," SOCIETE NOUVELLE "," SOC NOUV ",1)
replace standard_name = subinstr( standard_name," SOCIETE PARISIENNE "," SOC PARIS ",1)
replace standard_name = subinstr( standard_name," SOCIETE PARISIENN "," SOC PARIS ",1)
replace standard_name = subinstr( standard_name," SOCIETE PARISIEN "," SOC PARIS ",1)
replace standard_name = subinstr( standard_name," SOCIETE TECHNIQUES "," SOC TECH ",1)
replace standard_name = subinstr( standard_name," SOCIETE TECHNIQUE "," SOC TECH ",1)
replace standard_name = subinstr( standard_name," SDRUZENI PODNIKU "," SP ",1)
replace standard_name = subinstr( standard_name," SDRUZENI PODNIK "," SP ",1)
replace standard_name = subinstr( standard_name," SOCIETA PER AZIONI "," SPA ",1)
replace standard_name = subinstr( standard_name," SPITALUL "," SPITAL ",1)
replace standard_name = subinstr( standard_name," SOCIETE PRIVEE A RESPONSABILITE LIMITEE "," SPRL ",1)
replace standard_name = subinstr( standard_name," SOCIEDAD DE RESPONSABILIDAD LIMITADA "," SRL ",1)
replace standard_name = subinstr( standard_name," STIINTIFICA "," STIINT ",1)
replace standard_name = subinstr( standard_name," SUDDEUTSCHES "," SUDDEUT ",1)
replace standard_name = subinstr( standard_name," SUDDEUTSCHER "," SUDDEUT ",1)
replace standard_name = subinstr( standard_name," SUDDEUTSCHE "," SUDDEUT ",1)
replace standard_name = subinstr( standard_name," SUDDEUTSCH "," SUDDEUT ",1)
replace standard_name = subinstr( standard_name," SOCIEDADE "," SOC ",1)
replace standard_name = subinstr( standard_name," SOCIEDAD "," SOC ",1)
replace standard_name = subinstr( standard_name," SOCIETA "," SOC ",1)
replace standard_name = subinstr( standard_name," SOCIETE "," SOC ",1)
replace standard_name = subinstr( standard_name," SOCIETY "," SOC ",1)
replace standard_name = subinstr( standard_name," SA DITE "," SA ",1)
replace standard_name = subinstr( standard_name," TECHNICAL "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNICO "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNICZNY "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNIKAI "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNIKI "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNIK "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNIQUES "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNIQUE "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNISCHES "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNISCHE "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNISCH "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNOLOGY "," TECH ",1)
replace standard_name = subinstr( standard_name," TECHNOLOGIES "," TECH ",1)
replace standard_name = subinstr( standard_name," TELECOMMUNICATIONS "," TELECOM ",1)
replace standard_name = subinstr( standard_name," TELECOMMUNICACION "," TELECOM ",1)
replace standard_name = subinstr( standard_name," TELECOMMUNICATION "," TELECOM ",1)
replace standard_name = subinstr( standard_name," TELECOMMUNICAZIONI "," TELECOM ",1)
replace standard_name = subinstr( standard_name," TELECOMUNICAZIONI "," TELECOM ",1)
replace standard_name = subinstr( standard_name," TRUSTUL "," TRUST ",1)
replace standard_name = subinstr( standard_name," UNITED KINGDOM "," UK ",1)
replace standard_name = subinstr( standard_name," SECRETARY OF STATE FOR "," UK SEC FOR ",1)
replace standard_name = subinstr( standard_name," UNIVERSIDADE "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSIDAD "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITA DEGLI STUDI "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITAET "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITAIRE "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITAIR "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITATEA "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITEIT "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETAMI "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETAM "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETE "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETOM "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETOV "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETU "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETY "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITETA "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITAT "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITET "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITE "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITY "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIVERSITA "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNIWERSYTET "," UNIV ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA ADMINISTRATOR "," US ADMIN ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA AS REPRESENTED BY THE ADMINISTRATOR "," US ADMIN ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA AS REPRESENTED BY THE DEPT "," US DEPT ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA AS REPRESENTED BY THE UNITED STATES DEPT "," US DEPT ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICAN AS REPRESENTED BY THE UNITED STATES DEPT "," US DEPT ",1)
replace standard_name = subinstr( standard_name," UNITED STATES GOVERNMENT AS REPRESENTED BY THE SECRETARY OF "," US SEC ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA REPRESENTED BY THE SECRETARY "," US SEC ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA AS REPRESENTED BY THE SECRETARY "," US SEC ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICAS AS REPRESENTED BY THE SECRETARY "," US SEC ",1)
replace standard_name = subinstr( standard_name," UNITES STATES OF AMERICA AS REPRESENTED BY THE SECRETARY "," US SEC ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA SECRETARY OF "," US SEC ",1)
replace standard_name = subinstr( standard_name," UNITED STATES OF AMERICA "," USA ",1)
replace standard_name = subinstr( standard_name," UNITED STATES "," USA ",1)
replace standard_name = subinstr( standard_name," UTILAJE "," UTIL ",1)
replace standard_name = subinstr( standard_name," UTILAJ "," UTIL ",1)
replace standard_name = subinstr( standard_name," UTILISATIONS VOLKSEIGENER BETRIEBE "," VEB ",1)
replace standard_name = subinstr( standard_name," UTILISATION VOLKSEIGENER BETRIEBE "," VEB ",1)
replace standard_name = subinstr( standard_name," VEB KOMBINAT "," VEB KOMB ",1)
replace standard_name = subinstr( standard_name," VEREENIGDE "," VER ",1)
replace standard_name = subinstr( standard_name," VEREINIGTES VEREINIGUNG "," VER ",1)
replace standard_name = subinstr( standard_name," VEREINIGTE VEREINIGUNG "," VER ",1)
replace standard_name = subinstr( standard_name," VEREIN "," VER ",1)
replace standard_name = subinstr( standard_name," VERENIGING "," VER ",1)
replace standard_name = subinstr( standard_name," VERWALTUNGEN "," VERW ",1)
replace standard_name = subinstr( standard_name," VERWALTUNGS "," VERW ",1)
replace standard_name = subinstr( standard_name," VERWERTUNGS "," VERW ",1)
replace standard_name = subinstr( standard_name," VERWALTUNGSGESELLSCHAFT "," VERW GES ",1)
replace standard_name = subinstr( standard_name," VYZK USTAV "," VU ",1)
replace standard_name = subinstr( standard_name," VYZKUMNY USTAV "," VU ",1)
replace standard_name = subinstr( standard_name," VYZKUMNYUSTAV "," VU ",1)
replace standard_name = subinstr( standard_name," VEREINIGUNG VOLKSEIGENER BETRIEBUNG "," VVB ",1)
replace standard_name = subinstr( standard_name," VYZK VYVOJOVY USTAV "," VVU ",1)
replace standard_name = subinstr( standard_name," VYZKUMNY VYVOJOVY USTAV "," VVU ",1)
replace standard_name = subinstr( standard_name," WERKZEUGMASCHINENKOMBINAT "," WERKZ MASCH KOMB ",1)
replace standard_name = subinstr( standard_name," WERKZEUGMASCHINENFABRIK "," WERKZ MASCHFAB ",1)
replace standard_name = subinstr( standard_name," WESTDEUTSCHES "," WESTDEUT ",1)
replace standard_name = subinstr( standard_name," WESTDEUTSCHER "," WESTDEUT ",1)
replace standard_name = subinstr( standard_name," WESTDEUTSCHE "," WESTDEUT ",1)
replace standard_name = subinstr( standard_name," WESTDEUTSCH "," WESTDEUT ",1)
replace standard_name = subinstr( standard_name," WISSENSCHAFTLICHE(S) "," WISS ",1)
replace standard_name = subinstr( standard_name," WISSENSCHAFTLICHES TECHNISCHES ZENTRUM "," WTZ ",1)
replace standard_name = subinstr( standard_name," YUGEN KAISHA "," YG YUGEN GAISHA ",1)
replace standard_name = subinstr( standard_name," YUUGEN GAISHA "," YG YUGEN GAISHA ",1)
replace standard_name = subinstr( standard_name," YUUGEN KAISHA "," YG YUGEN GAISHA ",1)
replace standard_name = subinstr( standard_name," YUUGEN KAISYA "," YG YUGEN GAISHA ",1)
replace standard_name = subinstr( standard_name," ZAVODU "," ZAVOD ",1)
replace standard_name = subinstr( standard_name," ZAVODY "," ZAVOD ",1)
replace standard_name = subinstr( standard_name," ZENTRALES "," ZENT ",1)
replace standard_name = subinstr( standard_name," ZENTRALE "," ZENT ",1)
replace standard_name = subinstr( standard_name," ZENTRALEN "," ZENT ",1)
replace standard_name = subinstr( standard_name," ZENTRALNA "," ZENT ",1)
replace standard_name = subinstr( standard_name," ZENTRUM "," ZENT ",1)
replace standard_name = subinstr( standard_name," ZENTRALINSTITUT "," ZENT INST ",1)
replace standard_name = subinstr( standard_name," ZENTRALLABORATORIUM "," ZENT LAB ",1)
replace standard_name = subinstr( standard_name," ZAIDAN HOJIN "," ZH ",1)
replace standard_name = subinstr( standard_name," ZAIDAN HOUJIN "," ZH ",1)
replace standard_name = subinstr( standard_name," LIMITED "," LTD ",1)
replace standard_name = subinstr( standard_name," LIMITADA "," LTDA ",1)
replace standard_name = subinstr( standard_name," SECRETARY "," SEC ",1)

*additonal standardization - see the standard_name.do

** 2) Perform some additional changes
replace standard_name = subinstr( standard_name, " RES & DEV ", " R&D ", 1)
replace standard_name = subinstr( standard_name, " RECH & DEV ", " R&D ", 1)

** 3) Perform some country specific work
** UNITED STATES (most of this is in Derwent)

** UNITED KINGDOM
replace standard_name = subinstr( standard_name, " PUBLIC LIMITED ", " PLC ", 1)
replace standard_name = subinstr( standard_name, " PUBLIC LIABILITY COMPANY ", " PLC ", 1)
replace standard_name = subinstr( standard_name, " HOLDINGS ", " HLDGS ", 1)
replace standard_name = subinstr( standard_name, " HOLDING ", " HLDGS ", 1)
replace standard_name = subinstr( standard_name, " GREAT BRITAIN ", " GB ", 1)
replace standard_name = subinstr( standard_name, " LTD CO ", " CO LTD ", 1)

** SPANISH
replace standard_name = subinstr( standard_name, " SOC LIMITADA ", " SL ", 1)
replace standard_name = subinstr( standard_name, " SOC EN COMMANDITA ", " SC ", 1)
replace standard_name = subinstr( standard_name, " & CIA ", " CO ", 1)

** ITALIAN
replace standard_name = subinstr( standard_name, " SOC IN ACCOMANDITA PER AZIONI ", " SA ", 1)
replace standard_name = subinstr( standard_name, " SAPA ", " SA ", 1)
replace standard_name = subinstr( standard_name, " SOC A RESPONSABILITÀ LIMITATA ", " SRL ", 1)

** SWEDISH
replace standard_name = subinstr( standard_name, " HANDELSBOLAG ", " HB  ", 1)

** GERMAN
replace standard_name = subinstr( standard_name, " KOMANDIT GESELLSCHAFT ", " KG ", 1)
replace standard_name = subinstr( standard_name, " KOMANDITGESELLSCHAFT ", " KG ", 1)
replace standard_name = subinstr( standard_name, " EINGETRAGENE GENOSSENSCHAFT ", " EG ", 1)
replace standard_name = subinstr( standard_name, " GENOSSENSCHAFT ", " EG ", 1)
replace standard_name = subinstr( standard_name, " GESELLSCHAFT M B H ", " GMBH ", 1)
replace standard_name = subinstr( standard_name, " OFFENE HANDELS GESELLSCHAFT ", " OHG ", 1)
replace standard_name = subinstr( standard_name, " GESMBH ", " GMBH ", 1)
replace standard_name = subinstr( standard_name, " GESELLSCHAFT BURGERLICHEN RECHTS ", " GBR ", 1)
replace standard_name = subinstr( standard_name, " GESELLSCHAFT ", " GMBH ", 1)
* The following is common format. If conflict assume GMBH & CO KG over GMBH & CO OHG as more common.
replace standard_name = subinstr( standard_name, " GMBH CO KG ", " GMBH & CO KG ", 1)
replace standard_name = subinstr( standard_name, " GMBH COKG ", " GMBH & CO KG ", 1)
replace standard_name = subinstr( standard_name, " GMBH U CO KG ", " GMBH & CO KG ", 1)
replace standard_name = subinstr( standard_name, " GMBH U COKG ", " GMBH & CO KG ", 1)
replace standard_name = subinstr( standard_name, " GMBH U CO ", " GMBH & CO KG ", 1)
replace standard_name = subinstr( standard_name, " GMBH CO ", " GMBH & CO KG ", 1)
replace standard_name = subinstr( standard_name, " AG CO KG ", " AG & CO KG ", 1)
replace standard_name = subinstr( standard_name, " AG COKG ", " AG & CO KG ", 1)
replace standard_name = subinstr( standard_name, " AG U CO KG ", " AG & CO KG ", 1)
replace standard_name = subinstr( standard_name, " AG U COKG ", " AG & CO KG ", 1)
replace standard_name = subinstr( standard_name, " AG U CO ", " AG & CO KG ", 1)
replace standard_name = subinstr( standard_name, " AG CO ", " AG & CO KG ", 1)
replace standard_name = subinstr( standard_name, " GMBH CO OHG ", " GMBH &CO OHG ", 1)
replace standard_name = subinstr( standard_name, " GMBH COOHG ", " GMBH & CO OHG ", 1)
replace standard_name = subinstr( standard_name, " GMBH U CO OHG ", " GMBH & CO OHG ", 1)
replace standard_name = subinstr( standard_name, " GMBH U COOHG ", " GMBH & CO OHG ", 1)
replace standard_name = subinstr( standard_name, " AG CO OHG ", " AG & CO OHG ", 1)
replace standard_name = subinstr( standard_name, " AG COOHG ", " AG & CO OHG ", 1)
replace standard_name = subinstr( standard_name, " AG U CO OHG ", " AG & CO OHG ", 1)
replace standard_name = subinstr( standard_name, " AG U COOHG ", " AG & CO OHG ", 1)

** FRENCH and BELGIAN
replace standard_name = subinstr( standard_name, " SOCIETE ANONYME SIMPLIFIEE ", " SAS ", 1)
replace standard_name = subinstr( standard_name, " SOC ANONYME ", " SA ", 1)
replace standard_name = subinstr( standard_name, " STE ANONYME ", " SA ", 1)
replace standard_name = subinstr( standard_name, " SARL UNIPERSONNELLE ", " SARLU ", 1)
replace standard_name = subinstr( standard_name, " SOC PAR ACTIONS SIMPLIFIEES ", " SAS ", 1)
replace standard_name = subinstr( standard_name, " SAS UNIPERSONNELLE ", " SASU ", 1)
replace standard_name = subinstr( standard_name, " ENTREPRISE UNIPERSONNELLE A RESPONSABILITE LIMITEE ", " EURL ", 1)
replace standard_name = subinstr( standard_name, " SOCIETE CIVILE IMMOBILIERE ", " SCI ", 1)
replace standard_name = subinstr( standard_name, " GROUPEMENT D INTERET ECONOMIQUE ", " GIE ", 1)
replace standard_name = subinstr( standard_name, " SOCIETE EN PARTICIPATION ", " SP ", 1)
replace standard_name = subinstr( standard_name, " SOCIETE EN COMMANDITE SIMPLE ", " SCS ", 1)
replace standard_name = subinstr( standard_name, " ANONYME DITE ", " SA ", 1)
replace standard_name = subinstr( standard_name, " SOC DITE ", " SA ", 1)
replace standard_name = subinstr( standard_name, " & CIE ", " CO ", 1)

** BELGIAN
** Note: the Belgians use a lot of French endings, so handle as above.
** Also, they use NV (belgian) and SA (french) interchangably, so standardise to SA

replace standard_name = subinstr( standard_name, " BV BEPERKTE AANSPRAKELIJKHEID ", " BVBA ", 1)
replace standard_name = subinstr( standard_name, " COMMANDITAIRE VENNOOTSCHAP OP AANDELEN ", " CVA ", 1)
replace standard_name = subinstr( standard_name, " GEWONE COMMANDITAIRE VENNOOTSCHAP ", " GCV ", 1)
replace standard_name = subinstr( standard_name, " SOCIETE EN COMMANDITE PAR ACTIONS ", " SCA ", 1)


** DENMARK
* Usually danish identifiers have a slash (eg. A/S or K/S), but these will have been removed with all
* other punctuation earlier (so just use AS or KS).
replace standard_name = subinstr( standard_name, " ANDELSSELSKABET ", " AMBA ", 1)
replace standard_name = subinstr( standard_name, " ANDELSSELSKAB ", " AMBA ", 1)
replace standard_name = subinstr( standard_name, " INTERESSENTSKABET ", " IS ", 1)
replace standard_name = subinstr( standard_name, " INTERESSENTSKAB ", " IS ", 1)
replace standard_name = subinstr( standard_name, " KOMMANDITAKTIESELSKABET ", " KAS ", 1)
replace standard_name = subinstr( standard_name, " KOMMANDITAKTIESELSKAB ", " KAS ", 1)
replace standard_name = subinstr( standard_name, " KOMMANDITSELSKABET ", " KS ", 1)
replace standard_name = subinstr( standard_name, " KOMMANDITSELSKAB ", " KS ", 1)

** NORWAY
replace standard_name = subinstr( standard_name, " ANDELSLAGET ", " AL ", 1)
replace standard_name = subinstr( standard_name, " ANDELSLAG ", " AL ", 1)
replace standard_name = subinstr( standard_name, " ANSVARLIG SELSKAPET ", " ANS ", 1)
replace standard_name = subinstr( standard_name, " ANSVARLIG SELSKAP ", " ANS ", 1)
replace standard_name = subinstr( standard_name, " AKSJESELSKAPET ", " AS ", 1)
replace standard_name = subinstr( standard_name, " AKSJESELSKAP ", " AS ", 1)
replace standard_name = subinstr( standard_name, " ALLMENNAKSJESELSKAPET ", " ASA ", 1)
replace standard_name = subinstr( standard_name, " ALLMENNAKSJESELSKAP ", " ASA ", 1)
replace standard_name = subinstr( standard_name, " SELSKAP MED DELT ANSAR ", " DA ", 1)
replace standard_name = subinstr( standard_name, " KOMMANDITTSELSKAPET ", " KS ", 1)
replace standard_name = subinstr( standard_name, " KOMMANDITTSELSKAP ", " KS ", 1)

** NETHERLANDS
replace standard_name = subinstr( standard_name, " COMMANDITAIRE VENNOOTSCHAP ", " CV ", 1)
replace standard_name = subinstr( standard_name, " COMMANDITAIRE VENNOOTSCHAP OP ANDELEN ", " CVOA ", 1)
replace standard_name = subinstr( standard_name, " VENNOOTSCHAP ONDER FIRMA ", " VOF ", 1)

** FINLAND
replace standard_name = subinstr( standard_name, " PUBLIKT AKTIEBOLAG ", " APB ", 1)
replace standard_name = subinstr( standard_name, " KOMMANDIITTIYHTIO ", " KY ", 1)
replace standard_name = subinstr( standard_name, " JULKINEN OSAKEYHTIO ", " OYJ ", 1)

** POLAND
replace standard_name = subinstr( standard_name, " SPOLKA AKCYJNA ", " SA ", 1) 
replace standard_name = subinstr( standard_name, " SPOLKA PRAWA CYWILNEGO ", " SC ", 1)
replace standard_name = subinstr( standard_name, " SPOLKA KOMANDYTOWA ", " SK ", 1)
replace standard_name = subinstr( standard_name, " SPOLKA Z OGRANICZONA ODPOWIEDZIALNOSCIA ", " SPZOO ", 1)
replace standard_name = subinstr( standard_name, " SP Z OO ", " SPZOO ", 1)
replace standard_name = subinstr( standard_name, " SPZ OO ", " SPZOO ", 1)
replace standard_name = subinstr( standard_name, " SP ZOO ", " SPZOO ", 1)

** GREECE
replace standard_name = subinstr( standard_name, " ANONYMOS ETAIRIA ", " AE ", 1)
replace standard_name = subinstr( standard_name, " ETERRORRYTHMOS ", " EE ", 1)
replace standard_name = subinstr( standard_name, " ETAIRIA PERIORISMENIS EVTHINIS ", " EPE ", 1)
replace standard_name = subinstr( standard_name, " OMORRYTHMOS ", " OE ", 1)

** CZECH REPUBLIC
replace standard_name = subinstr( standard_name, " AKCIOVA SPOLECNOST ", " AS ", 1)
replace standard_name = subinstr( standard_name, " KOMANDITNI SPOLECNOST ", " KS ", 1)
replace standard_name = subinstr( standard_name, " SPOLECNOST S RUCENIM OMEZENYM ", " SRO ", 1)
replace standard_name = subinstr( standard_name, " VEREJNA OBCHODNI SPOLECNOST ", " VOS ", 1) 
                
** BULGARIA
replace standard_name = subinstr( standard_name, " AKTIONIERNO DRUSHESTWO ", " AD ", 1)
replace standard_name = subinstr( standard_name, " KOMANDITNO DRUSHESTWO ", " KD ", 1)
replace standard_name = subinstr( standard_name, " KOMANDITNO DRUSHESTWO S AKZII ", " KDA ", 1)
replace standard_name = subinstr( standard_name, " DRUSHESTWO S ORGRANITSCHENA OTGOWORNOST ", " OCD ", 1)



***********stem name to remove corporate IDs********************************************************************************************************************
*this section uses code from stem_name.do


gen stem_name = standard_name

** UNITED KINGDOM
replace stem_name = subinstr( stem_name, " LTD ", " ", 1)
replace stem_name = subinstr( stem_name, " CO LTD ", " ", 1)
replace stem_name = subinstr( stem_name, " TRADING LTD ", " ", 1)
replace stem_name = subinstr( stem_name, " HLDGS ", " ", 1)    
replace stem_name = subinstr( stem_name, " INST ", " ", 1)    
replace stem_name = subinstr( stem_name, " CORP ", " ", 1)       
replace stem_name = subinstr( stem_name, " INTL ", " ", 1)       
replace stem_name = subinstr( stem_name, " INC ", " ", 1)        
replace stem_name = subinstr( stem_name, " PLC ", " ", 1)        
replace stem_name = subinstr( stem_name, " SPA ", " ", 1)        
replace stem_name = subinstr( stem_name, " CLA ", " ", 1)        
replace stem_name = subinstr( stem_name, " LLP ", " ", 1)        
replace stem_name = subinstr( stem_name, " LLC ", " ", 1)        
replace stem_name = subinstr( stem_name, " AIS ", " ", 1)        
replace stem_name = subinstr( stem_name, " INVESTMENTS ", " ", 1)
replace stem_name = subinstr( stem_name, " PARTNERSHIP ", " ", 1)
replace stem_name = subinstr( stem_name, " & CO ", " ", 1)         
replace stem_name = subinstr( stem_name, " CO ", " ", 1)         
replace stem_name = subinstr( stem_name, " COS ", " ", 1)        
replace stem_name = subinstr( stem_name, " CP ", " ", 1)         
replace stem_name = subinstr( stem_name, " LP ", " ", 1)         
replace stem_name = subinstr( stem_name, " BLSA ", " ", 1)
replace stem_name = subinstr( stem_name, " GROUP ", " ", 1)

** FRANCE
replace stem_name = subinstr( stem_name, " SA ", " ", 1)         
replace stem_name = subinstr( stem_name, " SARL ", " ", 1)         
replace stem_name = subinstr( stem_name, " SAS ", " ", 1)         
replace stem_name = subinstr( stem_name, " EURL ", " ", 1)         
replace stem_name = subinstr( stem_name, " ETCIE ", " ", 1)         
replace stem_name = subinstr( stem_name, " ET CIE ", " ", 1)
replace stem_name = subinstr( stem_name, " CIE ", " ", 1)
replace stem_name = subinstr( stem_name, " GIE ", " ", 1)         
replace stem_name = subinstr( stem_name, " SC ", " ", 1)         
replace stem_name = subinstr( stem_name, " SNC ", " ", 1)         
replace stem_name = subinstr( stem_name, " SP ", " ", 1)         
replace stem_name = subinstr( stem_name, " SCS ", " ", 1)         

** GERMANY
replace stem_name = subinstr( stem_name, " GMBHCOKG ", " ", 1)         
replace stem_name = subinstr( stem_name, " EGENOSSENSCHAFT ", " ", 1)         
replace stem_name = subinstr( stem_name, " GMBHCO ", " ", 1)         
replace stem_name = subinstr( stem_name, " COGMBH ", " ", 1)         
replace stem_name = subinstr( stem_name, " GESMBH ", " ", 1)         
replace stem_name = subinstr( stem_name, " GMBH ", " ", 1)         
replace stem_name = subinstr( stem_name, " KGAA ", " ", 1)         
replace stem_name = subinstr( stem_name, " KG ", " ", 1)         
replace stem_name = subinstr( stem_name, " AG ", " ", 1)         
replace stem_name = subinstr( stem_name, " EG ", " ", 1)         
replace stem_name = subinstr( stem_name, " GMBHCOKGAA ", " ", 1)         
replace stem_name = subinstr( stem_name, " MIT ", " ", 1)         
replace stem_name = subinstr( stem_name, " OHG ", " ", 1)         
replace stem_name = subinstr( stem_name, " GRUPPE ", " ", 1)
replace stem_name = subinstr( stem_name, " GBR ", " ", 1)

** Spain
replace stem_name = subinstr( stem_name, " SL ", " ", 1)         
replace stem_name = subinstr( stem_name, " SA ", " ", 1)         
replace stem_name = subinstr( stem_name, " SC ", " ", 1)         
replace stem_name = subinstr( stem_name, " SRL ", " ", 1)
replace stem_name = subinstr( stem_name, " ESPANA ", " ", 1)

** Italy
replace stem_name = subinstr( stem_name, " SA ", " ", 1)         
replace stem_name = subinstr( stem_name, " SAS ", " ", 1)         
replace stem_name = subinstr( stem_name, " SNC ", " ", 1)         
replace stem_name = subinstr( stem_name, " SPA ", " ", 1)
replace stem_name = subinstr( stem_name, " SRL ", " ", 1)

** SWEDEN - front and back
replace stem_name = subinstr( stem_name, " AB ", " ", 1)
replace stem_name = subinstr( stem_name, " HB ", " ", 1)
replace stem_name = subinstr( stem_name, " KB ", " ", 1)

** Belgium
** Note: the belgians use a lot of French endings, so we include all the French ones.
** Also, they use NV (belgian) and SA (french) interchangably, so standardise to SA

* French ones again
replace stem_name = subinstr( stem_name, " SAS ", " ", 1)
replace stem_name = subinstr( stem_name, " SA ", " ", 1)
replace stem_name = subinstr( stem_name, " SARL ", " ", 1)
replace stem_name = subinstr( stem_name, " SARLU ", " ", 1)
replace stem_name = subinstr( stem_name, " SAS ", " ", 1)
replace stem_name = subinstr( stem_name, " SASU ", " ", 1)
replace stem_name = subinstr( stem_name, " EURL ", " ", 1)
replace stem_name = subinstr( stem_name, " ETCIE ", " ", 1)
replace stem_name = subinstr( stem_name, " CIE ", " ", 1)
replace stem_name = subinstr( stem_name, " GIE ", " ", 1)
replace stem_name = subinstr( stem_name, " SC ", " ", 1)
replace stem_name = subinstr( stem_name, " SNC ", " ", 1)
replace stem_name = subinstr( stem_name, " SP ", " ", 1)
replace stem_name = subinstr( stem_name, " SCS ", " ", 1)

* Specifically Belgian ones
replace stem_name = subinstr( stem_name, " BV ", " ", 1)
replace stem_name = subinstr( stem_name, " CVA ", " ", 1)
replace stem_name = subinstr( stem_name, " SCA ", " ", 1)
replace stem_name = subinstr( stem_name, " SPRL ", " ", 1)

* Change to French language equivalents where appropriate
replace stem_name = subinstr( stem_name, " SCS ", " ", 1)
replace stem_name = subinstr( stem_name, " SA ", " ", 1)
replace stem_name = subinstr( stem_name, " SPRL ", " ", 1)

** Denmark - front and back
* Usually danish identifiers have a slash (eg. A/S or K/S), but these will have been removed with all
* other punctuation earlier (so just use AS or KS).
replace stem_name = subinstr( stem_name, " AMBA ", " ", 1)
replace stem_name = subinstr( stem_name, " APS ", " ", 1)
replace stem_name = subinstr( stem_name, " AS ", " ", 1)
replace stem_name = subinstr( stem_name, " IS ", " ", 1)
replace stem_name = subinstr( stem_name, " KAS ", " ", 1)
replace stem_name = subinstr( stem_name, " KS ", " ", 1)
replace stem_name = subinstr( stem_name, " PF ", " ", 1)

** Norway - front and back
replace stem_name = subinstr( stem_name, " AL ", " ", 1)
replace stem_name = subinstr( stem_name, " ANS ", " ", 1)
replace stem_name = subinstr( stem_name, " AS ", " ", 1)
replace stem_name = subinstr( stem_name, " ASA ", " ", 1)
replace stem_name = subinstr( stem_name, " DA ", " ", 1)
replace stem_name = subinstr( stem_name, " KS ", " ", 1)

** Netherlands - front and back
replace stem_name = subinstr( stem_name, " BV ", " ", 1) 
replace stem_name = subinstr( stem_name, " CV ", " ", 1)
replace stem_name = subinstr( stem_name, " CVOA ", " ", 1)
replace stem_name = subinstr( stem_name, " NV ", " ", 1)
replace stem_name = subinstr( stem_name, " VOF ", " ", 1)

** Finland - front and back
** We get some LTD and PLC strings for finland. Remove.
replace stem_name = subinstr( stem_name, " AB ", " ", 1)
replace stem_name = subinstr( stem_name, " APB ", " ", 1)
replace stem_name = subinstr( stem_name, " KB ", " ", 1)
replace stem_name = subinstr( stem_name, " KY ", " ", 1)
replace stem_name = subinstr( stem_name, " OY ", " ", 1)
replace stem_name = subinstr( stem_name, " OYJ ", " ", 1)
replace stem_name = subinstr( stem_name, " OYJ AB ", " ", 1)
replace stem_name = subinstr( stem_name, " OY AB ", " ", 1)
replace stem_name = subinstr( stem_name, " LTD ", " ", 1)
replace stem_name = subinstr( stem_name, " PLC ", " ", 1)
replace stem_name = subinstr( stem_name, " INC ", " ", 1)

** Poland
replace stem_name = subinstr( stem_name, " SA ", " ", 1) 
replace stem_name = subinstr( stem_name, " SC ", " ", 1)
replace stem_name = subinstr( stem_name, " SK ", " ", 1)
replace stem_name = subinstr( stem_name, " SPZOO ", " ", 1)

** Greece
** Also see limited and so on sometimes
replace stem_name = subinstr( stem_name, " AE ", " ", 1)
replace stem_name = subinstr( stem_name, " EE ", " ", 1)
replace stem_name = subinstr( stem_name, " EPE ", " ", 1)
replace stem_name = subinstr( stem_name, " OE ", " ", 1)
replace stem_name = subinstr( stem_name, " SA ", " ", 1)
replace stem_name = subinstr( stem_name, " LTD ", " ", 1)
replace stem_name = subinstr( stem_name, " PLC ", " ", 1)
replace stem_name = subinstr( stem_name, " INC ", " ", 1)

** Czech Republic
replace stem_name = subinstr( stem_name, " AS ", " ", 1)
replace stem_name = subinstr( stem_name, " KS ", " ", 1)
replace stem_name = subinstr( stem_name, " SRO ", " ", 1)
replace stem_name = subinstr( stem_name, " VOS ", " ", 1) 

** Bulgaria
replace stem_name = subinstr( stem_name, " AD ", " ", 1)
replace stem_name = subinstr( stem_name, " KD ", " ", 1)
replace stem_name = subinstr( stem_name, " KDA ", " ", 1)
replace stem_name = subinstr( stem_name, " OCD ", " ", 1)
replace stem_name = subinstr( stem_name, " KOOP ", " ", 1)
replace stem_name = subinstr( stem_name, " DF ", " ", 1)
replace stem_name = subinstr( stem_name, " EOOD ", " ", 1)
replace stem_name = subinstr( stem_name, " EAD ", " ", 1)
replace stem_name = subinstr( stem_name, " OOD ", " ", 1)
replace stem_name = subinstr( stem_name, " KOOD ", " ", 1)
replace stem_name = subinstr( stem_name, " ET ", " ", 1)

** Japan
replace stem_name = subinstr( stem_name, " KOGYO KK ", " ", 1)
replace stem_name = subinstr( stem_name, " KK ", " ", 1)

replace standard_name = trim(subinstr(standard_name,"  "," ",30))
replace stem_name = trim(subinstr(stem_name,"  "," ",30))


rename standard_name name_clean
rename stem_name name_stem
}

*save dataset
save assignment_names_clean_stem, replace



*rename variables and identify firms in assignment dataset
use assignment_names_clean_stem, clear
keep if asstype=="firm"
foreach var in name id name_clean name_stem{
rename `var' assign_`var'
}
save assignment_names_clean_stem2, replace

