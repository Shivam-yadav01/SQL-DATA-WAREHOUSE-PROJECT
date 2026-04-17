-- segment product into cost range and count how many product fall into each segment
use datawarehouse;
with prod_cost as(select
p.product_key,
p.product_name as name,
f.sales_amount as cost
from gold_dim_product p
left join gold_fact_sales f
on p.product_key = f.product_key
where f.sales_amount is not null)
SELECT 
    CASE 
        WHEN cost < 100 THEN 'Below 100'
        WHEN cost BETWEEN 100 AND 500 THEN '100-500'
        WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
        ELSE 'Above 1000'
    END AS cost_range,
    COUNT(product_key) AS total_products
FROM prod_cost  -- or your specific table name
GROUP BY cost_range
ORDER BY total_products desc
;
-- Group customer in 3 segements based on their spending behaviour:
-- VIP: customer with at least 12 months spending history and spending more than 5000
-- Regular: customer with at least 12 months of history and spending 5000 or less
-- New: Customer with lifespan less than 12 months
-- and total number of customer by each group
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.sales_date) AS first_order_date,
        MAX(f.sales_date) AS last_order_date,
        TIMESTAMPDIFF(MONTH, MIN(f.sales_date), MAX(f.sales_date)) AS tenure_months
    FROM gold_dim_customers c
    LEFT JOIN gold_fact_sales f
        ON c.customer_key = f.customer_key
    GROUP BY c.customer_key
)
SELECT
    customers_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN tenure_months >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN tenure_months >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New Customer'
        END AS customers_segment
    FROM customer_spending
) AS t
GROUP BY customers_segment -- Group by the segment name, not the key!
ORDER BY total_customers DESC;

-- --/*
-- ===============================================================================
-- Product Report
-- ===============================================================================
-- Purpose:
--     - This report consolidates key product metrics and behaviors.

-- Highlights:
--     1. Gathers essential fields such as product name, category, subcategory, and cost.
--     2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
--     3. Aggregates product-level metrics:
--        - total orders
--        - total sales
--        - total quantity sold
--        - total customers (unique)
--        - lifespan (in months)
--     4. Calculates valuable KPIs:
--        - recency (months since last sale)
--        - average order revenue (AOR)
--        - average monthly revenue
-- ===============================================================================
-- */
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
-- IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
--     DROP VIEW gold.report_products;
-- GO

CREATE VIEW gold_report_products AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
    SELECT
	    f.order_number,
        f.sales_date,
		f.customer_key,
        f.sales_amount,
        f.sales_quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.product_cost
    FROM gold_fact_sales f
    LEFT JOIN gold_dim_product p
        ON f.product_key = p.product_key
    WHERE sales_date IS NOT NULL  -- only consider valid sales dates
),

product_aggregations AS (
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    product_cost,
timestampdiff(MONTH, MIN(sales_date), MAX(sales_date)) AS lifespan,
    MAX(sales_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(sales_quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(sales_quantity, 0)),1) AS avg_selling_price
FROM base_query

GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    product_cost
)

/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	product_cost,
	last_sale_date,
	timestampdiff(MONTH, last_sale_date, now()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Average Order Revenue (AOR)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,

	-- Average Monthly Revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue

FROM product_aggregations;

select * from gold_report_products;
