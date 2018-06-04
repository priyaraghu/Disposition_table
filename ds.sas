# Disposition_table
Table summarizes the disposition events in a study, with basic demography details
/*Final code*/
libname adam "/folders/myfolders/sasuser.v94/adam";

proc sql;/* storing all the denominatores*/
select count(distinct subjid) into:P1
from adam.adsl 
where randfl="Y";

select count(distinct subjid) into:g1
from adam.adsl
where trsqptcd ="ABFCED" and randfl="Y";

select count(distinct subjid) into:g2
from adam.adsl
where trsqptcd ="BCADFE" and randfl="Y";

select count(distinct subjid) into:g3
from adam.adsl
where trsqptcd ="CDBEAF" and randfl="Y";

select count(distinct subjid) into:g4
from adam.adsl
where trsqptcd ="DECFBA" and randfl="Y";

select count(distinct subjid) into:g5
from adam.adsl
where trsqptcd ="EFDACB" and randfl="Y";

select count(distinct subjid) into:g6
from adam.adsl
where trsqptcd ="FAEBDC" and randfl="Y";
quit;
/*deriving row1*/
data myadsl(keep= subjid trsqptcd randfl complfl);
set adam.adsl;
where randfl="Y";
run;
 proc freq data =myadsl noprint;
 tables trsqptcd/out= count(drop=percent);
 run;
 
 proc transpose data=count out=count_transformed(drop=_name_ _label_);/* row1 */
 id trsqptcd;
 var count;
 run;
 /* derving event variable for row1*/
data row1;
set count_transformed;
length EventN $4 Event $50;
EventN="1";Event="Subjects in the Randomized Population";
run;

/**************************************************************/ 
 data complfl; /* row2*/
set myadsl;
where complfl="Y";
run;

proc freq data = complfl noprint;
 tables trsqptcd/out= count_complfl(drop=percent);
 run;
 
 
proc transpose data=count_complfl out=count_complfl_transformed(drop=_name_ _label_);
 id trsqptcd;
 var count;
 run;
 
 data row2;
 set count_complfl_transformed;
EventN="2";Event="Subjects who Completed the Study";
run;
 
/****************************************************************/ 


data adsp(keep = subjid randfl aperiod aperiodc trseqpcd);/* derive row3 to row9*/
set adam.adsp;
where (aperiod ne 1) and  (aperiod ne 2) and randfl="Y";
run;

data adsl(keep=subjid randfl trseqpcd trsqptcd);/* subsetting from adsl and adsp datasets for treatment period*/
set adam.adsl;
where randfl eq "Y";
run;

proc sort data=adsp out= adsp_sorted;
by subjid trseqpcd randfl aperiod aperiodc ;
run;
proc sort data=adsl out= adsl_sorted;
by subjid trseqpcd randfl;
run;

data adsl_adsp(keep =subjid trsqptcd aperiodc);
merge adsl_sorted adsp_sorted;
by subjid trseqpcd randfl;
run;

proc sort data= adsl_adsp out=test;/* sort the merged dataset, number of subjects needed by treatment period*/
by subjid;
run;
proc freq data=test noprint;
by subjid;
tables aperiodc*trsqptcd/ out=count_row3(drop=percent);
run;
proc freq data=count_row3 noprint;
weight count;
tables aperiodc*trsqptcd/ out= test_1(drop=percent);
run;
proc sort data=test_1;
by aperiodc;
run;

proc transpose data=test_1 out=test_2(drop=_name_ _label_);
by aperiodc ;
id trsqptcd;
 var count;
 run;
/* setting all 3 rows*/
data row3;
set test_2;
Length EventN $4 Event $50;

if aperiodc="Treatment Period 1" then do;EventN="3";
Event="Subjects who completed Treatment Period 1";end;
if aperiodc="Treatment Period 2" then do;EventN="4";
Event="Subjects who completed Treatment Period 2";end;
if aperiodc="Treatment Period 3" then do;EventN="5";
Event="Subjects who completed Treatment Period 3";end;
if aperiodc="Treatment Period 4" then do;EventN="6";
Event="Subjects who completed Treatment Period 4";
end;
if aperiodc="Treatment Period 5" then do;EventN="7";
Event="Subjects who completed Treatment Period 5";end;
if aperiodc="Treatment Period 6" then do;EventN="8";
Event="Subjects who completed Treatment Period 6";end;
drop aperiodc;
run;
/******************* set all the 3 rows*/
 /*data ;
 set row1 row2 row3;
 run;*/
 
 /******* deriving row9 from adsp*/
