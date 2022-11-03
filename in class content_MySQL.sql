-- basic select clause, with calculaiton
select first_name as 'first name',
	last_name,
    points,
    (points + 10) * 100 as 'discount factor'
from customers;

select name, unit_price, unit_price*1.1 as new_price
from products;

-- basic filter with where (and, or, not)
select *
from customers
where not(birth_date <= '1990-01-01'
or points  <= 1000);

select *
from order_items
where order_id = 6
and unit_price*quantity >30;

-- filt with multiple conditions
select *
from products
where quantity_in_stock in (49,38,72);

-- between (inclusive)
select *
from customers
where birth_date
between '1990-01-01' and '2000-01-01';

-- like and wildcard
select *
from customers
where last_name like 'b%y';

select *
from customers
where address like '%trail%' or address like '%avenue%';

select *
from customers
where phone like '%9';

-- in can also be used
select *
from customers
where first_name in ('elka','ambur');

/*
regexp:
	regexp 'something' = like '%something%'
    regexp 'sth1 | sth2' = in ('sth1', 'sth2')
    regexp '^something' = like 'something%'
    regexp 'something$' = like '%something'
    regexp '[abc]sth' → asth/bsth/csth
    regexp '[a-d]sth' → a~d + sth
- ^ begin
- $ end
- | or
- [] in
*/
select *
from customers
where last_name regexp 'EY$|ON$';

select *
from customers
where last_name regexp '^My|se';

select *
from customers
where last_name regexp 'b[ru]';

-- is null
select *
from orders
where shipped_date is null;

-- order by
select *, quantity*unit_price as total_price
from order_items
where order_id = 2
order by total_price desc;

-- limit (always the last)
-- * limit 6,3 means skip the first 6 results and show the next 3
select *
from customers
order by points desc
limit 3;

-- join (inner join: intersection of two tables)
select orders.order_id,product_id, quantity
from orders
join order_items
on orders.order_id = order_items.order_id;

select o.order_id,product_id, quantity
from orders o
join order_items oi
on o.order_id = oi.order_id;

select order_id, o.product_id, quantity, o.unit_price
from order_items o
join products p
on o.product_id = p.product_id;

use sql_hr;

-- self joins
select e.employee_id, e.first_name, m.first_name as manager
from employees e
join employees m
on e.reports_to = m.employee_id;

use sql_store;

-- join multiple tables
select o.order_id, o.order_date, c.first_name, c.last_name, os.name as status
from orders o
join customers c
on o.customer_id = c.customer_id
join order_statuses os
on o.status = os.order_status_id
order by order_id;

use sql_invoicing;

select p.date, i.number as invoice_number, p.amount, c.name as client_name, pm.name as payment_method
from payments p
join clients c
on p.client_id = c.client_id
join invoices i
on p.invoice_id = i.invoice_id
join payment_methods pm
on p.payment_method = pm.payment_method_id;

use sql_store;

-- join a talbe with multiple primary keys
select *
from order_items oi
join order_item_notes n
on oi.order_id = n.order_id
and oi.product_id = n.product_id;

