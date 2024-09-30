# Apple Store Sales Analysis Project

 ![Apple_Store](https://github.com/user-attachments/assets/24709f01-cf43-4577-91db-67621764a053)

Welcome to the Apple Store Sales Analysis project! This project focuses on analyzing extensive
sales data from Apple stores to uncover insights, trends, and patterns that can optimize
business strategies and operational efficiencies.


## Introduction

This project dives deep into analyzing over 1 million sales records from Apple stores. Through
SQL queries and data analysis techniques, we aim to extract valuable insights that can inform
decision-making and enhance business performance.


## Dataset Overview

The dataset contains detailed sales information from Apple stores, including sales dates,
product details, store locations, and revenue metrics. Prior to analysis, the dataset underwent
extensive preprocessing, including exploratory data analysis (EDA), feature engineering, and
creation of new indices and features like the day of sale and profit calculations based on product
and sales data joins.


## Analysis Questions Resolved

During the analysis, the project addressed the following key questions using SQL queries and
advanced data analysis techniques:

### 1. Identify the top-selling [top 3] products in each category

```sql
WITH TOP_PRODUCTS AS
(
SELECT p.category, p.product_id, p.product_name, SUM(s.total_sales) AS total_sales,
DENSE_RANK() OVER(PARTITION BY p.category ORDER BY SUM(s.total_sales) DESC) AS rank
FROM products as p
INNER JOIN sales as s
ON s.product_id = p.product_id
GROUP BY 1, 2, 3
ORDER BY p.category, total_sales DESC
)
SELECT * 
FROM TOP_PRODUCTS
WHERE rank <= 3;
```


### 2. Calculate the average revenue per store location.

```sql
SELECT st.country, st.city, ROUND(AVG(sl.total_sales)::numeric, 2) as Avg_revenue
FROM stores AS st
INNER JOIN sales AS sl
ON st.store_id = sl.store_id
GROUP BY 1, 2
ORDER BY 1, 2;
```


### 3. Analyze seasonal sales trends across different regions.
```sql
WITH CTE AS
(
SELECT st.country, TO_CHAR(sl.sale_date, 'Month') AS Month, SUM(sl.total_sales) as total_sales
FROM sales AS sl
INNER JOIN stores AS st
ON sl.store_id = st.store_id
GROUP BY 1, TO_CHAR(sl.sale_date, 'Month')
ORDER BY 1
)
SELECT * FROM CTE
ORDER BY country, EXTRACT(MONTH FROM TO_DATE(Month, 'Mon'));
```


### 4. Determine the profitability of each product category.
```sql
SELECT p.category, ROUND(SUM(s.total_sales::numeric - (s.quantity * p.cogs::numeric)), 2) as Profitability
FROM products AS p
INNER JOIN sales as s
ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 1;
```


### 5. Which products have not been sold at all?
```sql
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN sales s
ON p.product_id = s.product_id
WHERE s.product_id IS NULL;
```


### 6. How are stores ranked based on their performance?
```sql
SELECT st.store_id, st.store_name, st.country, SUM(sl.total_sales) AS total_sales, 
RANK() OVER(ORDER BY SUM(sl.total_sales) DESC) AS Stores_rank
FROM sales sl
INNER JOIN stores st
ON st.store_id = sl.store_id
GROUP BY 1,2,3
ORDER BY 5;
```


### 7. Identify stores with declining sales compared to the previous quarter.
```sql
WITH LAST_CTE AS
(
SELECT st.store_id, st.store_name, SUM(sl.total_sales) AS totals
FROM sales sl
INNER JOIN stores st
ON sl.store_id = st.store_id
WHERE sale_date BETWEEN DATE_TRUNC('Quarter', '2021-12-28'::date - INTERVAL '3 months')
AND (DATE_TRUNC('quarter', '2021-12-28'::date - INTERVAL '3 months') + INTERVAL '3 months - 1 day')
GROUP BY 1, 2
), 
CURRENT_CTE AS 
(
SELECT st.store_id, st.store_name, SUM(sl.total_sales) AS totals
FROM sales sl
INNER JOIN stores st
ON sl.store_id = st.store_id
WHERE sale_date BETWEEN DATE_TRUNC('quarter', '2021-12-28'::date)
AND (DATE_TRUNC('quarter', '2021-12-28'::date) + INTERVAL '3 months - 1 day')
GROUP BY 1, 2
)
SELECT c.store_id, c.store_name, COALESCE(c.totals, 0) AS current_quarter_sales, l.totals AS last_quarter_sales
from LAST_CTE AS l
LEFT JOIN CURRENT_CTE AS c
ON l.store_id = c.store_id
WHERE c.totals < l.totals
OR c.totals IS NULL;
```


### Calculate the profit margin percentage for each product.
```sql
SELECT s.product_id, 
ROUND(SUM((s.total_sales::numeric - (s.quantity * p.cogs::numeric))/NULLIF(s.total_sales::numeric, 0) * 100), 3) as profit_percentage
FROM sales AS s
INNER JOIN products p
ON p.product_id = s.product_id
GROUP BY 1
order by 1;
```


### 9. Evaluate yearly growth rate by revenue and profit of each country’s business
```sql
WITH CTE01 AS
(
SELECT st.country, 	EXTRACT(YEAR FROM sl.sale_date) AS year, SUM(sl.total_sales) as total_sales,
SUM(sl.total_sales::numeric - (sl.quantity*p.cogs::numeric)) as total_profit
FROM SALES sl
INNER JOIN stores st   
ON sl.store_id = st.store_id
INNER JOIN products p
ON p.product_id = sl.product_id
GROUP BY 1, 2
),
CTE02 
AS(
SELECT country, year, total_sales AS current_year_sales,
LAG(total_sales) OVER(PARTITION BY country ORDER BY year) as last_year_sales,
total_profit as current_year_profit,
LAG(total_profit) over(PARTITION BY country ORDER BY year) as last_year_profit
FROM CTE01
)
SELECT country, year, COALESCE(last_year_sales, 0) as last_year_sales, 
current_year_sales,
COALESCE(ROUND((current_year_sales::numeric - last_year_sales::numeric)/last_year_sales::numeric * 100, 3), 0) as sales_growth_ratio,
COALESCE(last_year_profit, 0) as last_year_profit,
current_year_profit, 
COALESCE(ROUND((current_year_profit - last_year_profit) / last_year_profit * 100, 3), 0) as profit_growth_ratio
FROM CTE02;
```

### 10. Identify geographical regions with the highest sales growth rate.
```sql
WITH CTE1 AS
(
SELECT st.country, EXTRACT(YEAR FROM sl.sale_date) AS year, SUM(total_sales) as totals
FROM sales sl
INNER JOIN stores st
ON sl.store_id = st.store_id
GROUP BY 1, 2
),
CTE2 AS
(
SELECT country, year, totals AS current_year_sales, 
LAG(totals) OVER(PARTITION BY country ORDER BY year) as last_year_sales
FROM CTE1
)
SELECT country, 
COALESCE(ROUND(SUM((current_year_sales::numeric - last_year_sales::numeric)/NULLIF(last_year_sales::numeric,0) * 100), 3), 0) AS Sales_growth_rate
FROM CTE2
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;
```



## Getting Started

To replicate the analysis or explore the dataset further, follow these steps:
1. Clone the repository to your local machine.
2. Set up a SQL environment (e.g., PostgreSQL, MySQL) to execute queries.
3. Load the provided dataset into your SQL database.
4. Execute the SQL queries provided in the repository to perform data analysis and derive
insights.
5. Customize queries as needed to address specific analytical objectives or questions.


## Conclusion

Through this project, we aim to provide actionable insights into Apple store sales performance,
customer behaviors, and operational efficiencies. By leveraging SQL and data analysis,
stakeholders can make informed decisions to optimize business strategies and drive growth.
Feel free to explore the repository, contribute to further analysis, or adapt the project for your
specific business needs!


## Notice

All data and analyses presented in this project are simulated and for educational purposes only.
Any resemblance to real data or entities is coincidental.
