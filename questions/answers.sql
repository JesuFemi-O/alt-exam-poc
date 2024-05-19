
SELECT
    li.item_id AS product_id,
    p.name AS product_name,
    COUNT(DISTINCT o.order_id) AS num_times_in_successful_orders
FROM
    ALT_SCHOOL.LINE_ITEMS li
JOIN
    ALT_SCHOOL.ORDERS o ON li.order_id = o.order_id
JOIN
    ALT_SCHOOL.PRODUCTS p ON li.item_id = p.id
WHERE
    o.status = 'success' 
GROUP BY
    li.item_id, p.name
ORDER BY
    num_times_in_successful_orders DESC
LIMIT 1;



-- Answer to Part 2A.2 

SELECT
    c.customer_id,
    c.location,
    SUM(p.price) AS total_spend
FROM
    ALT_SCHOOL.ORDERS o
JOIN
    ALT_SCHOOL.CUSTOMERS c ON o.customer_id = c.customer_id
JOIN
    ALT_SCHOOL.PRODUCTS p ON id = p.id
GROUP BY
    c.customer_id, c.location
ORDER BY
    total_spend DESC
LIMIT 5;

-- Answer to Part 2B.1

SELECT
    c.location AS location,
    COUNT(*) AS checkout_count
FROM
    ALT_SCHOOL.EVENTS e
JOIN
    ALT_SCHOOL.CUSTOMERS c ON e.customer_id = c.customer_id
WHERE
    e.event_data->>'status' = 'success' 
    AND e.event_data->>'event_type' = 'checkout' 
GROUP BY
    c.location
ORDER BY
    checkout_count DESC
LIMIT 1;


-- Answer to Part 2B.2

WITH Abandoned_Carts AS (
    SELECT
        customer_id,
        COUNT(*) AS num_events
    FROM
        ALT_SCHOOL.EVENTS
    WHERE
        event_data->>'event_type' = 'checkout'  
        AND event_data->>'status' <> 'success'  
        AND event_data->>'event_type' <> 'visit' 
        AND customer_id IS NOT NULL 
    GROUP BY
        customer_id
)
SELECT
    AC.customer_id,
    AC.num_events
FROM
    Abandoned_Carts AC;


-- Answer to Part 2B.3

WITH Checkout_Customers AS (
    SELECT DISTINCT
        customer_id
    FROM
        ALT_SCHOOL.EVENTS
    WHERE
        event_data->>'event_type' = 'checkout'  
        AND event_data->>'status' = 'success'  
)
SELECT
    ROUND(AVG(num_visits)::numeric, 2) AS average_visits
FROM
    (
        SELECT
            customer_id,
            COUNT(*) AS num_visits
        FROM
            ALT_SCHOOL.EVENTS
        WHERE
            customer_id IN (SELECT customer_id FROM Checkout_Customers) 
            AND event_data->>'event_type' = 'visit' 
        GROUP BY
            customer_id
    ) AS Visit_Counts;