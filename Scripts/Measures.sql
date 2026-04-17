-- Measures
-- find the total sales
select sum(sales_amount) as total_sales from gold_fact_sales;
-- Find how many items are sold
select sum(sales_quantity) as total_quantity from gold_fact_sales;
-- Find avg selling price
select round(avg(sls_price),0) as total_quantity from gold_fact_sales;
-- find total number of orders
select count(order_number) as total_order from gold_fact_sales;
select count(distinct order_number) as total_order from gold_fact_sales;
-- find total number of products
select count(product_name)as total_products from gold_dim_product;
-- find total number of customers
select count(customer_key) as total_customer from gold_dim_customers;
select count(distinct customer_key) as total_customer from gold_dim_customers;
-- find total number of customers that placed order
select count(distinct customer_key) as total_customer_placed_order from gold_fact_sales;
-- Generating a report that shows all key metrics of the column
select 'total_sales' as measure_name, sum(sales_amount) as measure_value from gold_fact_sales
union all
select 'total_quantity' as measure_name, sum(sales_quantity) as measure_value from gold_fact_sales
union all
select 'Average Price', round(avg(sls_price),0) from gold_fact_sales
union all
select 'Total_order',count(distinct order_number) from gold_fact_sales
union all
select 'Total_products', count(product_name)from gold_dim_product
union all
select 'total_customer',count(distinct customer_key)  from gold_dim_customers
union all
select 'total_customer_placed_order', count(distinct customer_key)from gold_fact_sales;