-- outer join (join table B to table A no matter if it's null in B)
select p.product_id, p.name, oi.quantity
from products p
left join order_items oi
on p.product_id = oi.product_id;

-- outer join multiple talbes (the first one should be the most inclusive table)
select c.customer_id, c.first_name, o.order_id, s.name as shipper
from customers c
left join orders o
on c.customer_id = o.customer_id
left join shippers s
on o.shipper_id = s.shipper_id
order by c.customer_id;

/*
show order date, order id from orders table (original one)
show customer name from customers table (using client id)
show shipper name (no matter if it's shipped) from shippers table (outer jion on shipper id)
show order status from status table (using status id)
*/
select o.order_date, o.order_id, c.first_name as customer, s.name as shipper, os.name as status
from orders o
join customers c
on o.customer_id = c.customer_id
left join shippers s
on o.shipper_id = s.shipper_id
join order_statuses os
on o.status = os.order_status_id
order by o.status, o.order_id;

use sql_hr;

-- self outer join (show manager info on the right including the manager itself)
select e.employee_id, e.first_name, m.first_name
from employees e
left join employees m
on e.reports_to = m.employee_id;

-- using (instead of on xxx = xxx when column name is exactly the same)
select o.order_date, o.order_id, c.first_name as customer, s.name as shipper, os.name as status
from orders o
join customers c
using(customer_id)
left join shippers s
using(shipper_id)
join order_statuses os
on o.status = os.order_status_id
order by o.status, o.order_id;

-- using clause (with multiple primary keys)
select *
from order_items oi
join order_item_notes oin
using (order_id, product_id);

select p.date, c.name as client, p.amount, pm.name as payment_method
from payments p
join clients c
using (client_id)
join payment_methods pm
on p.payment_method = pm.payment_method_id;

-- natural join (select by system)
select *
from orders o
natural join customers c;

-- cross join (useful when assigning size or colors to every product)
select s.name as shipper, p.name as product
from shippers s
cross join products p
order by s.name;

-- implicit cross join
select s.name as shipper, p.name as product
from shippers s, products p
order by s.name;

-- union (connect rows with the same number of columns, column name will be the first "as ...")
select order_id, order_date, 'Active' as status
from orders
where order_date >= '2019-01-01'
union
select order_id, order_date, 'Archived' as status
from orders
where order_date <= '2019-01-01';

-- if select only one column and union, the result will be distinct
select customer_id
from orders
union
select customer_id
from orders;

-- the number of columns should be the same
select order_id, customer_id
from orders
union
select first_name, first_name
from customers;

select customer_id, first_name, points, 'Bronze' as type
from customers
where points < 2000
union
select customer_id, first_name, points, 'Silver' as type
from customers
where points between 2000 and 3000
union
select customer_id, first_name, points, 'Gold' as type
from customers
where points > 3000
order by first_name;

-- insert rows
insert into products (name, quantity_in_stock, unit_price)
value ('product1', 12, 2.15),
	  ('product2', 10, 1.87),
      ('product3', 19, 4.39);

-- create table by copy paste (notice: there will be no PK and AI)
create table orders_test as
select * from orders;

-- copy selected row to the table
insert into orders_test
select * from orders
where order_id = 1;

-- can by copied from other tables across databases as long as the number of column and attributes matched
insert into orders_test (customer_id, order_date, status, comments, shipped_date, shipper_id)
select client_id, invoice_date, '1', number, payment_date, invoice_id
from sql_invoicing.invoices
where invoice_date >= '2019-07-01';

insert into orders_test (customer_id, order_date, status, comments, shipped_date, shipper_id)
select customer_id, order_date, status, comments, shipped_date, shipper_id
from orders
where order_date <= '2018-01-01';

create table orders_test2 as
select order_id, customer_id, status, comments
from orders;

insert into orders_test2 (customer_id, status, comments)
select customer_id, status, comments
from orders
where order_id = 1;

use sql_invoicing;

create table invoices_archived as
select invoice_id, number, c.name as client, iv.invoice_total, iv.payment_total, iv.invoice_date, iv.due_date, iv.payment_date
from invoices iv
join clients c
using (client_id)
where payment_date is not null;

-- insert hierarchical rows into tow tables
create table orders_test as
select * from orders;
create table order_items_test as
select * from order_items;
insert into orders_test (customer_id, order_date, status)
values (1, '2019-01-02', 1);
insert into order_items_test
values (last_insert_id(), 1, 1, 2.95),
	   (last_insert_id(), 2, 4, 3.18);

use sql_store;

-- update rows (un-check the "safe update" in MySQL preference first)
update customers
set points = points+50
where birth_date < '1990-01-01';

use sql_invoicing;

-- update with subqueries
update invoices
set payment_total = invoice_total * 0.5, payment_date = due_date
where client_id in (
select client_id
from clients
where state in ('CA', 'NY')
);

use sql_store;

update orders
set comments = 'Gold customer'
where customer_id in (
select customer_id from customers
where points > 3000
);

use sql_invoicing;

-- aggregate functions (returns only one result when use directly)
select
	'First half of 2019' as date_range,
    sum(invoice_total) as total_sales,
    sum(payment_total) as total_payments,
    sum(invoice_total - payment_total) as what_we_expect
from invoices
where invoice_date between '2019-01-01' and '2019-06-30'
union
select
	'Second half of 2019' as date_range,
    sum(invoice_total) as total_sales,
    sum(payment_total) as total_payments,
    sum(invoice_total - payment_total) as what_we_expect
from invoices
where invoice_date between '2019-07-01' and '2019-12-31'
union
select
	'Total' as date_range,
    sum(invoice_total) as total_sales,
    sum(payment_total) as total_payments,
    sum(invoice_total)-sum(payment_total) as what_we_expect
from invoices
where invoice_date between '2019-01-01' and '2019-12-31';

-- group by
select p.date as date, pm.name as payment_method, sum(p.amount) as total_payments
from payments p
join payment_methods pm
on p.payment_method = pm.payment_method_id
group by p.date, payment_method
order by p.date;

select client_id, sum(invoice_total) as total_sales
from invoices
group by client_id;

use sql_store;

select c.customer_id, c.first_name, c.last_name, sum(oi.quantity*oi.unit_price) as order_sales
from customers c
join orders o
using (customer_id)
join order_items oi
using (order_id)
where c.state = 'VA'
group by c.customer_id
having order_sales > 100;

use sql_invoicing;

-- group by with rollup (only MySQL have this rollup sentence)
select pm.name as payment_method, sum(p.amount) as total
from payments p
join payment_methods pm
on p.payment_method = pm.payment_method_id
group by pm.name with rollup;

use sql_store;

-- subqueries in where
select *
from products
where unit_price > 
	(select unit_price from products
    where name regexp 'Lettuce');

use sql_hr;

select employee_id, first_name, last_name
from employees
where salary >
	(select avg(salary)
    from employees);

use sql_store;

select *
from products
where product_id not in (
select distinct product_id
from order_items);

use sql_invoicing;

-- subqueries vs. join
-- subquery
select *
from clients
where client_id not in (
	select distinct client_id
	from invoices);
-- join
select * from clients
left join invoices using(client_id)
where invoice_id is null;

use sql_store;

-- subsubsub query
select c.customer_id, first_name, last_name
from customers c
where customer_id in (
	select customer_id from orders
    where order_id in (
		select order_id from order_items
		where product_id = (
			select product_id from products where name regexp 'lettuce')));
-- join
select distinct c.customer_id, c.first_name, c.last_name
from customers c
join orders
using (customer_id)
join order_items
using (order_id)
where product_id in (
select product_id from products
where name regexp 'lettuce');
-- another subquery with join
select distinct c.customer_id, c.first_name, c.last_name
from customers c
where customer_id in (
	select o.customer_id
    from order_items oi
    join orders o using (order_id)
    where product_id = (
		select product_id from products
		where name regexp 'lettuce'));

use sql_invoicing;

-- all
-- select invoices that larger than client 3's every invoice
select *
from invoices
where invoice_total > all (
	select invoice_total
	from invoices
	where client_id = 3);
-- is the same as:
select *
from invoices
where invoice_total > (
	select max(invoice_total)
    from invoices
    where client_id = 3
    );

-- any
-- select the clients who have at least two invoices
select *
from clients
where client_id = any(
	select client_id
    from invoices
    group by client_id
    having count(*) >=2);
-- is the same as:
select *
from clients
where client_id in(
	select client_id
	from invoices
	group by client_id
	having count(*) >=2);

use sql_hr;

-- correlated subqueries
-- the subquery refers to the outer query
select *
from employees e
where salary > (
	select avg(salary) as office_avg
	from employees
	where office_id = e.office_id);

use sql_invoicing;

select *
from invoices i
where invoice_total > (
	select avg(invoice_total)
    from invoices
    where client_id = i.client_id);

use sql_store;

-- exists
select *
from products p
where not exists(
	select product_id
    from order_items
    where product_id = p.product_id);
-- is the same as:
-- however, exists creates a correlated subquery
-- it's better to use exists when the subquery returns a huge list of results
select *
from products
where product_id not in (
	select product_id
    from order_items);

use sql_invoicing;

-- subqueries in select clause
-- if not "select" aggregate function, only one result will return
-- alias should also be "select"
select i.client_id, c.name, sum(invoice_total) as total_sales,
	(select avg(invoice_total) from invoices) as average,
    sum(invoice_total) - (select average) as difference
from invoices i
right join clients c
using(client_id)
group by client_id;
-- is the same as:
select client_id, name,
	(select sum(invoice_total) from invoices
		where client_id = c.client_id) as total_sales,
	(select avg(invoice_total) from invoices) as average,
    (select total_sales - average) as difference
from clients c;

-- subqueries in from clause
-- must give the derived table an alias
-- can use view instead (better)
select max(difference) as max_difference, min(difference) as min_difference
from (
	select client_id, name,
		(select sum(invoice_total) from invoices
			where client_id = c.client_id) as total_sales,
		(select avg(invoice_total) from invoices) as average,
		(select total_sales - average) as difference
	from clients c
) as sales_summary

-- subqueries in from clause
-- must give the derived table an alias
-- can use view instead (better)
select max(difference) as max_difference, min(difference) as min_difference
from (
	select client_id, name,
		(select sum(invoice_total) from invoices
			where client_id = c.client_id) as total_sales,
		(select avg(invoice_total) from invoices) as average,
		(select total_sales - average) as difference
	from clients c
) as sales_summary;

-- Numeric Functions
select round(5.73);
select round(5.73, 1);
select truncate(5.7468, 2); -- not round
select ceiling(7.2); -- return the smallest int >= this number
select floor(8.4); -- return the largest int <= this number
select abs(-10.4);
select rand();

-- String Function
select length('abc');
select length('A B C');
select length('I love you');
select upper('where are you');
select lower('Sky');
select ltrim('     what are you');
select length(rtrim('  abc    '));
select length(trim('   I love you    '));
select left('Kindergarten', 4);
select right('Kindergarten', 6);
select substring('Kingdergarten', 3, 4);
select substring('I love you', 2, 7);
select locate('n', 'Kindergarten');
select locate('app', 'whatsapp');
select replace('whatsapp', 'a', 'b');
select replace('Kindergarten', 'garten', 'Nape');
select concat('abc', ' ', 'def');

use sql_store;
select concat(first_name, ' ', last_name) as full_name from customers;

-- Date Function
select now(), curdate(), curtime();
select year(now()), month(now()), day(now()),
	hour(now()), minute(now()), second(now());
select year('2019-01-01');
select dayname(now()), monthname(now());
select extract(year from now()), extract(month from now());

select * from orders
where year(order_date) >= year(now());
-- remember to compare year() with year()

-- Formatting Dates and Times
select date_format('2022-01-02', '%M-%D %Y');
select date_format(now(),'%m %d %y');
-- search 'mysql date format string' for more formation
select time_format(now(), '%H:%i %p');

-- Calculating Dates and Times
select date_add(now(), interval 1 day);
select date_add(now(), interval 1 month);




