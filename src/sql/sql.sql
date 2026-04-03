use train DATABASE:

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
