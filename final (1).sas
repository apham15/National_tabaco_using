filename webdat url "http://bigblue.depaul.edu/jlee141/econdata/health_data/NATS/nats_2013_finalcpl_6_weighted.csv";

proc import datafile=webdat out=NATS DBMS=csv replace;
run;

/*sorting the data set by strata variableS*/
proc sort data=NATS;
	by SMOKNOW SMOK100;
run;

/*splitting datasets into training (80%) and testing (20%)*/
proc surveyselect data=NATS method=srs seed=1981156 
		outall /*my student ID is 1981156*/
		samprate=0.8 out=INDATA;
	strata SMOKNOW SMOK100;
run;

data TRAIN; set INDATA;
	if selected=1;
run;

data TEST; set INDATA;
	if selected=0;
	SMOKSOMEDAY=.;
run;

/*Formats used in analysis*/
Proc Format;
	value AGEGR 
	1="18-24" 
	2="25-34" 
	3="35-44" 
	4="45-54" 
	5="55-64" 
	6="65+" 
	7="Unknown";
	
	value RACEET 
	1="White only, non-Hispanic" 
	2="Black  only, non-Hispanic" 
	3="Asian  only, non-Hispanic" 
	4="Native Hawaiian or Other PI only, non-Hispanic" 
	5="American Indian or Alaska Native only, non-Hispanic" 
	6="Other race only, non-Hispanic" 7="Multi-racial, non-Hispanic" 8="Hispanic" 
	9="Unknown";
	
	value GEN 
	1="MALE" 
	2="FEMALE";
	
	value EDUC 
	1="Less than high school diploma" 
	2="High School diploma or equivalent" 
	3="Some college or less than Bachelor degree" 
	4="Bachelor degree" 
	5="Postgraduate degree" 
	7="Unknown";
	
	value $STAT 
	"AK"="Alaska" 
	"AL"="Alabama" 
	"AR"="Arkansas" 
	"AZ"="Arizona" 
	"CA"="California" 
	"CO"="Colorado" 
	"CT"="Connecticut" 
	"DC"="District of Columbia" 
	"DE"="Delaware" 
	"FL"="Florida" 
	"GA"="Georgia" 
	"HI"="Hawaii" 
	"IA"="Iowa" 
	"ID"="Idaho" 
	"IL"="Illinois" 
	"IN"="Indiana" 
	"KS"="Kansas" 
	"KY"="Kentucky" 
	"LA"="Louisiana" 
	"MA"="Massachusetts" 
	"MD"="Maryland" 
	"ME"="Maine" 
	"MI"="Michigan"
	"MN"="Minnesota" 
	"MO"="Missouri" 
	"MS"="Mississippi"
	"MT"="Montana" 
	"NC"="North Carolina" 
	"ND"="North Dakota" 
	"NE"="Nebraska" 
	"NH"="New Hampshire" 
	"NJ"="New Jersey" 
	"NM"="New Mexico" 
	"NV"="Nevada" 
	"NY"="New York" 
	"OH"="Ohio" 
	"OK"="Oklahoma" 
	"OR"="Oregon" 
	"PA"="Pennsylvania" 
	"RI"="Rhode Island" 
	"SC"="South Carolina" 
	"SD"="South Dakota" 
	"TN"="Tennessee" 
	"TX"="Texas" 
	"UT"="Utah" 
	"VA"="Virginia" 
	"VT"="Vermont" 
	"WA"="Washington" 
	"WI"="Wisconsin" 
	"WV"="West Virginia" 
	"WY"="Wyoming";
	
	value CIG_BRAND 
	1="BASIC (BRANDED DISCOUNT)" 
	2="CAMEL" 
	3="DORAL (BRANDED DISCOUNT)" 
	4="KOOL" 5="MARLBORO GOLD" 
	6="MARLBORO MENTHOL" 
	7="MARLBORO RED" 
	8="MARLBORO (OTHER)" 
	9="NEWPORT BOX" 
	10="NEWPORT MENTHOL BLUE" 
	11="NEWPORT MENTHOL GOLD" 
	12="NEWPORT (OTHER)" 
	13="PALL MALL" 
	14="SALEM" 
	15="VIRGINIA SLIMS" 
	16="WINSTON" 
	66="DID NOT BUY ONE BRAND MOST OFTEN DURING THE PAST 30 DAYS" 
	88="DID NOT BUY ANY CIGARETTE DURING THE PAST 30 DAYS" 
	96="OTHER (SPECIFY)";
	
	value HARM 
	1="Not harmful" 
	2="Harmful" 
	3="Very harmful";
