-- Part 2a i
select id as product_id, name as product_name, count(name) as num_times_in_succesful_orders
from alt_school.orders
inner join alt_school.line_items
using (order_id)
inner join alt_school.products
on products.id = line_items.item_id 
where status = 'success' 
group by id, name
order by num_times_in_succesful_orders desc
limit 1;

-- Part 2a ii
SELECT
    c.customer_id,
    c.location,
    SUM(p.price * (e.event_date->>'quantity')::int) AS total_spend,
FROM
    alt_school.events e
INNER JOIN
    alt_school.orders o ON e.customer_id = o.customer_id
INNER JOIN
    alt_school.products p ON (e.event_date->>'item_id')::int = p.id
INNER JOIN
    alt_school.customers c ON o.customer_id = c.customer_id
WHERE
    e.event_date->>'event_type' = 'add_to_cart'
    AND e.customer_id IN (
        SELECT
            e2.customer_id
        FROM
            alt_school.events e2
        WHERE
            e2.event_date @> '{"event_type":"checkout"}'::jsonb
    )
    AND NOT EXISTS (
        SELECT 1
        FROM
            alt_school.events e3
        WHERE
            e3.customer_id = e.customer_id
            AND e3.event_date->>'event_type' = 'add_to_cart'
            AND e3.event_date->>'timestamp' > e.event_date->>'timestamp'
    )
GROUP BY
    c.customer_id, c.location
ORDER BY
    total_spend DESC
LIMIT
    5;
    

-- Part 2b i

select location , count(location) as checkout_count
from alt_school.events
inner join alt_school.orders
using (customer_id)
inner join alt_school.customers
using (customer_id)
where status = 'success' 
and event_date @> '{"event_type":"checkout"}'::jsonb
group by location
order by checkout_count desc
limit 1;

-- Part 2b ii

SELECT
    e.customer_id,
    COUNT(*) AS num_events
FROM
    alt_school.events e
WHERE
    e.event_date->>'event_type' = 'add_to_cart'
    AND NOT EXISTS (
        SELECT 1
        FROM alt_school.events e2
        WHERE e2.customer_id = e.customer_id
        AND e2.event_date->>'event_type' = 'checkout'
        AND e2.event_timestamp > e.event_timestamp
    )
    AND e.event_date->>'event_type' != 'visit'
GROUP BY
    e.customer_id;
    
    
-- Part 2b iii

SELECT
    ROUND(AVG(visits), 2) AS average_visits
FROM (
    SELECT
        e.customer_id,
        COUNT(*) AS visits
    FROM
        alt_school.events e
    WHERE
        e.event_date @> '{"event_type":"visit"}'::jsonb
        AND EXISTS (
            SELECT 1
            FROM alt_school.events e2
            WHERE e2.customer_id = e.customer_id
            AND e2.event_date @> '{"event_type":"checkout"}'::jsonb
        )
    GROUP BY
        e.customer_id
) AS subquery;