data adsp(keep = subjid randfl discfl  trseqpcd);
set adam.adsp;
where (aperiod ne 1) and  (aperiod ne 2) ;
run;

data adsl(keep=subjid randfl trseqpcd trsqptcd);
set adam.adsl;
where randfl eq "Y" ;
run;
proc sort data=adsp out= adsp_sorted;
by subjid trseqpcd randfl  ;
run;
proc sort data=adsl out= adsl_sorted;
by subjid trseqpcd randfl;
run;

data adsl_adsp(keep =subjid discfl randfl trsqptcd );/* has treatment sequence taken from adsl*/
merge adsl_sorted adsp_sorted;
by subjid trseqpcd ;
run;
/* subsetting for records who have discontinued*/
data test1(drop=randfl);
set adsl_adsp;
where discfl="Y";
run;
proc freq data=test1 noprint;
 tables trsqptcd/ out= test2(drop=percent);
 run;
 
 proc transpose data=test2 out=test2_transposed(drop=_name_ _label_);
 id trsqptcd;
 var count;
 run;
 
 data row9;
 set test2_transposed;
 length EventN $4 Event $50;
 EventN="9";
 Event="Subjects who Discontinued Early";
 run;
 
/**********************************end of part1****************************/

/* deriving part2*/
data adsp(keep = subjid randfl discfl preason aperiod  trseqpcd);
set adam.adsp;
where (aperiod ne 1) and  (aperiod ne 2) and discfl="Y";
run;

data adsl(keep=subjid randfl trseqpcd complfl trsqptcd);
set adam.adsl;
where randfl eq "Y" and complfl="N";
run;
proc sort data=adsp out= adsp_sorted;
by subjid trseqpcd   ;
run;
proc sort data=adsl out= adsl_sorted;
by subjid trseqpcd ;
run;

data adsl_adsp(keep =subjid_N  trsqptcd preason );/* has treatment sequence taken from adsl*/
merge adsl_sorted adsp_sorted;
by subjid trseqpcd ;
subjid_N=input(subjid, 8.);
run;
proc format; /*format for preloadfmt applied on preason*/
value $reason
 "Occurence Of Intolerable Adverse Event" ="Adverse Event"
 "Withdrawal Of Consent" ="Withdrawal of Consent"
 "Lost to Follow-up" ="Lost to Follow-up"
 "Administrative Reasons"="Administrative Reasons" 
 "Major Violation of the Protocol"="Major Violation of the Protocol" 
 "Physician Decision" ="Physician Decision"
 "Pregnancy" ="Pregnancy"
 "Non-Compliance"="Non-compliance" 
 "Termination of the Study"="Termination of the Study" 
 "Death" ="Death"
 "Other"="Other"
 ;
 quit;
 

proc means  data=adsl_adsp noprint  n nway completetypes;
class trsqptcd; 
class preason/preloadfmt ;
format preason $reason. ;
var subjid_N;
output out= means_1 (DROP= _TYPE_ _FREQ_) n=n1;
run;

proc sort data= means_1;
by preason;
run;
proc transpose data= means_1 out= means_2(drop=_name_ );
by preason;
id trsqptcd;
var  n1;
run;
 /* rename Preason as Event*/
proc format;
 value $event_number
"Adverse Event"="11"
 "Withdrawal of Consent"="12"
 "Lost to Follow-up" ="13"
 "Administrative Reasons" ="14"
 "Major Violation of the Protocol"="15" 
 "Physician Decision"="16"
 "Pregnancy"="17"
 "Non-compliance"="18" 
 "Termination of the Study"="19" 
 "Death"="20"
 "Other"="21"
 ;
 quit;
 
 data row11;
 set means_2;
 length Event $50 EventN $4;
 Event=put(preason,$reason.);/* equating formatted preason as Event*/ 
 EventN=put(Event, $event_number.);
 drop preason;
 run;
 
 data temp1;
 set row1 row2 row3 row9 row11;
 run;
 
 data temp2;
 set temp1;/* code to handle missing values*/
 if(ABFCED eq .) then do; ABFCED=0; end;
 if(BCADFE eq .) then do; BCADFE=0; end;
 if(CDBEAF eq .) then do; CDBEAF=0; end;
 if(DECFBA eq .) then do; DECFBA=0; end;
 if(EFDACB eq .) then do; EFDACB=0; end;
 if(FAEBDC eq .) then do; FAEBDC=0; end;
 Total= (ABFCED+BCADFE+CDBEAF+DECFBA+EFDACB+FAEBDC);
 run;
 
 
 /* calculating  percentages*/