run;

Run;

/*Question 1*/
/*Data cleanning*/
Data Train_Data ; 
	Set TRAIN ;
   		If AGE < 0 then AGE = . ;
   		If SMOKPERDAY < 0 then SMOKPERDAY = . ; 
   		If SMOKPERDAY = 666 then SMOKPERDAY = 0 ;
		If GENDER < 0 then GENDER = . ;
		If AGEGRP_R < 0 then AGEGRP_R = . ;
		If Index(STATEFIPS,"-") > 0 Then STATEFIPS = "" ;
		If CIGBRAND < 0 Then CIGBRAND = . ;
		If INCOME2 < 0 Then INCOME2 = . ;
		If QUITCIGS< 0 Then QUITCIGS = . ;
		If COSTPACK2_R < 0 Then COSTPACK2_R = . ;
Run ;

/*1) The percentage of current smokers by race, gender, age group, education Level and geographic*/
proc freq data=Train_Data;
	tables RACEETHNIC GENDER AGEGRP_R EDUCA2_R STATEFIPS / 
		plots=freqplot(twoway=stacked orient=horizontal);
	Where SMOKSTATUS2_R=1;
	Format RACEETHNIC RACEET. GENDER GEN. AGEGRP_R AGEGR. EDUCA2_R 
		EDUC. STATEFIPS $STAT.;
Run;
/* Explaination*/
/*According to the graphs and statistical analysis:
-	Highest percentage (70.74) of current smokers are from white only non-Hispanic group
-	Highest percentage (50.34) of current smokers are females
-	Highest percentage (22.17) of current smokers are in 55-64 age group.
-	Highest percentage (34.36) of current smokers are from some college or less than bachelor’s degree group.
-	Highest percentage (7.30) of current smokers are California state.*/

/*2) Among the current smokers, who use e-cigarette? Answers by race, gender, age group, education level*/
proc freq data=Train_Data order=Freq;
	;
	tables RACEETHNIC GENDER AGEGRP_R EDUCA2_R / plots=freqplot(twoway=stacked orient=horizontal);
	Where SMOKSTATUS2_R=1 and CECIG=1;
	Format RACEETHNIC RACEET. GENDER GEN. AGEGRP_R AGEGR. EDUCA2_R EDUC.;
Run;

/* Explaination*/
/*According to the graphs and statistical analysis:
-	Highest percentage (75.35) of current smokers who use e cigarettes are from white only, non-Hispanic race group.
-	Highest percentage (50.08) of current smokers who use e cigarettes are from females.
-	Highest percentage (22.12) of current smokers who use e cigarettes are from 25-34 age category.
-	Highest percentage (39.14) of current smokers who use e cigarettes are from some college or less than bachelor’s degree group.*/

/*3) Among the current smokers, who use smokeless tobacco products? Answers by race, gender, age group, education level*/
proc freq data=Train_Data order=Freq;
	;
	tables RACEETHNIC GENDER AGEGRP_R EDUCA2_R / plots=freqplot(twoway=stacked orient=horizontal);
	Where SMOKSTATUS2_R=1 and CSMKLS=1;
	Format RACEETHNIC RACEET. GENDER GEN. AGEGRP_R AGEGR. EDUCA2_R EDUC.;
Run;

/* Explaination*/
/*According to the graphs and statistical analysis:
-	Highest percentage (77.47) of current smokers who use smokeless tobacco products are from white only non-Hispanic race group.
-	Highest percentage (92.46) of current smokers who use smokeless tobacco products are male.
-	Highest percentage (27.68) of current smokers who use smokeless tobacco products from 23-34 age category.
-	Highest percentage (38.41) of current smokers who use smokeless tobacco products from high school diploma or equivalent education category.*/

/*4) The mean and median cost per pack by state. The top three highest cost states and the lowest cost states*/
Proc sort data=Train_Data;
	By STATEFIPS;
