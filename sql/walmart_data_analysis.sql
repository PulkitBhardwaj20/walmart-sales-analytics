-- Question 1: Find different payment method and number of transactions, number of qty sold
SELECT 
	payment_method,
    count(*),
    sum(quantity)
FROM walmart
GROUP BY payment_method;

-- Question 2: Identify the highest-rated category in each branch, displaying the branch, category and average rating

with category_ratings as (SELECT
	branch,
    category,
    AVG(rating) as avg_rating,
       RANK() OVER (
		PARTITION BY branch
        ORDER BY AVG(rating) DESC
	) AS rnk
FROM walmart
GROUP BY branch, category)

SELECT 
	branch,
    category,
    avg_rating
FROM category_ratings
WHERE rnk = 1;

-- Question 3: Identify the busiest weekday for each branch based on the number of transactions

WITH trns_cnt_by_date AS (SELECT
    branch,
    dayname(STR_TO_DATE(date, '%d/%m/%y')) AS weekday,
    COUNT(*) as trns_cnt,
    RANK() OVER(
			partition by branch
            order by count(*) DESC
            ) AS rnk
FROM walmart
GROUP BY branch, dayname(STR_TO_DATE(date, '%d/%m/%y')))

SELECT
	branch,
    weekday,
    trns_cnt,
    rnk
FROM trns_cnt_by_date
WHERE rnk = 1;

-- Question 4: Calculate the total quantity of items sold per payment method. List payment method total quantity

SELECT * FROM walmart;
SELECT 
	payment_method,
    sum(quantity) as qty
FROM walmart
GROUP BY payment_method
ORDER BY qty DESC;

-- QUESTION 5: Determine the average, minimum, and maximum rating of products for each city. List the city, average_rating, min_rating, and max_rating.

SELECT * FROM walmart;

SELECT 
	city,
    ROUND(avg(rating),1),
    min(rating),
    max(rating)
FROM walmart
GROUP BY city, category;

-- QUESTION 6: Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin). List category and total_profit, ordered from highest to lowest profit

SELECT * FROM walmart;
SELECT
	category,
    ROUND(SUM(total),1) as total_revenue, 
    ROUND(SUM(total*profit_margin),2)  as total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- QUESTION 7: Determine the most common payment method for each Branch. Display Branch and the preferred_payment_method.

SELECT * FROM walmart;

WITH preferred_payment_method AS (SELECT
	branch,
    payment_method,
    count(*) as payment_method_count,
    RANK() OVER(
			PARTITION BY branch
            ORDER BY count(*) DESC
            ) as rnk
FROM walmart
GROUP BY branch, payment_method)

SELECT 
	branch,
    payment_method,
    payment_method_count
FROM preferred_payment_method
WHERE rnk = 1;

-- QUESTION 8: Categorize sales into 3 group MORNING, AFTERNOON, EVENING. Find out each of the shift and number of invoices
SELECT * FROM walmart;

SELECT
	branch,
	CASE
		WHEN str_to_date(time, '%H:%i:%s') < '12:00:00' THEN 'MORNING'
        WHEN str_to_date(time, '%H:%i:%s') < '18:00:00' THEN 'AFTERNOON'
        ELSE 'EVENING'
	END AS shift,
    count(*) as number_of_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY number_of_invoices DESC;

-- QUESTION 9: Identify 5 branch with highest decrese ratio in revenue compared to last year(current year 2023 and last year 2022)

SELECT * FROM walmart;

WITH rev_2023 as (SELECT
	branch,
    sum(total) as cr_rev
FROM walmart
WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) = 2023
GROUP BY branch),

rev_2022 as (SELECT
	branch,
    sum(total) as ls_rev
FROM walmart
WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) = 2022
GROUP BY branch)

SELECT
	*,
    ROUND(((ls_rev-cr_rev)/ls_rev*100),2) as rev_dec
FROM rev_2023
JOIN rev_2022
USING (branch)
WHERE ls_rev>cr_rev
ORDER BY rev_dec DESC LIMIT 5
