/*Replace missing values with a blank*/
OPTIONS MISSING='';

/*Read in the cleaned csv file of energy consumption data.*/
PROC IMPORT DATAFILE= '/folders/myfolders/SASData/Annual_Energy_Consumption_Data_2017.csv'
OUT=WORK.TORONTOENERGY
DBMS=CSV;
GETNAMES=YES
;
RUN;

/*Select only the data where Operation Name starts with 'D'*/
PROC SQL;
CREATE TABLE OperationName_D AS
SELECT * 
FROM 
WORK.TORONTOENERGY
WHERE Operation_Name LIKE 'D%';
;
QUIT;

/*Select only the Energy Consumption columns and Operation Name */
PROC SQL;
CREATE TABLE Operation_ColsRequired AS
   SELECT Operation_Name, Total_GHG_Emissions_in_KG,
   Energy__ekWhPersqft
      FROM OPERATIONNAME_D;
QUIT;


/*Get the means of all energy consumption columns */
PROC MEANS DATA=WORK.OPERATION_COLSREQUIRED;
RUN;