Run;

Proc Summary data=Train_Data noprint;
	By STATEFIPS;
	Var COSTPACK2_R;
	Output out=COST (Where=(STATEFIPS ne "")) Mean=Mean_ Median=Median_;
Run;

Proc sort data=COST Out=HIGH_COST;
	By Desending Mean_;
Run;

Proc print Data=HIGH_COST (OBS=3);
Run;

Proc sort data=COST Out=LOW_COST;
	By Mean_;
Run;

Proc print Data=LOW_COST (OBS=3);
Run;

/* Explaination*/
/*According to the graphs and statistical analysis:
-	New York state has the highest mean cost and Massachusetts and Alaska are the other two states.
-	West Virginia state has the lowest mean cost and Kentucky and Georgia are the other two states.*/

/*5) The rank of the most popular brands by smokers including current and past smokers*/
proc freq data=Train_Data order=Freq;
	tables CIGBRAND / plots=freqplot(twoway=stacked orient=horizontal);
	Where SMOKSTATUS_R in (1 2 3);
	Format CIGBRAND CIG_BRAND.;
Run;
/* Explaination*/
/*According to the graphs and statistical analysis, if we not consider other variable, Marlboro (other) is the highest.*/


/*6) Who are the most conscious groups in the danger of smoking on health by race, gender, age group, and education level?*/
proc freq data=Train_Data order=Freq;
	tables RACEETHNIC*HARMCIG GENDER*HARMCIG AGEGRP_R*HARMCIG EDUCA2_R*HARMCIG / 
		plots=freqplot(twoway=stacked orient=horizontal);
	Where HARMCIG in (1 2 3);
	Format RACEETHNIC RACEET. GENDER GEN. AGEGRP_R AGEGR. EDUCA2_R EDUC. HARMCIG 
		HARM.;
Run;
/* Explaination*/
/*According to the graphs and statistical analysis:
-	White, only non-Hispanic group are more conscious about the health since they think smoking is very harmful to their health.
-	Females are more conscious about the health since they think smoking is very harmful to their health.
-	65+ age group more conscious about the health since they think smoking is very harmful to their health.
-	Some college or less than bachelor’s degree group more conscious about the health since they smoking is very harmful to their health*/


/*7)	Who quit smoking or intension to quit smoking by race, gender, age group, education level?*/
proc freq data=Train_Data order=Freq;
	tables RACEETHNIC GENDER AGEGRP_R EDUCA2_R / plots=freqplot(twoway=stacked orient=horizontal);
	Where QUITCOM=1 or QUITCIGS=1;
	Format RACEETHNIC RACEET. GENDER GEN. AGEGRP_R AGEGR. EDUCA2_R EDUC.;
Run;

/* Explaination*/
/*According to the graphs and statistical analysis:
-	White, only non-Hispanic group is more likely to quit smoking or intension to quit smoking
-	Male is more likely to quit smoking or intension to quit smoking
-	65+ age group is more likely to quit smoking or intension to quit smoking
-	Some college or less than bachelor’s degree group is more likely to quit smoking or intension to quit smoking*/


/*8) Suppose you are working as a consultant for Phillip Morris and promote the brand name "Marlboro".
Using descriptive analytics, find the best target group in terms of race, gender, and age group. Fully justify
your answers using graphs and descriptive statistics*/
proc freq data=Train_Data order=Freq;
	tables RACEETHNIC GENDER AGEGRP_R / plots=freqplot(twoway=stacked orient=horizontal);
	Where CIGBRAND in (5 6 7 8);
	Format RACEETHNIC RACEET. GENDER GEN. AGEGRP_R AGEGR.;
Run;

Proc Summary data=Train_Data print mean median std max min;
	Var RACEETHNIC GENDER AGEGRP_R;
	Where CIGBRAND in (5 6 7 8);
Run;

