-- foreign key integrity (Dimension)
use datawarehouse;
select * from gold_fact_sales f
left join gold_dim_customers c
on c.customer_key = f.customer_key
left join gold_dim_product p
on p.product_key = f.product_key
 