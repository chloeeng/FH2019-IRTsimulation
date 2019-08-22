
    data simfull;
    merge r.rthetas fh.fscore2PL_A;
    by simid sampleid;
    run;
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

	'https://github.com/chloeeng/IRTsimulation-SAS.git'
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

	ods graphics on;
	proc sgplot data=fscore2PL_A_means; 
	styleattrs datacontrastcolors=(black) datacolors=(CX2471A3 CX76448A GRAY28) datalinepatterns=(solid dot);
	histogram ability_mean / group=study;  
	density ability_mean / group=study;   
	run;
	proc sgplot data=fscore2PL_A_means;  
	styleattrs datacontrastcolors=(black) datacolors=(CX2471A3 CX76448A GRAY28) datalinepatterns=(solid dot);
	histogram factor_mean / group=study;   
	density factor_mean / group=study;  
	run;

	
	proc sgplot data=fscore2PL_A_means;  
	styleattrs datacontrastcolors=(black) datacolors=(CX2471A3 CX76448A GRAY28) datalinepatterns=(solid dot);
	histogram ability_mean;   
	density ability_mean;  
	histogram factor_mean;   
	density factor_mean;  
	where study=0;
	run;
 	proc sgplot data=fscore2PL_A_means;  
	styleattrs datacontrastcolors=(black) datacolors=(CX2471A3 CX76448A GRAY28) datalinepatterns=(solid dot);
	histogram ability_mean;   
	density ability_mean;  
	histogram factor_mean;   
	density factor_mean;  
	where study=1;
	run;
 
	proc sgplot data=fscore2PL_A_means;
	scatter x=ability_mean y=factor_mean / group=study;
	reg x=ability_mean y=factor_mean / group=study;
	run;

	%macro rthetas;
		%do i=1 %to 9; 
		PROC IMPORT OUT= WORK.BL_3MID_NARROW_&i DATAFILE="D:\Dropbox\Friday Harbor\2019\Data\RThetas\00000000&i._BASELINE_3MIDDLE_NARROW_results.csv" 
		DBMS=CSV REPLACE; GETNAMES=YES; DATAROW=2; RUN;
		%end;
		%do i=10 %to 99; 
		PROC IMPORT OUT= WORK.BL_3MID_NARROW_&i DATAFILE="D:\Dropbox\Friday Harbor\2019\Data\RThetas\0000000&i._BASELINE_3MIDDLE_NARROW_results.csv" 
		DBMS=CSV REPLACE; GETNAMES=YES; DATAROW=2; RUN;
		%end;
		%do i=100 %to 999; 
		PROC IMPORT OUT= WORK.BL_3MID_NARROW_&i DATAFILE="D:\Dropbox\Friday Harbor\2019\Data\RThetas\000000&i._BASELINE_3MIDDLE_NARROW_results.csv" 
		DBMS=CSV REPLACE; GETNAMES=YES; DATAROW=2; RUN;
		%end;
		PROC IMPORT OUT= WORK.BL_3MID_NARROW_1000 DATAFILE="D:\Dropbox\Friday Harbor\2019\Data\RThetas\000001000_BASELINE_3MIDDLE_NARROW_results.csv" 
		DBMS=CSV REPLACE; GETNAMES=YES; DATAROW=2; RUN;
	%mend;
	%rthetas;

	libname r 'D:\Dropbox\Friday Harbor\2019\Data\RThetas';
	data r.rthetas;
	set  bl_3mid_narrow_:;
	rename scenario=simid
		   id=sampleid;
	proc sort; by simid sampleid; 
	proc datasets library=work;
	delete bl_3mid_narrow_:;
	run;  
	
	