/* Explaination*/
/*According to the graphs and statistical analysis:
•	Lower Dummy race group (showing by dummies 1, 2, or 3) can be majority group who use Marlboro brand.
•	Lower dummy gender group (showing by dummies 1) can be majority group who use Marlboro brand.
•	Middle dummy age group (showing by dummies 3 or 4) can be majority group who use Marlboro brand.
•	White only, non-Hispanic group using Marlboro brand the most.
•	Male using Marlboro brand the most.
•	45-54 age group using Marlboro brand the most.
=>	So the best target group will be white only, non-Hispanic male population in 45 to 54 age category to promote.*/


/*Question 2*/
/*1)	Demographic clusters: Clusters by age, income group, and education level*/
/*Removing outliers for cluster analysis*/
PROC UNIVARIATE DATA=Train_Data NEXTROBS=5;
	VAR AGE INCOME2 EDUCA2_R;
RUN;

Data Train_Data1; set Train_Data;
	If AGE > 89 Then delete;
Run;

/*I. Hierarchical Clustering */
ods graphics on/ discretemax=44300 TIPMAX=88600 width=6in outputfmt=gif imagemap=on 
	imagename="cluster" border=off;
proc cluster data=Train_Data1 method=centroid out=cls1 print=7 ccc pseudo plots(maxpoints=595750);
	var AGE INCOME2 EDUCA2_R;
run;
ods graphics off;

/*Create Tree Data*/
proc tree data=cls1 noprint out=treecom ncl=5;
	copy AGE INCOME2 EDUCA2_R;
run;

/* II. Non-Hierarchical Clustering - K-Means */
/* K means */
proc fastclus data=Train_Data1 out=kmeancls2 maxclusters=5;
	var AGE INCOME2 EDUCA2_R;
run;

/*2) Test if the clusters are significant to the number of cigarettes smoked per day, and currently smoke or not*/
ods graphics on/ maxlegendarea=40 WIDTH= 3.5 in HEIGHT= 3.5in;
proc glm data=kmeancls2;
	class cluster SMOKSTATUS2_R SMOKPERDAY;
	model cluster=SMOKSTATUS2_R SMOKPERDAY;
	run;
	ods graphics off;
Quit;

/* Explaination*/
/*According to the statistic analysis and graph:
-	The hierarchical Clustering and cluster 3 for the non-hierarchical Clustering having most observation. 
-	If looked at the means of age, income and education level both having almost same values with age around 55, income category around 5 and education category around 3. As a result, those are the most important groups.*/

/*3) Based on the clusters who is the most important group to the tobacco companies*/
Proc summary print mean min max data=treecom;
	var AGE INCOME2 EDUCA2_R;
	class cluster;
Run;

Proc summary print mean min max data=kmeancls2;
	var AGE INCOME2 EDUCA2_R;
	class cluster;
Run;

/*Question 3*/
/*variables selected - AGE GENHEALTH QUITCIGS MARITAL2 RACE-variables (RACEMULTI1 - RACEMULTI5) - GENDER EMPLOY2 HARMCIG*/
/*Creating dummy variables where needed and do data cleanning for variables intent to use for regression*/
Data Train_Data2; set Train_Data;
Age_Square=AGE*AGE;

If GENHEALTH < 0 Then GENHEALTH=.; /*GENHEALTH - create binary dummy variables*/
If GENHEALTH ^=. Then do;	
	GENHEALTH_1=0; If GENHEALTH=1 Then GENHEALTH_1=1; 
	GENHEALTH_2=0; If GENHEALTH=2 Then GENHEALTH_2=1;
	GENHEALTH_3=0; If GENHEALTH=3 Then GENHEALTH_3=1;
	GENHEALTH_4=0; If GENHEALTH=4 Then GENHEALTH_4=1;
	End;

If QUITCIGS=2 Then QUITCIGS=0; /*QUITCIGS - make binary*/

