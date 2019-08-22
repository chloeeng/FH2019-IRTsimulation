/*	--------------------------------------------------------------------------------------- */
/*																							*/
/*	Friday Harbor Workgroup 4 Simulation													*/
/*	Dataset Creation Code																	*/ 
/*																							*/
/*	CREATED: August 21, 2019																*/
/*	LAST MODIFIED: 																*/
/*																							*/
/*																							*/
/*	--------------------------------------------------------------------------------------- */
 
	libname fh 'D:\Dropbox\Friday Harbor\2019\Data';

	%macro irt (version);
	%do i=1 %to 1000;
		proc irt data=fh.&version link=logit out=fscore2pl&i scoremethod=eap noprint;
		var item_1--item_15;
		where simid = &i.;
		run;
	%end;
	data fh.fscore2PL_&version;
	set fscore2pl:;
	diff=ability-_factor1;  
	run;
	%mend; 
	%irt(a);
	%irt(b);

	*ods output summary=with_stackods(drop=_control_);
	proc means data=fh.fscore2PL_A /*stackodsoutput*/ mean std n min p25 median p75 max;
	class simid;
	var ability _factor1 diff; 
	where study=0;
	output out=fscore2pl_A_means0;
	run;
	proc means data=fh.fscore2PL_A /*stackodsoutput*/ mean std n min p25 median p75 max;
	class simid;
	var ability _factor1 diff; 
	where study=1;
	output out=fscore2pl_A_means1;
	run;

	data fscore2PL_A_means; set fscore2PL_A_means0 (in=a) fscore2pl_A_means1 (in=b);
	if a then study=0;
	if b then study=1;
	if _stat_='MEAN' then ability_mean=ability;
	if _stat_='MEAN' then factor_mean=_factor1;
	if _stat_='MEAN' then diff_mean=diff;
	if _stat_='STD' then ability_std=ability;
	if _stat_='STD' then factor_std=_factor1;
	if _stat_='STD' then diff_std=diff;
	if _type_=0 then delete;
	run;
