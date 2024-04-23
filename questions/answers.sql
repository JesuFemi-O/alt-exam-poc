------QUESTION 2A (i)-------

---Thought Process
-- Identify Successful Orders: I first identify the customers who made successful orders. by filtering orders with status set to 'success' 
-- Identify Successfully Checked Out Products: For each of these customers, I then identify the products that were successfully checked out by filtering the events table setting status to success and event type to checkout.
-- Calculate the Most Ordered Product: I then calculate which product has been ordered the most by counting the number of times each product appears in the successfully checked out products.
-- Retrieve Product Information: Finally, I retrieve the name of the most ordered product along with the count and product id as required.


-- creating the first CTE to identify customer id that made successful orders
with successful_orders as
( 
	select e.customer_id from alt_school.events e 	
	join alt_school.orders o on e.customer_id = o.customer_id
	where o.status = 'success' 
),
-- creating the second CTE to identify successfully checked out products
successful_checkouts as (
  select e.customer_id,
     li.item_id as product_id -- Extracting the product id from item id column in the line items table
  from alt_school.events e
    join successful_orders so on e.customer_id = so.customer_id
    join alt_school.line_items li on e.event_data ->> 'order_id' = li.order_id :: text
    where e.event_data ->> 'status' = 'success' and e.event_data ->> 'event_type' = 'checkout' -- Filtering for events that successfully checked out
)

--- query to answer the question ----

select sc.product_id, 
 		p.name product_name, 
 		count(*) num_times_in_successful_order
 from successful_checkouts sc
 join alt_school.products p on sc.product_id = p.id
 group by sc.product_id, p.name
 order by count(product_id) desc
 limit 1; --limiting result to 1 to return the most ordered item.


------QUESTION 2A (ii)-------
--- I FOUND THIS QUESTION VERY TOUGH, I HOPE I GET IT RIGHT-----
-- Thought Process:
-- Identify Customers with Successful Checkouts: I first identify customers who made successful checkouts by filtering the events table with the status field set to 'success'.
-- Identify Items in the Cart during Checkout: For each of these customers, I then identify the items that were in the cart during checkout.
-- Calculate Total Spend per Item: Next I did was to calculate the total spend per customer by multiplying the quantity of each item by its price.
-- Get Total Spend for Each Customer: Finally, I calculate the total spending for each customer and retrieve their location. 
-- Group the Result by Customer and Location: I then grouped the result by customer and location. The result is also ordered by total spend in descending order, and limited to the top 5 spenders as required.


with successful_checkouts AS (
    select e.customer_id,
        cast(e.event_data ->> 'item_id' as integer) AS item_id, 
        cast(e.event_data ->> 'quantity' as integer) AS quantity, 
        (select count(*)
         from alt_school.events ae
         where ae.customer_id = e.customer_id
           and ae.event_data ->> 'item_id' = e.event_data ->> 'item_id'
           and ae.event_data ->> 'status' = 'add_to_cart') AS cart_items -- counting the items in the cart during checkout
    from alt_school.events e
    where e.customer_id IN (
            select e.customer_id 
            from alt_school.events e 
            where e.event_data ->> 'status' = 'success') -- filtering for successful checkouts
        		and e.event_data ->> 'event_type' = 'add_to_cart'
    		order by e.customer_id
 )
 select sc.customer_id customer_id,
 		c.location location,
 		sum(sc.quantity * p.price) total_spend
 from successful_checkouts sc
 	join alt_school.customers c using(customer_id)
 	join alt_school.products p on sc.item_id = p.id 
 group by sc.customer_id, c."location" 
 order by total_spend desc
 limit 5;



--------QUESTION 2B (i)----------------------
----Thought Process ------
-- Joining Tables: I wrote a query to join the customers and events tables on the customer_id.
-- Filter Successful Checkouts: also filter the events to include only successful checkouts.
-- Group by Location: group the result by location.
-- Count Checkouts: count the number of successful checkouts for each location.
-- Find the Location with the Most Checkouts: Finally, I retrieve the location with the highest number of successful checkouts.

select c.location location, 
		count(*) checkout_count	-- select location and checkout_count coloumns as required
from alt_school.customers c 
  join alt_school.events e on c.customer_id = e.customer_id 
  where e.event_data ->> 'status' = 'success' -- filtering event_data from events table setting status as 'success'
  group by 1 
  order by 2 desc
  limit 1;


-------QUESTION 2B (ii)-----------

select e.customer_id, 
	count(*) num_event --selecting customer id and counting number of events before abandonments as required.
from alt_school.events e 
  where e.event_data ->> 'event_type' != 'visit' --excluding visit events
  group by e.customer_id 
  order by num_event desc;


--------QUESTION 2B (iii)-----------
------Thought Process-----
-- Identify Successful Visits: The CTE identifies the customers who made successful visits that is visited and completed an order as required.
-- Calculate the Number of Visits per Customer: For each of these customers, I then calculate the number of visits.
-- Calculate the Average Visits per Customer: Finally, I calculate the average number of visits by customers before completing an order and rounded to 2 d.p as required.

with customer_visit as 
(select e.customer_id, count(*) num_visits
  from alt_school.events e
  where event_data ->> 'event_type' = 'visit' and  --filtering event data by setting event type to visit to return customers that visited
  e.customer_id in (select e.customer_id from alt_school.events e where e.event_data ->> 'status' = 'success') -- further filtering to return visitors that completed an order
  group by e.customer_id)
select round(avg(cv.num_visits),2) average_visits -- calculating average visits before completing an order.
from customer_visit cv;