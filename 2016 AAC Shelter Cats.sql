/*Source:
	https://www.kaggle.com/code/residentmario/bagging-with-animal-shelter-outcomes/data
*/

SELECT * FROM cat_intake;
SELECT * FROM cat_outcomes;

/*
For the sake of this analysis, we won't need the cats' coat pattern on our
cat_intake table. Remove that column from the intake table. 
*/
ALTER TABLE cat_intake 
	DROP COLUMN coat_pattern;
SELECT * FROM cat_intake;

/*
Put the dates in which the cats were received at a shelter in order.
*/ 
SELECT * FROM cat_intake
	ORDER BY monthyear ASC;
    
/*
Which month in 2016 saw the most admissions to shelters? Do you see a trend 
in the months in which more pets are admitted? What may explain this?
*/
SELECT COUNT(monthyear),
	CASE
      WHEN monthyear LIKE "%-01-%" THEN "January"
      WHEN monthyear LIKE "%-02-%" THEN "February"
      WHEN monthyear LIKE "%-03-%" THEN "March"
      WHEN monthyear LIKE "%-04-%" THEN "April"
      WHEN monthyear LIKE "%-05-%" THEN "May"
      WHEN monthyear LIKE "%-06-%" THEN "June"
      WHEN monthyear LIKE "%-07-%" THEN "July"
      WHEN monthyear LIKE "%-08-%" THEN "August"
      WHEN monthyear LIKE "%-09-%" THEN "September"
      WHEN monthyear LIKE "%-10-%" THEN "October"
      WHEN monthyear LIKE "%-11-%" THEN "November"
      WHEN monthyear LIKE "%-12-%" THEN "December"
    END as "admission_month"
    FROM cat_intake
    GROUP BY "admission_month"
    Order by COUNT(*) DESC;
/*
July saw the highest admission of cats to Austin animal shelters (767 admissions). 
If you look at our generated table, you see that more cats were admitted to shelters 
in warmer months. This may be explained by the fact that cats tend to wander away 
from their homes in warmer months. Free roaming cats also tend to give birth in the 
spring/summer, resulting in more admissions of kittens to shelters. 
*/
 
/*
What percentage of cats admitted to shelters in 2016 were adopted?
What percentage were transferred to other shelters?
*/
SELECT outcome_type AS Outcome, 
	(COUNT(outcome_type) * 100 / (SELECT COUNT(*) FROM cat_outcomes)) AS Percentage
    FROM cat_outcomes
    WHERE outcome_type = "Adoption" OR outcome_type = "Transfer"
    GROUP BY outcome_type;
--46% of admitted cats were adopted
--42% of admitted cats were 

/*
Determine the months in which months the most cats were adopted.
Does it correspond with the months in which the most cats were admitted?
Do a join that includes only cats adopted in 2016!
*/
CREATE TABLE adoptions_numbers AS 
SELECT COUNT(outcome_month),
	CASE
      WHEN outcome_month IS "1" THEN "January"
      WHEN outcome_month IS "2" THEN "February"
      WHEN outcome_month IS "3" THEN "March"
      WHEN outcome_month IS "4" THEN "April"
      WHEN outcome_month IS "5" THEN "May"
      WHEN outcome_month IS "6" THEN "June"
      WHEN outcome_month IS "7" THEN "July"
      WHEN outcome_month IS "8" THEN "August"
      WHEN outcome_month IS "9" THEN "September"
      WHEN outcome_month IS "10" THEN "October"
      WHEN outcome_month IS "11" THEN "November"
      WHEN outcome_month IS "12" THEN "December"
    END as "adoption_month"
    FROM cat_outcomes
    WHERE outcome_type = "Adoption"
    GROUP BY "adoption_month"
    Order by COUNT(*) DESC;

SELECT * FROM adoptions_numbers;
     
