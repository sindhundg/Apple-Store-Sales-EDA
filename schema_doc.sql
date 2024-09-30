-- Schema creation


CREATE TABLE products
(
	product_id INT PRIMARY KEY,	
	product_name VARCHAR(30),	
	category	VARCHAR(25),
	price	FLOAT,
	launched_price	FLOAT,
	cogs FLOAT
);


 
CREATE TABLE stores
(
	store_id INT PRIMARY KEY,	
	store_name	VARCHAR(35),
	country	VARCHAR(5),
	city VARCHAR(25)
);
 
ALTER TABLE stores
ALTER COLUMN country TYPE VARCHAR(15);
 

 
CREATE TABLE sales
(
	sale_id	INT PRIMARY KEY,
	store_id INT,	
	product_id	INT,
	sale_date DATE,	
	quantity INT,
	CONSTRAINT fk_sales_stores FOREIGN KEY (store_id) REFERENCES stores(store_id),
	CONSTRAINT fk_sales_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);
 
-- End of Schemas



-- Verification

SELECT * FROM products;
SELECT * FROM stores;
SELECT * FROM sales;


-- Adding a new column "total sales" in sales table

ALTER TABLE sales 
ADD COLUMN total_sales FLOAT;


-- Populating the column

UPDATE sales as s
SET total_sales = s.quantity * p.price
FROM products as p
WHERE s.product_id = p.product_id;

-- Verification

SELECT * FROM sales;