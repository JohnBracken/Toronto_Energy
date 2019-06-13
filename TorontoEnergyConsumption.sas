/*The following script reads in a dataset which describes
power consumption of various public buildings in Toronto.
Multiple steps are then taken to clean the data so that what
results is a clean dataset with labelled columns and properly
assigned variables to the data.  Finally, the table is exported
into a clean csv file, which can then be used later for analysis.*/

/*Replace missing values with a blank*/
OPTIONS MISSING='';

/*Read in csv file of energy consumption data.*/
PROC IMPORT DATAFILE= '/folders/myfolders/SASData/Annual_Energy_Consumption_Data_2017.xlsx'
OUT=WORK.TORONTOENERGY
DBMS=XLSX;
GETNAMES=NO
;
RUN;

/*Strip away the first few rows, since they are just text details and not
column headings.  Format the character columns to have sufficient width for
titles and labels.*/
DATA WORK.TORONTOENERGY;
  SET WORK.TORONTOENERGY;
  FORMAT G H I K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AI $40.;
  RETAIN G H I K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AI;
  ID = _N_;
  IF ID < 6 THEN DELETE;
RUN;

/*Set all columns to character variables for now, but this will change
later.  Sufficient character width will be needed for each column label. */
PROC SQL;
	ALTER TABLE WORK.TORONTOENERGY
		MODIFY 
		G varchar(40),
		H varchar(40),
		I varchar(40),
		K varchar(40),
		L varchar(40),
		M varchar(40),
		N varchar(40),
		O varchar(40),
		P varchar(40),
		Q varchar(40),
		R varchar(40),
		S varchar(40),
		T varchar(40),
		U varchar(40),
		V varchar(40),
		W varchar(40),
		X varchar(40),
		Y varchar(40),
		Z varchar(40),
		AA varchar(40),
		AB varchar(40),
		AC varchar(40),
		AD varchar(40),
		AE varchar(40),
		AI varchar(40)
		; 
QUIT;

/* Now set each column to its proper label based on the original
data */
PROC SQL;
	UPDATE WORK.TORONTOENERGY
	SET A = 'Operation_Name', B = 'Operation_Type',
	C = 'Address', D = 'City', E='Postal_Code',
	F = 'Total_Floor_Area', G = 'Unit_Area', H= 'AvgHrsperWeek',
	I = 'AnnualFlow_MegaLitres', J = 'Electricity_Quantity', K = 'Unit_Electricity',
	L = 'Natural_Gas_Quantity', M='Unit_Gas', N = 'QOils_1_and_2',
	O = 'Unit_Oil12', P = 'QOils_4_and_6', Q = 'Unit_Oil46', 
	R = 'Propane_Quantity', S = 'UnitPropane', T = 'Coal_Quantity', 
	U ='Unit_Coal', V = 'Wood_Quantity', W='Unit_Wood', X = 'District_Heating_Quantity',
	Y = 'Unit_Heat', Z= 'IsRenewableHeat', AA = 'IfYes_EmissionsFactorHeat', 
	AB = 'District_Cooling_Quantity', AC='Unit_Cool', AD='IsRenewableCool', 
	AE='IfYes_EmissionsFactorCool', AF = 'Total_GHG_Emissions_in_KG', 
	AG = 'Energy__ekWhPersqft', AH = 'Energy_ekWhPerMegaLitre',
	AI = 'Operation_ID', AJ = 'Comments' 
	WHERE ID = 8;
	;
QUIT;

/*Remove any remaining rows above the start of the column labels at this point*/
DATA WORK.TORONTOENERGY;
  SET WORK.TORONTOENERGY;
  IF ID < 8 THEN DELETE;
RUN;	

/*Create a new table of column names.  This section takes
the first observation from the table, which are string column names and puts
them into a column list of the names.  The VAR _all_ step lists all alphabetical
column names and labels associated with the more detailed string names for each
column.  The resulting table is similar to a dictionary, with alphabetical indices
and the corresponding titles for each variable. */
PROC TRANSPOSE DATA=WORK.TORONTOENERGY(obs=1) OUT=WORK.COLNAMES;
  VAR _all_;
RUN;

/*The ID column is missing as a result of the transpose, since it was
originally numeric, so this step adds the value 'ID' to the column with
the names of each variable.*/
PROC SQL;
UPDATE WORK.COLNAMES
SET COL1 ='ID'
WHERE _NAME_ = 'ID';
;
QUIT;


/*This section creates a global macro variable called rename.
In the first step, the catx step is used to assign the string variable
alphabetical name to the title of the actual column.  This is done
for each variable and the full string of variables is placed into a macro
variable called rename, from the table of column names. 
Each column name in the string is separated by a space.  No need to
print out the value of the macro variable.*/
PROC SQL noprint ;
  SELECT CATX('=',_name_,col1) 
    INTO :rename SEPARATED BY ' '
    FROM WORK.COLNAMES
  ;
QUIT;

/*View all current macro variables.  Shows structure
of macro variable just created.*/
%PUT _ALL_;

