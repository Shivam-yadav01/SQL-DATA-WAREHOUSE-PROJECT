use datawarehouse;
create view gold_dim_customers as
select 
row_number() over (order by cst_id) as customer_key,
ci.cst_id as customer_id,
ci.cst_key as cusotmer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
la.cntry as country,
ci.cst_marital as marital_status,
ca.bdate as birthdate,
ci.cst_create_date as create_date,

case 
when ci.cst_gender != 'n/a' then ci.cst_gender  
else coalesce(ca.gen, 'n/a')
end as gender

from silver_crm_cust_info ci
left join silver_erp_cust_az12 ca
on  ci.cst_key = ca.cid
left join silver_erp_loc_a101 la
on ci.cst_key = la.cid; 