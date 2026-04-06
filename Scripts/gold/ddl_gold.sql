/* 
created gold view prdouct
*/
use datawarehouse;
create view gold_dim_product as 
select
row_number() over(order by pn.prd_start_dt, pn.prd_key)as product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.cat as categor, 
pc.subcat as subcategory,
pc.maintenance as maintenance,
pn.prd_cost as product_cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date
-- pn.prd_end_dt
from silver_crm_prd_info pn
left join silver_erp_px_cat_g1v2 pc
on pn.cat_id = pc.id
where prd_end_dt = '';-- filter out all historical data
select * from gold_dim_product;
/* Fact_sales */
use datawarehouse;
create view gold_fact_sales as
select 
sd.sls_ord_num as order_number,
pr.product_key ,
cu.customer_key,
sd.sls_order_dt as sales_date,
sd.sls_ship_dt as ship_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as sales_quantity,
sd.sls_price from silver_crm_sales_details sd
left join gold_dim_product pr
on sd.sls_prd_key = pr.product_number
left join gold_dim_customers cu
on sd.sls_cust_id = cu.customer_id;
select * from gold_dim_product;
select * FROM silver_crm_sales_details;
/* product */
use datawarehouse;
create view gold_dim_product as 
select
row_number() over(order by pn.prd_start_dt, pn.prd_key)as product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.cat as categor, 
pc.subcat as subcategory,
pc.maintenance as maintenance,
pn.prd_cost as product_cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date
-- pn.prd_end_dt
from silver_crm_prd_info pn
left join silver_erp_px_cat_g1v2 pc
on pn.cat_id = pc.id
where prd_end_dt = '';-- filter out all historical data
select * from gold_dim_product;

