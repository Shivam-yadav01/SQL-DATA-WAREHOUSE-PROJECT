-- which 5 product generate highest revenue?
select 
* from 
(select 
p.product_name,
sum(f.sales_amount)as total_revenue,
Row_number() over(order by sum(f.sales_amount) desc) as rank_products
from gold_fact_sales f
left join gold_dim_product p 
on p.product_key = f.product_key
group by p.product_name
order by total_revenue desc)t
where rank_products <=5
 ;
 select 
* from 
(select 
p.product_name,
sum(f.sales_amount)as total_revenue,
rank() over(order by sum(f.sales_amount) desc) as rank_products
from gold_fact_sales f
left join gold_dim_product p 
on p.product_key = f.product_key
group by p.product_name
order by total_revenue desc)t
where rank_products <=5;
-- What are the worst performing products in terms of sales?
select 
p.product_name,
sum(f.sales_amount)as total_revenue
from gold_fact_sales f
left join gold_dim_product p 
on p.product_key = f.product_key
group by p.product_name
order by total_revenue ASC limit 5 
 ;
 -- which 3 best category revenue?
select 
p.subcategory,
sum(f.sales_amount)as total_revenue
from gold_fact_sales f
left join gold_dim_product p 
on p.product_key = f.product_key
group by p.subcategory
order by total_revenue desc limit 3
 ;
 