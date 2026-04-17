use datawarehouse;
select
year(sales_date),
sum(sales_amount) as total_sales,
count(distinct customer_key)as total_customers,
sum(sales_quantity) as total_quantity
from gold_fact_sales
group by year(sales_date)
order by year(sales_date)
;
-- By month
select
year(sales_date) as order_year,
month(sales_date)as order_month,
sum(sales_amount) as total_sales,
count(distinct customer_key)as total_customers,
sum(sales_quantity) as total_quantity
from gold_fact_sales
group by year(sales_date), month(sales_date)
order by year(sales_date),month(sales_date)
;
-- date truncate
select
CAST(DATE_FORMAT(sales_date, '%Y-%m-01') AS DATE) AS order_date,
month(sales_date)as order_month,
sum(sales_amount) as total_sales,
count(distinct customer_key)as total_customers,
sum(sales_quantity) as total_quantity
from gold_fact_sales
group by 1,2
order by order_date
;
