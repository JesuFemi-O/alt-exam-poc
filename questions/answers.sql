Part 2ai
--what is the most ordered item based on the number of times it appears in an order cart that checked out successfully?
SELECT p.id as product_id, p.name as product_name,count (*) as quantity 
FROM alt_school.events AS e
-- using join to create connections between tables
	INNER JOIN alt_school.customers AS c ON e.customer_id = c.customer_id
	INNER JOIN alt_school.orders AS o ON c.customer_id = o.customer_id
	INNER JOIN  alt_school.line_items as l ON o.order_id = l.order_id
	INNER JOIN  alt_school.products as p ON l.item_id = p.id
	
--- filtering to get only successfully checked out items based on events_data column
WHERE e.event_data ->> 'event_type' = 'checkout' 
  AND e.event_data ->> 'status' = 'success'

 --checking that the order ids for the successful check outs match the information in the orders table
  AND o.order_id = (jsonb_extract_path_text(e.event_data, 'order_id'))::UUID
 --grouping each product
  group by l.item_id, p.id 
--arranging in descending order 
  order by quantity desc
--display only 1 result to see the most ordered item
  limit 1;
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

--Part 2aii
 --Top 5 spenders
 SELECT e.customer_id AS customer_id, 
       c.location AS location,
--adding the product of the price per quantity 
--this does not yet filter for successful checkouts
-- and does not yet consider items removed from cart      
       SUM(p.price * (jsonb_extract_path_text(e.event_data, 'quantity')::int)) AS total_spend
FROM alt_school.events AS e
-- Using join to create connections between tables
INNER JOIN alt_school.customers AS c ON e.customer_id = c.customer_id
--using event_data in events table to link id in products table using item_id 
INNER JOIN alt_school.products AS p ON (jsonb_extract_path_text(e.event_data, 'item_id')::int = p.id)
--grouping the calulations of th etotal spend per customer
GROUP BY e.customer_id, c.location
ORDER BY total_spend desc
--top 5 spenders
limit 5;

===========================================================================================================
===========================================================================================================

--Part 2bi 
--Determine the most common location (country) where successful checkouts occurred
 SELECT 
    c.location AS location, 
--counting all cases of checkout only
    COUNT(CASE WHEN e.event_data ->> 'event_type' = 'checkout' THEN 1 ELSE NULL END) AS checkout_count
FROM 
    alt_school.events AS e
-- Using join to create connections between tables
INNER JOIN 
    alt_school.customers AS c ON e.customer_id = c.customer_id
INNER JOIN 
    alt_school.orders AS o ON c.customer_id = o.customer_id

-- Filtering to get only successfully checked out items based on events_data column
WHERE 
    e.event_data ->> 'event_type' = 'checkout' 
    AND e.event_data ->> 'status' = 'success' 
   
-- Grouping by location
GROUP BY 
    c.location
-- Arranging in descending order 
ORDER BY 
    checkout_count desc
--most commun location where successful checkouts occured    
    limit 1;
   
-----------------------------------------------------------------------------------------------------


--Part 2bii
--Count the number of events (excluding visits) that occurred before the abandonment.   
SELECT 
    e.customer_id,
-- count number of events excluding visits and checkouts
-- does not yet take into account that some of these events may have led to checkouts
    COUNT(
        CASE WHEN e.event_data ->> 'event_type' != 'checkout' 
                  AND e.event_data ->> 'event_type' != 'visit'
             THEN 1 ELSE NULL 
        END
    ) AS num_events
FROM 
    alt_school.events AS e
-- attempt to filter out events/visits that led to check outs    
WHERE 
    e.customer_id NOT IN (
        SELECT 
            e2.customer_id
        FROM 
            alt_school.events AS e2
        WHERE 
            e2.event_data ->> 'event_type' = 'checkout'
    )
-- grouping the data for each customer    
GROUP BY 
    e.customer_id
--ordered from top to bottom since this looks more interesting and may be worth reviewing
-- asc just started with 1 did not realy capture the frequency
ORDER BY 
    num_events desc;

----------------------------------------------------------------------------------------------------------- 

--Part 2aiii
--Using CTE to get granular calculation     
WITH tab AS (
    SELECT 
--counting the total number of customers ignoring duplicates   
        COUNT(DISTINCT customer_id) AS total_customers,
--number of all events minus successful checkouts       
        COUNT(        
            CASE WHEN e.event_data ->> 'event_type' IS NOT null
            			and 'event_type' != 'checkout' 
            			and 'status' != 'success'
                 THEN 1 ELSE NULL 
            END
        ) AS num_events
    FROM 
        alt_school.events AS e
    --attempt to filter for cutomers with successful checkouts
    --by checking if the customer_id has a history of check_out  
    WHERE 
        e.customer_id IN (
            SELECT 
                e2.customer_id
            FROM 
                alt_school.events AS e2
            -- filters for successful checkouts   
            WHERE 
                e2.event_data ->> 'event_type' = 'checkout'
                and e2.event_data ->> 'status' = 'success'
        )
)
--calculation to find average
--cast function used to 'convert' data type for the purpose of this funtion
--round function used to limit the decimal places to 2
--using formular sum of events/number of events per customer
SELECT 
    ROUND(CAST(SUM(num_events) AS numeric) / (SELECT total_customers FROM tab), 2) AS average_visits
FROM 
    tab;
   
