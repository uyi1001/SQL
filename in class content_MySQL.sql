--basic select and calculation
select first_name as 'first name',
	last_name,
    points,
    (points + 10) * 100 as 'discount factor'
from customers;

select name, unit_price, unit_price*1.1 as new_price
from products;

select *
from customers
where not(birth_date <= '1990-01-01'
or points  <= 1000);

select *
from order_items
where order_id = 6
and unit_price*quantity >30;

select *
from products
where quantity_in_stock in (49,38,72);

select *
from customers
where birth_date
between '1990-01-01' and '2000-01-01';

select *
from customers
where last_name like 'b%y';

select *
from customers
where address like '%trail%' or address like '%avenue%';

select *
from customers
where phone like '%9';

select *
from customers
where first_name in ('elka','ambur');

select *
from customers
where last_name regexp 'EY$|ON$';

select *
from customers
where last_name regexp '^My|se';

select *
from customers
where last_name regexp 'b[ru]';

select *
from orders
where shipped_date is null;

select *, quantity*unit_price as total_price
from order_items
where order_id = 2
order by total_price desc;

select *
from customers
order by points desc
limit 3;

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

select e.employee_id, e.first_name, m.first_name as manager
from employees e
join employees m
on e.reports_to = m.employee_id;

use sql_store;

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

select *
from order_items oi
join order_item_notes n
on oi.order_id = n.order_id
and oi.product_id = n.product_id;

select p.product_id, p.name, oi.quantity
from products p
left join order_items oi
on p.product_id = oi.product_id;

select c.customer_id, c.first_name, o.order_id, s.name as shipper
from customers c
left join orders o
on c.customer_id = o.customer_id
left join shippers s
on o.shipper_id = s.shipper_id
order by c.customer_id;

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

select e.employee_id, e.first_name, m.first_name
from employees e
left join employees m
on e.reports_to = m.employee_id;

select o.order_date, o.order_id, c.first_name as customer, s.name as shipper, os.name as status
from orders o
join customers c
using(customer_id)
left join shippers s
using(shipper_id)
join order_statuses os
on o.status = os.order_status_id
order by o.status, o.order_id;

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

select *
from orders o
natural join customers c;

select s.name as shipper, p.name as product
from shippers s
cross join products p
order by s.name;

select s.name as shipper, p.name as product
from shippers s, products p
order by s.name;

select order_id, order_date, 'Active' as status
from orders
where order_date >= '2019-01-01'
union
select order_id, order_date, 'Archived' as status
from orders
where order_date <= '2019-01-01';

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

insert into products (name, quantity_in_stock, unit_price)
value ('product1', 12, 2.15),
	  ('product2', 10, 1.87),
      ('product3', 19, 4.39);

create table orders_test as
select * from orders;

insert into orders_test
select * from orders
where order_id = 1;

insert into orders_test
select * from orders
where order_id = 1;

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

use sql_store;

update customers
set points = points+50
where birth_date < '1990-01-01';

use sql_invoicing;

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

select pm.name as payment_method, sum(p.amount) as total
from payments p
join payment_methods pm
on p.payment_method = pm.payment_method_id
group by pm.name with rollup;

use sql_store;

select *
from products
where unit_price > 
	(select unit_price from products
    where name regexp 'Lettuce');








