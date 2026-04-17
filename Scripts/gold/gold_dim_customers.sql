use datawarehouse;
create view gold_dim_product as 
select
row_number() over(order by pn.prd_start_dt, pn.prd_key)as product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.cat as category, 
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
DROP VIEW gold_dim_product;