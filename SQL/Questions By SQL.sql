use Toys_Store;

-- Some Exploration

--Total Revenue

SELECT 
	SUM(Product_Price*Units) AS Revenue
FROM 
	sales
JOIN 
	products 
ON
	sales.Product_ID=products.Product_ID



--Total Profit

SELECT 
	SUM((Product_Price - Product_Cost)*Units) AS Total_Profit
FROM 
	sales
JOIN 
	products 
ON
	sales.Product_ID=products.Product_ID



--Total Units Sold

SELECT 
	SUM(Units) AS Total_units_sold
FROM 
	sales



--Total Inventory

SELECT
	SUM(Stock_On_Hand) AS Stock
FROM 
	inventory



 --Inventory cost

SELECT 
	SUM(Product_Cost*stock_on_hand) AS inventory
FROM 
	inventory
JOIN 
	products 
ON
	inventory.Product_ID=products.Product_ID



--Most profitable product categories

SELECT
	product_category,
	ROUND(AVG((Product_Price - Product_Cost)*Units),2) AS avg_profit,
	SUM((Product_price-product_cost)*units) AS store_profit
FROM 
	sales
JOIN 
	products 
ON
	sales.Product_ID=products.Product_ID
GROUP BY
	product_category
ORDER BY 
	store_profit DESC



 ---The total sales for each month

SELECT 
    DATEPART(MONTH, Date) AS Sales_Month,  
    SUM(Product_Price * Units) AS Total_Sales    
FROM 
    sales
INNER JOIN 
    products ON sales.Product_ID = products.Product_ID
GROUP BY 
    DATEPART(MONTH, Date)                  
ORDER BY 
    Sales_Month
	


-- Top 5 Products by Units Sold

SELECT TOP 5
       products.Product_Name,
       products.Product_Category,
       SUM(sales.Units) AS Total_Units_Sold
FROM 
   sales
JOIN 
    products ON sales.Product_ID = products.Product_ID
GROUP BY
    products.Product_Name, products.Product_Category
ORDER BY 
    Total_Units_Sold DESC



-- Questions

---1 What are the total sales for each month?

SELECT 
	YEAR(DATE) AS Year, 
	MONTH(DATE) AS Month, 
	SUM(Product_Price * Units) AS revenue 
FROM 
	sales
JOIN
	products
ON
	sales.Product_ID = products.Product_ID
GROUP BY 
	YEAR(DATE), MONTH(DATE) 
ORDER BY 
	Year, Month


---2 How do sales vary across different product categories over time?

SELECT 
    products.Product_Category, 
    YEAR(sales.Date) AS year,
    MONTH(sales.Date) AS month, 
    SUM(sales.Units * products.Product_Price) AS total_sales
FROM 
	sales
JOIN 
	products 
ON 
	sales.product_id = products.Product_ID
GROUP BY 
	products.Product_Category, YEAR(sales.DATE), MONTH(sales.DATE)
ORDER BY 
	products.Product_Category ,year, month;



---3 What are the top 5 best-selling products overall?

SELECT TOP 5
    products.Product_Name, 
    SUM(sales.Units) AS total_units_sold
FROM 
	sales
JOIN 
	products 
ON 
	sales.Product_ID = products.Product_ID
GROUP BY 
	products.Product_Name
ORDER BY 
	total_units_sold DESC


---4 Which product had the highest sales in each store?

WITH cte AS (
SELECT 
    sales.store_id,
	stores.Store_Name,
    products.Product_Name, 
    SUM(sales.Units * products.Product_Price) AS total_sales
FROM 
	stores
JOIN
	sales
ON
	stores.Store_ID = sales.Store_ID
JOIN 
	products 
ON 
	sales.product_id = products.product_id
GROUP BY 
	sales.store_id, stores.Store_Name, products.product_name
),
cte2 AS (
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY store_id ORDER BY total_sales DESC) AS rank_no
FROM cte
)
SELECT 
	* 
FROM 
	cte2 
WHERE 
	rank_no = 1
ORDER BY 
	store_id, total_sales DESC



---5 Which store has the highest overall sales?

SELECT TOP 1
    sales.Store_ID, 
    SUM(sales.Units * products.Product_Price) AS total_sales
FROM sales
JOIN 
	products 
ON 
	sales.Product_ID = products.Product_ID
GROUP BY 
	sales.Store_ID
ORDER BY 
	total_sales DESC



---6 What is the average number of units sold per sale in each store?

SELECT 
    stores.Store_Name,  
    AVG(sales.Units) AS Avg_Units_Per_Sale  
FROM 
    sales
JOIN 
    stores ON sales.Store_ID = stores.Store_ID  
GROUP BY 
    stores.Store_Name  