CREATE TABLE admissions_numbers AS
SELECT COUNT(monthyear),
	CASE
      WHEN monthyear LIKE "%-01-%" THEN "January"
      WHEN monthyear LIKE "%-02-%" THEN "February"
      WHEN monthyear LIKE "%-03-%" THEN "March"
      WHEN monthyear LIKE "%-04-%" THEN "April"
      WHEN monthyear LIKE "%-05-%" THEN "May"
      WHEN monthyear LIKE "%-06-%" THEN "June"
      WHEN monthyear LIKE "%-07-%" THEN "July"
      WHEN monthyear LIKE "%-08-%" THEN "August"
      WHEN monthyear LIKE "%-09-%" THEN "September"
      WHEN monthyear LIKE "%-10-%" THEN "October"
      WHEN monthyear LIKE "%-11-%" THEN "November"
      WHEN monthyear LIKE "%-12-%" THEN "December"
    END as "admission_month"
    FROM cat_intake
    GROUP BY "admission_month"
    Order by COUNT(*) DESC;
    
ALTER TABLE adoptions_numbers
	RENAME COLUMN "COUNT(outcome_month)" TO "number_of_adoptions";

SELECT * FROM adoptions_numbers;

ALTER TABLE admissions_numbers
	RENAME COLUMN "COUNT(monthyear)" TO "number_of_admissions";

SELECT * FROM admissions_numbers;

SELECT * FROM admissions_numbers, adoptions_numbers;

ALTER TABLE admissions_numbers
ADD ID INTEGER IDENTITY(1, 1) PRIMARY KEY;

CREATE TABLE admissions AS
SELECT
        t.admission_month,
        t.number_of_admissions,
        ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS id
    FROM admissions_numbers AS t
    ORDER BY number_of_admissions DESC;

CREATE TABLE adoptions AS
SELECT
        t.adoption_month,
        t.number_of_adoptions,
        ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS id
    FROM adoptions_numbers AS t
    ORDER BY number_of_adoptions DESC;

SELECT * FROM admissions;
SELECT * FROM adoptions;

SELECT admissions.admission_month, admissions.number_of_admissions, adoptions.adoption_month, adoptions.number_of_adoptions 
	FROM admissions
	INNER JOIN adoptions
	ON admissions.id = adoptions.id
/*
From this table, we can see that the number of adoptions does not necessarily 
increase with the number of admissions. This is an issue because shelter 
are highly susceptible to overcrowding in summer months. Under conditions of 
overcrowding, shelters cannot provide efficient, effective, humane care
*/

/*
Which characteristics seem to increase a cat's chances for adoption?
*/

CREATE TABLE adopted_cats AS
SELECT * FROM cat_outcomes
	WHERE outcome_type = "Adoption";
    
SELECT * FROM adopted_cats;

CREATE TABLE percentage_adopted_by_age_group AS
SELECT age_upon_outcome AS Age_Upon_Adoption, 
	(COUNT(age_upon_outcome) * 100 / (SELECT COUNT(*) FROM adopted_cats)) AS Percentage
    FROM adopted_cats
    GROUP BY age_upon_outcome
    ORDER BY Percentage DESC; 
   
SELECT * FROM percentage_adopted_by_age_group;

SELECT SUM(Percentage)
	FROM percentage_adopted_by_age_group
	WHERE age_upon_adoption LIKE "%mon%";
--Cats aged <1 year made up 67% of all cats adopted in 2016. 

CREATE TABLE percentage_by_age_group AS
SELECT age_upon_outcome AS Age_Upon_Outcome, 
	(COUNT(age_upon_outcome) * 100 / (SELECT COUNT(*) FROM cat_outcomes)) AS Percentage
    FROM cat_outcomes
    GROUP BY age_upon_outcome
    ORDER BY Percentage DESC;
    
SELECT * FROM percentage_by_age_group;

SELECT SUM(Percentage)
	FROM percentage_by_age_group
	WHERE Age_Upon_Outcome LIKE "%mon%";
--Cats aged <1 year made up 42% of all cats admitted to shelters in 2016. 

CREATE TABLE admissions_by_color AS
SELECT color,
	(COUNT(color) * 100 / (SELECT COUNT(*) FROM cat_outcomes)) AS Percentage_Admitted
	FROM cat_outcomes
    GROUP BY color
    ORDER BY Percentage_Admitted DESC;

SELECT * FROM admissions_by_color;
--Brown and black cats are most commonly admitted to shelters. 

CREATE TABLE adoptions_by_color AS
SELECT color,
	(COUNT(color) * 100 / (SELECT COUNT(*) FROM adopted_cats)) AS Percentage_Adopted
	FROM adopted_cats
    GROUP BY color
    ORDER BY Percentage_Adopted DESC;

