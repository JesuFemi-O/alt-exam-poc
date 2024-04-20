## Part 2a : what is the most ordered item based on the number of times it appears 
# in an order cart that checked out successfully?

---- Question 2a --- (i)

select 
	li.item_id as product_id,
	p.name as product_name,
	count(distinct o.order_id) as num_times_in_successful_orders from ALT_SCHOOL.LINE_ITEMS li
join
	ALT_SCHOOL.ORDERS o ON li.order_id = o.order_id 
join 
	ALT_SCHOOL.PRODUCTS p ON li.item_id = p.id 
where 
o.status = 'success'
group by 
	li.item_id, p.name
order by
	num_times_in_successful_orders
desc 
limit 1;


---- Question 2a --- (ii)

select c.customer_id, c.location, SUM(p.price) as total_spend
from ALT_SCHOOL.ORDERS o
join ALT_SCHOOL.CUSTOMERS c on o.customer_id = c.customer_id 
join ALT_SCHOOL.PRODUCTS p on id = p.id
group by c.customer_id, c.location
order by total_spend desc
limit 5;


---- Question 2b --- (i)

select c.location as location,
COUNT(1) as checkout_count
from ALT_SCHOOL.EVENTS e
join ALT_SCHOOL.customers c on e.customer_id = c.customer_id 
where e.event_data->>'status' = 'success'
and e.event_data->>'event_type' = 'checkout'
group by c.location
order by checkout_count 
desc limit 1;,


---- Question 2b --- (ii)

with Abandoned_Carts as (
	select customer_id,
	COUNT(1) as num_events
	from ALT_SCHOOL.events
	where event_data->>'event_type' = 'checkout'
	and event_data->>'status' <> 'success'
	and event_data->>'event_type' <> 'visit'
	and customer_id is not null 
	group by customer_id
)
select AC.customer_id, AC.num_events
from Abandoned_Carts AC;


---- Question 2b --- (iii)

with Checkout_Customers as (
	select distinct
		customer_id
	from ALT_SCHOOL.events
	where event_data->>'status' = 'success'
)
select ROUND(AVG(num_visits)::numeric, 2) as average_visits
from
	(
		select 
			customer_id, 
			COUNT(1) as num_visits 
		from ALT_SCHOOL.EVENTS 
		where 
			customer_id in 
(select customer_id from checkout_Customers)
			and event_data->>'event_type' = 'visits'
			group by 
				customer_id
	) as visit_Counts;

	
	
	
