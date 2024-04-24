-- Question one answer: Identify the most ordered item based on the number of times it appears in successfully checked out orders.

SELECT
    p.id AS product_id,
    p.name AS product_name,
    COUNT(DISTINCT o.order_id) AS num_times_in_successful_orders
FROM
    alt_school_db.alt_school.products p
JOIN
    alt_school_db.alt_school.line_items li ON p.id = li.item_id 
JOIN
    alt_school_db.alt_school.orders o ON CAST(li.order_id AS uuid) = o.order_id
WHERE
    o.status = 'success'
GROUP BY
    p.id, p.name
ORDER BY
    num_times_in_successful_orders DESC
LIMIT 1;


-- Question two answer: Find the top 5 spenders without considering currency and without using the line_item table.

SELECT
    c.customer_id,
    c.location,
    SUM(p.price) AS total_spend
FROM
    alt_school_db.alt_school.events e
JOIN
    alt_school_db.alt_school.products p ON p.id = (e.event_date->>'item_id')::int
JOIN
    alt_school_db.alt_school.customers c ON e.customer_id::uuid = c.customer_id
JOIN
    alt_school_db.alt_school.orders o ON o.customer_id::uuid = c.customer_id
WHERE
    o.status = 'success'
GROUP BY
    c.customer_id ,c.location
ORDER BY
    total_spend DESC
LIMIT 5;


-- Question three answer: Determine the most common location where successful checkouts occurred.

SELECT
    c.location as location,
    count(*) as checkout_count
FROM
    alt_school.customers c
JOIN
    alt_school.events e on c.customer_id::uuid = e.customer_id::uuid
WHERE
    e.event_date->> 'status' = 'success'
GROUP BY
    c."location"
ORDER BY
    checkout_count desc
LIMIT 1;


-- Question four answer: Identify customers who abandoned their carts and count the number of events that occurred before the abandonment.

WITH AbandonedCarts AS (
    SELECT
        customer_id,
        MIN(event_timestamp) AS abandonment_time
    FROM
        alt_school.events
    WHERE
        event_date->>'event_type' = 'remove_from_cart'
    GROUP BY
        customer_id
)
SELECT
    e.customer_id::uuid,
    COUNT(*) AS num_events
FROM
    alt_school.events e
JOIN
    AbandonedCarts ac ON e.customer_id = ac.customer_id
WHERE
    e.event_timestamp < ac.abandonment_time
    AND e.event_date->>'event_type' != 'visit'
GROUP BY
    e.customer_id;

   
   SELECT
    AVG(total_visits)::numeric(10, 2) AS average_visits
FROM (
    SELECT
        c.customer_id,
        COUNT(e.event_date) AS total_visits
    FROM
        alt_school.customers c
    JOIN
        alt_school.events e ON c.customer_id = e.customer_id
    JOIN
        alt_school.orders o ON c.customer_id = o.customer_id
    WHERE
        e.event_data->>'event_type' = 'visit'
        AND o.status = 'success'
    GROUP BY
        c.customer_id
) AS subquery;