SELECT * FROM adoptions_by_color;

CREATE TABLE admissions_vs_adoptions AS
SELECT admissions_by_color.color, admissions_by_color.percentage_admitted, adoptions_by_color.percentage_adopted
	FROM admissions_by_color 
	INNER JOIN adoptions_by_color 
    ON admissions_by_color.color = adoptions_by_color.color;

SELECT * FROM admissions_vs_adoptions; 

SELECT color,
	CASE
      WHEN percentage_admitted > percentage_adopted THEN "lower"
      WHEN percentage_admitted < percentage_adopted THEN "higher"
      ELSE "same"
    END as "Adoption Rate Relative to Admission Rate"
    FROM admissions_vs_adoptions
    ORDER BY "Adoption Rate Relative to Admission Rate";
--Adopted at a higher rate than admitted: brown/white, calico, torbie, blue/white, cream/white
--Adpoted at a lower rate than admitted: brown, orange, white, seal
--The rest of the colors were adopted at the same rate as they were admitted.

CREATE TABLE percentage_adopted_by_sex AS
SELECT sex, (COUNT(sex) * 100 / (SELECT COUNT(*) FROM adopted_cats)) AS Percentage_Adopted
	FROM adopted_cats
    GROUP BY sex;
    
SELECT * FROM percentage_adopted_by_sex;

CREATE TABLE percentage_admitted_by_sex AS
SELECT sex, (COUNT(sex) * 100 / (SELECT COUNT(*) FROM cat_intake)) AS Percentage_Admitted
	FROM cat_intake
    GROUP BY sex;

SELECT * FROM percentage_admitted_by_sex;

SELECT percentage_admitted_by_sex.sex, percentage_admitted_by_sex.percentage_admitted, percentage_adopted_by_sex.percentage_adopted
	FROM percentage_admitted_by_sex
    JOIN percentage_adopted_by_sex
    ON percentage_adopted_by_sex.sex = percentage_admitted_by_sex.sex;
/*
Female cats were adopted at a slightly lower rate than they were admitted,
while male cats were adopted at a slightly higher rate than they were admitted.
*/

SELECT COUNT(sex) FROM cat_intake WHERE sex = "Female";
SELECT COUNT(sex) FROM cat_intake WHERE sex = "Male";

SELECT COUNT(sex) FROM adopted_cats WHERE sex = "Female";
SELECT COUNT(sex) FROM adopted_cats WHERE sex = "Male";
--3800 (57%) female cats in shelter; 1665 (53%) of them adopted
--2827 (42%) male cats in shelter; 1446 (46%) of them adopted
 
CREATE TABLE domestic_breed_percentage AS
SELECT domestic_breed,
	(COUNT(domestic_breed) * 100 / (SELECT COUNT(*) FROM cat_intake)) AS Percentage
	FROM cat_intake
    GROUP BY domestic_breed;

SELECT Percentage,
	CASE
    	WHEN domestic_breed = 0 then "False"
        WHEN domestic_breed = 1 then "True"
    END AS "Domestic breed?"
	FROM domestic_breed_percentage;
--95% of admitted cats were domestic breeds. 
--4% were not.
   
CREATE TABLE adopted_domestic_breed_percentage AS
SELECT domestic_breed,
	(COUNT(domestic_breed) * 100 / (SELECT COUNT(*) FROM adopted_cats)) AS Percentage
	FROM adopted_cats
    GROUP BY domestic_breed;

SELECT Percentage,
	CASE
    	WHEN domestic_breed = 0 then "False"
        WHEN domestic_breed = 1 then "True"
    END AS "Domestic breed?"
	FROM adopted_domestic_breed_percentage;	
--95% of adopted cats were domestic breeds. 
--4% were not.

/*
Status of domestication did not impact likelihood of adoption. 
*/

/*
What was the most popular day of the week for adoptions? 
Least popular?
*/

SELECT outcome_weekday,
	COUNT(outcome_weekday) AS "Total Adoptions"
    FROM adopted_cats
    GROUP BY outcome_weekday
    ORDER BY "Total Adoptions" DESC;
--Most popular day: Saturday (798 adoptions)
--Least popular day: Thursday (285 adoptions)
