-- which category contribute most to overall sales
with cat_sales as(select
p.category,
sum(f.sales_amount)as total_sales
from gold_dim_product p
left join gold_fact_sales f
on p.product_key = f.product_key
where f.sales_amount is not null group by p.category)
select 
category,
total_sales,
sum(total_sales) over () overall_sales,
concat(round((total_sales/sum(total_sales) over ())*100,2),'%')as percent_of_total
from cat_sales
order by total_sales desc;