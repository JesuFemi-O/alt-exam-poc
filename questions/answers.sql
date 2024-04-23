
-- part 2.a.i: most ordered item based on the number of times it appears in an order cart that checked out successfully?
-- 

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
-- 

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

with sheet1 as (
	-- this query selects all event types other than visits from abandoned carts.
	-- here, we have an abandoned cart as a cart that does not make  asuccessful checkout.
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

with visit_per_customer as (
	---this subquery selects all visits from successful checkouts
	select distinct customer_id, count(customer_id) as num_visits
	from alt_school.events
	where event_data->>'event_type'='visit' and customer_id in (
		select customer_id from alt_school.events where event_data->>'status'='success'
	)
	group by customer_id
	order by num_visits desc
)
select ROUND(AVG(num_visits), 2) 
from visit_per_customer;