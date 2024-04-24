
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

-- Create customers table
CREATE TABLE IF NOT EXISTS ALT_SCHOOL.CUSTOMERS
(
    customer_id UUID PRIMARY KEY,
    device_id UUID NOT NULL,
    location VARCHAR NOT NULL,
    currency VARCHAR NOT NULL
);

-- Copy customers data
COPY ALT_SCHOOL.CUSTOMERS (customer_id, device_id, location, currency)
FROM '/data/customers.csv' DELIMITER ',' CSV HEADER;

-- Complete orders table
CREATE TABLE IF NOT EXISTS ALT_SCHOOL.ORDERS
(
    order_id UUID NOT NULL PRIMARY KEY,
    customer_id UUID NOT NULL,
    status VARCHAR NOT NULL,
    checked_out_at TIMESTAMP
);

-- Copy orders data
COPY ALT_SCHOOL.ORDERS (order_id, customer_id, status, checked_out_at)
FROM '/data/orders.csv' DELIMITER ',' CSV HEADER;

-- Complete line_items table
CREATE TABLE IF NOT EXISTS ALT_SCHOOL.LINE_ITEMS
(
    line_item_id BIGINT PRIMARY KEY,
    order_id UUID NOT NULL,
    item_id BIGINT NOT NULL,
    quantity BIGINT NOT NULL
);

-- Copy line_items data
COPY ALT_SCHOOL.LINE_ITEMS (line_item_id, order_id, item_id, quantity)
FROM '/data/line_items.csv' DELIMITER ',' CSV HEADER;

-- Complete events table
CREATE TABLE IF NOT EXISTS ALT_SCHOOL.EVENTS
(
    event_id BIGINT PRIMARY KEY,
    customer_id UUID NOT NULL,
    event_data JSONB NOT NULL,
    event_timestamp TIMESTAMP NOT NULL
);

-- Copy events data
COPY ALT_SCHOOL.EVENTS (event_id, customer_id, event_data, event_timestamp)
FROM '/data/events.csv' DELIMITER ',' CSV HEADER;

