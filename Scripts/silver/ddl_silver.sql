/*  
silver_crm_cust_info
*/
use datawarehouse;
-- checking for nulls or duplicates in primary key
-- expectation: no result
select cst_id ,count(*) from bronze_crm_cust_info group by cst_id having count(*)>1 or cst_id is null;

-- check for Unwanted spaces
-- expectation: no results
select cst_firstname
from bronze_crm_cust_info 
where cst_firstname != trim(cst_firstname);
-- check for Unwanted spaces
-- expectation: no results
select cst_lastname
from bronze_crm_cust_info 
where cst_lastname != trim(cst_lastname);
-- check for Unwanted spaces
-- expectation: no results
select cst_gender
from bronze_crm_cust_info 
where cst_gender != trim(cst_gender);
-- in case you see any unwanted spaces, you can use trim() 
-- function example trim(cst_lastname) it will remove unwanted spaces.
-- Widening the 'pipes' so 'Married' (7 chars) and 'Female' (6 chars) can pass through
-- inserting into the silver layer
TRUNCATE TABLE silver_crm_cust_info;
ALTER TABLE silver_crm_cust_info 
MODIFY COLUMN cst_marital VARCHAR(20),
MODIFY COLUMN cst_gender VARCHAR(20);
insert into silver_crm_cust_info(
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital,
cst_gender,
cst_create_date

 )
select 
cst_id, cst_key, cst_firstname, cst_lastname, 
case 
when upper(trim(cst_marital)) = 'S' then 'Single'
when upper(trim(cst_marital)) = 'M' then 'Married'
else 'n/a'
end as cst_marital,-- Normalise marital status values to readable format
case 
when upper(trim(cst_gender)) = 'F' then 'Female'
when upper(trim(cst_gender)) = 'M' then 'Male'
else 'n/a'
end as cst_gender, -- Normalise gender status values to readable format
cst_create_date  
from (select *, row_number() over (partition by cst_id order by cst_create_date desc)as flag_last
from bronze_crm_cust_info where cst_id is not null)t where flag_last = 1;-- select most recent records per customer
select * from silver_crm_cust_info;
-- -- -- -- -- -- -- -- --------------------  ----------  --------------------  -------------------- --------------------
-------------------- -------------------- -------------------- -------------------- -------------------- --------------------
/*  transformations: here are the transformations done to get or rectify the data bronze layer to get the silver layer */
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
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
/* prd_info  silver table  after the transformation */
use datawarehouse;
truncate table silver_crm_prd_info;
insert into silver_crm_prd_info(
prd_id,

cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)
select 
prd_id,
Replace(substring(prd_key,1,5),'-','_')as cat_id,-- extracted the category id
substring(prd_key,7, length(prd_key))as prd_key,-- extracted the prodcut key
prd_nm,
CASE 
        WHEN prd_cost IS NULL OR TRIM(prd_cost) = '' THEN 0 
        ELSE prd_cost 
    END AS 
prd_cost,
case when upper(trim(prd_line))= 'M' then 'mountain'
when upper(trim(prd_line)) = 'R' then 'Road'
when upper(trim(prd_line)) = 'S' then 'Other Sales'
when upper(trim(prd_line)) = 'T' then 'Touring'
else 'n/a'
end as
prd_line,-- map product line to descriptive values
prd_start_dt,
prd_end_dt
from bronze_crm_prd_info;
select * from silver_crm_prd_info;
ALTER TABLE silver_crm_prd_info 
MODIFY COLUMN cat_id VARCHAR(50) AFTER prd_key;
-------------------------------------------------------- -------------------------------------------------------- --------------------------------------------------------
-------------------------------------------------------- -------------------------------------------------------- --------------------------------------------------------
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
--------------------- --------------------- --------------------- --------------------- --------------------- --------------------- 
--------------------- --------------------- --------------------- --------------------- --------------------- --------------------- 
/*  sales table  silver table after the operations done in the table sls_details */
use datawarehouse;
truncate table silver_crm_sales_details;
insert into silver_crm_sales_details(
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_quantity,
sls_sales,
sls_price
)
select 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_quantity,
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
from bronze_crm_sales_details ;
-- where sls_ord_num != trim(sls_ord_num);-- to check any for any spaces in this column
-- where sls_prd_key not in(select
-- prd_key from silver_crm_prd_info
-- ) ; -- checking the integrity of the prd_key from prd_info
-- where sls_cust_id not in(select
-- cst_id from silver_crm_cust_info
-- ) ; -- checking the integrity of the cust_id form crm_cust_info
-- checked these three columns seem great, so we don't have to do any transformation for this.
select count(*) from silver_crm_sales_details;
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
/*  erp_cust_az12  silver layer */
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
/*  erp_loc_a101 */
use datawarehouse;
truncate silver_erp_loc_a101;
insert into silver_erp_loc_a101(
cid,
cntry
)
select
replace(cid,'-','')cid,
case when trim(cntry) = 'DE' then 'Germany'
when trim(cntry) in('us', 'usa') then 'United State'
when trim(cntry) ='' or cntry is null then 'n/a'
else trim(cntry)
end as cntry 
from bronze_erp_loc_a101 ;
-- where replace(cid,'-','') not in (select cst_key from silver_crm_cust_info);
-- data standardisation and consistency
select distinct cntry
from bronze_erp_loc_a101 order by cntry;
 -- cntry as old_cntry,
select * from silver_erp_loc_a101;
/* Everything is covered in this code only */
--------------------- ---------------------  ---------------------  ---------------------  ---------------------  --------------------- 
--------------------- ---------------------  ---------------------  ---------------------  ---------------------  --------------------- 
/* erp_px_cat_g1v2  this code includes data transformations too */
select
id,
cat,
subcat,
maintenance from bronze_erp_px_cat_g1v2;
-- checking unwanted spaces
select * from bronze_erp_px_cat_g1v2 
where cat != trim(cat) or 
subcat != trim(subcat) or 
maintenance != trim(maintenance);
-- data consistency
select distinct cat from bronze_erp_px_cat_g1v2;
select distinct subcat from bronze_erp_px_cat_g1v2;
select distinct maintenance from bronze_erp_px_cat_g1v2;
--------------------- --------------------- --------------------- --------------------- --------------------- --------------------- 
--------------------- --------------------- --------------------- --------------------- --------------------- --------------------- 
/* As I have made the stored procedure earlier, now I'm calling here so as to see the whole silver layer */
call load_sliver;
--------------------- --------------------- --------------------- --------------------- --------------------- ---------------------
--------------------- --------------------- --------------------- --------------------- --------------------- --------------------- 


