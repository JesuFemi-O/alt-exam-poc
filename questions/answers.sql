## Part 2A- Question 1
-- I created a cte called subquery that uses the orders table to get orders that are successful and joined it with the events table on the customer_id column
-- and from the events table I used the event_type column to find out all customers that checked out and the time they checked out
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
order by num_times_in_successful_orders desc;
-- The most ordered item has it's product_id as '7', product_name as 'Apple AirPods Pro' with the number of successful orders as '735'
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
##Part 2A- Question 2
-- I used a CTE to join the events table to the customers table using the customer_id, and got the location and event_product_id from the events table 
with my_query as (
select e.customer_id, c.location, (e.event_data ->> 'item_id')::int as event_product_id --I had to cast item_id as an integer to be able to query the result on the cte below
from events e
join customers c on e.customer_id = c.customer_id
)
-- Here I joined the my_query CTE to the products table to get the sum of the price for each customer_id
-- Then I joined the products table to the events_product_id cte table above
select distinct mq.customer_id, mq.location, sum(p.price) over (partition by customer_id) as total_spend
from my_query mq
join products p on mq.event_product_id = p.id
order by total_spend desc;
-- Running the query we see that the customers with the highest spend resides in Dominica, Cameroon, India, New Caledonia and Norway
-- with a total spend of 19,672.81, 19,352.81, 19,079.73, 19,002.81 and 18,952.77 respectively.

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
##Part 2B- Question 1
--Made use of the CTE I created earlier in question 2a(that is made up of event table and orders table and used that to find the successful checkout
with successful_checkout as (
select o.customer_id, o.status, o.order_id     
from orders o
join events e on o.customer_id = e.customer_id
where o.status = 'success'
and e.event_data ->> 'event_type' = 'checkout'
and e.event_timestamp = o.checked_out_at
)
--Here I joined the customers table with the successful checkout table to get the location
select location, count(sc.order_id) as checkout_count
from successful_checkout sc
join customers c on sc.customer_id = c.customer_id
group by location
order by checkout_count desc;
--we can see that the country with the highest number of successful orders is Korea with a total checkout number of 17
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
##Part 2B- Question 2
-- I created a CTE which I used to count the total number of customers who visited, added to cart, removed from cart and did not check out
with abandoned_customers as (
select distinct(customer_id),
count(case when event_data ->> 'event_type' = 'visit' then 1 end) as visits,
count(case when event_data ->> 'event_type' = 'add_to_cart' then 1 end) as add_to_cart,
count(case when event_data ->> 'event_type' = 'remove_from_cart' then 1 end) as remove_from_cart,
count(case when event_data ->> 'event_type' != 'checkout' then 1 end) as num_of_events
from events
group by customer_id
)
-- I did a join on the orders table to find customers with their unique order id, they cannot generate a new order id if they have not checked out/made a successful order before
select o.customer_id, ac.num_of_events
from orders o
join abandoned_customers ac on o.customer_id = ac.customer_id
where o.status != 'success';

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
##Part 2B- Question 3
-- I used a cte on the events table to find customers that have completed a checkout
with checkout_customers as (
select distinct customer_id
from events
where event_data ->> 'event_type' = 'checkout'
)
select round(avg(visits), 2) as avg_visits
-- I used a table subquery to find the total number of visits per customer
from (
    select customer_id, count(*) as visits
    from events
-- Here I used a scalar subquery to filter only customers that appear on my checkout_customers cte and also people that have visited the website
    where customer_id in (select customer_id from checkout_customers)
    and event_data ->> 'event_type' = 'visit'
    group by customer_id
) as customer_visits;
-- After rounding up to 2 decimal places, I got the aggregate to be 4.51