If MARITAL2 < 0 Then MARITAL2=.; /*MARITAL2 - create binary dummy variables*/
If MARITAL2 ^=. Then do;
	MARITAL2_1 = 0 ; If MARITAL2 = 1 Then MARITAL2_1 = 1 ;
	MARITAL2_2 = 0 ; If MARITAL2 = 2 Then MARITAL2_2 = 1 ;
	MARITAL2_3 = 0 ; If MARITAL2 = 3 Then MARITAL2_3 = 1 ;
	MARITAL2_4 = 0 ; If MARITAL2 = 4 Then MARITAL2_4 = 1 ;
	MARITAL2_5 = 0 ; If MARITAL2 = 5 Then MARITAL2_5 = 1 ;
	MARITAL2_6 = 0 ; If MARITAL2 = 6 Then MARITAL2_6 = 1 ;
	End;

	If RACEMULTI1 < 0 Then RACEMULTI1 = . ; /*Race variables (RACEMULTI1 - RACEMULTI5  RACEMULTI6 to compare ) - Make binary*/
	If RACEMULTI2 < 0 Then RACEMULTI2 = . ;
	If RACEMULTI3 < 0 Then RACEMULTI3 = . ;
	If RACEMULTI4 < 0 Then RACEMULTI4 = . ;
	If RACEMULTI5 < 0 Then RACEMULTI5 = . ;
	If RACEMULTI1 = 2 Then RACEMULTI1 = 0 ;
	If RACEMULTI2 = 2 Then RACEMULTI2 = 0 ;
	If RACEMULTI3 = 2 Then RACEMULTI3 = 0 ;
	If RACEMULTI4 = 2 Then RACEMULTI4 = 0 ;
	If RACEMULTI5 = 2 Then RACEMULTI5 = 0 ;

	If GENDER = 2 Then GENDER = 0 ; /*GENDER - Make binary*/

	If EMPLOY2 < 0 Then EMPLOY2 = . ; /*EMPLOY2 - Make binary*/
    If EMPLOY2 = 2 Then EMPLOY2 = 0 ; 

	If HARMCIG < 0 Then HARMCIG = . ; /*HARMCIG - create binary dummy variables */
	If HARMCIG ^= . Then do ;
		HARMCIG_1 = 0 ; If HARMCIG = 2 Then HARMCIG_1 = 1 ;
		HARMCIG_2 = 0 ; If HARMCIG = 3 Then HARMCIG_2 = 1 ;
	End ;

Run ;

/*Creating scatter plots to examine relationship with the non binary variable*/
ods graphics on/ antialias=on antialiasmax=240800;
Proc sgscatter data = Train_Data;
	Plot SMOKPERDAY*(AGE) ;
Run ;
ods graphics off;

/*Explaination*/
/*According to the statistic analysis and graph: AGE can be used as nonlinear variable.*/

%Let indep_var =  GENHEALTH_1 GENHEALTH_2 GENHEALTH_3 GENHEALTH_4 QUITCIGS 
				  MARITAL2_1  MARITAL2_2  MARITAL2_3  MARITAL2_4  MARITAL2_5 MARITAL2_6 
				  RACEMULTI1 RACEMULTI2 RACEMULTI3 RACEMULTI4 RACEMULTI5 GENDER 
				  EMPLOY2 HARMCIG_1 HARMCIG_2 ;
				  
ods graphics on;
proc reg data=Train_Data2 plots(maxpoints=none) ;
	model SMOKPERDAY = &indep_var                            	;   output out=reg1  p=y1 ;
	model SMOKPERDAY = &indep_var  Age_Square Age              ;   output out=reg2  p=y2 ; 
	model SMOKPERDAY = &indep_var  / selection=stepwise      	;   output out=reg3  p=y3 ; 
	model SMOKPERDAY = &indep_var  / selection=adjrsq        	;   output out=reg4  p=y4 ; 
run ;
	ods graphics off;
Quit;

/*Explaination*/
/*According to the statistic analysis and graph:
-	Comparing above two models, MODEL 2 having higher adjusted R square. Hence, the model two is better than model 1. 
-	However, both having very low r squared values.*/

/* 2 out of sample forecasting results */
data All1; set reg1 reg2 reg3 reg4;
	e1=SMOKPERDAY - y1;
	e2=SMOKPERDAY - y2;
	e3=SMOKPERDAY - y3;
	e4=SMOKPERDAY - y4;
	mse1=(e1)**2;
	mse2=(e2)**2;
	mse3=(e3)**2;
	mse4=(e4)**2;
	rmse1=((e1)**2)**0.5;
	rmse2=((e2)**2)**0.5;
	rmse3=((e3)**2)**0.5;
	rmse4=((e4)**2)**0.5;
	mpe1=abs((e1)/SMOKPERDAY);
	mpe2=abs((e2)/SMOKPERDAY);
	mpe3=abs((e3)/SMOKPERDAY);
	mpe4=abs((e4)/SMOKPERDAY);
	mae1=abs(e1);
	mae2=abs(e2);
	mae3=abs(e3);
	mae4=abs(e4);
