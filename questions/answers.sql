## Part 2A- Question 1
-- I created a cte called subquery that uses the orders table to get orders that are successful and joined it with the events table on the customer_id column
-- and from the events table I used the event_type column to find out all customers that checked out and their time they checked out
with subquery as (
select o.customer_id, o.status, o.order_id     
from orders o
join events e ON o.customer_id = e.customer_id
where o.status = 'success'
and e.event_data ->> 'event_type' = 'checkout'
and e.event_timestamp = o.checked_out_at
),
-- Here I created another cte called sub that allows me to find the order_id, the line_item and the product name
-- I joined the line_items table with the subquery cte table I created above and the products table on the order.id
sub as(
select s.order_id, li.item_id, p.name
from subquery as s
join line_items li on s.order_id = li.order_id 
join products p on li.item_id = p.id
)
-- Here I used the sub cte table to get the product_id, the product_name and the number of times the order per product was successful
-- I used a count on the order_id to get the unique total of each product that was successful then I used the order by clause to find the most ordered number.
select sub.item_id as product_id, sub.name as product_name, count(sub.order_id)as num_times_in_successful_orders
from sub
group by sub.item_id, sub.name
order by num_times_in_successful_orders desc
-- The most ordered item has it's product_id as '7', prooduct_name as 'Apple AirPods Pro' with the number of successful orders as '735'
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
##Part 2A- Question 2




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
##Part 2B- Question 1
--Made use of the CTE I created earlier in question 2a(that is made up of event table and orders table and used that to find the successful checkout
with successful_checkout as (
SELECT o.customer_id, o.status, o.order_id     
FROM orders o
JOIN events e ON o.customer_id = e.customer_id
WHERE o.status = 'success'
AND e.event_data ->> 'event_type' = 'checkout'
AND e.event_timestamp = o.checked_out_at
)
--Here I joined the customers table with the successful checkout table to get the location
select location, count(sc.order_id) as checkout_count
from successful_checkout sc
join customers c on sc.customer_id = c.customer_id
group by location
order by checkout_count desc
--we can see that the country with the highest number of successful orders is Korea with a total checkout number of 17
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------