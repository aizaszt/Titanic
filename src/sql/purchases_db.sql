
-- classification of onboard products by category and quantity 
SELECT "category", count("unit") AS "no"
FROM titanic_onboard_products top 
GROUP BY "category"
ORDER BY "no" DESC; -- Services:10 Shop:9 Bar:7 Kitchen:4 

-- classification of onboard products by subcategory and quantity 
SELECT "subcategory", count("unit"), sum("stock_qty") AS quantity
FROM titanic_onboard_products top 
GROUP BY "subcategory"
ORDER BY quantity DESC;

-- sold product number and total amount 
SELECT top."product_name", top."subcategory", sum("quantity") AS "quantity", sum("final_amount_1912_gbp") AS "Total_amount"
FROM titanic_purchases tp
JOIN titanic_onboard_products top ON tp."product_id"=top."product_id"
GROUP BY "product_name", top."subcategory"
ORDER BY "Total_amount" DESC; -- most profitable is "Champagne bottle" 1242,6753$;  less profitable is "Wireless Message" 4,562$ 

-- most profitable subcategory 
SELECT top."subcategory", sum("quantity") AS "quantity", sum("final_amount_1912_gbp") AS "Total_amount"
FROM titanic_purchases tp
JOIN titanic_onboard_products top ON tp."product_id"=top."product_id"
GROUP BY top."subcategory"
ORDER BY "Total_amount" DESC; -- Most profitable subcategory is "Alchol", less is "Accessories"

-- which part of titanic was most profitable 
SELECT "deck_location", sum("final_amount_1912_gbp") AS "total_amount"
FROM titanic_purchases tp 
JOIN titanic_onboard_products top ON tp."product_id"=top."product_id"
GROUP BY "deck_location"
ORDER BY "total_amount" DESC;  -- most profitable part is "Dining Saloon"

-- who was most prifitable passenger 
SELECT train."Name", sum("final_amount_1912_gbp") AS "total_amount"
FROM titanic_purchases tp 
JOIN train ON train."PassengerId"=tp."PassengerId"
GROUP BY "Name"
ORDER BY "total_amount" DESC; -- Most spending passenger is Mrs.Emil 31,186003$

--Какие товары лежали на складе (stock_qty) в огромном количестве, но их никто так и не захотел купить
SELECT 
    top.product_name, 
    top.stock_qty + COALESCE(sales.total_sold, 0) AS initial_stock,
    (top.stock_qty* 100)/ (top.stock_qty + COALESCE(sales.total_sold, 0)) AS not_sold
FROM titanic_onboard_products top
LEFT JOIN (
    SELECT product_id, SUM(quantity) as total_sold 
    FROM titanic_purchases 
    GROUP BY product_id
) sales ON top.product_id = sales.product_id
ORDER BY not_sold  DESC; -- Wireless Message per_word 95% is not sold 

--Совпадают ли списки тех, кто совершил крупную покупку в баре 14 апреля, со списками погибших?
SELECT 
    tp.purchase_datetime, 
    top.product_name, 
    tp.quantity, 
    t."Name", 
    t."Pclass",
    t."Survived"
FROM titanic_purchases tp
JOIN titanic_onboard_products top ON tp.product_id = top.product_id
JOIN train t ON tp."PassengerId" = t."PassengerId"
WHERE top.subcategory = 'Alcohol' AND tp.quantity>1
  AND tp.purchase_datetime BETWEEN  '1912-04-14 00:00:00' AND '1912-04-14 23:00:00'
ORDER BY tp.purchase_datetime; --First Class passengers had a privilege in survival, but alcohol may made them slow to react. They didn't realize the ship was in danger until it was too late.

--Если пассажир тратил на борту больше, чем стоил его билет были ли больше шансов выжить 
SELECT 
    t."Name",
    t."Pclass",
    t."Fare" AS ticket_price,
    t."Survived",
    SUM(tp.final_amount_1912_gbp) AS total_onboard_spent,
    COUNT(tp.purchase_id) AS number_of_purchases
FROM train t
JOIN titanic_purchases tp ON t."PassengerId" = tp."PassengerId"
GROUP BY t."Name", t."Pclass", t."Fare", t."Survived"
HAVING SUM(tp.final_amount_1912_gbp) > t."Fare"
ORDER BY total_onboard_spent DESC; -- more than fare mostly spent Staff and their survival rate was very low 

