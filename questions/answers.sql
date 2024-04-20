-- PART 2a

-- Question 1:- what is the most ordered item based on the number of times it appears in an order cart that checked out successfully?
--  you are expected to return the product_id, and product_name and num_times_in_successful_orders

WITH counting AS (
    SELECT
        id AS product_id,
        name AS product_name,
        quantity,
        -- I decided to count the total number of check_out_at of each items because it has the record of 
		-- all the items added to cart, be it successful, cancelled or failed.
        COUNT(checked_out_at) * quantity AS items_count
    FROM alt_school.orders o
    JOIN alt_school.line_items l USING (order_id)
    FULL JOIN alt_school.products p ON l.item_id = p.id
    WHERE status = 'success'
    GROUP BY id, name, quantity
),
items_ranking AS (
SELECT
    product_id,
    product_name,
    -- In order to get the number of time an and item appears in a successful cart, it is important 
	-- I multiply the total number of items with a success status by its quantity and sum it up to help 
	-- determine the most ordered items based on the number of times it appeared in order cart
    sum (items_count) as num_times_in_succesful_orders,
    -- The rank function implication was to help rank the most ordered items in accordance to the number of time
    -- it apeared in the order cart.
    RANK() OVER (ORDER BY SUM(items_count) DESC)  AS rank
FROM counting
GROUP BY product_id, product_name)
SELECT 
	product_id,
	product_name,
	num_times_in_succesful_orders
FROM items_ranking
WHERE rank = 1;


-- Question 2: - without considering currency, and without using the line_item table, find the top 5 spenders
--  you are exxpected to return the customer_id, location, total_spend

with spenders as (
-- The idea behind this WITH clause is to extract a dataset that contain customer_id, location, event_data quantity, prices of items
-- and the summation of event_data quantity casted to int because it has a bigint datatype multitplied by price of each of the items
-- partitioned over customer_id to get the total amount spent by each customers which was further filtered by those that have 
-- success status with a row with null event_data quantity
    select 
        customer_id,
        location,
        event_data ->> 'quantity' as quantity,
        price,
        sum((event_data ->> 'quantity')::int * price) over (partition by customer_id) as total_spent
    from alt_school.customers c  
    join alt_school.orders o using (customer_id)
    join alt_school.events e using(customer_id)
    join alt_school.products p on (e.event_data ->> 'item_id')::int = p.id
    -- Though, the where event_data quantity is not null did not play any significant role here, this is just me trying to play safe.
    -- I obervered that the event_type with "remove from cart" does not have any quantity data. The status = success already filtered 
    -- what i needed to get my result but being on a safer side made me include the quantity not null in the where clause
    where status = 'success' and event_data ->> 'quantity' is not null
)
select 
    distinct customer_id,
    location,
    total_spent
from spenders
order by total_spent desc
fetch first 5 rows only;


-- PART 2b:


-- QUESTION 1: - using the events table, Determine **the most common location** (country) where successful checkouts 
-- occurred. return `location` and `checkout_count`


WITH checkout_counts AS (
    SELECT
        location,
        -- event_type key from the event column was counted because it contains the data of the activities at 
		-- the event, so counting the event_type and sorting it by those that have success status will help
		-- figure out the most common locations with a successful checkouts
        COUNT(event_data ->> 'event_type') AS checkout_count,
        -- I've used the RANK() window function to assign a rank to each location based on the checkout count, ordered by
        -- descending checkout count. Then, in the outer query, I've selected the locations where the rank is equal to 1, 
        -- effectively retrieving the location(s) with the highest checkout count.
        RANK() OVER (ORDER BY COUNT(event_data ->> 'event_type') DESC) AS checkout_rank
    FROM 
        alt_school.events e 
    JOIN 
    -- The customer table was added so as to get the location names after realizing that the event table did not contain 
    -- such information from my finding and it is required to be retured in out result
        alt_school.customers c USING (customer_id)
    WHERE 
        event_data ->> 'status' = 'success' 
    GROUP BY 
        location
)
SELECT 
    location,
    checkout_count
FROM 
    checkout_counts
WHERE 
    checkout_rank = 1;


-- QUESTION 2: - using the events table, identify the customers who abandoned their carts and count the number of events 
-- (excluding visits) that occurred before the abandonment. return the `customer_id` and `num_events`


with abandoned_carts as (
-- Since a cart is considered abandoned if a user fails to checkout i.e the user adds/removes items from their cart but 
-- never proceeds to pay for their orders, so it important to first filter out customers with a success status and count the 
-- remainiing customers event_type, reason being that we were told to count customers that abadoned their carts and I believe 
-- that it is not possible for somebody to have a success status and still abadon his/her cart. So technically, I am counting
-- customers with a "Cancelled" and "Failed" status in my result. It is also important to note that no customers with 2 different
-- status, so i can confidently consider consider customers with both "cancelled" and "failed" status as those who abadoned
-- their cart because they didn't successfully made any payment
	select distinct 
		customer_id,
		count (event_data ->> 'event_type') as abadoned_count
	from events
	where event_data ->> 'status' != 'success'
	group by customer_id
)
select 
	customer_id,
	count(*) as num_events 
from events e
inner join abandoned_carts using (customer_id)
where event_data ->> 'event_type' != 'visit'
	and customer_id in (
	select customer_id
	from abandoned_carts)
group by customer_id;


-- QUESTION 3: - Find the average number of visits per customer, considering only customers who completed a checkout! return 
-- average_visits to 2 decimal place


WITH completed_checkouts AS (
-- As pointed in the question saying, "the average_visits number is a metric that suggests the avearge number of times a customer visits 
-- the website before they make a successful transaction", so the first step that crossed my mind in my analysis was to create CTE for 
-- customers with a successful checkout.
    SELECT DISTINCT customer_id
    FROM events
    WHERE event_data->>'status' = 'success'
),
customer_visits AS (
-- And in order for me to find the average of the customer, I went ahead to create "customer_visits" that have the
-- counts of the timestamp of each customer's visit and also went ahead to make a successfull checkout not those who only visited
-- without making any successful checkout.
    SELECT customer_id, COUNT(distinct event_data->>'timestamp') AS num_visits
    FROM events
    WHERE customer_id IN (SELECT customer_id FROM completed_checkouts)
    AND event_data->>'event_type' = 'visit'
    GROUP BY customer_id
)
SELECT ROUND(AVG(num_visits), 2) AS average_visits
FROM customer_visits;