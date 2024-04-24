
-- part 2.a.i: most ordered item based on the number of times it appears in an order cart that checked out successfully?

--  product_id |    product_name    | num_times_in_successful_orders 
--  -----------+--------------------+--------------------------------
--  3          | Sony PlayStation 5 |                           1172

WITH checkouts AS (
	-- CTE1 ->> checkouts: 
    -- filter rows with successful checkouts identified by custmer_id
    SELECT * 
    FROM alt_school.events
    WHERE customer_id IN (
        SELECT customer_id 
        FROM alt_school.events AS e 
        WHERE e.event_data->>'status' = 'success'
    )
),
removed_items AS (
    -- CTE2 ->> removed_items
	-- filter rows with items removed from cart after adding to the cart
    SELECT event_id, customer_id, event_data, CONCAT(customer_id, '_', event_data->>'item_id') AS ce 
    FROM alt_school.events
    WHERE CONCAT(customer_id, '_', event_data->>'item_id') IN (
        SELECT CONCAT(customer_id, '_', event_data->>'item_id') 
        FROM alt_school.events 
        WHERE event_data->>'event_type' = 'remove_from_cart'
    )
    AND CONCAT(customer_id, '_', event_data->>'item_id') IN (
        SELECT CONCAT(customer_id, '_', event_data->>'item_id') 
        FROM alt_school.events 
        WHERE event_data->>'event_type' = 'add_to_cart'
    )
),
checker as (
    -- CTE3 ->> checker
	-- table with only items that were added to the cart, not removed and made it successful checkouts
	SELECT * 
	FROM checkouts
	WHERE event_id NOT IN (
		SELECT event_id FROM removed_items
	)
)

-- solution query:
-- product_id, product_name and num_times_in_successful_orders
-- from events, products table joining on (item_id and product_id)

SELECT 
    c.event_data->>'item_id' AS product_id,
    p.name as product_name,
    SUM((c.event_data->>'quantity')::INT) AS num_times_in_successful_orders
FROM 
    checker AS c
JOIN 
    alt_school.products AS p ON c.event_data->>'item_id' = CAST(p.id AS TEXT)
--                                                    
WHERE 
    c.event_data->>'event_type' = 'add_to_cart'
GROUP BY 
    c.event_data->>'item_id', p.name
ORDER BY 
    num_times_in_successful_orders DESC
LIMIT 1;




-- part 2.a.ii: top five spenders

--              customer_id              |  location   | total_spend 
-- --------------------------------------+-------------+-------------
--  c9eca26c-dfc4-4569-b404-ace1f3c27c2c | France      |    34935.70
--  662af3bb-cd98-42b8-a299-6b42c23821e6 | Singapore   |    33831.78
--  bf3e38e6-29c9-40c0-97a2-3ceaa7d305ad | Senegal     |    31525.73
--  3c8e3261-bb06-4452-9342-11850addf518 | Switzerland |    31449.58
--  f2e8a54d-6437-43ef-822c-74af0addcca4 | Liberia     |    30999.77

WITH checkouts AS (
	-- CTE1 ->> checkouts: 
    -- filter rows with successful checkouts identified by custmer_id
    SELECT * 
    FROM alt_school.events
    WHERE customer_id IN (
        SELECT customer_id 
        FROM alt_school.events AS e 
        WHERE e.event_data->>'status' = 'success'
    )
),
removed_items AS (
	-- CTE2 ->> removed_items
    -- filter rows with items removed from cart after adding to the cart
    SELECT event_id, customer_id, event_data, CONCAT(customer_id, '_', event_data->>'item_id') AS ce 
    FROM alt_school.events
    WHERE CONCAT(customer_id, '_', event_data->>'item_id') IN (
        SELECT CONCAT(customer_id, '_', event_data->>'item_id') 
        FROM alt_school.events 
        WHERE event_data->>'event_type' = 'remove_from_cart'
    )
    AND CONCAT(customer_id, '_', event_data->>'item_id') IN (
        SELECT CONCAT(customer_id, '_', event_data->>'item_id') 
        FROM alt_school.events 
        WHERE event_data->>'event_type' = 'add_to_cart'
    )
),
checker as (
	-- CTE3 ->> checker
    -- table with only items that were added to the cart, and made it successful checkouts 
	SELECT * 
	FROM checkouts
	WHERE event_id NOT IN (
		SELECT event_id FROM removed_items
	)
)

-- solution query:
-- 

SELECT 
    c1.customer_id,
    c2.location,
    SUM((p.price * (c1.event_data->>'quantity')::NUMERIC)) AS total_spend
FROM 
    checker AS c1
JOIN 
    alt_school.products AS p ON c1.event_data->>'item_id' = CAST(p.id AS TEXT)
