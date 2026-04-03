use train database:

-- our targert data 
select * from train t;

-- uniqueness check
select t."PassengerId", COUNT(*)
from train t
group by t."PassengerId"
having  COUNT(*) > 1;
-- there s no duplicates, we can start

--how many passengers do we have?
select count(*) from train t; -- we have 891 passengers 

-- how many of them survieved?
SELECT count(*) from train where "Survived"=1 ; -- 342 of them survieved 

-- how many of survived passengers are female or male --
select count(*) from train t where t."Survived" =1  and t."Sex" = 'female'; --233 of survived passengers were female
select count(*) from train t where t."Survived" =1  and t."Sex" = 'male'; --109 of survived passengers were male

-- how many of the survived was in class 1,2,3
select count (*) from train t  where t."Pclass" = 1 and "Survived"=1; --136 of them class 1
select count (*) from train t  where t."Pclass" = 2 and "Survived"=1; -- 87 of them class 2 
select count (*) from train t  where t."Pclass" = 3 and "Survived"=1; --119 of them class 3 

--number of survived passengers by their port of embarkation 
select count(*) from train t where t."Survived" =1 and t."Embarked" = 'C'; --93 of them Cherbourg port 
select count(*) from train t where t."Survived" =1 and t."Embarked" = 'S'; --217 of them Southampton 
select count(*) from train t where t."Survived" =1 and t."Embarked" = 'Q'; -- 30 of them Queenstown

--number of passengers by port and female numbers 
select count(*) from train t where t."Embarked" = 'S'  and t."Sex" = 'female'; --644 passengers Southampton 203 female 
select count(*) from train t where t."Embarked" = 'C' and t."Sex" = 'female'; --168 passengers Cherbourg 73 female 
select count(*) from train t where t."Embarked" = 'Q' and t."Sex" = 'female'; -- 77 passengers Queenstown 36 female

--number of survived passengers by their port of embarktion and females numbers
select count(*) from train t where t."Survived" =1 and t."Embarked" = 'C' and t."Sex" = 'female'; --93 of them Cherbourg port 64 female
select count(*) from train t where t."Survived" =1 and t."Embarked" = 'S' and t."Sex" = 'female'; --217 of them Southampton 140 female
select count(*) from train t where t."Survived" =1 and t."Embarked" = 'Q' and t."Sex" = 'female'; --30 of them Queenstown 27 female 

--avarage age 
select AVG(t."Age") from train t; -- avarege age of all passengers is 29.69 
select AVG(t."Age") from train t where t."Survived" =1 ; --avarege age of all survived passengers is 28.34 
select AVG(t."Age") from train t where t."Survived" =1 and t."Sex" = 'male'; --avarege age of all passengers is 27.27
select AVG(t."Age") from train t where t."Survived" =1 and t."Sex" = 'female'; --avarege age of all passengers is 28.84

-- survived and sibling correlation
select count(*) from train t where t."Survived"=1 and t."SibSp"=0; -- 210 
select count(*) from train t where t."Survived"=1 and t."SibSp">0; -- 132


-- survived parent child corr 
select count(*) from train t where t."Survived"=1 and t."Parch"=0 ; --233
select count(*) from train t where t."Survived"=1 and t."Parch">0 ; --109 

-- survived child
select count(*) from train t where t."Survived"=1 and t."Age"<18;  -- 61 

select count(*) from train t where t."Survived"=1 and t."Age">50;  -- 22

select count(*) from train t where t."Survived"=1 and t."Age"<1;  -- 7 

select count(*) from train t where t."Survived"=1 and t."Age" between 18 and 50 and t."Sex"='male' --64 

select count(*) from train t where t."Survived"=1 and t."Age" between 18 and 50 and t."Sex"='female' --143 

select min(t."Age" ) from train t; -- 0.42 
select min(t."Age" ) from train t where t."Survived"=1; --0.42
select max(t."Age" ) from train t; --80 
select max(t."Age" ) from train t where t."Survived"=1; --80

select min(t."Age" ) from train t where t."Survived"=1 and t."Sex"='female'; -- 0,75 
select max(t."Age" ) from train t where t."Survived"=1 and t."Sex"='female'; --63 

select count (*) from train t where t."Fare" >10; -- 555 
select count (*) from train t where t."Survived" =1 and  t."Fare" >10; -- 275 

-- fare 

select count(*) from train t where t."Fare" >300; --3

select count(*) from train t where t."Fare" >200; --20 

select count(*) from train t where t."Fare" >100; --53 

select count(*) from train t where t."Fare" >50; --160 

select * from test 


