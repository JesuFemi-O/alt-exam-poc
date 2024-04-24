-- Create schema
CREATE SCHEMA IF NOT EXISTS ALT_SCHOOL;
-- create and populate tables
create table if not exists ALT_SCHOOL.PRODUCTS
(
    id  serial primary key,
    name varchar not null,
    price numeric(10, 2) not null
);
COPY ALT_SCHOOL.PRODUCTS (id, name, price)
FROM '/data/products.csv' DELIMITER ',' CSV HEADER;

create table if not exists ALT_SCHOOL.CUSTOMERS
(
    customer_id uuid primary key,
    device_id varchar not null,
    location varchar not null, 
    currency varchar not null
);
COPY ALT_SCHOOL.CUSTOMERS (customer_id, device_id, location, currency)
FROM '/data/customers.csv' DELIMITER ',' CSV HEADER;

-- TODO: provide the command to copy the customers data in the /data folder into ALT_SCHOOL.CUSTOMERS

-- TODO: complete the table DDL statement
create table if not exists ALT_SCHOOL.ORDERS
(
    order_id uuid not null primary key,
    customer_id varchar not null,
    status varchar not null,
    checked_out_at timestamp
    -- provide the other fields
);
COPY ALT_SCHOOL.ORDERS (order_id, customer_id,status,checked_out_at)
FROM '/data/orders.csv' DELIMITER ',' CSV HEADER;

-- provide the command to copy orders data into POSTGRES
create table if not exists ALT_SCHOOL.LINE_ITEMS
(
    line_item_id varchar primary key,
    order_id varchar not null,
    item_id int not null,
    quantity int not null
    -- provide the remaining fields
);
-- provide the command to copy ALT_SCHOOL.LINE_ITEMS data into POSTGRES
COPY ALT_SCHOOL.LINE_ITEMS (line_item_id, order_id, item_id, quantity)
FROM '/data/line_items.csv' DELIMITER ',' CSV HEADER;

-- setup the events table following the examle provided
create table if not exists ALT_SCHOOL.EVENTS
(
    -- TODO: PROVIDE THE FIELDS
    event_id varchar primary key,
    customer_id varchar not null,
    event_date json not null,
    event_timestamp timestamp not null
);
COPY ALT_SCHOOL.EVENTS (event_id, customer_id, event_date, event_timestamp)
FROM '/data/events.csv' DELIMITER ',' CSV HEADER;

-- TODO: provide the command to copy ALT_SCHOOL.EVENTS data into POSTGRES






