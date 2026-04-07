

-- our targert data 
SELECT * FROM train t;

-- uniqueness check
select "PassengerId", COUNT(*)
FROM train t
GROUP BY "PassengerId"
HAVING  COUNT(*) > 1;
-- there s no duplicates, we can start

--how many passengers do we have?
SELECT count(*) FROM train t; -- we have 891 passengers 
-- how many of them survieved?
SELECT count(*) FROM train WHERE "Survived"=1 ; -- 342 of them survieved 
--Survivability rate 
SELECT AVG("Survived") * 100  FROM train ; --38.38%

-- passengers in 1st class  had a higher survival rate than those in 3rd class.
SELECT "Pclass", AVG("Survived") * 100 AS survival_percentage
FROM train
GROUP BY "Pclass"
ORDER BY "Pclass"; -- 1st class 62,96%; 2nd class 47.28%; 3rd class 24.23% 

--female passengers survived at a much higher rate than male passengers.
SELECT "Sex",  AVG("Survived") * 100 AS survival_percentage
FROM train 
GROUP BY "Sex" 
ORDER BY "Sex"; -- female: 74.20% ; male: 18.89% 

--Passengers under the age of 18 had higher survival rates  and over the age of 60 had the lowest survival rates
SELECT 
	CASE 
		WHEN "Age" < 13 THEN 'Kids'
        WHEN "Age" < 18 THEN 'Teenagers' 
        WHEN "Age" < 40 THEN 'Adults'   
        WHEN "Age" < 60 THEN 'Middle age'
        WHEN "Age" >= 60 THEN 'Elders'
        ELSE 'Unknown age'
	END AS "Age_Category",
	COUNT(*) AS total_passengers,
	AVG("Survived") * 100 AS survival_percentage 
FROM train 
GROUP BY 1
ORDER BY survival_percentage DESC; -- Kids: 57.97% ; Teenagers: 47.72% ; Midde age: 39.41% ; Adults:38.35% ; Unknown age: 29.27% ; Elders:26.92% 

--Passengers traveling with at least one family member (SibSp + Parch > 0) survived more often than those traveling alone.
SELECT 
	CASE 
		WHEN "Parch"+"SibSp" > 0 THEN 'With family member'
        WHEN "Parch"+"SibSp" < 0 THEN 'Alone'
	END AS "Traveling person numb",
	COUNT(*) AS total_passengers,
	AVG("Survived") * 100 AS survival_percentage 
FROM train 
GROUP BY 1
ORDER BY survival_percentage DESC;  --WITH FAMILY:50.56%  Alone:30% 

--Families with more than 4 members had lower survival rates because it was harder to coordinate and reach lifeboats together.
SELECT 
	CASE 
        WHEN "Parch"+"SibSp" > 4 THEN 'With 4 or more family member'
        ELSE 'Other'
	END AS "Traveling person numb",
	COUNT(*) AS total_passengers,
	AVG("Survived") * 100 AS survival_percentage 
FROM train 
GROUP BY 1
ORDER BY survival_percentage DESC; -- Others: 39.69% ; With 4 or more family members:14.89%

--Passengers who boarded at Cherbourg (Embarked = 'C') have a higher survival rate
SELECT 
	"Embarked",
	COUNT(*) AS total_passengers,
	AVG("Survived") * 100 AS survival_percentage
FROM train 
GROUP BY "Embarked"
ORDER BY survival_percentage DESC; -- Embarked = 'C': 55%  Embarked = 'Q':38.96%   Embarked = 'S': 33.69%   Empty:100%

--Survival status is more likely to be recorded for passengers with known ages than for those with missing (NULL) age values.
SELECT 
CASE 
	WHEN "Age" IS NOT NULL THEN 'with age'
	ELSE 'Null age'
END AS "Age:",
	COUNT(*) AS total_passengers,
	AVG("Survived") * 100 AS survival_percentage 
FROM train 
GROUP BY "Age:"
ORDER BY survival_percentage DESC; -- with age: 40.61% ; null age: 29.38% 

--Ticket price highly effected to be survived 
SELECT
    CASE 
        WHEN "Fare" = 0 THEN 'Staff'
        WHEN "Fare" <= 10 THEN 'Low cost'
        WHEN "Fare" <= 30 THEN 'Medium cost '
        WHEN "Fare" <= 100 THEN 'High cost' 
        ELSE '100+ Luxury'
    END AS fare_bracket,
    COUNT(*) AS total_passengers,
    ROUND(AVG("Survived") * 100, 2) AS survival_rate_pct
FROM train
GROUP BY 1 
ORDER BY MIN("Fare") ASC; -- Staff: 6.67%  Low cast:20.56%  Medium cost: 43.3%  High cost:53.59%  Luxury: 73.58%