data final;
set temp2;
length  ABFCED_N $20 BCADFE_N $20 CDBEAF_N $20 DECFBA_N $20 EFDACB_N $20 FAEBDC_N $20 total_new $20;
if EventN eq "1" then do; 
ABFCED_N=put(ABFCED,4.); BCADFE_N=put(BCADFE,4.); CDBEAF_N=put(CDBEAF,4.);
DECFBA_N=put(DECFBA,4.); EFDACB_N=put(EFDACB,4.); FAEBDC_N=put(FAEBDC,4.);
Total_new=put(total,4.);
end;

else  do;
if ABFCED eq 0 then do; ABFCED_N=put(ABFCED, 4.); end;
if (ABFCED ne 0 and ABFCED ne &g1 ) then do; 
ABFCED_N=compress(put(ABFCED, 4.) || '(' || put(((ABFCED/&g1)*100),8.1) || ')') ;end;
if(ABFCED ne 0 and ABFCED eq &g1 ) then do;
ABFCED_N=compress(put(ABFCED, 4.) || '(' || put(((ABFCED/&g1)*100),8.) || ')') ;end;


if  BCADFE eq 0 then do; BCADFE_N=put(BCADFE, 4.); end;
if ( BCADFE ne 0 and BCADFE ne &g2) then do; 
BCADFE_N=compress(put(BCADFE, 4.) || '(' || put(((BCADFE/&g1)*100),8.1) || ')') ;end;
if(( BCADFE ne 0 and  BCADFE eq &g2)) then do;
BCADFE_N=compress(put(BCADFE, 4.) || '(' || put(((BCADFE/&g1)*100),8.) || ')') ;end;


if CDBEAF eq 0 then do; CDBEAF_N=put(CDBEAF, 4.); end;
if ( CDBEAF ne 0 and CDBEAF ne &g3) then do; 
CDBEAF_N=compress(put(CDBEAF, 4.) || '(' || put(((CDBEAF/&g3)*100),8.1) || ')') ;end;
if(( CDBEAF ne 0 and CDBEAF eq &g3)) then do;
CDBEAF_N=compress(put(CDBEAF, 4.) || '(' || put(((CDBEAF/&g1)*100),8.) || ')') ;end;

if DECFBA eq 0 then do; DECFBA_N=put(DECFBA, 4.); end;
if ( DECFBA ne 0 and DECFBA ne &g1) then do; 
DECFBA_N=compress(put(DECFBA, 4.) || '(' || put(((DECFBA/&g1)*100),8.1) || ')') ;end;
if(( DECFBA ne 0 and  DECFBA eq &g1)) then do;
DECFBA_N=compress(put(DECFBA, 4.) || '(' || put(((DECFBA/&g1)*100),8.) || ')') ;end;

if EFDACB eq 0 then do; EFDACB_N=put(EFDACB, 4.); end;
if ( EFDACB ne 0 and  EFDACB ne &g1) then do; 
EFDACB_N=compress(put(EFDACB, 4.) || '(' || put(((EFDACB/&g1)*100),8.1) || ')') ;end;
if(( EFDACB ne 0 and  EFDACB eq &g1)) then do;
EFDACB_N=compress(put( EFDACB,4.) || '(' || put(((EFDACB/&g1)*100),8.) || ')') ;end;

if  FAEBDC eq 0 then do; FAEBDC_N=put(FAEBDC, 4.); end;
if ( FAEBDC ne 0 and  FAEBDC ne &g1) then do; 
FAEBDC_N=compress(put(FAEBDC, 4.) || '(' || put(((FAEBDC/&g1)*100),8.1) || ')') ;end;
if(( FAEBDC ne 0 and  FAEBDC eq &g1)) then do;
FAEBDC_N=compress(put(FAEBDC,4.) || '(' || put(((FAEBDC/&g1)*100),8.) || ')') ;end;

if  total eq 0 then do; total_new=compress(put(total, 4.)); end;
if ( total ne 0 and  total ne &p1) then do; 
total_new=compress(put(total, 4.) || '(' || put(((total/&p1)*100),8.1) || ')') ;end;
if(( total ne 0 and  total eq &p1)) then do;
total_new=compress(put(total,4.) || '(' || put(((total/&p1)*100),8.) || ')') ;end;
end;/* else do loop completes, copmutes for all events ne 1*/
drop ABFCED BCADFE  CDBEAF DECFBA EFDACB FAEBDC total;
rename ABFCED_N=ABFCED BCADFE_N=BCADFE CDBEAF_N=CDBEAF DECFBA_N=DECFBA 
EFDACB_N=EFDACB FAEBDC_N=FAEBDC total_new=Total;
run;
 
