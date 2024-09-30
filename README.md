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


### 3. 
 
