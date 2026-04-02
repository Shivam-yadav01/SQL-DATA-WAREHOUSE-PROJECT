/*  transformations: here are the transformations done to get or rectify the data bronze layer to get the silver layer */
*/
-- Bronze Layer 
use datawarehouse;
-- to remove the duplicates

select 
* from (select *, row_number() over (partition by cst_id order by cst_create_date desc)as flag_last
from bronze_crm_cust_info where cst_id is not null)t where flag_last = 1;
-- Data standardisation and consistency
select distinct cst_gender
from bronze_crm_cust_info;

-- Data standardisation and consistency
select distinct cst_marital
from bronze_crm_cust_info;
-- silver Layer
-- check for Unwanted spaces
-- expectation: no results
select cst_firstname
from silver_crm_cust_info 
where cst_firstname != trim(cst_firstname);
-- Data standardisation and consistency
select distinct cst_gender
from silver_crm_cust_info;
-- Data standardisation and consistency
select distinct cst_marital
from silver_crm_cust_info;
-- check for Unwanted spaces
-- expectation: no results
select cst_gender
from silver_crm_cust_info 
where cst_gender != trim(cst_gender);
-- check for Unwanted spaces
-- expectation: no results
select cst_lastname
from silver_crm_cust_info 
where cst_lastname != trim(cst_lastname);
-------------------- -------------------- -------------------- -------------------- -------------------- --------------------
-------------------- -------------------- -------------------- -------------------- -------------------- -------------------- 
/* Operations performed for prd info silver layer and checking the data */

-- Checking duplicates and nulls
select prd_id, count(*) from bronze_crm_prd_info group by prd_id having count(*)>1 or prd_id is null;
-- unwanted spaces
select prd_nm
from bronze_crm_prd_info
where prd_nm != trim(prd_nm);
-- check for negative or null values in prd_cost
select prd_cost
from bronze_crm_prd_info
where  prd_cost = '';
-- Data Standardisation
select distinct prd_line
from bronze_crm_prd_info;
-- check validity of date column
select * from bronze_crm_prd_info where prd_end_dt < prd_start_dt;
select prd_id, 
prd_key, 
prd_nm, 
prd_start_dt, 

date_sub(
lead(prd_start_dt) over(partition by prd_key order by prd_start_dt) , INTERVAL 1 DAY )as prd_end_dt
 from bronze_crm_prd_info-- calculate end date as one day before the next start date
;


-- checking quality of silver_crm_prd_info
-- unwanted spaces
select prd_nm
from silver_crm_prd_info
where prd_nm != trim(prd_nm);
-- check for negative or null values in prd_cost
select prd_cost
from silver_crm_prd_info
where  prd_cost = '';
-- Data Standardisation
select distinct prd_line
from silver_crm_prd_info;
-- check validity of date column
select * from silver_crm_prd_info where prd_end_dt < prd_start_dt;
--------------------  --------------------  --------------------  --------------------  --------------------  -------------------- 
--------------------  --------------------  --------------------  --------------------  --------------------  -------------------- 
/*  sls table transformation */
use datawarehouse;
-- in the table of sales we saw that the date column have integer as datatype so, we'll change it to date
select
sls_order_dt
from bronze_crm_sales_details
where sls_order_dt<= 0 or length(sls_order_dt) !=8;
-- checking for invalid date
select 
* from bronze_crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt;
-- checking Data Consistency: Between sales, quantity, and price
-- >> sales = Quantity*price
-- >> values must not be null, zero, or negative
select distinct
sls_sales as old_sls_sales,
sls_quantity,
sls_price,
case 
when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
then sls_quantity * abs(sls_price) 
else sls_sales
end as sls_sales,
case 
when sls_price is null or sls_price <= 0
then sls_sales/ nullif(sls_quantity,0)
else sls_price
end as sls_price

from bronze_crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <=0 or sls_quantity <=0 or sls_price <=0
order by sls_sales,sls_quantity,sls_price;
-------------------- -------------------- -------------------- -------------------- -------------------- -------------------- 
-------------------- -------------------- -------------------- -------------------- -------------------- --------------------
/*  
transformation to get the ERP_cust_az12
*/
select 
truncate silver_erp_cust_az12;
Insert into silver_erp_cust_az12(
cid,
bdate,
GEN
)
select
case when cid  like 'NAS%' THEN SUBSTRING(cid,4, length(cid))
else cid
end as cid,
case when 
bdate> curdate() then null
else bdate
end as bdate,
case when upper(trim(gen)) in ('F','Female') then 'Female'
when upper(trim(gen)) in ('M','male') then 'Male'
else 'N/a'
END AS GEN from bronze_erp_cust_az12 -- where
-- case when cid  like 'NAS%' THEN SUBSTRING(cid,4, length(cid))
-- else cid
-- end not in (select distinct cst_key from silver_crm_cust_info)
;
--------------------- --------------------- --------------------- --------------------- --------------------- --------------------- 
--------------------- --------------------- --------------------- --------------------- --------------------- --------------------- 
/*  sls table transformation */
use datawarehouse;
-- in the table of sales we saw that the date column have integer as datatype so, we'll change it to date
select
sls_order_dt
from bronze_crm_sales_details
where sls_order_dt<= 0 or length(sls_order_dt) !=8;
-- checking for invalid date
select 
* from bronze_crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt;
-- checking Data Consistency: Between sales, quantity, and price
-- >> sales = Quantity*price
-- >> values must not be null, zero, or negative
select distinct
sls_sales as old_sls_sales,
sls_quantity,
sls_price,
case 
when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
then sls_quantity * abs(sls_price) 
else sls_sales
end as sls_sales,
case 
when sls_price is null or sls_price <= 0
then sls_sales/ nullif(sls_quantity,0)
else sls_price
end as sls_price

from bronze_crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <=0 or sls_quantity <=0 or sls_price <=0
order by sls_sales,sls_quantity,sls_price;
--------------------- --------------------- --------------------- --------------------- --------------------- --------------------- 
--------------------- --------------------- --------------------- --------------------- --------------------- ---------------------
