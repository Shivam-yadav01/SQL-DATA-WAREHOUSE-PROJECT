-- Customer Report
-- Purpose
--    This report consolidates the customer key metircs and behaviours
-- Higlights
--    1. Gather essential details about customers such as names, age, transcation details
--    2. Segment into categories such (vip, regular, new) and age groups
--    3. Aggregates customer-level metrics
--       a. total orders
--       b. total sales
--       c. total quantity purchased 
--       d. total products
--       e. lifespan(in months)
-- 4. Calculate KPI 
--    recency (Months last order)
--    average order value
--    average monthly spend
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- 1. Retriving base column from the tables
create view   gold_report_customers as(
with base_query as(Select 
f.order_number,
f.product_key,
f.sales_date,
f.sales_amount,
f.sales_quantity,
c.customer_key,
 c.cusotmer_number,
-- c.last_name,
c.birthdate,
concat(c.first_name,'',c.last_name)as customer_name,
TIMESTAMPDIFF(year,c.birthdate, now())age
from gold_dim_customers c
left join gold_fact_sales f
on c.customer_key = f.customer_key
where sales_date is not null and  product_key is not null),
-- Customer aggreagtions: summarizes key metrics at customer level
customer_aggreation as(
select
customer_key,
-- cusotmer_number,
customer_name,
age,
count(distinct order_number) as total_orders,
sum(sales_amount) as total_sales,
sum(sales_quantity) as total_quantity,
count(distinct product_key) as total_products,
Max(sales_date) as last_order_date
from base_query
group by customer_key, customer_name, age)
select 
customer_key, customer_name, 
age,
case when age<20 then 'Under20'
when age between 20 and 29 then '20-29'
when age between 30 and 39 then '30-39'
else '40 and above'
end as age_group,

 total_orders,
total_sales,
total_quantity,
total_products,
last_order_date
last_order_date,
TIMESTAMPDIFF(month,last_order_date, now())as recency,
-- Compute average value
case when total_orders = 0 then 0
else total_sales/ total_orders
end as avg_order_value
-- compute average monthly spend

 --      CASE 
--             WHEN tenure_months >= 12 AND total_spending > 5000 THEN 'VIP'
--             WHEN tenure_months >= 12 AND total_spending <= 5000 THEN 'Regular'
--             ELSE 'New Customer'
--         END AS customers_segment
from customer_aggreation);

