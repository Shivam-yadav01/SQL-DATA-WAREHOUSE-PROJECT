-- calculate the total sales per month
-- and the running total of sales over time
select
sales_date,
sales_amount
from gold_fact_sales;

SELECT 
 CAST(DATE_FORMAT(sales_date, '%Y-%m-01') AS DATE) AS order_date,
    SUM(sales_amount) AS total_sales
FROM gold_fact_sales
where sales_date is not null
GROUP BY order_date
;
WITH monthly_agg AS (
    SELECT 
        CAST(DATE_FORMAT(sales_date, '%Y-%m-01') AS DATE) AS order_date,
        SUM(sales_amount) AS total_sales,
        round(avg(sls_price),0) as avg_price
    FROM gold_fact_sales
    WHERE sales_date IS NOT NULL
    GROUP BY order_date
)
SELECT 
    order_date,
    total_sales,
avg(avg_price)OVER (ORDER BY order_date) AS running_avg_price,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_sales
FROM monthly_agg
ORDER BY order_date;