run;

proc means n mean data=all1 maxdec=4;
	var rmse: mse: mae: mpe:;
run;

ods graphics on/ antialias=on antialiasmax=240800;
ods layout gridded columns=2;
ods region;
proc sgplot data=all1;
	title 'Regular';
	scatter x=SMOKPERDAY y=y1;
run;
ods graphics off;
ods layout end;

ods graphics on/ antialias=on antialiasmax=240800;
ods layout gridded columns=2;
ods region;
proc sgplot data=all1;
	title 'Age_Square x Age';
	scatter x=SMOKPERDAY y=y2;
run;
ods graphics off;
ods layout end;

ods graphics / antialias=on antialiasmax=60195;
ods layout gridded columns=2;
ods region;
proc sgplot data=all1;
	title 'Stepwise Regression';
	scatter x=SMOKPERDAY y=y3;
run;
ods graphics off;
ods layout end;

ods graphics on/ antialias=on antialiasmax=240800;
ods layout gridded columns=2;
ods region;
proc sgplot data=all1;
	title 'Regression with Selected Variables';
	scatter x=SMOKPERDAY y=y4;
run;
ods graphics off;
ods layout end;

/*Explaination*/
/*According to the statistic analysis and graph:
1)	RMSE (root mean square error) - Model 2 is the best 
2)	MSE (mean square error) - Model 2 is the best
3)	MPE (mean percentage error) - Model 2 is the best
4)	MAE (mean absolute error) - Model 2 is the best*/

/*Question 4*/
/*variables selected - AGE INCOME2 EDUCA2_R GENDER RACEETHNIC GENHEALTH*/
Data Train_Data3 ; set Train_Data2 ;
	If SMOKNOW < 0 then SMOKNOW = . ; 
	If SMOKNOW in (1 2) Then SMOKE = 1 ;
	Else if SMOKNOW ^= . then  SMOKE = 0 ; 
Run ;

%Let indep_var =   GENHEALTH_1 GENHEALTH_2 GENHEALTH_3 GENHEALTH_4 
				  MARITAL2_1  MARITAL2_2  MARITAL2_3  MARITAL2_4  MARITAL2_5 MARITAL2_6 
				  RACEMULTI1 RACEMULTI2 RACEMULTI3 RACEMULTI4 RACEMULTI5 GENDER 
				  EMPLOY2 HARMCIG_1 HARMCIG_2  ;
				  
proc reg data=Train_Data3 ;
 model SMOKE = &indep_var                            	;   output out=reg1  p=y1 ;
 model SMOKE = &indep_var  Age_Square Age              ;   output out=reg2  p=y2 ; 
 model SMOKE = &indep_var  / selection=stepwise      	;   output out=reg3  p=y3 ; 
 model SMOKE = &indep_var  / selection=adjrsq        	;   output out=reg4  p=y4 ; 
run ;
Quit ;

/*Explaination*/
/*According to the statistic analysis and graph:
-	Comparing above two models, MODEL 2 having higher adjusted R square,. Hence, the model two is better than model 1. 
-	However, both having very low r squared values.*/

/*2 out of sample forecasting results */
data All2; set reg1 reg2 reg3 reg4;
	e1=SMOKE - y1;
	e2=SMOKE - y2;
	e3=SMOKE - y3;
	e4=SMOKE - y4;
	mse1=(e1)**2;
	mse2=(e2)**2;
	mse3=(e3)**2;
	mse4=(e4)**2;
	rmse1=((e1)**2)**0.5;
	rmse2=((e2)**2)**0.5;
	rmse3=((e3)**2)**0.5;
	rmse4=((e4)**2)**0.5;
	mpe1=abs((e1)/SMOKE);
	mpe2=abs((e2)/SMOKE);
	mpe3=abs((e3)/SMOKE);
	mpe4=abs((e4)/SMOKE);
	mae1=abs(e1);
	mae2=abs(e2);
	mae3=abs(e3);
	mae4=abs(e4);
