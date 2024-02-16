
%let wrds = wrds.wharton.upenn.edu 4016; 
options comamid=TCP remote=WRDS;
signon username=_prompt_;
Libname rwork slibref=work server=wrds;
libname perm '*****insert filepath here******\Data\patent_trade_data';

*Compustat data pull;
rsubmit;
data comp; set comp.funda
(keep = gvkey tic conm cik datadate cusip indfmt datafmt popsrc consol curcd fic fyr fyear sich);
where	(fyear ge 1970) 
		and (indfmt='INDL') and (datafmt='STD') and (popsrc='D') and (consol='C');
drop indfmt datafmt popsrc consol;
run;
proc sort data=comp out=comp nodupkey; by gvkey fyear;run;

* Get Permno;
proc sql; create table comp as select distinct
	a.*, b.lpermno as permno
    from comp as a left join crsp.ccmxpf_linktable
	(where=(linktype in ('LU', 'LC', 'LD', 'LF', 'LN', 'LO', 'LS', 'LX'))) as b
    on (a.gvkey = b.gvkey) 
	and (b.linkdt <= a.datadate or b.linkdt = .B) 
	and (a.datadate <= b.linkenddt or b.linkenddt = .E);
 	quit;
endrsubmit;

rsubmit;
proc download data=comp out=comp;run;
endrsubmit;

*reduce dataset down to most recent sic for a given permno;
proc sort data=comp out=comp nodupkey; by permno descending fyear;run;
proc sort data=comp out=comp nodupkey; by permno;run;

data comp; set comp;
where permno ne .;
keep permno gvkey sich;
run;

data perm.permno_sic; set comp; run;

*save as STATA dataset;
proc export data=comp outfile='*****insert filepath here******\Data\patent_trade_data\permno_sic.dta' replace; run;
