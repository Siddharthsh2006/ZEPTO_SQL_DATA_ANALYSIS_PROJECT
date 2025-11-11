-- SQL PROJECT 
-- TABLE CREATION

drop table if exists zepto;

create table zepto (
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock VARCHAR(10),	
quantity INTEGER
);
-- DATA EXPLORATION

-- COUNT NO OF ROWS
SELECT 
    COUNT(*)
FROM
    zepto;

-- SAMPLE DATA
SELECT 
    *
FROM
    zepto
LIMIT 10;

-- NULL VALUES
SELECT * FROM zepto
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

-- DIFFERENT PRODUCT CATEGORIES
SELECT 
    category
FROM
    zepto
GROUP BY category;

-- products in stock vs out of stock
SELECT 
    outOfStock, COUNT(sku_id)
FROM
    zepto
WHERE
    outOfStock = 'TRUE';
    
-- PRODUCT NAME PRESENT MULTIPLE TIMES 
SELECT 
    name, COUNT(sku_id) AS total_sku
FROM
    zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;

-- DATA CLEANING

-- products with price = 0
SELECT 
    *
FROM
    zepto
WHERE
    mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM zepto 
WHERE
    mrp = 0 OR discountedSellingPrice = 0;
    
-- CONVERT PAISE INTO RUPEES  
UPDATE zepto 
SET 
    mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;

-- DATA  ANALYSIS

-- Q1. Find the top 10 best-value products based on the discount percentage
SELECT 
   DISTINCT name, mrp, discountPercent
FROM
    zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- Q2.What are the Products with High MRP but Out of Stock
SELECT DISTINCT
    name, mrp
FROM
    zepto
WHERE
    mrp > 300 AND outOfStock = 'TRUE'
ORDER BY mrp DESC;

-- Q3.Calculate Estimated Revenue for each category
SELECT 
    category,
    SUM(discountedSellingPrice * quantity) AS total_revenue
FROM
    zepto
GROUP BY category
ORDER BY total_revenue DESC;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT 
    name, mrp, discountPercent
FROM
    zepto
WHERE
    mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC , discountPercent DESC;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
SELECT 
	category,ROUND(AVG(discountPercent),2) AS avg_discount
FROM 
	zepto 
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
SELECT 
    name,
    weightInGms,
    discountedSellingPrice,
    ROUND(discountedSellingPrice / weightInGms, 2) AS price_per_gram
FROM
    zepto
WHERE
    weightInGms > 100
ORDER BY price_per_gram DESC;

-- Q7.Group the products into categories like Low, Medium, Bulk.

SELECT DISTINCT
    name,
    weightInGms,
    CASE
        WHEN weightInGms < 1000 THEN 'Low'
        WHEN weightInGms < 5000 THEN 'Medium'
        ELSE 'Bulk'
    END AS weight_category
FROM
    zepto;
    
-- Q8.What is the Total Inventory Weight Per Category 
SELECT 
    category,
    SUM(weightInGms * availablequantity) AS total_weight
FROM
    zepto
GROUP BY category
ORDER BY total_weight;

-- Q9.For each product category, calculate the ratio of the Average Available Quantity for
-- products that have a high discount (discountPercent > 15) versus
-- those that have a low discount (discountPercent<=5).

WITH CategoryStockRatios AS (
    SELECT
        category,
        -- Average available quantity for highly discounted items (> 15%)
        AVG(CASE WHEN discountPercent > 15 THEN availableQuantity ELSE NULL END) AS AvgStock_HighDiscount,
        -- Average available quantity for low discounted items (<= 5%)
        AVG(CASE WHEN discountPercent <= 5 THEN availableQuantity ELSE NULL END) AS AvgStock_LowDiscount
    FROM
        zepto
    GROUP BY
        category
)
SELECT
    category,
    AvgStock_HighDiscount / AvgStock_LowDiscount AS DiscountStockRatio
FROM
    CategoryStockRatios
WHERE
    AvgStock_LowDiscount IS NOT NULL AND AvgStock_LowDiscount > 0
ORDER BY
    DiscountStockRatio DESC;

-- Q10.First, classify products into discount tiers as 'High Discount' if discountPercent > 20
-- 'Medium Discount' if discountPercent is between 10 and 20(inclusive)
-- 'Low Discount' if discountPercent<10.
-- Then, restrict the analysis to only the 'High Discount' tier and 
-- find the product category that has the lowest average available quantity 
-- among these highly discounted products.

WITH DiscountedTiers AS
(
	SELECT category,
    availableQuantity,
    CASE 
		WHEN discountPercent> 20 THEN 'High Discount' 
		WHEN discountPercent BETWEEN 10 AND 20 THEN 'Medium Discount' 
		WHEN discountPercent<10 THEN 'Low Discount' 
        ELSE 'Unknown'
	END AS DiscountTier 
	FROM 
		zepto 
)
SELECT 
	category,
    AVG(availableQuantity) AS AverageAvailableQuantity
FROM
    DiscountedTiers
WHERE
    DiscountTier = 'High Discount'
GROUP BY
    category
ORDER BY
    AverageAvailableQuantity ASC
LIMIT 1;


-- 					END				    --
