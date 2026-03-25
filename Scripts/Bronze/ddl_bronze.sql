/* 
This code creates a bronze layer of the database.
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
This code is to written to import the data from csv file, for the first table I have written code to import, but for the others I tried importing with help of code it was showing error,
so, I used other option  "table wizard import" option to import the data. 
After inserting the data I made stored procedure to keep all the bronze layer table at one place.
------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/


LOAD DATA LOCAL INFILE '/tmp/cust_info.csv' 
INTO TABLE bronze_crm_cust_info 
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'  
-- TRY THIS: Back to standard Mac/Linux line endings
LINES TERMINATED BY '\n'  
IGNORE 1 ROWS 
(@v_id, @v_key, @v_first, @v_last, @v_marital, @v_gender, @v_date) 
SET      
    cst_id = NULLIF(TRIM(@v_id), ''),     
    cst_key = NULLIF(TRIM(@v_key), ''),     
    cst_firstname = NULLIF(TRIM(@v_first), ''),     
    cst_lastname = NULLIF(TRIM(@v_last), ''),     
    cst_marital = NULLIF(TRIM(@v_marital), ''),     
    cst_gender = NULLIF(TRIM(@v_gender), ''),     
    cst_create_date = NULLIF(TRIM(REPLACE(@v_date, '\r', '')), '');
    select * from bronze_crm_cust_info;
    select count(*) from bronze_crm_sales_details;
    select * from bronze_erp_cust_AZ12;
    drop table bronze_erp_cust_AZ12;
    drop table bronze_erp_Loc_A101;
    drop table bronze_erp_px_cat_G1V2;
    select * from bronze_erp_px_cat_G1V2;
    -- imported all the data
    DELIMITER //

CREATE PROCEDURE load_bronze()
BEGIN

select 'Loading Bronze Layer'as msg;
    SELECT * FROM bronze_crm_cust_info;
    SELECT * FROM bronze_crm_prd_info;
    SELECT * FROM bronze_crm_sales_details;
    SELECT * FROM bronze_erp_cust_az12;
    SELECT * FROM bronze_erp_loc_a101;
    SELECT * FROM bronze_erp_px_cat_g1v2;
    
END //

DELIMITER ;
CALL load_bronze();
