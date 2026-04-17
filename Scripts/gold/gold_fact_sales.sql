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