
------*******Objectives******

------Normalize data and create relationships between tables using foreign keys
------Upon initial inspection of the data, we can start thinking of some questions about it that we would want to answer.
---1. What is the overall sales and profit trend ?
---2. Which are the Top 10 products by sales ?
---3. Which are the most and least Selling Products ?
---4. Which is the most preferred Shipping Mode ?
---5. Which are the Most Profitable Category and Sub-Category ?
---6. Who are the customers that attract the most profit ?
---7. What item was mostly sold in each year ?
---8. Top 10 items that bring in the most profit yearly ?
---9. What is the overall monthly and daily order trend ?
--10. What country do most customers come from ?




------SOLUTION
--Load existing data into sql by creating table and declaring the features with their data types.

CREATE TABLE main_table
(
    order_id character varying(256) not null,
    order_date date,
    ship_date date,
    ship_mode character varying(256)  ,
    customer_name character varying(256) not null ,
    segment character varying(256) ,
    state character varying(256)  ,
    country character varying(256) not null,
    market character varying(256) ,
    region character varying(256) ,
    product_id character varying(256) not null ,
    category character varying(256),
    sub_category character varying(256),
    product_name character varying(256),
    sales numeric not null,
    quantity integer,
	discount numeric,
	profit numeric not null,
	shipping_cost numeric,
	order_priority character varying(256),
	year integer
);

select * from main_table

alter table main_table 
add column customer_id serial,
add column ship_id serial,    
add column sales_id serial,
add column ord_id serial;


----Create tables from MAIN_TABLE while declaring the features with their data types.
----Normalize data and create relationships between tables using foreign keys


----CREATING ORDERS TABLE
create table orders
(
	ord_id int,
    sales_id int,
    order_date date,
    order_priority varchar(225),
    discount numeric,
    quantity int,
    primary key (ord_id)
      
);

alter table orders
add constraint fk_orders foreign key (sales_id) references sales(sales_id);

insert into orders (ord_id, sales_id, order_date, order_priority, discount, quantity)
select ord_id, sales_id, order_date, order_priority, discount, quantity from main_table;


-----CREATE SHIPMENT TABLE
create table shipment
(
    ship_id int,
    ord_id int,
    ship_mode varchar(225),
    ship_date date,
    shipping_cost numeric,
	primary key (ship_id),
    foreign key (ord_id) references orders(ord_id)
);

insert into Shipment (ship_id, ord_id, ship_mode, ship_date, shipping_cost)
select ship_id, ord_id, ship_mode, ship_date, shipping_cost from main_table;



------CREATE CUSTOMERS TABLE
create table customers
(
    customer_id int,
    ord_id int,
    customer_name varchar(225) not null,
    segment varchar(225) not null,
    country varchar(225) not null,
	primary key (customer_id)
);


alter table customers
add constraint fk_customers foreign key (ord_id) references orders(ord_id);

insert into customers (customer_id, ord_id, customer_name, segment, country)
select customer_id, ord_id, customer_name, segment, country from main_table;




--CREATE SALES TABLE
create table sales
(
    sales_id int,
    ord_id int,
    prod_id int,
    sales numeric,
    year int,
    profit numeric,
    primary key (sales_id),
    foreign key (ord_id) references orders(ord_id)
    
);
insert into sales (sales_id, ord_id, prod_id, sales, year, profit)
select sales_id, ord_id, prod_id, sales, year, profit from main_table;



---CREATING CATEGORY TABLE 

create table category
(
    category_id int,
    ord_id int,
    sales_id int,
    category varchar(225),
    sub_category varchar(225),
    primary key (category_id),
    foreign key (ord_id) references orders(ord_id),
    foreign key (sales_id) references sales(sales_id)
    
);
insert into category (category_id, ord_id, sales_id, category, sub_category)
select category_id, ord_id, sales_id, category, sub_category from main_table;



----CREATE PRODUCTS TABLE

create table products
(
    prod_id int,
    ord_id int,
    ship_id int,
    category_id int,
    product_name varchar(225),
    primary key (prod_id),
    foreign key (ship_id) references shipment(ship_id),
    foreign key (category_id) references category(category_id)
     
);


alter table products
add constraint fk_products foreign key (ord_id) references orders(ord_id);

insert into products (prod_id, ord_id, ship_id, category_id, product_name)
select prod_id, ord_id, ship_id, category_id, product_name from main_table;



--ANSWERS TO QUESTIONS



--1. What is the overall sales and profit trend?
select  year, sum(sales)  as total_sales_per_year, sum(profit)  as total_profit_per_year
from sales 
group by year
order by total_sales_per_year;

select year, sum(profit)  as total_profit_per_year
from sales
group by year
order by total_profit_per_year ASC;



--2. Which are the Top 10 products by sales?
select product_name, category, sub_category, sum(sales) as total_sales
from products p
inner join sales s on p.ord_id = s.ord_id
inner join category c on c.ord_id = p.ord_id
group by product_name, category, sub_category
order by total_sales DESC
limit 10;