-- Есть ли те кто вооюше не тратили и смогли ли они выжить 
SELECT t."Name", t."Survived" 
FROM train t WHERE t."PassengerId" NOT IN (SELECT "PassengerId" FROM titanic_purchases);
SELECT COUNT(*) AS non_spending_passengers
FROM train
WHERE "PassengerId" NOT IN (
    SELECT DISTINCT "PassengerId" 
    FROM titanic_purchases 
    WHERE "PassengerId" IS NOT NULL); -- there is no passenger who did not spent 
-- насколько повлияло доход человека на его выживаемость 
WITH TotalFinancials AS (
    SELECT 
        t."PassengerId",
        t."Survived",
        (t."Fare" + COALESCE(SUM(tp.final_amount_1912_gbp), 0)) AS total_financial_power
    FROM train t
    LEFT JOIN titanic_purchases tp ON t."PassengerId" = tp."PassengerId"
    GROUP BY t."PassengerId", t."Survived", t."Fare"
)
SELECT 
    CASE 
        WHEN total_financial_power = 0 THEN '0. Free/Staff'
        WHEN total_financial_power < 10 THEN '1. Low (Under 10 GBP)'
        WHEN total_financial_power < 30 THEN '2. Medium (10-30 GBP)'
        WHEN total_financial_power < 100 THEN '3. High (30-100 GBP)'
        ELSE '4. Elite (100+ GBP)'
    END AS wealth_category,
    COUNT(*) AS passenger_count,
    ROUND(AVG("Survived") * 100, 2) AS survival_rate_pct
FROM TotalFinancials
GROUP BY 1
ORDER BY 1; -- Survival rate for Elite: 80,82% High:50% Medium:37% Low:18% It means their profit more effect than their class

-- насколько повлияло траты на борту на выжеваемость человека 
WITH Spending AS (
    SELECT 
        t."PassengerId",
        t."Survived",
        t."Pclass",
        SUM(tp.final_amount_1912_gbp) AS total_spent
    FROM train t
    JOIN titanic_purchases tp ON t."PassengerId" = tp."PassengerId"
    GROUP BY t."PassengerId", t."Survived", t."Pclass"
)
SELECT 
    CASE 
        WHEN total_spent < 1 THEN 'Low Spender (<1 GBP)'
        WHEN total_spent < 5 THEN 'Medium Spender (1-5 GBP)'
        WHEN total_spent < 20 THEN 'High Spender (5-20 GBP)'
        ELSE 'VIP Spender (20+ GBP)'
    END AS spending_group,
    COUNT(*) AS total_passengers,
    ROUND(AVG("Survived") * 100, 2) AS survival_rate_pct
FROM Spending
GROUP BY 1
ORDER BY 3 DESC; -- VIP Spender: 94,74% High Spender: 58% Medium: 33% Low: 15% Spendings on board also effected to survival rate 
-- менялись ли цены на продукты в зависимости от времени 
SELECT 
    top.product_name,
    COUNT(DISTINCT tp.unit_price_1912_gbp) AS price_count,
    MIN(tp.unit_price_1912_gbp) AS min_p,
    MAX(tp.unit_price_1912_gbp) AS max_p,
    MIN(tp.purchase_datetime) AS first_sale,
    MAX(tp.purchase_datetime) AS last_sale
FROM titanic_purchases tp
JOIN titanic_onboard_products top ON tp.product_id = top.product_id
GROUP BY top.product_name
HAVING COUNT(DISTINCT tp.unit_price_1912_gbp) > 1
ORDER BY price_count DESC; -- products price was not changed


-- те, кто платил «живыми деньгами», тратили меньше, чем те, кто записывал траты на счет
SELECT 
    payment_method,
    COUNT(*) AS transactions_count,
    AVG(final_amount_1912_gbp) AS avg_check,
    SUM(final_amount_1912_gbp) AS total_amount
FROM titanic_purchases
GROUP BY payment_method
ORDER BY total_amount DESC; -- total_amount almost same, so payment method does not effect to spendings 