---7 How does the average sale price vary between stores?

SELECT 
    stores.Store_Name,  
    AVG(products.Product_Price * sales.Units) AS Avg_Sale_Price  
FROM 
    sales
JOIN 
    products ON sales.Product_ID = products.Product_ID 
JOIN 
    stores ON sales.Store_ID = stores.Store_ID  
GROUP BY 
    stores.Store_Name;



---8 Which products have the highest and lowest stock levels currently?

-- Top 10 products
SELECT TOP 10
    inventory.Product_ID,
	products.Product_Name,
    SUM(inventory.Stock_On_Hand) AS Stocks
FROM 
    inventory
JOIN 
    products ON inventory.Product_ID = products.Product_ID
GROUP BY
	inventory.Product_ID,products.Product_Name
ORDER BY 
    Stocks DESC;

-- Lowest 10 products
SELECT TOP 10
    inventory.Product_ID,
	products.Product_Name,
    SUM(inventory.Stock_On_Hand) AS Stocks
FROM 
    inventory
JOIN 
    products ON inventory.Product_ID = products.Product_ID
GROUP BY
	inventory.Product_ID,products.Product_Name
ORDER BY 
    Stocks;



---9 Are there any products that are out of stock in any of the stores?

SELECT 
    products.Product_Name,  
    stores.Store_Name,  
    inventory.Stock_On_Hand  
FROM 
    inventory
JOIN 
    products ON inventory.Product_ID = products.Product_ID  
JOIN 
    stores ON inventory.Store_ID = stores.Store_ID
WHERE 
    inventory.Stock_On_Hand = 0  



---10 What is the average stock level for each product category?

SELECT 
    products.Product_Category, 
    AVG(inventory.Stock_On_Hand) AS Avg_Stock_Level  
FROM 
    inventory
JOIN 
    products ON inventory.Product_ID = products.Product_ID 
GROUP BY
    products.Product_Category;



---11 Do products with higher stock levels tend to sell more?

WITH cte AS (
SELECT 
	products.Product_ID, 
	products.Product_Name, 
	SUM(sales.Units) AS total_units
FROM 
    products
JOIN 
    sales 
ON 
	sales.Product_ID = products.Product_ID
GROUP BY
	products.Product_ID, products.Product_Name
)
SELECT 
	cte.Product_ID, 
	cte.Product_Name, 
	cte.Total_Units, 
	SUM(inventory.Stock_On_Hand) AS Stocks,
	ROW_NUMBER() OVER(ORDER BY total_units DESC)
FROM 
	cte
JOIN
	inventory
ON 
	cte.Product_ID = inventory.Product_ID
GROUP BY
	cte.Product_ID, cte.Product_Name, cte.Total_Units
ORDER BY
	Stocks DESC;

-- The query indicates that products with higher stock on hand generally sell more units, though there are likely other factors influencing sales. Products with low stock on hand tend to sell fewer units



---12 Which products have the highest sales during Black Friday?

--Top 10 Products sold in black Friday
SELECT 
	TOP 10 
	products.Product_Name, 
	SUM(products.Product_Cost*sales.Units) AS Total_Sales
FROM
	products
JOIN
	sales
ON
	products.Product_ID = sales.Product_ID
WHERE 
	(DATEPART(MONTH, sales.Date) = 11 AND DATEPART(DAY, sales.Date) = 25 AND DATEPART(YEAR, sales.Date) = 2022)
OR
	(DATEPART(MONTH, sales.Date) = 11 AND DATEPART(DAY, sales.Date) = 24 AND DATEPART(YEAR, sales.Date) = 2023)
GROUP BY
	products.Product_Name
ORDER BY
	Total_Sales DESC



---13 Which stores generated the highest total revenue during summer?

SELECT 
	stores.Store_Name, 
	SUM(sales.Units * products.Product_Price) AS total_revenue
FROM sales
JOIN 
	stores 
ON 
	sales.Store_ID = stores.Store_ID
JOIN 
	products 
ON 
	sales.Product_ID = products.Product_ID
WHERE 
	DATEPART(MONTH, sales.Date) IN (6, 7, 8)
GROUP BY 
	stores.Store_Name
ORDER BY 
	total_revenue DESC;



---14 How does the sales performance of each product category change over different quarters?

SELECT 
	products.Product_Category, 
	DATEPART(QUARTER, sales.Date) AS Quarter_Sales,
	SUM(sales.Units*products.Product_Cost) AS Total_Sales
FROM
	sales
JOIN
	products
ON
	sales.Product_ID = products.Product_ID
GROUP BY
	products.Product_Category, DATEPART(QUARTER, sales.Date)
ORDER BY
    products.Product_Category,
    Quarter_Sales

