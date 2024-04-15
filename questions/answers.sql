-- Answer to Part 2A.1

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
    o.status = 'success'  -- Consider only successfully checked-out orders
GROUP BY
    li.item_id, p.name
ORDER BY
    num_times_in_successful_orders DESC
LIMIT 1;

--THOUGHTS/SUMMATION
-- What I first did was to aggregate the data from the LINE_ITEMS and ORDERS tables using the order_id column to link line items to orders.
-- then join the PRODUCTS table to get the product name based on the item_id because the LINE_ITEMS table typically contains references- 
-- to products through their item_id, which serves as a unique key linking to the id column in the PRODUCTS table.
-- which then enrich our query results with the product names, making it more informative and user-friendly

-- kindly note i made use of first letter of each table/columns as are aliases examples ar Li for list items, c=customers, p=product etc.

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

--THOUGHTS/SUMMATION
-- joined the ORDERS table with the CUSTOMERS table using the customer_id column to link orders to customers, then, joined the PRODUCTS table to get the price of each product.
--  sum up products purchased and then mix it by customer and they location- 

-- Answer to Part 2B.1

SELECT
    c.location AS location,
    COUNT(*) AS checkout_count
FROM
    ALT_SCHOOL.EVENTS e
JOIN
    ALT_SCHOOL.CUSTOMERS c ON e.customer_id = c.customer_id
WHERE
    e.event_data->>'status' = 'success'  -- Filter events with success status
    AND e.event_data->>'event_type' = 'checkout' -- Consider only checkout events
GROUP BY
    c.location
ORDER BY
    checkout_count DESC
LIMIT 1;

--THOUGHTS/SUMMATION
-- joined the EVENTS table with the CUSTOMERS table using the customer_id column to link events to customers.
-- further on filter events to include only those with a status of 'success' and an action of 'checkout', to indicates successful checkouts.
-- i noticed there are checkout events type with status 'failed' or 'cancelled' hence why i ensured that status must be success and event_type checkout to indicates successful checkouts

-- Answer to Part 2B.2

WITH Abandoned_Carts AS (
    SELECT
        customer_id,
        COUNT(*) AS num_events
    FROM
        ALT_SCHOOL.EVENTS
    WHERE
        event_data->>'event_type' = 'checkout'  -- Identify checkout events
        AND event_data->>'status' <> 'success'  -- Filter out successful checkouts
        AND event_data->>'event_type' <> 'visit'  -- Exclude visit 
        AND customer_id IS NOT NULL  -- Exclude events without a customer_id
    GROUP BY
        customer_id
)
SELECT
    AC.customer_id,
    AC.num_events
FROM
    Abandoned_Carts AC;

--THOUGHTS/SUMMATION
-- i noticed the event type from my search doesnt content abandoned carts we only have remove_from_cart
-- Cart abandonment usually refers to situations where users add items to their carts but fail to proceed to checkout
-- so i considered "checkout" events that were not successful (i.e., the user initiated the checkout process but did not complete the purchase) as instances of cart abandonment.
-- i used use CTE named Abandoned_Carts to identify instances of cart abandonment before proceeding to 
-- select the customer_id and the count of events (excluding visits) from the Abandoned_Carts CTE for each customer.


-- Answer to Part 2B.3

WITH Checkout_Customers AS (
    SELECT DISTINCT
        customer_id
    FROM
        ALT_SCHOOL.EVENTS
    WHERE
        event_data->>'event_type' = 'checkout'  -- Identify successful checkout events
        AND event_data->>'status' = 'success'  -- Filter out unsuccessful checkouts
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
            customer_id IN (SELECT customer_id FROM Checkout_Customers)  -- Consider only customers who completed a checkout
            AND event_data->>'event_type' = 'visit'  -- Identify visit events
        GROUP BY
            customer_id
    ) AS Visit_Counts;


--THOUGHTS/SUMMATION
-- Considered only customers who completed a checkout, then calculated the total number of visits for these customers and divide it by the number of customers who completed a checkout
--using a CTE named Checkout_Customers to identify customers who completed a checkout successfully.
-- then selected customer_id and count the number of visit events for each customer who completed a checkout in the subquery and filter only visit events
-- and then calculate the average number of visits per user  taking the average of the number of visits and round it to 2 decimal places.
