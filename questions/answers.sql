--QUESTION PART 2A;1
--- what is the most ordered item based on the number of times it appears in an order cart that checked out successfully?
--  you are expected to return the product_id, and product_name and num_times_in_successful_orders where:
--
--  - product_id: the uuid string uniquely representing the product
--  - product_name: the name of the product as provided in the product table
--  - the number of times the product appeared in a a users cart that was successfully checked out. if ten customers added the item to their carts and only 8 of them successfully checked out and paid, then the answer should be 8 not 10.

select
	li.item_id as product_id,
	p.name as product_name,
	COUNT(distinct o.order_id) as num_times_in_successful_orders
from
	alt_school.line_items li 
join alt_school.orders o on li.order_id = o.order_id
join alt_school.products p on li.item_id = p.id 
where 
	o.status = 'success'
group by 
	li.item_id, p.name
order by 
	num_times_in_successful_orders desc 
limit 10;

-- This query is used to identify the top 10 most popular products based on the number of successful orders they appear in.
-- This could be useful for inventory management, sales analysis, or marketing purposes.


-- QUESTION 2A;2
--- without considering currency, and without using the line_item table, find the top 5 spenders
--  you are exxpected to return the customer_id, location, total_spend where:
--
--  - customer_id: uuid string that uniquely identifies a customer
--  - location - the customer's location
--  - total_spend - the total amount of money spent on orders


select 
	c.customer_id,
	c.location,
	sum(p.price) as total_spend
from
	alt_school.orders o
join
	alt_school.customers c on o.customer_id = c.customer_id
join
	alt_school.products p on id = p.id
group by
	c.customer_id, c.location
order by
	total_spend desc
limit 10;

--  The assumption is that, the id in the orders table corresponds to the product id in the products table.

-- This query is used to identify the top 10 customers who have spent the most on their orders.
-- This could be useful for customer segmentation, sales analysis, or marketing purposes.


-- QUESTION 2B;1
--- using the events table, Determine **the most common location** (country) where successful checkouts occurred. return `location` and `checkout_count` where:
--    - location: the name of the location
--    - checkout_count: the number of checkouts that occured in the location

select 
	c.location AS location,
	count(*) AS checkout_count
from
	alt_school.events e 
join
	alt_school.customers c on e.customer_id = c.customer_id
where 
	e.event_data->>'status' = 'success'
and e.event_data->>'event_type' = 'checkout'
group by
	c.location
order by
	checkout_count desc
LIMIT 5;


-- This query is used to identify the top 5 locations with the most successful checkouts.
-- This could be useful for understanding geographical trends in successful transactions, which could inform business strategy or marketing efforts.


-- QUESTION 2B;2
--- using the events table, identify the customers who abandoned their carts and count the number of events (excluding visits) that occurred before the abandonment. return the `customer_id` and `num_events` where:
--
--    - customer_id: id uniquely identifying the customers
--    - num_events: the number of events excluding visits that occured before abandonment

with Abandoned_Carts AS (
select 
	customer_id,
	count(*) AS num_events
from
alt_school.events e 
where
	event_data->>'event_type' = 'checkout'

and event_data->>'status' <> 'success'

and event_data->>'event_type' <> 'visit'
and customer_id is not null
group by
	customer_id
)
select 
	AC.customer_id,
	AC.num_events
from
Abandoned_Carts AC;

-- This query is used to identify the number of unsuccessful checkout events (excluding ‘visit’ events) for each customer. 
-- This could be useful for understanding customer behavior, particularly in terms of cart abandonment, which could inform business strategy or marketing efforts


-- QUESTION 2B;3
--- Find the average number of visits per customer, considering only customers who completed a checkout! return average_visits to 2 decimal place
--
--    - average_visits: this number is a metric that suggests the avearge number of times a customer visits the website before they make a successful transaction!

WITH Checkout_Customers AS (
    SELECT DISTINCT
        customer_id
    FROM
        alt_school.events 
    WHERE
        event_data->>'event_type' = 'checkout'
        AND event_data->>'status' = 'success'
)
SELECT 
    ROUND(AVG(num_visits)::NUMERIC, 2) AS average_visits
FROM (
    SELECT
        customer_id,
        COUNT(*) AS num_visits
    FROM
        alt_school.events 
    WHERE
        customer_id IN (SELECT customer_id FROM Checkout_Customers)
        AND event_data->>'event_type' = 'visit'
    GROUP BY
        customer_id
) AS Visit_Counts;

-- This query is used to calculate the average number of ‘visit’ events per customer who has successfully checked out. 
-- This could be useful for understanding customer behavior, particularly in terms of site engagement among customers who have made a purchase.