/*Here we can now rename all the columns to something that
makes more sense.  The first actual data observation is in row
2, but the rename option can be used with the character value
stored in the macro variable to rename all the columns.  The space
between each column name is crucial for this step to work.  */
DATA WORK.TORONTOENERGY;
  SET WORK.TORONTOENERGY (FIRSTOBS=2 RENAME=(&rename));
RUN;

/*Readjust the observation ID values to start at 1 in the 
first row of observations.   */
PROC SQL;
 UPDATE WORK.TORONTOENERGY
 SET ID = ID - 8;
 ;
QUIT;

/*For all the variables that are supposed to be numeric,
set them to numeric now with the proper format for each variable.*/
DATA WORK.TORONTOENERGY; 
	SET WORK.TORONTOENERGY;
	Total_Floor_Area_Num= INPUT(Total_Floor_Area, BESTD10.);
    RENAME Total_Floor_Area_Num=Total_Floor_Area;
    DROP Total_Floor_Area;
    
    AvgHrsperWeek_Num= INPUT(AvgHrsperWeek, BESTD5.);
    RENAME AvgHrsperWeek_Num = AvgHrsperWeek;
    DROP AvgHrsperWeek;
    
    AnnualFlow_MegaLitres_Num= INPUT(AnnualFlow_MegaLitres, BESTD12.5);
    RENAME AnnualFlow_MegaLitres_Num = AnnualFlow_MegaLitres;
    DROP AnnualFlow_MegaLitres;
    
    Electricity_Quantity_Num= INPUT(Electricity_Quantity, BESTD15.4);
    RENAME Electricity_Quantity_Num = Electricity_Quantity;
    DROP Electricity_Quantity;
    
    Natural_Gas_Quantity_Num= INPUT(Natural_Gas_Quantity, BESTD15.6);
    RENAME Natural_Gas_Quantity_Num = Natural_Gas_Quantity;
    DROP Natural_Gas_Quantity;
    
    QOils_1_and_2_Num= INPUT(QOils_1_and_2, BESTD2.);
    RENAME QOils_1_and_2_Num = QOils_1_and_2;
    DROP QOils_1_and_2;
    
    QOils_4_and_6_Num= INPUT(QOils_4_and_6, BESTD2.);
    RENAME QOils_4_and_6_Num = QOils_4_and_6;
    DROP QOils_4_and_6;
    
    Propane_Quantity_Num= INPUT(Propane_Quantity, BESTD2.);
    RENAME Propane_Quantity_Num = Propane_Quantity;
    DROP Propane_Quantity;
    
    Coal_Quantity_Num= INPUT(Coal_Quantity, BESTD2.);
    RENAME Coal_Quantity_Num = Coal_Quantity;
    DROP Coal_Quantity;
    
    Wood_Quantity_Num= INPUT(Wood_Quantity, BESTD2.);
    RENAME Wood_Quantity_Num = Wood_Quantity;
    DROP Wood_Quantity;
    
    District_Heating_Quantity_Num= INPUT(District_Heating_Quantity,BESTD8.5);
    RENAME District_Heating_Quantity_Num = District_Heating_Quantity;
    DROP District_Heating_Quantity;
    
    IfYes_EmissionsFactorHeat_Num= INPUT(IfYes_EmissionsFactorHeat,BESTD8.5);
    RENAME IfYes_EmissionsFactorHeat_Num = IfYes_EmissionsFactorHeat;
    DROP IfYes_EmissionsFactorHeat;
    
    District_Cooling_Quantity_Num= INPUT(District_Cooling_Quantity,BESTD8.5);
    RENAME District_Cooling_Quantity_Num = District_Cooling_Quantity;
    DROP District_Cooling_Quantity;
    
    IfYes_EmissionsFactorCool_Num= INPUT(IfYes_EmissionsFactorCool,BESTD8.5);
    RENAME IfYes_EmissionsFactorCool_Num = IfYes_EmissionsFactorCool;
    DROP IfYes_EmissionsFactorCool;
    
    Total_GHG_Emissions_in_KG_Num= INPUT(Total_GHG_Emissions_in_KG,BESTD12.);
    RENAME Total_GHG_Emissions_in_KG_Num = Total_GHG_Emissions_in_KG;
    DROP Total_GHG_Emissions_in_KG;
    
    Energy__ekWhPersqft_Num= INPUT(Energy__ekWhPersqft,BESTD12.1);
    RENAME Energy__ekWhPersqft_Num = Energy__ekWhPersqft;
    DROP Energy__ekWhPersqft;
    
    Energy_ekWhPerMegaLitre_Num= INPUT(Energy_ekWhPerMegaLitre,BESTD12.1);
    RENAME Energy_ekWhPerMegaLitre_Num = Energy_ekWhPerMegaLitre;
    DROP Energy_ekWhPerMegaLitre;  
RUN;

/*Export the data into a clean csv file, which is ready for analysis. */
PROC EXPORT DATA=WORK.TORONTOENERGY DBMS=CSV
OUTFILE='/folders/myfolders/SASData/Annual_Energy_Consumption_Data_2017.csv';
RUN;