--3. Which are the most and least Selling Products?
select product_name, sum(quantity) as total_quantity
from products p
inner join orders o on p.ord_id = o.ord_id
inner join category c on c.ord_id = p.ord_id
group by product_name
order by total_quantity DESC
limit 10;


select product_name, sum(quantity) as total_quantity
from orders o
inner join products p on p.ord_id = o.ord_id
inner join category c on c.ord_id = p.ord_id
group by product_name
order by total_quantity ASC
limit 10;



--4. Which is the most preferred Shipping Mode ?
select ship_mode, count(ship_mode) as count 
from shipment
group by ship_mode
order by count DESC;



--5. Which are the Most Profitable Category and Sub-Category ?
select category, sub_category, sum(profit) as total_profit  
from sales s 
inner join category c on s.sales_id = c.sales_id
group by category, sub_category
order by total_profit DESC;



--6. Who are the customers that attracts the most profit ?
select customer_name, sum(profit) as total_profit, sum(sales) as total_sales
from sales s
inner join customers c on s.ord_id = c.ord_id
group by customer_name
order by total_profit DESC
limit 10;



--7. Top 10 mostly sold item in each year?
select TO_CHAR(DATE_TRUNC('year', order_date), 'YYYY') AS year, product_name, category, sub_category, sum(quantity) as total_quantity
from orders o
inner join products p on o.ord_id = p.ord_id
inner join category c on p.ord_id = c.ord_id
where order_date between '2011-01-01' and '2011-12-31'
group by DATE_TRUNC('year', order_date), product_name, category, sub_category
order by total_quantity DESC
limit 10;

select TO_CHAR(DATE_TRUNC('year', order_date), 'YYYY') AS year, product_name, category, sub_category, sum(quantity) as total_quantity
from orders o
inner join products p on o.ord_id = p.ord_id
inner join category c on p.ord_id = c.ord_id
where order_date between '2012-01-01' and '2012-12-31'
group by DATE_TRUNC('year', order_date), product_name, category, sub_category
order by total_quantity DESC
limit 10;

select TO_CHAR(DATE_TRUNC('year', order_date), 'YYYY') AS year, product_name, category, sub_category, sum(quantity) as total_quantity
from orders o
inner join products p on o.ord_id = p.ord_id
inner join category c on p.ord_id = c.ord_id
where order_date between '2013-01-01' and '2013-12-31'
group by DATE_TRUNC('year', order_date), product_name, category, sub_category
order by total_quantity DESC
limit 10;

select TO_CHAR(DATE_TRUNC('year', order_date), 'YYYY') AS year, product_name, category, sub_category, sum(quantity) as total_quantity
from orders o
inner join products p on o.ord_id = p.ord_id
inner join category c on p.ord_id = c.ord_id
where order_date between '2014-01-01' and '2014-12-31'
group by DATE_TRUNC('year', order_date), product_name, category, sub_category
order by total_quantity DESC
limit 10;


--8. Top 10 items that bring in the most profit yearly ?

select s.prod_id, category, sub_category, year, product_name, sum(profit) as total_profit
from sales s
inner join products p on s.prod_id = p.prod_id
inner join category c on c.sales_id = s.sales_id
where year = 2011
group by s.prod_id, category, sub_category, year, product_name
order by total_profit DESC
limit 10;


select s.prod_id,category, sub_category, year, product_name, sum(profit) as total_profit
from sales s
inner join products p on s.prod_id = p.prod_id
inner join category c on c.sales_id = s.sales_id
where year = 2012
group by s.prod_id,category, sub_category, year, product_name
order by total_profit DESC
limit 10;

select s.prod_id,category, sub_category, year, product_name, sum(profit) as total_profit
from sales s
inner join products p on s.prod_id = p.prod_id
inner join category c on c.sales_id = s.sales_id
where year = 2013
group by s.prod_id, category,sub_category, year, product_name
order by total_profit DESC
limit 10;

select s.prod_id, category,sub_category, year, product_name, sum(profit) as total_profit
from sales s
inner join products p on s.prod_id = p.prod_id
inner join category c on c.sales_id = s.sales_id
where year = 2014
group by s.prod_id, category,sub_category, year, product_name
order by total_profit DESC
limit 10;



--9. What country do most customers come from ?
select country, count(*) as count
from customers
group by country
order by count DESC;



--10. What is the overall monthly and daily order trend ?

select to_char(date_trunc('Month', order_date), 'Month') as month, count(*) AS total_orders
from orders o
where order_date >= '2011-01-01' and order_date < '2014-12-31'
group by month
order by total_orders DESC;


select to_char(date_trunc('Day', order_date), 'Day') as day, count(*) AS total_orders
from orders o
where order_date >= '2011-01-01' and order_date < '2014-12-31'
group by day
order by total_orders DESC;