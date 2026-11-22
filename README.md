# Retial_sales_Analyisis_PostgreSql
# Retail Sales Analysis — SQL Project

An end-to-end SQL project that explores retail transaction data with **PostgreSQL**: database setup, data import, data cleaning, and 10 business questions answered with SQL.

## Project Overview

The analysis focuses on sales performance, product categories, customer behaviour, monthly revenue trends, and transaction timing. The results can support decisions on stock, staffing, and marketing.

**Tools:** PostgreSQL 18 · DBeaver · psql

## Repository Structure

```
├── retail_sales.csv                     # Raw dataset
├── retail_sales_analysis.sql            # All SQL: setup, cleaning, analysis
├── Retail_Sales_Analysis_Report.docx    # Full project report
└── README.md
```

## Dataset

Retail transactions from 2022–2023. After cleaning: **1,997 transactions**, total revenue **911,720**.

| Column | Type | Description |
|---|---|---|
| transaction_id | INT (PK) | Unique transaction ID |
| sale_date | DATE | Date of sale |
| sale_time | TIME | Time of sale |
| customer_id | INT | Customer ID |
| gender | VARCHAR(15) | Male / Female |
| age | INT | Customer age |
| category | VARCHAR(15) | Beauty, Clothing, Electronics |
| price_per_unit | FLOAT | Price per unit |
| quantity | INT | Units sold |
| cogs | FLOAT | Cost of goods sold |
| total_sale | FLOAT | Total sale amount |

## 1. Database Setup

```sql
CREATE TABLE retail_sales (
    transaction_id  INT PRIMARY KEY,
    sale_date       DATE,
    sale_time       TIME,
    customer_id     INT,
    gender          VARCHAR(15),
    age             INT,
    category        VARCHAR(15),
    price_per_unit  FLOAT,
    quantity        INT,
    cogs            FLOAT,
    total_sale      FLOAT
);
```

Data loaded with psql:

```sql
\copy retail_sales FROM 'C:/data/retail_sales.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
```

## 2. Data Cleaning

- Removed rows with missing values in any column.
- Standardized gender values: `M` → `Male`, `F` → `Female`.

```sql
DELETE FROM retail_sales
WHERE sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL
   OR gender IS NULL OR age IS NULL OR category IS NULL
   OR quantity IS NULL OR price_per_unit IS NULL
   OR cogs IS NULL OR total_sale IS NULL;

UPDATE retail_sales SET gender = 'Male'   WHERE gender = 'M';
UPDATE retail_sales SET gender = 'Female' WHERE gender = 'F';
```

## 3. Business Questions & Results

### Q1. Transactions on November 5, 2022
```sql
SELECT * FROM retail_sales WHERE sale_date = '2022-11-05';
```
**Result:** 11 transactions.

### Q2. Clothing transactions with quantity > 2 in November 2022
> The original question uses quantity > 10, but the maximum quantity in this dataset is 4, so the threshold was lowered to 2.
```sql
SELECT *
FROM   retail_sales
WHERE  category = 'Clothing'
  AND  quantity > 2
  AND  sale_date >= '2022-11-01'
  AND  sale_date <  '2022-12-01'
ORDER BY quantity DESC;
```
**Result:** 29 transactions.

### Q3. Total sales and orders by category
```sql
SELECT category,
       SUM(total_sale)       AS net_sales,
       COUNT(transaction_id) AS total_orders
FROM   retail_sales
GROUP BY category;
```
| Category | Net sales | Orders |
|---|---:|---:|
| Electronics | 313,810 | 684 |
| Clothing | 311,070 | 701 |
| Beauty | 286,840 | 612 |

### Q4. Average age of Beauty customers
```sql
SELECT ROUND(AVG(age), 2) AS avg_customer_age
FROM   retail_sales
WHERE  category = 'Beauty';
```
**Result:** 40.39

### Q5. High-value transactions (total_sale ≥ 1,000)
```sql
SELECT * FROM retail_sales
WHERE  total_sale >= 1000
ORDER BY total_sale DESC;
```
**Result:** 200+ transactions; the largest combine unit price 500 with quantity 4.

### Q6. Transactions by gender and category
```sql
SELECT category, gender, COUNT(transaction_id)
FROM   retail_sales
GROUP BY gender, category;
```
| Category | Female | Male |
|---|---:|---:|
| Beauty | 316 | 296 |
| Clothing | 348 | 353 |
| Electronics | 354 | 330 |

### Q7. Best-selling month in each year
```sql
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
SELECT * FROM monthly_sales WHERE rnk = 1;
```
| Year | Best month | Total sales |
|---|---|---:|
| 2022 | December | 72,880 |
| 2023 | December | 69,145 |

### Q8. Top 5 customers by total spending
```sql
SELECT customer_id, SUM(total_sale) AS total_sale
FROM   retail_sales
GROUP BY customer_id
ORDER BY total_sale DESC
LIMIT 5;
```
| Customer ID | Total spending |
|---:|---:|
| 3 | 38,440 |
| 1 | 30,750 |
| 5 | 30,405 |
| 2 | 25,295 |
| 4 | 23,580 |

### Q9. Unique customers per category
```sql
SELECT category, COUNT(DISTINCT customer_id) AS unique_customers
FROM   retail_sales
GROUP BY category
ORDER BY unique_customers DESC;
```
| Category | Unique customers |
|---|---:|
| Clothing | 149 |
| Electronics | 144 |
| Beauty | 141 |

### Q10. Orders by time shift
Morning: before 12:00 · Afternoon: 12:00–17:59 · Evening: 18:00 onward
```sql
SELECT CASE
           WHEN sale_time < '12:00:00' THEN 'MORNING'
           WHEN sale_time < '18:00:00' THEN 'AFTERNOON'
           ELSE 'EVENING'
       END      AS shift,
       COUNT(*) AS total_orders
FROM   retail_sales
GROUP BY shift
ORDER BY total_orders DESC;
```
| Shift | Orders | Share |
|---|---:|---:|
| Evening | 1,062 | 53.2% |
| Morning | 558 | 27.9% |
| Afternoon | 377 | 18.9% |

## Key Findings

- **Revenue:** 1,997 transactions generated 911,720; average order value 456.54.
- **Categories:** Electronics leads in revenue, Clothing in orders and unique customers, Beauty in average order value (468.69).
- **Customers:** women make slightly more purchases (1,018 vs 979); the average Beauty customer is about 40.
- **Loyalty:** the top 5 customers account for 16.3% of total revenue.
- **Seasonality:** December is the best month in both years.
- **Timing:** more than half of all transactions happen in the evening.

## Recommendations

- Increase stock and staff before December; start holiday campaigns in November.
- Focus staffing and promotions on evening hours.
- Introduce a loyalty programme for top-spending customers.
- Use cross-category offers, since customers buy across all categories.

## How to Run

1. Create a PostgreSQL database.
2. Run the `CREATE TABLE` script.
3. Load the CSV with `\copy`.
4. Run the cleaning queries, then the analysis queries in `retail_sales_analysis.sql`.

## Author

**Hamroali Safarov** — aspiring Data Analyst / Data Engineer
