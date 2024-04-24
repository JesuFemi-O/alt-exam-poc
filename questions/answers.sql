1. --most_successful_ordered_item
SELECT 
li.item_id AS product_id, 
p.name AS product_name, 
COUNT(*) AS most_successful_ordered_item
FROM line_items li
JOIN orders o ON li.order_id = o.order_id
JOIN products p ON li.item_id = p.id
WHERE o.status = 'success'
GROUP BY li.item_id, p.name
ORDER BY most_successful_ordered_item DESC
LIMIT 1;
---output - 
product_id	product_name	    most_successful_ordered_item
7	       Apple AirPods Pro	    735



-- Top 5 spenders without using currency
SELECT 
o.customer_id, 
c.location, 
SUM(p.price * li.quantity) AS total_spend
FROM alt_school.orders o
JOIN alt_school.line_items li ON o.order_id = li.order_id
JOIN alt_school.products p ON li.item_id = p.id
JOIN alt_school.customers c ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.location
ORDER BY total_spend DESC
LIMIT 5;

---output - 
customer_id                              location                   total_spend
f2bf7442-1556-43cc-b927-51870d20743f	Netherlands Antilles	    41671.35
7bf3eb6d-af40-4d02-bfca-047ece08857e	Bouvet Island (Bouvetoya)	41617.65
851d9d01-1fd2-4027-9ff2-55ec97185eb3	Chile	                    41555.61
50b09933-0454-4b2a-8986-92ece7ed4937	Comoros	                    41551.58
5320e15e-cf74-459b-be51-b5eeda340cf3	Bahamas	                    41507.53


--most common successful checkout location
SELECT c.location, COUNT(*) AS checkout_count
FROM alt_school.events e
JOIN alt_school.customers c ON e.customer_id = c.customer_id
JOIN alt_school.orders o ON e.event_data->>'order_id' = o.order_id::text
WHERE e.event_data->>'event_type' = 'checkout' AND o.status = 'success'
GROUP BY c.location
ORDER BY checkout_count DESC
LIMIT 1;

--output the successful checkout
location|checkout_count|
--------+--------------+
Korea   |            17|



--customers who abandoned their carts excluding visits
SELECT 
e.customer_id, 
COUNT(*) AS num_events
FROM alt_school.events e
WHERE e.event_data->>'event_type' != 'visit' 
AND e.customer_id 
NOT IN (SELECT DISTINCT customer_id FROM alt_school.events WHERE e.event_data->>'event_type' = 'checkout')
GROUP BY e.customer_id
ORDER BY num_events DESC;

-- output limit 6
customer_id                         |num_events|
------------------------------------+----------+
2561d443-c77b-41a6-8077-5a61aadedb47|        23|
3a09f477-dbee-4a17-9ef0-36f6bbd2e1dc|        22|
b4ee8d72-9064-4372-85c7-7ae091a0572c|        22|
66901052-8fe2-44b8-8b7e-8cfb9eecdca7|        22|
f0b1a808-7def-4d7f-b2cb-723e92797f3f|        22|
a68a4174-0109-4469-ab21-d49b48750829|        22|


-- average visits
SELECT ROUND(AVG(num_visits), 2) AS average_visits
FROM (
    SELECT e.customer_id, COUNT(*) AS num_visits
    FROM alt_school.events e
    WHERE e.event_data->>'event_type' = 'visit' AND e.customer_id IN (
        SELECT DISTINCT customer_id
        FROM alt_school.events
        WHERE event_data->>'event_type' = 'checkout'
    )
    GROUP BY e.customer_id
) subquery;

--output for average_visits
average_visits|
--------------+
          4.51|