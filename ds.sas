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