run;

proc means n mean data=all2 maxdec=4;
	var rmse: mse: mae: mpe:;
run;

ods graphics on/ antialias=on antialiasmax=240800;
ods layout gridded columns=2;
ods region;
proc sgplot data=all2;
	title 'Regular';
	scatter x=SMOKE y=y1;
run;
ods graphics off;
ods layout end;

ods graphics on/ antialias=on antialiasmax=240800;
ods layout gridded columns=2;
ods region;
proc sgplot data=all2;
	title 'Age_Square x Age';
	scatter x=SMOKE y=y2;
run;
ods graphics off;
ods layout end;

ods graphics / antialias=on antialiasmax=240800;
ods layout gridded columns=2;
ods region;
proc sgplot data=all2;
	title 'Stepwise Regression';
	scatter x=SMOKE y=y3;
run;
ods graphics off;
ods layout end;

ods graphics on/ antialias=on antialiasmax=240800;
ods layout gridded columns=2;
ods region;
proc sgplot data=all2;
	title 'Regression with Selected Variables';
	scatter x=SMOKE y=y4;
run;
ods graphics off;
ods layout end;

/*Explaination*/
/*According to the statistic analysis and graph:
1)	RMSE (root mean square error) - Model 2 is the best
2)	MSE (mean square error) - Model 2 is the best 
3)	MPE (mean percentage error) - Model 2 is the best
4)	MAE (mean absolute error) - Model 2 is the best*/

/* logistic regression*/
ods noproctitle;
ods graphics / imagemap=on;

proc logistic data=TRAIN_DATA2 descending plots=effect plots=roc(id=prob) PLOTS(MAXPOINTS=NONE);
	class RACEETHNIC / param=effect;
	model smoktype / smokperday= RACEETHNIC / link=logit 
		technique=fisher
		selection=forward
		rule=single
        expb;
run;  

ods noproctitle;
ods graphics / imagemap=on;

proc logistic data=TRAIN_DATA2 descending plots=effect plots=roc(id=prob) PLOTS(MAXPOINTS=NONE);
	class gender / param=effect;
	model smoktype / smokperday= gender / link=logit 
		technique=fisher
		selection=forward
		rule=single
        expb;
run;  

ods noproctitle;
ods graphics / imagemap=on;

proc logistic data=TRAIN_DATA2 descending plots=effect plots=roc(id=prob) PLOTS(MAXPOINTS=NONE);
	class age / param=effect;
	model smoktype / smokperday= age / link=logit 
		technique=fisher
		selection=forward
		rule=single
        expb;
run; 

ods noproctitle;
ods graphics / imagemap=on;

proc logistic data=TRAIN_DATA2 descending plots=effect plots=roc(id=prob) PLOTS(MAXPOINTS=NONE);
	class income2 / param=effect;
	model smoktype / smokperday= income2 / link=logit 
		technique=fisher
		selection=forward
		rule=single
        expb;
run;

ods noproctitle;
ods graphics / imagemap=on;

proc logistic data=TRAIN_DATA2 descending plots=effect plots=roc(id=prob) PLOTS(MAXPOINTS=NONE);
	class educa2_r/ param=effect;
	model smoktype / smokperday= educa2_r / link=logit 
		technique=fisher
		selection=forward
		rule=single
        expb;
run;   

/* random forest */
proc hpforest data=train_data2 maxtrees=500 
								seed=1981156
								trainfraction=0.6
								alpha= 0.1
								maxdepth=50
								leafsize=6;
target SMOKPERDAY/level= binary;
input &indep_var/ level=nominal;
input &indep_var  Age_Square Age/ level=interval;
ods output fitstatistics = fitstats (rename=(Ntrees=Trees));
run;

data fitstats;
   set fitstats;
   label Trees = 'Number of Trees';
   label MiscAll = 'Full Data';
   label Miscoob = 'OOB';
run;

proc sgplot data=fitstats;
   title "OOB vs Training";
   series x=Trees y=MiscAll;
   series x=Trees y=MiscOob/lineattrs=(pattern=shortdash thickness=2);
   yaxis label='Misclassification Rate';
run;
title;
