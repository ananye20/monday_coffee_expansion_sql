-- Follow images attached for more understanding of business problems and questions of MONDAY COFFEE EXPANSION

-- How many people in each city are estimated to consume coffee given that 25% of population does
-- Coffee consumer count

SELECT city_name, 
ROUND(population/1000000,2) as population_in_million, 
ROUND(population*0.25/1000000,2) as population_consuming_coffee_in_million,
city_rank
FROM city;

-- Total revenue generated across all cities in last quarter of 2023
-- Total revenue from coffee sales

SELECT SUM(total) as total_revenue
FROM sales
WHERE EXTRACT(QUARTER FROM sale_date)='4' AND EXTRACT(YEAR FROM sale_date)='2023';

-- For each city

SELECT city_name, SUM(total) as total_revenue
FROM sales S
JOIN customers CU
ON S.customer_id = CU.customer_id
JOIN city C
ON C.city_id = CU.city_id
WHERE EXTRACT(QUARTER FROM sale_date)='4' AND EXTRACT(YEAR FROM sale_date)='2023'
GROUP BY city_name
ORDER BY 2 DESC;

-- How many units of each product have been sold
-- Sales count for each product

SELECT product_name, COUNT(S.sale_id) as total_orders
FROM sales S
JOIN products P
ON S.product_id = P.product_id
GROUP BY 1
ORDER BY 2 DESC;

-- What is average sales amount per customer in each city
-- Average Sales amount per city

WITH cte as (SELECT CU.city_id, SUM(total)/COUNT(CU.customer_id) as avg_sales_amount_per_city
FROM customers CU
LEFT JOIN sales S
ON CU.customer_id = S.customer_id
GROUP BY 1)

SELECT city_name, avg_sales_amount_per_city
FROM cte CT
LEFT JOIN city C
ON CT.city_id = C.city_id
ORDER BY 2 DESC;

-- Provide the list of cities with their population and estimated consumers 
-- City Population and Coffee Consumers

SELECT city_name, ROUND(population*0.25/1000000,2) as coffe_consumers, 
COUNT(DISTINCT customer_id) as count_of_customers
FROM city C
LEFT JOIN customers CU
ON C.city_id = CU.city_id
GROUP BY 1,2;

-- Top 3 selling products for each city based on sales volume
-- Top selling Products by City

WITH cte as(SELECT *
FROM products P
LEFT JOIN sales S
ON P.product_id = S.product_id),

cc as (SELECT * 
FROM customers CU
LEFT JOIN cte CT
ON CU.customer_id = CT.customer_id),

sales_volume_c as (SELECT city_id, product_name, COUNT(sale_id) as sales_volume, 
RANK() OVER (PARTITION BY city_id ORDER BY COUNT(sale_id) DESC) as rnk
FROM cc
GROUP BY 1,2)

SELECT C.city_name, product_name, sales_volume, rnk as rank_of_product
FROM sales_volume_c SV
JOIN city C
ON SV.city_id = C.city_id
WHERE rnk<=3
ORDER BY 1, 3 DESC;

-- Unique customers in each city who have purchased coffee products
-- Customer Segmentation by City

SELECT city_name, COUNT(DISTINCT customer_id) as count_of_customers
FROM customers CU
JOIN city C
ON CU.city_id = C.city_id
GROUP BY city_name;

-- Find each city and their average sale per customer and avg rent per customer
-- Impact of estimated rent on sales

SELECT city_name, 
AVG(estimated_rent) as estimated_rent,
COUNT(DISTINCT S.customer_id) as total_cx,
ROUND(SUM(total):: NUMERIC/COUNT(DISTINCT CU.customer_id),2) as avg_sale_per_customer, 
ROUND(AVG(estimated_rent):: NUMERIC/COUNT(DISTINCT S.customer_id),2) as avg_rent_per_customer
FROM sales S
JOIN customers CU
ON S.customer_id = CU.customer_id
JOIN city C
ON C.city_id = CU.city_id
GROUP BY 1
ORDER BY 4 DESC;

-- Monthly Sales Growth/Decline
-- Sales growth rate: Calculate the percentage growth (or decline) in sales 
-- over different time periods (monthly) by each city

WITH sale_yr as (SELECT city_name, 
EXTRACT(MONTH FROM sale_date) as month, 
EXTRACT(YEAR FROM sale_date) as year,
SUM(total) as cr_month_sales,
LAG(SUM(total)) OVER (PARTITION BY city_name) as last_month_sales
FROM sales S
JOIN customers CU
ON S.customer_id = CU.customer_id
JOIN city C
ON CU.city_id = C.city_id
GROUP BY 1,2,3
ORDER BY 1,3,2)

SELECT *, 
ROUND((cr_month_sales-last_month_sales)::NUMERIC*100/last_month_sales ::NUMERIC,2) as growth_or_decline_percentage
FROM sale_yr
WHERE last_month_sales IS NOT NULL;

-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

SELECT city_name, SUM(total) as total_revenue,
SUM(estimated_rent) as total_rent,
COUNT(DISTINCT CU.customer_id) as total_customers,
ROUND((AVG(population) * 0.25)/1000000, 3) as estimated_coffee_consumer_in_millions
FROM sales S
JOIN customers CU
ON S.customer_id = CU.customer_id
JOIN city C
ON CU.city_id = C.city_id
GROUP BY 1
ORDER BY 2 DESC;

-- END OF QUERIES