JOIN 
    alt_school.customers AS c2 ON c1.customer_id = c2.customer_id
WHERE 
    c1.event_data->>'event_type' = 'add_to_cart'
GROUP BY 
    c1.customer_id, c2.location
ORDER BY 
    total_spend DESC
LIMIT 5;



-- part2.b.i: the most common location (country) where successful checkouts occurred.

-- location | checkout_count 
-- ---------+----------------
-- Korea    |             17

WITH checkouts AS (
	-- CTE1 ->> checkouts: 
    -- filter rows with successful checkouts identified by custmer_id
    SELECT * 
    FROM alt_school.events
    WHERE customer_id IN (
        SELECT customer_id 
        FROM alt_school.events AS e 
        WHERE e.event_data->>'status' = 'success'
    )
),
removed_items AS (
	-- CTE2 ->> removed_items
    -- filter rows with items removed from cart after adding to the cart
    SELECT event_id, customer_id, event_data, CONCAT(customer_id, '_', event_data->>'item_id') AS ce 
    FROM alt_school.events
    WHERE CONCAT(customer_id, '_', event_data->>'item_id') IN (
        SELECT CONCAT(customer_id, '_', event_data->>'item_id') 
        FROM alt_school.events 
        WHERE event_data->>'event_type' = 'remove_from_cart'
    )
    AND CONCAT(customer_id, '_', event_data->>'item_id') IN (
        SELECT CONCAT(customer_id, '_', event_data->>'item_id') 
        FROM alt_school.events 
        WHERE event_data->>'event_type' = 'add_to_cart'
    )
),
checker as (
	-- CTE3 ->> checker
    -- table with only items that were added to the cart, not removed and made it successful checkouts
	SELECT * 
	FROM checkouts
	WHERE event_id NOT IN (
		SELECT event_id FROM removed_items
	)
)

SELECT 
    c2.location,
    COUNT(DISTINCT c1.customer_id) AS checkout_count
FROM 
    checker AS c1 
JOIN 
    alt_school.customers AS c2 ON c1.customer_id = c2.customer_id  
WHERE 
    event_data->>'status' = 'success' 
GROUP BY 
    c2.location
ORDER BY 
    checkout_count DESC
LIMIT 1;



-- part 2.b.ii : customers who abandoned their carts and count the number of events (excluding visits) that occurred before the abandonment.

--              customer_id              | num_events 
--  -------------------------------------+------------
--  1c2b1a0d-4627-42cb-a55a-24c7c92611b0 |         22
--  713fe25b-a6c1-4978-9a56-2a5f711137d1 |         22
--  82ae4c93-06a8-4530-9865-d06676acfb6f |         22
--  3a09f477-dbee-4a17-9ef0-36f6bbd2e1dc |         22
--  eb7dcb88-073d-403e-bdd4-1e5725fe2338 |         22
--  8afb120e-84a2-4d64-afc5-18891385d3b3 |         22
--  b1e5d31e-1feb-41cf-9a63-968c70c33744 |         22
--  70676244-3cd0-40f0-a749-8a406059e70c |         22
--  b4ee8d72-9064-4372-85c7-7ae091a0572c |         22
--  f0b1a808-7def-4d7f-b2cb-723e92797f3f |         22
--  2519a6f0-4287-40b5-a0eb-c994bace8543 |         22
--  eeeea458-d704-4ef9-b7e6-618d2a8c47ed |         21
--  7105dba6-13c9-46f1-947f-9b8c246d14a5 |         21
--  a6a41da2-3e3c-4ef3-99e3-41e4777581a1 |         21
--  64af4631-72c1-4388-ab42-38ebab1767ca |         21
--    ---   - -- - -- - -- -  ---        |         --
--                  < CONTD >            |  < CONTD >

with sheet1 as (
	-- this query selects all event types other than visits from abandoned carts.
	-- here, we have an abandoned cart as a cart that does not make a successful checkout.
	select * from alt_school.events
		where customer_id not in (
			select customer_id from alt_school.events where event_data->>'status'='success' or event_data ->> 'status' = 'failed'
		)
		and
		event_data ->> 'event_type'!='visit' and event_data->>'event_type'!='checkout'
)
select customer_id, count(event_data->>'event_type') as num_events  from sheet1
group by customer_id
order by num_events desc;



--part 2.b.iii

-- average_visits 
-- ---------------
--           4.47

with visit_per_customer as (
	---this subquery selects only visits from successful checkouts
	select distinct customer_id, count(customer_id) as num_visits
	from alt_school.events
	where event_data->>'event_type'='visit' and customer_id in (
		select customer_id from alt_school.events where event_data->>'status'='success'
	)
	group by customer_id
	order by num_visits desc
)

-- average visit per customer
select ROUND(AVG(num_visits), 2) as average_visits
from visit_per_customer;