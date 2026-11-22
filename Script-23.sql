DROP TABLE  IF EXISTS  retial_sales;

CREATE TABLE retail_sales (
    transaction_id INT PRIMARY KEY,
    sale_date      DATE,
    sale_time      TIME,
    customer_id    INT,
    gender         VARCHAR(15),
    age            INT,
    category       VARCHAR(15),
    pirce_per_unit FLOAT,
    quantity       INT,
    cogs           FLOAT,
    total_sale     FLOAT
);

SELECT  * 
FROM 	retail_sales rs 
WHERE 	rs.transaction_id IS NULL 

==========================================================================

--  2    Data Cleaning 

==========================================================================
SELECT 	* 
FROM 	retail_sales rs 
WHERE 	rs.sale_date         IS NULL 
		OR rs.sale_time 	 IS NULL 
		OR rs.customer_id 	 IS NULL 
		OR rs.gender 		 IS NULL 
		OR rs.age 			 IS NULL 
		OR rs.category 		 IS NULL 
		OR rs.quantity 		 IS NULL 
		OR rs.price_per_unit IS NULL 
		OR rs.cogs 			 IS NULL 
		OR rs.total_sale     IS NULL 
	

		
-- Delate rows containing Null values or blank stirings 
-- in text columns
		
		
DELETE 	
		FROM 	retail_sales rs 
		WHERE 	rs.sale_date         IS NULL 
				OR rs.sale_time 	 IS NULL 
				OR rs.customer_id 	 IS NULL 
				OR rs.gender 		 IS NULL 
				OR rs.age 			 IS NULL 
				OR rs.category 		 IS NULL 
				OR rs.quantity 		 IS NULL 
				OR rs.price_per_unit IS NULL 
				OR rs.cogs 			 IS NULL 
				OR rs.total_sale     IS NULL 
				

-- Replace M with Male and F with Female

-- To check
SELECT DISTINCT gender
FROM retail_sales rs 

-- Replace M with Male

UPDATE retail_sales rs 
SET gender = 'Male'
WHERE rs.gender = 'M'

-- Replace F with Female

UPDATE retail_sales rs 
SET gender = 'Female'
WHERE rs.gender = 'F'

-- To check 2

SELECT 
		DISTINCT rs.gender 
FROM retail_sales rs 


================================================================================

-- 3 Data Analyisis And Business Questions

================================================================================


-- Questions 1  Sales on a Specific Date: Retrieve transactions made on November 5, 2022.

SELECT 	* 
FROM 	retail_sales rs 
WHERE 	rs.sale_date  = '2022-11-05'

-- Questions 2 Clothing Sales Analysis: Identify Clothing transactions with quantities greater than 2 during November 2022.

SELECT * 
FROM retail_sales rs 
WHERE rs.category = 'Clothing' 
		AND rs.quantity > 2 
		AND rs.sale_date >= '2022-11-01' 
		AND rs.sale_date < '2022-12-01'
		ORDER BY quantity DESC 
		
		
-- Questions 3 Sales Performance by Category: Calculate total sales revenue and transaction counts for each category.
		

SELECT 
		DISTINCT rs.category 
FROM retail_sales rs 


SELECT 
			rs.category,
			SUM(rs.total_sale)        AS Net_Sales,
			count(rs.transaction_id ) AS Total_orders
FROM retail_sales rs 
GROUP BY rs.category 

-- Questions 4 Customer Demographics: Calculate the average age of customers purchasing Beauty products.

SELECT 
		round(AVG(rs.age),2) avg_customer_age
FROM  	retail_sales rs 
WHERE 	rs.category = 'Beauty'

-- Questions 5 High-Value Transactions: Identify transactions with sales exceeding 1,000.

SELECT 		* 
FROM 		retail_sales rs 
WHERE 		rs.total_sale 	>= 1000
ORDER BY 	rs.total_sale  DESC 


-- Questions 6 Gender-Based Sales Analysis: Compare transaction counts by gender and product category

SELECT 
		rs.category,
		rs.gender, 
		count(rs.transaction_id ) 
FROM retail_sales rs  
GROUP BY gender, category

-- Questions 7 -- Monthly Sales Trends: Identify the best-selling month in each year based on total revenue.

WITH monthly_sales AS (
    SELECT EXTRACT(YEAR  FROM sale_date) AS year,
           EXTRACT(MONTH FROM sale_date) AS month,
           SUM(total_sale)               AS total_sale,
           RANK() OVER (
               PARTITION BY EXTRACT(YEAR FROM sale_date)
               ORDER BY SUM(total_sale) DESC
           ) AS rnk
    FROM   retail_sales
    GROUP BY 1, 2
)
SELECT *
FROM   monthly_sales
WHERE  rnk = 1;


-- Questions 8 -- Top Five Customers: Identify customers with the highest total spending.

SELECT 
			rs.customer_id,
			SUM(rs.total_sale ) AS total_sale 
FROM 		retail_sales rs 
GROUP BY 	customer_id 
ORDER BY  	total_sale 			DESC 
LIMIT 		5

-- Questions 9 -- Customer Analysis by Category: Calculate the number of unique customers purchasing from each category.

SELECT 
			rs.category,
			count(DISTINCT rs.customer_id) AS unique_customers
FROM 		retail_sales rs 
GROUP BY 	category
ORDER BY    unique_customers DESC 


-- Questions 10 -- Sales by Time Shift: Categorize transactions into Morning, Afternoon, and Evening shifts.

-- Morning: Before 12:00 PM
-- Afternoon: 12:00 PM to before 6:00 PM
-- Evening: 6:00 PM onward

SELECT 
			CASE 
				WHEN sale_time < '12:00:00' THEN 'MORNING'
				WHEN sale_time < '18:00:00' THEN 'AFTERNOON'
				ELSE 'EVENING'
			END AS shift ,
			count(*) AS total_orders
FROM 		retail_sales rs 
GROUP BY 	shift 
ORDER BY 	total_orders DESC 



		
		
		
		
		
		
		


