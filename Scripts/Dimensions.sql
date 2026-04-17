-- Data Exploration
use datawarehouse;
select distinct country from gold_dim_customers;
select distinct cntry from silver_erp_loc_a101;
-- How many sales of year are avaiable
select distinct category, subcategory, product_name from gold_dim_product order by 1,2,3;
select min(sales_date) as first_order_date,
max(sales_date)as last_order_date,
TIMESTAMPDIFF(month,min(sales_date),max(sales_date)) as order_range_months from gold_fact_sales;
-- Finding younger and older customer
select
min(birthdate)as oldest_cusotmer
,TIMESTAMPDIFF(YEAR, min(birthdate), CURRENT_DATE()) AS old_age,
max(birthdate) as youngest_customer, TIMESTAMPDIFF(YEAR, max(birthdate), CURRENT_DATE()) AS young_age
from gold_dim_customers;
