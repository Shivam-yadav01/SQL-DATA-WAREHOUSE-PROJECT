select 
ci.cst_gender,
ca.gen,
case 
when ci.cst_gender != 'n/a' then ci.cst_gender  
else coalesce(ca.gen, 'n/a')
end as new_gen

from silver_crm_cust_info ci
left join silver_erp_cust_az12 ca
on  ci.cst_key = ca.cid
left join silver_erp_loc_a101 la
on ci.cst_key = la.cid; 
