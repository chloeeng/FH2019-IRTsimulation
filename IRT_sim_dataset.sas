/*	--------------------------------------------------------------------------------------- */
/*																							*/
/*	Friday Harbor Workgroup 4 Simulation													*/
/*	Dataset Creation Code																	*/
/*																							*/ 
/*																							*/
/*	CREATED: August 20, 2019																*/
/*	LAST MODIFIED: 																			*/
/*																							*/
/*																							*/
/*	--------------------------------------------------------------------------------------- */



/*	Dataset Creation ---------------------------------------------------------------------- */

/*	Modifiable Characteristics */
	%let iter = 1000;						/* Iterations  */
	%let N0 = 1000;							/* Number of participants in study 0 */
	%let N1 = 1000;							/* Number of participants in study 1 */ 

	%let item0 = 9;							/* Number of items in study 0 */ 
	%let item1 = 9;							/* Number of items in study 1 */ 
	%let item_overlap = 3; 					/* Number of anchor items in both surveys */ 
	%let itemn = 15; 						/* Total items: item0 + item1 - item_overlap */

	%let diffrange0 = 8; *mean; %let diffrange1 = 0.3; *interval; /*For a range of -2.1 to 2.1 by 3, where z=item number ranging from 1 to 15 */

/* 	Hand Coding Discrimination */	 
	%let discrimination1=1;
	%let discrimination2=1;
	%let discrimination3=1;
	%let discrimination4=1;
	%let discrimination5=1;
	%let discrimination6=1;
	%let discrimination7=1;
	%let discrimination8=1;
	%let discrimination9=1;
	%let discrimination10=1;
	%let discrimination11=1;
	%let discrimination12=1;
	%let discrimination13=1;
	%let discrimination14=1;
	%let discrimination15=1;

/*	Mean 
	%let mean_ability_study0 = -0.5;	
	%let sd_ability_study0 = 1;
	%let mean_ability_study1 = 0.5;
	%let sd_ability_study1 = 1;

/*	Derived Characteritics */
	%let N_full = &n0+&n1;	/* sample size */ 

	data sim0;
 *	defining seed for random number generation ;
	call streaminit(893292);  
 *	Mean/SD of study 0 and study 1;
	mean_ability_study0=&mean_ability_study0;
	sd_ability_study0=&sd_ability_study0;
	mean_ability_study1=&mean_ability_study1;
	sd_ability_study1=&sd_ability_study1;
 *	Set discrimination for everyone ; 
 *	Simulate item values ; 
	do simid = 1 to &iter; * THIS CODE CREATES THE MULTIPLE SIMULATION SAMPLES ;
		do i = 1 to &N_full; 
		/*	Defining how many people are assigned to each study */
			study=rand('BINOMIAL',.5,1); * 0.5 is the probabililty of being assigned into one of the studies ;
			if study=0 then ability=rand("Normal",mean_ability_study0,sd_ability_study0);
			if study=1 then ability=rand("Normal",mean_ability_study1,sd_ability_study1);
			%macro item; /* -----------------------------------------------------------------------------------------------*/
			/*	Creating Item Variables 1-# of items */
				%do z=1 %to &itemn;
					item_&z=.;
					difficulty&z = (&z-&diffrange0)*&diffrange1;  
					discrimination&z=&&discrimination&z;
					/* 	To hand input difficulty: 
						difficulty[DEFINE NUMBER] = NEW VALUE */
				%end;

			/* 	Coding for if in study 0, have values only for items 1 to 9 */
				if study=0 then do;
				%do j=1 %to 9;   
						item0_&j = 	exp(discrimination&j*(ability-difficulty&j))/
									(1+exp(discrimination&j*(ability-difficulty&j)));
						item_&j = rand('Binomial', item0_&j,1);
				%end;  
				end;  
			/* 	Coding for if in study 1, have values only for items 7 to 15 */
				if study=1 then do; 
				%do k=7 %to 15;  
						item0_&k = exp(discrimination&k*(ability-difficulty&k))/(1+exp(discrimination&k*(ability-difficulty&k))); 
						item_&k = rand('Binomial',item0_&k,1);
				%end; 
				end;
			%mend; 
			%item;
			output;
		end;
	end;
	drop i mean_ability: sd_ability: difficulty: ;*item0:;
	run;

	proc means data=sim0; var ability item0: item_1--item_15; class study; run;
	
 *	Assigning random IDs (separating by statement from next steps for computational power) ;
	data sim; set sim0; by simid; sampleid=_N_-((simid-1)*(&n0+&n1)); run;
	proc sort data=sim; by simid study; run;

/*	Outputting permanent dataset ----------------------------------------------------------
	libname fh 'D:\Dropbox\Friday Harbor\2019\Data';
	data fh.H; set sim; run;															
	--------------------------------------------------------------------------------------- */

/*	SIMULATING IRT ------------------------------------------------------------------------ */

/*	TWO PARAMETER LOGISTIC MODEL */
	*ods exclude ItemFit IterHistory ParameterEstimates ItemInfo;
	proc irt data=sim itemfit out=fscore2PL itemstat scoremethod=ml noprint;
	by simid; 
	var item_1--item_15;
	run;
	ods exclude none;
	proc means data=fscore2PL mean std min q1 median q3 max; var _factor1; by simid; run;

/*	GRADED RESPONSE MODEL */
	proc irt data=data itemfit out=fscoreGR;
	by simid; *where simid=1;
	var i1-i20;
	model i1-i20/resfunc=gr;
	run;
	proc means data=fscore2PL mean std min q1 median q3 max; var _factor1; by simid; run;
