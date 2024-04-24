--Part2 First Question
SELECT
    p.id,
    p.name,
    COUNT(*) AS num_times_in_successful_orders
FROM
    alt_school.products p
JOIN
    line_items li ON p.id = li.item_id
JOIN
    orders o ON li.order_id = o.order_id
WHERE
    o.status = 'success' 
GROUP BY
    p.id,
    p.name
ORDER BY
    num_times_in_successful_orders DESC
LIMIT 1;

--Part2 second question

SELECT
    o.customer_id,
    c.location,
    SUM(p.price * li.quantity) AS total_spend
FROM
    orders o
JOIN
    customers c ON o.customer_id = c.customer_id
JOIN
    line_items li ON o.order_id = li.order_id
JOIN
    products p ON li.item_id = p.id
GROUP BY
    o.customer_id,
    c.location
ORDER BY
    total_spend DESC
LIMIT 5;

--part2b First Question

SELECT c.location, COUNT(CASE WHEN e.event_data->>'status' = 'success' THEN 1 END) AS Check_out_count
FROM alt_school.events e
LEFT JOIN alt_school.customers c USING (customer_id)
GROUP BY c.location
order by check_out_count desc
limit 5;

--part2b Second Question
SELECT
    e.customer_id,
    COUNT(*) AS num_events
FROM
    alt_school.events e
WHERE
    e.customer_id NOT IN (
        SELECT
            customer_id
        FROM
            alt_school.events
        WHERE
            event_data->>'status' = 'success'
    )
    AND e.event_data->>'event_type' != 'visit'
GROUP BY
    e.customer_id;
   
--part2b Third Question

SELECT
    ROUND(AVG(num_visits)::numeric, 2) AS average_visits
FROM (
    SELECT
        e.customer_id,
        COUNT(CASE WHEN e.event_data->>'event_type' = 'visit' THEN 1 END) AS num_visits
    FROM
        alt_school.events e
    WHERE
        e.customer_id IN (
            SELECT DISTINCT
                customer_id
            FROM
                alt_school.events
            WHERE
                event_data->>'event_type' = 'checkout_success'
        )
    GROUP BY
        e.customer_id
) AS subquery;
