-- Analyse the yearly performance of the product by comparing their sales to both the avg sales performance
-- of the product and the previous year's sales
with yearly_product_sales as (
select
year(f.sales_date)as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold_fact_sales f
left join gold_dim_product p
on f.product_key = p.product_key
where p.product_name is not null
group by year(f.sales_date) , p.product_name)
select 
order_year,
product_name,
current_sales,
avg(current_sales) over(partition by product_name) as avg_sales,
current_sales - avg(current_sales) over(partition by product_name) as diff_avg,
case 
when current_sales - avg(current_sales) over(partition by product_name)>0 then 'Above avg'
when current_sales - avg(current_sales) over(partition by product_name)<0 then 'Below avg'
else 'avg'
end as avg_change,
-- year-over-year analysis
lag(current_sales) over(partition by product_name order by order_year) as py_sales,
current_sales - lag(current_sales) over(partition by product_name order by order_year)as diff_py,
case 
when current_sales - lag(current_sales) over(partition by product_name order by order_year)>0 then 'Increase'
when current_sales - lag(current_sales) over(partition by product_name order by order_year)<0 then 'decrease'
else 'No change'
end as py_change
from yearly_product_sales
order by product_name, order_year;
-- crazyyyyy bhaiii

